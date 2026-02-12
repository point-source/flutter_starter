# ADR 009: Environment Configuration Strategy

## Status

Accepted (amended)

## Context

The application must support multiple environments (development, staging, production) with different API base URLs, Sentry DSNs, feature flags, and behavioral differences (SSL pinning, logging verbosity).

Common approaches:

- **Multiple entry points**: Separate `main_dev.dart`, `main_staging.dart`, `main_prod.dart` files, each initializing a different configuration.
- **Flutter flavors**: Platform-level build variants (Android productFlavors, iOS schemes). Powerful but complex to set up and maintain.
- **Compile-time constants**: `--dart-define` or `--dart-define-from-file` to inject values at build time without multiple entry points.
- **Runtime configuration**: Load from a config file, remote config, or environment variables at startup.

## Decision

Use a **single `main.dart`** with **`--dart-define-from-file`** to inject environment-specific values at compile time.

Implementation:

- Example config files live in `config/examples/` and are committed to the repo.
- Active config files (`config/*.json`) are gitignored. Run `./scripts/setup.sh` to provision them from the templates.
- The `AppEnvironment` enum reads compile-time constants via `String.fromEnvironment` and `bool.fromEnvironment`.
- Configuration values include: `ENVIRONMENT`, `API_URL`, `SENTRY_DSN`.
- Sensible defaults apply when no config file is specified (defaults to development).
- A `STRICT_ENV` flag enables strict validation in CI, throwing `StateError` on invalid environment values.
- Environment-specific behavior (Sentry enablement, SSL pinning, sample rates) is computed from the `AppEnvironment` enum's instance properties.
- Multiple `--dart-define-from-file` args can be layered, with later files overriding earlier values. This enables overlay configs for auth bypass modes.

Build commands:

```bash
# Provision config files (first time)
./scripts/setup.sh

# Development (default, config optional)
flutter run --dart-define-from-file=config/development.json

# Staging
flutter run --dart-define-from-file=config/staging.json

# Production release
flutter build apk --release --dart-define-from-file=config/production.json
```

### Auth Bypass (Development)

Additional compile-time constants support bypassing or simplifying the login flow:

- `AUTH_BYPASS` -- `"mock"` (fake user, no network) or `"prefill"` (pre-fill login form)
- `DEV_EMAIL` / `DEV_PASSWORD` -- credentials for prefill mode

These are provided via overlay config files layered on top of the base environment config:

```bash
# Mock mode (no backend needed)
flutter run \
  --dart-define-from-file=config/development.json \
  --dart-define-from-file=config/auth_bypass_mock.json

# Prefill mode (real backend, pre-filled credentials)
flutter run \
  --dart-define-from-file=config/development.json \
  --dart-define-from-file=config/auth_bypass_prefill.json
```

VS Code launch configurations are provided for each mode.

## Consequences

### Positive

- **Single entry point**: One `main.dart` reduces duplication and the risk of diverging initialization logic.
- **Compile-time safety**: Environment values are baked into the binary; they cannot be tampered with at runtime. Auth bypass code is tree-shaken from release builds.
- **Simple CI integration**: Each CI job provisions configs from templates and optionally overrides from secrets.
- **No platform configuration**: Unlike flavors, no Android `build.gradle` or iOS scheme changes needed.
- **Config-as-templates**: Only example files are committed. Sensitive values (DSNs, credentials) never enter version control.

### Negative

- **No runtime switching**: Changing environments requires a rebuild. Cannot switch environments in a running app.
- **Setup step required**: Developers must run `./scripts/setup.sh` before their first build.
- **Limited to string/bool/int**: `--dart-define` only supports primitive types, not complex configuration objects.

### Neutral

- The `AppEnvironment` enum centralizes all environment-dependent decisions, making it the single source of truth for "what environment are we in?"
- A configuration warning system logs diagnostics at startup when the environment is misconfigured.
