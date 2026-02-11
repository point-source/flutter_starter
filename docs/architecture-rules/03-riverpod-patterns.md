# Architecture Rule 03: Riverpod Patterns

## Overview

All providers use the **`@riverpod` / `@Riverpod` annotation** from `riverpod_generator`. Manual `Provider`, `StateNotifierProvider`, etc. are not used. This ensures consistent auto-dispose behavior and compile-time safety.

## Provider Types

### Functional providers (DI wiring)

Use annotated top-level functions for dependency injection. These create and return a dependency.

```dart
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

### Class-based notifier providers (state management)

Use annotated classes extending the generated `_$ClassName` for stateful logic.

```dart
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  Future<AuthState> build() async {
    // Initial state computation
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

## Naming Conventions

| Provider type | Annotation | Generated name | Example |
|--------------|-----------|---------------|---------|
| Service | `@riverpod` (function) | `<functionName>Provider` | `authServiceProvider` |
| Repository | `@riverpod` (function) | `<functionName>Provider` | `authRepositoryProvider` |
| ViewModel | `@Riverpod()` (class) | `<className>Provider` | `authViewModelProvider` |
| Derived state | `@riverpod` (function) | `<functionName>Provider` | `authStateProvider` |
| Infrastructure | `@Riverpod(keepAlive: true)` | `<name>Provider` | `dioProvider` |

## keepAlive Rules

Use `@Riverpod(keepAlive: true)` **only** for providers that must survive the entire app lifetime:

| Provider | keepAlive | Reason |
|----------|-----------|--------|
| `dioProvider` | `true` | Shared HTTP client, expensive to recreate |
| `appRouterProvider` | `true` | Router must persist across navigation |
| `authViewModelProvider` | `true` | Auth state must survive screen changes |
| `sharedPrefsProvider` | `true` | Initialized once at startup |
| Feature services | `false` | Auto-dispose when feature is not in use |
| Feature repositories | `false` | Auto-dispose when feature is not in use |
| Feature view models | `false` | Auto-dispose when user navigates away |

## ref.read vs ref.watch

### In widgets (WidgetRef)

```dart
// WATCH for reactive rebuilds on state changes
final state = ref.watch(authViewModelProvider);

// READ for one-time access in callbacks
onPressed: () => ref.read(authViewModelProvider.notifier).login(email, password),
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
bool authState(Ref ref) {
  final viewModel = ref.watch(authViewModelProvider); // watch for reactivity
  return viewModel.whenOrNull(data: (s) => s.isAuthenticated) ?? false;
}
```

## DO

- Use `@riverpod` (lowercase) for simple functional providers.
- Use `@Riverpod(keepAlive: true)` (uppercase) when you need `keepAlive`.
- Use `ref.watch` in `build` methods and derived providers for reactivity.
- Use `ref.read` in event handlers, callbacks, and one-time DI resolution.
- Return abstract interfaces from repository providers (`IAuthRepository`, not `AuthRepository`).
- Place provider definitions in the same file as the class they provide (e.g., service provider in the view model file, or its own dedicated file).

## DO NOT

- Do not use manual `Provider()`, `StateNotifierProvider()`, or `FutureProvider()` constructors.
- Do not call `ref.watch` inside event handlers or callbacks -- use `ref.read`.
- Do not call `ref.read` in `build()` methods where reactivity is needed -- use `ref.watch`.
- Do not set `keepAlive: true` on feature-scoped providers without a documented reason.
- Do not create circular provider dependencies.
- Do not access `ref` after a provider has been disposed (use `ref.onDispose` for cleanup).
