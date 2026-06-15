#!/usr/bin/env bash
# shadcn-godot installer.
#
# Run it from your project's addons/ folder:
#   cd addons
#   curl -fsSL https://raw.githubusercontent.com/atticusofsparta/godot-addon-shadcn/main/install.sh | bash
#
# Optional: pass a branch or tag as the first argument:
#   ... | bash -s -- v0.1.0
set -euo pipefail

REPO="atticusofsparta/godot-addon-shadcn"
REF="${1:-main}"

if [ "$(basename "$PWD")" != "addons" ]; then
  echo "⚠  You don't appear to be in an 'addons/' folder (cwd: $PWD)."
  echo "   The addon will be installed to: $PWD/shadcn"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "→ Downloading shadcn-godot ($REF)…"
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/$REF" | tar -xz -C "$TMP"

SRC="$(find "$TMP" -type d -path '*/addons/shadcn' | head -1)"
if [ -z "$SRC" ] || [ ! -d "$SRC" ]; then
  echo "✗ Could not find addons/shadcn in the archive." >&2
  exit 1
fi

if [ -d "./shadcn" ]; then
  echo "→ Replacing existing ./shadcn"
  rm -rf "./shadcn"
fi
cp -R "$SRC" "./shadcn"

echo "✓ Installed to $PWD/shadcn"
echo "  Enable it in Godot: Project → Project Settings → Plugins → shadcn-godot."
