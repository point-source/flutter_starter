# ADR 009: Environment Configuration Strategy

## Status

Accepted

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

- Three JSON config files in `config/`: `development.json`, `staging.json`, `production.json`.
- The `AppEnvironment` enum reads compile-time constants via `String.fromEnvironment` and `bool.fromEnvironment`.
- Configuration values include: `ENVIRONMENT`, `API_URL`, `SENTRY_DSN`.
- Sensible defaults apply when no config file is specified (defaults to development).
- A `STRICT_ENV` flag enables strict validation in CI, throwing `StateError` on invalid environment values.
- Environment-specific behavior (Sentry enablement, SSL pinning, sample rates) is computed from the `AppEnvironment` enum's instance properties.

Build commands:

```bash
# Development (default, config optional)
flutter run --dart-define-from-file=config/development.json

# Staging
flutter run --dart-define-from-file=config/staging.json

# Production release
flutter build apk --release --dart-define-from-file=config/production.json
```

## Consequences

### Positive

- **Single entry point**: One `main.dart` reduces duplication and the risk of diverging initialization logic.
- **Compile-time safety**: Environment values are baked into the binary; they cannot be tampered with at runtime.
- **Simple CI integration**: Each CI job passes a different `--dart-define-from-file` argument.
- **No platform configuration**: Unlike flavors, no Android `build.gradle` or iOS scheme changes needed.

### Negative

- **No runtime switching**: Changing environments requires a rebuild. Cannot switch environments in a running app.
- **JSON file management**: Config files contain potentially sensitive values (Sentry DSN) and should be managed carefully in version control.
- **Limited to string/bool/int**: `--dart-define` only supports primitive types, not complex configuration objects.

### Neutral

- The `AppEnvironment` enum centralizes all environment-dependent decisions, making it the single source of truth for "what environment are we in?"
- A configuration warning system logs diagnostics at startup when the environment is misconfigured.
