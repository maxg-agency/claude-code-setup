# 2026-10-07: feature-dev sized to the task

Task: the token spend of the feature pipeline was too high because it ran the full set of agents for every feature. Three architects were slow and often converged on the same answer. Needed: small features without architects, medium ones with a compromise, large ones unchanged.

Rollback: `sh ~/.claude/changes/2026-10-07-feature-dev-scale/rollback.sh`
Snapshots: `before/` as it was, `after/` as it became.

## What the analysis showed (65 plan files over two weeks)

- Three architects' reports on a medium feature weigh 100–220 KB, explorers 60–130 KB, reviewers 10–30 KB. Architects are the main cost.
- On medium features the second and third architect brought 2–5 borrowings into the chosen approach, not a different approach.
- Small features were already done by hand with "no agents", about 15 plans out of 65.
- Architects with a wide question took 20–42 minutes and barely changed the decision.

## What changed

### 1. ~/.claude/skills/feature-dev/SKILL.md
- New phase 0: size the task (S / M / L) in one turn, announce it in one line, do not wait.
- Agents by size: explorers 0 / 0–1 / 2–3, architects 0 / 1 / 2–3, reviewers self-review / 2 / 3.
- M: one "pragmatic balance" architect with two asides (minimalist, clean architect).
- Doubt goes up; the size can rise mid-work and is recorded; it never drops.
- PLAN.md gets a `Scale:` line.
Copy: `after/SKILL.md`

### 2. ~/.claude/CLAUDE.md
One sentence: running the skill for small things is cheap now.
Copy: `after/CLAUDE.md`

## What did not change
Seven phases, the plan file, the large-task path.
