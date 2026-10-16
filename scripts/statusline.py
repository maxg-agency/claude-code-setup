#!/usr/bin/env python3
"""Claude Code status line: model, context used, subscription limits.

Claude Code runs this after every response and pipes session JSON to stdin.
It prints one line, shown under the prompt. It costs no tokens: the model
never sees it. Fields: https://code.claude.com/docs/en/statusline

Not installed by install.sh: statusLine is a single setting and would replace
your own. Shows in the terminal only, not in the VS Code panel. To use it, add
to ~/.claude/settings.json:
  "statusLine": {"type": "command", "command": "python3 /path/to/statusline.py"}
"""
import json
import sys

try:
    d = json.load(sys.stdin)
except Exception:
    print("")
    sys.exit()

model = (d.get("model") or {}).get("display_name") or "?"
cw = d.get("context_window") or {}
used = cw.get("total_input_tokens")
size = cw.get("context_window_size")
pct = cw.get("used_percentage")

parts = [model]
if used is not None and size:
    size_txt = f"{size / 1_000_000:g}M" if size >= 1_000_000 else f"{size // 1000}k"
    pct_txt = f" ({pct:.0f}%)" if pct is not None else ""
    parts.append(f"{used / 1000:.0f}k / {size_txt}{pct_txt}")

rl = d.get("rate_limits") or {}
lim = []
for key, label in (("five_hour", "5h"), ("seven_day", "7d")):
    p = (rl.get(key) or {}).get("used_percentage")
    if p is not None:
        lim.append(f"{label} {p:.0f}%")
if lim:
    parts.append("limits " + " · ".join(lim))

print(" · ".join(parts))
