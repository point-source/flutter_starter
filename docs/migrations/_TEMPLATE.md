# Migration: vX.Y.Z -- Short Description

## Summary

One to three sentences describing what changed and why it matters.

## Risk Level

**Low** | **Medium** | **High**

- **Low**: New files only, no changes to existing APIs or patterns.
- **Medium**: Modified files or updated dependencies, but no breaking API changes.
- **High**: Breaking changes that require code modifications in downstream projects.

## Files Added

New files introduced in this release. These can generally be accepted as-is.

```
lib/core/tasks/task_channel.dart
lib/core/tasks/task_progress.dart
docs/architecture-rules/13-background-tasks.md
docs/adrs/011-mock-first-features.md
```

## Files Modified

Existing files that changed. Review diffs carefully if you've customized these.

```
lib/core/error/failure.dart          # Added new failure subtypes
pubspec.yaml                         # New dependencies: fast_immutable_collections
analysis_options.yaml                # Updated lint rules
```

## Breaking Changes

List any changes that will cause compile errors or behavioral changes in downstream code.

- `Result.valueOrNull` renamed to `Result.value` -- update all call sites
- `AuthRepository.login()` now returns `Result<AuthState>` instead of `Result<User>`

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. Resolve conflicts in `pubspec.yaml` (keep your app name/version, accept new dependencies)
3. Run `flutter pub get`
4. Find and replace `Result.valueOrNull` with `Result.value` across your codebase
5. Update any code that calls `AuthRepository.login()` to expect `AuthState`
6. Run `dart run build_runner build --delete-conflicting-outputs`
7. Run `flutter test` and fix any failures

## Expected Conflicts

| File | Resolution |
|---|---|
| `pubspec.yaml` | Keep your app name/version, accept template dependency changes |
| `lib/core/routing/app_router.dart` | Keep your routes, adopt new template route patterns |
| `lib/features/auth/data/repositories/auth_repository.dart` | Accept template changes, re-apply any customizations |

## Can Skip?

**No** -- contains breaking changes that later releases depend on.

(Or: **Yes** -- this release only adds new optional features. You can skip it and pick up the changes in a later sync.)
