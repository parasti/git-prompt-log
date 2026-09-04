# git-prompt-log

`git-prompt-log` records prompt timelines on commits via `git notes` to enable clean, deterministic prompt attribution.

---

## Getting Started

### Installation

Clone and run the installer:

```bash
git clone https://github.com/parasti/git-prompt-log.git
cd git-prompt-log
./install.sh
```

`./install.sh` installs the binary into `~/.local/bin/` and prompts before making any global Git or assistant configuration changes.

### Enable in a Repository

```bash
cd my-project
git prompt-log init
```

This single command:
1. Installs `.git/hooks/post-commit` to record prompts when an assistant commits (no-op during human commits; skip with `--no-post-commit`).
2. Installs `.git/hooks/post-rewrite` so Git automatically invokes note reconciliation on rebase/squash.
3. Configures repository-scoped Git notes rewriting (`notes.rewrite.rebase = true`, `notes.rewriteRef = refs/notes/commits`).
4. Installs the repository assistant skill at `.agents/skills/git-prompt-log/SKILL.md` (skip with `--no-skill`).

### Workflow

1. **Record Notes:** When an assistant authors a commit, the post-commit hook automatically detects the agent and records the prompt note. You can also record manually at any time:
   ```bash
   git prompt-log record
   ```

2. **Inspect Notes:** View notes natively in standard Git or via `git-prompt-log`:
   ```bash
   # Standard git log
   git log -n 1

   # Formatted note view
   git prompt-log show HEAD
   ```

3. **Export for Pull Requests:** Package accumulated prompt notes into a reviewable log commit before opening a PR:
   ```bash
   git prompt-log export-log --commit
   ```
   This writes `prompts/YYYY_MM_DD_HHMMSS_<slug>.md` and commits it to the branch so reviewers can inspect the prompt timeline in the PR diff.

4. **Upstream Re-hydration (Maintainer):** When the PR lands on `main` (even if squashed or rebased in GitHub's web UI), re-hydrate the notes on `main`:
   ```bash
   git prompt-log import-log prompts/YYYY_MM_DD_feature.md
   ```
   The tool matches commits by exact hash or commit subject and attaches prompt provenance back to `refs/notes/commits`.

---

## Motivation

Very simply, sharing the source code alone is not cutting it for open source projects that use coding agents. The actual source code is now the combination of harness, model, code, and prompts entered by a human. Sharing these provides a level of transparency and opportunities to learn from each other.

This idea went through a couple of iterations. The first iteration was a distillation of raw transcripts into Markdown files tracked in the repo, where the prompts would be preserved verbatim but the agent would summarize the events happening in between. That felt good until I realized that I never ever read what the agent has summarized. The second iteration still worked with Markdown files but tried to be more faithful to the transcript logs and documented the tool calls in between. And I still just skipped over those. It dawned on me that I only really cared about the prompts and the source code that resulted from those prompts. Then, upon discovering Git AI, a tool that promised to be exactly what I wanted but fell short in actual testing (not actually recording prompts being the big one), I proceeded with the third iteration.

Some decisions:

- Prompts are stored in `git notes`. This piggybacks on existing well-tested git infrastructure for managing notes and handles commit SHA changes.
- Each commit holds the entire prompt chain that led to that commit. The chain is in reverse chronological order so the top prompt is always the causal prompt that resulted in the commit you're looking at.

---

## Note Schema

```text
Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401
Assistant-Harness: Antigravity CLI 1.1.25
Assistant-Model: Gemini 3.8 Flash (High)
Assistant-Recorded: 2026-09-04 01:03:57 UTC

Assistant-Prompts:
  [2026-09-04 01:09:25 UTC] Let's implement this.
  [2026-09-04 01:03:57 UTC] Pivot camera around ball origin
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

## Prompt Prefixes

Prompts can be excluded or retracted from notes using prefix tags in your messages.

### Excluding Prompts

Prefix a prompt with any of the following tags to prevent it from being recorded:

- `[ignore]`
- `[skip]`
- `[wrong-session]`
- `[scratch]`

Example:
```text
[ignore] What was that git command again?
```

### Retracting Prompts

If an unintended prompt was already sent in the active session, send a retraction tag to drop it:

- `[ignore-last]` (or `[retract]`, `[wrong-session]`): Drops the preceding prompt.
- `[ignore-last N]`: Drops the preceding *N* prompts (e.g., `[ignore-last 2]`).
- `[ignore-all]`: Clears all prompts recorded for the current session.

Retraction and steering can be combined into a single message:
```text
[ignore-last] Actually, implement this instead...
```

### Manual Filtering & Editing

Prompts can also be filtered or modified via the CLI:

- `git prompt-log record --drop "<pattern>"`: Exclude prompts matching a regex pattern.
- `git prompt-log record --drop-last <N>`: Drop the last *N* prompts before recording.
- `git prompt-log edit HEAD`: Open the note in `$EDITOR` for manual editing.

---

## Uninstallation

To remove Git hooks and repository configuration:

```bash
# Remove post-rewrite and post-commit hooks from the current repository
git prompt-log uninstall-hook

# Completely remove hooks, unset local git notes config, and delete local skill
git prompt-log uninstall-hook --all
```

To remove the CLI binary from your machine:

```bash
./uninstall.sh
```
