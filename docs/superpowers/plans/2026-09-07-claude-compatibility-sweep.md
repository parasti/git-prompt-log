# Claude Code Compatibility Sweep Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `git prompt-log`'s session-inspection, exclusion, association, and identity paths work for Claude Code, without changing Antigravity behavior.

**Architecture:** Dispatch the Claude-affected paths through the existing adapter registry; keep all Antigravity code paths byte-for-byte and confine new logic to `ClaudeCodeAdapter` and harness-neutral command code. The existing (Antigravity-heavy) suite is the regression guarantee.

**Tech Stack:** Python 3 stdlib, `unittest`, git.

**Spec:** `docs/superpowers/specs/2026-09-07-claude-compatibility-design.md`

## Global Constraints

- Do NOT edit `AntigravityAdapter`, `get_brain_dir`, `get_brain_dirs`, `find_session_dir`, `parse_session_transcript`, or `AntigravityAdapter._session_matches_repo`.
- New behavior must be gated on the resolved adapter being non-Antigravity, or live inside `ClaudeCodeAdapter`.
- The full existing test suite must pass after every task: `python3 -m unittest discover -s tests -p "test_*.py"`.
- The tool is a single script: `bin/git-prompt-log` (Python, no extension). Tests import it via `gpn = importlib.machinery.SourceFileLoader("git_prompt_log", str(bin_path)).load_module()`.
- Tests run inside a harness that scrubs agent env vars module-wide (`setUpModule`); tests that need `CLAUDE_CODE_SESSION_ID` must set it explicitly in the subprocess/`os.environ`.

**Deviation from spec (approved at plan time):** Spec Section 2 (add `CLAUDE_CODE_SESSION_ID` to the `cmd_session` env source at line ~2909) is redundant — the registry dispatch added in Task 1 resolves Claude sessions with or without that env var. No env-line edit is made; Task 1's test proves resolution works both ways.

---

## Task 1: `cmd_session` harness-aware resolution

Make `git prompt-log session` list a Claude session's prompts. Antigravity's resolution path stays unchanged; the Claude/other path uses the registry's already-parsed prompts.

**Files:**
- Modify: `bin/git-prompt-log` — `cmd_session` (around lines 2888–2960)
- Test: `tests/test_git_prompt_log.py` — new class `TestClaudeSessionCommand`

**Interfaces:**
- Consumes: `REGISTRY.find_session_data(adapter_name="auto", repo_root=<Path>, apply_session_excludes=False) -> (adapter, dict|None)` where dict has keys `session_id`, `prompts`, `harness`, `detected_model`.
- Produces: no new public symbols.

- [ ] **Step 1: Write the failing test**

Add to `tests/test_git_prompt_log.py` (end of file, before `if __name__`):

```python
class TestClaudeSessionCommand(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.repo = Path(self.tmp.name) / "repo"
        self.repo.mkdir()
        subprocess.run(["git", "init", "-b", "main"], cwd=self.repo, check=True, capture_output=True)
        subprocess.run(["git", "config", "user.name", "T"], cwd=self.repo, check=True)
        subprocess.run(["git", "config", "user.email", "t@e.com"], cwd=self.repo, check=True)
        subprocess.run(["python3", str(bin_path), "init"], cwd=self.repo, check=True, capture_output=True)
        # Claude transcript filed in repo/.claude/<sid>.jsonl (a dir _get_claude_dirs scans).
        self.sid = "claude-sess-001"
        cdir = self.repo / ".claude"
        cdir.mkdir()
        (cdir / f"{self.sid}.jsonl").write_text("\n".join([
            json.dumps({"type": "user", "cwd": str(self.repo),
                        "message": {"role": "user", "content": "First real prompt"},
                        "promptSource": "typed", "timestamp": "2026-09-07T10:00:00Z"}),
            json.dumps({"type": "assistant", "message": {"model": "claude-opus-4-8"}}),
            json.dumps({"type": "user", "cwd": str(self.repo),
                        "message": {"role": "user", "content": "Second real prompt"},
                        "promptSource": "typed", "timestamp": "2026-09-07T10:01:00Z"}),
        ]), encoding="utf-8")

    def tearDown(self):
        self.tmp.cleanup()

    def _run_session(self, extra_env=None):
        env = os.environ.copy()
        env["PATH"] = f"{bin_path.parent}:{env.get('PATH', '')}"
        if extra_env:
            env.update(extra_env)
        return subprocess.run(["python3", str(bin_path), "session"],
                              cwd=self.repo, capture_output=True, text=True, env=env)

    def test_session_lists_claude_prompts_plain_shell(self):
        res = self._run_session()
        self.assertEqual(res.returncode, 0, res.stderr)
        self.assertIn("First real prompt", res.stdout)
        self.assertIn("Second real prompt", res.stdout)

    def test_session_lists_claude_prompts_with_session_env(self):
        res = self._run_session({"CLAUDE_CODE_SESSION_ID": self.sid})
        self.assertEqual(res.returncode, 0, res.stderr)
        self.assertIn("First real prompt", res.stdout)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python3 -m unittest tests.test_git_prompt_log.TestClaudeSessionCommand -v`
Expected: FAIL — stderr "No prompts found in session …" / assertion on missing "First real prompt".

- [ ] **Step 3: Implement the harness-aware resolution**

In `bin/git-prompt-log`, `cmd_session`: add a `raw_data = None` initializer immediately after `t_path = None` (near line 2894), so:

```python
    t_path = None
    raw_data = None
    session_id = getattr(args, "session", None)
```

Then replace the fallback block (currently lines ~2936–2955, the `if not session_id or not t_path:` block that re-derives `t_path` via brain dirs) with:

```python
        if not session_id or not t_path:
            adapter, data = REGISTRY.find_session_data(
                adapter_name="auto", repo_root=repo_root, apply_session_excludes=False
            )
            if not data:
                sys.stderr.write("No active agent session transcript found.\n")
                return 1
            session_id = data.get("session_id") or session_id
            if adapter and adapter.name == "antigravity":
                # Antigravity: resolve the on-disk transcript exactly as before.
                s_dir = find_session_dir(session_id)
                if s_dir:
                    cand = s_dir / ".system_generated" / "logs" / "transcript.jsonl"
                    if cand.exists():
                        t_path = cand
                if not t_path:
                    for b in get_brain_dirs():
                        cand = b / session_id / ".system_generated" / "logs" / "transcript.jsonl"
                        if cand.exists():
                            t_path = cand
                            break
                if not t_path:
                    t_path = get_brain_dir() / session_id / ".system_generated" / "logs" / "transcript.jsonl"
            else:
                # Claude / other harness: use the registry-parsed prompts directly.
                raw_data = data
```

Then change the parse line (currently line ~2957) from:

```python
    raw_data = parse_session_transcript(t_path, apply_session_excludes=False, repo_root=repo_root)
```

to:

```python
    if raw_data is None:
        raw_data = parse_session_transcript(t_path, apply_session_excludes=False, repo_root=repo_root)
```

(The `session_excludes = load_session_excludes(...)` line just above it stays.)

- [ ] **Step 4: Run tests to verify they pass**

Run: `python3 -m unittest tests.test_git_prompt_log.TestClaudeSessionCommand -v`
Expected: PASS (both tests).

- [ ] **Step 5: Run the full suite (Antigravity regression guard)**

Run: `python3 -m unittest discover -s tests -p "test_*.py"`
Expected: OK, all tests pass.

- [ ] **Step 6: Commit**

```bash
git add bin/git-prompt-log tests/test_git_prompt_log.py
git commit -m "fix(session): resolve Claude sessions via registry, keep Antigravity path"
```

---

## Task 2: Claude exclusion round-trip

`session drop`/`restore` must work for a Claude session. This rides on Task 1 plus the existing `load_session_excludes`/`save_session_excludes` (which already use a `<common_git>/prompt-log/sessions/<sid>.json` fallback when no Antigravity brain dir exists). This task verifies the round-trip and fixes any glue if the test fails.

**Files:**
- Test: `tests/test_git_prompt_log.py` — add to `TestClaudeSessionCommand`
- Modify (only if the test fails): `bin/git-prompt-log` — `cmd_session` drop/restore actions

**Interfaces:**
- Consumes: the `session` subcommand's `drop`/`restore` actions and `--index`/target args (see existing `test_session_drop_and_undrop_cli`, line ~1356, for the CLI shape).

- [ ] **Step 1: Confirm the drop/restore CLI shape (already verified)**

The `session` subcommand is `session <action> <target>` where `action` ∈ `{list, show, drop, exclude, undrop, restore, clear}` (parser at line ~3481) and `target` is a 1-based index or regex (line ~3484). So `session drop 1` and `session restore 1` are the correct forms. The drop/restore action branches (lines ~2994–3040) operate on `all_prompts` (populated from `raw_data`) and `save_session_excludes`, so Task 1's change is expected to make them work with no further code.

- [ ] **Step 2: Write the test**

Add to `TestClaudeSessionCommand`:

```python
    def _run(self, *args, extra_env=None):
        env = os.environ.copy()
        env["PATH"] = f"{bin_path.parent}:{env.get('PATH', '')}"
        if extra_env:
            env.update(extra_env)
        return subprocess.run(["python3", str(bin_path), "session", *args],
                              cwd=self.repo, capture_output=True, text=True, env=env)

    def test_session_drop_and_restore_claude(self):
        drop = self._run("drop", "1")
        self.assertEqual(drop.returncode, 0, drop.stderr)
        listed = self._run()
        # Prompt 1 now shows as excluded.
        self.assertIn("[EXCLUDED]", listed.stdout)
        restore = self._run("restore", "1")
        self.assertEqual(restore.returncode, 0, restore.stderr)
        listed2 = self._run()
        self.assertNotIn("[EXCLUDED]", listed2.stdout)
```

- [ ] **Step 3: Run test to verify it fails (or passes)**

Run: `python3 -m unittest tests.test_git_prompt_log.TestClaudeSessionCommand.test_session_drop_and_restore_claude -v`
Expected: If it FAILS, the drop/restore actions still assume an Antigravity `t_path`; apply the same `raw_data`/registry pattern from Task 1 to those action branches in `cmd_session`, then re-run. If it PASSES, exclusion already works through the fallback path — no code change needed.

- [ ] **Step 4: Run the full suite**

Run: `python3 -m unittest discover -s tests -p "test_*.py"`
Expected: OK.

- [ ] **Step 5: Commit**

```bash
git add tests/test_git_prompt_log.py bin/git-prompt-log
git commit -m "test(session): verify Claude exclusion drop/restore round-trip"
```

---

## Task 3: Claude session↔repo association by cwd/worktree

A Claude transcript filed under a project directory whose name does not match the repo (e.g. a worktree) must still associate when its recorded `cwd` is inside the repo's worktree tree.

**Files:**
- Modify: `bin/git-prompt-log` — `ClaudeCodeAdapter.find_session_data` (candidate scan, lines ~1377–1403) + two new private helpers on `ClaudeCodeAdapter`
- Test: `tests/test_git_prompt_log.py` — add to `TestIngestionAdapters`

**Interfaces:**
- Produces: `ClaudeCodeAdapter._get_repo_worktree_paths(repo_root: Optional[Path]) -> Set[Path]` and `ClaudeCodeAdapter._transcript_cwd_in_repo(fpath: Path, worktree_paths: Set[Path]) -> bool`.

- [ ] **Step 1: Write the failing test**

Add to `TestIngestionAdapters`:

```python
    def test_claude_association_by_cwd_across_worktree(self):
        import os as _os
        repo = self.work_dir / "myrepo"
        repo.mkdir()
        subprocess.run(["git", "init", "-b", "main"], cwd=repo, check=True, capture_output=True)
        # Claude filed the transcript in a neutrally-named dir (no "myrepo" in the path),
        # but the recorded cwd is the repo root.
        cdir = self.work_dir / "unrelated-project-dir"
        cdir.mkdir()
        (cdir / "sess-x.jsonl").write_text("\n".join([
            json.dumps({"type": "user", "cwd": str(repo),
                        "message": {"role": "user", "content": "Work in myrepo"},
                        "promptSource": "typed", "timestamp": "2026-09-07T10:00:00Z"}),
        ]), encoding="utf-8")

        adapter = gpn.ClaudeCodeAdapter()
        old = _os.environ.get("CLAUDE_PROJECT_DIR")
        _os.environ["CLAUDE_PROJECT_DIR"] = str(cdir)
        try:
            data = adapter.find_session_data(session_id=None, repo_root=repo)
        finally:
            if old is None:
                _os.environ.pop("CLAUDE_PROJECT_DIR", None)
            else:
                _os.environ["CLAUDE_PROJECT_DIR"] = old
        self.assertIsNotNone(data, "cwd inside repo worktree tree should associate the session")
        self.assertEqual([p.text for p in data["prompts"]], ["Work in myrepo"])
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python3 -m unittest tests.test_git_prompt_log.TestIngestionAdapters.test_claude_association_by_cwd_across_worktree -v`
Expected: FAIL — `data` is `None` (path-based match misses the neutral dir).

- [ ] **Step 3: Add the worktree helpers**

In `ClaudeCodeAdapter` (place next to `_get_claude_dirs`), add:

```python
    def _get_repo_worktree_paths(self, repo_root: Optional[Path]) -> Set[Path]:
        """Resolved working-tree paths for the repo: every `git worktree list`
        entry plus the repo root itself."""
        paths: Set[Path] = set()
        if not repo_root:
            return paths
        try:
            paths.add(repo_root.resolve())
        except Exception:
            pass
        code, out, _ = run_git(["worktree", "list", "--porcelain"], repo_root=repo_root)
        if code == 0 and out:
            for line in out.splitlines():
                if line.startswith("worktree "):
                    try:
                        paths.add(Path(line[len("worktree "):].strip()).resolve())
                    except Exception:
                        continue
        return paths

    def _transcript_cwd_in_repo(self, fpath: Path, worktree_paths: Set[Path]) -> bool:
        """True when the transcript's recorded cwd is a worktree path or nested
        under one. Reads only the first line that carries a cwd."""
        if not worktree_paths:
            return False
        try:
            with open(fpath, "r", encoding="utf-8", errors="replace") as f:
                for _ in range(20):
                    line = f.readline()
                    if not line:
                        break
                    line = line.strip()
                    if not line or '"cwd"' not in line:
                        continue
                    try:
                        obj = json.loads(line)
                    except json.JSONDecodeError:
                        continue
                    cwd = obj.get("cwd")
                    if not cwd:
                        continue
                    cpath = Path(cwd).resolve()
                    return any(cpath == wt or wt in cpath.parents for wt in worktree_paths)
        except Exception:
            return False
        return False
```

- [ ] **Step 4: Use the helpers in the candidate scan**

In `ClaudeCodeAdapter.find_session_data`, just before the `for d in dirs:` candidate loop (after `repo_strs = get_repo_identifiers(repo)`), add:

```python
        worktree_paths = self._get_repo_worktree_paths(repo)
```

Then, inside the `for fpath in files:` loop, change the candidate condition from:

```python
                    fpath_str = str(fpath).lower()
                    if any(r in fpath_str for r in repo_strs):
                        candidates.append((mtime, fpath))
```

to:

```python
                    fpath_str = str(fpath).lower()
                    if any(r in fpath_str for r in repo_strs) or self._transcript_cwd_in_repo(fpath, worktree_paths):
                        candidates.append((mtime, fpath))
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `python3 -m unittest tests.test_git_prompt_log.TestIngestionAdapters.test_claude_association_by_cwd_across_worktree -v`
Expected: PASS.

- [ ] **Step 6: Run the full suite**

Run: `python3 -m unittest discover -s tests -p "test_*.py"`
Expected: OK.

- [ ] **Step 7: Commit**

```bash
git add bin/git-prompt-log tests/test_git_prompt_log.py
git commit -m "fix(claude): associate sessions by transcript cwd across worktrees"
```

---

## Task 4: Identity cleanup

Replace the stale Claude fallback model and remove the dead module-level `get_agent_identity()`.

**Files:**
- Modify: `bin/git-prompt-log` — `ClaudeCodeAdapter.get_agent_identity` (line ~1179) and module-level `get_agent_identity()` (line ~1608)
- Test: `tests/test_git_prompt_log.py` — add to `TestIngestionAdapters`

**Interfaces:**
- Consumes: `ClaudeCodeAdapter().get_agent_identity(detected_model=None) -> (harness, model)`.

- [ ] **Step 1: Write the failing test**

Add to `TestIngestionAdapters`:

```python
    def test_claude_identity_fallback_model_is_neutral(self):
        adapter = gpn.ClaudeCodeAdapter()
        _, model = adapter.get_agent_identity(detected_model=None)
        self.assertEqual(model, "Claude")

    def test_module_level_get_agent_identity_removed(self):
        self.assertFalse(hasattr(gpn, "get_agent_identity"),
                         "dead module-level get_agent_identity() should be removed")
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `python3 -m unittest tests.test_git_prompt_log.TestIngestionAdapters -k identity -v` and `... -k get_agent_identity -v`
Expected: FAIL — model is `"Claude 3.7 Sonnet"`; `gpn.get_agent_identity` still exists.

- [ ] **Step 3: Update the Claude fallback model**

In `bin/git-prompt-log`, `ClaudeCodeAdapter.get_agent_identity`, change:

```python
        return harness, detected_model or "Claude 3.7 Sonnet"
```

to:

```python
        return harness, detected_model or "Claude"
```

- [ ] **Step 4: Remove the dead module-level function**

Delete the entire module-level `def get_agent_identity() -> Tuple[str, str]:` function (lines ~1608–1613). Confirm no references remain:

Run: `grep -n "^get_agent_identity\|[^.]get_agent_identity()" bin/git-prompt-log`
Expected: no matches (only `self.get_agent_identity(...)` / `adapter.get_agent_identity(...)` method calls remain).

- [ ] **Step 5: Run tests to verify they pass**

Run: `python3 -m unittest tests.test_git_prompt_log.TestIngestionAdapters -k identity -v` and `... -k get_agent_identity -v`
Expected: PASS.

- [ ] **Step 6: Run the full suite**

Run: `python3 -m unittest discover -s tests -p "test_*.py"`
Expected: OK.

- [ ] **Step 7: Commit**

```bash
git add bin/git-prompt-log tests/test_git_prompt_log.py
git commit -m "refactor(claude): neutral fallback model; drop dead get_agent_identity()"
```

---

## Final verification

- [ ] **Reinstall the binary and confirm real behavior**

```bash
./install.sh --local-only
cd /Users/jr/Work/sites/liveriga.com/repo && git prompt-log session
```
Expected: lists that repo's Claude session prompts (no "No prompts found").
