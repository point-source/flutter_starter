# Flutter Starter

An enterprise-ready Flutter starter template with clean architecture, code generation, and opinionated project structure.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart)
![Riverpod](https://img.shields.io/badge/Riverpod-3.x-00B4D8)
![AutoRoute](https://img.shields.io/badge/AutoRoute-11.x-6C63FF)
![Retrofit](https://img.shields.io/badge/Retrofit-4.x-009688)
![License](https://img.shields.io/badge/License-TBD-lightgrey)

---

## Architecture

This project follows **feature-first clean architecture** with three layers per feature:

```
feature/
  data/       -- Models, services (API), repositories (impl), mappers
  domain/     -- Entities, failures, repository interfaces
  ui/         -- Pages, view models (Riverpod), widgets
```

Shared infrastructure lives in `lib/core/`. State management uses Riverpod with code-generated providers. Navigation uses AutoRoute with typed route guards. Networking uses Dio + Retrofit for type-safe API clients.

For a full breakdown, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) (if available) and the ADRs in `docs/adrs/`.

---

## Prerequisites

| Tool       | Version       |
|------------|---------------|
| Flutter    | Stable channel (3.x) |
| Dart       | >= 3.10.8     |

Verify your setup:

```bash
flutter doctor
```

---

## Getting Started

### Using This Template for a New Project

```bash
# 1. Create a new repository from this template
#    Option A: Use GitHub's "Use this template" button
#    Option B: Clone and create new repo manually
git clone https://github.com/PointSource/flutter_starter.git my-new-app
cd my-new-app
rm -rf .git
git init

# 2. Add template as remote for future updates
git remote add template https://github.com/PointSource/flutter_starter.git
git fetch template

# 3. Install dependencies
flutter pub get

# 4. Run code generation
dart run build_runner build --delete-conflicting-outputs
dart run slang

# 5. Launch the app (development)
flutter run --dart-define-from-file=config/development.json
```

**📖 For keeping your project in sync with template updates, see [docs/TEMPLATE_SYNC.md](docs/TEMPLATE_SYNC.md)**

---

## Project Structure

```
lib/
  main.dart                          -- Entry point
  bootstrap.dart                     -- App initialization
  app.dart                           -- Root MaterialApp / ProviderScope
  core/
    env/                             -- Environment config (dev/staging/prod)
    error/                           -- Error handling utilities
    feature_flags/                   -- Feature flag providers
    l10n/                            -- i18n source strings (*.i18n.json)
    logging/                         -- Logger setup (Sentry integration)
    network/                         -- Dio provider, interceptors
    presentation/                    -- Shared widgets (e.g. connectivity banner)
    routing/                         -- AutoRoute router, guards
    storage/                         -- Secure storage, shared prefs, token storage
    theme/                           -- App theme, color palette, extensions
    utils/                           -- General-purpose helpers
  features/
    auth/                            -- Authentication (reference feature)
      data/
        mappers/                     -- DTO-to-entity mappers
        models/                      -- DTOs (dart_mappable)
        repositories/                -- Repository implementations
        services/                    -- Retrofit API clients
      domain/
        entities/                    -- Domain entities
        failures/                    -- Typed failure classes
        repositories/                -- Repository interfaces
      l10n/                          -- Feature-scoped translations
      ui/
        pages/                       -- Screen widgets
        view_models/                 -- Riverpod view models
        widgets/                     -- Feature-scoped widgets
    dashboard/                       -- Dashboard feature
    profile/                         -- User profile feature
    settings/                        -- App settings (theme, locale)
  gen/                               -- Generated i18n files (slang)
config/
  development.json                   -- Dev environment variables
  staging.json                       -- Staging environment variables
  production.json                    -- Production environment variables
test/                                -- Unit and widget tests
bricks/                              -- Mason bricks (feature, repository, view_model)
docs/
  adrs/                              -- Architecture Decision Records
  architecture-rules/                -- Enforced architecture constraints
```

---

## Adding a New Feature

Use the Auth feature (`lib/features/auth/`) as a reference implementation.

1. **Create the directory scaffold.** Each feature follows the `data/`, `domain/`, `ui/` layer split. You can use the Mason bricks in `bricks/` to generate boilerplate:
   ```bash
   # First time only: install registered bricks
   mason get

   # Scaffold a full feature (data + domain + ui layers)
   mason make feature --feature_name my_feature

   # Or scaffold individual parts:
   mason make repository --feature_name my_feature --entity_name order
   mason make view_model --feature_name my_feature --page_name detail
   ```

2. **Define domain entities** in `domain/entities/` using `dart_mappable`.

3. **Define failure types** in `domain/failures/`.

4. **Create a repository interface** in `domain/repositories/` (e.g. `i_my_feature_repository.dart`).

5. **Create DTOs** in `data/models/` with `@MappableClass()` annotation.

6. **Create a Retrofit service** in `data/services/` with `@RestApi()` annotation.

7. **Implement the repository** in `data/repositories/`, injecting the service and mapping DTOs to entities.

8. **Create a mapper** in `data/mappers/` for DTO-to-entity conversion.

9. **Build view models** in `ui/view_models/` using `@riverpod` annotation.

10. **Build pages and widgets** in `ui/pages/` and `ui/widgets/`.

11. **Register routes** in `lib/core/routing/app_router.dart`.

12. **Run code generation:**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

13. **Add feature-scoped translations** in `features/<name>/l10n/` if needed, then run `dart run slang`.

14. **Write tests** mirroring the feature structure under `test/features/<name>/`.

---

## Available Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run --dart-define-from-file=config/development.json` | Run app (development) |
| `flutter run --dart-define-from-file=config/staging.json` | Run app (staging) |
| `flutter run --dart-define-from-file=config/production.json` | Run app (production) |
| `flutter test` | Run all tests |
| `flutter test --coverage` | Run tests with coverage |
| `flutter build apk --release --dart-define-from-file=config/production.json` | Build release APK |
| `dart run build_runner build --delete-conflicting-outputs` | Run code generation (one-shot) |
| `dart run build_runner watch --delete-conflicting-outputs` | Run code generation (watch mode) |
| `dart run slang` | Generate i18n string files |
| `dart analyze` | Run static analysis |
| `dart format .` | Format all Dart files |

---

## Environment Configuration

The app uses compile-time constants via `--dart-define-from-file`. Three environment configs are provided:

| File | Environment | API URL |
|------|-------------|---------|
| `config/development.json` | Development | `http://localhost:3000` |
| `config/staging.json` | Staging | Configured per project |
| `config/production.json` | Production | Configured per project |

Each config file defines:

- `ENVIRONMENT` -- Environment name (`development`, `staging`, `production`)
- `API_URL` -- Backend API base URL
- `SENTRY_DSN` -- Sentry DSN for error reporting (empty in dev)

See `lib/core/env/app_environment.dart` for how these values are consumed at runtime.

---

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run a specific test file
flutter test test/features/auth/data/repositories/auth_repository_test.dart
```

Tests are organized to mirror the `lib/` structure:

```
test/
  core/       -- Tests for shared infrastructure
  features/   -- Tests for feature layers
  helpers/    -- Test utilities and mocks
```

This project uses [mocktail](https://pub.dev/packages/mocktail) for mocking.

---

## Code Generation

This project relies on code generation for several libraries:

| Generator | Produces | Trigger |
|-----------|----------|---------|
| `riverpod_generator` | `*.g.dart` provider files | `build_runner` |
| `auto_route_generator` | `*.gr.dart` route files | `build_runner` |
| `retrofit_generator` | `*.g.dart` API client impls | `build_runner` |
| `dart_mappable_builder` | `*.mapper.dart` serialization | `build_runner` |
| `slang` | `lib/gen/strings*.g.dart` i18n | `dart run slang` |

After modifying annotated source files, regenerate with:

```bash
dart run build_runner build --delete-conflicting-outputs
dart run slang
```

Generated files are committed to the repository. The CI pipeline includes a `codegen-check` job that verifies they are up to date.

---

## Documentation

- **Architecture Overview** -- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Architecture Decision Records** -- [docs/adrs/](docs/adrs/)
- **Architecture Rules** -- [docs/architecture-rules/](docs/architecture-rules/)
- **Template Synchronization** -- [docs/TEMPLATE_SYNC.md](docs/TEMPLATE_SYNC.md)
- **Mason Bricks** -- [bricks/](bricks/) (feature, repository, view_model scaffolding)

---

## License

TBD
