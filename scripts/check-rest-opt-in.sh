#!/usr/bin/env bash
# Exercise the supported REST opt-in against clean neutral starter copies.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v mason >/dev/null 2>&1; then
  echo "mason is required: dart pub global activate mason_cli" >&2
  exit 1
fi

gate_dir="$(mktemp -d "${TMPDIR:-/tmp}/flutter-starter-rest-gate-XXXXXX")"
opt_in_dir="$(mktemp -d "${TMPDIR:-/tmp}/flutter-starter-rest-opt-in-XXXXXX")"
trap 'rm -rf "$gate_dir" "$opt_in_dir"' EXIT

archive_to() {
  local destination="$1"
  git -C "$REPO_ROOT" archive HEAD | tar -x -C "$destination"
}

archive_to "$gate_dir"
(
  cd "$gate_dir"
  mason get
  set +e
  mason make feature --feature_name premature --dio true >gate.log 2>&1
  status=$?
  set -e
  if [[ "$status" -eq 0 ]]; then
    echo "Premature REST generation unexpectedly succeeded." >&2
    exit 1
  fi
  grep -q 'mason make dio_rest' gate.log
  if [[ -e lib/features/premature || -e test/features/premature ]]; then
    echo "Premature REST generation left partial output." >&2
    exit 1
  fi
)
# The gate fixture is no longer needed. Release it before code generation and
# Flutter compilation in the opted-in fixture to keep peak temporary disk usage
# bounded on CI runners.
rm -rf "$gate_dir"

archive_to "$opt_in_dir"
(
  cd "$opt_in_dir"
  mason get
  mason make dio_rest
  mason make feature --feature_name rest_probe --dio true

  grep -q '^  dio:' pubspec.yaml
  grep -q '^  retrofit:' pubspec.yaml
  grep -q '^  retrofit_generator:' pubspec.yaml
  grep -q '^      retrofit_generator:' build.yaml
  grep -q '"REST_API_URL"' config/examples/development.json
  test -f .flutter_starter/capabilities/dio_rest.json
  grep -q 'REST is one repository implementation alongside mocks' \
    docs/project/REST_DIO.md
  grep -q 'same public `Result<T>` contract' docs/project/REST_DIO.md

  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  dart format --output=none --set-exit-if-changed --line-length=80 lib test
  dart analyze --fatal-warnings
  # Generation is complete. The copied bricks and build caches are not test
  # inputs, so release them before Flutter creates compiler output.
  rm -rf bricks build .dart_tool/build
  flutter test \
    test/core/http \
    test/features/rest_probe/data/repositories/rest_probe_repository_test.dart \
    test/features/rest_probe/ui/pages/rest_probe_page_test.dart
)

if grep -Eq '^  (dio|retrofit):' "$REPO_ROOT/pubspec.yaml"; then
  echo "The neutral starter unexpectedly depends on Dio or Retrofit." >&2
  exit 1
fi
if grep -q '^      retrofit_generator:' "$REPO_ROOT/build.yaml"; then
  echo "The neutral starter unexpectedly enables Retrofit generation." >&2
  exit 1
fi
if grep -q '"REST_API_URL"' "$REPO_ROOT"/config/examples/*.json; then
  echo "The neutral starter unexpectedly requires REST_API_URL." >&2
  exit 1
fi
if [[ -d "$REPO_ROOT/lib/core/http" ]]; then
  echo "The neutral starter unexpectedly contains shared HTTP code." >&2
  exit 1
fi

base_guidance=(
  "$REPO_ROOT/docs/template/CLAUDE.md"
  "$REPO_ROOT/docs/template/ARCHITECTURE.md"
  "$REPO_ROOT/docs/template/architecture-rules"
)
if grep -R -E -q \
  'DioException -->|Always catch `DioException`|Dio Interceptor Chain \(core/http/\)|Dio infrastructure lives in `core/http/`|Provides the main \[Dio\] instance' \
  "${base_guidance[@]}"; then
  echo "Base guidance still presents Dio/Retrofit as current infrastructure." >&2
  exit 1
fi

echo "REST opt-in acceptance checks passed."
