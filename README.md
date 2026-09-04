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

### Quickstart: Try It On This Repo

`git-prompt-log` is built and developed using `git-prompt-log`. Since Git notes are not cloned by default, import our exported prompt log to inspect the real prompts that built this codebase:

```bash
# In the cloned git-prompt-log directory:
git prompt-log init
git prompt-log import-log prompts/git-prompt-log.md

# View the commit history with prompt timelines in rich color:
git prompt-log log
```

You can view the causal prompt on each commit, or pass `--full` to view the cumulative prompt history:

```bash
git prompt-log log --full
```

### The Day-to-Day Workflow

In practice, **you will almost never run `record` yourself**. Once enabled in a repository, `git-prompt-log` works completely automatically in the background:

1. **Prompt and commit naturally:** When your coding assistant (e.g. Google Antigravity, Claude Code) authors a commit, the `.git/hooks/post-commit` hook automatically detects the active session, extracts the steering prompt that guided the work, and attaches it as a git note. Regular human commits are unaffected.
2. **Rebasing and squashing just work:** When you rebase, squash, or amend commits, Git invokes the `.git/hooks/post-rewrite` hook, which automatically preserves and merges prompt chains in reverse-chronological order.
3. **Inspect anytime:**
   ```bash
   # View recent commits and their active steering prompts:
   git prompt-log log

   # Standard git log also includes prompt notes:
   git log -n 1
   ```

### Pull Requests & Collaboration (Export & Import)

Because Git notes are not pushed or fetched by default during standard `git push` or GitHub PR workflows:

1. **Export for PR Review:** Before opening a PR, package the accumulated prompt notes into a Markdown log on your branch:
   ```bash
   git prompt-log export-log --commit
   ```
   This writes `prompts/YYYY_MM_DD_HHMMSS_<slug>.md` and commits it to your branch, giving reviewers full visibility into your prompt history alongside code diffs.

2. **Re-hydrate on Merge (Maintainer):** When the PR merges into `main` (even if squashed or rebased via GitHub's web UI), restore the notes on `main`:
   ```bash
   git prompt-log import-log prompts/YYYY_MM_DD_HHMMSS_<slug>.md
   ```
   The tool matches commits by commit subject or hash and re-attaches prompt provenance into `refs/notes/commits`.

### Enable in Any Repository

To enable prompt logging in any other project:

```bash
cd my-project
git prompt-log init
```

This single command:
1. Installs `.git/hooks/post-commit` to record prompts when an assistant commits (no-op during human commits; skip with `--no-post-commit`).
2. Installs `.git/hooks/post-rewrite` so Git automatically reconciles notes on rebase/squash.
3. Configures repository-scoped Git notes rewriting (`notes.rewrite.rebase = true`, `notes.rewriteRef = refs/notes/commits`).

*(Optional: pass `--skill` to also install the repository assistant skill at `.agents/skills/git-prompt-log/SKILL.md`).*

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

#### Targeted Retraction (Any Time in the Session)

You do not need to retract a prompt immediately on the next turn. At any point later in the conversation, target earlier prompts by text matching or turn index:

- `[retract "Commit"]` (or `[drop-prompt "Commit"]`): Excises earlier prompts matching `"Commit"` from the session history.
- `[retract #2]` (or `[drop-prompt 2]`): Excises prompt turn #2 from the session history.
- `[retract "Commit"] Implement authentication instead`: Retracts an earlier prompt and steers in the same turn.

### Session Prompt Management (CLI)

To inspect and exclude specific prompts from an active session without modifying raw transcript files or setting blanket global regexes:

```bash
# List prompts in the active session with 1-based index numbers
git prompt-log session

# Mark a specific prompt turn (e.g. #2) as excluded from this session
git prompt-log session drop 2

# Or exclude prompts matching a specific pattern for this session
git prompt-log session drop "Commit"

# Restore a previously excluded prompt
git prompt-log session undrop 2

# Clear all session-specific exclusions
git prompt-log session clear
```

Session exclusions are persisted in `prompt-log-excludes.json` alongside the session data, and the note on `HEAD` is automatically refreshed.

### Always-Skip Patterns (Configuration)

To permanently and automatically skip routine recurring prompts (such as `"Commit"`, `"push"`, or short housekeeping directives) across all recordings without needing manual prefixes:

```bash
# Add an exclusion pattern for the current repository
git config --add prompt-log.exclude "^(?i)commit$"

# Or configure globally across all repositories
git config --global --add prompt-log.exclude "^(?i)commit$"
```

Any prompt matching a configured `prompt-log.exclude` regex will be automatically omitted from prompt notes by both the post-commit hook and `git prompt-log record`.

### Manual Filtering & Editing

Prompts can also be filtered or modified retroactively via the CLI:

- `git prompt-log record --drop "<pattern>"`: Exclude prompts matching a regex pattern (works on existing notes or new recordings).
- `git prompt-log record --drop-last <N>`: Drop the last *N* prompts before recording.
- `git prompt-log edit HEAD`: Open the note in `$EDITOR` for manual editing.

---

## Supported Harnesses

`git-prompt-log` automatically detects and ingests prompts from supported assistant harnesses or manual human entry:

| Harness | Identifier | Signals & Transcripts |
| :--- | :--- | :--- |
| Google Antigravity | `antigravity` | `$AGY_SESSION_ID`, `$ANTIGRAVITY_CONVERSATION_ID`, `brain/` |
| Claude Code | `claude` | `$CLAUDE_SESSION_ID`, `~/.claude/projects/`, `$CLAUDE_TRANSCRIPT_PATH` |
| Manual Entry | `manual` | `-m / --message "..."` or `--stdin` |

### Configuring Your Assistant Harness

You can explicitly specify which assistant harness to use for this repository or globally without relying on environment variables:

```bash
# Set default harness for current repository
git prompt-log harness antigravity
# or via standard git config:
git config prompt-log.harness antigravity

# Or configure globally across all repositories
git prompt-log harness --global antigravity
# or:
git config --global prompt-log.harness antigravity

# Initialize a repository with an explicit default harness
git prompt-log init --harness antigravity

# Or override via environment variable
export PROMPT_LOG_HARNESS=antigravity

# View current configuration, active session, and supported harnesses
git prompt-log harness
git prompt-log harness --json

# Clear configuration to restore auto-detection
git prompt-log harness clear
```

### Manual Prompt Recording (Human or Scripted)

For commits authored manually by humans or piped from external scripts:

```bash
# Record prompt manually on HEAD
git prompt-log record -m "Implement OAuth authentication flow"

# Pipe prompt via standard input
echo "Refactor database query batching" | git prompt-log record --stdin

# Specify custom harness and model metadata
git prompt-log record -m "Initial schema proposal" --harness "Human" --model "Manual"
```

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
