# Prompt Log: Git-Prompt-Log

- **Exported:** 2026-09-04 22:53:02 UTC

- **Session:** `9674eda6-390f-4b1d-9910-72bec1843401`
- **Harness:** Antigravity CLI 1.1.25
- **Model:** Gemini 3.8 Flash (High)

- **Session:** `6f5dcc91-5281-4d36-bf55-f3da5c1ab997`
- **Harness:** Antigravity CLI 1.1.26
- **Model:** Gemini 3.8 Flash (High)

- **Session:** `264ec0fe-9040-412b-abe3-06d2c06305c3`
- **Harness:** Antigravity CLI 1.1.26
- **Model:** Gemini 3.8 Flash (High)

## Commits

- `73e9d0a8` feat: Initial release of git-prompt-note
- `6ec909d9` feat: Add init subcommand and make global config opt-in in installer
- `dce5fe95` feat: Add export-log and import-log commands for PR workflows
- `41f55bb7` cli: Install post-commit hook by default in init and install-hook
- `7ab0a313` cli: Add hook uninstallation and accidental prompt retraction
- `a0a984df` test: Add end-to-end integration tests for commit lifecycle and rewrites
- `cd8956bf` test: Add test for prompt note placement when dropping commits during rebase
- `cf9c91d1` cli: Prevent prompt duplication when commits are reordered in rebase
- `bddcd5ab` cli: Transition to cumulative prompt model with active and incremental views
- `a54d6e5d` cli: Add ANSI color formatting and pager integration to log command
- `c9994cf4` cli: Default prompt-note log revision range to HEAD
- `30969190` notes: Record prompts in reverse-chronological order with causal prompt at top
- `ca0d07f1` docs: Restructure documentation and rename skill to git-prompt-note
- `8bba2f9d` chore: Remove .agents directory
- `e0a44d9d` refactor: rename tool to git-prompt-log ("git prompt-log")
- `24a5f494` feat(cli): default install and init to no skill and add --skill flag
- `1b0c35c3` feat(hook): add automatic migration of legacy hooks on install
- `85025c06` feat(exclude): support persistent always-skip patterns via prompt-log.exclude and retroactive note pruning
- `b5d2e256` feat(session): add session-specific prompt exclusions and in-chat targeted retraction
- `02efc10f` feat(adapters): implement pluggable ingestion adapter scaffolding (antigravity, claude, aider, direct)
- `8c1280a0` refactor(adapters): drop Aider adapter
- `ca820871` refactor(adapters): rename direct adapter to manual
- `05d84ac9` fix(adapters): detect active agy session from process tree and remove dot from session exclusion file
- `eb2cdb6d` feat(harness): support explicit harness configuration via git config and harness command
- `1b3e8383` refactor(config): rename prompt-log.adapter to prompt-log.harness
- `4370f657` refactor(config): remove legacy prompt-log.adapter fallback
- `e5af4fc5` refactor(cli): consolidate adapters subcommand into harness subcommand
- `1e21a36c` refactor(cli): drop install subcommand in favor of init
- `7ebb4922` docs: reframe ingestion adapters as supported agents
- `c7863f1b` refactor(cli): standardize public interface and docs on harness

## Steering Prompts

### Session `9674eda6` (Gemini 3.8 Flash (High))

#### [2026-09-03 22:03:57 UTC]

> Git seems to have only one way of showing extra information on commits outside of the DAG and that is via git notes. So we must use git notes. But what do we want to store on those git notes? "Here is the model, harness and session (prompts) that lead to this commit being made". I just tried to use "git ai" (a tool for this) and it fails on the basic premise of showing the prompts - I learned they had that and removed it because removing PII and sensitive data from transcripts was hard; and this is very true but really a matter of hygiene, because if you have those in your transcripts then your model provider also has those now. And most people don't knowingly paste PII and sensitive data into their prompts - mostly it's the agent sniffing those out. So prompt sharing isn't a dead end. "git ai" does its thing by installing hooks into agents, listening to git event streams, wrapping git commands to show an interpretation of the JSON. It's a lot of stuff. But I want something that hones in on the git notes: this commit has a git note with information on how it came about, which model/harness/prompts were used - there are always prompts in a session that are the navigators, that set the course, upon which the rest of the stuff is built, so even if the prompt is "yes, do it" combined with the patch and these navigator prompts, it should be clear what happened without even needing to store megabytes of transcripts of LLM generated text. So commit -> git note -> session date/agent/model/prompts with dates leading up to commit. When rebasing, squashing, etc - this needs some thought: squashing is combining two into one, so I guess if prompts come from one session, they are combined (generally the longer one simply wins then), if they come from two sessions, both sessions are represented in the git note, and so on.

#### [2026-09-03 22:09:25 UTC]

> Let's implement this.

#### [2026-09-03 22:13:23 UTC]

> How do I use this?

#### [2026-09-03 22:19:41 UTC]

> So recording of prompt notes is fully manual?

#### [2026-09-03 22:24:52 UTC]

> "Human creates a commit during an active session" -> this is iffy to me, if I make commits myself those don't belong to a random session I have open.

#### [2026-09-03 22:29:12 UTC]

> Run a full end-to-end test with a separate repo and a headless agy

#### [2026-09-04 08:12:18 UTC]

> While in bed I had a bizarre thought: what if you use a regular branch as a notes ref?

#### [2026-09-04 08:15:10 UTC]

> How do people make pull requests with notes?

#### [2026-09-04 08:18:03 UTC]

> Feels like an extra tool could be written that does something "export notes to a file" and maintainer then runs "import notes from file"?

#### [2026-09-04 08:20:00 UTC]

> Well, it gets funny fast because the repo is then filled with exports of these JSON files.

#### [2026-09-04 08:23:03 UTC]

> Honestly, I think it needs to be a combination of the two. Agents and Git tracks prompts via git notes, then agent can export that to a commit, a PR flow happens, then maintainer imports it back into notes so that tracking keeps working. If we fully rely on in-tree files, it gets very messy very fast.

#### [2026-09-04 08:28:42 UTC]

> And honestly, I feel like refs/notes/commits is a good default to use (due to other refs needing extra annoying steps), but may benefit from delineating the prompt note as a block from the rest of the notes content.

#### [2026-09-04 08:29:39 UTC]

> Curious though, if that's even needed. The syntax for the prompt note is kind of easy to parse, right?

#### [2026-09-04 08:33:04 UTC]

> Maybe less ambiguous key names now that we've established it travels in shared storage.

#### [2026-09-04 08:34:38 UTC]

> Fuck I don't like that. Perhaps use "Assistant-" prefix. We're not AI yet.

#### [2026-09-04 08:35:42 UTC]

> There is nothing to be legacy compatible with. Just use the new way, feature is 5 hours old.

#### [2026-09-04 08:37:39 UTC]

> Great. So how do I use it if I want to start from zero on a new repo.

#### [2026-09-04 08:39:42 UTC]

> I want to distribute git-prompt-note as a separate thing from Neverball with a setup script, so I can just clone it and set it up with one command.

#### [2026-09-04 08:46:01 UTC]

> Okay, so I don't think anyone will want this to be global unless asked. So we need to ask in the setup script. If denied, show how to enable per repo (preferably just a simple git prompt-note thing, please).

#### [2026-09-04 08:56:32 UTC]

> Cool. Is it installed for me?

#### [2026-09-04 08:57:22 UTC]

> Will the skill be enough for agents to know and when to use this? Including the export steps?

#### [2026-09-04 08:59:13 UTC]

> Do all of this except AGENTS.md changes.

#### [2026-09-04 09:04:52 UTC]

> Does Git have hooks/someting to guarantee the record will happen? Agent may forget, I think?

#### [2026-09-04 09:07:09 UTC]

> Yeah, do it.

#### [2026-09-04 09:10:23 UTC]

> Make the hooks easily uninstallable.
> I sometimes type a prompt into the wrong session by accident when running them in parallel. Wouldn't want that prompt to land in a prompt note. Any way of marking prompts that way?

#### [2026-09-04 09:15:26 UTC]

> Explain how the tool decides which prompts should be on which commit? In this repo they make sense, but we're not doing my regular "make a worktree, add commits, iterate and rewrite multiple times until clean and working, then merge".

#### [2026-09-04 09:25:03 UTC]

> Are all these backed by tests?

#### [2026-09-04 12:01:50 UTC]

> What happens if I ask the agent to rebase and remove one of the commits?

#### [2026-09-04 12:07:10 UTC]

> I like to think that the "correct" approach is then to imagine how the prompt notes would look had the commit never been made. They would still record the dead end and the request to drop the changes.

#### [2026-09-04 12:08:33 UTC]

> Do a test with the rebase and tell me where the prompts land.

#### [2026-09-04 12:11:38 UTC]

> Okay, so just to reiterate, the prompts of commit 2 then land on commit 3 (that is now commit 2)?

#### [2026-09-04 12:12:07 UTC]

> That leads me to my next question: what happens if commits are reordered in a rebase?

#### [2026-09-04 12:16:41 UTC]

> Sometimes the agent does things like hard reset and recommit to clean up history. That sounds like it would destroy really any structure here - all prompts would land on the first commit.

#### [2026-09-04 12:23:03 UTC]

> I guess this could be seen as a special case? It would help immensely if those commits at least had a note with the last prompt. In fact, at any time when a commit sha1 changes, really the prompt responsible for that is the last prompt issued. So it gets into this spaghetti mess where if we squash commits, it gets the prompt notes of both of those commits as well as the prompts that lead to the squash? My brain starts aching all of a sudden!

#### [2026-09-04 12:26:13 UTC]

> Yes, but unsure how it fits into the architecture. Perhaps the current active prompt is a separate Assistant tag?

#### [2026-09-04 12:28:20 UTC]

> That's literally what I would expect: that each commit receives the full prompt list. My only reason for shying away from that is storage space, that is literally it.

#### [2026-09-04 12:30:59 UTC]

> Yes, let's explore this.

#### [2026-09-04 12:36:14 UTC]

> From a UI perspective I loved the existing method of only recording the incremental prompts - reading `git log` was a pleasure. But the hard problems are really forcing my hand here. Option A. I just realized that it's kind of like what Git does - doesn't record diffs, just records the entire tree state and makes an UI around that.

#### [2026-09-04 12:42:18 UTC]

> Wish git prompt-note log had colors and ran via a pager like git log does.

#### [2026-09-04 12:44:56 UTC]

> What does git prompt-note log really show by default? I only see one commit there.

#### [2026-09-04 12:47:55 UTC]

> That is kind of cool. It does have the moment of - when I look at the full prompt list for a commit, much of it I want to skip because it makes no sense. But the last prompt (the active prompt) is perfect, literally explains how we got to that commit.

#### [2026-09-04 12:50:57 UTC]

> I would be inclined to say to reverse the recorded list, so the causal prompt is already at the top.

### Session `6f5dcc91` (Gemini 3.8 Flash (High))

#### [2026-09-04 15:24:55 UTC]

> Have a technical writer subagent edit the README.md, update it for factual accuracy and groundedness, remove duplicate sections, trim the document down, put the important things first (what is this and how to use it is what people generaly want to read first rather than the full list of flags that the setup command supports)

#### [2026-09-04 15:27:58 UTC]

> Very important: remove all marketing clutter. "AI" isn't a thing. A tool doing what it does is sufficient, no need to say what it doesn't do - remove the "without cluttering" etc sections.

#### [2026-09-04 15:28:47 UTC]

> Remove the info about non-interactive setups, because I don't personally care.

#### [2026-09-04 15:29:35 UTC]

> I really hate that the subagent removed all my manually entered text for some reason.

#### [2026-09-04 15:30:59 UTC]

> I reverted all the changes made after my initial prompt. The subagent removed all my content that I typed in manually. I asked to edit and trim down, not to revert to the previous version.

#### [2026-09-04 15:32:31 UTC]

> Can we stop running tests on README.md edits.

#### [2026-09-04 15:37:20 UTC]

> I don't really understand how you're so bad at writing readmes, I would have figured the dataset for that is massive.

#### [2026-09-04 15:46:16 UTC]

> Here's an example of a good README (a couple of them): https://raw.githubusercontent.com/emscripten-core/emscripten/refs/heads/main/README.md https://raw.githubusercontent.com/TheLartians/substitute/refs/heads/main/README.md

#### [2026-09-04 15:47:21 UTC]

> Follow these examples, don't copy them

#### [2026-09-04 15:52:13 UTC]

> Any point to the SKILL.md? First off, it's dated. Second, seems like its only purpose might be to be informative to the agent, not to instruct it to use anything from this.

#### [2026-09-04 15:54:15 UTC]

> I feel like, as a skill, it should teach the agent to answer questions about the tool and use the tool for tasks when the user requests. So just fully rewrite it to that goal.

#### [2026-09-04 15:56:22 UTC]

> Didn't update  the name of the skill

#### [2026-09-04 15:58:43 UTC]

> "git push origin "refs/notes/*"" -> this must never ever be done, eradicate all examples of this. Our stance is to use import/export to share prompt notes

#### [2026-09-04 16:02:15 UTC]

> In the readme, reorganize this section "Accidental Prompts & Parallel Sessions" into a normal documentation section that explains prompt prefixes

#### [2026-09-04 16:09:43 UTC]

> Commit all this.

#### [2026-09-04 16:10:18 UTC]

> Remove .agents folder, don't think I need it.

### Session `264ec0fe` (Gemini 3.8 Flash (High))

#### [2026-09-04 21:06:25 UTC]

> Rename the entire tool to git-prompt-log / "git prompt-log"

#### [2026-09-04 21:24:18 UTC]

> For the install subcommand, default to no skill and install skill with --skill

#### [2026-09-04 21:30:18 UTC]

> How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?

#### [2026-09-04 21:32:05 UTC]

> Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the "Commit" prompt

#### [2026-09-04 21:43:02 UTC]

> Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.

#### [2026-09-04 21:51:07 UTC]

> Where are these choices saved?

#### [2026-09-04 21:53:42 UTC]

> How doe the command know the active session when run outside an agent process?

#### [2026-09-04 21:55:13 UTC]

> Would you say the tool as a whole is very Antigravity specific?

#### [2026-09-04 21:57:00 UTC]

> Build the ingestion adapter scaffolding.

#### [2026-09-04 22:07:12 UTC]

> I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?

#### [2026-09-04 22:08:37 UTC]

> Drop Aider.

#### [2026-09-04 22:10:37 UTC]

> Rename direct adapter to manual everywhere.

#### [2026-09-04 22:12:27 UTC]

> Remove dot from the exclusion file stored in a session dir to facilitate discovery.

#### [2026-09-04 22:13:41 UTC]

> I just ran `git prompt-log adapters` from inside agy and it still shows all adapters as inactive and active harness as none.

#### [2026-09-04 22:20:02 UTC]

> Walking the process tree and looking at open file descriptors is kind of insane. I would rather the user explicitly told us in some very simple way which harness they are using.

#### [2026-09-04 22:24:23 UTC]

> Let's use consistent terminology: rename prompt-log.adapter to prompt-log.harness, likewise for the env var.

#### [2026-09-04 22:27:50 UTC]

> "with automatic fallback to prompt-log.adapter" -> remove the fallback, this has never been deployed

#### [2026-09-04 22:29:40 UTC]

> adapters/harness commands serve basically the same purpose - remove adapters subcommand and integrate it into the harness subcommand

#### [2026-09-04 22:34:49 UTC]

> I got confused trying to figure out the difference between init and install subcommands.

#### [2026-09-04 22:38:34 UTC]

> "Ingestion Adapters & Manual Recording" -> humans reading a README will have no idea what this is, edit to say "Supported Agents" and generally remove any mention of pluggable adapters (nobody can plug them, it's internal architecture)

#### [2026-09-04 22:43:14 UTC]

> Do not retain --adapter as an alias; again - we've never deployed. I'm now confused, are we using --agent and harness both now? For consistency, stick to one or the other in public facing texts.

<!-- git-prompt-log:metadata
{
  "version": 1,
  "exported_at": "2026-09-04 22:53:02 UTC",
  "slug": "git-prompt-log",
  "commits": [
    {
      "hash": "73e9d0a8b951b2b13f9cdef66819679d0c36bbdd",
      "subject": "feat: Initial release of git-prompt-note",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 08:42:22 UTC\n\nAssistant-Prompts:\n  [2026-09-03 22:03:57 UTC] Git seems to have only one way of showing extra information on commits outside of the DAG and that is via git notes. So we must use git notes. But what do we want to store on those git notes? \"Here is the model, harness and session (prompts) that lead to this commit being made\". I just tried to use \"git ai\" (a tool for this) and it fails on the basic premise of showing the prompts - I learned they had that and removed it because removing PII and sensitive data from transcripts was hard; and this is very true but really a matter of hygiene, because if you have those in your transcripts then your model provider also has those now. And most people don't knowingly paste PII and sensitive data into their prompts - mostly it's the agent sniffing those out. So prompt sharing isn't a dead end. \"git ai\" does its thing by installing hooks into agents, listening to git event streams, wrapping git commands to show an interpretation of the JSON. It's a lot of stuff. But I want something that hones in on the git notes: this commit has a git note with information on how it came about, which model/harness/prompts were used - there are always prompts in a session that are the navigators, that set the course, upon which the rest of the stuff is built, so even if the prompt is \"yes, do it\" combined with the patch and these navigator prompts, it should be clear what happened without even needing to store megabytes of transcripts of LLM generated text. So commit -> git note -> session date/agent/model/prompts with dates leading up to commit. When rebasing, squashing, etc - this needs some thought: squashing is combining two into one, so I guess if prompts come from one session, they are combined (generally the longer one simply wins then), if they come from two sessions, both sessions are represented in the git note, and so on.\n  [2026-09-03 22:09:25 UTC] Let's implement this.\n  [2026-09-03 22:13:23 UTC] How do I use this?\n  [2026-09-03 22:19:41 UTC] So recording of prompt notes is fully manual?\n  [2026-09-03 22:24:52 UTC] \"Human creates a commit during an active session\" -> this is iffy to me, if I make commits myself those don't belong to a random session I have open.\n  [2026-09-03 22:29:12 UTC] Run a full end-to-end test with a separate repo and a headless agy\n  [2026-09-04 08:12:18 UTC] While in bed I had a bizarre thought: what if you use a regular branch as a notes ref?\n  [2026-09-04 08:15:10 UTC] How do people make pull requests with notes?\n  [2026-09-04 08:18:03 UTC] Feels like an extra tool could be written that does something \"export notes to a file\" and maintainer then runs \"import notes from file\"?\n  [2026-09-04 08:20:00 UTC] Well, it gets funny fast because the repo is then filled with exports of these JSON files.\n  [2026-09-04 08:23:03 UTC] Honestly, I think it needs to be a combination of the two. Agents and Git tracks prompts via git notes, then agent can export that to a commit, a PR flow happens, then maintainer imports it back into notes so that tracking keeps working. If we fully rely on in-tree files, it gets very messy very fast.\n  [2026-09-04 08:28:42 UTC] And honestly, I feel like refs/notes/commits is a good default to use (due to other refs needing extra annoying steps), but may benefit from delineating the prompt note as a block from the rest of the notes content.\n  [2026-09-04 08:29:39 UTC] Curious though, if that's even needed. The syntax for the prompt note is kind of easy to parse, right?\n  [2026-09-04 08:33:04 UTC] Maybe less ambiguous key names now that we've established it travels in shared storage.\n  [2026-09-04 08:34:38 UTC] Fuck I don't like that. Perhaps use \"Assistant-\" prefix. We're not AI yet.\n  [2026-09-04 08:35:42 UTC] There is nothing to be legacy compatible with. Just use the new way, feature is 5 hours old.\n  [2026-09-04 08:37:39 UTC] Great. So how do I use it if I want to start from zero on a new repo.\n  [2026-09-04 08:39:42 UTC] I want to distribute git-prompt-note as a separate thing from Neverball with a setup script, so I can just clone it and set it up with one command."
    },
    {
      "hash": "6ec909d99614822e3728978b0e46dc2d972147f4",
      "subject": "feat: Add init subcommand and make global config opt-in in installer",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 08:47:35 UTC\n\nAssistant-Prompts:\n  [2026-09-04 08:46:01 UTC] Okay, so I don't think anyone will want this to be global unless asked. So we need to ask in the setup script. If denied, show how to enable per repo (preferably just a simple git prompt-note thing, please)."
    },
    {
      "hash": "dce5fe957a49ee6c71eb8d771c02bf4a899ba0e9",
      "subject": "feat: Add export-log and import-log commands for PR workflows",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 09:02:09 UTC\n\nAssistant-Prompts:\n  [2026-09-04 08:56:32 UTC] Cool. Is it installed for me?\n  [2026-09-04 08:57:22 UTC] Will the skill be enough for agents to know and when to use this? Including the export steps?\n  [2026-09-04 08:59:13 UTC] Do all of this except AGENTS.md changes."
    },
    {
      "hash": "41f55bb794646d7e042c9000b3dd84f6be744ea1",
      "subject": "cli: Install post-commit hook by default in init and install-hook",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 09:10:10 UTC\n\nAssistant-Prompts:\n  [2026-09-04 09:04:52 UTC] Does Git have hooks/someting to guarantee the record will happen? Agent may forget, I think?\n  [2026-09-04 09:07:09 UTC] Yeah, do it."
    },
    {
      "hash": "7ab0a31317e8884229fd3b9c7f3d047a6a57e93a",
      "subject": "cli: Add hook uninstallation and accidental prompt retraction",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 09:15:08 UTC\n\nAssistant-Prompts:\n  [2026-09-04 09:10:23 UTC] Make the hooks easily uninstallable.\n    I sometimes type a prompt into the wrong session by accident when running them in parallel. Wouldn't want that prompt to land in a prompt note. Any way of marking prompts that way?"
    },
    {
      "hash": "a0a984dfc1baeb1e7c794c15cc97a1d539d3238c",
      "subject": "test: Add end-to-end integration tests for commit lifecycle and rewrites",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 09:28:21 UTC\n\nAssistant-Prompts:\n  [2026-09-04 09:15:26 UTC] Explain how the tool decides which prompts should be on which commit? In this repo they make sense, but we're not doing my regular \"make a worktree, add commits, iterate and rewrite multiple times until clean and working, then merge\".\n  [2026-09-04 09:25:03 UTC] Are all these backed by tests?"
    },
    {
      "hash": "cd8956bf85900a30e5d7a470b56097d5908d9015",
      "subject": "test: Add test for prompt note placement when dropping commits during rebase",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 12:09:25 UTC\n\nAssistant-Prompts:\n  [2026-09-04 12:01:50 UTC] What happens if I ask the agent to rebase and remove one of the commits?\n  [2026-09-04 12:07:10 UTC] I like to think that the \"correct\" approach is then to imagine how the prompt notes would look had the commit never been made. They would still record the dead end and the request to drop the changes.\n  [2026-09-04 12:08:33 UTC] Do a test with the rebase and tell me where the prompts land."
    },
    {
      "hash": "cf9c91d1987927bfc67ab7a711ec21e1cafb1294",
      "subject": "cli: Prevent prompt duplication when commits are reordered in rebase",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 12:13:54 UTC\n\nAssistant-Prompts:\n  [2026-09-04 12:11:38 UTC] Okay, so just to reiterate, the prompts of commit 2 then land on commit 3 (that is now commit 2)?\n  [2026-09-04 12:12:07 UTC] That leads me to my next question: what happens if commits are reordered in a rebase?"
    },
    {
      "hash": "bddcd5abade3accadfa7537fd4973aa1dec54cee",
      "subject": "cli: Transition to cumulative prompt model with active and incremental views",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 12:39:32 UTC\n\nAssistant-Prompts:\n  [2026-09-03 22:03:57 UTC] Git seems to have only one way of showing extra information on commits outside of the DAG and that is via git notes. So we must use git notes. But what do we want to store on those git notes? \"Here is the model, harness and session (prompts) that lead to this commit being made\". I just tried to use \"git ai\" (a tool for this) and it fails on the basic premise of showing the prompts - I learned they had that and removed it because removing PII and sensitive data from transcripts was hard; and this is very true but really a matter of hygiene, because if you have those in your transcripts then your model provider also has those now. And most people don't knowingly paste PII and sensitive data into their prompts - mostly it's the agent sniffing those out. So prompt sharing isn't a dead end. \"git ai\" does its thing by installing hooks into agents, listening to git event streams, wrapping git commands to show an interpretation of the JSON. It's a lot of stuff. But I want something that hones in on the git notes: this commit has a git note with information on how it came about, which model/harness/prompts were used - there are always prompts in a session that are the navigators, that set the course, upon which the rest of the stuff is built, so even if the prompt is \"yes, do it\" combined with the patch and these navigator prompts, it should be clear what happened without even needing to store megabytes of transcripts of LLM generated text. So commit -> git note -> session date/agent/model/prompts with dates leading up to commit. When rebasing, squashing, etc - this needs some thought: squashing is combining two into one, so I guess if prompts come from one session, they are combined (generally the longer one simply wins then), if they come from two sessions, both sessions are represented in the git note, and so on.\n  [2026-09-03 22:09:25 UTC] Let's implement this.\n  [2026-09-03 22:13:23 UTC] How do I use this?\n  [2026-09-03 22:19:41 UTC] So recording of prompt notes is fully manual?\n  [2026-09-03 22:24:52 UTC] \"Human creates a commit during an active session\" -> this is iffy to me, if I make commits myself those don't belong to a random session I have open.\n  [2026-09-03 22:29:12 UTC] Run a full end-to-end test with a separate repo and a headless agy\n  [2026-09-04 08:12:18 UTC] While in bed I had a bizarre thought: what if you use a regular branch as a notes ref?\n  [2026-09-04 08:15:10 UTC] How do people make pull requests with notes?\n  [2026-09-04 08:18:03 UTC] Feels like an extra tool could be written that does something \"export notes to a file\" and maintainer then runs \"import notes from file\"?\n  [2026-09-04 08:20:00 UTC] Well, it gets funny fast because the repo is then filled with exports of these JSON files.\n  [2026-09-04 08:23:03 UTC] Honestly, I think it needs to be a combination of the two. Agents and Git tracks prompts via git notes, then agent can export that to a commit, a PR flow happens, then maintainer imports it back into notes so that tracking keeps working. If we fully rely on in-tree files, it gets very messy very fast.\n  [2026-09-04 08:28:42 UTC] And honestly, I feel like refs/notes/commits is a good default to use (due to other refs needing extra annoying steps), but may benefit from delineating the prompt note as a block from the rest of the notes content.\n  [2026-09-04 08:29:39 UTC] Curious though, if that's even needed. The syntax for the prompt note is kind of easy to parse, right?\n  [2026-09-04 08:33:04 UTC] Maybe less ambiguous key names now that we've established it travels in shared storage.\n  [2026-09-04 08:34:38 UTC] Fuck I don't like that. Perhaps use \"Assistant-\" prefix. We're not AI yet.\n  [2026-09-04 08:35:42 UTC] There is nothing to be legacy compatible with. Just use the new way, feature is 5 hours old.\n  [2026-09-04 08:37:39 UTC] Great. So how do I use it if I want to start from zero on a new repo.\n  [2026-09-04 08:39:42 UTC] I want to distribute git-prompt-note as a separate thing from Neverball with a setup script, so I can just clone it and set it up with one command.\n  [2026-09-04 08:46:01 UTC] Okay, so I don't think anyone will want this to be global unless asked. So we need to ask in the setup script. If denied, show how to enable per repo (preferably just a simple git prompt-note thing, please).\n  [2026-09-04 08:56:32 UTC] Cool. Is it installed for me?\n  [2026-09-04 08:57:22 UTC] Will the skill be enough for agents to know and when to use this? Including the export steps?\n  [2026-09-04 08:59:13 UTC] Do all of this except AGENTS.md changes.\n  [2026-09-04 09:04:52 UTC] Does Git have hooks/someting to guarantee the record will happen? Agent may forget, I think?\n  [2026-09-04 09:07:09 UTC] Yeah, do it.\n  [2026-09-04 09:10:23 UTC] Make the hooks easily uninstallable.\n    I sometimes type a prompt into the wrong session by accident when running them in parallel. Wouldn't want that prompt to land in a prompt note. Any way of marking prompts that way?\n  [2026-09-04 09:15:26 UTC] Explain how the tool decides which prompts should be on which commit? In this repo they make sense, but we're not doing my regular \"make a worktree, add commits, iterate and rewrite multiple times until clean and working, then merge\".\n  [2026-09-04 09:25:03 UTC] Are all these backed by tests?\n  [2026-09-04 12:01:50 UTC] What happens if I ask the agent to rebase and remove one of the commits?\n  [2026-09-04 12:07:10 UTC] I like to think that the \"correct\" approach is then to imagine how the prompt notes would look had the commit never been made. They would still record the dead end and the request to drop the changes.\n  [2026-09-04 12:08:33 UTC] Do a test with the rebase and tell me where the prompts land.\n  [2026-09-04 12:11:38 UTC] Okay, so just to reiterate, the prompts of commit 2 then land on commit 3 (that is now commit 2)?\n  [2026-09-04 12:12:07 UTC] That leads me to my next question: what happens if commits are reordered in a rebase?\n  [2026-09-04 12:16:41 UTC] Sometimes the agent does things like hard reset and recommit to clean up history. That sounds like it would destroy really any structure here - all prompts would land on the first commit.\n  [2026-09-04 12:23:03 UTC] I guess this could be seen as a special case? It would help immensely if those commits at least had a note with the last prompt. In fact, at any time when a commit sha1 changes, really the prompt responsible for that is the last prompt issued. So it gets into this spaghetti mess where if we squash commits, it gets the prompt notes of both of those commits as well as the prompts that lead to the squash? My brain starts aching all of a sudden!\n  [2026-09-04 12:26:13 UTC] Yes, but unsure how it fits into the architecture. Perhaps the current active prompt is a separate Assistant tag?\n  [2026-09-04 12:28:20 UTC] That's literally what I would expect: that each commit receives the full prompt list. My only reason for shying away from that is storage space, that is literally it.\n  [2026-09-04 12:30:59 UTC] Yes, let's explore this.\n  [2026-09-04 12:36:14 UTC] From a UI perspective I loved the existing method of only recording the incremental prompts - reading `git log` was a pleasure. But the hard problems are really forcing my hand here. Option A. I just realized that it's kind of like what Git does - doesn't record diffs, just records the entire tree state and makes an UI around that."
    },
    {
      "hash": "a54d6e5dd1a516540015a0c2bd18270d6907691c",
      "subject": "cli: Add ANSI color formatting and pager integration to log command",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 12:43:41 UTC\n\nAssistant-Prompts:\n  [2026-09-03 22:03:57 UTC] Git seems to have only one way of showing extra information on commits outside of the DAG and that is via git notes. So we must use git notes. But what do we want to store on those git notes? \"Here is the model, harness and session (prompts) that lead to this commit being made\". I just tried to use \"git ai\" (a tool for this) and it fails on the basic premise of showing the prompts - I learned they had that and removed it because removing PII and sensitive data from transcripts was hard; and this is very true but really a matter of hygiene, because if you have those in your transcripts then your model provider also has those now. And most people don't knowingly paste PII and sensitive data into their prompts - mostly it's the agent sniffing those out. So prompt sharing isn't a dead end. \"git ai\" does its thing by installing hooks into agents, listening to git event streams, wrapping git commands to show an interpretation of the JSON. It's a lot of stuff. But I want something that hones in on the git notes: this commit has a git note with information on how it came about, which model/harness/prompts were used - there are always prompts in a session that are the navigators, that set the course, upon which the rest of the stuff is built, so even if the prompt is \"yes, do it\" combined with the patch and these navigator prompts, it should be clear what happened without even needing to store megabytes of transcripts of LLM generated text. So commit -> git note -> session date/agent/model/prompts with dates leading up to commit. When rebasing, squashing, etc - this needs some thought: squashing is combining two into one, so I guess if prompts come from one session, they are combined (generally the longer one simply wins then), if they come from two sessions, both sessions are represented in the git note, and so on.\n  [2026-09-03 22:09:25 UTC] Let's implement this.\n  [2026-09-03 22:13:23 UTC] How do I use this?\n  [2026-09-03 22:19:41 UTC] So recording of prompt notes is fully manual?\n  [2026-09-03 22:24:52 UTC] \"Human creates a commit during an active session\" -> this is iffy to me, if I make commits myself those don't belong to a random session I have open.\n  [2026-09-03 22:29:12 UTC] Run a full end-to-end test with a separate repo and a headless agy\n  [2026-09-04 08:12:18 UTC] While in bed I had a bizarre thought: what if you use a regular branch as a notes ref?\n  [2026-09-04 08:15:10 UTC] How do people make pull requests with notes?\n  [2026-09-04 08:18:03 UTC] Feels like an extra tool could be written that does something \"export notes to a file\" and maintainer then runs \"import notes from file\"?\n  [2026-09-04 08:20:00 UTC] Well, it gets funny fast because the repo is then filled with exports of these JSON files.\n  [2026-09-04 08:23:03 UTC] Honestly, I think it needs to be a combination of the two. Agents and Git tracks prompts via git notes, then agent can export that to a commit, a PR flow happens, then maintainer imports it back into notes so that tracking keeps working. If we fully rely on in-tree files, it gets very messy very fast.\n  [2026-09-04 08:28:42 UTC] And honestly, I feel like refs/notes/commits is a good default to use (due to other refs needing extra annoying steps), but may benefit from delineating the prompt note as a block from the rest of the notes content.\n  [2026-09-04 08:29:39 UTC] Curious though, if that's even needed. The syntax for the prompt note is kind of easy to parse, right?\n  [2026-09-04 08:33:04 UTC] Maybe less ambiguous key names now that we've established it travels in shared storage.\n  [2026-09-04 08:34:38 UTC] Fuck I don't like that. Perhaps use \"Assistant-\" prefix. We're not AI yet.\n  [2026-09-04 08:35:42 UTC] There is nothing to be legacy compatible with. Just use the new way, feature is 5 hours old.\n  [2026-09-04 08:37:39 UTC] Great. So how do I use it if I want to start from zero on a new repo.\n  [2026-09-04 08:39:42 UTC] I want to distribute git-prompt-note as a separate thing from Neverball with a setup script, so I can just clone it and set it up with one command.\n  [2026-09-04 08:46:01 UTC] Okay, so I don't think anyone will want this to be global unless asked. So we need to ask in the setup script. If denied, show how to enable per repo (preferably just a simple git prompt-note thing, please).\n  [2026-09-04 08:56:32 UTC] Cool. Is it installed for me?\n  [2026-09-04 08:57:22 UTC] Will the skill be enough for agents to know and when to use this? Including the export steps?\n  [2026-09-04 08:59:13 UTC] Do all of this except AGENTS.md changes.\n  [2026-09-04 09:04:52 UTC] Does Git have hooks/someting to guarantee the record will happen? Agent may forget, I think?\n  [2026-09-04 09:07:09 UTC] Yeah, do it.\n  [2026-09-04 09:10:23 UTC] Make the hooks easily uninstallable.\n    I sometimes type a prompt into the wrong session by accident when running them in parallel. Wouldn't want that prompt to land in a prompt note. Any way of marking prompts that way?\n  [2026-09-04 09:15:26 UTC] Explain how the tool decides which prompts should be on which commit? In this repo they make sense, but we're not doing my regular \"make a worktree, add commits, iterate and rewrite multiple times until clean and working, then merge\".\n  [2026-09-04 09:25:03 UTC] Are all these backed by tests?\n  [2026-09-04 12:01:50 UTC] What happens if I ask the agent to rebase and remove one of the commits?\n  [2026-09-04 12:07:10 UTC] I like to think that the \"correct\" approach is then to imagine how the prompt notes would look had the commit never been made. They would still record the dead end and the request to drop the changes.\n  [2026-09-04 12:08:33 UTC] Do a test with the rebase and tell me where the prompts land.\n  [2026-09-04 12:11:38 UTC] Okay, so just to reiterate, the prompts of commit 2 then land on commit 3 (that is now commit 2)?\n  [2026-09-04 12:12:07 UTC] That leads me to my next question: what happens if commits are reordered in a rebase?\n  [2026-09-04 12:16:41 UTC] Sometimes the agent does things like hard reset and recommit to clean up history. That sounds like it would destroy really any structure here - all prompts would land on the first commit.\n  [2026-09-04 12:23:03 UTC] I guess this could be seen as a special case? It would help immensely if those commits at least had a note with the last prompt. In fact, at any time when a commit sha1 changes, really the prompt responsible for that is the last prompt issued. So it gets into this spaghetti mess where if we squash commits, it gets the prompt notes of both of those commits as well as the prompts that lead to the squash? My brain starts aching all of a sudden!\n  [2026-09-04 12:26:13 UTC] Yes, but unsure how it fits into the architecture. Perhaps the current active prompt is a separate Assistant tag?\n  [2026-09-04 12:28:20 UTC] That's literally what I would expect: that each commit receives the full prompt list. My only reason for shying away from that is storage space, that is literally it.\n  [2026-09-04 12:30:59 UTC] Yes, let's explore this.\n  [2026-09-04 12:36:14 UTC] From a UI perspective I loved the existing method of only recording the incremental prompts - reading `git log` was a pleasure. But the hard problems are really forcing my hand here. Option A. I just realized that it's kind of like what Git does - doesn't record diffs, just records the entire tree state and makes an UI around that.\n  [2026-09-04 12:42:18 UTC] Wish git prompt-note log had colors and ran via a pager like git log does."
    },
    {
      "hash": "c9994cf46bdd45246b8aa8461dd79f4021a344ed",
      "subject": "cli: Default prompt-note log revision range to HEAD",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 12:45:31 UTC\n\nAssistant-Prompts:\n  [2026-09-03 22:03:57 UTC] Git seems to have only one way of showing extra information on commits outside of the DAG and that is via git notes. So we must use git notes. But what do we want to store on those git notes? \"Here is the model, harness and session (prompts) that lead to this commit being made\". I just tried to use \"git ai\" (a tool for this) and it fails on the basic premise of showing the prompts - I learned they had that and removed it because removing PII and sensitive data from transcripts was hard; and this is very true but really a matter of hygiene, because if you have those in your transcripts then your model provider also has those now. And most people don't knowingly paste PII and sensitive data into their prompts - mostly it's the agent sniffing those out. So prompt sharing isn't a dead end. \"git ai\" does its thing by installing hooks into agents, listening to git event streams, wrapping git commands to show an interpretation of the JSON. It's a lot of stuff. But I want something that hones in on the git notes: this commit has a git note with information on how it came about, which model/harness/prompts were used - there are always prompts in a session that are the navigators, that set the course, upon which the rest of the stuff is built, so even if the prompt is \"yes, do it\" combined with the patch and these navigator prompts, it should be clear what happened without even needing to store megabytes of transcripts of LLM generated text. So commit -> git note -> session date/agent/model/prompts with dates leading up to commit. When rebasing, squashing, etc - this needs some thought: squashing is combining two into one, so I guess if prompts come from one session, they are combined (generally the longer one simply wins then), if they come from two sessions, both sessions are represented in the git note, and so on.\n  [2026-09-03 22:09:25 UTC] Let's implement this.\n  [2026-09-03 22:13:23 UTC] How do I use this?\n  [2026-09-03 22:19:41 UTC] So recording of prompt notes is fully manual?\n  [2026-09-03 22:24:52 UTC] \"Human creates a commit during an active session\" -> this is iffy to me, if I make commits myself those don't belong to a random session I have open.\n  [2026-09-03 22:29:12 UTC] Run a full end-to-end test with a separate repo and a headless agy\n  [2026-09-04 08:12:18 UTC] While in bed I had a bizarre thought: what if you use a regular branch as a notes ref?\n  [2026-09-04 08:15:10 UTC] How do people make pull requests with notes?\n  [2026-09-04 08:18:03 UTC] Feels like an extra tool could be written that does something \"export notes to a file\" and maintainer then runs \"import notes from file\"?\n  [2026-09-04 08:20:00 UTC] Well, it gets funny fast because the repo is then filled with exports of these JSON files.\n  [2026-09-04 08:23:03 UTC] Honestly, I think it needs to be a combination of the two. Agents and Git tracks prompts via git notes, then agent can export that to a commit, a PR flow happens, then maintainer imports it back into notes so that tracking keeps working. If we fully rely on in-tree files, it gets very messy very fast.\n  [2026-09-04 08:28:42 UTC] And honestly, I feel like refs/notes/commits is a good default to use (due to other refs needing extra annoying steps), but may benefit from delineating the prompt note as a block from the rest of the notes content.\n  [2026-09-04 08:29:39 UTC] Curious though, if that's even needed. The syntax for the prompt note is kind of easy to parse, right?\n  [2026-09-04 08:33:04 UTC] Maybe less ambiguous key names now that we've established it travels in shared storage.\n  [2026-09-04 08:34:38 UTC] Fuck I don't like that. Perhaps use \"Assistant-\" prefix. We're not AI yet.\n  [2026-09-04 08:35:42 UTC] There is nothing to be legacy compatible with. Just use the new way, feature is 5 hours old.\n  [2026-09-04 08:37:39 UTC] Great. So how do I use it if I want to start from zero on a new repo.\n  [2026-09-04 08:39:42 UTC] I want to distribute git-prompt-note as a separate thing from Neverball with a setup script, so I can just clone it and set it up with one command.\n  [2026-09-04 08:46:01 UTC] Okay, so I don't think anyone will want this to be global unless asked. So we need to ask in the setup script. If denied, show how to enable per repo (preferably just a simple git prompt-note thing, please).\n  [2026-09-04 08:56:32 UTC] Cool. Is it installed for me?\n  [2026-09-04 08:57:22 UTC] Will the skill be enough for agents to know and when to use this? Including the export steps?\n  [2026-09-04 08:59:13 UTC] Do all of this except AGENTS.md changes.\n  [2026-09-04 09:04:52 UTC] Does Git have hooks/someting to guarantee the record will happen? Agent may forget, I think?\n  [2026-09-04 09:07:09 UTC] Yeah, do it.\n  [2026-09-04 09:10:23 UTC] Make the hooks easily uninstallable.\n    I sometimes type a prompt into the wrong session by accident when running them in parallel. Wouldn't want that prompt to land in a prompt note. Any way of marking prompts that way?\n  [2026-09-04 09:15:26 UTC] Explain how the tool decides which prompts should be on which commit? In this repo they make sense, but we're not doing my regular \"make a worktree, add commits, iterate and rewrite multiple times until clean and working, then merge\".\n  [2026-09-04 09:25:03 UTC] Are all these backed by tests?\n  [2026-09-04 12:01:50 UTC] What happens if I ask the agent to rebase and remove one of the commits?\n  [2026-09-04 12:07:10 UTC] I like to think that the \"correct\" approach is then to imagine how the prompt notes would look had the commit never been made. They would still record the dead end and the request to drop the changes.\n  [2026-09-04 12:08:33 UTC] Do a test with the rebase and tell me where the prompts land.\n  [2026-09-04 12:11:38 UTC] Okay, so just to reiterate, the prompts of commit 2 then land on commit 3 (that is now commit 2)?\n  [2026-09-04 12:12:07 UTC] That leads me to my next question: what happens if commits are reordered in a rebase?\n  [2026-09-04 12:16:41 UTC] Sometimes the agent does things like hard reset and recommit to clean up history. That sounds like it would destroy really any structure here - all prompts would land on the first commit.\n  [2026-09-04 12:23:03 UTC] I guess this could be seen as a special case? It would help immensely if those commits at least had a note with the last prompt. In fact, at any time when a commit sha1 changes, really the prompt responsible for that is the last prompt issued. So it gets into this spaghetti mess where if we squash commits, it gets the prompt notes of both of those commits as well as the prompts that lead to the squash? My brain starts aching all of a sudden!\n  [2026-09-04 12:26:13 UTC] Yes, but unsure how it fits into the architecture. Perhaps the current active prompt is a separate Assistant tag?\n  [2026-09-04 12:28:20 UTC] That's literally what I would expect: that each commit receives the full prompt list. My only reason for shying away from that is storage space, that is literally it.\n  [2026-09-04 12:30:59 UTC] Yes, let's explore this.\n  [2026-09-04 12:36:14 UTC] From a UI perspective I loved the existing method of only recording the incremental prompts - reading `git log` was a pleasure. But the hard problems are really forcing my hand here. Option A. I just realized that it's kind of like what Git does - doesn't record diffs, just records the entire tree state and makes an UI around that.\n  [2026-09-04 12:42:18 UTC] Wish git prompt-note log had colors and ran via a pager like git log does.\n  [2026-09-04 12:44:56 UTC] What does git prompt-note log really show by default? I only see one commit there."
    },
    {
      "hash": "30969190a19f1eb4e6e3684b5802e17fe44c2dc1",
      "subject": "notes: Record prompts in reverse-chronological order with causal prompt at top",
      "note": "Assistant-Session: 9674eda6-390f-4b1d-9910-72bec1843401\nAssistant-Harness: Antigravity CLI 1.1.25\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 12:53:36 UTC\n\nAssistant-Prompts:\n  [2026-09-04 12:50:57 UTC] I would be inclined to say to reverse the recorded list, so the causal prompt is already at the top.\n  [2026-09-04 12:47:55 UTC] That is kind of cool. It does have the moment of - when I look at the full prompt list for a commit, much of it I want to skip because it makes no sense. But the last prompt (the active prompt) is perfect, literally explains how we got to that commit.\n  [2026-09-04 12:44:56 UTC] What does git prompt-note log really show by default? I only see one commit there.\n  [2026-09-04 12:42:18 UTC] Wish git prompt-note log had colors and ran via a pager like git log does.\n  [2026-09-04 12:36:14 UTC] From a UI perspective I loved the existing method of only recording the incremental prompts - reading `git log` was a pleasure. But the hard problems are really forcing my hand here. Option A. I just realized that it's kind of like what Git does - doesn't record diffs, just records the entire tree state and makes an UI around that.\n  [2026-09-04 12:30:59 UTC] Yes, let's explore this.\n  [2026-09-04 12:28:20 UTC] That's literally what I would expect: that each commit receives the full prompt list. My only reason for shying away from that is storage space, that is literally it.\n  [2026-09-04 12:26:13 UTC] Yes, but unsure how it fits into the architecture. Perhaps the current active prompt is a separate Assistant tag?\n  [2026-09-04 12:23:03 UTC] I guess this could be seen as a special case? It would help immensely if those commits at least had a note with the last prompt. In fact, at any time when a commit sha1 changes, really the prompt responsible for that is the last prompt issued. So it gets into this spaghetti mess where if we squash commits, it gets the prompt notes of both of those commits as well as the prompts that lead to the squash? My brain starts aching all of a sudden!\n  [2026-09-04 12:16:41 UTC] Sometimes the agent does things like hard reset and recommit to clean up history. That sounds like it would destroy really any structure here - all prompts would land on the first commit.\n  [2026-09-04 12:12:07 UTC] That leads me to my next question: what happens if commits are reordered in a rebase?\n  [2026-09-04 12:11:38 UTC] Okay, so just to reiterate, the prompts of commit 2 then land on commit 3 (that is now commit 2)?\n  [2026-09-04 12:08:33 UTC] Do a test with the rebase and tell me where the prompts land.\n  [2026-09-04 12:07:10 UTC] I like to think that the \"correct\" approach is then to imagine how the prompt notes would look had the commit never been made. They would still record the dead end and the request to drop the changes.\n  [2026-09-04 12:01:50 UTC] What happens if I ask the agent to rebase and remove one of the commits?\n  [2026-09-04 09:25:03 UTC] Are all these backed by tests?\n  [2026-09-04 09:15:26 UTC] Explain how the tool decides which prompts should be on which commit? In this repo they make sense, but we're not doing my regular \"make a worktree, add commits, iterate and rewrite multiple times until clean and working, then merge\".\n  [2026-09-04 09:10:23 UTC] Make the hooks easily uninstallable.\n    I sometimes type a prompt into the wrong session by accident when running them in parallel. Wouldn't want that prompt to land in a prompt note. Any way of marking prompts that way?\n  [2026-09-04 09:07:09 UTC] Yeah, do it.\n  [2026-09-04 09:04:52 UTC] Does Git have hooks/someting to guarantee the record will happen? Agent may forget, I think?\n  [2026-09-04 08:59:13 UTC] Do all of this except AGENTS.md changes.\n  [2026-09-04 08:57:22 UTC] Will the skill be enough for agents to know and when to use this? Including the export steps?\n  [2026-09-04 08:56:32 UTC] Cool. Is it installed for me?\n  [2026-09-04 08:46:01 UTC] Okay, so I don't think anyone will want this to be global unless asked. So we need to ask in the setup script. If denied, show how to enable per repo (preferably just a simple git prompt-note thing, please).\n  [2026-09-04 08:39:42 UTC] I want to distribute git-prompt-note as a separate thing from Neverball with a setup script, so I can just clone it and set it up with one command.\n  [2026-09-04 08:37:39 UTC] Great. So how do I use it if I want to start from zero on a new repo.\n  [2026-09-04 08:35:42 UTC] There is nothing to be legacy compatible with. Just use the new way, feature is 5 hours old.\n  [2026-09-04 08:34:38 UTC] Fuck I don't like that. Perhaps use \"Assistant-\" prefix. We're not AI yet.\n  [2026-09-04 08:33:04 UTC] Maybe less ambiguous key names now that we've established it travels in shared storage.\n  [2026-09-04 08:29:39 UTC] Curious though, if that's even needed. The syntax for the prompt note is kind of easy to parse, right?\n  [2026-09-04 08:28:42 UTC] And honestly, I feel like refs/notes/commits is a good default to use (due to other refs needing extra annoying steps), but may benefit from delineating the prompt note as a block from the rest of the notes content.\n  [2026-09-04 08:23:03 UTC] Honestly, I think it needs to be a combination of the two. Agents and Git tracks prompts via git notes, then agent can export that to a commit, a PR flow happens, then maintainer imports it back into notes so that tracking keeps working. If we fully rely on in-tree files, it gets very messy very fast.\n  [2026-09-04 08:20:00 UTC] Well, it gets funny fast because the repo is then filled with exports of these JSON files.\n  [2026-09-04 08:18:03 UTC] Feels like an extra tool could be written that does something \"export notes to a file\" and maintainer then runs \"import notes from file\"?\n  [2026-09-04 08:15:10 UTC] How do people make pull requests with notes?\n  [2026-09-04 08:12:18 UTC] While in bed I had a bizarre thought: what if you use a regular branch as a notes ref?\n  [2026-09-03 22:29:12 UTC] Run a full end-to-end test with a separate repo and a headless agy\n  [2026-09-03 22:24:52 UTC] \"Human creates a commit during an active session\" -> this is iffy to me, if I make commits myself those don't belong to a random session I have open.\n  [2026-09-03 22:19:41 UTC] So recording of prompt notes is fully manual?\n  [2026-09-03 22:13:23 UTC] How do I use this?\n  [2026-09-03 22:09:25 UTC] Let's implement this.\n  [2026-09-03 22:03:57 UTC] Git seems to have only one way of showing extra information on commits outside of the DAG and that is via git notes. So we must use git notes. But what do we want to store on those git notes? \"Here is the model, harness and session (prompts) that lead to this commit being made\". I just tried to use \"git ai\" (a tool for this) and it fails on the basic premise of showing the prompts - I learned they had that and removed it because removing PII and sensitive data from transcripts was hard; and this is very true but really a matter of hygiene, because if you have those in your transcripts then your model provider also has those now. And most people don't knowingly paste PII and sensitive data into their prompts - mostly it's the agent sniffing those out. So prompt sharing isn't a dead end. \"git ai\" does its thing by installing hooks into agents, listening to git event streams, wrapping git commands to show an interpretation of the JSON. It's a lot of stuff. But I want something that hones in on the git notes: this commit has a git note with information on how it came about, which model/harness/prompts were used - there are always prompts in a session that are the navigators, that set the course, upon which the rest of the stuff is built, so even if the prompt is \"yes, do it\" combined with the patch and these navigator prompts, it should be clear what happened without even needing to store megabytes of transcripts of LLM generated text. So commit -> git note -> session date/agent/model/prompts with dates leading up to commit. When rebasing, squashing, etc - this needs some thought: squashing is combining two into one, so I guess if prompts come from one session, they are combined (generally the longer one simply wins then), if they come from two sessions, both sessions are represented in the git note, and so on."
    },
    {
      "hash": "ca0d07f11e52aa6a0e40c9b26a74e061b8c826d1",
      "subject": "docs: Restructure documentation and rename skill to git-prompt-note",
      "note": "Assistant-Session: 6f5dcc91-5281-4d36-bf55-f3da5c1ab997\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 16:09:59 UTC\n\nAssistant-Prompts:\n  [2026-09-04 16:09:43 UTC] Commit all this.\n  [2026-09-04 16:02:15 UTC] In the readme, reorganize this section \"Accidental Prompts & Parallel Sessions\" into a normal documentation section that explains prompt prefixes\n  [2026-09-04 15:58:43 UTC] \"git push origin \"refs/notes/*\"\" -> this must never ever be done, eradicate all examples of this. Our stance is to use import/export to share prompt notes\n  [2026-09-04 15:56:22 UTC] Didn't update  the name of the skill\n  [2026-09-04 15:54:15 UTC] I feel like, as a skill, it should teach the agent to answer questions about the tool and use the tool for tasks when the user requests. So just fully rewrite it to that goal.\n  [2026-09-04 15:52:13 UTC] Any point to the SKILL.md? First off, it's dated. Second, seems like its only purpose might be to be informative to the agent, not to instruct it to use anything from this.\n  [2026-09-04 15:47:21 UTC] Follow these examples, don't copy them\n  [2026-09-04 15:46:16 UTC] Here's an example of a good README (a couple of them): https://raw.githubusercontent.com/emscripten-core/emscripten/refs/heads/main/README.md https://raw.githubusercontent.com/TheLartians/substitute/refs/heads/main/README.md\n  [2026-09-04 15:32:31 UTC] Can we stop running tests on README.md edits.\n  [2026-09-04 15:27:58 UTC] Very important: remove all marketing clutter. \"AI\" isn't a thing. A tool doing what it does is sufficient, no need to say what it doesn't do - remove the \"without cluttering\" etc sections.\n  [2026-09-04 15:24:55 UTC] Have a technical writer subagent edit the README.md, update it for factual accuracy and groundedness, remove duplicate sections, trim the document down, put the important things first (what is this and how to use it is what people generaly want to read first rather than the full list of flags that the setup command supports)"
    },
    {
      "hash": "8bba2f9db4e2f35bc0785ff14d51b661b97c5a22",
      "subject": "chore: Remove .agents directory",
      "note": "Assistant-Session: 6f5dcc91-5281-4d36-bf55-f3da5c1ab997\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 21:01:06 UTC\n\nAssistant-Prompts:\n  [2026-09-04 16:10:18 UTC] Remove .agents folder, don't think I need it.\n  [2026-09-04 16:09:43 UTC] Commit all this.\n  [2026-09-04 16:02:15 UTC] In the readme, reorganize this section \"Accidental Prompts & Parallel Sessions\" into a normal documentation section that explains prompt prefixes\n  [2026-09-04 15:58:43 UTC] \"git push origin \"refs/notes/*\"\" -> this must never ever be done, eradicate all examples of this. Our stance is to use import/export to share prompt notes\n  [2026-09-04 15:56:22 UTC] Didn't update  the name of the skill\n  [2026-09-04 15:54:15 UTC] I feel like, as a skill, it should teach the agent to answer questions about the tool and use the tool for tasks when the user requests. So just fully rewrite it to that goal.\n  [2026-09-04 15:52:13 UTC] Any point to the SKILL.md? First off, it's dated. Second, seems like its only purpose might be to be informative to the agent, not to instruct it to use anything from this.\n  [2026-09-04 15:47:21 UTC] Follow these examples, don't copy them\n  [2026-09-04 15:46:16 UTC] Here's an example of a good README (a couple of them): https://raw.githubusercontent.com/emscripten-core/emscripten/refs/heads/main/README.md https://raw.githubusercontent.com/TheLartians/substitute/refs/heads/main/README.md\n  [2026-09-04 15:37:20 UTC] I don't really understand how you're so bad at writing readmes, I would have figured the dataset for that is massive.\n  [2026-09-04 15:32:31 UTC] Can we stop running tests on README.md edits.\n  [2026-09-04 15:30:59 UTC] I reverted all the changes made after my initial prompt. The subagent removed all my content that I typed in manually. I asked to edit and trim down, not to revert to the previous version.\n  [2026-09-04 15:29:35 UTC] I really hate that the subagent removed all my manually entered text for some reason.\n  [2026-09-04 15:28:47 UTC] Remove the info about non-interactive setups, because I don't personally care.\n  [2026-09-04 15:27:58 UTC] Very important: remove all marketing clutter. \"AI\" isn't a thing. A tool doing what it does is sufficient, no need to say what it doesn't do - remove the \"without cluttering\" etc sections.\n  [2026-09-04 15:24:55 UTC] Have a technical writer subagent edit the README.md, update it for factual accuracy and groundedness, remove duplicate sections, trim the document down, put the important things first (what is this and how to use it is what people generaly want to read first rather than the full list of flags that the setup command supports)"
    },
    {
      "hash": "e0a44d9d3fb549223b1b2d4a67bd78b71adc5108",
      "subject": "refactor: rename tool to git-prompt-log (\"git prompt-log\")",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 21:20:30 UTC\n\nAssistant-Prompts:\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "24a5f494bd1437987567ae427b38c34347691134",
      "subject": "feat(cli): default install and init to no skill and add --skill flag",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 21:38:31 UTC\n\nAssistant-Prompts:\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "1b0c35c3184867a869758ffd456fe0077f5442b5",
      "subject": "feat(hook): add automatic migration of legacy hooks on install",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 21:38:43 UTC\n\nAssistant-Prompts:\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "85025c066a0eb09767bcf69727438ce14532f894",
      "subject": "feat(exclude): support persistent always-skip patterns via prompt-log.exclude and retroactive note pruning",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 21:46:33 UTC\n\nAssistant-Prompts:\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "b5d2e25672c60d8b1ad4b53fbf060ca53f8508ea",
      "subject": "feat(session): add session-specific prompt exclusions and in-chat targeted retraction",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 21:49:37 UTC\n\nAssistant-Prompts:\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "02efc10f16eda992102b30f9b7f286dd449ccd50",
      "subject": "feat(adapters): implement pluggable ingestion adapter scaffolding (antigravity, claude, aider, direct)",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:05:09 UTC\n\nAssistant-Prompts:\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "8c1280a04b8cfb1b4e6a0da05a5feff8abcae684",
      "subject": "refactor(adapters): drop Aider adapter",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:10:07 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "ca8208715def7c8aee076cfcd93bede9b797d731",
      "subject": "refactor(adapters): rename direct adapter to manual",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:12:19 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:10:37 UTC] Rename direct adapter to manual everywhere.\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "05d84ac95e647970d161420e0ec1b131fb911d27",
      "subject": "fix(adapters): detect active agy session from process tree and remove dot from session exclusion file",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:16:59 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:13:41 UTC] I just ran `git prompt-log adapters` from inside agy and it still shows all adapters as inactive and active harness as none.\n  [2026-09-04 22:12:27 UTC] Remove dot from the exclusion file stored in a session dir to facilitate discovery.\n  [2026-09-04 22:10:37 UTC] Rename direct adapter to manual everywhere.\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "eb2cdb6df917234ccd843ccf25174b026e81be55",
      "subject": "feat(harness): support explicit harness configuration via git config and harness command",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:23:11 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:20:02 UTC] Walking the process tree and looking at open file descriptors is kind of insane. I would rather the user explicitly told us in some very simple way which harness they are using.\n  [2026-09-04 22:13:41 UTC] I just ran `git prompt-log adapters` from inside agy and it still shows all adapters as inactive and active harness as none.\n  [2026-09-04 22:12:27 UTC] Remove dot from the exclusion file stored in a session dir to facilitate discovery.\n  [2026-09-04 22:10:37 UTC] Rename direct adapter to manual everywhere.\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "1b3e8383138d02b54a6222b78e558c70e4aea720",
      "subject": "refactor(config): rename prompt-log.adapter to prompt-log.harness",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:26:29 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:24:23 UTC] Let's use consistent terminology: rename prompt-log.adapter to prompt-log.harness, likewise for the env var.\n  [2026-09-04 22:20:02 UTC] Walking the process tree and looking at open file descriptors is kind of insane. I would rather the user explicitly told us in some very simple way which harness they are using.\n  [2026-09-04 22:13:41 UTC] I just ran `git prompt-log adapters` from inside agy and it still shows all adapters as inactive and active harness as none.\n  [2026-09-04 22:12:27 UTC] Remove dot from the exclusion file stored in a session dir to facilitate discovery.\n  [2026-09-04 22:10:37 UTC] Rename direct adapter to manual everywhere.\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "4370f65717465b25972d108d8a82bcc4c4d8f520",
      "subject": "refactor(config): remove legacy prompt-log.adapter fallback",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:29:36 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:27:50 UTC] \"with automatic fallback to prompt-log.adapter\" -> remove the fallback, this has never been deployed\n  [2026-09-04 22:24:23 UTC] Let's use consistent terminology: rename prompt-log.adapter to prompt-log.harness, likewise for the env var.\n  [2026-09-04 22:20:02 UTC] Walking the process tree and looking at open file descriptors is kind of insane. I would rather the user explicitly told us in some very simple way which harness they are using.\n  [2026-09-04 22:13:41 UTC] I just ran `git prompt-log adapters` from inside agy and it still shows all adapters as inactive and active harness as none.\n  [2026-09-04 22:12:27 UTC] Remove dot from the exclusion file stored in a session dir to facilitate discovery.\n  [2026-09-04 22:10:37 UTC] Rename direct adapter to manual everywhere.\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "e5af4fc597e534cb36fc707af46ae153f37a6afc",
      "subject": "refactor(cli): consolidate adapters subcommand into harness subcommand",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:31:35 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:29:40 UTC] adapters/harness commands serve basically the same purpose - remove adapters subcommand and integrate it into the harness subcommand\n  [2026-09-04 22:27:50 UTC] \"with automatic fallback to prompt-log.adapter\" -> remove the fallback, this has never been deployed\n  [2026-09-04 22:24:23 UTC] Let's use consistent terminology: rename prompt-log.adapter to prompt-log.harness, likewise for the env var.\n  [2026-09-04 22:20:02 UTC] Walking the process tree and looking at open file descriptors is kind of insane. I would rather the user explicitly told us in some very simple way which harness they are using.\n  [2026-09-04 22:13:41 UTC] I just ran `git prompt-log adapters` from inside agy and it still shows all adapters as inactive and active harness as none.\n  [2026-09-04 22:12:27 UTC] Remove dot from the exclusion file stored in a session dir to facilitate discovery.\n  [2026-09-04 22:10:37 UTC] Rename direct adapter to manual everywhere.\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "1e21a36c92efe8ee4a293675719f2d96487a1d24",
      "subject": "refactor(cli): drop install subcommand in favor of init",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:37:56 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:34:49 UTC] I got confused trying to figure out the difference between init and install subcommands.\n  [2026-09-04 22:29:40 UTC] adapters/harness commands serve basically the same purpose - remove adapters subcommand and integrate it into the harness subcommand\n  [2026-09-04 22:27:50 UTC] \"with automatic fallback to prompt-log.adapter\" -> remove the fallback, this has never been deployed\n  [2026-09-04 22:24:23 UTC] Let's use consistent terminology: rename prompt-log.adapter to prompt-log.harness, likewise for the env var.\n  [2026-09-04 22:20:02 UTC] Walking the process tree and looking at open file descriptors is kind of insane. I would rather the user explicitly told us in some very simple way which harness they are using.\n  [2026-09-04 22:13:41 UTC] I just ran `git prompt-log adapters` from inside agy and it still shows all adapters as inactive and active harness as none.\n  [2026-09-04 22:12:27 UTC] Remove dot from the exclusion file stored in a session dir to facilitate discovery.\n  [2026-09-04 22:10:37 UTC] Rename direct adapter to manual everywhere.\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "7ebb492219a67ad72817b52c38a9e55ca5824683",
      "subject": "docs: reframe ingestion adapters as supported agents",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:41:36 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:38:34 UTC] \"Ingestion Adapters & Manual Recording\" -> humans reading a README will have no idea what this is, edit to say \"Supported Agents\" and generally remove any mention of pluggable adapters (nobody can plug them, it's internal architecture)\n  [2026-09-04 22:34:49 UTC] I got confused trying to figure out the difference between init and install subcommands.\n  [2026-09-04 22:29:40 UTC] adapters/harness commands serve basically the same purpose - remove adapters subcommand and integrate it into the harness subcommand\n  [2026-09-04 22:27:50 UTC] \"with automatic fallback to prompt-log.adapter\" -> remove the fallback, this has never been deployed\n  [2026-09-04 22:24:23 UTC] Let's use consistent terminology: rename prompt-log.adapter to prompt-log.harness, likewise for the env var.\n  [2026-09-04 22:20:02 UTC] Walking the process tree and looking at open file descriptors is kind of insane. I would rather the user explicitly told us in some very simple way which harness they are using.\n  [2026-09-04 22:13:41 UTC] I just ran `git prompt-log adapters` from inside agy and it still shows all adapters as inactive and active harness as none.\n  [2026-09-04 22:12:27 UTC] Remove dot from the exclusion file stored in a session dir to facilitate discovery.\n  [2026-09-04 22:10:37 UTC] Rename direct adapter to manual everywhere.\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    },
    {
      "hash": "c7863f1bd586b90bc3915134b5c1df18e752fe9a",
      "subject": "refactor(cli): standardize public interface and docs on harness",
      "note": "Assistant-Session: 264ec0fe-9040-412b-abe3-06d2c06305c3\nAssistant-Harness: Antigravity CLI 1.1.26\nAssistant-Model: Gemini 3.8 Flash (High)\nAssistant-Recorded: 2026-09-04 22:45:32 UTC\n\nAssistant-Prompts:\n  [2026-09-04 22:43:14 UTC] Do not retain --adapter as an alias; again - we've never deployed. I'm now confused, are we using --agent and harness both now? For consistency, stick to one or the other in public facing texts.\n  [2026-09-04 22:38:34 UTC] \"Ingestion Adapters & Manual Recording\" -> humans reading a README will have no idea what this is, edit to say \"Supported Agents\" and generally remove any mention of pluggable adapters (nobody can plug them, it's internal architecture)\n  [2026-09-04 22:34:49 UTC] I got confused trying to figure out the difference between init and install subcommands.\n  [2026-09-04 22:29:40 UTC] adapters/harness commands serve basically the same purpose - remove adapters subcommand and integrate it into the harness subcommand\n  [2026-09-04 22:27:50 UTC] \"with automatic fallback to prompt-log.adapter\" -> remove the fallback, this has never been deployed\n  [2026-09-04 22:24:23 UTC] Let's use consistent terminology: rename prompt-log.adapter to prompt-log.harness, likewise for the env var.\n  [2026-09-04 22:20:02 UTC] Walking the process tree and looking at open file descriptors is kind of insane. I would rather the user explicitly told us in some very simple way which harness they are using.\n  [2026-09-04 22:13:41 UTC] I just ran `git prompt-log adapters` from inside agy and it still shows all adapters as inactive and active harness as none.\n  [2026-09-04 22:12:27 UTC] Remove dot from the exclusion file stored in a session dir to facilitate discovery.\n  [2026-09-04 22:10:37 UTC] Rename direct adapter to manual everywhere.\n  [2026-09-04 22:08:37 UTC] Drop Aider.\n  [2026-09-04 22:07:12 UTC] I have never used Aider and unsure what the direct prompt recording is for. Reasons to keep?\n  [2026-09-04 21:57:00 UTC] Build the ingestion adapter scaffolding.\n  [2026-09-04 21:55:13 UTC] Would you say the tool as a whole is very Antigravity specific?\n  [2026-09-04 21:53:42 UTC] How doe the command know the active session when run outside an agent process?\n  [2026-09-04 21:51:07 UTC] Where are these choices saved?\n  [2026-09-04 21:43:02 UTC] Hmm, so my options are: 1) remember to add a prompt prefix to following prompots, 2) preemptively filter it out with an exclude regex, 3) rewrite notes after the fact. There is no option that matches what I want, which is to mark a specific prompt from a specific session from not being included - other than retroactively editing the raw transcript to add a prefix.\n  [2026-09-04 21:32:05 UTC] Possible to mark a prompt as always-skip if I missed the chance to add a prompt prefix? I'd like to always skip the \"Commit\" prompt\n  [2026-09-04 21:30:18 UTC] How did commit 24a5f494bd1437987567ae427b38c34347691134 end up with no prompt notes?\n  [2026-09-04 21:24:18 UTC] For the install subcommand, default to no skill and install skill with --skill\n  [2026-09-04 21:06:25 UTC] Rename the entire tool to git-prompt-log / \"git prompt-log\""
    }
  ]
}
-->
