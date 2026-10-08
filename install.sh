#!/bin/sh
# Installs the feature-dev skill, its three helper agents and the rules block into ~/.claude.
#
#   sh install.sh               install; never overwrites anything that exists
#   sh install.sh --update      refresh what this script installed
#   sh install.sh --uninstall   remove what this script installed
#
# Optional: CLAUDE_DIR (default ~/.claude)
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILL_DIR="$CLAUDE_DIR/skills/feature-dev"
AGENTS_DIR="$CLAUDE_DIR/agents"
AGENTS="feature-explorer feature-architect feature-reviewer"
RULES="$CLAUDE_DIR/CLAUDE.md"
MARK_START="<!-- claude-code-setup:start -->"
MARK_END="<!-- claude-code-setup:end -->"
MARKER=".installed-by-claude-code-setup"
STAMP="$(date +%Y%m%d-%H%M%S)"

ours_skill()  { [ -f "$SKILL_DIR/$MARKER" ]; }
ours_agent()  { [ -f "$AGENTS_DIR/$1.md" ] && grep -q "installed-by: claude-code-setup" "$AGENTS_DIR/$1.md"; }
has_block()   { [ -f "$RULES" ] && grep -q "$MARK_START" "$RULES"; }

backup_rules() {
  [ -f "$RULES" ] && cp "$RULES" "$RULES.bak-$STAMP" && echo "backup  $RULES.bak-$STAMP"
  return 0
}
remove_block() {
  awk -v s="$MARK_START" -v e="$MARK_END" '$0==s{skip=1} !skip{print} $0==e{skip=0}' "$RULES" > "$RULES.tmp" && mv "$RULES.tmp" "$RULES"
}
append_block() {
  { printf '\n%s\n' "$MARK_START"; cat "$HERE/claude/CLAUDE.md"; echo "$MARK_END"; } >> "$RULES"
}
put_skill() {
  mkdir -p "$(dirname "$SKILL_DIR")"
  cp -R "$HERE/skills/feature-dev" "$SKILL_DIR"
  touch "$SKILL_DIR/$MARKER"
}
put_agent() {
  mkdir -p "$AGENTS_DIR"
  # tag the copy so --update and --uninstall know it is ours
  awk 'NR==1{print; next} !done && /^---$/{print "installed-by: claude-code-setup"; done=1} {print}' \
    "$HERE/agents/$1.md" > "$AGENTS_DIR/$1.md"
}

case "$1" in
  --uninstall)
    if ours_skill; then rm -rf "$SKILL_DIR"; echo "removed $SKILL_DIR"
    elif [ -e "$SKILL_DIR" ]; then echo "kept    $SKILL_DIR (not installed by this script)"; fi
    for a in $AGENTS; do
      if ours_agent "$a"; then rm -f "$AGENTS_DIR/$a.md"; echo "removed $AGENTS_DIR/$a.md"
      elif [ -e "$AGENTS_DIR/$a.md" ]; then echo "kept    $AGENTS_DIR/$a.md (not installed by this script)"; fi
    done
    if has_block; then backup_rules; remove_block; echo "removed the rules block from $RULES"; fi
    exit 0 ;;
  --update)
    if ours_skill; then
      mv "$SKILL_DIR" "$(dirname "$SKILL_DIR")/.feature-dev.bak-$STAMP"; put_skill
      echo "updated $SKILL_DIR (previous copy: .feature-dev.bak-$STAMP next to it)"
    elif [ -e "$SKILL_DIR" ]; then echo "skip    $SKILL_DIR is not ours"
    else put_skill; echo "added   $SKILL_DIR"; fi
    for a in $AGENTS; do
      if ours_agent "$a" || [ ! -e "$AGENTS_DIR/$a.md" ]; then put_agent "$a"; echo "updated $AGENTS_DIR/$a.md"
      else echo "skip    $AGENTS_DIR/$a.md is not ours"; fi
    done
    if has_block; then backup_rules; remove_block; append_block; echo "updated the rules block in $RULES"
    else echo "skip    no rules block in $RULES (run without --update to add it)"; fi
    exit 0 ;;
  "") ;;
  *) echo "unknown option: $1"; exit 1 ;;
esac

# 1. Skill
if [ -e "$SKILL_DIR" ]; then echo "skip    $SKILL_DIR already exists (use --update if this script installed it)"
else put_skill; echo "added   $SKILL_DIR"; fi

# 2. Helper agents
for a in $AGENTS; do
  if [ -e "$AGENTS_DIR/$a.md" ]; then echo "skip    $AGENTS_DIR/$a.md already exists"
  else put_agent "$a"; echo "added   $AGENTS_DIR/$a.md"; fi
done

# 3. Rules block, appended between markers; the file is never replaced
if has_block; then echo "skip    $RULES already has the rules block (use --update to refresh it)"
else backup_rules; append_block; echo "added   the rules block to $RULES"; fi

cat <<EOF

Done. Restart Claude Code so the skill, agents and rules load, then in any project:
  /feature-dev <what you want built>
EOF
