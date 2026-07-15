# Architecture Rule 05: Error Handling

## Overview

Errors use a two-tier boundary: a selected data source may throw its own
exceptions inside the data layer, while repositories return explicit `Result`
values to the rest of the application. No SDK, persistence, transport, or other
source exception crosses the repository boundary.

```text
Selected source (mock / SDK / local / custom / REST)
    -> source value or source-specific exception
Repository
    -> maps value to domain entity
    -> maps exception to application Failure
    -> returns Result<T>
Notifier / ViewModel
    -> maps Result with when(success:, failure:)
UI
    -> renders AsyncValue success or failure state
```

## Result Contract

All repository methods return `Future<Result<T>>`:

```dart
abstract interface class IProfileRepository {
  Future<Result<Profile>> getProfile();
}
```

Implementations catch only errors they understand and translate those errors to
application failures. Preserve unexpected error objects and stack traces:

```dart
Future<Result<Profile>> getProfile() async {
  try {
    final record = await _source.readProfile();
    return Success(record.toDomain());
  } on SourceMissingRecord catch (_, stackTrace) {
    return Err(ProfileNotFound(stackTrace));
  } on Exception catch (error, stackTrace) {
    return Err(UnexpectedFailure(error, stackTrace));
  }
}
```

`SourceMissingRecord` is a placeholder for the selected source's exception. It
must stay in the data implementation; callers see only `ProfileNotFound`.

## Failure Hierarchy

Use `Failure` subclasses for application-meaningful outcomes:

```text
Failure
  +-- NetworkFailure (NoConnection, Timeout)
  +-- ServerFailure (BadResponse, Unauthorized, Forbidden, NotFound)
  +-- CacheFailure (CacheReadFailure, CacheWriteFailure)
  +-- UnexpectedFailure
  +-- <Feature>Failure (feature-specific sealed hierarchy)
```

These are application failures, not a universal taxonomy for every backend.
Prefer feature failures when callers or UI need distinct behavior. Use core
infrastructure failures only when their meaning is truthful for the selected
source.

## Backend-specific Translation

Each repository implementation owns its mapping. For example, an SDK repository
may translate an SDK's invalid-session exception to `SessionExpired`, a local
repository may translate a read error to `CacheReadFailure`, and an opted-in REST
repository may translate a transport response to `Unauthorized`. Do not force
unrelated source errors through one low-level exception hierarchy.

Known failures should be safe for application handling. Raw exception messages,
request URIs, payloads, provider identifiers, and credentials must not become
user-facing `Failure.message` content.

## Failure Equality

`Failure` subclasses use value equality based on semantic fields. Stack traces
are diagnostic and excluded. A subclass with additional semantic fields must
include them in `==` and `hashCode`:

```dart
final class RateLimited extends Failure {
  const RateLimited(this.retryAfter, [StackTrace? stackTrace])
    : super('Rate limited', stackTrace);

  final Duration retryAfter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateLimited && retryAfter == other.retryAfter;

  @override
  int get hashCode => retryAfter.hashCode;
}
```

## Notifier Consumption

Notifiers convert both Result branches to presentation state without knowing the
source implementation:

```dart
Future<void> loadProfile() async {
  state = const AsyncLoading();
  final result = await ref.read(profileRepositoryProvider).getProfile();
  state = result.when(
    success: AsyncData.new,
    failure: (failure) => AsyncError(failure, StackTrace.current),
  );
}
```

Views render `AsyncValue` and use the failure-message mapper for localized,
user-facing text.

## Adding a Feature Failure

1. Create a sealed hierarchy under `features/<name>/domain/failures/`.
2. Map the selected source's relevant errors inside its repository implementation.
3. Add a localized message mapping for every final failure subtype.
4. Test the mapping through the repository interface and test the visible error
   state through the notifier or widget.

## DO

- Always return `Result<T>` from repository methods.
- Catch source-specific exceptions only inside their data implementation.
- Preserve `StackTrace` when creating `Err` values.
- Preserve the original object in `UnexpectedFailure(error, stackTrace)`.
- Use feature failures for outcomes requiring distinct product behavior.
- Keep failure messages safe and map them to localized UI text separately.

## DO NOT

- Do not throw expected source failures from repository methods.
- Do not import backend types into domain, notifier, ViewModel, or UI code.
- Do not teach one transport exception as the default failure source.
- Do not catch errors in the UI.
- Do not stringify an unexpected error before passing it to
  `UnexpectedFailure`; retain the original object for diagnostics.
