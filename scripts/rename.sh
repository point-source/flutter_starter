#!/usr/bin/env bash
# Renames the flutter_starter template to a new project name.
# Run this once after cloning the template to set up your project.
#
# Usage:
#   ./scripts/rename.sh [--dry-run] <package_name> <org_identifier> <display_name>
#   ./scripts/rename.sh [--dry-run]   (interactive prompts for any missing values)
#   ./scripts/rename.sh -h | --help
#
# Parameters:
#   package_name     snake_case package name  (e.g. my_awesome_app)
#   org_identifier   reverse-domain prefix    (e.g. com.mycompany)
#   display_name     human-readable app name  (e.g. "My Awesome App")
#
# Flags:
#   --dry-run  Show what would change without modifying any files
#   -h/--help  Show this help

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Resolve to repo root regardless of where the script is invoked from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DRY_RUN=false
CHANGE_COUNT=0

# Inputs (set in main after arg parsing / prompting)
PKG_NAME=""
ORG_ID=""
DISPLAY_NAME=""

# Derived values (set in compute_derived)
PKG_CAMEL=""
ANDROID_ID=""
BUNDLE_ID=""
ORG_PATH=""
KOTLIN_OLD_PATH=""
KOTLIN_NEW_PATH=""

# ── Helpers ───────────────────────────────────────────────────────────────────

usage() {
  sed -n '/^# Usage:/,/^[^#]/p' "$0" | grep '^#' | sed 's/^# //' | sed 's/^#//'
  exit 0
}

step()  { echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"; }
pass()  { echo -e "${GREEN}✓ $1${NC}"; }
fail()  { echo -e "${RED}✗ $1${NC}"; }
warn()  { echo -e "${YELLOW}⚠  $1${NC}"; }
info()  { echo -e "  $1"; }

# Cross-platform sed -i wrapper (macOS requires an empty-string backup suffix).
sed_i() {
  if [[ "$OSTYPE" == darwin* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# Convert snake_case to camelCase (pure bash — no GNU sed \U needed).
snake_to_camel() {
  local input="$1"
  local result=""
  local first=true
  local IFS='_'
  for word in $input; do
    if $first; then
      result="$word"
      first=false
    else
      local cap
      cap="$(printf '%s' "${word:0:1}" | tr '[:lower:]' '[:upper:]')${word:1}"
      result="${result}${cap}"
    fi
  done
  echo "$result"
}

# do_replace FILE GREP_PATTERN SED_REPLACEMENT
# Only modifies FILE when GREP_PATTERN matches; prints status; respects DRY_RUN.
# Uses '|' as the sed delimiter — patterns/replacements must not contain '|'.
do_replace() {
  local file="$1"
  local pattern="$2"
  local replacement="$3"

  [[ -f "$file" ]] || return 0

  if grep -q "$pattern" "$file" 2>/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[dry-run] would update: $file"
    else
      sed_i "s|$pattern|$replacement|g" "$file"
      pass "Updated: $file"
    fi
    CHANGE_COUNT=$((CHANGE_COUNT + 1))
  fi
}

# ── Safety Checks ─────────────────────────────────────────────────────────────

check_safety() {
  step "Safety checks"

  # Block execution when this is the canonical template repo itself.
  local dir_name remote_url
  dir_name="$(basename "$REPO_ROOT")"
  remote_url="$(git remote get-url origin 2>/dev/null || echo '')"

  if [[ "$dir_name" == "flutter_starter" ]] \
      && echo "$remote_url" | grep -qi "point-source/flutter_starter"; then
    fail "This is the canonical flutter_starter template repository."
    echo ""
    echo "  This script is for derived projects (clones/forks), not the template itself."
    echo "  Rename is blocked when the directory is named 'flutter_starter' AND"
    echo "  the git origin points to point-source/flutter_starter."
    echo ""
    echo "  To rename the template itself, first rename the directory or change the"
    echo "  git remote, then re-run this script."
    exit 1
  fi
  pass "Repository is not the canonical template"

  # Warn on uncommitted changes.
  local dirty
  dirty="$(git status --porcelain 2>/dev/null || echo '')"
  if [[ -n "$dirty" ]]; then
    warn "Uncommitted changes detected."
    if [[ "$DRY_RUN" == false ]]; then
      echo ""
      echo "  Commit or stash changes first so the rename diff is easy to review."
      echo ""
      read -r -p "  Continue anyway? [y/N] " confirm
      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
      fi
    fi
  else
    pass "Working tree is clean"
  fi

  # Warn if the pubspec already has a non-template name (idempotency hint).
  local current_name
  current_name="$(grep '^name:' "$REPO_ROOT/pubspec.yaml" | awk '{print $2}')"
  if [[ "$current_name" != "flutter_starter" ]]; then
    warn "pubspec.yaml name is already '$current_name' (not 'flutter_starter')."
    warn "Re-running may be a no-op for most replacements."
  else
    pass "pubspec.yaml name is 'flutter_starter' — ready to rename"
  fi
}

# ── Input Validation ──────────────────────────────────────────────────────────

validate_inputs() {
  step "Validating inputs"

  if [[ ! "$PKG_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    fail "Invalid package name: '$PKG_NAME'"
    echo "  Must match: ^[a-z][a-z0-9_]*\$   (e.g. my_awesome_app)"
    exit 1
  fi
  pass "Package name:   $PKG_NAME"

  if [[ ! "$ORG_ID" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$ ]]; then
    fail "Invalid org identifier: '$ORG_ID'"
    echo "  Must match: ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+\$   (e.g. com.mycompany)"
    exit 1
  fi
  pass "Org identifier: $ORG_ID"

  if [[ -z "$DISPLAY_NAME" ]]; then
    fail "Display name must not be empty."
    exit 1
  fi
  pass "Display name:   $DISPLAY_NAME"
}

# ── Derived Values ────────────────────────────────────────────────────────────

compute_derived() {
  step "Derived values"

  PKG_CAMEL="$(snake_to_camel "$PKG_NAME")"
  ANDROID_ID="${ORG_ID}.${PKG_NAME}"
  BUNDLE_ID="${ORG_ID}.${PKG_CAMEL}"
  ORG_PATH="${ORG_ID//.//}"   # e.g. com.mycompany → com/mycompany
  KOTLIN_OLD_PATH="android/app/src/main/kotlin/com/pointsource/flutter_starter"
  KOTLIN_NEW_PATH="android/app/src/main/kotlin/${ORG_PATH}/${PKG_NAME}"

  info "camelCase name:  $PKG_CAMEL"
  info "Android ID:      $ANDROID_ID"
  info "Bundle ID:       $BUNDLE_ID"
  info "Kotlin path:     $KOTLIN_NEW_PATH"
}

# ── Rename Operations ─────────────────────────────────────────────────────────

rename_pubspec() {
  step "pubspec.yaml"
  do_replace "pubspec.yaml" "^name: flutter_starter$" "name: ${PKG_NAME}"
}

rename_dart_imports() {
  step "Dart imports (lib/ and test/)"
  while IFS= read -r -d '' f; do
    do_replace "$f" "package:flutter_starter/" "package:${PKG_NAME}/"
  done < <(find lib test -name '*.dart' \
    ! -name '*.g.dart' \
    ! -name '*.gr.dart' \
    ! -name '*.mapper.dart' \
    ! -path 'lib/gen/*' \
    -print0 2>/dev/null || true)
}

rename_brick_imports() {
  step "Dart imports (bricks/)"
  local found=false
  while IFS= read -r -d '' f; do
    found=true
    do_replace "$f" "package:flutter_starter/" "package:${PKG_NAME}/"
  done < <(find bricks -name '*.dart' -print0 2>/dev/null || true)
  if [[ "$found" == false ]]; then
    info "No bricks/ Dart files found — skipping"
  fi
}

rename_android() {
  step "Android"

  # build.gradle.kts: namespace + applicationId
  do_replace "android/app/build.gradle.kts" \
    "com\.pointsource\.flutter_starter" "$ANDROID_ID"

  # AndroidManifest.xml: app label
  do_replace "android/app/src/main/AndroidManifest.xml" \
    'android:label="flutter_starter"' \
    "android:label=\"${DISPLAY_NAME}\""

  # fastlane/Appfile: fallback package_name
  do_replace "android/fastlane/Appfile" \
    "com\.pointsource\.flutter_starter" "$ANDROID_ID"

  # fastlane/.env.default: PACKAGE_NAME variable
  do_replace "android/fastlane/.env.default" \
    "^PACKAGE_NAME=.*" "PACKAGE_NAME=${ANDROID_ID}"

  # Move Kotlin source files to new package path.
  if [[ -d "$KOTLIN_OLD_PATH" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[dry-run] would move: $KOTLIN_OLD_PATH"
      info "                   → $KOTLIN_NEW_PATH"
      CHANGE_COUNT=$((CHANGE_COUNT + 1))
    else
      mkdir -p "$KOTLIN_NEW_PATH"
      while IFS= read -r -d '' kt; do
        mv "$kt" "$KOTLIN_NEW_PATH/"
        pass "Moved: $(basename "$kt") → $KOTLIN_NEW_PATH/"
      done < <(find "$KOTLIN_OLD_PATH" -name '*.kt' -print0 2>/dev/null || true)
      # Remove now-empty old directories bottom-up.
      local old_org="android/app/src/main/kotlin/com/pointsource"
      rmdir "$KOTLIN_OLD_PATH"    2>/dev/null || true
      rmdir "$old_org"            2>/dev/null || true
      rmdir "android/app/src/main/kotlin/com" 2>/dev/null || true
    fi
  fi

  # Update package declaration in MainActivity.kt (works whether or not moved).
  local kt_file=""
  if [[ -f "$KOTLIN_NEW_PATH/MainActivity.kt" ]]; then
    kt_file="$KOTLIN_NEW_PATH/MainActivity.kt"
  elif [[ -f "$KOTLIN_OLD_PATH/MainActivity.kt" ]]; then
    kt_file="$KOTLIN_OLD_PATH/MainActivity.kt"
  fi
  if [[ -n "$kt_file" ]]; then
    do_replace "$kt_file" \
      "^package com\.pointsource\.flutter_starter$" \
      "package ${ANDROID_ID}"
  fi
}

rename_ios() {
  step "iOS"

  local plist="ios/Runner/Info.plist"
  # CFBundleDisplayName: human-readable title
  do_replace "$plist" \
    "<string>Flutter Starter</string>" \
    "<string>${DISPLAY_NAME}</string>"
  # CFBundleName: short technical name
  do_replace "$plist" \
    "<string>flutter_starter</string>" \
    "<string>${PKG_NAME}</string>"

  local pbxproj="ios/Runner.xcodeproj/project.pbxproj"
  # RunnerTests bundle ID first (longer, more-specific match)
  do_replace "$pbxproj" \
    "com\.pointsource\.flutterStarter\.RunnerTests" \
    "${BUNDLE_ID}.RunnerTests"
  # Base bundle ID
  do_replace "$pbxproj" \
    "com\.pointsource\.flutterStarter" \
    "$BUNDLE_ID"

  # fastlane/.env.default: APP_IDENTIFIER variable
  do_replace "ios/fastlane/.env.default" \
    "^APP_IDENTIFIER=.*" "APP_IDENTIFIER=${BUNDLE_ID}"
}

rename_macos() {
  step "macOS"

  local xcconfig="macos/Runner/Configs/AppInfo.xcconfig"
  do_replace "$xcconfig" \
    "^PRODUCT_NAME = flutter_starter$" \
    "PRODUCT_NAME = ${DISPLAY_NAME}"
  do_replace "$xcconfig" \
    "^PRODUCT_BUNDLE_IDENTIFIER = com\.pointsource\.flutterStarter$" \
    "PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID}"
  # Copyright line: update org prefix only
  do_replace "$xcconfig" \
    "com\.pointsource\." \
    "${ORG_ID}."

  local pbxproj="macos/Runner.xcodeproj/project.pbxproj"
  # RunnerTests bundle IDs first (longer match)
  do_replace "$pbxproj" \
    "com\.pointsource\.flutterStarter\.RunnerTests" \
    "${BUNDLE_ID}.RunnerTests"
  # Base bundle ID
  do_replace "$pbxproj" \
    "com\.pointsource\.flutterStarter" \
    "$BUNDLE_ID"
  # .app references in comments and paths (e.g. /* flutter_starter.app */)
  do_replace "$pbxproj" \
    "flutter_starter\.app" \
    "${PKG_NAME}.app"
  # Trailing executable name in TEST_HOST paths (e.g. .../flutter_starter")
  do_replace "$pbxproj" \
    "BUNDLE_EXECUTABLE_FOLDER_PATH)/flutter_starter\"" \
    "BUNDLE_EXECUTABLE_FOLDER_PATH)/${PKG_NAME}\""

  local xcscheme="macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme"
  do_replace "$xcscheme" \
    "BuildableName = \"flutter_starter\.app\"" \
    "BuildableName = \"${PKG_NAME}.app\""
}

rename_web() {
  step "Web"

  local manifest="web/manifest.json"
  do_replace "$manifest" \
    '"name": "flutter_starter"' \
    "\"name\": \"${DISPLAY_NAME}\""
  do_replace "$manifest" \
    '"short_name": "flutter_starter"' \
    "\"short_name\": \"${PKG_NAME}\""

  local index="web/index.html"
  do_replace "$index" \
    'content="flutter_starter"' \
    "content=\"${DISPLAY_NAME}\""
  do_replace "$index" \
    '<title>flutter_starter</title>' \
    "<title>${DISPLAY_NAME}</title>"
}

rename_docs() {
  step "CLAUDE.md"

  # Line: "working in the `flutter_starter` codebase."
  do_replace "CLAUDE.md" \
    "working in the \`flutter_starter\` codebase\." \
    "working in the \`${PKG_NAME}\` codebase."

  # Line: "- Package imports: \`package:flutter_starter/...\`"
  do_replace "CLAUDE.md" \
    "package:flutter_starter/" \
    "package:${PKG_NAME}/"
}

# ── License File ──────────────────────────────────────────────────────────────

# Detect the unmodified template LICENSE.md and prompt the user to handle it.
# Derived projects should replace or remove the template's license rather than
# silently inheriting attribution to the template's copyright holder.
handle_template_license() {
  step "LICENSE.md"

  local license_file="$REPO_ROOT/LICENSE.md"

  if [[ ! -f "$license_file" ]]; then
    info "No LICENSE.md found — skipping"
    return 0
  fi

  # Fingerprint the unacknowledged template license by an HTML comment
  # sentinel embedded in LICENSE.md. The sentinel is invisible in rendered
  # markdown and is stripped on "keep", so the user is never re-prompted
  # after they've made an intentional choice. This works correctly even when
  # the template author re-uses the template and keeps BSD-3-Clause as-is.
  local sentinel="TEMPLATE LICENSE FILE - flutter_starter"
  if ! grep -qF "$sentinel" "$license_file" 2>/dev/null; then
    pass "LICENSE.md has no template sentinel — already acknowledged"
    return 0
  fi

  warn "The template's LICENSE.md (BSD-3-Clause, copyright point-source) is still in place."
  echo ""
  echo "  Derived projects should replace this with their own license to avoid"
  echo "  inheriting attribution to the template's copyright holder."
  echo ""

  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would prompt to (d)elete / (k)eep / (s)kip"
    CHANGE_COUNT=$((CHANGE_COUNT + 1))
    return 0
  fi

  echo "  Options:"
  echo "    d) Delete LICENSE.md now (add your own license file later)"
  echo "    k) Keep the template license (BSD-3-Clause; you must comply with its terms)"
  echo "    s) Skip — decide later (you'll be re-prompted on next rename.sh run)"
  echo ""
  read -r -p "  Choice [d/k/s]: " license_choice

  case "$license_choice" in
    d|D)
      rm -f "$license_file"
      pass "Deleted LICENSE.md — remember to add your project's license"
      CHANGE_COUNT=$((CHANGE_COUNT + 1))
      ;;
    k|K)
      # Strip the sentinel line so future runs treat the file as acknowledged.
      # The actual license text is left untouched.
      sed_i "/${sentinel}/d" "$license_file"
      pass "Kept template LICENSE.md (BSD-3-Clause); sentinel removed"
      CHANGE_COUNT=$((CHANGE_COUNT + 1))
      ;;
    *)
      warn "LICENSE.md left unchanged — review before publishing your project"
      ;;
  esac
}

# ── Post-Rename Cleanup ───────────────────────────────────────────────────────

cleanup_generated() {
  step "Cleanup generated files"

  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would delete: *.g.dart, *.gr.dart, *.mapper.dart, lib/gen/"
    return 0
  fi

  local deleted=0
  while IFS= read -r -d '' f; do
    rm -f "$f"
    deleted=$((deleted + 1))
  done < <(find lib test \
    \( -name '*.g.dart' -o -name '*.gr.dart' -o -name '*.mapper.dart' \) \
    -print0 2>/dev/null || true)

  if [[ -d "lib/gen" ]]; then
    rm -rf "lib/gen"
    deleted=$((deleted + 1))
  fi

  if [[ $deleted -gt 0 ]]; then
    pass "Deleted $deleted generated file(s) — run codegen before building"
  else
    pass "No generated files found to delete"
  fi
}

# ── Summary ───────────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  if [[ "$DRY_RUN" == true ]]; then
    echo -e "${CYAN}━━━ Dry run complete ━━━${NC}"
    echo ""
    echo "  $CHANGE_COUNT change(s) would be applied."
    echo ""
    echo "  Run without --dry-run to apply."
  else
    echo -e "${GREEN}━━━ Rename complete ━━━${NC}"
    echo ""
    echo "  $CHANGE_COUNT change(s) applied."
    echo ""
    echo "  Next steps:"
    echo "    1. Regenerate code:"
    echo "       dart run build_runner build --delete-conflicting-outputs && dart run slang"
    echo "    2. Verify the app builds:"
    echo "       flutter run --dart-define-from-file=config/development.json"
    echo "    3. Commit the rename:"
    echo "       git add -A && git commit -m \"Rename project to ${PKG_NAME}\""
  fi
  echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
  local positional=()

  for arg in "$@"; do
    case "$arg" in
      --dry-run)  DRY_RUN=true ;;
      -h|--help)  usage ;;
      -*)
        echo -e "${RED}Unknown flag: $arg${NC}"
        echo "Run with --help for usage."
        exit 1
        ;;
      *) positional+=("$arg") ;;
    esac
  done

  # Assign positional args.
  [[ ${#positional[@]} -ge 1 ]] && PKG_NAME="${positional[0]}"
  [[ ${#positional[@]} -ge 2 ]] && ORG_ID="${positional[1]}"
  [[ ${#positional[@]} -ge 3 ]] && DISPLAY_NAME="${positional[2]}"

  # Interactive prompts for any missing values.
  [[ -z "$PKG_NAME"     ]] && read -r -p "Package name (snake_case, e.g. my_awesome_app): " PKG_NAME
  [[ -z "$ORG_ID"       ]] && read -r -p "Org identifier (reverse domain, e.g. com.mycompany): " ORG_ID
  [[ -z "$DISPLAY_NAME" ]] && read -r -p "Display name (e.g. My Awesome App): " DISPLAY_NAME

  echo ""
  [[ "$DRY_RUN" == true ]] && echo -e "${YELLOW}DRY RUN MODE — no files will be modified${NC}\n"

  echo "  Package name:   $PKG_NAME"
  echo "  Org identifier: $ORG_ID"
  echo "  Display name:   $DISPLAY_NAME"

  check_safety
  validate_inputs
  compute_derived

  rename_pubspec
  rename_dart_imports
  rename_brick_imports
  rename_android
  rename_ios
  rename_macos
  rename_web
  rename_docs
  handle_template_license

  [[ "$DRY_RUN" == false ]] && cleanup_generated

  print_summary
}

main "$@"
