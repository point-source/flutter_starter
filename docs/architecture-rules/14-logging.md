# Architecture Rule 14: Logging

## Overview

All application code should use the structured `IAppLogger` interface rather than calling `print` or `dart:developer` directly. The logger abstraction lives in `core/logging/` and is accessed via `loggerProvider`, which returns a `ConsoleLogger` in development and a `SentryReporter` in staging/production.

## File Layout

```
core/logging/
  app_logger.dart       -- IAppLogger interface + ConsoleLogger implementation
  sentry_reporter.dart  -- SentryReporter implementation (Sentry breadcrumbs + events)
  logger_provider.dart  -- @Riverpod(keepAlive: true) provider returning the right impl
  logger_provider.g.dart
```

## Implementations

| Implementation | Environment | Behaviour |
|---|---|---|
| `ConsoleLogger` | Development | Writes to `dart:developer` log with severity prefix |
| `SentryReporter` | Staging / Production | debug/info → breadcrumbs; warning → `captureMessage`; error/fatal → `captureException` |

## Severity Levels

| Level | When to use | Examples |
|---|---|---|
| `debug` | Verbose diagnostics useful only while developing | Cache hit/miss, provider rebuild, route transition |
| `info` | Normal events worth recording | Login succeeded, profile updated, task completed |
| `warning` | Recoverable but unexpected condition | Repository returned a domain failure, token refresh failed (retrying) |
| `error` | A single operation failed unexpectedly | Unhandled exception in a repository catch block, `UnexpectedFailure` from a task |
| `fatal` | Unrecoverable application state | Unhandled `PlatformDispatcher.onError`, `FlutterError.onError` |

## Tag Convention

Use the `tag` parameter to identify the subsystem that produced the log entry:

| Context | Tag value |
|---|---|
| Feature code | Feature name: `'auth'`, `'profile'`, `'dashboard'` |
| Infrastructure | Specific name: `'http'`, `'tasks'`, `'storage'` |
| Bootstrap / global | `'bootstrap'` |

## Where to Log

### Repositories (Dio-backed)

Log `error` in `on Exception catch` blocks — these represent genuinely unexpected exceptions that were converted to `UnexpectedFailure`:

```dart
@override
Future<Result<Profile>> getProfile() async {
  try {
    final dto = await _service.getProfile();
    return Success(dto.toDomain());
  } on DioException catch (e, st) {
    return Err(_mapDioException(e, st));
  } on Exception catch (e, st) {
    _logger.error(
      'Unexpected error fetching profile',
      error: e,
      stackTrace: st,
      tag: 'profile',
    );
    return Err(UnexpectedFailure(e, st));
  }
}
```

Domain-mapped failures (`_mapDioException`) are expected and do **not** need logging at the repository level — they are logged downstream by notifiers.

### Notifiers / ViewModels

Log `warning` when a repository result is a failure, before setting `AsyncError` or throwing `FailureException`:

```dart
return result.when(
  success: (data) => data,
  failure: (failure) {
    _logger.warning(
      'Failed to load profile',
      data: {'failure': failure.toString()},
      tag: 'profile',
    );
    throw FailureException(failure);
  },
);
```

### Auth Lifecycle

Log `info` on login/register success and call `setUser()` so Sentry attaches user context:

```dart
// On successful login:
_logger.info('Login succeeded', data: {'userId': user.id}, tag: 'auth');
_logger.setUser(user.id, user.email);

// On logout:
_logger.info('Logout', tag: 'auth');
_logger.setUser(null, null);
```

### TaskTracker

Log `error` for `UnexpectedFailure` in `_onTaskFailed`. Expected task failures (`TaskCancelled`, domain failures) do not need extra logging.

### Bootstrap

The `_reportToSentry()` handler should fall back to `ConsoleLogger.fatal()` in development so unhandled errors are visible in the debug console even when Sentry is disabled.

## How to Access the Logger

### In providers / notifiers (have `ref`)

```dart
final logger = ref.read(loggerProvider);
logger.info('Something happened', tag: 'feature');
```

Read the logger once (typically in `build()` or at call site) — do not `watch` it.

### In Dio-backed repositories (constructor injection)

```dart
class ProfileRepository implements IProfileRepository {
  const ProfileRepository(this._service, this._logger);
  final ProfileService _service;
  final IAppLogger _logger;
}
```

Wire the logger in the repository provider:

```dart
@riverpod
IProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(
      ref.read(profileServiceProvider),
      ref.read(loggerProvider),
    );
```

### In mock repositories

Mock repositories do **not** take a logger — they return hard-coded `Result` values and never encounter unexpected exceptions.

## DO

- Use `tag` on every log call so entries are filterable by subsystem.
- Log `warning` for domain failures (expected but noteworthy).
- Log `error` for unexpected exceptions caught in repository `catch` blocks.
- Call `setUser()` on login/register success and `setUser(null, null)` on logout.
- Override `loggerProvider` in tests to prevent console noise and enable verification.

## DO NOT

- Do not call `print()` or `debugPrint()` for operational logging — use the logger.
- Do not log at `error`/`fatal` for expected domain failures (use `warning`).
- Do not `watch` `loggerProvider` — the logger instance never changes at runtime.
- Do not add a logger to mock repositories — they have no exception-throwing code paths.
- Do not log sensitive data (passwords, tokens, PII beyond user ID/email for Sentry context).
