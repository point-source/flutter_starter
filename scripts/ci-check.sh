#!/usr/bin/env bash
# Runs the same checks as the GitHub Actions CI workflow locally.
# Use this before committing to catch failures early and avoid wasting CI compute.
#
# By default, formatting is applied and re-staged automatically (only files that
# were already staged are re-staged; unstaged files stay unstaged).
# If codegen produces changes, the commit is aborted so you can review the
# updated files and commit again. The script also fails on analysis errors
# or test failures.
#
# Usage:
#   ./scripts/ci-check.sh              # Run all checks (lint, test, codegen)
#   ./scripts/ci-check.sh lint         # Run only lint (analyze + format)
#   ./scripts/ci-check.sh test         # Run only tests
#   ./scripts/ci-check.sh codegen      # Run only codegen freshness check
#   ./scripts/ci-check.sh --check      # Check-only mode (no auto-fix, like CI)
#   ./scripts/ci-check.sh --coverage   # Run tests with coverage report
#   ./scripts/ci-check.sh --help       # Show this help

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Files that were staged before the hook ran. Populated in main().
STAGED_FILES=""

# Resolve to repo root regardless of where the script is invoked from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

CHECK_ONLY=false
COVERAGE=false

usage() {
  sed -n '/^# Usage:/,/^$/p' "$0" | sed 's/^# //' | sed 's/^#//'
  exit 0
}

step() {
  echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"
}

pass() {
  echo -e "${GREEN}✓ $1${NC}"
}

fail() {
  echo -e "${RED}✗ $1${NC}"
}

# Filter stdin (one file path per line) to only paths that were staged before
# the hook ran. Prints matching paths to stdout.
only_staged() {
  if [ -z "$STAGED_FILES" ]; then
    return 0
  fi
  grep -xF -f <(echo "$STAGED_FILES") || true
}

# ── Lint ────────────────────────────────────────────────────────────────────

run_lint() {
  # Mirrors CI: find all .dart files excluding generated code.
  local dart_files
  dart_files=$(find lib test -name '*.dart' \
    ! -name '*.g.dart' \
    ! -name '*.gr.dart' \
    ! -name '*.mapper.dart' \
    ! -path 'lib/gen/*' 2>/dev/null || true)

  # ── Format ──
  if [ -n "$dart_files" ]; then
    if [ "$CHECK_ONLY" = true ]; then
      step "Format check (dart format --line-length=80)"
      # shellcheck disable=SC2086
      if dart format --output=none --set-exit-if-changed --line-length=80 $dart_files; then
        pass "Formatting passed"
      else
        fail "Formatting failed"
        return 1
      fi
    else
      step "Format (dart format --line-length=80)"
      # shellcheck disable=SC2086
      dart format --line-length=80 $dart_files
      # Re-stage only files that were already staged before the hook ran.
      local to_stage
      to_stage=$(echo "$dart_files" | tr ' ' '\n' | only_staged)
      if [ -n "$to_stage" ]; then
        # shellcheck disable=SC2086
        git add $to_stage
        pass "Formatting applied (staged)"
      else
        pass "Formatting applied"
      fi
    fi
  fi

  # ── Analyze ──
  step "Analyze (dart analyze --fatal-warnings)"
  if dart analyze --fatal-warnings; then
    pass "Analysis passed"
  else
    fail "Analysis failed"
    return 1
  fi
}

# ── Test ────────────────────────────────────────────────────────────────────

run_test() {
  local flags=()
  if [ "$COVERAGE" = true ]; then
    flags+=(--coverage)
    step "Tests (flutter test --coverage)"
  else
    step "Tests (flutter test)"
  fi

  if flutter test ${flags[@]+"${flags[@]}"}; then
    pass "Tests passed"
  else
    fail "Tests failed"
    return 1
  fi
}

# ── Code Generation Freshness ──────────────────────────────────────────────

# Patterns that code generators produce. Only these are checked for staleness
# so that unrelated changes (e.g. pubspec.lock) don't cause false failures.
GENERATED_PATTERNS=('*.g.dart' '*.gr.dart' '*.mapper.dart' 'lib/gen/*')

run_codegen() {
  step "Code generation (build_runner + slang)"
  dart run build_runner build --delete-conflicting-outputs
  dart run slang

  # Build git diff args that scope to generated file patterns only.
  local diff_args=()
  for pattern in "${GENERATED_PATTERNS[@]}"; do
    diff_args+=("$pattern")
  done

  # Check whether codegen changed any generated files (staged or unstaged).
  local changed_generated
  changed_generated=$(git diff --name-only -- "${diff_args[@]}" || true)
  # Also check for newly created (untracked) generated files.
  local untracked_generated
  untracked_generated=$(git ls-files --others --exclude-standard -- "${diff_args[@]}" 2>/dev/null || true)
  # Combine both lists.
  local all_changed
  all_changed=$(printf '%s\n%s' "$changed_generated" "$untracked_generated" | sed '/^$/d' | sort -u)

  if [ -n "$all_changed" ]; then
    echo ""
    echo -e "${YELLOW}Generated files are out of date:${NC}"
    echo "$all_changed"
    if [ "$CHECK_ONLY" = true ]; then
      fail "Generated files are out of date — commit blocked."
    else
      echo ""
      echo -e "${YELLOW}The files above have been updated on disk.${NC}"
      echo -e "${YELLOW}Review the changes, stage them, and commit again.${NC}"
      fail "Generated files were stale — commit aborted so you can review."
    fi
    return 1
  else
    pass "Generated files are up to date"
  fi
}

# ── Main ────────────────────────────────────────────────────────────────────

main() {
  # Snapshot which files are staged now, so we only re-stage those after
  # formatting / codegen. Files that weren't staged stay unstaged.
  STAGED_FILES=$(git diff --cached --name-only --diff-filter=d 2>/dev/null || true)

  local targets=()

  for arg in "$@"; do
    case "$arg" in
      --check)    CHECK_ONLY=true ;;
      --coverage)  COVERAGE=true ;;
      -h|--help) usage ;;
      lint|test|codegen) targets+=("$arg") ;;
      *)
        echo -e "${RED}Unknown argument: $arg${NC}"
        echo "Valid targets: lint, test, codegen"
        echo "Flags: --check, --coverage, --help"
        exit 1
        ;;
    esac
  done

  # Default: run all checks.
  if [ ${#targets[@]} -eq 0 ]; then
    targets=(lint test codegen)
  fi

  local failed=0

  for target in "${targets[@]}"; do
    case "$target" in
      lint)    run_lint    || failed=1 ;;
      test)    run_test    || failed=1 ;;
      codegen) run_codegen || failed=1 ;;
    esac
  done

  echo ""
  if [ "$failed" -ne 0 ]; then
    echo -e "${RED}━━━ CI checks FAILED ━━━${NC}"
    exit 1
  else
    echo -e "${GREEN}━━━ All CI checks passed ━━━${NC}"
  fi
}

main "$@"
