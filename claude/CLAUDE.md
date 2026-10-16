## Deployment safety
- Secrets (API keys, tokens, passwords) live only in .env or environment variables, never in code.
- .env is in .gitignore, otherwise secrets leak with the first commit.
- Databases are never reachable from the internet: localhost or VPN only.
- No debug mode on a server (debug=False, NODE_ENV=production).
- Do not run applications as root; create a dedicated user.
- Check for stray open ports (admin panels, dashboards, metrics).
- Do not disable security checks for convenience (verify=False, allowAll and the like are for local development only).
- SSH to servers by key only, never by password.

## Feature development
Anything larger than a micro edit goes through the `/feature-dev` skill.

**Do directly, without the skill:**
- A typo, a word, a grammar fix.
- Pure cosmetics: a color, a margin, one CSS variable, a label.
- Questions, explanations, reading code.

**Run `/feature-dev` for:**
- New functionality of any size.
- Refactoring that changes logic.
- New endpoints, integrations, external APIs.
- Changes to a user flow.
- Backend logic, migrations, data schema.

When unsure, run the skill. It is cheap for small tasks: phase 0 sizes the task, and a small one gets no helper agents, just a short plan and the change.

## Checkpoints and models
Model names: the `Planning model:` and `Building model:` lines of the models block in this file. `<set me>` there means: ask the user once and write the name in. The same name in both lines means no model stops; checkpoints still apply.
- Plan (understanding code, choosing an approach, a plan that failed in practice) on the planning model; build (a ready plan, fixes after review, routine edits) on the building model. Your own model is named in your system prompt. Wrong model: do nothing else, write the state, print the stop line. Exceptions: scale S, or the user said "do it on this model".
- A checkpoint happens when the plan is ready, a model switch is needed, the user says "continue tomorrow", context is warned about or compacted, or a unit of work is finished. In order: (1) write the unit's self-contained state file (PLAN.md of a feature, STATE.md otherwise) with a `Model log` entry; (2) agent reports as delivered into `blueprints/` next to it; (3) the user's answers verbatim into the state file, decisions into DECISIONS.md; (4) roll the status up to the project's MASTER-PLAN.md, creating it and DECISIONS.md from `~/.claude/skills/feature-dev/examples/` if missing; (5) propose a commit message, commit only if the user asks; (6) the stop line if a switch is needed.
- Stop line, then stop: "I have reached the point where we need to switch to <model>. State saved: <path>. To continue: /model <model>, then "continue"." For features the exact three-line form is in the skill. Never switch models or chats yourself.
- Last line of every checkpoint message: the latest "Context: Nk / …" line from the hook, or "Context: unknown" if there is none. The same number goes into the `Model log` entry.
- When the user corrects you or confirms a non-obvious approach, write one memory file (the rule, why, how to apply) and one line in MEMORY.md.
