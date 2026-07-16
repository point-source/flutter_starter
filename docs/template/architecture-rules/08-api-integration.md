# Architecture Rule 08: Backend Integration

## Overview

Features start with mock repository implementations. A real data source is a
project decision: SDKs, local stores, custom clients, and REST clients are peer
implementations behind the same repository interface. The base starter does not
select or install one.

The stable application contract is:

```text
UI / notifier -> repository interface -> Result<domain value>
                         ^
                         |
              selected data implementation
```

## Repository Boundary

Repository interfaces live in the domain layer and use domain entities,
application failures, and `Result<T>`. They must not expose SDK models, database
records, HTTP responses, or source-specific exception types.

```dart
abstract interface class IProfileRepository {
  Future<Result<Profile>> getProfile();
}
```

Each implementation owns three translations:

1. Call its selected source.
2. Convert source values to domain entities when necessary.
3. Catch source-specific exceptions and convert them to application `Failure`
   values before returning `Err`.

```dart
Future<Result<Profile>> getProfile() async {
  try {
    final record = await _client.fetchProfile();
    return Success(record.toDomain());
  } on ClientNotFoundException catch (_, stackTrace) {
    return Err(ProfileNotFound(stackTrace));
  } on Exception catch (error, stackTrace) {
    return Err(UnexpectedFailure(error, stackTrace));
  }
}
```

`ClientNotFoundException` and the record type remain private to the data layer.
Callers see only `Result<Profile>` and `ProfileFailure`/`Failure` values.

## Peer Implementations

| Implementation | Source owned by data layer | Typical mapping |
|---|---|---|
| Mock/in-memory | Hard-coded or mutable in-memory state | Domain values and deliberate test failures |
| SDK-backed | Provider SDK client and SDK response types | SDK exceptions/models to application failures/entities |
| Local | Preferences, secure storage, SQLite, or files | Storage errors/records to cache or feature failures/entities |
| Custom client | Project-owned protocol/client | Client errors/payloads to application failures/entities |
| REST | HTTP client, transport errors, and DTOs | Transport errors/DTOs to application failures/entities |

Do not add a universal source-exception hierarchy. Low-level failure taxonomies
are not interchangeable; the repository's application-facing contract is.

## Provider Wiring

Providers return the repository interface so changing the implementation does
not change callers:

```dart
@riverpod
IProfileRepository profileRepository(Ref ref) {
  return MockProfileRepository();
}
```

After selecting a backend, replace only the binding and inject its client:

```dart
@riverpod
IProfileRepository profileRepository(Ref ref) {
  return SdkProfileRepository(ref.read(profileClientProvider));
}
```

## Adding a Backend Implementation

1. Keep or define the domain repository interface and failure types first.
2. Add the selected client/source under the feature's data layer, or under
   `core/` only when it is genuinely shared by multiple features.
3. Implement the interface and keep all source types inside the data layer.
4. Map known source errors to feature-specific failures; preserve unexpected
   errors and stack traces with `UnexpectedFailure`.
5. Test successful value mapping and each meaningful failure mapping through
   the public repository API.
6. Swap the provider binding only after the implementation tests pass.
7. Exercise the same Result-driven UI success and failure states used by mocks.

## REST Opt-in

If the project deliberately chooses the starter's supported Dio/Retrofit REST
capability, install it once with:

```bash
mason make dio_rest
```

That command adds the REST dependencies and foundation, then emits concrete
configuration, generation, interceptor, and transport-error guidance at
`docs/project/REST_DIO.md`. Only an opted-in project should run REST-specific
feature, repository, or service generation. The generated repository still
implements the same domain interface and returns the same `Result<T>` contract.

## DO

- Start features with a runnable mock implementation.
- Return domain entities and `Result<T>` from repository interfaces.
- Keep source models, clients, and exceptions inside the data layer.
- Map source-specific errors at the repository boundary.
- Test repository success and failure through the public interface.
- Record project-specific backend decisions in `docs/project/decisions/`.

## DO NOT

- Do not add a real-backend dependency before the project selects it.
- Do not import source SDKs or transport libraries into domain or UI code.
- Do not expose raw response, record, DTO, or exception types from repositories.
- Do not assume REST is the next step after a mock; choose the source that fits
  the product.
- Do not follow Dio/Retrofit instructions unless `dio_rest` has been installed.
