# Flutter Starter Template -- Improvement Tracker

This document catalogs verified issues found during a comprehensive code review,
organized by severity. Each issue includes the affected files, a description
of the problem, and the recommended fix.

Issues are grouped into **Parts** for incremental implementation. Each part is
independent and can be assigned to a separate agent/developer.

---

## Critical Issues

### 1. Failure subclasses lack `==` / `hashCode`

**Files:** `lib/core/error/failures.dart`

`Err<T>` in `result.dart` implements `operator ==` by delegating to
`failure == other.failure`. But no `Failure` subclass overrides `==` or
`hashCode`, so equality is identity-based. This means:

```dart
// Always false (non-const), even though semantically identical:
Err(BadResponse(404)) == Err(BadResponse(404))  // false!
```

Only `const` instances happen to work (Dart canonicalizes identical const
objects). Any non-const Failure — like `BadResponse` with a dynamic status
code or `UnexpectedFailure` wrapping an error — silently fails equality checks
in tests and production code (deduplication, caching, etc.).

Additionally, `Failure.toString()` on line 33 uses `'$runtimeType: $message'`,
which violates the project's `no_runtimetype_tostring` lint rule.

**Fix (Part 1):**
- Add `operator ==` and `hashCode` to the `Failure` base class (compare
  `runtimeType` + `message`, exclude `stackTrace`).
- Override on `BadResponse` to include `statusCode`.
- Override on `UnexpectedFailure` to include `error`.
- Replace `$runtimeType` in `toString()` with a switch expression or
  hardcoded type name.
- Add explicit equality tests in `test/core/error/result_test.dart`.
- Document the equality contract in `docs/architecture-rules/05-error-handling.md`.

---

### 2. Hardcoded UI strings violate the i18n contract

**Files:**
- `lib/core/presentation/widgets/adaptive_scaffold.dart` (12 instances)
- `lib/features/profile/ui/pages/profile_page.dart` (4 instances)
- `lib/features/settings/ui/pages/settings_page.dart` (3 instances)
- `lib/features/auth/ui/pages/login_page.dart` (8+ instances)
- `lib/core/l10n/en.i18n.json` (missing keys)

The architecture rules (`docs/architecture-rules/10-i18n.md`) state: "Provide
translations for all user-facing strings -- no hardcoded strings in widgets."
Multiple UI files violate this:

| File | Hardcoded Strings |
|------|-------------------|
| `adaptive_scaffold.dart` | "Dashboard", "Profile", "Settings" x4 layouts |
| `profile_page.dart` | "Name", "Bio", "Phone", "Name is required" |
| `settings_page.dart` | "System", "English", "Espanol" |
| `login_page.dart` | "Welcome Back", "Sign in to your account", field labels, validation messages |

The translation file `en.i18n.json` has keys for titles (`dashboard.title`,
`profile.title`) but is missing keys for navigation labels, form field labels,
and locale option names.

**Fix (Part 2):**
- Add missing keys to `en.i18n.json`.
- Replace all hardcoded strings with `t.` accessors.
- Regenerate translations with `dart run slang`.

---

## High Priority Issues

### 3. AuthInterceptor crashes if secure storage throws

**File:** `lib/core/network/interceptors/auth_interceptor.dart`

The `onRequest` method calls `await _tokenStorage.getAccessToken()` (line 42)
without a try/catch. If `FlutterSecureStorage` throws (corrupted keychain,
platform error, permission issue), the exception propagates unhandled and
**all HTTP requests fail**.

**Fix (Part 3):**
- Wrap the token read in try/catch.
- On failure, log a debug warning and proceed without the Authorization header
  (graceful degradation).

---

### 4. RefreshTokenInterceptor lacks redundant-refresh guard

**File:** `lib/core/network/interceptors/refresh_token_interceptor.dart`

The interceptor extends `QueuedInterceptor` (which serializes `onError`
calls), but has no `_isRefreshing` flag. When the queue drains and a second
batch of 401 responses arrives after a successful refresh, each triggers a
redundant `_attemptRefresh()` call. This wastes API calls and risks token
rotation race conditions on backends that invalidate refresh tokens on use.

**Fix (Part 3):**
- Add `bool _isRefreshing = false`.
- Guard `_attemptRefresh()` behind the flag.
- Retry with the current (already-refreshed) token when the flag is set.

---

### 5. ProfilePage allows duplicate save submissions

**File:** `lib/features/profile/ui/pages/profile_page.dart`

The save button (lines 215-219) never disables during the async `_saveProfile`
operation. Compare with `login_page.dart`, which correctly:
1. Watches `authStateRepoProvider` for `AsyncLoading` (line 75)
2. Sets `onPressed: isLoading ? null : _onLogin` (line 138)
3. Shows a `CircularProgressIndicator` inside the button (lines 139-145)

The profile page follows none of these patterns.

**Fix (Part 4):**
- Watch `profileViewModelProvider` for `AsyncLoading`.
- Disable the save button and show a spinner during save.
- Follow the exact pattern from `login_page.dart`.

---

### 6. TokenStorage.saveTokens is not atomic

**File:** `lib/core/storage/token_storage.dart`

`saveTokens` uses `Future.wait([write(access), write(refresh)])`. If one
write succeeds and the other fails, storage is left in an inconsistent state
(e.g., access token saved, refresh token missing). The refresh token
interceptor assumes both are present or both are absent.

**Fix (Part 5):**
- Document the limitation with a doc comment.
- Add error logging if either write fails.
- Consider sequential writes with rollback for a future iteration.

---

### 7. FeatureFlagProvider.resetAll() doesn't await storage removal

**File:** `lib/core/feature_flags/feature_flag_provider.dart`

`resetAll()` is `void` and calls `_prefs.remove()` without awaiting
(lines 53-58). State updates immediately but storage removal may fail
silently. If the app restarts before removal completes, old flag values
persist on disk despite appearing reset in the UI.

**Fix (Part 4):**
- Change return type to `Future<void>`.
- Await `Future.wait([...])` for all remove calls.

---

### 8. DeterminateProgress.fraction accepts invalid values

**File:** `lib/core/tasks/task_progress.dart`

`DeterminateProgress(this.fraction)` accepts any `double`. Values like `1.5`
or `-0.3` produce nonsensical percentages (150%, -30%) from the `percent`
getter. Same issue exists for `PhasedProgress.fraction`.

**Fix (Part 4):**
- Add `assert(fraction >= 0.0 && fraction <= 1.0)` to both constructors.
- Add tests verifying the assertion fires on out-of-range values.

---

## Medium Priority Issues

### 9. failure_message_mapper drops feature failures to "unexpected"

**File:** `lib/core/utils/failure_message_mapper.dart`

The switch (lines 24-33) only handles infrastructure failures (`NoConnection`,
`Timeout`, `BadResponse`, etc.). Feature-specific failures (`AuthFailure`,
`ProfileFailure` subtypes) fall through to the `_ => t.core.error.unexpected`
wildcard, showing a generic message instead of the contextual one.

**Fix (Part 5):**
- Add cases for `InvalidCredentials`, `EmailAlreadyInUse`, `SessionExpired`,
  `AuthServerError`, `ProfileNotFound`, `ProfileUpdateRejected`.
- All use existing translation keys.

---

### 10. bootstrap.dart duplicates Sentry reporting logic

**File:** `lib/bootstrap.dart`

`FlutterError.onError` (lines 58-73) and `PlatformDispatcher.instance.onError`
(lines 75-87) both implement identical `FailureException` unwrapping and
`Sentry.captureException` logic. This is a DRY violation and maintenance
hazard -- a bug fix in one handler could be missed in the other.

**Fix (Part 5):**
- Extract shared logic to `void _reportToSentry(Object error, StackTrace? stack)`.
- Call from both handlers.

---

### 11. Duplicated private `_mapProfile` in Supabase repositories

**Files:**
- `lib/features/profile/data/repositories/supabase_profile_repository.dart`
- `lib/features/profile/data/repositories/supabase_profile_stream_repository.dart`

Both files contain an identical private `_mapProfile(Map<String, dynamic>)`
method. This violates DRY and makes the mapping logic untestable (private
methods can't be tested directly).

**Fix (Part 6):**
- Extract to a shared extension `SupabaseProfileMapper` on `Map<String, dynamic>`
  in `lib/features/profile/data/mappers/supabase_profile_mapper.dart`.
- Follow the same extension pattern as `UserDtoMapper` and `ProfileDtoMapper`.

---

### 12. SupabaseClientProvider has no configuration guard

**File:** `lib/core/network/supabase_client_provider.dart`

The provider unconditionally calls `Supabase.instance.client`. If Supabase
is not configured (`SUPABASE_URL` / `SUPABASE_ANON_KEY` missing), this throws
a runtime error with no helpful message.

**Fix (Part 6):**
- Add an assertion checking `AppEnvironment.isSupabaseConfigured`.
- Provide a descriptive error message.

---

### 13. SentryReporter.setUser() not on IAppLogger interface

**Files:**
- `lib/core/logging/app_logger.dart`
- `lib/core/logging/sentry_reporter.dart`

`setUser(String?, String?)` is implemented only on `SentryReporter`. Callers
must cast to the concrete type, breaking the abstraction.

**Fix (Part 6):**
- Add `setUser` to `IAppLogger` with a doc comment.
- Add a no-op implementation in `ConsoleLogger`.
- Add `@override` to `SentryReporter.setUser`.

---

## Low Priority / Template Quality Issues

### 14. No widget tests for any pages

Six page files exist (`login_page.dart`, `register_page.dart`,
`dashboard_page.dart`, `profile_page.dart`, `settings_page.dart`) with zero
corresponding widget tests. The example `test/widget_test.dart` only tests
core types. For a canonical reference template, at least the auth pages should
demonstrate widget testing patterns.

---

### 15. No dashboard view model test

`lib/features/dashboard/ui/view_models/dashboard_view_model.dart` has no test
file. The view model is simple (derives greeting name from auth state), but
as the canonical dashboard feature, it should demonstrate the testing pattern.

---

### 16. No TaskChannel usage example in any feature

`TaskChannel` is fully implemented in `core/tasks/` but no feature exercises
it. The background task system is tested in isolation but never demonstrated
in a real feature context (e.g., avatar upload in profile).

---

### 17. No family provider example in any feature

No parameterized (family) providers exist in `lib/features/`. For teams
building real apps, a reference example of a family provider would be valuable.

---

### 18. No pagination example

No feature demonstrates infinite scroll or paginated data loading with
Riverpod, which is one of the most common patterns in production apps.

---

## Part Summary

| Part | Issues | Priority | Confidence | Risk |
|------|--------|----------|------------|------|
| **1** | #1 (Failure equality + toString) | Critical | Very High | Low |
| **2** | #2 (i18n hardcoded strings) | Critical | High | Low |
| **3** | #3, #4 (Interceptor resilience) | High | High | Low |
| **4** | #5, #7, #8 (ProfilePage loading, flag provider, progress clamp) | High | High | Low |
| **5** | #6, #9, #10 (Error mapping, bootstrap dedup, token docs) | Medium | High | Low |
| **6** | #11, #12, #13 (Mapper extraction, Supabase guard, logger interface) | Medium | Medium | Low |

Issues #14-18 are noted for future work and do not have assigned parts.
