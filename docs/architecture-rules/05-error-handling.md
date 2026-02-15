# Architecture Rule 05: Error Handling

## Overview

Errors are handled through a two-tier system: **exceptions** at the data layer boundary and **Result values** above the repository layer. Exceptions are thrown and caught. Results are returned and pattern-matched.

## Error Flow

```
Service (throws AppException)
    |
    v
Repository (catches exception, returns Result<T>)
    |
    v
ViewModel (calls .when() on Result, sets AsyncValue state)
    |
    v
View (renders based on AsyncValue: loading/error/data)
```

## The Result Type

All repository methods return `Future<Result<T>>`:

```dart
// In the repository interface
Future<Result<User>> login(String email, String password);

// In the repository implementation
Future<Result<User>> login(String email, String password) async {
  try {
    final response = await _authService.login(
      LoginRequest(email: email, password: password),
    );
    await _tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    return Success(response.user.toDomain());
  } on DioException catch (e, st) {
    return Err(_mapDioException(e, st));
  } on Exception catch (e, st) {
    return Err(UnexpectedFailure(e, st));
  }
}
```

## Failure Hierarchy

```
Failure (abstract base)
  |
  +-- NetworkFailure (sealed)
  |     +-- NoConnection (final)
  |     +-- Timeout (final)
  |
  +-- ServerFailure (sealed)
  |     +-- BadResponse (final, carries statusCode)
  |     +-- Unauthorized (final)
  |     +-- Forbidden (final)
  |     +-- NotFound (final)
  |
  +-- CacheFailure (sealed)
  |     +-- CacheReadFailure (final)
  |     +-- CacheWriteFailure (final)
  |
  +-- UnexpectedFailure (final, carries original error)
  |
  +-- AuthFailure (sealed, in features/auth/domain/failures/)
  |     +-- InvalidCredentials (final)
  |     +-- EmailAlreadyInUse (final)
  |     +-- SessionExpired (final)
  |     +-- AuthServerError (final)
  |
  +-- ProfileFailure (sealed, in features/profile/domain/failures/)
        +-- ...
```

## Failure Equality

`Failure` subclasses implement **value equality** based on their semantic
fields. This ensures that `Err(NotFound()) == Err(NotFound())` works
correctly with `Result<T>`.

**Equality rules:**
- The base `Failure.==` compares `runtimeType` + `message`.
- `stackTrace` is **excluded** from equality (it is diagnostic, not semantic).
- Subclasses with extra fields (e.g., `BadResponse.statusCode`,
  `UnexpectedFailure.error`) must override `==` and `hashCode` to include
  those fields.

**When adding a new failure with extra fields:**

```dart
final class RateLimited extends ServerFailure {
  const RateLimited(this.retryAfter, [StackTrace? stackTrace])
      : super('Rate limited', stackTrace);

  final Duration retryAfter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateLimited &&
          retryAfter == other.retryAfter &&
          message == other.message;

  @override
  int get hashCode => Object.hash(retryAfter, message);

  @override
  String toString() => 'RateLimited: $message (retry after $retryAfter)';
}
```

## Exception-to-Failure Mapping

Repositories map `DioException` (which wraps `AppException` from `ErrorInterceptor`) to feature-specific failures:

```dart
AuthFailure _mapDioException(DioException e, StackTrace st) {
  final error = e.error;
  if (error is AppException) {
    return switch (error.statusCode) {
      401 => InvalidCredentials(st),
      409 => EmailAlreadyInUse(st),
      _ => AuthServerError(error.message, st),
    };
  }
  return AuthServerError(e.message ?? 'Unknown auth error', st);
}
```

## Notifier Consumption

Notifiers (in `data/providers/` or `ui/view_models/`) convert `Result<T>` to `AsyncValue` state:

```dart
Future<void> login(String email, String password) async {
  state = const AsyncLoading();
  final result = await ref.read(authRepositoryProvider).login(email, password);

  state = result.when(
    success: (user) => AsyncData(AuthState.authenticated(user)),
    failure: (failure) => AsyncError(failure, StackTrace.current),
  );
}
```

## UI Error Display

Views use `AsyncValue.when()` and the failure message mapper:

```dart
final state = ref.watch(authStateRepoProvider);

state.when(
  loading: () => const CircularProgressIndicator(),
  error: (error, _) => Text(mapFailureToMessage(error)),
  data: (authState) => /* success UI */,
);
```

## Adding a New Feature Failure

1. Create a sealed class in `features/<name>/domain/failures/`:

```dart
sealed class ProfileFailure extends Failure {
  const ProfileFailure(super.message, [super.stackTrace]);
}

final class ProfileNotFound extends ProfileFailure {
  const ProfileNotFound([StackTrace? stackTrace])
      : super('Profile not found', stackTrace);
}
```

2. Map exceptions to the failure in the repository's `_mapDioException` method.
3. Add user-facing messages in `failure_message_mapper.dart`.

## DO

- Always return `Result<T>` from repository methods.
- Always catch `DioException` and generic `Exception` in repository methods.
- Always include `StackTrace` when creating `Err` values.
- Use feature-specific failure types for errors that require distinct UI behavior.
- Use `UnexpectedFailure` as the catch-all for truly unexpected exceptions.

## DO NOT

- Do not throw exceptions from repository methods -- return `Err` instead.
- Do not let `AppException` or `DioException` propagate to the ViewModel or UI layer.
- Do not catch errors in ViewModels -- let the `Result` type handle it.
- Do not use generic `Failure` where a feature-specific failure exists.
- Do not put user-facing error messages in `Failure.message` -- use the failure message mapper.
