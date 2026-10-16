# Instructions for an AI agent installing this setup

You were asked to install, follow or update this setup for your user. This file is written for you. Read it fully before running anything. Human-facing explanations are in `README.md` and `HOW-IT-WORKS.md`.

## What gets installed

| From | To | What |
|---|---|---|
| `skills/feature-dev/` + `examples/` | `~/.claude/skills/feature-dev/` | The feature pipeline skill, with the state file templates (feature plan, state file, master plan, decisions) in its `examples/`. |
| `agents/*.md` | `~/.claude/agents/` | Three helper agents the skill calls: `feature-explorer`, `feature-architect`, `feature-reviewer`. |
| `claude/CLAUDE.md` | appended to `~/.claude/CLAUDE.md` | A short rules block between `<!-- claude-code-setup:start -->` and `<!-- claude-code-setup:end -->`: deployment safety, when to use `/feature-dev`, how every chat ends with a checkpoint, which model plans and which builds. |
| (generated) | appended to `~/.claude/CLAUDE.md` | A models block between `<!-- claude-code-setup:models:start -->` and `<!-- claude-code-setup:models:end -->`: two lines, `Planning model:` and `Building model:`. Written once; `--update` never replaces it. |
| `scripts/context-hook.py` | `~/.claude/scripts/claude-code-setup-context-hook.py` + one `UserPromptSubmit` entry in `~/.claude/settings.json` | On every user message prints `Context: Nk / <window> (P%)` into the model's context (about 15 tokens), so checkpoints can report it. |

No plugins. One settings change: the `UserPromptSubmit` entry, merged in with python3 without touching other keys or hooks (`settings.json` is backed up first; if it is not valid JSON, it is left alone and the installer prints the entry to add by hand). Models are never switched by the setup: the agent stops and the user runs `/model`. `scripts/statusline.py` is not installed. Everything else in the repository (`docs/`, `memory/`) is reading material.

## Before you install: ask the user three things

Ask in one message:

1. **Global or one project.** The rules block applies to every project on this machine and makes `/feature-dev` the default for anything larger than a micro edit. Global, or only in one project's `CLAUDE.md`? For one project, pass `CLAUDE_RULES_FILE=<project>/CLAUDE.md`: the rules block and the models block go there instead. The skill, the agents and the hook are still installed into `~/.claude`; the hook only adds the `Context:` line.
2. **Existing files.** If `~/.claude/skills/feature-dev` or an agent with the same name already exists and was not installed by this script, it belongs to the user. Ask before replacing it. The installer never replaces it on its own.
3. **Models.** Which model plans (understanding code, questions, choosing an approach) and which builds (code by a ready plan)? Use the names they type after `/model`, for example `opus` and `sonnet`. One model for everything is fine: give the same name twice, and the agent never stops for a switch. Also ask whether their context window is 1M; if yes, pass `CLAUDE_CONTEXT_WINDOW=1000000`.

Check that `python3` is on the PATH. Without it everything installs except the context hook, and checkpoints say `Context: unknown`.

## Install

Clone into a place that stays, so updates can `git pull` there:

```sh
git clone https://github.com/maxg-agency/claude-code-setup ~/claude-code-setup
cd ~/claude-code-setup
CLAUDE_PLANNING_MODEL=<planning> CLAUDE_BUILDING_MODEL=<building> sh install.sh
```

Add `CLAUDE_CONTEXT_WINDOW=1000000` in front if the user has a 1M window, and `CLAUDE_RULES_FILE=<project>/CLAUDE.md` for a one-project install. The script never overwrites. Report every `skip` line to the user. Then ask the user to restart Claude Code; skills, agents and rules load at session start.

## Verify

- `~/.claude/skills/feature-dev/SKILL.md` exists and contains "Phase 0. Scale".
- `~/.claude/agents/` contains the three `feature-*.md` files.
- `~/.claude/CLAUDE.md` (or the project's file) contains each of the four marker lines exactly once as a whole line (`grep -cxF '<!-- claude-code-setup:start -->' ~/.claude/CLAUDE.md` prints 1), and the models block has the two names (not `<set me>`, unless the user skipped question 3).
- `~/.claude/skills/feature-dev/examples/` holds the templates.
- `~/.claude/settings.json` mentions `claude-code-setup-context-hook.py` exactly once, and `echo '{}' | python3 ~/.claude/scripts/claude-code-setup-context-hook.py` exits 0 with no output.
- In a new session the skill list shows `feature-dev`, the agent list shows the three helpers, and from the second message on the context carries a `Context:` line.

## Update

From the same clone (re-clone if it is gone), with the same `CLAUDE_RULES_FILE` if one was used:

```sh
cd ~/claude-code-setup
git pull
sh install.sh --update
```

Replaces only what this script installed: the skill (the previous copy is kept as `~/.claude/skills/.feature-dev.bak-<timestamp>`), the three agents, the rules block between the markers (`CLAUDE.md` is backed up first) and the hook script. The models block and anything the user wrote outside the markers stay. An install from before the hook existed gets the models block and the hook added.

If the user had edited the installed skill, their edits are in the `.bak-` copy. Tell them and offer to carry the edits over.

## Uninstall

```sh
sh install.sh --uninstall
```

With `CLAUDE_RULES_FILE` if one was used at install.

## What not to do

- **Do not copy `memory/` into the user's memory.** Those files are the author's own corrections, shown as an example of the format. They would teach the user's agent someone else's preferences.
- Do not install anything from `docs/extra-skills.md` without the user's go-ahead; those skills come from other authors.
- Do not edit `~/.claude/settings.json` beyond what the installer does. If it refused because the file is not valid JSON, show the user the printed entry; do not repair their file without asking.

## If the user asks why it works this way

Answer from these facts; they are the author's reasons.

- **Why a full plan and full context before building.** Long chats fill the context window. Each turn then re-sends the whole history, which costs more tokens, and the model's quality drops: it loses early decisions, confuses file versions, follows recent noise over the plan. The author therefore often finishes planning, opens a new chat and runs `/feature-dev resume <path>`. `PLAN.md` and `blueprints/` are written so the new chat needs nothing from the old one.
- **Why not automatic compaction.** A compaction summary drops exact paths, the user's verbatim answers and the reasons options were rejected. The plan file keeps them on purpose.
- **Why fewer agents on small tasks.** Helper agents are the main token cost: each re-reads the code and writes a long report. On medium features, extra architects mostly added small borrowings, not different designs. The full set still runs on large tasks.
- **If quality matters more than tokens.** Say "full run" to force the large path, or install Anthropic's original `feature-dev` plugin and use `/feature-dev:feature-dev`.

## How the user works afterwards

- `/feature-dev <request>` in any project. The skill announces the task size in one line and continues.
- Small tasks are planned in a few lines and built right away, on whatever model the chat is on. Medium and large ones show the approach, wait for the user's pick, and on the planning model stop with "I have reached the point where we need to switch to <model>…". The user runs `/model <model>` and says "continue", or opens a new chat with `/feature-dev resume <path>`. Switching is manual by design.
- Every chat that finishes or pauses a unit of work ends with a checkpoint: the state file written, the status rolled up to the project's `MASTER-PLAN.md`, a proposed commit message, and the `Context:` number as the last line.
- `/feature-dev resume <path to PLAN.md>`, or "continue", picks a feature up in a later session.
- Plans go to `<project>/.claude/feature-dev/<slug>/`. Suggest adding `.claude/feature-dev/` to the project's `.gitignore` if the user does not want plans in git.
