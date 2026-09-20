# Prompt Log Export 2026-09-20 13:16:38 UTC

- **Generator:** [git-prompt-log](https://github.com/parasti/git-prompt-log)
- **Export command:** `git prompt-log export --range origin/main..HEAD --slug configurable_and_default_exclusions --commit`
- **Import command:** `git prompt-log import prompts/2026_09_20_131638_configurable_and_default_exclusions.md`

---

- **Session:** `74e94227-7fc0-4842-97b1-dee001823147`
- **Harness:** Antigravity CLI 1.2.7
- **Model:** Gemini 3.8 Flash (High)

## Commits

- `00c142c2` feat(exclude): add configurable exclusions and default routine prompt exclusions

## Steering Prompts

#### [2026-09-20 12:52:19 UTC]

> /plan Add back configurable exclusions (via git config like we used to have) and have default exclusions enabled unless overridden: '^[Yy]es\.?$', '^[Dd]o it\.?$', '^[Oo][Kk]$', '^[Rr]esume$'

#### [2026-09-20 13:03:00 UTC]

> "prompt-note.exclude" -> no need for legacy support, remove all plans of that. Also, make the regexes consistent - e.g., some accept a trailing period, some don't while all should accept all forms equally. I don't think uninstall should be removing user config. Uesrs should be removing user config.

#### [2026-09-20 13:06:12 UTC]

> [Approved] configurable_exclusions_plan.md

#### [2026-09-20 13:15:58 UTC]

> Commit and generate a prompt log for the sesssion in a separate commit.

Commits:
- `00c142c2` feat(exclude): add configurable exclusions and default routine prompt exclusions

<!-- git-prompt-log:metadata
{
  "version": 1,
  "exported_at": "2026-09-20 13:16:38 UTC",
  "export_command": "git prompt-log export --range origin/main..HEAD --slug configurable_and_default_exclusions --commit",
  "import_command": "git prompt-log import prompts/2026_09_20_131638_configurable_and_default_exclusions.md",
  "commits": [
    {
      "hash": "00c142c2f5f0eb8a638f198f6dfbadc521786e66",
      "subject": "feat(exclude): add configurable exclusions and default routine prompt exclusions",
      "note": "Assistant-Session: 74e94227-7fc0-4842-97b1-dee001823147\nAssistant-Harness: Antigravity CLI 1.2.7\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-20 13:16:11 UTC\n\nAssistant-Prompts:\n  [2026-09-20 13:15:58 UTC] Commit and generate a prompt log for the sesssion in a separate commit.\n  [2026-09-20 13:06:12 UTC] [Approved] configurable_exclusions_plan.md\n  [2026-09-20 13:03:00 UTC] \"prompt-note.exclude\" -> no need for legacy support, remove all plans of that. Also, make the regexes consistent - e.g., some accept a trailing period, some don't while all should accept all forms equally. I don't think uninstall should be removing user config. Uesrs should be removing user config.\n  [2026-09-20 12:52:19 UTC] /plan Add back configurable exclusions (via git config like we used to have) and have default exclusions enabled unless overridden: '^[Yy]es\\.?$', '^[Dd]o it\\.?$', '^[Oo][Kk]$', '^[Rr]esume$'"
    }
  ]
}
-->
