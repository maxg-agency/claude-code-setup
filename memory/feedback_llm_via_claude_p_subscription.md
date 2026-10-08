---
name: feedback_llm_via_claude_p_subscription
description: Demos and personal projects call the model through a local `claude -p` under the subscription; no API keys; the call lives in one module
metadata:
  type: feedback
---
For demos and personal projects the model is called as a `claude -p` subprocess under the Claude subscription. No API keys are created. The user confirmed it explicitly for a demo bot: "we use my Claude subscription, as we did with the earlier projects, without an API".

**Why:** zero keys and zero billing at a stage where there are no clients. The pattern is already debugged in a runner module (spawn, `--output-format json`, a watchdog by timeout).

**How to apply:** when designing a bot or a script with an LLM, default to a wrapper module over `claude -p`, not the SDK; pass images through `--allowedTools Read` and a file path. The production version for a client moves to an API key (the subscription is not for commercial use), so keep the model call in one module. Do not propose an API key "for quality"; first look for a path on the subscription. The proven path for frequent calls: one living headless session with `--input-format stream-json --output-format stream-json` on the small model with thinking disabled (1.4–1.7 s per turn), structured answers via `--json-schema` + no tools, state via `--resume`. Cost is measured as a share of the subscription's limits, not in money. With untrusted text in the prompt, switch tools and connectors off per call. Related: [[feedback_no_waiting_on_slow_agents]].
