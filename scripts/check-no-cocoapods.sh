#!/usr/bin/env bash
# Static anti-regression check: fail if any CocoaPods artifact reappears
# under ios/ or macos/.
#
# Apple builds resolve native plugins exclusively through Swift Package Manager
# (see docs SPEC §spec:spm-only-integration). CocoaPods has been fully removed.
# This check asserts the *absence* of CocoaPods artifacts directly, independent
# of what the CI runner has installed -- GitHub's macos-latest runners ship
# CocoaPods pre-installed, so a re-added Podfile could still build green and slip
# through a build-only guard. This closes that gap.
#
# It inspects the filesystem only (no toolchain required), so it runs on a cheap
# ubuntu-latest CI job.
#
# Usage:
#   ./scripts/check-no-cocoapods.sh    # Exit 0 if clean, non-zero on any artifact
#
# Fails (listing every offender) if any of these exist under ios/ or macos/:
#   1. a Podfile
#   2. a Podfile.lock
#   3. a Pods/ directory
#   4. a Pods.xcodeproj reference inside a *.xcworkspace/contents.xcworkspacedata
#   5. a Pods-Runner *.xcconfig #include inside a Flutter/*.xcconfig

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Resolve to repo root regardless of where the script is invoked from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Apple target directories to inspect. Missing directories are skipped.
APPLE_DIRS=()
for dir in ios macos; do
  [ -d "$dir" ] && APPLE_DIRS+=("$dir")
done

violations=()

# Record a violation with a clear, artifact-specific message.
violation() {
  violations+=("$1")
}

if [ "${#APPLE_DIRS[@]}" -gt 0 ]; then
  # 1 & 2: Podfile / Podfile.lock anywhere under the Apple targets.
  while IFS= read -r match; do
    [ -n "$match" ] && violation "CocoaPods Podfile present: $match"
  done < <(find "${APPLE_DIRS[@]}" -type f -name 'Podfile' 2>/dev/null)

  while IFS= read -r match; do
    [ -n "$match" ] && violation "CocoaPods lockfile present: $match"
  done < <(find "${APPLE_DIRS[@]}" -type f -name 'Podfile.lock' 2>/dev/null)

  # 3: Pods/ directory (installed pods scaffolding).
  while IFS= read -r match; do
    [ -n "$match" ] && violation "CocoaPods Pods/ directory present: $match"
  done < <(find "${APPLE_DIRS[@]}" -type d -name 'Pods' 2>/dev/null)

  # 4: Pods.xcodeproj reference inside a workspace definition.
  while IFS= read -r match; do
    [ -n "$match" ] || continue
    if grep -q 'Pods\.xcodeproj' "$match" 2>/dev/null; then
      violation "Pods.xcodeproj referenced in workspace: $match"
    fi
  done < <(find "${APPLE_DIRS[@]}" -type f -path '*.xcworkspace/contents.xcworkspacedata' 2>/dev/null)

  # 5: Pods-Runner xcconfig #include inside a Flutter/*.xcconfig.
  # Matches both `#include` and the optional `#include?` form.
  while IFS= read -r match; do
    [ -n "$match" ] || continue
    if grep -Eq '#include\??[[:space:]]+"[^"]*Pods-Runner[^"]*\.xcconfig"' "$match" 2>/dev/null; then
      violation "Pods-Runner xcconfig include present: $match"
    fi
  done < <(find "${APPLE_DIRS[@]}" -type f -path '*/Flutter/*.xcconfig' 2>/dev/null)
fi

if [ "${#violations[@]}" -gt 0 ]; then
  echo -e "${RED}✗ CocoaPods artifacts detected — Apple targets must stay CocoaPods-free (SPM only).${NC}"
  for v in "${violations[@]}"; do
    echo -e "${RED}  • ${v}${NC}"
  done
  echo
  echo "Remove the artifact(s) above. Apple plugins resolve through Swift Package"
  echo "Manager; no Podfile, Pods/ scaffolding, or Pods-Runner include is needed."
  exit 1
fi

echo -e "${GREEN}✓ No CocoaPods artifacts found under ios/ or macos/.${NC}"
