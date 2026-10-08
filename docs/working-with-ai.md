# Working with AI: the rules that survived

These are the rules that came out of real corrections over several months of shipping with Claude Code. Each one exists because its absence cost something. They live in the global `CLAUDE.md` and in the memory folder; this page is the readable version.

## Ask only what I alone can answer

A question with a recommendation attached, where undoing is cheap, is not a question. It is offloading. Before asking, the model checks three things: do I have a recommendation with reasons; is it cheap to undo; does the user know something I do not. Only the third earns a question. Decisions the model makes itself are written down in one line so they can be challenged later.

What is already in an approved plan counts as my decision, even if the model later finds an argument against it. An argument against an approved item is raised as a question with a recommendation, not decided silently.

## The plan file is the only source of truth

Chat gets compressed, sessions end, I open new chats on purpose. Everything the next agent needs is in `PLAN.md`, and the full subagent reports sit next to it in `blueprints/`. The plan is written so that an agent who never saw the chat can implement by it. Saving happens before the stop, not after.

## Full context, not a digest

When a chat gets long, or I say "I'll continue tomorrow", the model saves everything it based its decisions on: the explorers' findings, the architects' blueprints as delivered, my answers verbatim, the reviewers' reports. Then I usually open a new chat and resume from the files. A long context costs more per turn and makes the model sloppier; a fresh chat with a complete plan is cheaper and sharper. A digest is for reading; the raw reports are for the next session that disagrees with the digest.

## Do not wait for slow agents

An architect agent once ran for 42 minutes and changed nothing in the decision. The rule now: give agents a narrow question and ready facts (file list, constraints, answers), never end a turn with "waiting for agents", and if your own option is ready, bring it; fold the report in later if it adds anything.

## The budget is cut on the cost of a step, not on the number of steps

Under context pressure the temptation is to skip a mandatory step because a log line suggests it is not needed. A log line describes a state on a date; it is not a rule. Rules live in skills and configs. If the budget does not fit, cut raw text, extra file reads and screenshots, not steps.

## The model does not do arithmetic

Any calculation goes through code (Python, a spreadsheet formula), and the model quotes the result. No calculation means no number. This came from a finance bot where the model, asked twice in a row, counted 78 records instead of 71 and called a spending line an outlier by comparing 9 days with 31 without normalizing. After the calculations moved into code, the same questions came back exact.

## No made-up numbers in copy

Marketing copy, case studies and bios contain only numbers that exist in a source I can point to. "Saved 40 percent" without a measurement is not written. Outcomes without measurements are written as estimates and labelled as such.

## Research without assumptions

When asked to research, every claim links to its source inline. "Probably", "typically" and "as is well known" are not sources. If nothing was found, the answer is "nothing found", not a plausible guess.

## Look at the page with your eyes

Automated UI checks passed 515 of 515 while the page had an empty right column and an unstyled table. After any content change that alters the shape of a page, the model takes full-page screenshots at four window sizes and looks at them before saying "done". Alignment is checked by measuring element edges, not by eye.

## Orphan processes are cleaned up on every exit path

Scripts that start a headless browser or a test runner with a timeout left processes running for a day and eating CPU. Every such script now has cleanup on `exit`, `SIGINT` and `SIGTERM`, uses a random debugging port, and never pipes its output through `head`.

## Where these came from

Each rule is a memory file with a "why" (the incident) and a "how to apply" (the check). See `memory/` for the format and `docs/memory-and-self-learning.md` for how the loop works.
