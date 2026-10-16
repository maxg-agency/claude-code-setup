#!/usr/bin/env python3
"""UserPromptSubmit hook: tells the model how big its context is.

Claude Code runs this on every user message and passes session JSON on stdin,
including transcript_path of THIS session. The script reads the token usage of
the last answer from the transcript and prints one short line, which Claude
Code adds to the model's context (~15 tokens). Works in the terminal, the
VS Code panel and the Desktop app alike. Docs: https://code.claude.com/docs/en/hooks

Window size: CLAUDE_CONTEXT_WINDOW if set, otherwise 200k, switching to 1M once
the context is past 200k. Run /context once to see your real window.

The transcript is only read, never executed. Any error means no output, so a
broken hook never blocks a prompt.
"""
import json
import os
import sys

try:
    WINDOW = int(os.environ.get("CLAUDE_CONTEXT_WINDOW") or 200_000)
except ValueError:
    WINDOW = 200_000
if WINDOW <= 0:
    WINDOW = 200_000

try:
    path = json.load(sys.stdin)["transcript_path"]
except Exception:
    sys.exit(0)

used = None
try:
    with open(path, "rb") as f:
        f.seek(0, 2)
        f.seek(max(0, f.tell() - 400_000))
        tail = f.read().decode("utf-8", "ignore").splitlines()
    for line in tail:
        try:
            o = json.loads(line)
        except Exception:
            continue
        m = o.get("message")
        # skip subagent turns (smaller context) and synthetic records with zero usage
        if o.get("type") == "assistant" and not o.get("isSidechain") and isinstance(m, dict) and m.get("usage"):
            u = m["usage"]
            total = (u.get("input_tokens") or 0) + (u.get("cache_read_input_tokens") or 0) + (u.get("cache_creation_input_tokens") or 0)
            if total:
                used = total
except Exception:
    pass

if used is None:
    sys.exit(0)

if used > WINDOW:
    WINDOW = 1_000_000
size_txt = f"{WINDOW / 1_000_000:g}M" if WINDOW >= 1_000_000 else f"{WINDOW // 1000}k"
print(f"Context: {used / 1000:.0f}k / {size_txt} ({used * 100 / WINDOW:.0f}%)")
