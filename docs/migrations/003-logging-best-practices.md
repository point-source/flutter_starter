# Migration: 003 -- Logging Best Practices

## Summary

Added structured logging throughout the app using the existing `IAppLogger` infrastructure. Repositories, notifiers, auth lifecycle, TaskTracker, and bootstrap now log at appropriate severity levels. A new architecture rule documents the conventions. Brick templates generate logging-aware code for new features.

## Risk Level

**Medium** -- Modified existing files (auth providers, profile view model, task tracker, bootstrap) and brick templates. No breaking API changes, but downstream projects that customized these files will see merge conflicts.

## Files Added

```
docs/architecture-rules/14-logging.md
```

## Files Modified

```
CLAUDE.md                                                    # Added ### Logging subsection
docs/ARCHITECTURE.md                                         # Added rule 14 row to table
lib/features/auth/data/providers/auth_providers.dart          # Added logger calls in build/login/register/logout
lib/features/profile/ui/view_models/profile_view_model.dart   # Added warning logs in failure branches
lib/core/tasks/task_tracker.dart                              # Added error log for UnexpectedFailure in _onTaskFailed
lib/bootstrap.dart                                            # Added ConsoleLogger fallback when Sentry disabled
test/helpers/mocks.dart                                       # Added MockAppLogger
test/features/auth/data/providers/auth_providers_test.dart    # Override loggerProvider
test/features/profile/ui/view_models/profile_view_model_test.dart  # Override loggerProvider
test/core/tasks/task_tracker_test.dart                        # Override loggerProvider
bricks/feature/__brick__/.../repositories/{{feature_name.snakeCase()}}_repository.dart  # IAppLogger param + logging (dio only)
bricks/feature/__brick__/.../providers/{{feature_name.snakeCase()}}_providers.dart       # Pass loggerProvider to repo (dio only)
bricks/feature/__brick__/.../view_models/{{feature_name.snakeCase()}}_view_model.dart   # Warning log in failure branch
bricks/repository/__brick__/.../repositories/{{entity_name.snakeCase()}}_repository.dart # IAppLogger param + logging
```

## Breaking Changes

None. All changes are additive -- existing public APIs are unchanged.

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. Resolve conflicts (see table below)
3. Run `flutter pub get`
4. Run `dart run build_runner build --delete-conflicting-outputs`
5. If you have custom Dio-backed repositories generated from the old brick templates, consider adding `IAppLogger` as a constructor parameter and logging in `on Exception catch` blocks to match the new convention
6. If you have custom notifiers/view models, consider adding `ref.read(loggerProvider).warning(...)` calls in failure branches
7. Add `MockAppLogger` to your test helpers and override `loggerProvider` in tests that use providers which now read it
8. Run `flutter test` and fix any failures

## Expected Conflicts

| File | Resolution |
|---|---|
| `lib/features/auth/data/providers/auth_providers.dart` | Accept template logging additions, re-apply any custom auth logic |
| `lib/features/profile/ui/view_models/profile_view_model.dart` | Accept template logging, re-apply any custom profile logic |
| `lib/core/tasks/task_tracker.dart` | Accept template logging in `_onTaskFailed` |
| `lib/bootstrap.dart` | Accept `ConsoleLogger` fallback, keep any custom bootstrap logic |
| `test/helpers/mocks.dart` | Accept `MockAppLogger` addition |
| `CLAUDE.md` | Accept new `### Logging` section |

## Can Skip?

**Yes** -- this release only adds logging calls and documentation. No existing APIs changed. You can skip it and pick up the changes in a later sync, though you will miss debug console output for failures until then.
