#!/usr/bin/env bash
# Validate that Fastlane deployment is properly configured.
#
# This script checks environment variables, config files, and signing
# setup WITHOUT requiring Ruby or Fastlane to be installed.
#
# Usage:
#   ./scripts/preflight.sh          # Check both platforms
#   ./scripts/preflight.sh ios      # Check iOS only
#   ./scripts/preflight.sh android  # Check Android only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

FAILURES=0

pass() {
  printf "${GREEN}  OK    %s${RESET}\n" "$1"
}

fail() {
  printf "${RED}  FAIL  %s${RESET}\n" "$1"
  FAILURES=$((FAILURES + 1))
}

warn() {
  printf "${YELLOW}  WARN  %s${RESET}\n" "$1"
}

header() {
  printf "\n${BOLD}%s${RESET}\n" "$1"
}

# ── Shared Checks ───────────────────────────────────────────────────────────

check_flutter() {
  if command -v flutter &> /dev/null; then
    pass "Flutter CLI"
  else
    fail "Flutter CLI (flutter not found on PATH)"
  fi
}

check_ruby() {
  if command -v ruby &> /dev/null; then
    local version
    version="$(ruby --version | head -1)"
    pass "Ruby ($version)"
  else
    fail "Ruby (not found on PATH — install Ruby 3.4+)"
  fi
}

check_bundler() {
  if command -v bundle &> /dev/null; then
    pass "Bundler"
  else
    fail "Bundler (not found — run: gem install bundler)"
  fi
}

check_config() {
  local env="${1:-staging}"
  local config="$PROJECT_ROOT/config/$env.json"
  if [[ -f "$config" ]]; then
    pass "Environment config (config/$env.json)"
  else
    fail "Environment config (config/$env.json not found — run ./scripts/setup.sh)"
  fi
}

# ── iOS Checks ──────────────────────────────────────────────────────────────

check_ios() {
  header "iOS Deployment Preflight"

  check_flutter
  check_ruby
  check_bundler
  check_config

  # Load env vars from ios/fastlane/.env.default if it exists
  local env_file="$PROJECT_ROOT/ios/fastlane/.env.default"
  if [[ -f "$env_file" ]]; then
    # Source only lines that look like VAR=VALUE (skip comments and blanks)
    while IFS='=' read -r key value; do
      if [[ -n "$key" && "$key" != \#* && -n "${value:-}" ]]; then
        # Only set if not already in environment (real env takes precedence)
        if [[ -z "${!key:-}" ]]; then
          export "$key=$value"
        fi
      fi
    done < "$env_file"
  fi

  # App identifier
  local app_id="${APP_IDENTIFIER:-}"
  if [[ -z "$app_id" || "$app_id" == "com.example.myapp" ]]; then
    fail "APP_IDENTIFIER (not set or still placeholder — update ios/fastlane/.env.default)"
  else
    pass "APP_IDENTIFIER ($app_id)"
  fi

  # Apple ID
  local apple_id="${APPLE_ID:-}"
  if [[ -z "$apple_id" || "$apple_id" == "you@example.com" ]]; then
    fail "APPLE_ID (not set or still placeholder)"
  else
    pass "APPLE_ID ($apple_id)"
  fi

  # Team ID
  local team_id="${TEAM_ID:-}"
  if [[ -z "$team_id" || "$team_id" == "XXXXXXXXXX" ]]; then
    fail "TEAM_ID (not set or still placeholder)"
  else
    pass "TEAM_ID ($team_id)"
  fi

  # ITC Team ID
  local itc_team_id="${ITC_TEAM_ID:-}"
  if [[ -z "$itc_team_id" || "$itc_team_id" == "123456789" ]]; then
    fail "ITC_TEAM_ID (not set or still placeholder)"
  else
    pass "ITC_TEAM_ID ($itc_team_id)"
  fi

  # match repo URL
  local match_url="${MATCH_GIT_URL:-}"
  if [[ -z "$match_url" || "$match_url" == "git@github.com:your-org/certificates.git" ]]; then
    fail "MATCH_GIT_URL (not set or still placeholder)"
  else
    pass "MATCH_GIT_URL ($match_url)"
  fi

  # Fastlane installed
  if [[ -f "$PROJECT_ROOT/ios/Gemfile.lock" ]]; then
    pass "iOS Gemfile.lock (dependencies installed)"
  else
    warn "iOS Gemfile.lock not found (run: cd ios && bundle install)"
  fi
}

# ── Android Checks ──────────────────────────────────────────────────────────

check_android() {
  header "Android Deployment Preflight"

  check_flutter
  check_ruby
  check_bundler
  check_config

  # Load env vars from android/fastlane/.env.default if it exists
  local env_file="$PROJECT_ROOT/android/fastlane/.env.default"
  if [[ -f "$env_file" ]]; then
    while IFS='=' read -r key value; do
      if [[ -n "$key" && "$key" != \#* && -n "${value:-}" ]]; then
        if [[ -z "${!key:-}" ]]; then
          export "$key=$value"
        fi
      fi
    done < "$env_file"
  fi

  # key.properties
  local key_props="$PROJECT_ROOT/android/key.properties"
  if [[ -f "$key_props" ]]; then
    pass "key.properties exists"

    # Check for placeholder passwords
    if grep -q "changeme" "$key_props"; then
      fail "key.properties still contains placeholder passwords (changeme)"
    else
      pass "key.properties passwords configured"
    fi

    # Check keystore file
    local store_file
    store_file="$(grep '^storeFile=' "$key_props" | cut -d= -f2 | tr -d '[:space:]')"
    if [[ -n "$store_file" ]]; then
      local resolved="$PROJECT_ROOT/android/$store_file"
      if [[ -f "$resolved" ]]; then
        pass "Keystore file ($store_file)"
      else
        fail "Keystore file not found ($store_file)"
      fi
    fi
  else
    fail "key.properties not found (copy from key.properties.example)"
  fi

  # Package name
  local pkg="${PACKAGE_NAME:-}"
  if [[ -z "$pkg" || "$pkg" == "com.example.myapp" ]]; then
    fail "PACKAGE_NAME (not set or still placeholder — update android/fastlane/.env.default)"
  else
    pass "PACKAGE_NAME ($pkg)"
  fi

  # Google Play JSON key
  local json_key="${GOOGLE_PLAY_JSON_KEY:-}"
  if [[ -z "$json_key" ]]; then
    fail "GOOGLE_PLAY_JSON_KEY (not set)"
  elif [[ -f "$json_key" ]]; then
    pass "Google Play JSON key ($json_key)"
  else
    fail "Google Play JSON key file not found ($json_key)"
  fi

  # Fastlane installed
  if [[ -f "$PROJECT_ROOT/android/Gemfile.lock" ]]; then
    pass "Android Gemfile.lock (dependencies installed)"
  else
    warn "Android Gemfile.lock not found (run: cd android && bundle install)"
  fi
}

# ── Main ────────────────────────────────────────────────────────────────────

PLATFORM="${1:-both}"

case "$PLATFORM" in
  ios)
    check_ios
    ;;
  android)
    check_android
    ;;
  both|"")
    check_ios
    check_android
    ;;
  *)
    echo "Usage: $0 [ios|android|both]" >&2
    exit 1
    ;;
esac

echo ""
if [[ $FAILURES -gt 0 ]]; then
  printf "${RED}${BOLD}%d check(s) failed.${RESET} See docs/FASTLANE.md for setup instructions.\n" "$FAILURES"
  exit 1
else
  printf "${GREEN}${BOLD}All preflight checks passed!${RESET}\n"
fi
