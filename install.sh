#!/bin/sh
# Installs the feature-dev skill (with the state file templates), its three helper agents,
# the rules block, the models block and the context hook into ~/.claude.
#
#   sh install.sh               install; never overwrites anything that exists
#   sh install.sh --update      refresh what this script installed
#   sh install.sh --uninstall   remove what this script installed
#
# Optional:
#   CLAUDE_DIR              default ~/.claude
#   CLAUDE_PLANNING_MODEL   model that plans, as you type it after /model (e.g. opus)
#   CLAUDE_BUILDING_MODEL   model that builds (e.g. sonnet); unset means "<set me>",
#                           and the agent asks you once
#   CLAUDE_RULES_FILE       where the rules and models blocks go (default $CLAUDE_DIR/CLAUDE.md);
#                           a project's CLAUDE.md for a one-project install; pass it to --update too
#   CLAUDE_CONTEXT_WINDOW   your context window in tokens (e.g. 1000000) for the hook;
#                           unset means 200k, switching to 1M once the context is past 200k
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILL_DIR="$CLAUDE_DIR/skills/feature-dev"
AGENTS_DIR="$CLAUDE_DIR/agents"
AGENTS="feature-explorer feature-architect feature-reviewer"
RULES="${CLAUDE_RULES_FILE:-$CLAUDE_DIR/CLAUDE.md}"
MARK_START="<!-- claude-code-setup:start -->"
MARK_END="<!-- claude-code-setup:end -->"
MODELS_START="<!-- claude-code-setup:models:start -->"
MODELS_END="<!-- claude-code-setup:models:end -->"
HOOK_NAME="claude-code-setup-context-hook.py"
HOOK_SCRIPT="$CLAUDE_DIR/scripts/$HOOK_NAME"
SETTINGS="$CLAUDE_DIR/settings.json"
MARKER=".installed-by-claude-code-setup"
STAMP="$(date +%Y%m%d-%H%M%S)"

case "$CLAUDE_CONTEXT_WINDOW" in
  "") HOOK_CMD="python3 \"$HOOK_SCRIPT\"" ;;
  *[!0-9]*|0*) echo "CLAUDE_CONTEXT_WINDOW must be a positive number of tokens, got: $CLAUDE_CONTEXT_WINDOW"; exit 1 ;;
  *) HOOK_CMD="CLAUDE_CONTEXT_WINDOW=$CLAUDE_CONTEXT_WINDOW python3 \"$HOOK_SCRIPT\"" ;;
esac

ours_skill()  { [ -f "$SKILL_DIR/$MARKER" ]; }
ours_agent()  { [ -f "$AGENTS_DIR/$1.md" ] && grep -q "installed-by: claude-code-setup" "$AGENTS_DIR/$1.md"; }
has_block()   { [ -f "$RULES" ] && grep -qxF "$MARK_START" "$RULES"; }
has_models()  { [ -f "$RULES" ] && grep -qxF "$MODELS_START" "$RULES"; }
has_hook()    { [ -f "$SETTINGS" ] && grep -q "$HOOK_NAME" "$SETTINGS"; }

backup_rules() {
  [ -f "$RULES" ] && cp "$RULES" "$RULES.bak-$STAMP" && echo "backup  $RULES.bak-$STAMP"
  return 0
}
remove_block() {  # $1 start marker, $2 end marker; also drops the blank line the block was appended after
  if ! grep -qxF "$2" "$RULES"; then
    echo "skip    $RULES has \"$1\" but no end marker; fix it by hand"; return 1
  fi
  awk -v s="$1" -v e="$2" '
    $0==s { skip=1; blank=0; next }
    skip  { if ($0==e) skip=0; next }
    $0=="" { blank++; next }
    { while (blank-- > 0) print ""; blank=0; print }
    END   { while (blank-- > 0) print "" }' "$RULES" > "$RULES.tmp" && mv "$RULES.tmp" "$RULES"
}
append_block() {
  { printf '\n%s\n' "$MARK_START"; cat "$HERE/claude/CLAUDE.md"; echo "$MARK_END"; } >> "$RULES"
}
put_models() {
  { printf '\n%s\n' "$MODELS_START"
    echo "Planning model: ${CLAUDE_PLANNING_MODEL:-<set me>}"
    echo "Building model: ${CLAUDE_BUILDING_MODEL:-<set me>}"
    echo "$MODELS_END"; } >> "$RULES"
}
put_skill() {
  mkdir -p "$(dirname "$SKILL_DIR")"
  cp -R "$HERE/skills/feature-dev" "$SKILL_DIR"
  cp -R "$HERE/examples" "$SKILL_DIR/examples"
  touch "$SKILL_DIR/$MARKER"
}
put_agent() {
  mkdir -p "$AGENTS_DIR"
  # tag the copy so --update and --uninstall know it is ours
  awk 'NR==1{print; next} !done && /^---$/{print "installed-by: claude-code-setup"; done=1} {print}' \
    "$HERE/agents/$1.md" > "$AGENTS_DIR/$1.md"
}
put_hook_script() {
  mkdir -p "$CLAUDE_DIR/scripts"
  cp "$HERE/scripts/context-hook.py" "$HOOK_SCRIPT"
}

# Adds or removes our UserPromptSubmit entry in settings.json, leaving every other key and hook as is.
#   $1 = add (replace ours with the current command) | remove
# Returns 2 without python3, 1 if settings.json is not valid JSON or has an unexpected shape.
settings_edit() {
  command -v python3 >/dev/null 2>&1 || return 2
  [ -f "$SETTINGS" ] && cp "$SETTINGS" "$SETTINGS.bak-$STAMP"
  python3 -I - "$SETTINGS" "$HOOK_CMD" "$1" "$HOOK_NAME" <<'PY' || return 1
import json, os, sys
path, cmd, mode, name = sys.argv[1:5]
path = os.path.realpath(path)  # keep a symlinked settings.json a symlink
try:
    d = json.load(open(path)) if os.path.exists(path) else {}
    hooks = d.setdefault("hooks", {})
    ups = hooks.setdefault("UserPromptSubmit", [])
    assert isinstance(d, dict) and isinstance(hooks, dict) and isinstance(ups, list)
except Exception:
    sys.exit(1)  # unreadable or unexpected shape: touch nothing
def ours(g):
    return isinstance(g, dict) and any(isinstance(h, dict) and name in str(h.get("command", "")) for h in g.get("hooks", []))
ups[:] = [g for g in ups if not ours(g)]
if mode == "add":
    ups.append({"hooks": [{"type": "command", "command": cmd}]})
if not ups:
    del hooks["UserPromptSubmit"]
if not hooks:
    del d["hooks"]
tmp = path + ".tmp"
with open(tmp, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write("\n")
if os.path.exists(path):
    os.chmod(tmp, os.stat(path).st_mode & 0o7777)  # keep e.g. 0600
os.replace(tmp, path)
PY
}
add_hook() {
  if ! command -v python3 >/dev/null 2>&1; then
    echo "skip    context hook: python3 not found. The rest works; checkpoints will say \"Context: unknown\"."
    return 0
  fi
  put_hook_script
  rc=0; settings_edit add || rc=$?
  if [ "$rc" = 0 ]; then echo "added   context hook ($HOOK_SCRIPT, UserPromptSubmit in $SETTINGS)"
  else
    rm -f "$SETTINGS.bak-$STAMP"
    echo "skip    $SETTINGS is not valid JSON or has an unexpected shape; left untouched. Add by hand under \"hooks\":"
    echo "        \"UserPromptSubmit\": [{\"hooks\": [{\"type\": \"command\", \"command\": \"$(printf '%s' "$HOOK_CMD" | sed 's/"/\\"/g')\"}]}]"
  fi
}

case "$1" in
  --uninstall)
    if ours_skill; then rm -rf "$SKILL_DIR"; echo "removed $SKILL_DIR"
    elif [ -e "$SKILL_DIR" ]; then echo "kept    $SKILL_DIR (not installed by this script)"; fi
    for a in $AGENTS; do
      if ours_agent "$a"; then rm -f "$AGENTS_DIR/$a.md"; echo "removed $AGENTS_DIR/$a.md"
      elif [ -e "$AGENTS_DIR/$a.md" ]; then echo "kept    $AGENTS_DIR/$a.md (not installed by this script)"; fi
    done
    if has_block || has_models; then
      backup_rules
      has_block && remove_block "$MARK_START" "$MARK_END" && echo "removed the rules block from $RULES"
      has_models && remove_block "$MODELS_START" "$MODELS_END" && echo "removed the models block from $RULES"
    fi
    if has_hook; then
      rc=0; settings_edit remove || rc=$?
      if [ "$rc" = 0 ]; then echo "removed the context hook entry from $SETTINGS"
      else echo "kept    the context hook entry in $SETTINGS (python3 missing or invalid JSON); remove it by hand"; fi
    fi
    if [ -f "$HOOK_SCRIPT" ]; then rm -f "$HOOK_SCRIPT"; echo "removed $HOOK_SCRIPT"; fi
    exit 0 ;;
  --update)
    if ours_skill; then
      BAK=".feature-dev.bak-$STAMP"; [ -e "$(dirname "$SKILL_DIR")/$BAK" ] && BAK="$BAK-$$"
      mv "$SKILL_DIR" "$(dirname "$SKILL_DIR")/$BAK"; put_skill
      echo "updated $SKILL_DIR (previous copy: $BAK next to it)"
    elif [ -e "$SKILL_DIR" ]; then echo "skip    $SKILL_DIR is not ours"
    else put_skill; echo "added   $SKILL_DIR"; fi
    for a in $AGENTS; do
      if ours_agent "$a" || [ ! -e "$AGENTS_DIR/$a.md" ]; then put_agent "$a"; echo "updated $AGENTS_DIR/$a.md"
      else echo "skip    $AGENTS_DIR/$a.md is not ours"; fi
    done
    if has_block; then
      backup_rules
      if remove_block "$MARK_START" "$MARK_END"; then append_block; echo "updated the rules block in $RULES"; fi
      # the models block holds the user's choice: added if missing, never replaced
      if ! has_models; then put_models; echo "added   the models block to $RULES"; fi
    else echo "skip    no rules block in $RULES (run without --update to add it)"; fi
    if [ -f "$HOOK_SCRIPT" ] && has_hook && [ -z "$CLAUDE_CONTEXT_WINDOW" ]; then
      put_hook_script; echo "updated $HOOK_SCRIPT"
    else add_hook; fi
    exit 0 ;;
  "") ;;
  *) echo "unknown option: $1"; exit 1 ;;
esac

# 1. Skill, with the state file templates in examples/
if [ -e "$SKILL_DIR" ]; then echo "skip    $SKILL_DIR already exists (use --update if this script installed it)"
else put_skill; echo "added   $SKILL_DIR"; fi

# 2. Helper agents
for a in $AGENTS; do
  if [ -e "$AGENTS_DIR/$a.md" ]; then echo "skip    $AGENTS_DIR/$a.md already exists"
  else put_agent "$a"; echo "added   $AGENTS_DIR/$a.md"; fi
done

# 3. Rules block and models block, appended between markers; the file is never replaced
if has_block; then echo "skip    $RULES already has the rules block (use --update to refresh it)"
else backup_rules; append_block; echo "added   the rules block to $RULES"; fi
if has_models; then echo "skip    $RULES already has the models block"
else put_models; echo "added   the models block to $RULES"; fi

# 4. Context hook: one UserPromptSubmit entry merged into settings.json
if has_hook; then echo "skip    $SETTINGS already has the context hook"
else add_hook; fi

cat <<EOF

Done. Restart Claude Code so the skill, agents, rules and hook load.
EOF
if grep -qE "^(Planning|Building) model: <set me>$" "$RULES" 2>/dev/null; then
  echo "Model names are not set yet: edit the two lines in the models block of $RULES,"
  echo "or just start; the agent asks you once and writes them there."
fi
cat <<EOF
Then in any project:
  /feature-dev <what you want built>
EOF
