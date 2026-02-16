#!/usr/bin/env bash
# Runs the same checks as the GitHub Actions CI workflow locally.
# Use this before committing to catch failures early and avoid wasting CI compute.
#
# By default, formatting and codegen are applied and staged automatically.
# The script only fails if analysis errors or test failures remain.
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
      # Stage any formatting changes so they're included in the commit.
      # shellcheck disable=SC2086
      git add $dart_files
      pass "Formatting applied (staged)"
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

  if [ "$CHECK_ONLY" = true ]; then
    step "Verify generated files are up to date"
    if git diff --exit-code -- "${diff_args[@]}"; then
      pass "Generated files are up to date"
    else
      fail "Generated files are out of date."
      return 1
    fi
  else
    # Stage any regenerated files so they're included in the commit.
    if ! git diff --quiet -- "${diff_args[@]}"; then
      echo ""
      echo -e "${YELLOW}Generated files were out of date — staging updates:${NC}"
      git diff --name-only -- "${diff_args[@]}"
      git add -- $(git diff --name-only -- "${diff_args[@]}")
      pass "Generated files updated (staged)"
    else
      pass "Generated files are up to date"
    fi
  fi
}

# ── Main ────────────────────────────────────────────────────────────────────

main() {
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
