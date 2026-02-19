#!/usr/bin/env bash
# Claude Code Stop hook: checks whether template-significant files were modified
# without a corresponding migration doc. If so, blocks the agent and asks it to
# create one.
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

# Template-significant file patterns (paths that downstream projects care about).
TEMPLATE_PATTERNS=(
  '^CLAUDE\.md$'
  '^pubspec\.yaml$'
  '^analysis_options\.yaml$'
  '^docs/adrs/'
  '^docs/architecture-rules/'
  '^lib/core/'
  '^lib/features/auth/'
  '^scripts/'
  '^config/examples/'
  '^bricks/'
)

# Check uncommitted changes (staged + unstaged) for template-significant files.
cd "$REPO_ROOT"
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || true)
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)
ALL_CHANGED=$(printf '%s\n%s' "$CHANGED_FILES" "$STAGED_FILES" | sort -u | grep -v '^$' || true)

if [ -z "$ALL_CHANGED" ]; then
  exit 0
fi

# Check if any changed file matches a template-significant pattern.
HAS_TEMPLATE_CHANGE=false
for pattern in "${TEMPLATE_PATTERNS[@]}"; do
  if echo "$ALL_CHANGED" | grep -qE "$pattern"; then
    HAS_TEMPLATE_CHANGE=true
    break
  fi
done

if [ "$HAS_TEMPLATE_CHANGE" = false ]; then
  exit 0
fi

# Check if a migration doc is already in the changeset.
if echo "$ALL_CHANGED" | grep -qE '^docs/migrations/[0-9]'; then
  exit 0
fi

# Also check if one was already created but is untracked.
UNTRACKED_MIGRATIONS=$(git ls-files --others --exclude-standard -- 'docs/migrations/[0-9]*' 2>/dev/null || true)
if [ -n "$UNTRACKED_MIGRATIONS" ]; then
  exit 0
fi

# Block the agent and ask it to create a migration doc.
cat <<'EOF'
{
  "decision": "block",
  "reason": "Template-significant files were modified without a migration doc. Before finishing, create a migration doc at docs/migrations/NNN-short-description.md following the template in docs/migrations/_TEMPLATE.md. See docs/migrations/README.md for details on what to include."
}
EOF
