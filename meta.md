# Flutter Starter Template — Implementation Plan

## Tech Stack Summary

| Concern | Package | Notes |
|---------|---------|-------|
| State Management | `riverpod` + `riverpod_generator` | `@riverpod` code gen for all providers |
| DI | Riverpod (provider tree) | No get_it/injectable needed |
| Navigation | `auto_route` + `auto_route_generator` | Type-safe, guards, nested nav |
| HTTP Client | `dio` + `retrofit` + `retrofit_generator` | Code-gen API services per feature |
| Data Classes | `dart_mappable` + `dart_mappable_builder` | Immutable models, JSON, copyWith |
| Collections | `fast_immutable_collections` | IList, IMap, ISet for domain models |
| Error Handling | Custom sealed `Result<T>` | No fpdart dependency |
| Connectivity | `connectivity_plus` | Offline-aware UX |
| Local Storage | `shared_preferences` + `flutter_secure_storage` | Settings + encrypted tokens |
| Theming | `flex_color_scheme` | Material 3 |
| i18n | `slang` + `slang_flutter` + `slang_build_runner` | Type-safe, feature-scoped |
| Testing | `mocktail` | Mocking framework |
| Linting | Custom `analysis_options.yaml` | Based on recommended + custom rules |
| CI/CD | GitHub Actions | Build, test, lint, coverage |
| Logging | `logging` (dev console) + `sentry_flutter` (prod) | Environment-aware |
| Code Gen | `build_runner` | Single pipeline for all generators |
| Scaffolding | `mason_cli` + custom bricks | Feature, repository, viewmodel bricks |
| Documentation | ADRs + architecture rules | AI-ready development docs |

---

## Architecture Overview

Follows the **Flutter Architecture Guide** (MVVM) combined with **Clean Architecture** layering:

```
┌──────────────────────────────────────────────┐
│  UI LAYER                                    │
│  Views (Widgets) + ViewModels (Notifiers)    │
├──────────────────────────────────────────────┤
│  DOMAIN LAYER (optional per feature)         │
│  Use Cases (only when cross-repository)      │
├──────────────────────────────────────────────┤
│  DATA LAYER                                  │
│  Repositories (source of truth) + Services   │
└──────────────────────────────────────────────┘
```

**Key rules:**
- Views know only their ViewModel (Riverpod provider)
- ViewModels call Repositories (or Use Cases when needed)
- Repositories call Services and map DTOs → domain models
- Services are stateless API wrappers (retrofit-generated)
- Domain layer is optional — only add use cases when logic spans multiple repositories

---

## Directory Structure

```
lib/
├── main.dart                           # Single entry point (env via --dart-define-from-file)
├── bootstrap.dart                      # App initialization
├── app.dart                            # Root App widget (MaterialApp.router)
│
├── core/
│   ├── env/
│   │   └── app_environment.dart        # Env enum (dev/staging/prod) + compile-time config
│   │
│   ├── error/
│   │   ├── result.dart                 # sealed Result<T> = Success | Failure
│   │   └── failures.dart               # Failure hierarchy (sealed classes)
│   │
│   ├── http/
│   │   ├── dio_provider.dart           # Riverpod provider for configured Dio instance
│   │   ├── dio_api_exception.dart      # Dio-specific exception types (ServerException, etc.)
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart       # Adds Bearer token
│   │       ├── refresh_token_interceptor.dart  # Auto-refresh on 401 (QueuedInterceptor)
│   │       ├── logging_interceptor.dart    # Logs requests/responses
│   │       └── error_interceptor.dart      # Maps DioException → DioApiException
│   │
│   ├── storage/
│   │   ├── secure_storage_provider.dart    # FlutterSecureStorage provider
│   │   ├── shared_prefs_provider.dart      # SharedPreferences provider
│   │   └── token_storage.dart              # ITokenStorage + SecureTokenStorage impl
│   │
│   ├── routing/
│   │   ├── app_router.dart             # @AutoRouterConfig with all routes
│   │   ├── app_router.gr.dart          # (generated)
│   │   └── guards/
│   │       └── auth_guard.dart         # AutoRouteGuard checking auth state
│   │
│   ├── theme/
│   │   ├── app_theme.dart              # Light/dark ThemeData via FlexColorScheme
│   │   ├── color_palette.dart          # App color constants
│   │   └── theme_extensions.dart       # Custom ThemeExtensions (semantic colors)
│   │
│   ├── logging/
│   │   ├── app_logger.dart             # IAppLogger interface + ConsoleLogger
│   │   ├── logger_provider.dart        # Riverpod provider for logger
│   │   └── sentry_reporter.dart        # Sentry integration (staging/prod)
│   │
│   ├── feature_flags/
│   │   ├── feature_flag.dart           # FeatureFlag enum
│   │   └── feature_flag_provider.dart  # Riverpod Notifier for flag management
│   │
│   ├── l10n/                           # slang translations (core strings)
│   │   ├── strings.i18n.json           # English (default)
│   │   └── strings_es.i18n.json        # Spanish
│   │
│   ├── presentation/
│   │   ├── responsive/
│   │   │   ├── breakpoints.dart        # Breakpoint enum (compact/medium/expanded/large/extraLarge)
│   │   │   └── responsive_builder.dart # Widget that rebuilds based on breakpoint
│   │   └── widgets/
│   │       ├── adaptive_scaffold.dart  # Responsive shell: bottom nav (mobile), rail (tablet), drawer (desktop)
│   │       ├── app_snackbar.dart       # Standardized error/success snackbars
│   │       └── connectivity_banner.dart # Offline/online banner using connectivity_plus
│   │
│   └── utils/
│       └── failure_message_mapper.dart # Maps Failure → localized user-facing string
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── services/
│   │   │   │   └── auth_service.dart       # @RestApi() retrofit service
│   │   │   ├── models/
│   │   │   │   ├── login_request.dart      # @MappableClass DTO
│   │   │   │   ├── login_response.dart     # @MappableClass DTO
│   │   │   │   └── user_dto.dart           # @MappableClass DTO
│   │   │   ├── mappers/
│   │   │   │   └── user_mapper.dart        # Extension: UserDto → User
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart    # AuthRepository implements IAuthRepository
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart               # @MappableClass domain entity
│   │   │   ├── repositories/
│   │   │   │   └── i_auth_repository.dart  # Abstract repository interface
│   │   │   └── failures/
│   │   │       └── auth_failure.dart       # sealed AuthFailure extends Failure
│   │   ├── ui/
│   │   │   ├── view_models/
│   │   │   │   └── auth_view_model.dart    # @riverpod AsyncNotifier
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   └── register_page.dart
│   │   │   └── widgets/
│   │   │       └── auth_form.dart
│   │   └── l10n/
│   │       ├── auth_strings.i18n.json
│   │       └── auth_strings_es.i18n.json
│   │
│   ├── dashboard/
│   │   ├── data/
│   │   │   └── ...                     # (same pattern)
│   │   ├── ui/
│   │   │   ├── view_models/
│   │   │   │   └── dashboard_view_model.dart
│   │   │   └── pages/
│   │   │       └── dashboard_page.dart
│   │   └── l10n/
│   │       └── ...
│   │
│   ├── profile/
│   │   ├── data/
│   │   │   ├── services/
│   │   │   │   └── profile_service.dart    # CRUD API
│   │   │   ├── models/
│   │   │   │   └── profile_dto.dart
│   │   │   ├── mappers/
│   │   │   │   └── profile_mapper.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── profile.dart
│   │   │   ├── repositories/
│   │   │   │   └── i_profile_repository.dart
│   │   │   └── failures/
│   │   │       └── profile_failure.dart
│   │   ├── ui/
│   │   │   ├── view_models/
│   │   │   │   └── profile_view_model.dart
│   │   │   ├── pages/
│   │   │   │   └── profile_page.dart
│   │   │   └── widgets/
│   │   │       └── profile_form.dart
│   │   └── l10n/
│   │       └── ...
│   │
│   └── settings/
│       ├── ui/
│       │   ├── view_models/
│       │   │   ├── theme_view_model.dart       # Persists theme to SharedPreferences
│       │   │   └── locale_view_model.dart      # Persists locale
│       │   └── pages/
│       │       └── settings_page.dart
│       └── l10n/
│           └── ...
│
├── gen/                                # (generated) slang output
│   └── strings.g.dart
│
test/                                   # Mirrors lib/ structure
├── core/
│   ├── error/
│   ├── network/
│   └── ...
├── features/
│   ├── auth/
│   │   ├── data/repositories/
│   │   ├── domain/
│   │   └── ui/view_models/
│   └── ...
└── helpers/
    ├── test_utils.dart                 # ProviderContainer setup helpers
    ├── mocks.dart                      # Shared mock classes
    └── fakes.dart                      # Shared fakes

CLAUDE.md                               # AI agent context file (conventions, pointers, commands)

config/
├── development.json
├── staging.json
└── production.json

docs/
├── adrs/                              # Architecture Decision Records
│   ├── 001-riverpod-for-state-and-di.md
│   ├── 002-auto-route-for-navigation.md
│   ├── 003-dio-retrofit-for-networking.md
│   ├── 004-dart-mappable-for-models.md
│   ├── 005-sealed-result-for-errors.md
│   ├── 006-slang-for-i18n.md
│   ├── 007-feature-first-architecture.md
│   ├── 008-mvvm-with-clean-architecture.md
│   ├── 009-environment-configuration.md
│   └── 010-logging-and-monitoring.md
├── architecture-rules/                # AI-ready rules
│   ├── 01-project-structure.md
│   ├── 02-layer-responsibilities.md
│   ├── 03-riverpod-patterns.md
│   ├── 04-navigation-rules.md
│   ├── 05-error-handling.md
│   ├── 06-data-modeling.md
│   ├── 07-testing-standards.md
│   ├── 08-api-integration.md
│   ├── 09-theming.md
│   ├── 10-i18n.md
│   ├── 11-security.md
│   └── 12-documentation.md
└── ARCHITECTURE.md                    # High-level overview

bricks/
├── feature/                           # Mason brick: full feature scaffold
├── repository/                        # Mason brick: repository + service
└── view_model/                        # Mason brick: page + viewmodel
```

---

## Implementation Steps

### Phase 1: Project Scaffold & Core Infrastructure

#### 1.1 Create Flutter project
- **Path**: `~/Documents/Git/GitHub/PointSource/flutter_starter`
- **Package name**: `flutter_starter`
- `flutter create --org com.pointsource --project-name flutter_starter ~/Documents/Git/GitHub/PointSource/flutter_starter`
- Initialize git repo
- Set up `pubspec.yaml` with all dependencies
- Configure `analysis_options.yaml` with custom strict lint rules
- Configure `build.yaml` for all code generators (dart_mappable, retrofit, auto_route, riverpod, slang)

#### 1.2 Error handling foundation — `lib/core/error/`
- **`result.dart`** — Sealed Result type:
  ```dart
  sealed class Result<T> {
    const Result();

    R when<R>({required R Function(T data) success, required R Function(Failure failure) failure});
    Result<R> map<R>(R Function(T data) transform);
    Result<R> flatMap<R>(Result<R> Function(T data) transform);
    T getOrElse(T Function(Failure failure) orElse);
    T? getOrNull();
    bool get isSuccess;
    bool get isFailure;
  }

  final class Success<T> extends Result<T> { ... }
  final class Err<T> extends Result<T> { ... }
  ```
- **`failures.dart`** — Failure hierarchy:
  ```dart
  sealed class Failure {
    String get message;
    StackTrace? get stackTrace;
  }

  // Infrastructure failures
  sealed class NetworkFailure extends Failure { ... }   // noConnection, timeout
  sealed class ServerFailure extends Failure { ... }     // badResponse(statusCode), unauthorized, forbidden
  sealed class CacheFailure extends Failure { ... }      // readError, writeError

  // Feature failures defined in each feature's domain/failures/
  ```
- **`dio_api_exception.dart`** — Dio-specific exception types caught at the service/repository boundary

#### 1.3 Environment configuration — `lib/core/env/`
- **`app_environment.dart`** — Adapted from original's `application_environment.dart`
  - Enum with `development`, `staging`, `production`
  - Compile-time constants via `String.fromEnvironment` / `bool.fromEnvironment`
  - `apiBaseUrl`, `sentryDsn`, `sentrySampleRate`, `sentryEnabled`
  - Strict mode validation for CI

#### 1.4 Storage — `lib/core/storage/`
- **`secure_storage_provider.dart`** — `@riverpod` provider for FlutterSecureStorage
- **`shared_prefs_provider.dart`** — `@riverpod` provider for SharedPreferences (async init in bootstrap)
- **`token_storage.dart`** — `ITokenStorage` interface + `SecureTokenStorage` implementation
  - `saveTokens(accessToken, refreshToken)`
  - `getAccessToken()`, `getRefreshToken()`, `clearTokens()`

#### 1.5 HTTP Infrastructure — `lib/core/http/`
- **`dio_provider.dart`** — Riverpod provider creating Dio with all interceptors:
  ```dart
  @riverpod
  Dio dio(Ref ref) {
    final dio = Dio(BaseOptions(baseUrl: AppEnvironment.current.apiBaseUrl));
    dio.interceptors.addAll([
      AuthInterceptor(ref.read(tokenStorageProvider)),
      RefreshTokenInterceptor(ref.read(tokenStorageProvider), dio),
      LoggingInterceptor(ref.read(loggerProvider)),
      ErrorInterceptor(),
    ]);
    return dio;
  }
  ```
- **`auth_interceptor.dart`** — Reads access token from storage, adds `Authorization: Bearer <token>` header
- **`refresh_token_interceptor.dart`** — Extends `QueuedInterceptor`:
  - On 401, acquires lock, calls refresh endpoint, retries original request
  - Queues concurrent requests while refresh is in progress
  - On refresh failure, clears tokens and signals auth state change
- **`logging_interceptor.dart`** — Logs request/response via IAppLogger with sensitive data redaction
- **`error_interceptor.dart`** — Maps DioException → DioApiException (ServerException, NetworkException, TimeoutException)

#### 1.6 Logging — `lib/core/logging/`
- **`app_logger.dart`** — `IAppLogger` interface with `debug`, `info`, `warning`, `error`, `fatal`
- **`ConsoleLogger`** — Uses `dart:developer` `log()` in development
- **`sentry_reporter.dart`** — Sentry integration for staging/prod
- **`logger_provider.dart`** — `@riverpod` provider that returns environment-appropriate logger

#### 1.7 Routing — `lib/core/routing/`
- **`app_router.dart`** — `@AutoRouterConfig` with:
  - Unauthenticated routes: LoginRoute, RegisterRoute
  - Shell route (AutoTabsRouter) wrapping AdaptiveScaffold: DashboardRoute, ProfileRoute, SettingsRoute
  - Auth guard applied to shell and protected routes
  - Deep linking support
- **`auth_guard.dart`** — `AutoRouteGuard` that checks auth state provider:
  ```dart
  class AuthGuard extends AutoRouteGuard {
    final Ref _ref;
    @override
    void onNavigation(NavigationResolver resolver, StackRouter router) {
      final isAuth = _ref.read(authStateProvider).isAuthenticated;
      if (isAuth) { resolver.next(); }
      else { resolver.redirect(const LoginRoute()); }
    }
  }
  ```
- **`app_router` as Riverpod provider**: Create router inside a provider so `ref` can be passed to AuthGuard

#### 1.8 Theming — `lib/core/theme/`
- **`app_theme.dart`** — FlexColorScheme light/dark with Material 3 (`useMaterial3: true`)
- **`color_palette.dart`** — Brand color constants
- **`theme_extensions.dart`** — Semantic colors (success, warning, info, etc.)

#### 1.9 Feature flags — `lib/core/feature_flags/`
- **`feature_flag.dart`** — Enum of flags
- **`feature_flag_provider.dart`** — `@riverpod` Notifier managing flag state with SharedPreferences persistence

#### 1.10 i18n setup — `lib/core/l10n/`
- Configure slang in `build.yaml` or `slang.yaml`
- Create `strings.i18n.json` (English) and `strings_es.i18n.json` (Spanish)
- Feature-scoped: each feature has its own `l10n/` directory with slang JSON files
- **Note on slang feature-scoping**: slang supports namespaces within a single file set, OR separate packages. For a monorepo starter, use **namespaced keys** in the core strings file (e.g., `auth.login_button`, `profile.edit_title`) rather than truly separate translation file sets, since slang generates a single `Translations` class. This is simpler and avoids the complexity of multi-package slang.

#### 1.11 Responsive/adaptive layout — `lib/core/presentation/`
- **`breakpoints.dart`** — Breakpoint enum and width thresholds:
  - `compact` (< 600dp) — phone
  - `medium` (600–840dp) — small tablet
  - `expanded` (840–1200dp) — large tablet / small desktop
  - `large` (1200dp+) — desktop
- **`responsive_builder.dart`** — Widget that provides current breakpoint to children via `LayoutBuilder`
- **`adaptive_scaffold.dart`** — Shell widget wrapping `AutoTabsRouter`:
  - compact → `Scaffold` + `BottomNavigationBar`
  - medium → `Scaffold` + `NavigationRail`
  - expanded → `Scaffold` + `NavigationRail` with labels
  - large → `Scaffold` + persistent `NavigationDrawer`
  - Preserves tab state across breakpoint changes
- **`connectivity_banner.dart`** — Material banner that shows when device goes offline (using `connectivity_plus`)

#### 1.12 Bootstrap — `lib/bootstrap.dart`
- Initialize Flutter bindings
- Initialize SharedPreferences (async)
- Register dart_mappable FIC hooks
- Initialize Sentry (if staging/prod)
- Set up global error handlers (Flutter.onError, PlatformDispatcher.onError, runZonedGuarded)
- Create ProviderScope with overrides (SharedPreferences instance)
- Run app

#### 1.13 App widget — `lib/app.dart`
- `ProviderScope` wrapping `MaterialApp.router`
- auto_route's `router.config()` for routerConfig
- FlexColorScheme theme from theme provider
- slang locale from locale provider

---

### Phase 2: Auth Feature (Reference Implementation)

This is the **canonical example** that all other features follow.

#### 2.1 Domain layer — `lib/features/auth/domain/`
- **`user.dart`** — `@MappableClass()` domain entity with `id`, `email`, `name`
- **`i_auth_repository.dart`** — Abstract interface:
  ```dart
  abstract class IAuthRepository {
    Future<Result<User>> login(String email, String password);
    Future<Result<User>> register(String email, String password, String name);
    Future<Result<void>> logout();
    Future<Result<User?>> getCurrentUser();
  }
  ```
- **`auth_failure.dart`** — Sealed class:
  ```dart
  sealed class AuthFailure extends Failure {
    const AuthFailure(super.message, [super.stackTrace]);
  }
  final class InvalidCredentials extends AuthFailure { ... }
  final class EmailAlreadyInUse extends AuthFailure { ... }
  final class SessionExpired extends AuthFailure { ... }
  final class AuthServerError extends AuthFailure { ... }
  ```

#### 2.2 Data layer — `lib/features/auth/data/`
- **`auth_service.dart`** — Retrofit API:
  ```dart
  @RestApi(parser: .DartMappable)
  abstract class AuthService {
    factory AuthService(Dio dio) = _AuthService;

    @POST('/auth/login')
    Future<LoginResponse> login(@Body() LoginRequest request);

    @POST('/auth/register')
    Future<LoginResponse> register(@Body() RegisterRequest request);

    @POST('/auth/logout')
    Future<void> logout();

    @GET('/auth/me')
    Future<UserDto> getCurrentUser();
  }
  ```
- **`login_request.dart`**, **`login_response.dart`**, **`user_dto.dart`** — `@MappableClass()` DTOs
- **`user_mapper.dart`** — Extension `UserDto.toDomain() → User`
- **`auth_repository.dart`** — Implements `IAuthRepository`:
  - Wraps service calls in try/catch
  - Maps exceptions → `Result<T>` (Success or Err with AuthFailure)
  - Manages token storage on login/register/logout

#### 2.3 UI layer — `lib/features/auth/ui/`
- **`auth_view_model.dart`** — `@riverpod` AsyncNotifier:
  ```dart
  @riverpod
  class AuthViewModel extends _$AuthViewModel {
    @override
    Future<AuthState> build() async {
      final result = await ref.read(authRepositoryProvider).getCurrentUser();
      return result.when(
        success: (user) => user != null ? AuthState.authenticated(user) : AuthState.unauthenticated(),
        failure: (_) => AuthState.unauthenticated(),
      );
    }

    Future<void> login(String email, String password) async { ... }
    Future<void> register(...) async { ... }
    Future<void> logout() async { ... }
  }
  ```
- **`auth_state.dart`** — `@MappableClass()` with union-like pattern or simple class
- **`login_page.dart`** — ConsumerWidget reading authViewModelProvider
- **`register_page.dart`**
- Provider for repository: `@riverpod IAuthRepository authRepository(Ref ref) => AuthRepository(ref.read(authServiceProvider), ref.read(tokenStorageProvider));`
- Provider for service: `@riverpod AuthService authService(Ref ref) => AuthService(ref.read(dioProvider));`

#### 2.4 Auth state for routing
- A separate `@riverpod` provider exposing auth state as a stream/listenable for the AuthGuard

---

### Phase 3: Dashboard, Profile, Settings Features

#### 3.1 Dashboard
- Simple page with greeting, navigation to other sections
- Demonstrates reading auth state to display user info

#### 3.2 Profile (CRUD reference)
- Full data layer: ProfileService (retrofit), ProfileDto, ProfileRepository
- Domain: Profile entity, IProfileRepository, ProfileFailure
- UI: ProfileViewModel with load/update operations
- Demonstrates: loading states, error handling, form validation, optimistic updates

#### 3.3 Settings
- **ThemeViewModel** — `@riverpod` Notifier persisting theme mode to SharedPreferences
- **LocaleViewModel** — `@riverpod` Notifier persisting locale to SharedPreferences
- Settings page with theme toggle (system/light/dark) and language selector
- Demonstrates: local-only state without API calls, persistence pattern

---

### Phase 4: Testing Infrastructure

#### 4.1 Test helpers — `test/helpers/`
- **`test_utils.dart`** — Helper to create ProviderContainer with overrides:
  ```dart
  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }
  ```
- **`mocks.dart`** — Shared mocks: `MockAuthRepository`, `MockProfileRepository`, `MockDio`, etc.
- **`fakes.dart`** — Fake data factories: `FakeUser`, `FakeProfile`, etc.
- **`pump_app.dart`** — Widget test helper wrapping with ProviderScope + MaterialApp.router

#### 4.2 Test patterns
- **Repository tests**: Override service provider, verify Result mapping
- **ViewModel tests**: Use ProviderContainer with mock repository overrides, verify state transitions
- **Widget tests**: Wrap in ProviderScope with mock overrides, pump, verify UI
- **Integration tests**: Full flow with mock server

#### 4.3 Coverage target
- Aim for high coverage on repositories, viewmodels, and domain logic
- Document coverage expectations per layer in architecture rules

---

### Phase 5: Documentation

#### 5.1 CLAUDE.md (AI agent context file)
Root-level file that AI coding agents (Claude Code, Cursor, Copilot, etc.) read automatically. Contains:
- Project overview and architecture summary
- Pointers to `docs/architecture-rules/` for detailed patterns
- Coding conventions: naming, file organization, import ordering
- Documentation standards (see 5.5 below)
- Common commands: build, test, code gen, lint
- "When adding a new feature, follow the Auth feature as the reference implementation"
- Pointers to ADRs for rationale behind decisions

#### 5.2 ADRs (10 records)
Each ADR follows the format: Title, Status, Context, Decision, Consequences
1. Riverpod for state management and DI
2. auto_route for navigation
3. dio + retrofit for networking
4. dart_mappable for data modeling
5. Sealed Result type for error handling
6. slang for internationalization
7. Feature-first architecture
8. MVVM with Clean Architecture layers
9. Environment configuration strategy
10. Logging and monitoring approach

#### 5.3 Architecture rules (12 files)
Each rule file describes the pattern, provides examples, and lists dos/don'ts. Designed for AI consumption.
1. Project structure
2. Layer responsibilities
3. Riverpod patterns
4. Navigation rules
5. Error handling
6. Data modeling
7. Testing standards
8. API integration
9. Theming
10. i18n
11. Security
12. **Documentation standards** (see 5.5)

#### 5.4 ARCHITECTURE.md
High-level overview with diagrams, layer descriptions, data flow, and links to ADRs.

#### 5.5 In-code documentation standards
Documented in `docs/architecture-rules/12-documentation.md` and enforced by convention:

**Docstrings (required on all public APIs):**
- Every public class, method, property, and top-level function gets a `///` doc comment
- First line: single sentence describing *what* it does (imperative mood: "Creates...", "Returns...", "Handles...")
- Additional lines (when needed): *why* it exists, edge cases, usage examples
- Parameters documented with `[paramName]` inline references when non-obvious
- Example:
  ```dart
  /// Attempts to log in with the given [email] and [password].
  ///
  /// Returns [Success] with the authenticated [User] on success,
  /// or [Err] with an [AuthFailure] on failure (invalid credentials,
  /// network error, etc.).
  Future<Result<User>> login(String email, String password);
  ```

**Inline comments (for non-obvious logic only):**
- Explain *why*, not *what* — the code shows what, comments explain intent
- Required for: workarounds, non-obvious business rules, performance optimizations, regex patterns
- Not needed for: self-explanatory code, simple assignments, standard patterns

**File-level comments:**
- Each file starts with a `///` doc comment on the primary class/function explaining its role in the architecture
- Feature barrel files (`index.dart`) document what the feature does at a high level

**Generated code:**
- Never document generated files (`.g.dart`, `.gr.dart`)
- Document the source annotations that drive generation (e.g., the `@RestApi()` class, the `@riverpod` function)

**Markdown docs:**
- ADRs updated when a decision changes
- Architecture rules updated when a pattern evolves
- CLAUDE.md updated when new conventions are established
- README.md kept current with setup/build/test instructions

#### 5.6 README.md
Getting started, project structure, development workflow, build commands, contribution guide.

---

### Phase 6: Mason Bricks

#### 6.1 `feature` brick
Generates complete feature with: data/ (service, models, mappers, repository), domain/ (entities, repository interface, failures), ui/ (view_models, pages, widgets), l10n/

#### 6.2 `repository` brick
Generates: retrofit service, DTOs, mapper, repository interface, repository implementation, providers

#### 6.3 `view_model` brick
Generates: page, viewmodel (AsyncNotifier), state class, providers

---

### Phase 7: CI/CD

#### 7.1 GitHub Actions workflow
- **Lint**: `dart analyze`
- **Test**: `flutter test --coverage`
- **Build**: `flutter build` (verify compilation)
- **Code gen check**: Verify generated files are up-to-date

---

## Design Decisions & Rationale

### 1. Why Result<T> over fpdart or try/catch
fpdart's `Either` in Dart is verbose due to Dart's lack of native union return types and limited exhaustive checking on Left/Right. A custom sealed `Result<T>` provides:
- **Explicit type signatures** — `Future<Result<User>>` makes failure possibility visible
- **Forced handling** — You can't accidentally ignore a failure (unlike try/catch)
- **Composable** — `map`, `flatMap`, `when` are cleaner than nested try/catch
- **No stack unwinding** — Failures are values, not control flow
- **Exhaustive switching** — On feature-specific failures via `switch` on the sealed failure type

Pattern: Repositories return `Result<T>`. ViewModels call `.when()`. Feature-specific failures are inspected with `switch` only when different UI responses are needed per failure type.

### 2. Single main.dart (not per-flavor)
Using a single `main.dart` with `--dart-define-from-file` for environment selection. Multiple entry points only add value when you need different widget trees per flavor — Riverpod provider overrides handle that better. Simpler and less to maintain.

### 3. dart_mappable usage strategy
Use dart_mappable for DTOs and simple domain models (`toJson`/`fromJson` + `copyWith`). Use plain Dart 3 sealed classes for Result, Failures, and state unions (dart_mappable doesn't have freezed's union serialization, and these types rarely need JSON serialization anyway).

### 4. fast_immutable_collections + dart_mappable
Simple `MappableHook` that converts `IList` ↔ `List` using FIC's built-in `unlock` (to mutable) and `IList()` constructor (from mutable). dart_mappable handles recursive encoding/decoding of the inner types. Register globally in `mappable_hooks.dart` at app startup.

### 5. Riverpod + auto_route guard interaction
auto_route guards don't have `ref` by default. Solution: Create the `AppRouter` inside a Riverpod provider and pass `ref` to the `AuthGuard` constructor. The guard reads auth state via `ref.read(authStateProvider)`.

### 6. slang feature-scoping
slang generates a single `Translations` class. Use **namespaced keys** within the core translation files (e.g., `auth.loginButton`, `profile.editTitle`) rather than separate slang configs per feature. Simpler code gen, logically organized strings.

### 7. Token refresh ↔ Riverpod bridge
Dio interceptors live outside Riverpod's provider tree. Pass an `onAuthExpired` callback from the dio provider to the `RefreshTokenInterceptor`. On refresh failure, the callback calls `ref.invalidate(authViewModelProvider)` to trigger re-evaluation of auth state.

### 8. SharedPreferences async initialization
Initialize in `bootstrap.dart`, pass as ProviderScope override:
```dart
final prefs = await SharedPreferences.getInstance();
runApp(ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  child: const App(),
));
```

### 9. Adaptive/responsive navigation
Replicate the original repo's `AdaptiveNavigationScaffold` pattern using auto_route's `AutoTabsRouter`:
- **Compact** (< 600dp): Bottom navigation bar
- **Medium** (600-840dp): Navigation rail
- **Expanded** (840-1200dp): Navigation rail with labels
- **Large** (1200dp+): Persistent navigation drawer

The shell route wraps all authenticated routes. A `Breakpoints` enum + `ResponsiveBuilder` widget drives layout decisions.

### 10. Connectivity
`connectivity_plus` provides a stream of connectivity changes. A `connectivityProvider` exposes this as a Riverpod stream. A `ConnectivityBanner` widget shows/hides an offline indicator. Repositories can optionally check connectivity before API calls to fail fast with a user-friendly message.

### 11. No hooks
Skipping flutter_hooks/hooks_riverpod. They require strict ordering discipline and lack lint rules to prevent misuse. For reducing StatefulWidget boilerplate, `ConsumerStatefulWidget` + `ref.listen` covers most cases. TextEditingController/FocusNode lifecycle can be managed with a simple mixin if needed.

---

## Verification Plan

### How to test the completed template

1. **Build check**: `flutter build apk --debug` and `flutter build ios --debug --no-codesign` should compile without errors
2. **Code gen**: `dart run build_runner build --delete-conflicting-outputs` should complete without errors
3. **Lint**: `dart analyze` should pass with zero issues
4. **Tests**: `flutter test` should pass all tests
5. **Coverage**: `flutter test --coverage` and verify coverage report
6. **Run the app**:
   - `flutter run --dart-define-from-file=config/development.json`
   - Verify login page loads
   - Verify navigation works (auth → dashboard → profile → settings)
   - Verify theme toggle persists across restarts
   - Verify locale switching works
7. **Mason bricks**: `mason make feature --feature_name test_feature` should generate correct structure
8. **Environment configs**: Verify dev/staging/prod configs load correctly

---

## Implementation Order

1. Project creation + pubspec.yaml + build.yaml + analysis_options.yaml
2. Core error handling (Result, Failures, Exceptions)
3. Core environment config + config JSON files (dev/staging/prod)
4. Core storage (secure storage, shared prefs, token storage)
5. Core networking (dio + interceptors + connectivity_plus)
6. Core logging
7. Core theming
8. Core i18n (slang setup + mappable hooks for FIC)
9. Core routing (auto_route + auth guard)
10. Core presentation widgets (adaptive scaffold, responsive breakpoints, connectivity banner, snackbar)
11. Bootstrap + App widget
12. Auth feature (full reference implementation)
13. Dashboard feature
14. Profile feature (CRUD reference)
15. Settings feature (persistence reference)
16. Feature flags
17. Tests for all the above
18. Documentation (ADRs, architecture rules, README, ARCHITECTURE.md)
19. Mason bricks
20. CI/CD GitHub Actions workflow
