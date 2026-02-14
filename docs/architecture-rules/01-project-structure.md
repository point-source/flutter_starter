# Architecture Rule 01: Project Structure

## Overview

The project uses a **feature-first** directory structure. Shared infrastructure lives in `lib/core/`. Feature-specific code lives in `lib/features/<feature_name>/`. Generated code lives in `lib/gen/`. Tests mirror the `lib/` layout.

## Directory Layout

```
lib/
  main.dart                    # Single entry point
  bootstrap.dart               # Async initialization
  app.dart                     # Root MaterialApp.router widget

  core/                        # Shared infrastructure (no feature-specific logic)
    env/                       # Environment configuration
    error/                     # Result, Failure, AppException
    network/                   # Dio provider, interceptors
      interceptors/
    routing/                   # AppRouter, route guards
      guards/
    storage/                   # Secure storage, SharedPreferences, token storage
    theme/                     # AppTheme, ColorPalette, ThemeExtensions
    logging/                   # IAppLogger, ConsoleLogger, Sentry
    feature_flags/             # Feature flag enum and provider
    presentation/              # Shared widgets and responsive utilities
      responsive/
      widgets/
    utils/                     # Shared utility functions
    l10n/                      # Core translation JSON files

  features/
    <feature_name>/
      data/                    # Data layer
        services/              # Retrofit @RestApi() classes
        models/                # @MappableClass() DTOs
        mappers/               # DTO -> Entity extension methods
        repositories/          # Repository implementations
        providers/             # @riverpod infrastructure providers (service, repo)
      domain/                  # Domain layer (optional)
        entities/              # @MappableClass() domain models
        repositories/          # Abstract repository interfaces
        failures/              # Feature-specific sealed Failure classes
      ui/                      # UI layer
        view_models/           # @riverpod AsyncNotifier classes (optional)
        pages/                 # @RoutePage() widgets
        widgets/               # Feature-specific reusable widgets

  gen/                         # Generated slang output (do not edit)

test/                          # Mirrors lib/ structure
  core/
  features/
  helpers/                     # Test utilities, mocks, fakes
    test_utils.dart
    mocks.dart
    fakes.dart

config/                        # Environment config JSON files
  development.json
  staging.json
  production.json

docs/
  adrs/                        # Architecture Decision Records
  architecture-rules/          # This directory
```

## Rules

### Where files go

| File type | Location | Example |
|-----------|----------|---------|
| Retrofit service | `features/<name>/data/services/` | `auth_service.dart` |
| DTO model | `features/<name>/data/models/` | `user_dto.dart` |
| DTO-to-entity mapper | `features/<name>/data/mappers/` | `user_mapper.dart` |
| Repository implementation | `features/<name>/data/repositories/` | `auth_repository.dart` |
| Infrastructure providers | `features/<name>/data/providers/` | `auth_providers.dart` |
| Domain entity | `features/<name>/domain/entities/` | `user.dart` |
| Repository interface | `features/<name>/domain/repositories/` | `i_auth_repository.dart` |
| Feature failure | `features/<name>/domain/failures/` | `auth_failure.dart` |
| ViewModel (notifier) | `features/<name>/ui/view_models/` | `profile_view_model.dart` |
| Page widget | `features/<name>/ui/pages/` | `login_page.dart` |
| Feature widget | `features/<name>/ui/widgets/` | `auth_form.dart` |
| Shared widget | `core/presentation/widgets/` | `app_snackbar.dart` |
| Dio interceptor | `core/network/interceptors/` | `auth_interceptor.dart` |
| Route guard | `core/routing/guards/` | `auth_guard.dart` |
| Translation file | `core/l10n/` | `strings.i18n.json` |
| Test file | `test/<mirror_of_lib_path>/` | `test/features/auth/data/repositories/auth_repository_test.dart` |

### DO

- Place all feature code inside `lib/features/<feature_name>/`.
- Mirror the `lib/` directory structure in `test/`.
- Use `core/` only for code that is genuinely shared across multiple features.
- Keep generated files (`.g.dart`, `.gr.dart`, `.mapper.dart`) next to their source files.
- Place test helpers, mocks, and fakes in `test/helpers/`.

### DO NOT

- Do not import from one feature's `ui/` layer into another feature. Cross-feature sharing goes through `data/providers/`.
- Do not put feature-specific logic in `core/`.
- Do not create barrel files (`index.dart`) that re-export everything -- use explicit imports.
- Do not manually edit generated files.
- Do not place business logic in `main.dart` or `app.dart` -- those are structural entry points only.
