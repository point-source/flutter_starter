# ADR 010: Logging and Monitoring Approach

## Status

Accepted

## Context

The application needs structured logging for development debugging and production error monitoring. Requirements:

- Debug-level logging visible in the IDE console during development.
- Error and crash reporting in staging and production environments.
- A consistent logging interface that does not couple application code to a specific logging backend.
- Sensitive data redaction in log output (auth tokens, passwords).

Alternatives considered:

- **print / debugPrint**: Simple but unstructured, no severity levels, no tags, impossible to filter or route to monitoring services.
- **logger package**: Pretty console output with color coding. Development-only; does not integrate with crash reporting.
- **firebase_crashlytics**: Production-grade crash reporting but locks the project into the Firebase ecosystem.
- **Sentry alone**: Good crash reporting but lacks structured console logging for development.

## Decision

Use a **dual-transport approach**:

1. **Development**: `ConsoleLogger` implementing `IAppLogger`, using `dart:developer` `log()` for structured console output with severity prefixes (`[DEBUG]`, `[INFO]`, `[WARN]`, `[ERROR]`, `[FATAL]`), tags, and optional data maps.
2. **Production/Staging**: **sentry_flutter** for crash reporting and performance monitoring, initialized conditionally in `bootstrap.dart` based on `AppEnvironment.sentryEnabled`.

The `IAppLogger` interface defines five severity levels: `debug`, `info`, `warning`, `error`, `fatal`. Each accepts a message, optional structured data map, optional tag, and (for error/fatal) an error object with stack trace.

Global error handlers are configured in `bootstrap.dart`:

- `FlutterError.onError` captures framework errors.
- `PlatformDispatcher.instance.onError` captures uncaught async errors.
- Both forward to Sentry when enabled.

The `LoggingInterceptor` in the Dio chain logs HTTP requests and responses, redacting sensitive headers (Authorization).

## Consequences

### Positive

- **Abstraction**: All code depends on `IAppLogger`, not on `dart:developer` or Sentry directly. Swapping or adding transports requires no call-site changes.
- **Environment-aware**: Development gets verbose console logs; production gets crash reports without console noise.
- **Structured data**: The `data` map parameter enables contextual logging (user ID, request path, feature name) without string concatenation.
- **Global safety net**: `FlutterError.onError` and `PlatformDispatcher.instance.onError` ensure no crash goes unreported.

### Negative

- **Sentry dependency**: Sentry adds a non-trivial dependency and requires a DSN to be configured for staging/production.
- **Two systems to understand**: Developers must know that `IAppLogger` is for structured logging while Sentry captures crashes at a different level.
- **No log persistence**: Console logs in development are ephemeral; there is no local file logging for post-mortem debugging on devices.

### Neutral

- Sentry sample rates are tuned per environment: 0% in development, 100% in staging, 10% in production.
- The logger provider (`loggerProvider`) returns the environment-appropriate `IAppLogger` implementation.
