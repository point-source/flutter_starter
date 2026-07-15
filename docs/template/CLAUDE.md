<!--
  Template-maintained AI agent context.

  This file is imported by the root CLAUDE.md via @import. It contains the
  conventions, tech stack, architecture patterns, and commands defined by
  the flutter_starter template.

  DO NOT add project-specific content here. Put that in docs/project/CLAUDE.md
  instead — anything added to this file will be overwritten during template
  sync. See docs/template/TEMPLATE_SYNC.md for the ownership split.
-->

## Tech Stack

| Concern | Package | Notes |
|---|---|---|
| State / DI | `flutter_riverpod` + `riverpod_generator` | `@riverpod` code gen for all providers |
| Navigation | `auto_route` + `auto_route_generator` | Type-safe routes, guards, nested nav |
| Data Access | Repository interfaces + project-selected sources | Mocks by default; SDK, local, custom, or REST implementations are peers |
| Data Models | `dart_mappable` + `dart_mappable_builder` | Immutable models, JSON, copyWith |
| Collections | `fast_immutable_collections` | IList, IMap, ISet for domain models |
| Error Handling | Custom sealed `Result<T>` | No fpdart -- failures are values |
| Background Tasks | Custom `TaskTracker` + `TaskChannel` | Progress, cancellation, throttling, retry |
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
    error/               # Result<T>, Failure hierarchy
    storage/             # Token storage, secure storage, shared prefs providers
    tasks/               # TaskTracker, TaskChannel, progress, cancellation
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
    repositories/        # Repository implementation (mock by default)
    providers/           # @riverpod infrastructure providers
    # Optional -- added when connecting a backend:
    # sources/           # Optional SDK, local, custom-client, or REST adapters
    # models/            # Optional source-specific data models
    # mappers/           # Optional source-model to domain mapping extensions
  domain/
    entities/            # @MappableClass() domain models
    repositories/        # Abstract repository interface (IXxxRepository)
    failures/            # sealed XxxFailure extends Failure
  ui/
    view_models/         # @riverpod AsyncNotifier (optional, page-specific)
    pages/               # @RoutePage() ConsumerWidget pages
    widgets/             # Feature-specific widgets
  l10n/                  # Feature-scoped translation strings
```

The domain layer is optional -- only add it when the feature needs its own
entity types, repository abstraction, or failure hierarchy.

View models are optional -- only create them when a page needs significant
data transformation between the domain and the UI. Pages can watch providers
from `data/providers/` directly when no transformation is needed.

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
  - Backend-specific annotations only after that backend capability is selected
  - `@RoutePage()` -- auto_route page registration
- Files using code gen include `part '<filename>.g.dart';`

### State Management (Riverpod)
- Views use `ConsumerWidget` or `ConsumerStatefulWidget`
- Infrastructure providers (services, repositories) live in `data/providers/`
- ViewModels are optional `@riverpod` AsyncNotifier classes in `ui/view_models/`
- Only create a ViewModel when the page needs significant data transformation
- Pages can watch `data/providers/` directly for simple passthrough cases
- Use `@Riverpod(keepAlive: true)` for app-lifetime providers (router, auth, long-lived selected clients)
- Use `ref.read()` for one-shot reads, `ref.watch()` for reactive dependencies
- Cross-feature sharing happens through `data/providers/`, never `ui/view_models/`

### Error Handling
- Repositories return `Future<Result<T>>` (never throw)
- `Result<T>` is a sealed class: `Success<T>` or `Err<T>`
- Infrastructure failures: `NetworkFailure`, `ServerFailure`, `CacheFailure`
- Feature failures: sealed class extending `Failure` (e.g., `AuthFailure`)
- ViewModels call `result.when(success:, failure:)` to map to `AsyncValue`
- Repositories catch errors from their selected source and map them to application `Failure` values
- Source exceptions and response types never cross the repository boundary

### Background Tasks
- Long-running user tasks (uploads, syncs) use `TaskTracker` in `core/tasks/`
- Features create a `TaskChannel` provider scoping category, concurrency, retry
- `TaskChannel.run<T>(id:, label:, work:)` submits work; returns `Future<Result<T>>`
- Work functions receive `CancellationToken` + `void Function(TaskProgress)` callback
- Progress types: `indeterminate`, `determinate(fraction)`, `phased(label, [fraction])`
- Categories with `maxConcurrent` throttle parallel tasks; excess queue as `pending`
- See `docs/template/architecture-rules/13-background-tasks.md` for full patterns

### Logging
- All operational logging goes through `IAppLogger` via `loggerProvider` — never `print()`
- Dev → `ConsoleLogger` (dart:developer); staging/prod → `SentryReporter` (breadcrumbs + events)
- Severity: `debug` (dev diagnostics), `info` (normal events), `warning` (domain failures), `error` (unexpected exceptions), `fatal` (unrecoverable)
- Always pass `tag` — feature name for features (`'auth'`), specific name for infra (`'http'`)
- Repositories: log `error` when an unexpected source exception becomes `UnexpectedFailure`
- Notifiers: log `warning` when mapping a failure to `AsyncError` or `FailureException`
- Auth: log `info` + call `setUser()` on login/register success; `setUser(null, null)` on logout
- Access via `ref.read(loggerProvider)` in providers; inject it into repositories that can encounter runtime source errors
- See `docs/template/architecture-rules/14-logging.md` for full patterns

### UI Structure
- **Pages are layout orchestrators** -- they assemble and arrange widget components,
  not implement fine-grained UI logic inline. Extract meaningful chunks into
  dedicated widgets in `ui/widgets/` to keep pages modular and readable.
- **Input placement in compact portrait** -- when a page has a small number of
  input fields (1-3), position them near the bottom of the viewport so they are
  thumb-accessible on phones. Exception: pages that are primarily forms (e.g.,
  profile editing) should use conventional top-down form layout.
- **Mock backends for UI work** -- always ensure a mock repository is available
  before building out UI pages. This enables running and testing the UI without
  a live backend (`BACKEND=mock` is the default). Add or extend mock repositories
  as needed so new pages are exercisable immediately.

### Navigation
- Routes defined in `lib/core/routing/app_router.dart`
- `AuthGuard` protects authenticated routes via `isAuthenticatedProvider`
- Shell route wraps tabbed navigation with `AdaptiveScaffold`
- Pages annotated with `@RoutePage()` for auto_route generation

### Environment Configuration
- Single `main.dart` entry point
- Environment selected via `--dart-define-from-file=config/<env>.json`
- Config templates live in `config/examples/`; active configs are gitignored
- Run `./scripts/setup.sh` to provision `config/*.json` from templates
- `AppEnvironment` enum reads compile-time constants
- Backend mode: `BACKEND=mock` (default, mock repos) or `BACKEND=real` (backend-backed repos)
- Dev prefill: `DEV_PREFILL=true` pre-fills login with `DEV_EMAIL`/`DEV_PASSWORD` (only with `BACKEND=real`)

## Common Commands

```bash
# Provision config files from templates (first time only)
./scripts/setup.sh

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

# Run CI checks locally (same as GitHub Actions)
./scripts/ci-check.sh          # All checks: lint, test, codegen
./scripts/ci-check.sh lint     # Analyze + format only
./scripts/ci-check.sh test     # Tests only
./scripts/ci-check.sh codegen  # Codegen freshness only

# Run the app (development)
flutter run --dart-define-from-file=config/development.json

# Run the app (staging)
flutter run --dart-define-from-file=config/staging.json

# Release build (production)
flutter build apk --release --dart-define-from-file=config/production.json

# Build iOS (Apple targets use Swift Package Manager -- no CocoaPods / pod install)
# --no-codesign builds unsigned, so it succeeds on any machine with just Flutter + Xcode
flutter build ios --no-codesign --dart-define-from-file=config/production.json

# Build macOS
flutter build macos --release --dart-define-from-file=config/production.json

# Build web (development)
flutter build web --release --dart-define-from-file=config/development.json

# Build web (production)
flutter build web --release --dart-define-from-file=config/production.json
```

## Error Handling Flow

```
Selected source (mock / SDK / local / custom / REST)
    --> source value or source-specific exception
    --> repository maps value to entity or exception to Failure
    --> Result<T> (Success or Err)
    --> notifier/ViewModel .when() --> AsyncValue
    --> UI renders the same success or failure states for every source
```

The repository is the translation boundary. Domain and UI code must not import
SDK models, transport responses, database records, or source exception types.

## Adding a New Feature

**Follow the Auth feature (`lib/features/auth/`) as the canonical reference.**

New features use a **mock-first** approach: start with a mock repository, then
replace its provider binding only after the project selects a real data source.

1. Run `mason make feature` to scaffold the feature with a mock repository
2. Define domain entities (`@MappableClass()`) and repository interface
3. Define feature-specific failures (sealed class extending `Failure`)
4. Implement the mock repository (returns `Result<T>`, hard-coded or in-memory data)
5. Create infrastructure providers in `data/providers/` (repository)
6. Optionally create a ViewModel (`@riverpod` AsyncNotifier) only if the page needs significant data transformation -- skip if the page would just pass through data
7. Build pages (`@RoutePage()`, `ConsumerWidget`) and widgets
8. Register routes in `app_router.dart`
9. Run `dart run build_runner build --delete-conflicting-outputs`
10. Add tests mirroring the `lib/` structure under `test/`

Mocks, SDK clients, local stores, custom clients, and REST clients are peer
repository implementations. If the project deliberately selects the supported
Dio/Retrofit REST capability, run `mason make dio_rest` first; that opt-in emits
its concrete setup and generation guide at `docs/project/REST_DIO.md`.

## Commit Style

Use [Conventional Commits](https://www.conventionalcommits.org/) for all commit messages.

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `fix:` — patches a bug (correlates with PATCH in SemVer)
- `feat:` — introduces a new feature (correlates with MINOR in SemVer)
- `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:` — other common types
- `BREAKING CHANGE:` footer or `!` after type/scope — breaking API change (correlates with MAJOR in SemVer)

**Examples:**
```
feat(auth): add biometric login support

fix(routing): resolve redirect loop in AuthGuard

docs: update getting started instructions

refactor(http): extract error interceptor into separate file

feat(profile)!: replace username with email as primary identifier

BREAKING CHANGE: username field removed from UserEntity
```

## Detailed Documentation

All template-maintained documentation lives under `docs/template/`.
Project-specific documentation belongs in `docs/project/`.

- **Architecture overview**: `docs/template/ARCHITECTURE.md`
- **Architecture Decision Records** (template): `docs/template/adrs/`
- **Architecture rules and patterns**: `docs/template/architecture-rules/`
- **Deployment (iOS, Android, Web)**: `docs/template/DEPLOYMENT.md`
- **Template roadmap and future work**: `docs/template/ROADMAP.md`
- **Template design proposals**: `docs/template/proposals/`
- **Template update migration guides**: `docs/template/migrations/`
- **Project-specific ADRs** (app-level decisions): `docs/project/decisions/`
- **Project documentation guide**: `docs/project/README.md`
