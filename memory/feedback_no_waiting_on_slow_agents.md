---
name: feedback_no_waiting_on_slow_agents
description: The user does not tolerate waiting on slow subagents; if the data is enough, move on without the second report
metadata:
  type: feedback
---
Do not block the work on a slow subagent. During a feature for the site the second architect ran for 20+ minutes; the user wrote "ping it", "speed up, impossible to wait", and stopped the agent by hand. A repeat a week later: I ended a turn with "waiting for the two architects' reports" although I had already measured everything and written the brief myself; the user asked "are you stuck?". The architects took 28 and 42 minutes and changed almost nothing in the decision.

**Why:** one blueprint and my own reading of the code were enough; I could have described the second approach myself in a minute. Waiting for the sake of the pipeline's form irritates more than a slightly less complete comparison.

**How to apply:** never end a turn with "waiting for agents": if my own decision is ready, bring it to the user for approval at once and fold the agents' reports in later if they contain anything useful. Give architects and reviewers a narrow question and ready facts, otherwise they spend half an hour rediscovering the known. Launch parallel agents only where the result is really needed; if one report has arrived and covers the question, do not wait for the others, formulate the alternative yourself and go to the question or to the code.
