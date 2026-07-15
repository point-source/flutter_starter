#!/usr/bin/env bash
# Exercise deliberate template-sync paths for active REST and SDK adopters.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURES="$REPO_ROOT/test/fixtures/rest_adopter_migration"
ACTIVE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/flutter-starter-active-rest-XXXXXX")"
SDK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/flutter-starter-sdk-no-rest-XXXXXX")"
trap 'rm -rf "$ACTIVE_DIR" "$SDK_DIR"' EXIT

assert_migration_guidance() {
  local guide="$REPO_ROOT/docs/template/migrations/014-backend-neutral-networking.md"
  test -f "$guide"
  grep -q 'Runtime networking behavior warning' "$guide"
  grep -q 'Retain as project-owned' "$guide"
  grep -q 'Adopt the supported opt-in' "$guide"
  grep -q 'SDK or no backend' "$guide"
  grep -q '`API_URL`.*`REST_API_URL`' "$guide"
  grep -q 'authentication headers and token refresh' "$guide"
  grep -q 'interceptor order' "$guide"
  grep -q 'timeouts, error mapping, and logging' "$guide"
  grep -q 'TLS and certificate-pinning behavior' "$guide"
  grep -q 'backend provider binding' "$guide"
  grep -q 'project-owned after selection' \
    "$REPO_ROOT/docs/template/TEMPLATE_SYNC.md"
}

archive_to() {
  local destination="$1"
  git -C "$REPO_ROOT" archive HEAD | tar -x -C "$destination"
  git -C "$destination" init -q
  git -C "$destination" add -A
  git -C "$destination" \
    -c user.name='Migration Fixture' \
    -c user.email='fixture@example.invalid' \
    commit -qm 'fixture: record downstream baseline'
}

overlay_fixture() {
  local fixture="$1"
  local destination="$2"
  cp -R "$fixture"/. "$destination"/
  while IFS= read -r -d '' source; do
    mv "$source" "${source%.fixture}"
  done < <(find "$destination" -type f -name '*.fixture' -print0)
}

add_legacy_metadata() {
  local project="$1"
  sed -i '/  # Connectivity/i\
  # Project-owned legacy REST stack\
  dio: ^5.7.0\
  retrofit: ^4.9.2\
' "$project/pubspec.yaml"
  sed -i '/  dart_mappable_builder:/i\
  retrofit_generator: ^10.2.1' "$project/pubspec.yaml"
  sed -i '/      # dart_mappable code generation/i\
      # Project-owned Retrofit generation\
      retrofit_generator:\
        enabled: true\
        generate_for:\
          include:\
            - lib/features/**/data/services/**\
' "$project/build.yaml"

  local environment url file
  for environment in development staging production; do
    case "$environment" in
      development) url='http://localhost:3000' ;;
      staging) url='https://api-staging.example.com' ;;
      production) url='https://api.example.com' ;;
    esac
    file="$project/config/examples/$environment.json"
    sed -i "/\"SENTRY_DSN\"/i\  \"API_URL\": \"$url\"," "$file"
  done
}

apply_active_rest_sync() {
  local project="$1"
  local choice="${2:-}"
  if [[ "$choice" != retain && "$choice" != adopt ]]; then
    echo 'Active REST detected: choose retain or adopt before syncing.' >&2
    return 2
  fi
  if [[ "$choice" == adopt ]]; then
    echo 'The adopt path is exercised by scripts/check-rest-opt-in.sh.' >&2
    return 0
  fi

  overlay_fixture "$FIXTURES/active_rest" "$project"
  add_legacy_metadata "$project"
}

assert_active_rest_complete() {
  local project="$1"
  test -f "$project/lib/core/http/legacy_rest_client.dart"
  test -f "$project/lib/features/legacy_probe/data/services/legacy_probe_service.dart"
  grep -q '^  dio:' "$project/pubspec.yaml"
  grep -q '^  retrofit:' "$project/pubspec.yaml"
  grep -q '^  retrofit_generator:' "$project/pubspec.yaml"
  grep -q '^      retrofit_generator:' "$project/build.yaml"
  grep -q '"API_URL"' "$project/config/examples/development.json"
}

assert_sdk_stays_rest_free() {
  local project="$1"
  test -f \
    "$project/lib/features/sdk_probe/data/repositories/sdk_probe_repository.dart"
  test ! -d "$project/lib/core/http"
  test ! -e "$project/.flutter_starter/capabilities/dio_rest.json"
  if grep -Eq '^  (dio|retrofit|retrofit_generator):' \
    "$project/pubspec.yaml"; then
    echo 'SDK fixture regained a REST dependency.' >&2
    return 1
  fi
  if grep -q '^      retrofit_generator:' "$project/build.yaml"; then
    echo 'SDK fixture regained Retrofit generation.' >&2
    return 1
  fi
  if grep -R -E -q \
    '"(API_URL|REST_API_URL|ENABLE_SSL_PINNING)"|sslPinningEnabled' \
    "$project/config" "$project/lib"; then
    echo 'SDK fixture regained REST URL or SSL-toggle configuration.' >&2
    return 1
  fi
}

run_project_checks() {
  local project="$1"
  shift
  (
    cd "$project"
    ./scripts/setup.sh
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    dart format --output=none --set-exit-if-changed --line-length=80 lib test
    dart analyze --fatal-warnings
    # Generated sources remain under lib/. The brick copies and build caches are
    # not test inputs, so release them before Flutter compiles the fixture.
    rm -rf bricks build .dart_tool/build
    flutter test --concurrency=1 "$@"
    flutter build bundle --debug \
      --dart-define-from-file=config/development.json
  )
}

assert_migration_guidance

archive_to "$ACTIVE_DIR"
if apply_active_rest_sync "$ACTIVE_DIR" 2>/dev/null; then
  echo 'Active REST sync unexpectedly accepted an implicit choice.' >&2
  exit 1
fi
apply_active_rest_sync "$ACTIVE_DIR" retain
assert_active_rest_complete "$ACTIVE_DIR"
run_project_checks \
  "$ACTIVE_DIR" \
  test/core/http/legacy_rest_client_test.dart

rm -rf "$ACTIVE_DIR"

archive_to "$SDK_DIR"
overlay_fixture "$FIXTURES/sdk_no_rest" "$SDK_DIR"
assert_sdk_stays_rest_free "$SDK_DIR"
run_project_checks \
  "$SDK_DIR" \
  test/features/sdk_probe/data/repositories/sdk_probe_repository_test.dart
assert_sdk_stays_rest_free "$SDK_DIR"

echo 'REST adopter migration checks passed.'
