# Architecture Rule 02: Layer Responsibilities

## Overview

Each feature is organized into up to three layers: **UI**, **Domain**, and **Data**. Dependencies flow inward: UI -> Domain -> Data. The domain layer is optional for simple features.

## Layer Diagram

```
  UI Layer (views + view models)
       |
       | depends on
       v
  Domain Layer (entities, interfaces, failures)  <-- OPTIONAL
       ^
       | implements
       |
  Data Layer (repositories, services, DTOs, mappers)
```

## UI Layer

**Location**: `features/<name>/ui/`

**Contains**: Pages (widgets), ViewModels (Riverpod notifiers), feature-specific widgets.

**Responsibilities**:

- Render UI based on ViewModel state (`AsyncValue<T>`).
- Delegate user actions to ViewModel methods.
- Handle navigation via auto_route.
- Display errors using `failure_message_mapper` to convert failures to user-facing strings.

```dart
// Page reads ViewModel state and calls ViewModel methods
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);

    return state.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => ErrorDisplay(message: mapFailureToMessage(error)),
      data: (authState) => LoginForm(
        onSubmit: (email, password) {
          ref.read(authViewModelProvider.notifier).login(email, password);
        },
      ),
    );
  }
}
```

**Rules**:

- Views must not contain business logic (validation, data transformation, API calls).
- Views must not import services, repositories, or DTOs directly.
- Views access state exclusively through `ref.watch(viewModelProvider)`.
- Views trigger actions exclusively through `ref.read(viewModelProvider.notifier).method()`.

## Domain Layer (Optional)

**Location**: `features/<name>/domain/`

**Contains**: Entities, repository interfaces, feature-specific failures, use cases (rare).

**Responsibilities**:

- Define the feature's data contracts (entities with domain-meaningful field names and types).
- Define the repository interface that the data layer must implement.
- Define feature-specific failure types for exhaustive error handling.
- Orchestrate logic across multiple repositories (use cases -- only when needed).

```dart
// Repository interface in domain layer
abstract interface class IAuthRepository {
  Future<Result<User>> login(String email, String password);
  Future<Result<void>> logout();
}

// Feature-specific failure hierarchy
sealed class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.stackTrace]);
}
final class InvalidCredentials extends AuthFailure { ... }
final class EmailAlreadyInUse extends AuthFailure { ... }
```

**Rules**:

- Domain layer must not import from the data layer or UI layer.
- Domain layer must not depend on Flutter framework classes.
- Domain layer must not depend on Dio, Retrofit, or any networking library.
- Use cases are only added when logic spans multiple repositories.

**When to skip**: Skip the domain layer when the feature has no API, no DTOs to map, and no feature-specific failures (e.g., the settings feature).

## Data Layer

**Location**: `features/<name>/data/`

**Contains**: Repository implementations, Retrofit services, DTOs, DTO-to-entity mappers.

**Responsibilities**:

- Implement repository interfaces defined in the domain layer.
- Call external services (REST APIs via Retrofit, local storage).
- Map DTOs to domain entities using mapper extensions.
- Catch exceptions and return `Result<T>` values.
- Manage side effects (token persistence, cache writes).

```dart
// Repository implementation in data layer
class AuthRepository implements IAuthRepository {
  const AuthRepository(this._authService, this._tokenStorage);

  final AuthService _authService;
  final ITokenStorage _tokenStorage;

  @override
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
}
```

**Rules**:

- Repositories must always return `Result<T>`, never throw exceptions.
- DTOs must not leak into the domain or UI layers -- always map to entities.
- Services must be stateless HTTP wrappers (Retrofit-generated).
- The repository is the single source of truth for data operations within the feature.

## Dependency Direction Summary

| Layer | Can depend on | Must not depend on |
|-------|--------------|-------------------|
| UI | Domain, Core | Data (internal) |
| Domain | Core (error types only) | UI, Data, Flutter |
| Data | Domain (interfaces), Core | UI |
