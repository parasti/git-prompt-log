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
* **Note Format:** Notes store session headers (`Assistant-Session`, `Assistant-Harness`, `Assistant-Model`, `Assistant-Recorded`) followed by `Assistant-Prompts:` listed in reverse chronological order (causal prompt first). Squashed commits across different sessions separate each session with `---`.
* **Sharing Prompt Notes:** Notes are never pushed directly via git notes refs (`refs/notes/*`). Prompt notes are shared across repositories exclusively via markdown logs (`export-log` on the branch, and `import-log` upon landing).

---

## 2. Executing Tasks on Request

When the user asks you to perform operations with `git-prompt-log`, execute the appropriate commands:

### Enable Prompt Notes in a Repository
When asked to initialize or enable prompt notes:
```bash
git prompt-log init
```
*(or `git prompt-log install`)*
*Options to mention or use if requested:*
* `--skill`: Installs local repository assistant skill at `.agents/skills/git-prompt-log/SKILL.md` (default: no skill).
* `--no-post-commit`: Skips installing the automatic post-commit hook.

### Inspect Notes
When asked to view or check prompt notes:
```bash
# Formatted view of the note on HEAD (or any commit hash/ref)
git prompt-log show HEAD

# Or using native git log
git log -n 1

# View commit history annotated with active steering prompts
git prompt-log log
```

### Export Prompt Notes for Pull Requests
When asked to prepare a branch for review, export notes, or package prompts for a PR:
```bash
git prompt-log export-log --commit
```
This detects the branch range against the upstream base branch, generates `prompts/YYYY_MM_DD_HHMMSS_<slug>.md`, and creates a commit on the branch so reviewers can see the prompt timeline in the PR diff.

### Upstream Re-hydration (After Merge)
When asked to land, import, or re-hydrate notes on `main` after a PR merge:
```bash
git prompt-log import-log prompts/YYYY_MM_DD_HHMMSS_<slug>.md
```
This matches landed commits by commit hash or commit subject and attaches the prompt provenance back to `refs/notes/commits`.

### Manual Recording & Filtering
If the user asks to record prompts manually or filter out specific turns:
```bash
# Record current session prompts onto HEAD
git prompt-log record

# Preview without writing to git notes
git prompt-log record --dry-run

# Exclude prompts matching a regex pattern
git prompt-log record --drop "temporary scratch"

# Drop the last N prompts before recording
git prompt-log record --drop-last 1
```

### Interactive Note Editing
When asked to edit or modify a recorded note directly:
```bash
git prompt-log edit HEAD
```

### Accidental Prompt Retraction (Parallel Sessions)
When asked how to prevent or remove accidental prompts across parallel agent sessions, instruct or apply these markers:
* **Tag on input:** Prefix prompts with `[ignore]`, `[skip]`, `[wrong-session]`, or `[scratch]` to exclude them from being recorded.
* **Retract previous prompt:** Send `[ignore-last]` (or `[retract]`, `[wrong-session]`) to drop the preceding prompt.
* **Retract multiple prompts:** Send `[ignore-last N]` (e.g. `[ignore-last 2]`) or `[ignore-all]`.
* **Retract and steer in one turn:** `[ignore-last] Actually, do this instead...`.

### Sharing Notes (Export & Import Only)
Prompt notes must never be pushed directly via `refs/notes/*`. Prompt notes are shared across remotes exclusively via markdown logs:
1. Export on branch before PR: `git prompt-log export-log --commit`
2. Land and re-hydrate on target branch: `git prompt-log import-log <path>`

### Uninstall Hooks or Configuration
When asked to remove `git-prompt-log` from a repository:
```bash
# Remove repository hooks only
git prompt-log uninstall-hook

# Completely remove hooks, unset local git notes config, and remove local skill
git prompt-log uninstall-hook --all
```
