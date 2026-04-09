# ADR 001: Riverpod for State Management and Dependency Injection

## Status

Accepted

## Context

The Flutter starter template needs a robust solution for both state management and dependency injection (DI). Historically, Flutter projects use separate libraries for each concern -- for example, BLoC for state management paired with get_it/injectable for DI.

Key requirements:

- Compile-time safety for provider access (no runtime service locator lookups).
- Testability through easy provider overrides without global registries.
- Code generation to reduce boilerplate while maintaining readability.
- A single unified system rather than two separate concepts to learn and maintain.
- Support for both synchronous and asynchronous initialization patterns.

Popular alternatives considered:

- **BLoC + get_it/injectable**: Well-established but requires maintaining two separate systems. BLoC's event/state pattern adds ceremony for simple state. get_it is a runtime service locator with no compile-time safety.
- **Provider**: The predecessor to Riverpod with known limitations around compile-time safety, provider scoping, and testing ergonomics.
- **Riverpod (without code generation)**: Viable but requires manual provider declarations that are verbose and error-prone.

## Decision

Use **Riverpod** with **riverpod_generator** (`@riverpod` / `@Riverpod` annotations) as the unified solution for both state management and dependency injection.

Providers serve a dual role:

1. **DI containers** -- functional providers (annotated functions) create and wire dependencies such as Dio, repositories, and services.
2. **State holders** -- notifier providers (annotated classes extending `_$ClassName`) manage UI-facing state with `AsyncValue` for loading/error/data states.

The `@Riverpod(keepAlive: true)` annotation replaces manual `.autoDispose` management for long-lived providers like the Dio instance, the router, and the auth view model.

## Consequences

### Positive

- **Single concept**: Developers learn one system for both DI and state management.
- **Compile-time safety**: Generated providers are type-checked; typos and missing dependencies are caught at build time.
- **Testing**: `ProviderContainer(overrides: [...])` makes it trivial to swap implementations in tests without global teardown.
- **Auto-dispose by default**: Generated providers auto-dispose unless `keepAlive: true` is set, preventing memory leaks.
- **No runtime reflection**: Unlike get_it, Riverpod uses code generation rather than a mutable global registry.

### Negative

- **Code generation dependency**: Requires `build_runner` for every provider change, adding a build step.
- **Learning curve**: Developers unfamiliar with Riverpod must learn the provider taxonomy (functional, notifier, async notifier, stream).
- **Generated file noise**: Each provider file produces a `.g.dart` part file that must be committed or gitignored.

### Neutral

- The team must establish conventions for when to use `keepAlive: true` versus the default auto-dispose behavior (documented in architecture rule 03).
- `ref.read` versus `ref.watch` discipline must be enforced by code review and lint rules.
