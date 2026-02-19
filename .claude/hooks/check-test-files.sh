#!/usr/bin/env bash
# Claude Code Stop hook: checks whether modified/new .dart files under lib/
# are missing a corresponding _test.dart file under test/. If so, blocks the
# agent with a message to create the missing tests.
#
# Only runs in the template repo (folder named "flutter_starter").

set -euo pipefail

INPUT=$(cat)

# Avoid infinite loops -- if this hook already fired once this turn, let it go.
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

REPO_ROOT=$(echo "$INPUT" | jq -r '.cwd')

# Only run in the template repo itself.
if [ "$(basename "$REPO_ROOT")" != "flutter_starter" ]; then
  exit 0
fi

cd "$REPO_ROOT"

# Gather modified/new .dart files (staged + unstaged vs HEAD).
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || true)
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)
ALL_CHANGED=$(printf '%s\n%s' "$CHANGED_FILES" "$STAGED_FILES" | sort -u | grep -v '^$' || true)

if [ -z "$ALL_CHANGED" ]; then
  exit 0
fi

# Filter to only lib/ .dart files.
LIB_DART=$(echo "$ALL_CHANGED" | grep '^lib/.*\.dart$' || true)

if [ -z "$LIB_DART" ]; then
  exit 0
fi

# Skip patterns -- files that don't need unit tests.
SKIP_PATTERNS=(
  # Generated files
  '\.g\.dart$'
  '\.gr\.dart$'
  '\.mapper\.dart$'
  # Entry points
  '^lib/main\.dart$'
  '^lib/bootstrap\.dart$'
  '^lib/app\.dart$'
  # Generated translations
  '^lib/gen/'
  # Domain type definitions (pure data, tested via integration)
  '/domain/entities/'
  '/domain/failures/'
  '/domain/repositories/'
  # UI pages and widgets (widget test territory, not enforced here)
  '/ui/pages/'
  '/ui/widgets/'
  # Translation strings
  '/l10n/'
  # Theme, env, feature flags, presentation, logging (config/wiring)
  '^lib/core/theme/'
  '^lib/core/env/'
  '^lib/core/feature_flags/'
  '^lib/core/presentation/'
  '^lib/core/logging/'
)

MISSING=()

while IFS= read -r file; do
  [ -z "$file" ] && continue

  # Check if file matches any skip pattern.
  skip=false
  for pattern in "${SKIP_PATTERNS[@]}"; do
    if echo "$file" | grep -qE "$pattern"; then
      skip=true
      break
    fi
  done
  if [ "$skip" = true ]; then
    continue
  fi

  # Map lib/foo/bar.dart -> test/foo/bar_test.dart
  relative="${file#lib/}"
  test_file="test/${relative%.dart}_test.dart"

  if [ ! -f "$test_file" ]; then
    MISSING+=("$test_file")
  fi
done <<< "$LIB_DART"

if [ ${#MISSING[@]} -eq 0 ]; then
  exit 0
fi

# Build the list of missing test files for the block message.
MISSING_LIST=""
for f in "${MISSING[@]}"; do
  MISSING_LIST="${MISSING_LIST}  - ${f}\n"
done

cat <<EOF
{
  "decision": "block",
  "reason": "Modified lib/ files are missing corresponding test files. Create the following tests before finishing:\n${MISSING_LIST}Follow the existing test patterns in test/ (use mocktail, mirror the lib/ structure)."
}
EOF
