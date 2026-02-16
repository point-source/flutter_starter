#!/usr/bin/env bash
# Provision environment config files from example templates.
#
# Usage:
#   ./scripts/setup.sh          # Copy all examples (skip existing)
#   ./scripts/setup.sh --force  # Overwrite existing config files
#
# This script copies every config/examples/*.json to config/*.json.
# Existing files are preserved unless --force is passed, so local
# customizations (credentials, URLs) are never accidentally overwritten.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"
EXAMPLES_DIR="$CONFIG_DIR/examples"
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--force]" >&2
      exit 1
      ;;
  esac
done

copied=0
skipped=0

for example in "$EXAMPLES_DIR"/*.json; do
  name="$(basename "$example")"
  target="$CONFIG_DIR/$name"

  if [[ -f "$target" && "$FORCE" == false ]]; then
    echo "  skip  config/$name (already exists)"
    skipped=$((skipped + 1))
  else
    cp "$example" "$target"
    echo "  create config/$name"
    copied=$((copied + 1))
  fi
done

echo ""
echo "Done. $copied file(s) created, $skipped file(s) skipped."
if [[ $skipped -gt 0 && "$FORCE" == false ]]; then
  echo "Run with --force to overwrite existing files."
fi

# ── Git hooks ───────────────────────────────────────────────────────────────
# Point git to the checked-in .githooks directory so the pre-commit hook is
# active for every developer without manual setup.
REPO_ROOT="$SCRIPT_DIR/.."
current_hooks_path="$(git -C "$REPO_ROOT" config --local core.hooksPath 2>/dev/null || true)"
if [[ "$current_hooks_path" != ".githooks" ]]; then
  git -C "$REPO_ROOT" config --local core.hooksPath .githooks
  echo ""
  echo "Git hooks path set to .githooks (pre-commit CI checks enabled)."
else
  echo ""
  echo "Git hooks path already configured."
fi
