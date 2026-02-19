#!/usr/bin/env bash
# Claude Code Stop hook: nudges the agent to consider whether a project
# decision doc should be created for significant changes.
#
# Only runs in project repos (NOT the template repo "flutter_starter").
# Non-blocking -- prints advisory feedback rather than halting the agent.

set -euo pipefail

INPUT=$(cat)

REPO_ROOT=$(echo "$INPUT" | jq -r '.cwd')

# Only run in project repos, not the template itself.
if [ "$(basename "$REPO_ROOT")" = "flutter_starter" ]; then
  exit 0
fi

cd "$REPO_ROOT"

# Check that docs/project-decisions/ exists (confirms this is a project
# derived from the template).
if [ ! -d "docs/project-decisions" ]; then
  exit 0
fi

# Gather modified/new files (staged + unstaged vs HEAD).
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || true)
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)
ALL_CHANGED=$(printf '%s\n%s' "$CHANGED_FILES" "$STAGED_FILES" | sort -u | grep -v '^$' || true)

if [ -z "$ALL_CHANGED" ]; then
  exit 0
fi

# If a project decision doc is already in the changeset, no nudge needed.
if echo "$ALL_CHANGED" | grep -qE '^docs/project-decisions/[0-9]'; then
  exit 0
fi

# Also check for untracked project decision docs.
UNTRACKED=$(git ls-files --others --exclude-standard -- 'docs/project-decisions/[0-9]*' 2>/dev/null || true)
if [ -n "$UNTRACKED" ]; then
  exit 0
fi

# Print non-blocking advisory to stderr so the agent sees it as feedback.
cat >&2 <<'MSG'
Reminder: consider whether this change warrants a project decision doc.
A project decision doc (docs/project-decisions/NNN-short-description.md) is
appropriate when the change involves:
  - Choosing a backend, third-party service, or significant new dependency
  - Establishing a domain modeling convention or business rule
  - Deviating from or extending template patterns
  - Picking a deployment, CI/CD, or testing strategy
  - Any significant technical decision specific to this project

See docs/project-decisions/README.md for format and numbering.
If this change doesn't rise to that level, no action needed.
MSG
