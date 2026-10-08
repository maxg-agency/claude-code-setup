# The feature pipeline: how it is used and why it is sized

`/feature-dev` takes a request to working, reviewed code in seven phases. The shape comes from Anthropic's official `feature-dev` plugin: understand the code, ask, design, build, review, with explorer, architect and reviewer agents. This version adds a size check that decides how many agents run, a plan file for resuming, and its own three agents, so it needs no plugin.

## Daily use

```
/feature-dev <what you want>
```

Turn by turn:

1. One line: the size, why, and how many agents will run.
2. The session reads the relevant code and asks the blocking questions as one list.
3. It writes the approach into `PLAN.md`. On medium and large tasks it shows the options and waits for your pick.
4. It builds, runs the checks, runs reviewers by size, fixes clear bugs and shows you the rest.
5. A short summary: what was built, how it was verified, what is open.

Resume in a later session:

```
/feature-dev resume .claude/feature-dev/<slug>/PLAN.md
```

## Why there is a size check

**The problem, in my words at the time.** "The token spend on feature-dev is very high because it runs for absolutely every feature. Three architects are slow and often give the same answer. For large features that is fine; for small ones it only gets in the way."

**What 65 plan files over two weeks showed:**

- Architect reports on a medium feature weighed 100 to 220 KB of text, explorers 60 to 130 KB, reviewers 10 to 30 KB. Each agent also re-reads the codebase. Architects were the main cost.
- On medium features the second and third architect did not produce a different approach. They produced two to five details that were borrowed into the chosen one. On one project the "pragmatic balance" architect won every single time.
- Small features were already being done by hand with "no agents, please", about 15 plans out of 65. The pipeline had no middle setting.
- Architects given a wide question took 20 to 42 minutes and barely changed the decision. Given a file list and one question, they take a fraction of that.

**The fix.** Phase 0 sizes the task in one turn, without agents:

| | S small | M medium | L large |
|---|---|---|---|
| Signals | ≤3 files, one obvious or prescribed approach, known area, cheap to undo | 4–8 files, a local choice, touches a shared component or tests | >8 files or a new module, a choice that changes data, boundaries, integrations |
| Explorers | 0 | 0–1 with a narrow question | 2–3 |
| Architects | 0, the session writes the approach | 1 "pragmatic balance" + two asides: what a minimalist would do, what a clean architect would add | 2–3 |
| Reviewers | self-review; 1 agent only if shared code, data or publishing is touched | 2 | 3 |

The single architect on M with two asides is the compromise: it covers the borrowings the second and third architects used to bring, at the cost of one agent.

Guard rails, so medium and large work does not get worse:

- Doubt goes up. Down only by the user's word.
- The size can rise mid-work and is recorded (`Scale: S → M`). It never drops.
- If building shows the design is wrong, the session goes back to design at M or above.
- While an agent works, the session drafts its own option and does not wait more than it has to.

## The plan file

`PLAN.md` has seven sections: task, findings, questions and answers, approach, build log, review, summary. On S it is short. On M and L the agents' full reports are saved next to it in `blueprints/` with a one-line README per file. Section 4 is always enough to build from without the chat. `examples/PLAN.example.md` is a real small one.

## How a change to the setup is recorded

```
changes/2026-10-07-feature-dev-scale/
  README.md      what changed and why, with the data
  before/        snapshots of every touched file
  after/         snapshots after the change
  rollback.sh    puts everything back
```

Git would track the files; this folder keeps the reasoning and the undo button together, where a later session can read them. Format in `examples/`.
