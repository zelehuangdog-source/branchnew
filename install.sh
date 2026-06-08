#!/usr/bin/env bash
#
# branchnew installer — copies ./branchnew into ~/.local/bin, makes it
# executable, and ensures ~/.local/bin is on your PATH.
#
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "branchnew is macOS-only (it drives iTerm2 / Apple Terminal via AppleScript)." >&2
  exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$HOME/.local/bin"
DEST="$DEST_DIR/branchnew"

mkdir -p "$DEST_DIR"
install -m 0755 "$SRC_DIR/branchnew" "$DEST"
echo "✓ installed: $DEST"

# Make sure ~/.local/bin is on PATH.
case ":$PATH:" in
  *":$DEST_DIR:"*)
    echo "✓ $DEST_DIR is already on PATH"
    ;;
  *)
    RC="$HOME/.zshrc"
    LINE='export PATH="$HOME/.local/bin:$PATH"'
    if ! grep -qsF "$LINE" "$RC" 2>/dev/null; then
      printf '\n# added by branchnew installer\n%s\n' "$LINE" >> "$RC"
      echo "✓ added $DEST_DIR to PATH in $RC"
    fi
    echo "  → open a new terminal (or run: source $RC) to pick it up"
    ;;
esac

# Friendly heads-up if the claude CLI isn't visible yet.
if ! command -v claude >/dev/null 2>&1; then
  echo "! note: 'claude' was not found on PATH — install Claude Code so branchnew has something to launch."
fi

echo
echo "Done. Try:  branchnew --help"
