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

`git-prompt-log` is built and developed using `git-prompt-log`. Since Git notes are not cloned by default ([and should not be](#why-export-and-import-instead-of-pushing-notes)), initialize the repository and import our exported prompt log to inspect the real prompts that built this codebase:

```bash
# 1. Enable prompt logging in this repo (installs hooks & notes rewrite config):
git prompt-log init

# 2. Import past prompt notes:
git prompt-log import-log prompts/git-prompt-log.md

# 3. View the commit history with prompt timelines in rich color:
git prompt-log log
```

You can view the causal prompt on each commit, or pass `--full` to view the cumulative prompt history:

```bash
git prompt-log log --full
```

#### Try Live Prompt Recording

Now that the hooks are installed, see automated prompt tracking in action:

1. Ask your coding assistant (e.g. Google Antigravity, Claude Code) to make a change and commit it:
   > *"Add a small doc improvement to the README and commit it"*

2. Look at the log again:
   ```bash
   git prompt-log log -n 1
   ```
   Notice that the newly created commit automatically carries the exact steering prompt you gave your assistant!

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

Git notes are not pushed or fetched by default during standard `git push` or GitHub PR workflows (see [Why Export and Import Instead of Pushing Notes?](#why-export-and-import-instead-of-pushing-notes)):

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

### Why Export and Import Instead of Pushing Notes?

Git notes are ideal for local, non-invasive metadata storage, but pushing `refs/notes/*` directly to shared remotes creates several major problems that export and import solve:

1. **Privacy & Preventing Leaks:** Your local `refs/notes/commits` ref is repository-wide. It contains prompt notes for *all* local commits, including unpushed experiments, private feature branches, and sensitive queries you never intended to publish. Pushing the notes ref is an all-or-nothing operation that risks leaking private prompts. Exporting packages only the prompts for the specific branch and PR you intend to share.
2. **PR Workflow Friction:** Pushing notes alongside branches is painful. You have to push both the branch and the notes ref (`git push origin my-branch refs/notes/*`), pull request interfaces have no concept of dual-ref submissions, and concurrent note pushes by teammates cause non-fast-forward rejections that require tedious `git notes merge` steps. With export, prompt history is just a standard file in your branch—one ordinary `git push` handles everything.
3. **Invisibility:** Git notes are completely invisible in GitHub, GitLab, and Bitbucket pull request diffs and web interfaces. Reviewers cannot see the prompts that generated the code or leave comments on them. An exported Markdown file in `prompts/` lives directly in the PR diff alongside the code.
4. **Surviving GitHub Squash & Rebase:** When a pull request is squashed or rebased via GitHub's web UI, GitHub generates brand new commit SHAs on `main`. Remote Git notes attached to your branch commits are left behind and orphaned. Because the exported Markdown log is committed to the repository, maintainers can run `git prompt-log import-log` on `main` to match commits by subject and re-hydrate prompt notes onto the new commits.

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

## Session Prompt Management (Exclusions & Retraction)

You can inspect, exclude, or restore individual prompts from an active assistant session using the `session` subcommand:

```bash
# List prompts in the active session with 1-based index numbers
git prompt-log session

# Mark a specific prompt turn (e.g. #2) as excluded from this session
git prompt-log session drop 2

# Exclude prompts matching a specific pattern for this session
git prompt-log session drop "Commit"

# Restore a previously excluded prompt
git prompt-log session undrop 2

# Clear all session-specific exclusions
git prompt-log session clear
```

Session exclusions are persisted in `prompt-log-excludes.json` alongside the session data, and the prompt note on `HEAD` is automatically refreshed.

### Manual Filtering & Editing

Prompts can also be filtered or modified retroactively via the CLI:

- `git prompt-log record --drop "<pattern>"`: Exclude prompts matching a regex pattern (works on existing notes or new recordings). *(Caveat: The prompt will come back on subsequent commits from the same session if edited away in this way—use `git prompt-log session drop` for persistent session exclusion).*
- `git prompt-log record --drop-last <N>`: Drop the last *N* prompts before recording. *(Caveat: Dropped prompts will come back on subsequent commits from the same session).*
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
