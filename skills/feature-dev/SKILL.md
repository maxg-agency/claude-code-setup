---
name: feature-dev
description: Feature development that spends agents only where they pay off. Phase 0 sizes the task (S small, M medium, L large) and the size decides how many helper agents run: S none, M one architect, L a full run with several explorers, architects and reviewers. Then understand the code, ask only blocking questions, design, build, review, summarize, with a PLAN.md that lets any later session resume. Use when the user says "/feature-dev", asks for a feature, a refactor, a new endpoint, an integration, a UX flow change, or "continue by PLAN.md".
argument-hint: feature description | resume <path to PLAN.md>
---

# Feature Dev, sized to the task

Derived from Anthropic's `feature-dev` plugin (https://github.com/anthropics/claude-plugins-official/tree/main/plugins/feature-dev, Apache License 2.0). Modified: a size check that scales the number of helper agents, a resumable plan file, and new helper agents in place of the plugin's.

Seven phases from request to working code, in one session, on whatever model the user runs.
The expensive part of a feature pipeline is helper agents: each one re-reads the codebase
and writes a long report. So phase 0 decides how many of them the task actually needs.

Helper agents (installed with this skill into `~/.claude/agents/`):

| Agent | Job |
|---|---|
| `feature-explorer` | Traces how an area of the code works and returns the 5–10 files that matter. |
| `feature-architect` | Designs one implementation approach as an exact blueprint. |
| `feature-reviewer` | Reviews a diff for one focus and reports only high-confidence issues. |

If they are not installed, use the built-in `general-purpose` agent with the same
instructions, or do the work in the main thread.

## Phase 0. Scale

Request: $ARGUMENTS

In one turn, without agents: from the request and a quick look at the code (a grep, one to
three files, the latest PLAN.md in the same area) estimate the number of files, whether
there is a real choice of approach, whether the area is known, whether undoing is cheap.
Pick a scale and write one line in chat, for example:

```
Scale: M. 5 files, a choice between reusing the overlay host or a new dialog, area known from PLAN brief-overlay. Running: 1 architect, 2 reviewers.
```

Do not wait for an answer; continue. The user corrects it with one word if they disagree.

| | **S small** | **M medium** | **L large** |
|---|---|---|---|
| Signals (any two are enough) | ≤3 files; one obvious approach, or one already prescribed by a plan, a mockup or a decision log; known area; cheap to undo | 4–8 files; a local choice (where a helper goes, which component to reuse, the shape of data in one place); area partly known; touches a shared component or tests | >8 files or a new module; a choice that changes the data model, module boundaries, external integrations or the user flow; new area; migrations, schema, security, production behaviour |
| Exploration | main thread reads 1–3 files | 0–1 `feature-explorer` with a narrow question; main thread reads 5–8 files | 2–3 `feature-explorer` in parallel, different angles |
| Questions | only blocking ones, usually none | as needed | as needed |
| Architecture | main thread writes the approach | 1 `feature-architect` ("pragmatic balance") + two asides: what a minimalist would do, what a clean architect would add | 2–3 `feature-architect` in parallel: minimal change, clean architecture, pragmatic balance |
| Approval before building | no, build right away | yes, if there was a real choice | yes |
| Review | self-review of the diff; 1 `feature-reviewer` (bugs) only if the diff touches a shared component, data, publishing or auth | 2 `feature-reviewer`: bugs; simplicity + conventions | 3 `feature-reviewer`: simplicity; bugs; conventions |
| PLAN.md | short, sections 1, 4, 7 | full | full, plus `blueprints/` |

Rules:
- **Doubt goes up.** Between S and M take M, between M and L take L. Down only by the user's
  word ("no agents", "this is small"). Words the other way ("full run", "show me options")
  give L.
- **Escalate when the task turns out bigger.** If exploration or a question reveals a real
  choice or an unfamiliar area, raise the scale, write `Scale: S → M, why` in PLAN.md, run
  the missing agents. Never lower the scale after phase 0.
- **Agents get a narrow question and ready facts.** Put the file list, the constraints, the
  user's answers and one concrete question into each prompt. A wide question makes an agent
  spend half an hour rediscovering what you already know.
- **Do not wait on a slow agent.** While an agent runs, write your own option. If your
  option is ready and the report is late, go on with yours and fold the report in later.

## PLAN.md

Path: `<project root>/.claude/feature-dev/<feature-slug>/PLAN.md`, slug of 2–4 words with
hyphens. It exists so that a new session, or the same session after its context was
compressed, can continue without the chat. Write it as you go, not at the end.

```
# <Feature>
Status: scale-set | planned | building | reviewed | done
Scale: S | M | L, signals in one line; escalations with "→"

## 1. Task
What, why, constraints, in the wording the user confirmed.

## 2. What we found in the code
Key files (path + one line why), patterns, extension points, conventions.

## 3. Questions and answers
Each question and the user's answer, or the decision you made and why.

## 4. Approach
The approach and why; rejected options one line each.
Files to create / modify, with what changes in each.
Numbered steps. How to verify (command, manual scenario). What not to touch.

## 5. Build log
Step → what was done; deviations from section 4 and why.

## 6. Review
Findings by severity and what was done with each.

## 7. Summary
What was built, files changed, how it was verified, open follow-ups.
```

On M and L, save each agent's full report as delivered into `blueprints/` next to the plan,
with a README of one line per file: what it is and what was taken from it. Section 4 must
still be enough to build from without opening `blueprints/`.

Resume: `/feature-dev resume <path>` or "continue": read PLAN.md, find the next phase from
`Status`, read only the files named in sections 2 and 4, continue. Do not re-explore.

## Phase 1. Discovery

If the request is unclear, ask what problem it solves, what it should do, and the
constraints. Otherwise restate it in two or three lines. Create PLAN.md with sections 1
and the `Scale` line. On S, phases 0–4 usually fit in one turn.

## Phase 2. Exploration

By scale (table above). From the agents' file lists read in the main thread only what you
need for questions and design, usually 5–8 files, not all of them. Write section 2. If the
picture is bigger than phase 0 assumed, escalate here.

## Phase 3. Questions

Collect what is underspecified: edge cases, error handling, integration points, scope,
compatibility, performance. Ask only what the user alone can answer (their facts, their
money, their priorities, their taste). If you have a recommendation and the choice is cheap
to undo, decide, write it in section 3, and mention it in one line. Ask the remaining
questions as one list and wait. Skip this phase only when nothing is left to ask.

## Phase 4. Architecture

By scale:
- **S:** write section 4 yourself: approach, files, steps, verification, boundaries.
- **M:** one `feature-architect`, focus "pragmatic balance", with sections 1–3 and one
  question in the prompt. Ask it to end with two short blocks: "what a minimalist would do"
  and "what a clean architect would add". Write your own option in parallel. Compare, take
  what is useful, write section 4. If there was a real choice, show the user the options
  with your recommendation and wait for their pick.
- **L:** 2–3 `feature-architect` in parallel with the three focuses, the same facts and
  question for each. Compare, recommend one with reasons, show the user the trade-offs,
  wait for their pick, write section 4.

Section 4 is written so that someone who never saw the chat can build from it.

On M and L, if the session is already long (many files read, agent reports in context, or
Claude Code has compacted it), offer once: "The plan is saved. For fewer tokens and a
sharper model, you can continue in a new chat with `/feature-dev resume <path>`." Then go
on building unless the user takes the offer. A long context makes every turn costlier and
the model less precise; the plan and `blueprints/` are what make the switch lossless.

## Phase 5. Build

Implement by the steps of section 4, following the project's conventions. Write tests for
new behaviour where the project has tests. Run the verification from section 4. Deviate
from the plan only when it does not work in practice, and log each deviation in section 5.

If the build shows the approach is wrong in substance (not a fix, a different design),
stop building, write why in section 5, return to phase 4 and raise the scale at least to M.

## Phase 6. Review

By scale (table above). Give each reviewer the list of changed files, section 4 and its
focus, not "look at the repository". Merge the findings. Fix what is clearly a bug.
For the rest, show the user the serious ones with a recommendation and act on their answer.
Write section 6.

## Phase 7. Summary

Fill section 7, set `Status: done`, save reviewer reports to `blueprints/` on M and L.
Tell the user in a few lines what was built, how it was verified, and what is left open.
