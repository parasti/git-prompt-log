# Prompt Log Export 2026-09-09 23:24:50 UTC

- **Generator:** [git-prompt-log](https://github.com/parasti/git-prompt-log)
- **Export command:** `git prompt-log export --commit --slug install_cleanup_and_export_skill_guidance`
- **Import command:** `git prompt-log import prompts/2026_09_09_232450_install_cleanup_and_export_skill_guidance.md`

---

- **Session:** `87a3376c-c8e2-4ef5-8883-080b0ebb05d0`
- **Harness:** Antigravity CLI 1.1.28
- **Model:** Gemini 3.8 Flash (High)

## Commits

- `5dd4935b` feat(install): remove global gitconfig setup and clarify per-repo init requirement
- `a6059220` docs(skill): guide autonomous slug synthesis for prompt log export

## Steering Prompts

#### [2026-09-08 07:35:59 UTC]

> Let' s investigate and improve human-initiated recording, as it is somewhat unintuitive - I had 7 commits with missing prompts (because I was working on supporting that harness at that time), then went to do `git prompt-log record range`, and it just picked a random session and forced those prompts into that range, as well as added a prompt note for a commit that wasn't even created via a harness. I realize that this is asking a lot, but at the time there was no method to delete notes, so that left the prompt log in a bad state. A part of the issue is the fact that you can't even use `git prompt-log session` to find the session you need - it just lists prompts from a random session it found, no ability to see sessions that might apply to this cwd.

#### [2026-09-08 07:40:32 UTC]

> [tool:ask_question] (Recommended) Skip unprompted commits in ranges by default (only record on commits with prompts matching their timeframe; report skipped commits), and remove the blind all-prompts fallback.

#### [2026-09-08 07:41:59 UTC]

> [tool:ask_question] Only add `git prompt-log session list-sessions` (no top-level `sessions` command), requiring full session UUIDs for `--session`.

#### [2026-09-08 07:45:22 UTC]

> This design looks good.

#### [2026-09-08 07:54:51 UTC]

> Export prompts for the past two sessions

#### [2026-09-08 09:07:05 UTC]

> I am using a coding agent in redacted while having git-prompt-log set up globally in .gitconfig, but it's not recording notes.

#### [2026-09-08 09:09:06 UTC]

> Yes, do it. Also, remove the global .gitconfig stuff from install.sh since it only works partially.

Commits:
- `5dd4935b` feat(install): remove global gitconfig setup and clarify per-repo init requirement

#### [2026-09-08 09:16:44 UTC]

> Update skill, so agent doesn't get confused about what to do when asked to export a prompt log: it should build a slug from what it knows (because it knows best other than a human), then pass that to the record command and commit.

Commits:
- `a6059220` docs(skill): guide autonomous slug synthesis for prompt log export

<!-- git-prompt-log:metadata
{
  "version": 1,
  "exported_at": "2026-09-09 23:24:50 UTC",
  "export_command": "git prompt-log export --commit --slug install_cleanup_and_export_skill_guidance",
  "import_command": "git prompt-log import prompts/2026_09_09_232450_install_cleanup_and_export_skill_guidance.md",
  "commits": [
    {
      "hash": "5dd4935bb05968e7113f98fa930c2a7d24506062",
      "subject": "feat(install): remove global gitconfig setup and clarify per-repo init requirement",
      "note": "Assistant-Session: 87a3376c-c8e2-4ef5-8883-080b0ebb05d0\nAssistant-Harness: Antigravity CLI 1.1.27\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-08 09:12:03 UTC\n\nAssistant-Prompts:\n  [2026-09-08 09:09:06 UTC] Yes, do it. Also, remove the global .gitconfig stuff from install.sh since it only works partially.\n  [2026-09-08 09:07:05 UTC] I am using a coding agent in redacted while having git-prompt-log set up globally in .gitconfig, but it's not recording notes.\n  [2026-09-08 07:54:51 UTC] Export prompts for the past two sessions\n  [2026-09-08 07:45:22 UTC] This design looks good.\n  [2026-09-08 07:41:59 UTC] [tool:ask_question] Only add `git prompt-log session list-sessions` (no top-level `sessions` command), requiring full session UUIDs for `--session`.\n  [2026-09-08 07:40:32 UTC] [tool:ask_question] (Recommended) Skip unprompted commits in ranges by default (only record on commits with prompts matching their timeframe; report skipped commits), and remove the blind all-prompts fallback.\n  [2026-09-08 07:35:59 UTC] Let' s investigate and improve human-initiated recording, as it is somewhat unintuitive - I had 7 commits with missing prompts (because I was working on supporting that harness at that time), then went to do `git prompt-log record range`, and it just picked a random session and forced those prompts into that range, as well as added a prompt note for a commit that wasn't even created via a harness. I realize that this is asking a lot, but at the time there was no method to delete notes, so that left the prompt log in a bad state. A part of the issue is the fact that you can't even use `git prompt-log session` to find the session you need - it just lists prompts from a random session it found, no ability to see sessions that might apply to this cwd."
    },
    {
      "hash": "a6059220df69099ee5021a3fcde1a4793f26719f",
      "subject": "docs(skill): guide autonomous slug synthesis for prompt log export",
      "note": "Assistant-Session: 87a3376c-c8e2-4ef5-8883-080b0ebb05d0\nAssistant-Harness: Antigravity CLI 1.1.28\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-09 23:23:04 UTC\n\nAssistant-Prompts:\n  [2026-09-08 09:16:44 UTC] Update skill, so agent doesn't get confused about what to do when asked to export a prompt log: it should build a slug from what it knows (because it knows best other than a human), then pass that to the record command and commit.\n  [2026-09-08 09:09:06 UTC] Yes, do it. Also, remove the global .gitconfig stuff from install.sh since it only works partially.\n  [2026-09-08 09:07:05 UTC] I am using a coding agent in redacted while having git-prompt-log set up globally in .gitconfig, but it's not recording notes.\n  [2026-09-08 07:54:51 UTC] Export prompts for the past two sessions\n  [2026-09-08 07:45:22 UTC] This design looks good.\n  [2026-09-08 07:41:59 UTC] [tool:ask_question] Only add `git prompt-log session list-sessions` (no top-level `sessions` command), requiring full session UUIDs for `--session`.\n  [2026-09-08 07:40:32 UTC] [tool:ask_question] (Recommended) Skip unprompted commits in ranges by default (only record on commits with prompts matching their timeframe; report skipped commits), and remove the blind all-prompts fallback.\n  [2026-09-08 07:35:59 UTC] Let' s investigate and improve human-initiated recording, as it is somewhat unintuitive - I had 7 commits with missing prompts (because I was working on supporting that harness at that time), then went to do `git prompt-log record range`, and it just picked a random session and forced those prompts into that range, as well as added a prompt note for a commit that wasn't even created via a harness. I realize that this is asking a lot, but at the time there was no method to delete notes, so that left the prompt log in a bad state. A part of the issue is the fact that you can't even use `git prompt-log session` to find the session you need - it just lists prompts from a random session it found, no ability to see sessions that might apply to this cwd."
    }
  ]
}
-->
