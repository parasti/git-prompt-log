---
name: git-prompt-note
description: >-
  Use this skill to answer questions about git-prompt-note and execute
  git-prompt-note tasks (initializing repositories, inspecting notes,
  exporting PR logs, re-hydrating merged logs, or managing accidental prompts)
  when requested by the user.
---

# Git Prompt Note Skill

This skill guides the agent in answering user questions about `git-prompt-note` and executing tasks using the CLI when requested.

---

## 1. What `git-prompt-note` Is & How It Works

When answering questions about the tool, use this technical foundation:

* **Purpose:** `git-prompt-note` records human steering prompts and agent session metadata directly onto Git commits via Git notes (`refs/notes/commits`).
* **Automatic Recording:** During `git prompt-note init`, a `.git/hooks/post-commit` hook is installed. When an agent creates or amends a commit, this hook automatically detects the active session and records the prompt note on `HEAD`. For human commits, the hook is strictly a no-op.
* **Rebase & Squash Reconciliation:** A `.git/hooks/post-rewrite` hook is installed. When Git rewrites commits (`rebase`, `squash`, `fixup`, `commit --amend`), the hook automatically merges, deduplicates, and preserves prompt notes on the resulting commits.
* **Note Format:** Notes store session headers (`Assistant-Session`, `Assistant-Harness`, `Assistant-Model`, `Assistant-Recorded`) followed by `Assistant-Prompts:` listed in reverse chronological order (causal prompt first). Squashed commits across different sessions separate each session with `---`.
* **Sharing Prompt Notes:** Notes are never pushed directly via git notes refs (`refs/notes/*`). Prompt notes are shared across repositories exclusively via markdown logs (`export-log` on the branch, and `import-log` upon landing).

---

## 2. Executing Tasks on Request

When the user asks you to perform operations with `git-prompt-note`, execute the appropriate commands:

### Enable Prompt Notes in a Repository
When asked to initialize or enable prompt notes:
```bash
git prompt-note init
```
*Options to mention or use if requested:*
* `--no-post-commit`: Skips installing the automatic post-commit hook.
* `--no-skill`: Skips copying `.agents/skills/git-prompt-note/SKILL.md`.

### Inspect Notes
When asked to view or check prompt notes:
```bash
# Formatted view of the note on HEAD (or any commit hash/ref)
git prompt-note show HEAD

# Or using native git log
git log -n 1

# View commit history annotated with active steering prompts
git prompt-note log
```

### Export Prompt Notes for Pull Requests
When asked to prepare a branch for review, export notes, or package prompts for a PR:
```bash
git prompt-note export-log --commit
```
This detects the branch range against the upstream base branch, generates `prompts/YYYY_MM_DD_HHMMSS_<slug>.md`, and creates a commit on the branch so reviewers can see the prompt timeline in the PR diff.

### Upstream Re-hydration (After Merge)
When asked to land, import, or re-hydrate notes on `main` after a PR merge:
```bash
git prompt-note import-log prompts/YYYY_MM_DD_HHMMSS_<slug>.md
```
This matches landed commits by commit hash or commit subject and attaches the prompt provenance back to `refs/notes/commits`.

### Manual Recording & Filtering
If the user asks to record prompts manually or filter out specific turns:
```bash
# Record current session prompts onto HEAD
git prompt-note record

# Preview without writing to git notes
git prompt-note record --dry-run

# Exclude prompts matching a regex pattern
git prompt-note record --drop "temporary scratch"

# Drop the last N prompts before recording
git prompt-note record --drop-last 1
```

### Interactive Note Editing
When asked to edit or modify a recorded note directly:
```bash
git prompt-note edit HEAD
```

### Accidental Prompt Retraction (Parallel Sessions)
When asked how to prevent or remove accidental prompts across parallel agent sessions, instruct or apply these markers:
* **Tag on input:** Prefix prompts with `[ignore]`, `[skip]`, `[wrong-session]`, or `[scratch]` to exclude them from being recorded.
* **Retract previous prompt:** Send `[ignore-last]` (or `[retract]`, `[wrong-session]`) to drop the preceding prompt.
* **Retract multiple prompts:** Send `[ignore-last N]` (e.g. `[ignore-last 2]`) or `[ignore-all]`.
* **Retract and steer in one turn:** `[ignore-last] Actually, do this instead...`.

### Sharing Notes (Export & Import Only)
Prompt notes must never be pushed directly via `refs/notes/*`. Prompt notes are shared across remotes exclusively via markdown logs:
1. Export on branch before PR: `git prompt-note export-log --commit`
2. Land and re-hydrate on target branch: `git prompt-note import-log <path>`

### Uninstall Hooks or Configuration
When asked to remove `git-prompt-note` from a repository:
```bash
# Remove repository hooks only
git prompt-note uninstall-hook

# Completely remove hooks, unset local git notes config, and remove local skill
git prompt-note uninstall-hook --all
```
