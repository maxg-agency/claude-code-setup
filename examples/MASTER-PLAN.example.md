# Booking site · master plan

## 0. How we work

> A new chat on this project reads this section and nothing else of the file unless the task needs it.

**Where things live**
- Code: `code/`. Run locally: `npm run dev`, http://localhost:3000.
- Features: `code/.claude/feature-dev/<slug>/PLAN.md`, full agent reports in `blueprints/` next to it.
- Other work (mockups, research, texts): its own folder with a `STATE.md`.
- Decisions: [`DECISIONS.md`](DECISIONS.md), one line each, newest on top.
- Commits: I commit myself. The agent ends a unit with a proposed commit message.

**Where the next chat starts**

| # | Unit | State file | Status | Next step | Model |
|---|---|---|---|---|---|
| 1 | Booking form | `code/.claude/feature-dev/booking-form/PLAN.md` | planned | build | building |
| 2 | Pricing page copy | `copy/pricing/STATE.md` | waiting for my edits | edits block by block | planning |
| 3 | ~~Live chat~~ | | dropped, see DECISIONS 2026-10-12 | | |

## 1. Why the project exists

Two or three lines: who it is for and what has to be true when it is done.

## 2. Order of work

1. Booking form, so the first clients can book without a call.
2. Pricing page, once the form works.
3. Reviews block, after five real bookings.

## 3. Open questions for me

- Which payment provider: waiting for my answer.
