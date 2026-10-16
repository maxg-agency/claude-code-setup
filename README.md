# Claude Code Setup

A working setup for building products with Claude Code as a daily collaborator. It is the configuration I use to ship websites, bots and internal tools solo, with the model doing most of the typing and me doing the deciding.

The core is one skill, `/feature-dev`, that takes a request from "I want X" to working, reviewed code, and spends helper agents only where the task needs them. Around it: a short rules file that makes every chat end with a checkpoint, a model split (plan on a strong model, build on a cheaper one, with a fixed stop between them), a hook that tells the model how full its context is, three helper agents, and documents on how I test in a browser, keep memory and run the model through a subscription.

## What `/feature-dev` does

You describe what you want built. The skill takes it to working, reviewed code in seven phases, in one session:

0. **Size the task.** In one short turn it looks at the request and a few files and decides: small (S), medium (M) or large (L). It says so in one line and goes on. You can override with one word.
1. **Discovery.** Restates the task, or asks what problem it solves if that is unclear. Starts a `PLAN.md` for the feature.
2. **Exploration.** Reads the code that the change will touch. On large tasks, explorer agents trace the area in parallel and return the files that matter.
3. **Questions.** Asks only what you alone can answer: edge cases, scope, priorities, taste. Decides the rest itself and notes the decision.
4. **Architecture.** Writes the approach: exact files, numbered steps, how to verify, what not to touch. On medium and large tasks, architect agents propose options and you pick one.
5. **Build.** Implements by the plan, runs the project's checks, logs any deviation.
6. **Review.** Reviewer agents check the diff for bugs, simplicity and project conventions. Clear bugs are fixed; the rest comes to you with a recommendation.
7. **Summary.** What was built, how it was verified, what is left open.

The plan file means a later session can pick the feature up with "continue" or `/feature-dev resume <path>`.

### A modified version of Anthropic's skill, built to spend fewer tokens

The original is Anthropic's official `feature-dev` plugin: https://github.com/anthropics/claude-plugins-official/tree/main/plugins/feature-dev

The original runs the full set of agents on every feature: two to three explorers, two to three architects, three reviewers. That is right for a large feature and wasteful for a three-file change. This version adds phase 0 and scales the agents to the task:

| | Small | Medium | Large |
|---|---|---|---|
| Explorers | 0 | 0–1 | 2–3 |
| Architects | 0 | 1, with two short asides from the other viewpoints | 2–3 |
| Reviewers | self-review | 2 | 3 |

On large tasks it behaves like the original. It also adds the resumable plan file and ships its own three agents, so it works without the plugin. The numbers behind the change are in `docs/feature-dev.md`.

### When to switch back to the original

The saving comes from running fewer agents on small and medium tasks. If you find that more bugs get through than you expect, or tokens are not a constraint for you, use the original:

```
/plugin install feature-dev@claude-plugins-official
/feature-dev:feature-dev <what you want built>
```

Both can be installed side by side. A middle option: keep this version and tell it "full run" for features where quality matters most; that forces the large path with all agents.

## What is inside

| Path | What it is |
|---|---|
| `skills/feature-dev/` | The feature pipeline. Sizes the task first (S / M / L), then understands, asks, designs, builds, reviews. A plan file lets any later session resume. |
| `agents/` | The three helper agents the skill calls: explorer, architect, reviewer. |
| `claude/CLAUDE.md` | A short global rules block: deployment safety, when to use `/feature-dev`, how every chat ends with a checkpoint, which model plans and which builds. |
| `scripts/` | `context-hook.py`, installed as a hook: every message carries a `Context: Nk / 1M` line, which each checkpoint reports. `statusline.py`, optional and not installed: the same number under the prompt in the terminal. |
| `install.sh` | Installs the skill with the templates, the agents, the rules, the two model names and the hook into `~/.claude` without overwriting anything. `--update` refreshes, `--uninstall` removes. |
| `AGENTS.md` | Instructions for an AI agent asked to install or update this setup for you. |
| `HOW-IT-WORKS.md` | How a session uses all of this, step by step. Start here. |
| `docs/` | The longer story behind each part. `docs/checkpoints.md` is how work survives between chats: the five layers of files, how they link, and how every chat ends. |
| `memory/` | A sample of file-based memory: one fact per file, with a "why" and a "how to apply". |
| `examples/` | A real plan file, a state file, a master plan, a decision log, a mockup README and a change record, so the formats are concrete. Installed next to the skill, so a new project gets its master plan and decision log from them at the first checkpoint. |

## Quick start

Open Claude Code and say:

```
Install the setup from https://github.com/maxg-agency/claude-code-setup. Follow its AGENTS.md.
```

The agent asks you three questions (global or one project; what to do with existing files; which model plans and which builds), runs the installer and tells you to restart.

Or by hand:

```sh
git clone https://github.com/maxg-agency/claude-code-setup
cd claude-code-setup
CLAUDE_PLANNING_MODEL=opus CLAUDE_BUILDING_MODEL=sonnet sh install.sh
```

Without the two variables the agent asks you once and writes the names into `~/.claude/CLAUDE.md`. With a 1M context window, add `CLAUDE_CONTEXT_WINDOW=1000000`. The hook needs `python3`.

Restart Claude Code, then in any project:

```
/feature-dev add a retry when the profile page loads half-empty
```

On a medium or large task it stops after planning:

```
I have reached the point where we need to switch to sonnet.
State saved: .claude/feature-dev/profile-retry/PLAN.md
To continue: /model sonnet, then "continue" (or in a new chat: /feature-dev resume <path>).
Context: 84k / 200k (42%)
```

You switch, it builds. To update later: `git pull && sh install.sh --update`.

## The four ideas

1. **Size the task before spending on it.** A three-file change does not need three architects. A new module does. The skill decides in one short turn, says so in one line, and you can override with one word.
2. **Agents get a narrow question and ready facts.** An agent with a wide question spends half an hour rediscovering what the session already knows. With a file list and one question, it answers in minutes.
3. **The plan file is the source of truth.** Everything the next session needs lives in `PLAN.md`. Chat is disposable; files are not.
4. **The model learns from corrections.** Every time I correct it, it writes one small file: the rule, why, how to apply it. The index of those files is loaded into every session.

## FAQ

**Why does the skill write such a full plan before building?**
Because the build often happens in a new chat. A long session fills the context window with file contents, agent reports and back-and-forth. Two things go wrong when that happens. Every new message re-sends the whole history, so each turn costs more tokens. And the model works worse: with a lot of context it loses track of early decisions, mixes up versions of the same file and follows the latest noise instead of the plan. So we often finish the planning, then start a fresh chat and say `/feature-dev resume <path to PLAN.md>`. The plan, and on bigger tasks the agents' full reports in `blueprints/`, carry everything the new chat needs. A short summary would not: the details it drops are exactly the ones the next session needs.

**Do I have to switch models and chats myself?**
Yes, on purpose. The setup never switches for you: on medium and large tasks it stops after planning and tells you which model to switch to, and you run `/model`. A new chat is optional but cheaper: the plan file is self-contained, so `/clear` and `/feature-dev resume <path>` lose nothing, and the `Context:` number at each checkpoint shows how much the old chat would drag along. Small tasks never stop. If you use one model for everything, give the same name twice and there are no stops at all.

**Why not just rely on Claude Code's automatic compaction?**
Compaction summarizes the chat to free space, and a summary loses the exact file paths, the user's answers word for word and the reasons an option was rejected. The plan file keeps them deliberately, in a fixed structure, so nothing important depends on what the summarizer chose to keep.

**Why does it save the agents' raw reports, not just the conclusions?**
The plan holds the conclusions. When a later session disagrees with one, it can open the raw report and see what the conclusion was based on instead of redoing the research.

**Small tasks get no review agents. Is that safe?**
The session still reviews its own diff, and a reviewer agent runs if the change touches shared code, data, publishing or auth. If you see more bugs than you expect, say "full run" for important features, or switch to the original plugin (see above).

## Who this is for

Product people and founders who build with AI rather than manage a team of engineers. One person, one laptop, a Claude subscription, real projects that have to work.

## More skills

Smaller standalone skills live in [maxg-agency/skills](https://github.com/maxg-agency/skills). The first one, `step-zero`, pairs well with `/feature-dev`: it interviews you about the goal and writes `concept.md` before anything gets built.

## Author

Max Gankov, founder of [Max G Agency](https://maxg.agency), an AI automation agency for tech and service companies with a team.

- Website: https://maxg.agency
- LinkedIn: https://www.linkedin.com/in/max-gankov
- X: https://x.com/maxgankov

## Credits

The shape of the pipeline (seven phases, explorer, architect and reviewer roles) comes from Anthropic's official `feature-dev` plugin, licensed under Apache 2.0. This version adds the scale check, the plan file and its own agents, and does not need the plugin. The `grill-me` skill mentioned in `docs/extra-skills.md` is by Matt Pocock.

## License

MIT. See `LICENSE`.
