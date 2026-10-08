#!/bin/sh
# Rollback of the change from 2026-10-07 (feature-dev sized to the task).
# Run: sh ~/.claude/changes/2026-10-07-feature-dev-scale/rollback.sh
set -e
D="$HOME/.claude/changes/2026-10-07-feature-dev-scale"

cp "$D/before/SKILL.md" "$HOME/.claude/skills/feature-dev/SKILL.md"
echo "restored ~/.claude/skills/feature-dev/SKILL.md"
cp "$D/before/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
echo "restored ~/.claude/CLAUDE.md"
echo "Done. This record folder is not deleted; remove it by hand if not needed."
