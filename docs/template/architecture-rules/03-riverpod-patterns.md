# Architecture Rule 03: Riverpod Patterns

## Overview

All providers use the **`@riverpod` / `@Riverpod` annotation** from `riverpod_generator`. Manual `Provider`, `StateNotifierProvider`, etc. are not used. This ensures consistent auto-dispose behavior and compile-time safety.

## Provider Types

### Functional providers (DI wiring)

Use annotated top-level functions for dependency injection. These live in `data/providers/`.

```dart
// data/providers/auth_providers.dart

// Service provider -- creates a Retrofit service
@riverpod
AuthService authService(Ref ref) {
  return AuthService(ref.read(dioProvider));
}

// Repository provider -- wires service + storage
@riverpod
IAuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
  );
}
```

### Class-based notifier providers (shared state)

Use annotated classes extending the generated `_$ClassName` for shared stateful logic.
These live in `data/providers/` when state is shared across features or consumed by core.

```dart
// data/providers/auth_providers.dart
@Riverpod(keepAlive: true)
class AuthStateRepo extends _$AuthStateRepo {
  @override
  Future<AuthState> build() async {
    final result = await ref.read(authRepositoryProvider).getCurrentUser();
    return result.when(
      success: (user) => user != null
          ? AuthState.authenticated(user)
          : AuthState.unauthenticated(),
      failure: (_) => AuthState.unauthenticated(),
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).login(email, password);
    state = result.when(
      success: (user) => AsyncData(AuthState.authenticated(user)),
      failure: (f) => AsyncError(f, StackTrace.current),
    );
  }
}
```

### Page-specific ViewModels (optional)

ViewModels live in `ui/view_models/` and are only created when a page needs
significant data transformation between the domain and the UI. Do not create
passthrough ViewModels -- pages can watch `data/providers/` directly.

```dart
// ui/view_models/profile_view_model.dart
@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  Future<Profile> build() async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getProfile();
    return result.when(
      success: (profile) => profile,
      failure: (failure) => throw FailureException(failure),
    );
  }
}
```

## Naming Conventions

| Provider type | Annotation | Location | Generated name | Example |
|--------------|-----------|----------|---------------|---------|
| Service | `@riverpod` (function) | `data/providers/` | `<functionName>Provider` | `authServiceProvider` |
| Repository | `@riverpod` (function) | `data/providers/` | `<functionName>Provider` | `authRepositoryProvider` |
| Shared state notifier | `@Riverpod(keepAlive: true)` (class) | `data/providers/` | `<className>Provider` | `authStateRepoProvider` |
| Derived state | `@riverpod` (function) | `data/providers/` | `<functionName>Provider` | `isAuthenticatedProvider` |
| Page ViewModel | `@riverpod` (class) | `ui/view_models/` | `<className>Provider` | `profileViewModelProvider` |
| App infrastructure | `@Riverpod(keepAlive: true)` | `core/` | `<name>Provider` | `dioProvider` |

## keepAlive Rules

Use `@Riverpod(keepAlive: true)` **only** for providers that must survive the entire app lifetime:

| Provider | keepAlive | Reason |
|----------|-----------|--------|
| `dioProvider` | `true` | Shared HTTP client, expensive to recreate |
| `appRouterProvider` | `true` | Router must persist across navigation |
| `authStateRepoProvider` | `true` | Auth state must survive screen changes |
| `sharedPrefsProvider` | `true` | Initialized once at startup |
| `themePreferenceProvider` | `true` | Theme persists across navigation |
| Feature services | `false` | Auto-dispose when feature is not in use |
| Feature repositories | `false` | Auto-dispose when feature is not in use |
| Feature view models | `false` | Auto-dispose when user navigates away |

## ref.read vs ref.watch

### In widgets (WidgetRef)

```dart
// WATCH for reactive rebuilds on state changes
final state = ref.watch(authStateRepoProvider);

// READ for one-time access in callbacks
onPressed: () => ref.read(authStateRepoProvider.notifier).login(email, password),
```

### In providers and notifiers (Ref)

```dart
// READ for one-time dependency resolution in DI providers
@riverpod
AuthService authService(Ref ref) {
  return AuthService(ref.read(dioProvider)); // read, not watch
}

// WATCH in derived providers that should rebuild
@riverpod
bool isAuthenticated(Ref ref) {
  final authAsync = ref.watch(authStateRepoProvider); // watch for reactivity
  return authAsync.whenOrNull(data: (s) => s.isAuthenticated) ?? false;
}
```

## DO

- Use `@riverpod` (lowercase) for simple functional providers.
- Use `@Riverpod(keepAlive: true)` (uppercase) when you need `keepAlive`.
- Use `ref.watch` in `build` methods and derived providers for reactivity.
- Use `ref.read` in event handlers, callbacks, and one-time DI resolution.
- Return abstract interfaces from repository providers (`IAuthRepository`, not `AuthRepository`).
- Place infrastructure providers (services, repositories) in `data/providers/`, not in view model files.
- Cross-feature sharing goes through `data/providers/`, never `ui/view_models/`.

## DO NOT

- Do not use manual `Provider()`, `StateNotifierProvider()`, or `FutureProvider()` constructors.
- Do not call `ref.watch` inside event handlers or callbacks -- use `ref.read`.
- Do not call `ref.read` in `build()` methods where reactivity is needed -- use `ref.watch`.
- Do not set `keepAlive: true` on feature-scoped providers without a documented reason.
- Do not create circular provider dependencies.
- Do not access `ref` after a provider has been disposed (use `ref.onDispose` for cleanup).
