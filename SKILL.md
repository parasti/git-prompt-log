---
name: git-prompt-log
description: >-
  Use this skill to answer questions about git-prompt-log and execute
  git-prompt-log tasks (initializing repositories, inspecting notes,
  exporting PR logs, re-hydrating merged logs, or managing accidental prompts)
  when requested by the user.
---

# Git Prompt Log Skill

This skill guides the agent in answering user questions about `git-prompt-log` and executing tasks using the CLI when requested.

---

## 1. What `git-prompt-log` Is & How It Works

When answering questions about the tool, use this technical foundation:

* **Purpose:** `git-prompt-log` records human steering prompts and agent session metadata directly onto Git commits via Git notes (`refs/notes/commits`).
* **Automatic Recording:** During `git prompt-log init`, a `.git/hooks/post-commit` hook is installed. When an agent creates or amends a commit, this hook automatically detects the active session and records the prompt note on `HEAD`. For human commits, the hook is strictly a no-op.
* **Rebase & Squash Reconciliation:** A `.git/hooks/post-rewrite` hook is installed. When Git rewrites commits (`rebase`, `squash`, `fixup`, `commit --amend`), the hook automatically merges, deduplicates, and preserves prompt notes on the resulting commits.
* **Worktrees:** In Git worktrees, hooks and notes are shared with the main repository automatically. You do not need to reinitialize or inspect `.git/hooks`.
* **Note Format:** Notes store session headers (`Assistant-Session`, `Assistant-Harness`, `Assistant-Model`, `Assistant-Recorded`) followed by `Assistant-Prompts:` listed in reverse chronological order (causal prompt first; tool-mediated user inputs are prefixed with `[tool:<name>]`). Squashed commits across different sessions separate each session with `---`.
* **Streaming Log Wrapper & Shorthand:** `git prompt-log` (shorthand for `git prompt-log log`) acts as a streaming wrapper around `git log`, rendering commits with formatted prompt blocks and unprompted commit placeholders (`Prompt: none recorded`). Arbitrary native `git log` options (`-n`, `-p`, `--stat`, `--graph`, revision ranges) are forwarded directly to Git, custom prompt options are namespaced (`--prompt-full`, `--prompt-ref`), and Git's native pager environment is respected (automatically bypassed in non-interactive agent shells).
* **Sharing Prompt Notes:** Notes are never pushed directly via git notes refs (`refs/notes/*`). Prompt notes are shared across repositories exclusively via markdown logs (`export` on the branch, and `import` upon landing).

---

## 2. Executing Tasks on Request

### Export Prompt Notes for Pull Requests (Zero-Inspection 1-Command Flow)

When asked to export and commit a prompt log on a feature branch:

1. **Synthesize `--slug` from your conversation context:**
   As the AI assistant, you have complete context of what code, feature, or bug was worked on in this session. Formulate a concise, descriptive `snake_case` slug directly from memory (e.g., `user_authentication`, `camera_rotation_fix`, `configurable_exclusions`).
   * **Do NOT run `git branch`, `git status`, or `git log` to inspect branch names or commit messages for naming.** Formulate the slug directly from context.
   * **Do NOT ask the human to name the slug.** Naming is hard for humans; you are best positioned to summarize the work you just performed.

2. **Execute immediately in a single terminal command:**
   ```bash
   git prompt-log export --commit --slug "<context_derived_slug>"
   ```

3. **Invariants (Do NOT waste turns probing):**
   * **Do NOT run `git status` or `git branch` beforehand:** The feature branch revision range (`@{u}..HEAD`, `origin/main..HEAD`, or `origin/master..HEAD`) is detected automatically by the tool.
   * **Do NOT inspect `git notes` or run `git prompt-log show`:** Commits created by the assistant automatically have prompt notes attached via the post-commit hook. The tool automatically validates notes.
   * **Do NOT run `export --help` or `--stdout`:** `--commit` is safe, atomic, and idempotent. It creates `prompts/` automatically if missing, stages *only* the new markdown log, and leaves all other working tree files untouched.
   * **Do NOT run `git log` or `git status` afterwards:** `export --commit` outputs explicit confirmation upon completion (`Committed prompt log: '...'`).
   * Report completion immediately after this single command succeeds.

---

### Two-Step Workflow: "Commit and Export Prompt Log"

When the user asks to "commit work and export prompt log" or "generate prompt log for session":
1. **Step 1: Commit code changes normally**
   ```bash
   git add <modified-files>
   git commit -m "<descriptive message>"
   ```
   *(The post-commit hook automatically records session prompt notes onto this commit).*
2. **Step 2: Export the prompt log**
   ```bash
   git prompt-log export --commit --slug "<context_derived_slug>"
   ```
   *(Creates `prompts/YYYY_MM_DD_HHMMSS_<slug>.md` and commits it).*
   **Do NOT** attempt to stage code changes together with the prompt log export; they are always two separate commits.

---

### Exporting on `main` or Custom Commit Ranges

If working directly on `main` (or exporting a specific past commit range instead of a feature branch):
```bash
# Export commits from current session on main (where HEAD~N is the session start):
git prompt-log export --range <start_commit>~1..HEAD --commit --slug "<context_derived_slug>"

# Single commit export:
git prompt-log export --range HEAD~1..HEAD --commit --slug "<context_derived_slug>"
```

---

### Enable Prompt Notes in a Repository
When asked to initialize or enable prompt notes:
```bash
git prompt-log init
```
*Options to mention or use if requested:*
* `--no-post-commit`: Skips installing the automatic post-commit hook.
* `-H, --harness <name>`: Explicitly configure default assistant harness (`antigravity`, `claude`, `opencode`, `manual`).

---

### Inspect Notes & Commit Log History
When asked to view or check prompt notes or commit history:
```bash
# View commit history annotated with active steering prompts (shorthand for 'git prompt-log log')
git prompt-log

# Forward arbitrary native git log options and revision ranges directly
git prompt-log -n 5
git prompt-log -n 2 -p
git prompt-log --stat
git prompt-log --graph main..HEAD

# View full cumulative prompts per commit (instead of default last 4 prompts)
git prompt-log --prompt-full
# or:
git prompt-log log --prompt-full
# alias: --prompts-full

# Target a custom prompt notes ref
git prompt-log --prompt-ref refs/notes/custom-prompts

# Disable pager using Git's native flag or environment (custom --no-pager is intentionally not used)
git --no-pager prompt-log
GIT_PAGER=cat git prompt-log

# Formatted view of the note on HEAD (or any commit hash/ref)
git prompt-log show HEAD

# Interleave session prompts and branch commits into a unified chronological timeline
git prompt-log timeline
git prompt-log timeline main..HEAD
# (alias for 'git prompt-log session --commits [range]')

# Standard git log also displays prompt notes natively
git log -n 1
```

---

### Upstream Re-hydration (After Merge)
When asked to land, import, or re-hydrate notes on `main` after a PR merge:
```bash
# Single file
git prompt-log import prompts/YYYY_MM_DD_HHMMSS_<slug>.md

# Multiple files (e.g. via shell glob)
git prompt-log import prompts/*.md

# Preview imports without writing notes
git prompt-log import --dry-run prompts/*.md

# Import from stdin
git prompt-log import --stdin < prompts/log.md
cat prompts/log.md | git prompt-log import -
```
This matches landed commits by commit hash or commit subject and attaches the prompt provenance back to `refs/notes/commits`.
**Note:** Directory paths are rejected; pass files directly (e.g. `prompts/*.md`). Zero arguments will do nothing and require specifying files or stdin.

---

### Manual Recording & Filtering
If the user asks to record prompts manually (e.g. after committing changes themselves rather than having the assistant commit) or filter out specific turns:
```bash
# Record current assistant session prompts onto HEAD (e.g. after manual commit)
git prompt-log record

# Preview without writing to git notes
git prompt-log record --dry-run

# Record across an entire branch or revision range in one step (uses author date per commit)
git prompt-log record main..HEAD
git prompt-log record --range main..HEAD
git prompt-log record --dry-run main..HEAD

# Exclude prompts matching a regex pattern
git prompt-log record --drop "temporary scratch"

# Drop the last N prompts before recording
git prompt-log record --drop-last 1

# Keep only the last N prompts (drop older prompts, or delete note with 0)
git prompt-log record --keep-last 3
git prompt-log record HEAD~4.. --keep-last 3
git prompt-log record --keep-last 0

# Delete prompt notes from a commit or range of commits
git prompt-log record --delete
git prompt-log record --delete -c <hash>
git prompt-log record main..HEAD --delete
git prompt-log delete HEAD
git prompt-log delete main..HEAD

# Select prompts explicitly by 1-based index or range from `git prompt-log session`
git prompt-log record --prompts 1-10
git prompt-log record --until-prompt 10
git prompt-log record --commit <hash> -p 1,3,5

# Record a prompt manually without transcript (human or external script)
git prompt-log record -m "Implemented authentication pipeline"

# Attach prompt to a specific past commit (e.g. migrating old logs)
git prompt-log record --commit <hash> -m "Prompt from legacy log" --harness "Tool" --model "Model"

# Retroactively record session prompts for a past commit (defaults to author date to match session timeline)
git prompt-log record --commit <hash>
git prompt-log record --commit <hash> --date committer

# Pipe prompt from standard input
echo "Refactor caching layer" | git prompt-log record --stdin
cat prompt.txt | git prompt-log record --commit <hash> --stdin --harness "Tool"

# Record with explicit harness and model attribution
git prompt-log record -m "System architecture design" --harness "Human Dev" --model "Manual"
```

Dropping prompts via `record --drop` or `--drop-last` only affects that specific commit's note. Because the session transcript remains untouched, omitted prompts will return on subsequent commits from the same session unless excluded with `git prompt-log session drop`.

---

### Supported Harnesses
`git-prompt-log` supports multiple assistant harnesses (`antigravity`, `claude`, `opencode`, `manual`):
```bash
# Explicitly set the active harness for this repository (or --global)
git prompt-log harness antigravity
# or via standard git config:
git config prompt-log.harness antigravity

# Inspect configured harness, active detection, and supported harnesses
git prompt-log harness
git prompt-log harness --json

# Explicitly record using a specific harness
git prompt-log record --harness claude -c HEAD
```

---

### Interactive Note Editing
When asked to edit or modify a recorded note directly:
```bash
git prompt-log edit HEAD
```

---

### Session Prompt Management (Exclusions & Retraction)
When asked how to inspect, exclude, or retract specific prompts:
* **Session CLI (Persistent):** Use `git prompt-log session` to manage prompt inclusion across an active session:
  * `git prompt-log session list-sessions` (or `git prompt-log session ls`): List all candidate agent sessions matching the current repository or worktree.
  * `git prompt-log session`: List all prompts in the active session with 1-based index numbers.
  * `git prompt-log session --session <uuid>`: Target a specific session explicitly.
  * `git prompt-log session --commits [range]`: Interleave session prompts and branch commits into a unified chronological timeline to inspect note status and steering flow.
  * `git prompt-log session drop <index_or_pattern>`: Mark prompt #N or matching pattern as excluded for this session (automatically updates prompt notes across all commits in the session trail; or a specific commit with `-c`).
  * `git prompt-log session undrop <index_or_pattern>`: Restore a previously excluded prompt.
  * `git prompt-log session clear`: Clear all exclusions for the session.
* **Configurable Exclusions (Always-Skip Patterns via Git Config):**
  * Built-in default exclusions automatically skip routine prompts: `'^[Yy]es\.?$'`, `'^[Dd]o it\.?$'`, `'^[Oo][Kk]\.?$'`, `'^[Rr]esume\.?$'`.
  * `git config --add prompt-log.exclude "<regex>"`: Permanently skip routine patterns across all recordings (overrides default patterns).
  * `git config prompt-log.defaultExcludes true`: Retain defaults alongside custom patterns.
  * `git config prompt-log.exclude ""` or `git config prompt-log.defaultExcludes false`: Disable all exclusions.
* **Per-Commit Drops & Edits (Single Commit Only):**
  * `git prompt-log record --drop "<pattern>"`: Exclude matching prompts for this commit note only.
  * `git prompt-log edit HEAD`: Edit a recorded note interactively in `$EDITOR`.
  Modifying notes per-commit does not alter the underlying session transcript; omitted prompts will return on subsequent commits made in the same session unless excluded with `git prompt-log session drop`.

---

### Sharing Notes (Export & Import Only)
Prompt notes must never be pushed directly via `refs/notes/*`. Prompt notes are shared across remotes exclusively via markdown logs:
1. Export on branch before PR: `git prompt-log export --commit --slug "<context_derived_slug>"`
2. Land and re-hydrate on target branch: `git prompt-log import <path>`

---

### Deinitialize or Uninstall
When asked to remove `git-prompt-log` from a repository:
```bash
# Remove repository hooks only (uninstall is supported as an alias)
git prompt-log deinit

# Completely remove hooks, unset local git notes config, and remove local skill
git prompt-log deinit --all
```
