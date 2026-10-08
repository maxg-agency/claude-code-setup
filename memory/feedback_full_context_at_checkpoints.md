---
name: feedback_full_context_at_checkpoints
description: Before a new chat (a long session, end of day, "I'll continue tomorrow") save full plans and context to files, not only a digest
metadata:
  type: feedback
---
Before every switch to a new chat (a long session, the end of a session, the user's "I'll continue tomorrow" or "I need full context") the agent saves into the step's files not only the consolidated PLAN.md but also the full reports it is based on: the explorers' findings, the architects' blueprints, the user's answers verbatim, the reviewers' reports. Place: `.claude/feature-dev/<slug>/blueprints/` with a README saying what came from where and what was taken.

**Why:** the user said: "Always write down the full plans and contexts at this point. It matters." Before that the architects' blueprints lived only in the chat: section 4 referred to "the case list from the data blueprint", which the next agent could not see. Context compression and a new session erase the chat; files remain.

**How to apply:** before suggesting a new chat and before any "continue tomorrow", check: all agent reports of this step are in `blueprints/`, PLAN.md links to them, the user's decisions are written verbatim in section 3 and in DECISIONS.md, project memory is updated. Raw reports are saved as delivered (language and punctuation untouched), and the folder's README says so. Related: [[feedback_ask_only_blocking_questions]].
