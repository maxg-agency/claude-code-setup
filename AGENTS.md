# Instructions for an AI agent installing this setup

You were asked to install, follow or update this setup for your user. This file is written for you. Read it fully before running anything. Human-facing explanations are in `README.md` and `HOW-IT-WORKS.md`.

## What gets installed

| From | To | What |
|---|---|---|
| `skills/feature-dev/` | `~/.claude/skills/feature-dev/` | The feature pipeline skill. |
| `agents/*.md` | `~/.claude/agents/` | Three helper agents the skill calls: `feature-explorer`, `feature-architect`, `feature-reviewer`. |
| `claude/CLAUDE.md` | appended to `~/.claude/CLAUDE.md` | A short rules block between `<!-- claude-code-setup:start -->` and `<!-- claude-code-setup:end -->`: deployment safety, and when to use `/feature-dev`. |

No plugins, no settings changes, no model switching. Everything else in the repository (`docs/`, `memory/`, `examples/`) is reading material.

## Before you install: ask the user two things

Ask in one message:

1. **Global or one project.** The rules block applies to every project on this machine and makes `/feature-dev` the default for anything larger than a micro edit. Global, or only in one project's `CLAUDE.md`? If one project, skip the rules step of the installer and append `claude/CLAUDE.md` to that project's `CLAUDE.md` yourself.
2. **Existing files.** If `~/.claude/skills/feature-dev` or an agent with the same name already exists and was not installed by this script, it belongs to the user. Ask before replacing it. The installer never replaces it on its own.

## Install

From the cloned repository root:

```sh
sh install.sh
```

The script never overwrites. Report every `skip` line to the user. Then ask the user to restart Claude Code; skills, agents and rules load at session start.

## Verify

- `~/.claude/skills/feature-dev/SKILL.md` exists and contains "Phase 0. Scale".
- `~/.claude/agents/` contains the three `feature-*.md` files.
- `~/.claude/CLAUDE.md` contains the start marker exactly once and the end marker exactly once.
- In a new session the skill list shows `feature-dev`, and the agent list shows the three helpers.

## Update

```sh
git pull
sh install.sh --update
```

Replaces only what this script installed: the skill (the previous copy is kept as `~/.claude/skills/.feature-dev.bak-<timestamp>`), the three agents, and the rules block between the markers (`CLAUDE.md` is backed up first). Anything the user wrote outside the markers stays.

If the user had edited the installed skill, their edits are in the `.bak-` copy. Tell them and offer to carry the edits over.

## Uninstall

```sh
sh install.sh --uninstall
```

## What not to do

- **Do not copy `memory/` into the user's memory.** Those files are the author's own corrections, shown as an example of the format. They would teach the user's agent someone else's preferences.
- Do not install anything from `docs/extra-skills.md` without the user's go-ahead; those skills come from other authors.
- Do not edit `~/.claude/settings.json`. Nothing here needs it.

## If the user asks why it works this way

Answer from these facts; they are the author's reasons.

- **Why a full plan and full context before building.** Long chats fill the context window. Each turn then re-sends the whole history, which costs more tokens, and the model's quality drops: it loses early decisions, confuses file versions, follows recent noise over the plan. The author therefore often finishes planning, opens a new chat and runs `/feature-dev resume <path>`. `PLAN.md` and `blueprints/` are written so the new chat needs nothing from the old one.
- **Why not automatic compaction.** A compaction summary drops exact paths, the user's verbatim answers and the reasons options were rejected. The plan file keeps them on purpose.
- **Why fewer agents on small tasks.** Helper agents are the main token cost: each re-reads the code and writes a long report. On medium features, extra architects mostly added small borrowings, not different designs. The full set still runs on large tasks.
- **If quality matters more than tokens.** Say "full run" to force the large path, or install Anthropic's original `feature-dev` plugin and use `/feature-dev:feature-dev`.

## How the user works afterwards

- `/feature-dev <request>` in any project. The skill announces the task size in one line and continues.
- Small tasks are planned in a few lines and built right away. Medium and large ones show the approach and wait for the user's pick before building.
- `/feature-dev resume <path to PLAN.md>`, or "continue", picks a feature up in a later session.
- Plans go to `<project>/.claude/feature-dev/<slug>/`. Suggest adding `.claude/feature-dev/` to the project's `.gitignore` if the user does not want plans in git.
