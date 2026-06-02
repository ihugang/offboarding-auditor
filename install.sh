#!/usr/bin/env bash
#
# offboarding-auditor — terminal installer
#
# Installs the skill into your Claude Code skills directory (global by default).
#
#   curl -fsSL https://raw.githubusercontent.com/ihugang/offboarding-auditor/main/install.sh | bash
#
# Options (env vars):
#   SCOPE=project   install into ./.claude/skills instead of ~/.claude/skills
#   REF=main        git branch/tag to install from (default: main)
#
set -euo pipefail

REPO="https://github.com/ihugang/offboarding-auditor.git"
NAME="offboarding-auditor"
REF="${REF:-main}"

if [ "${SCOPE:-global}" = "project" ]; then
  BASE="$(pwd)/.claude/skills"
else
  BASE="$HOME/.claude/skills"
fi
DEST="$BASE/$NAME"

command -v git >/dev/null 2>&1 || { echo "❌ git is required but not found."; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "→ Cloning $REPO ($REF) ..."
git clone --depth 1 --branch "$REF" -q "$REPO" "$TMP/repo"

SRC="$TMP/repo/skills/$NAME"
[ -f "$SRC/SKILL.md" ] || { echo "❌ SKILL.md not found in repo at skills/$NAME — repo layout changed?"; exit 1; }

echo "→ Installing to $DEST ..."
mkdir -p "$BASE"
rm -rf "$DEST"
cp -R "$SRC" "$DEST"
chmod +x "$DEST/scripts/inventory.sh" 2>/dev/null || true

VER="$(sed -n 's/^version:[[:space:]]*//p' "$DEST/SKILL.md" | head -1)"
echo "✅ Installed offboarding-auditor v${VER:-?} → $DEST"
echo "   Start a NEW Claude Code session, then trigger it, e.g.:"
echo '   "对这个项目做离职/交接审计"  ·  "run an offboarding audit on this repo"'
