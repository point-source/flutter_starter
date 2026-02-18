# Architecture Overview

This document describes the high-level architecture of the Flutter Starter template.
For rationale behind specific decisions, see the [ADRs](adrs/). For detailed coding
patterns, see the [architecture rules](architecture-rules/).

## Architecture Pattern

The application follows **MVVM (Model-View-ViewModel)** combined with **Clean Architecture**
layering. Each feature is organized into three layers with strict dependency rules.

```
  ┌─────────────────────────────────────────────────────────────┐
  │                        UI LAYER                             │
  │                                                             │
  │  Views (ConsumerWidget)     ViewModels (optional @riverpod)  │
  │  - Render UI from state     - Expose AsyncValue<State>      │
  │  - Dispatch user actions    - Call repositories              │
  │  - Watch providers          - Map Result -> AsyncValue       │
  ├─────────────────────────────────────────────────────────────┤
  │                      DOMAIN LAYER                           │
  │                   (optional per feature)                     │
  │                                                             │
  │  Entities                    Repository Interfaces           │
  │  - Core business objects     - Abstract contracts            │
  │  Failures                    Use Cases                       │
  │  - Feature-specific errors   - Cross-repo orchestration     │
  ├─────────────────────────────────────────────────────────────┤
  │                       DATA LAYER                            │
  │                                                             │
  │  Repositories (impl)         Providers (@riverpod)          │
  │  - Source of truth            - Infrastructure wiring        │
  │  - Exception -> Result        Services (@RestApi, optional) │
  │  - Backend integration        - HTTP endpoints (Dio)        │
  │  DTOs (optional)              Mappers (optional)            │
  │  - JSON serialization         - DTO -> Domain entity        │
  └─────────────────────────────────────────────────────────────┘
```

### Dependency Rules

- **UI depends on Domain** (entities, failures) and **Data** (through Riverpod providers)
- **Domain depends on nothing** except core error types (`Result`, `Failure`)
- **Data depends on Domain** (implements repository interfaces, maps to entities)
- **No layer imports UI types**

The domain layer is optional. Simple features (like Settings) that only persist
local preferences may skip the domain layer entirely. Add it when the feature
has its own entity types, repository abstraction, or failure hierarchy.

Features default to **mock implementations**. The data layer starts with a mock
repository and providers wired to it. Services, DTOs, and mappers are added
later when connecting a real backend (REST API, SDK, etc.).

## Data Flow

The standard request lifecycle follows this path:

```
  User Action
      |
      v
  View (ConsumerWidget)
      |  calls method on notifier or watches provider directly
      v
  ViewModel (@riverpod AsyncNotifier) or data/providers/ notifier
      |  reads provider, calls method
      v
  Repository (implements IXxxRepository)
      |  calls service, catches exceptions
      v
  Service (@RestApi / retrofit)
      |  sends HTTP request via Dio
      v
  Dio Interceptor Chain
      |  AuthInterceptor -> RefreshTokenInterceptor
      |  -> LoggingInterceptor -> ErrorInterceptor
      v
  REST API
```

### Response Flow (Success)

```
  API Response (JSON)
      |
      v
  Retrofit (deserializes to DTO)
      |
      v
  Repository
      |  maps DTO -> domain entity
      |  returns Success(entity)
      v
  ViewModel
      |  result.when(success: ...) -> AsyncData(state)
      v
  View
      |  ref.watch() rebuilds with new data
      v
  UI Updated
```

### Response Flow (Error)

```
  HTTP Error / Network Failure
      |
      v
  Dio throws DioException
      |
      v
  ErrorInterceptor (in core/http/)
      |  wraps as DioApiException (Dio-specific, lives in core/http/)
      |  re-throws as DioException with DioApiException in .error
      v
  Repository catch block
      |  inspects DioApiException.statusCode
      |  maps to feature-specific Failure subtype
      |  returns Err(failure)
      v
  ViewModel
      |  result.when(failure: ...) -> AsyncError(failure, stackTrace)
      v
  View
      |  ref.watch() rebuilds with error state
      v
  Error UI Shown
```

## Error Handling Architecture

Error handling uses a layered conversion strategy that transforms raw errors into
typed, pattern-matchable values.

### The Error Type Hierarchy

```
  DioException (from Dio)
      |
      | ErrorInterceptor converts to:
      v
  DioApiException (sealed class, Dio-specific, in core/http/)
      |-- ServerException       statusCode, message
      |-- NetworkException      no connectivity
      |-- TimeoutException      request timed out
      |-- ParseException        response parsing failed
      |-- CacheException        local storage failed
      |
      | Repository catches and maps to:
      v
  Failure (abstract base class)
      |
      |-- NetworkFailure (sealed)
      |     |-- NoConnection
      |     |-- Timeout
      |
      |-- ServerFailure (sealed)
      |     |-- BadResponse(statusCode)
      |     |-- Unauthorized
      |     |-- Forbidden
      |     |-- NotFound
      |
      |-- CacheFailure (sealed)
      |     |-- CacheReadFailure
      |     |-- CacheWriteFailure
      |
      |-- UnexpectedFailure
      |
      |-- <Feature>Failure (sealed, per feature)
            |-- e.g. InvalidCredentials
            |-- e.g. EmailAlreadyInUse
            |-- e.g. SessionExpired
```

### The Result Type

All repository methods return `Future<Result<T>>` instead of throwing exceptions.

```dart
sealed class Result<T>
    |-- Success<T>(T data)
    |-- Err<T>(Failure failure)
```

Key operations on `Result`:
- `when(success:, failure:)` -- exhaustive pattern match
- `map(transform)` -- transform success value, pass through failure
- `flatMap(transform)` -- chain operations that themselves return Result
- `getOrElse(orElse)` -- unwrap with fallback
- `getOrNull()` -- unwrap or null

## Background Task Tracking

User-initiated long-running operations (file uploads, data syncs, batch processing) are
managed by a centralised `TaskTracker` Riverpod notifier in `core/tasks/`.

### Architecture

```
Feature UI                    Feature ViewModel
    |                              |
    | ref.watch(selector)          | channel.run<T>(...)
    |                              |
    v                              v
TaskChannel                   TaskChannel
    |                              |
    | filters by category          | delegates with prefixed ID
    |                              |
    v                              v
TaskTracker (IMap<String, TrackedTask>)
    |
    | manages lifecycle, throttling, cancellation
    |
    v
TaskWork<T> function
    | receives CancellationToken + progress callback
```

### Key Concepts

- **TaskTracker**: `@Riverpod(keepAlive: true)` notifier holding an
  `IMap<String, TrackedTask>` of every active or recently-terminal task.
- **TaskChannel**: Feature-scoped plain class that binds a category, concurrency
  limit, and defaults. Features create one channel per category and never touch
  the tracker directly.
- **TaskProgress**: Sealed hierarchy supporting indeterminate (spinner), determinate
  (0.0–1.0 fraction), and phased (labelled steps with optional fraction) progress.
- **CancellationToken**: Pure Dart cooperative cancellation — no Dio dependency.
  Features bridge to Dio's `CancelToken` inside the work function.
- **Throttling**: Categories with a registered `maxConcurrent` limit queue excess
  tasks as `pending` and auto-promote them when slots open.
- **Retry**: Tasks marked `retryable: true` retain their work factory for re-execution.

For detailed patterns, code examples, and DO/DO NOT rules, see
[Architecture Rule 13: Background Tasks](architecture-rules/13-background-tasks.md).

## Riverpod Provider Architecture

Riverpod serves as both state management and dependency injection. Providers
are organized by responsibility.

### Provider Hierarchy for a Feature

```
  dioProvider (@Riverpod keepAlive)
      |
      v
  authServiceProvider (@riverpod)          ─┐
      |  creates AuthService(dio)           │  data/providers/
      v                                     │  auth_providers.dart
  authRepositoryProvider (@riverpod)        │
      |  creates AuthRepository(...)        │
      v                                     │
  authStateRepoProvider (@Riverpod keepAlive)│
      |  AsyncNotifier holding AuthState    │
      v                                    ─┘
  isAuthenticatedProvider (@riverpod)
      |  derived bool from authStateRepo
      v
  AuthGuard / Views
```

Infrastructure providers (service, repository) and shared state notifiers
live in `data/providers/`. View models in `ui/view_models/` are optional
and only created when a page needs significant data transformation.

### Provider Patterns

| Pattern | Annotation | Location | Use Case |
|---|---|---|---|
| App-lifetime singleton | `@Riverpod(keepAlive: true)` | `data/providers/` | Dio, AppRouter, AuthStateRepo |
| Infrastructure wiring | `@riverpod` (function) | `data/providers/` | Services, repositories |
| Shared state notifier | `@Riverpod(keepAlive: true)` (class) | `data/providers/` | Auth state, preferences |
| Page-specific ViewModel | `@riverpod` (class) | `ui/view_models/` | Complex data transformation |
| Derived state | `@riverpod` (function) | `data/providers/` | `isAuthenticatedProvider` |

## Routing and Navigation

Navigation is handled by `auto_route` with type-safe route generation.

### Route Tree

```
  /login              (unauthenticated)
  /register           (unauthenticated)
  /                   (shell -- AuthGuard protected)
    /dashboard
    /profile
    /settings
```

### AuthGuard

The `AuthGuard` reads `isAuthenticatedProvider` (a derived boolean) synchronously.
If the user is not authenticated, navigation is redirected to `LoginRoute`.

The `AppRouter` is created inside a `@Riverpod(keepAlive: true)` provider so
that `Ref` can be passed to the `AuthGuard` constructor, bridging auto_route's
guard system with Riverpod's provider tree.

### Adaptive Navigation

The shell route renders an `AdaptiveScaffold` that changes navigation chrome
based on screen width:

| Breakpoint | Width | Navigation |
|---|---|---|
| Compact | < 600dp | Bottom navigation bar |
| Medium | 600--840dp | Navigation rail |
| Expanded | 840--1200dp | Navigation rail with labels |
| Large | 1200dp+ | Persistent navigation drawer |

## Environment Configuration

The application uses a single `main.dart` entry point. Environment selection is
handled entirely through compile-time constants loaded from JSON config files.

```
config/
  development.json     # Local development defaults
  staging.json         # Pre-production testing
  production.json      # Live deployment
```

### Usage

```bash
flutter run --dart-define-from-file=config/development.json
flutter build apk --release --dart-define-from-file=config/production.json
```

### AppEnvironment Enum

`AppEnvironment` reads compile-time constants (`ENVIRONMENT`, `API_URL`,
`SENTRY_DSN`) and exposes environment-aware configuration:

- `apiBaseUrl` -- per-environment API endpoint
- `sentryEnabled` -- true for staging/production
- `sentrySampleRate` -- 1.0 staging, 0.1 production
- `sslPinningEnabled` -- disabled in development for proxy inspection

Strict mode (`STRICT_ENV=true`) throws on invalid environment values, intended
for CI pipelines.

## Bootstrap Sequence

`main()` delegates to `bootstrap()`, which performs initialization in order:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Initialize `SharedPreferences` (async)
3. Log environment configuration warnings
4. Register global error handlers (`FlutterError.onError`, `PlatformDispatcher.onError`)
5. Initialize Sentry (staging/production only, if DSN configured)
6. Create `ProviderScope` with `SharedPreferences` override
7. Run `App` widget

## Dio Interceptor Chain (core/http/)

HTTP requests pass through four interceptors in order:

1. **AuthInterceptor** -- reads access token from `ITokenStorage`, adds
   `Authorization: Bearer <token>` header
2. **RefreshTokenInterceptor** (`QueuedInterceptor`) -- on 401, acquires lock,
   calls refresh endpoint using a separate plain Dio instance (avoiding
   interceptor recursion), retries the original request. On refresh failure,
   clears tokens and fires `onAuthExpired` callback to invalidate auth state
3. **LoggingInterceptor** -- logs request/response details via `IAppLogger`
   with sensitive data redaction
4. **ErrorInterceptor** -- converts `DioException` into `DioApiException` subtypes
   preserving the HTTP status code for downstream mapping

## Testing Strategy

Tests mirror the `lib/` directory structure under `test/`.

### Test Patterns by Layer

| Layer | What to Test | Approach |
|---|---|---|
| Repository | Exception-to-Result mapping, token persistence | Override service provider with mock, verify Result variants |
| ViewModel | State transitions (loading, data, error) | Use `ProviderContainer` with mock repository override |
| Widget | UI rendering for each state | Wrap in `ProviderScope` with mock overrides, pump, verify |
| Domain | Entity behavior, failure types | Unit tests, no mocking needed |

### Test Helpers

- `test/helpers/test_utils.dart` -- `createContainer()` with teardown
- `test/helpers/mocks.dart` -- shared mock classes (MockAuthRepository, etc.)
- `test/helpers/fakes.dart` -- fake data factories (FakeUser, FakeProfile, etc.)

## Shared Repositories (Cross-Feature Dependencies)

When multiple features need to depend on the same repository, place it in one of these locations:

### Option 1: Core Infrastructure (Recommended for True Cross-Cutting Concerns)

If the repository provides truly foundational data (e.g., user profile, app configuration, analytics):

```
lib/core/
  repositories/
    user/
      user_repository.dart         # IUserRepository interface
      user_repository_impl.dart    # Implementation
      user_repository_provider.dart  # @riverpod provider
```

**Use when:**
- Multiple unrelated features need the data (e.g., Dashboard, Profile, Settings all need user data)
- The data is foundational to the app (not business logic)
- You want to avoid circular dependencies between features

### Option 2: Primary Feature with Re-Export (Recommended for Feature-Owned Data)

If one feature "owns" the domain, other features can import from it:

```
lib/features/
  user/                    # Primary owner
    data/
      repositories/
        user_repository.dart
    domain/
      entities/
        user.dart

  dashboard/               # Consumer feature
    # Imports: package:flutter_starter/features/user/...

  profile/                 # Consumer feature
    # Imports: package:flutter_starter/features/user/...
```

**Use when:**
- One feature has primary ownership of the business logic
- Other features only read/consume the data (don't modify business rules)
- You want to keep the domain model close to its primary use case

### Option 3: Shared Feature Module (For Complex Shared Domains)

For substantial shared domains (e.g., "contacts", "products", "notifications"):

```
lib/features/
  shared/
    user/
      data/
      domain/
      providers/

  auth/          # Uses shared/user
  dashboard/     # Uses shared/user
  profile/       # Uses shared/user
```

**Use when:**
- The domain is complex enough to warrant its own feature module
- Multiple features both read AND write the data
- You want to centralize business rules for the shared domain

### Anti-Pattern: Avoid Duplication

❌ **Don't** duplicate repository implementations across features:

```
lib/features/
  dashboard/
    data/
      repositories/
        user_repository.dart    # ❌ Duplicated
  profile/
    data/
      repositories/
        user_repository.dart    # ❌ Duplicated
```

This creates maintenance burden and data inconsistency.

### Example: User Repository in Core

```dart
// lib/core/repositories/user/user_repository.dart
library;

/// Provides access to user profile data.
abstract interface class IUserRepository {
  /// Fetches the current user's profile.
  Future<Result<User>> getCurrentUser();

  /// Updates the current user's profile.
  Future<Result<void>> updateUser(User user);
}

// lib/core/repositories/user/user_repository_provider.dart
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_starter/core/repositories/user/user_repository.dart';
import 'package:flutter_starter/core/repositories/user/user_repository_impl.dart';

part 'user_repository_provider.g.dart';

/// Provides the user repository instance.
@riverpod
IUserRepository userRepository(UserRepositoryRef ref) {
  final service = ref.watch(userServiceProvider);
  return UserRepositoryImpl(service);
}
```

Then features can depend on it:

```dart
// lib/features/dashboard/ui/view_models/dashboard_view_model.dart
library;

import 'package:flutter_starter/core/repositories/user/user_repository_provider.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  Future<DashboardState> build() async {
    final userRepo = ref.read(userRepositoryProvider);
    final result = await userRepo.getCurrentUser();
    // ... use user data
  }
}
```

### Guideline Summary

1. **Start with Option 2** (feature-owned) if one feature has clear ownership
2. **Move to Option 1** (core) when 3+ unrelated features need the repository
3. **Only use Option 3** (shared feature) for complex shared business domains
4. **Never duplicate** repository implementations

## Architecture Decision Records

Rationale for major architectural choices is documented in ADRs:

| ADR | Decision |
|---|---|
| [001](adrs/001-riverpod-for-state-and-di.md) | Riverpod for state management and DI |
| [002](adrs/002-auto-route-for-navigation.md) | auto_route for navigation |
| [003](adrs/003-dio-retrofit-for-networking.md) | Dio + Retrofit for networking |
| [004](adrs/004-dart-mappable-for-models.md) | dart_mappable for data modeling |
| [005](adrs/005-sealed-result-for-errors.md) | Sealed Result type for error handling |
| [006](adrs/006-slang-for-i18n.md) | slang for internationalization |
| [007](adrs/007-feature-first-architecture.md) | Feature-first project structure |
| [008](adrs/008-mvvm-with-clean-architecture.md) | MVVM with Clean Architecture layers |
| [009](adrs/009-environment-configuration.md) | Environment configuration strategy |
| [010](adrs/010-logging-and-monitoring.md) | Logging and monitoring approach |
| [011](adrs/011-mock-first-features.md) | Mock-first feature implementation |

## Additional Documentation

| Directory | Purpose |
|---|---|
| [`project-decisions/`](project-decisions/) | Project-specific ADRs (app-level decisions, not template) |
| [`migrations/`](migrations/) | Template update migration guides for downstream projects |
| [`TEMPLATE_SYNC.md`](TEMPLATE_SYNC.md) | How to keep derived projects in sync with template updates |

## Architecture Rules

Detailed coding patterns and rules are documented in `docs/architecture-rules/`:

| Rule | Topic |
|---|---|
| [01](architecture-rules/01-project-structure.md) | Project structure |
| [02](architecture-rules/02-layer-responsibilities.md) | Layer responsibilities |
| [03](architecture-rules/03-riverpod-patterns.md) | Riverpod patterns |
| [04](architecture-rules/04-navigation-rules.md) | Navigation rules |
| [05](architecture-rules/05-error-handling.md) | Error handling |
| [06](architecture-rules/06-data-modeling.md) | Data modeling |
| [07](architecture-rules/07-testing-standards.md) | Testing standards |
| [08](architecture-rules/08-api-integration.md) | API integration |
| [09](architecture-rules/09-theming.md) | Theming |
| [10](architecture-rules/10-i18n.md) | Internationalization |
| [11](architecture-rules/11-security.md) | Security |
| [12](architecture-rules/12-documentation.md) | Documentation standards |
| [13](architecture-rules/13-background-tasks.md) | Background task tracking |
