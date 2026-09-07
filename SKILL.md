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
* **Note Format:** Notes store session headers (`Assistant-Session`, `Assistant-Harness`, `Assistant-Model`, `Assistant-Recorded`) followed by `Assistant-Prompts:` listed in reverse chronological order (causal prompt first; tool-mediated user inputs are prefixed with `[tool:<name>]`). Squashed commits across different sessions separate each session with `---`.
* **Sharing Prompt Notes:** Notes are never pushed directly via git notes refs (`refs/notes/*`). Prompt notes are shared across repositories exclusively via markdown logs (`export` on the branch, and `import` upon landing).

---

## 2. Executing Tasks on Request

When the user asks you to perform operations with `git-prompt-log`, execute the appropriate commands:

### Enable Prompt Notes in a Repository
When asked to initialize or enable prompt notes:
```bash
git prompt-log init
```
*Options to mention or use if requested:*
* `--no-post-commit`: Skips installing the automatic post-commit hook.
* `-H, --harness <name>`: Explicitly configure default assistant harness (`antigravity`, `claude`, `manual`).

### Inspect Notes
When asked to view or check prompt notes:
```bash
# Formatted view of the note on HEAD (or any commit hash/ref)
git prompt-log show HEAD

# Or using native git log
git log -n 1

# View commit history annotated with active steering prompts
git prompt-log
```

### Export Prompt Notes for Pull Requests
When asked to prepare a branch for review, export notes, or package prompts for a PR:
```bash
git prompt-log export --commit
```
This detects the branch range against the upstream base branch, generates `prompts/YYYY_MM_DD_HHMMSS_<slug>.md`, and creates a commit on the branch so reviewers can see the prompt timeline in the PR diff.

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
This matches landed commits by commit hash or commit subject and attaches the prompt provenance back to `refs/notes/commits`. Note: directory paths are rejected; pass files directly (e.g. `prompts/*.md`). Zero arguments will do nothing and require specifying files or stdin.

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

# Keep only the last N prompts (drop older prompts)
git prompt-log record --keep-last 3
git prompt-log record HEAD~4.. --keep-last 3

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

### Supported Harnesses
`git-prompt-log` supports multiple assistant harnesses (`antigravity`, `claude`, `manual`):
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

### Interactive Note Editing
When asked to edit or modify a recorded note directly:
```bash
git prompt-log edit HEAD
```

### Session Prompt Management (Exclusions & Retraction)
When asked how to inspect, exclude, or retract specific prompts:
* **Session CLI (Persistent):** Use `git prompt-log session` to manage prompt inclusion across an active session:
  * `git prompt-log session`: List all prompts in the active session with 1-based index numbers.
  * `git prompt-log session --commits [range]`: Interleave session prompts and branch commits into a unified chronological timeline to inspect note status and steering flow.
  * `git prompt-log session drop <index_or_pattern>`: Mark prompt #N or matching pattern as excluded for this session (automatically updates HEAD's prompt note).
  * `git prompt-log session undrop <index_or_pattern>`: Restore a previously excluded prompt.
  * `git prompt-log session clear`: Clear all exclusions for the session.
* **Per-Commit Drops & Edits (Single Commit Only):**
  * `git prompt-log record --drop "<pattern>"`: Exclude matching prompts for this commit note only.
  * `git prompt-log edit HEAD`: Edit a recorded note interactively in `$EDITOR`.
  Modifying notes per-commit does not alter the underlying session transcript; omitted prompts will return on subsequent commits made in the same session unless excluded with `git prompt-log session drop`.

### Sharing Notes (Export & Import Only)
Prompt notes must never be pushed directly via `refs/notes/*`. Prompt notes are shared across remotes exclusively via markdown logs:
1. Export on branch before PR: `git prompt-log export --commit`
2. Land and re-hydrate on target branch: `git prompt-log import <path>`

### Deinitialize or Uninstall
When asked to remove `git-prompt-log` from a repository:
```bash
# Remove repository hooks only (uninstall is supported as an alias)
git prompt-log deinit

# Completely remove hooks, unset local git notes config, and remove local skill
git prompt-log deinit --all
```
