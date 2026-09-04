---
name: agy-prompt-note
description: >-
  Attaches AI session metadata, model/harness provenance, and human steering prompts
  directly to git notes on commits, providing deterministic prompt deduplication
  and session merging across git rebase, squash, and amend.
---

# Antigravity Git Prompt Note Skill

Attaches AI session metadata, harness details, and human steering ("navigator") prompts directly to commits via standard Git notes (`refs/notes/commits`).

---

## Why Git Notes

Traditional prompt tracking either pollutes the git tree with markdown files (`prompts/*.md`) and requires rewriting commit trailers (`Prompt-Log:`), or relies on heavyweight daemons and full transcript logging (`git ai`) that bloats repositories and risks PII leakage.

`agy-prompt-note` records the essential provenance directly onto git commits without altering commit hashes or tree objects:
1. **Prompts over Transcripts:** Only the human steering prompts that set the course are stored; the patch itself already contains the code.
2. **Zero Tree Pollution:** Git notes live in `refs/notes/commits` outside the commit DAG.
3. **Deterministic Rewrites:** Intelligent post-rewrite handling preserves, deduplicates, and merges session notes across `git rebase -i`, `squash`, `fixup`, and `commit --amend`.

---

## Schema

```text
Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401
Assistant-Harness: Antigravity CLI 1.1.25
Assistant-Model: Gemini 3.8 Flash (High)
Assistant-Recorded: 2026-09-04 01:03:57 UTC

Assistant-Prompts:
  [2026-09-04 01:03:57 UTC] Pivot camera around ball origin
  [2026-09-04 01:09:25 UTC] Let's implement this.
```

When squashing commits across different sessions, each session is preserved sequentially separated by `---`:

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

## Architecture & Separation of Concerns

1. **Recording is Agent-Driven (Strict Causality):**
   - A commit only receives a prompt note if it was authored or steered by an agent.
   - When the AI agent creates a commit, it records the note:
     `python3 .agents/skills/agy-prompt-note/scripts/git_prompt_note.py record`
   - Manual human commits authored in your terminal are **never** hijacked by background sessions.
   - If the user explicitly wants to attach the active session note to a commit:
     `python3 .agents/skills/agy-prompt-note/scripts/git_prompt_note.py record`

2. **Rewriting is Git-Driven (`post-rewrite` Hook):**
   - The installed `post-rewrite` hook runs automatically on `git rebase`, `squash`, `fixup`, and `commit --amend`.
   - **Completely safe:** It only touches commits that *already* possess a prompt note. Commits authored without notes remain completely untouched.

---

## Commands

### One-Time Setup (Enables Safe History Rewriting)

```bash
# Installs post-rewrite hook and configures git notes rewrite settings
python3 .agents/skills/agy-prompt-note/scripts/git_prompt_note.py install-hook
```

### Agent / Manual Recording

```bash
# Record prompt note on HEAD (or --commit <hash>)
python3 .agents/skills/agy-prompt-note/scripts/git_prompt_note.py record

# Preview prompt note without writing
python3 .agents/skills/agy-prompt-note/scripts/git_prompt_note.py record --dry-run

# Show prompt note on HEAD
python3 .agents/skills/agy-prompt-note/scripts/git_prompt_note.py show
```

---

## Rebase and Squash Handling

When Git rewrites commits (`rebase`, `commit --amend`, `squash`, `fixup`), the installed `.git/hooks/post-rewrite` hook invokes `git_prompt_note.py post-rewrite`:

1. **Same-Session Squash:** Prompts from all squashed commits are unioned, deduplicated, and sorted chronologically into a single session entry with the latest `Recorded` timestamp.
2. **Cross-Session Squash:** Multiple session entries are preserved in chronological order separated by `---`.
3. **1-to-1 Rebase / Amend:** The note is transferred to the new commit hash, appending any newly executed steering prompts if amended within an active session.
