# How it works

How the pieces fit, in the order a session actually uses them. Each section links to the longer document.

## 1. A session starts

Claude Code loads, before the first message:

- `~/.claude/CLAUDE.md`, the global rules. The block from this repo says two things: keep secrets and servers safe, and send anything larger than a micro edit through `/feature-dev`.
- The project's own `CLAUDE.md`, if there is one.
- The memory index, `MEMORY.md`: one line per memory file. The model opens a file only when its line looks relevant.
- The list of skills and agents, by name and description. Their full text loads only when used.

## 2. A request comes in

Anything bigger than a typo or a color goes through `/feature-dev`. That would be wasteful if the skill were heavy for small things. It is not, because of the next step.

## 3. Phase 0: the size check

The skill looks at the request and takes a quick look at the code: a grep, one to three files, the last plan in the same area. Then it writes one line:

```
Scale: M. 5 files, a choice between reusing the overlay host or a new dialog, area known from PLAN brief-overlay. Running: 1 architect, 2 reviewers.
```

It does not wait. You correct it with one word if you disagree.

| | S small | M medium | L large |
|---|---|---|---|
| Signals | 3 files or fewer, one obvious approach, known area | 4 to 8 files, a local choice, touches a shared component | more than 8 files or a new module, a choice that changes data, boundaries or integrations |
| Explorer agents | 0 | 0 or 1 | 2 to 3 |
| Architect agents | 0 | 1, plus two short asides from the other viewpoints | 2 to 3 with different focuses |
| Waits for your pick before building | no | if there was a real choice | yes |
| Reviewer agents | self-review, 1 if risky code is touched | 2 | 3 |

Doubt goes up. The size can rise during the work, never drop.

Why this matters: helper agents are the expensive part. Each one re-reads the codebase and writes a long report. On a medium feature, three architects produced 100 to 220 KB of text, and the second and third usually contributed a few borrowings rather than a different design. Details in `docs/feature-dev.md`.

## 4. Understand, ask, design

The session reads the code that matters, asks only what you alone can answer (your facts, your money, your priorities, your taste), and decides the rest itself with a one-line note. It writes the approach into `PLAN.md`: exact files, numbered steps, how to verify, what not to touch.

On small tasks this is a few lines and building starts right away. On medium and large ones you see the options with a recommendation and pick.

## 5. Build, review, summarize

The session builds by the plan, runs the project's checks, and logs any deviation. Reviewer agents run by size, each with one focus and the list of changed files. Clear bugs are fixed; the rest is shown to you with a recommendation. The summary says what was built, how it was verified and what is left open.

If building shows the design is wrong in substance, the skill goes back to the design step with a bigger size instead of patching around it.

## 6. Picking up later

`PLAN.md` lives in `<project>/.claude/feature-dev/<slug>/`. On medium and large features the agents' full reports sit next to it in `blueprints/`. A new session, or the same one after its context was compressed, says "continue" or `/feature-dev resume <path>` and goes on from the recorded status without re-exploring.

## 7. Corrections become memory

When you correct the model, it writes one file into its memory folder:

```markdown
---
name: ask-only-blocking-questions
description: Ask only what the user alone can answer; decide the rest and record it
metadata:
  type: feedback
---
Do not ask a question you have already answered with a recommendation and that is cheap to undo. Decide, record it, say so in one line.

**Why:** a list of eight questions where the fourth came with "low impact, I recommend keeping yours" got an irritated reply. A question with a recommendation attached reads as offloading the work.

**How to apply:** before asking, check three things. Do I have a recommendation with reasons? Is it cheap to undo? Does the user know something I do not? Only the third earns a question.
```

And one line in `MEMORY.md`. Over a month this is what makes the model feel like it has worked with you before. Details: `docs/memory-and-self-learning.md`.

## 8. Changes to the setup are recorded

When the rules or a skill change, a dated folder records it: a README with the reasoning, `before/` and `after/` snapshots, a `rollback.sh`. The format is in `examples/`.

## 9. Testing happens in a browser the model can drive

The user's real Chrome through the Claude in Chrome extension for other people's sites and live effects. Headless Chrome over the DevTools protocol for screenshots of our own pages at four window sizes. Details: `docs/browser-testing.md`.

## 10. The model runs through the subscription, not an API key

Demos and personal tools call the model through a local `claude -p` subprocess under the subscription. The call lives in one module, so a client version can move to an API key by replacing that module. Untrusted text in a prompt means tools and connectors are switched off for that call. Details: `docs/subscription-not-api-keys.md`.
