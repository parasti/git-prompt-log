---
name: agy-prompt-note
description: >-
  Attaches AI session metadata, model/harness provenance, and human steering prompts
  directly to git notes on commits, provides deterministic prompt deduplication
  across git rebase/squash, exports branch prompt logs for pull requests, and
  re-hydrates prompt notes from merged logs. Use when authoring commits, recording
  prompt notes, finalizing a feature branch, preparing a pull request, or landing
  PR prompt logs.
---

# Antigravity Git Prompt Note Skill

Attaches AI session metadata, harness details, and human steering ("navigator") prompts directly to commits via standard Git notes (`refs/notes/commits`).

---

## Why Git Notes

Traditional prompt tracking either pollutes the git tree with markdown files (`prompts/*.md`) and requires rewriting commit trailers (`Prompt-Log:`), or relies on heavyweight daemons and full transcript logging (`git ai`) that bloats repositories and risks PII leakage.

`agy-prompt-note` records the essential provenance directly onto git commits without altering commit hashes or tree objects:
1. **Prompts over Transcripts:** Only the human steering prompts that set the course are stored; the patch itself already contains the code.
2. **Zero Tree Pollution:** Git notes live in `refs/notes/commits` outside the commit DAG during active development.
3. **Deterministic Rewrites:** Intelligent post-rewrite handling preserves, deduplicates, and merges session notes across `git rebase -i`, `squash`, `fixup`, and `commit --amend`.
4. **Hybrid PR Workflow:** At the PR boundary, accumulated notes on the branch can be exported to a single reviewable markdown commit (`git prompt-note export-log --commit`), and re-hydrated back into upstream notes upon landing (`git prompt-note import-log <file>`).

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

## Agent Runbook

### 1. After Authoring a Commit (Local Recording)
Whenever an agent creates or amends a commit on behalf of the user, record the steering prompts on `HEAD`:

```bash
git prompt-note record
```

To view the recorded note on a commit:
```bash
git prompt-note show HEAD
```

### 2. Preparing a Feature Branch for PR (Export Log)
When a feature branch is complete and ready for pull request review, export the branch's accumulated prompt notes into a reviewable log commit:

```bash
# Automatically detects branch range (e.g. main..HEAD), writes prompts/YYYY_MM_DD_<slug>.md, and commits it
git prompt-note export-log --commit
```

The exported file contains:
- Human-readable session metadata and steering prompts for reviewers in the web PR diff.
- An embedded metadata block that enables exact upstream re-hydration.

### 3. Maintainer / Post-Merge (Import Log)
After a PR is merged (even if squashed or rebased via GitHub's web UI), the maintainer re-hydrates the notes onto the landed commits on `main`:

```bash
git prompt-note import-log prompts/2026_09_04_feature.md
git push origin "refs/notes/*"
```

---

## Accidental Prompts & Parallel Sessions

When running multiple agent sessions in parallel across different projects, accidental prompts can be prevented or retracted using simple markers:

1. **Tag an Accidental Prompt Directly:**
   Prefix the prompt with `[ignore]`, `[skip]`, `[wrong-session]`, or `[scratch]`:
   ```text
   [wrong-session] Fix the audio mixer volume slider
   ```
   Such prompts are automatically excluded from prompt notes.

2. **Retract an Already-Sent Accidental Prompt:**
   If a prompt was sent by mistake, follow up in that same session with:
   ```text
   [ignore-last]
   ```
   (or `[wrong-session]`, `[ignore-prev]`, `[retract]`).
   This drops the preceding accidental prompt (and drops the retraction marker).
   To drop multiple accidental prompts: `[ignore-last 2]`.
   To reset all prompts accumulated in the session: `[ignore-all]`.

3. **Retract and Provide Real Prompt in One Turn:**
   ```text
   [ignore-last] Actually, fix the level select camera
   ```
   Drops the previous message and records only the intended prompt.

4. **Filtering and Editing Notes:**
   ```bash
   # Exclude prompts matching a regex when recording
   git prompt-note record --drop "audio mixer"

   # Drop last prompt when recording
   git prompt-note record --drop-last 1

   # Edit recorded note interactively in $EDITOR
   git prompt-note edit HEAD
   ```

---

## CLI Reference

```bash
# Initialize in a repository (hooks, local git config, local skill)
git prompt-note init

# Uninstall hooks
git prompt-note uninstall-hook

# Completely remove hooks, git config, and local skill
git prompt-note uninstall-hook --all

# Record prompt note on HEAD (or --commit <hash>)
git prompt-note record

# Preview prompt note without writing to git
git prompt-note record --dry-run

# Show prompt note on a commit
git prompt-note show [commit]

# Edit prompt note on a commit in $EDITOR
git prompt-note edit [commit]

# Export branch prompt notes to a markdown log file
git prompt-note export-log [--range <base>..HEAD] [--output <file>] [--commit]

# Import prompt notes from a log file into git notes
git prompt-note import-log <file> [--commit <hash>]
```

---

## Rebase and Squash Handling

When Git rewrites commits (`rebase`, `commit --amend`, `squash`, `fixup`), the installed `.git/hooks/post-rewrite` hook invokes `git prompt-note post-rewrite`:

1. **Same-Session Squash:** Prompts from all squashed commits are unioned, deduplicated, and sorted chronologically into a single session entry with the latest `Recorded` timestamp.
2. **Cross-Session Squash:** Multiple session entries are preserved in chronological order separated by `---`.
3. **1-to-1 Rebase / Amend:** The note is transferred to the new commit hash, appending newly executed steering prompts if amended within an active session.
