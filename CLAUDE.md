# CLAUDE.md -- AI Agent Context

This file provides context for AI coding agents (Claude Code, Cursor, Copilot, etc.)
working in the `flutter_starter` codebase.

## Project Overview

Enterprise-ready Flutter starter template using **MVVM + Clean Architecture**.
Designed as a reference implementation for production Flutter applications with
type-safe routing, code-generated providers, and explicit error handling.

## Tech Stack

| Concern | Package | Notes |
|---|---|---|
| State / DI | `flutter_riverpod` + `riverpod_generator` | `@riverpod` code gen for all providers |
| Navigation | `auto_route` + `auto_route_generator` | Type-safe routes, guards, nested nav |
| HTTP | `dio` + `retrofit` + `retrofit_generator` | Code-gen API services per feature |
| Data Models | `dart_mappable` + `dart_mappable_builder` | Immutable models, JSON, copyWith |
| Collections | `fast_immutable_collections` | IList, IMap, ISet for domain models |
| Error Handling | Custom sealed `Result<T>` | No fpdart -- failures are values |
| Storage | `shared_preferences` + `flutter_secure_storage` | Settings + encrypted tokens |
| Theming | `flex_color_scheme` | Material 3 light/dark |
| i18n | `slang` + `slang_flutter` | Type-safe, namespaced keys |
| Testing | `mocktail` | Mocking framework |
| Monitoring | `sentry_flutter` | Staging/production error reporting |
| Code Gen | `build_runner` | Single pipeline for all generators |

## Architecture

MVVM with Clean Architecture layers, feature-first directory structure.

```
lib/
  main.dart              # Single entry point
  bootstrap.dart         # Async init (SharedPreferences, Sentry, error handlers)
  app.dart               # Root MaterialApp.router widget

  core/                  # Shared infrastructure
    env/                 # AppEnvironment enum + compile-time config
    error/               # Result<T>, Failure hierarchy, AppException
    network/             # Dio provider + interceptors (auth, refresh, logging, error)
    storage/             # Token storage, secure storage, shared prefs providers
    routing/             # AppRouter, route guards
    theme/               # FlexColorScheme light/dark themes
    logging/             # IAppLogger, Sentry integration
    feature_flags/       # Feature flag enum + provider
    presentation/        # Shared widgets (AdaptiveScaffold, breakpoints)
    l10n/                # Core translation strings
    utils/               # Failure-to-message mapping

  features/              # Feature modules (each follows data/domain/ui pattern)
    auth/                # CANONICAL REFERENCE -- follow this for new features
    dashboard/
    profile/
    settings/
```

### Feature Directory Pattern

Each feature follows this structure:

```
features/<name>/
  data/
    services/            # @RestApi() retrofit service
    models/              # @MappableClass() DTOs
    mappers/             # DTO-to-domain mapping extensions
    repositories/        # Repository implementation
  domain/
    entities/            # @MappableClass() domain models
    repositories/        # Abstract repository interface (IXxxRepository)
    failures/            # sealed XxxFailure extends Failure
  ui/
    view_models/         # @riverpod AsyncNotifier + infrastructure providers
    pages/               # @RoutePage() ConsumerWidget pages
    widgets/             # Feature-specific widgets
  l10n/                  # Feature-scoped translation strings
```

The domain layer is optional -- only add it when the feature needs its own
entity types, repository abstraction, or failure hierarchy.

## Key Conventions

### File Structure
- `library;` directive at top of every file, after the `///` doc comment
- All public APIs must have `///` doc comments (imperative mood first line)
- Single quotes for strings
- Package imports: `package:flutter_starter/...`

### Code Generation
- Generated file extensions: `.g.dart`, `.gr.dart`, `.mapper.dart`
- **Never edit generated files**
- Annotations that trigger code gen:
  - `@riverpod` / `@Riverpod(keepAlive: true)` -- provider generation
  - `@MappableClass()` -- data model generation (JSON, copyWith)
  - `@RestApi()` -- retrofit HTTP service generation
  - `@RoutePage()` -- auto_route page registration
- Files using code gen include `part '<filename>.g.dart';`

### State Management (Riverpod)
- Views use `ConsumerWidget` or `ConsumerStatefulWidget`
- ViewModels are `@riverpod` AsyncNotifier classes
- Infrastructure providers (services, repositories) are `@riverpod` functions
- Use `@Riverpod(keepAlive: true)` for app-lifetime providers (Dio, router, auth)
- Use `ref.read()` for one-shot reads, `ref.watch()` for reactive dependencies

### Error Handling
- Repositories return `Future<Result<T>>` (never throw)
- `Result<T>` is a sealed class: `Success<T>` or `Err<T>`
- Infrastructure failures: `NetworkFailure`, `ServerFailure`, `CacheFailure`
- Feature failures: sealed class extending `Failure` (e.g., `AuthFailure`)
- ViewModels call `result.when(success:, failure:)` to map to `AsyncValue`
- Exceptions (`AppException`) live only in the data layer, caught by repositories

### Navigation
- Routes defined in `lib/core/routing/app_router.dart`
- `AuthGuard` protects authenticated routes via `authStateProvider`
- Shell route wraps tabbed navigation with `AdaptiveScaffold`
- Pages annotated with `@RoutePage()` for auto_route generation

### Environment Configuration
- Single `main.dart` entry point
- Environment selected via `--dart-define-from-file=config/<env>.json`
- Config files: `config/development.json`, `config/staging.json`, `config/production.json`
- `AppEnvironment` enum reads compile-time constants

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (all generators)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Generate translations (slang)
dart run slang

# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Static analysis
dart analyze

# Run the app (development)
flutter run --dart-define-from-file=config/development.json

# Run the app (staging)
flutter run --dart-define-from-file=config/staging.json

# Release build (production)
flutter build apk --release --dart-define-from-file=config/production.json
```

## Error Handling Flow

```
DioException --> ErrorInterceptor --> AppException
    (in Dio)                          (in DioException.error)

AppException --> Repository catch --> Failure (feature-specific)
                                  --> Result<T> (Success or Err)

Result<T> --> ViewModel .when() --> AsyncValue (AsyncData or AsyncError)
          --> UI reacts to AsyncValue states
```

## Adding a New Feature

**Follow the Auth feature (`lib/features/auth/`) as the canonical reference.**

1. Create the directory structure under `lib/features/<name>/`
2. Define domain entities (`@MappableClass()`) and repository interface
3. Define feature-specific failures (sealed class extending `Failure`)
4. Create the retrofit service (`@RestApi()`) and DTOs
5. Implement the repository (returns `Result<T>`, catches exceptions)
6. Create the ViewModel (`@riverpod` AsyncNotifier) with infrastructure providers
7. Build pages (`@RoutePage()`, `ConsumerWidget`) and widgets
8. Register routes in `app_router.dart`
9. Run `dart run build_runner build --delete-conflicting-outputs`
10. Add tests mirroring the `lib/` structure under `test/`

## Detailed Documentation

- **Architecture overview**: `docs/ARCHITECTURE.md`
- **Architecture Decision Records**: `docs/adrs/`
- **Architecture rules and patterns**: `docs/architecture-rules/`
