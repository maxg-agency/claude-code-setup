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

When unsure, run the skill. It is cheap for small tasks: phase 0 sizes the task, and a small one gets no helper agents, just a short plan and the change. The skill keeps its state in `.claude/feature-dev/<slug>/PLAN.md`, so "continue" or `/feature-dev resume <path>` picks up a feature in a later session.
