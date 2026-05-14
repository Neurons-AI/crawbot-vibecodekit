#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${CRAWBOT_KIT_TARGET:-$(pwd)}"
STAMP="$(date +%Y%m%d-%H%M%S)"

copy_with_backup() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ]; then
    cp "$dest" "$dest.bak-$STAMP"
  fi
  cp "$src" "$dest"
}

copy_with_backup "$ROOT/templates/AGENTS.md" "$TARGET/AGENTS.md"
copy_with_backup "$ROOT/templates/HEARTBEAT.md" "$TARGET/HEARTBEAT.md"
copy_with_backup "$ROOT/templates/vibe-workflow.md" "$TARGET/docs/vibe-workflow.md"
mkdir -p "$TARGET/skills"
if [ -d "$TARGET/skills/vibe-builder" ]; then
  cp -R "$TARGET/skills/vibe-builder" "$TARGET/skills/vibe-builder.bak-$STAMP"
fi
rm -rf "$TARGET/skills/vibe-builder"
cp -R "$ROOT/templates/skills/vibe-builder" "$TARGET/skills/vibe-builder"
mkdir -p "$TARGET/tmp"

echo "Installed CrawBot VibeCode Kit into: $TARGET"
echo "Run: node $ROOT/scripts/doctor.mjs --target '$TARGET'"
