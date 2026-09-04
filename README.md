# git-prompt-note

`git-prompt-note` attaches AI session metadata and human steering prompts directly to Git commits using Git notes (`refs/notes/commits`).

It provides clean, deterministic prompt attribution without altering commit SHAs, cluttering working trees with markdown files, or wrapping Git in proprietary runtime proxies.

---

## Key Principles

1. **Prompts over Transcripts:** The patch already contains the generated code. Git notes store only the navigator prompts that steered the assistant.
2. **Zero Tree Pollution:** Prompt notes live entirely outside the working tree in `refs/notes/commits`.
3. **Immutable DAG:** Attaching or updating notes does not alter commit hashes or commit messages.
4. **Rebase & Squash Native:** Integrates with Git's `.git/hooks/post-rewrite` hook to automatically merge, deduplicate, and preserve prompts across interactive rebase, squash, fixup, and amend.
5. **Universal Git Compatibility:** Native `git log` and `git show` display notes without third-party tools.

---

## Installation

Clone and run the installer:

```bash
git clone https://github.com/neverball/git-prompt-note.git
cd git-prompt-note
./install.sh
```

`./install.sh` installs the `git-prompt-note` binary into `~/.local/bin/` and prompts before making any global system changes:
- Asks whether to configure Git globally for notes rewriting (defaults to No).
- Asks whether to install the Antigravity assistant skill globally (defaults to No).

Non-interactive flags:
- `./install.sh --local-only`: Installs only the CLI binary without touching global configs.
- `./install.sh --global`: Opts into both global Git configuration and global assistant skill.

---

## Quickstart: Enable in Any Repository

To enable prompt notes for a specific repository without global configuration, run:

```bash
cd my-project
git prompt-note init
```

This single command:
1. Installs `.git/hooks/post-rewrite` so Git automatically invokes note reconciliation on rebase/squash.
2. Installs `.git/hooks/post-commit` so agent commits automatically have their steering prompts recorded (strictly no-op during human commits). Use `--no-post-commit` to skip.
3. Configures repository-scoped Git notes rewriting (`notes.rewrite.rebase = true`, `notes.rewriteRef = refs/notes/commits`).
4. Installs the repository-local assistant skill at `.agents/skills/agy-prompt-note/SKILL.md`. Use `--no-skill` to skip.

---

## Daily Workflow

### 1. Instruct the Assistant
Add a prompt attribution guideline to `AGENTS.md` in your repository:

```markdown
## AI Prompt Provenance
After authoring commits, record the steering prompt note on the commit:

```bash
git prompt-note record
```
```

### 3. Record Notes
When an assistant authors a commit, it records the note:

```bash
git prompt-note record
```

The tool identifies the active conversational turn and attributes only the steering prompts authored since the prior commit.

### 4. Inspect Notes
View notes natively in standard Git:

```bash
# Standard git log
git log -n 1

# Or via git-prompt-note
git prompt-note show HEAD
```

### 5. Export for Pull Requests
When a feature branch is ready for review, package the accumulated prompt notes into a reviewable log commit:

```bash
git prompt-note export-log --commit
```

This writes `prompts/YYYY_MM_DD_HHMMSS_<slug>.md` and commits it to the branch. Reviewers see the prompt log in the PR diff.

### 6. Upstream Re-hydration (Maintainer)
When the PR lands on `main` (even if squashed or rebased in GitHub's web UI), re-hydrate the notes on `main`:

```bash
git prompt-note import-log prompts/YYYY_MM_DD_feature.md
git push origin "refs/notes/*"
```

The tool matches commits by exact hash or commit subject, attaching the prompt provenance back to the landed commit in `refs/notes/commits`.

---

## Note Schema

```text
Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401
Assistant-Harness: Antigravity CLI 1.1.25
Assistant-Model: Gemini 3.8 Flash (High)
Assistant-Recorded: 2026-09-04 01:03:57 UTC

Assistant-Prompts:
  [2026-09-04 01:03:57 UTC] Pivot camera around ball origin
  [2026-09-04 01:09:25 UTC] Let's implement this.
```

When multiple commits are squashed across different sessions, each session is preserved sequentially separated by `---`:

```text
Assistant-Session: 147638d8-6fb3-46df-a685-441b1aec2349
Assistant-Harness: Antigravity CLI 1.1.24
Assistant-Model: Gemini 3.8 Flash (High)
Assistant-Recorded: 2026-09-02 18:30:12 UTC

Assistant-Prompts:
  [2026-09-02 18:25:01 UTC] Refactor camera mapping

---

Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401
Assistant-Harness: Antigravity CLI 1.1.25
Assistant-Model: Gemini 3.8 Flash (High)
Assistant-Recorded: 2026-09-04 01:03:57 UTC

Assistant-Prompts:
  [2026-09-04 01:02:10 UTC] Fix pitch clamping
```

---

## Accidental Prompts & Parallel Sessions

When working with parallel agent sessions across different worktrees or repositories, accidental prompts can be prevented or retracted:

- **Tagging on input:** Prefix prompts with `[ignore]`, `[skip]`, `[wrong-session]`, or `[scratch]`. They are automatically excluded from notes.
- **Retracting after sending:** If an accidental prompt was already sent, send `[ignore-last]` (or `[wrong-session]`, `[retract]`) in that session. It drops the preceding prompt.
- **Retracting multiple turns:** Use `[ignore-last N]` (e.g. `[ignore-last 2]`) or `[ignore-all]`.
- **Retracting and steering in one prompt:** `[ignore-last] Actually, do this instead...`.
- **Filtering on record:** `git prompt-note record --drop "pattern"` or `git prompt-note record --drop-last 1`.
- **Interactive editing:** `git prompt-note edit HEAD` opens the note in `$EDITOR`.

---

## Uninstalling Hooks

To remove the Git hooks installed by `init` or `install-hook`:

```bash
# Remove post-rewrite and post-commit hooks from the current repository
git prompt-note uninstall-hook

# Completely remove hooks, unset local git notes config, and delete local skill
git prompt-note uninstall-hook --all
```

---

## Remote Synchronization

To push and fetch notes automatically alongside branch pushes:

```bash
git config --add remote.origin.push "refs/notes/*:refs/notes/*"
git config --add remote.origin.fetch "+refs/notes/*:refs/notes/*"
```

---

## Testing

Run the automated test suite:

```bash
make test
```

## System Uninstallation

To remove the CLI binary from your machine:

```bash
./uninstall.sh
```

## License

GPL v2+ (or MIT upon release).

