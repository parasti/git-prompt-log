# Claude Code compatibility sweep — design

Date: 2026-09-07
Status: Approved (design), pending implementation plan

## Context

`git-prompt-log` was built for the Antigravity (Gemini) harness and later gained
a `ClaudeCodeAdapter`. Recording (`post-commit` → `cmd_record` → adapter
registry) now works for Claude Code, but several other code paths were never
updated and still assume the Antigravity harness. This effort fixes the
remaining Claude incompatibilities.

Hard constraint: **do not change Antigravity behavior.** Antigravity is used
daily and works 100%. The existing (Antigravity-heavy) test suite is the
regression guarantee — every test in it must keep passing with its current
meaning.

## Goals

Fix the four known Claude incompatibilities:

1. `git prompt-log session` (inspect prompts + manage exclusions) is
   Antigravity-only and reports "No prompts found" for every Claude session.
2. Exclusion management (`session drop`/`exclude`/`restore`) is unreachable for
   Claude (blocked by #1).
3. Identity fallbacks: stale Claude default model; dead module-level
   `get_agent_identity()`.
4. Claude session↔repo association fails across git worktrees, because Claude
   files a transcript under a project directory named for the launch path, which
   may not match the repo you are standing in.

## Non-goals

- No changes to `AntigravityAdapter`, the brain-dir helpers
  (`get_brain_dir`, `get_brain_dirs`, `find_session_dir`), or
  `parse_session_transcript` (which delegates to the Antigravity parser).
- No changes to the recording pipeline, note format, or the rewrite-chain logic.
- No new harnesses.

## Guiding approach

Dispatch the Claude-affected paths through the existing adapter registry, and
confine all new logic to `ClaudeCodeAdapter` and the harness-neutral command
code. Antigravity paths are left untouched and are exercised unchanged by the
existing suite.

## Design

### 1. `cmd_session` becomes harness-aware

Today `cmd_session` (no `--session` given) reaches `find_session_transcript()`,
which correctly finds the Claude session via the registry, then **discards it**
and re-derives the transcript path via Antigravity's brain-dir layout
(`<brain>/<sid>/.system_generated/logs/transcript.jsonl`) and re-parses with the
Antigravity parser (`parse_session_transcript`). For Claude that path does not
exist, so it returns `None` → "No prompts found".

Change: at the resolution point (currently lines ~2936–2957), obtain the
adapter that owns the session and branch:

- **Antigravity** → existing brain-dir resolution + `parse_session_transcript`,
  **unchanged**.
- **Claude / any non-Antigravity** → call
  `REGISTRY.find_session_data(adapter_name=<name>, session_id=<sid>,
  repo_root=<repo>, apply_session_excludes=False)` and use `data["prompts"]` and
  `data["session_id"]` directly. No brain-dir or Antigravity-parser assumptions.

`apply_session_excludes=False` yields the raw, unfiltered prompt list so the
command can still show `[EXCLUDED]` status. Exclusion actions
(`drop`/`exclude`/`restore`) then operate on that prompt list plus `session_id`
via the existing `load_session_excludes` / `save_session_excludes`, which already
resolve a Claude-compatible fallback path under the git common dir
(`<common_git>/prompt-log/sessions/<sid>.json`) when no Antigravity brain dir
exists.

The branch is chosen by the adapter identity the registry returns, so the
Antigravity flow is entered only for Antigravity and is otherwise identical.

### 2. Active-session shortcut recognizes Claude

The no-argument env check (line ~2909) reads only `AGY_SESSION_ID` /
`ANTIGRAVITY_CONVERSATION_ID`. Add `CLAUDE_CODE_SESSION_ID` as an additional
source (append, do not replace the Antigravity variables) so that running
`git prompt-log session` inside a live Claude session resolves directly to that
session id.

### 3. Claude session↔repo association by cwd/worktree

In `ClaudeCodeAdapter` only. When scanning candidate transcripts
(`find_session_data`), read each transcript's recorded `cwd` (present on Claude
Code entries) and treat the session as belonging to the repo when that `cwd` is
the repo root or falls within the repo's worktree tree.

Worktree tree = the set of paths from `git worktree list --porcelain` plus the
common dir's working tree. A new helper (e.g. `_get_repo_worktree_paths(repo_root)`)
computes it; matching is by path containment (a `cwd` equal to or nested under
any worktree path).

This is added **alongside** the current file-path identifier match, which
remains the fallback when a transcript has no `cwd` (older transcripts). When
both a cwd match and a path match are available, cwd match wins. Recency
tie-breaking among multiple matches is unchanged (most recent transcript).

Antigravity association (`_session_matches_repo`) is not touched.

### 4. Identity cleanup

- Replace the stale `ClaudeCodeAdapter.get_agent_identity` fallback model
  `"Claude 3.7 Sonnet"` with a neutral `"Claude"`. The real model is still read
  from the transcript when present; the fallback only applies when it is absent.
- Remove the dead module-level `get_agent_identity()` function (no callers). The
  per-adapter `get_agent_identity` methods are unaffected.

## Testing

New Claude-focused tests:

- `session` (list/show) end-to-end for a Claude transcript: prompts are listed.
- Exclusion round-trip: `session drop <target>` then `session` shows
  `[EXCLUDED]`; `restore` clears it — using the Claude fallback excludes path.
- Active-session resolution via `CLAUDE_CODE_SESSION_ID` env.
- Worktree cwd-association: a Claude transcript filed under a project directory
  whose name does not match the repo, but whose `cwd` is inside the repo's
  worktree tree, is still associated with the repo.
- Identity: Claude fallback model is `"Claude"` when the transcript has no model.

The **entire existing suite must stay green** — it is the Antigravity regression
guarantee. No existing test changes meaning.

## Antigravity-safety checklist

- No edits to `AntigravityAdapter`, `get_brain_dir`, `get_brain_dirs`,
  `find_session_dir`, `parse_session_transcript`, or `_session_matches_repo`.
- New behavior gated on the resolved adapter being non-Antigravity, or lives in
  `ClaudeCodeAdapter`.
- Full existing suite green after each change.

## Touch list (anticipated)

- `bin/git-prompt-log`:
  - `cmd_session` — harness-aware branch (Section 1) + Claude env source
    (Section 2).
  - `ClaudeCodeAdapter.find_session_data` + new `_get_repo_worktree_paths`
    helper (Section 3).
  - `ClaudeCodeAdapter.get_agent_identity` fallback model; delete module-level
    `get_agent_identity()` (Section 4).
- `tests/test_git_prompt_log.py` — new Claude tests (all sections).
