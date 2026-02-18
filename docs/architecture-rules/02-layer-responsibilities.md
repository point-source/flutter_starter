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
  Data Layer (repositories, services, DTOs, mappers, providers)
```

## UI Layer

**Location**: `features/<name>/ui/`

**Contains**: Pages (widgets), ViewModels (optional Riverpod notifiers), feature-specific widgets.

**Responsibilities**:

- Render UI based on provider state (`AsyncValue<T>`).
- Delegate user actions to notifier methods.
- Handle navigation via auto_route.
- Display errors using `failure_message_mapper` to convert failures to user-facing strings.

```dart
// Page watches a data/providers/ notifier directly (no ViewModel needed)
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authStateRepoProvider);

    return state.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => ErrorDisplay(message: mapFailureToMessage(error)),
      data: (authState) => LoginForm(
        onSubmit: (email, password) {
          ref.read(authStateRepoProvider.notifier).login(email, password);
        },
      ),
    );
  }
}
```

**Rules**:

- **Pages are layout orchestrators**: Pages should assemble and arrange extracted widget components, not implement fine-grained UI logic inline. Extract meaningful UI chunks into dedicated widgets in `ui/widgets/` to keep pages modular and readable.
- **Input placement in compact portrait**: When a page has a small number of input fields (1-3), position them near the bottom of the viewport so they are thumb-accessible on phones. Exception: pages that are primarily forms (e.g., profile editing) should use conventional top-down form layout.
- Views must not contain business logic (validation, data transformation, API calls).
- Views must not import services, repositories, or DTOs directly.
- Views access state through `ref.watch()` on either a ViewModel or `data/providers/` notifier.
- Views trigger actions through `ref.read(...notifier).method()`.
- ViewModels are optional -- only create them when significant data transformation is needed between the domain and the UI. Pages can watch `data/providers/` directly for simple cases.

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

**Contains**: Repository implementations, infrastructure providers, and optionally Retrofit services, DTOs, and DTO-to-entity mappers when connecting a backend.

**Responsibilities**:

- Implement repository interfaces defined in the domain layer.
- Call external services (REST APIs via Retrofit, SDK clients, local storage).
- Map DTOs to domain entities using mapper extensions.
- Catch exceptions and return `Result<T>` values.
- Manage side effects (token persistence, cache writes).
- Provide Riverpod providers for services and repositories in `data/providers/`.
- Host shared state notifiers (e.g., `AuthStateRepo`) that other features import.

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
- Retrofit services must be stateless HTTP wrappers (code-generated). SDK clients are injected directly.
- The repository is the single source of truth for data operations within the feature.

## Dependency Direction Summary

| Layer | Can depend on | Must not depend on |
|-------|--------------|-------------------|
| UI | Domain, Core | Data (internal) |
| Domain | Core (error types only) | UI, Data, Flutter |
| Data | Domain (interfaces), Core | UI |
