# Migration: 012 -- AuthGuard cold-start race fix

## Summary

Fixes a latent race in the auth bootstrap path that strands restored sessions on `/login` whenever a downstream project wires up a real backend. `App` now gates `MaterialApp.router` on the *initial* resolution of `authStateRepoProvider`, showing a brief splash so `AuthGuard` only runs after auth state is known. As a corollary, `AuthStateRepo.login`/`register`/`logout` now preserve their previous data on the `AsyncLoading` transition so subsequent in-flight mutations do not re-trigger the splash.

## Risk Level

**Low**

- No public API changes. The only behavioral change is a one-frame splash on cold start before the router is mounted.
- The bug being fixed is invisible with the default `MockAuthRepository` (its `getCurrentUser()` returns `Success(null)`), so projects still on the mock backend see no functional change. Projects that have plugged in a real backend gain a correctness fix.

## Files Added

```
test/app_test.dart                                          # Cold-start widget tests for App's auth gating
```

## Files Modified

```
lib/app.dart                                                # Splash gate on initial auth-state resolution
lib/features/auth/data/providers/auth_providers.dart        # login/register/logout preserve prior data via copyWithPrevious(state)
test/features/auth/data/providers/auth_providers_test.dart  # New 'isAuthenticated provider and loading transitions' group
```

## Breaking Changes

_None._

The splash branch in `App.build` is additive — the existing `MaterialApp.router` configuration is unchanged and is still returned once auth state has resolved. `LoginPage`'s existing `is AsyncLoading` spinner check continues to work because `copyWithPrevious(state)` preserves the `AsyncLoading` *type* while also preserving prior data.

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. If you have customized `lib/app.dart`, re-apply your customizations alongside the new splash gate. The gate must run before `MaterialApp.router` is constructed and reads `authStateRepoProvider` directly — see the file for the exact pattern.
3. If you have customized `AuthStateRepo` mutators (`login`/`register`/`logout`), keep the new `state = const AsyncLoading<AuthState>().copyWithPrevious(state)` pattern (with the `// ignore: invalid_use_of_internal_member` directive — see note below). A bare `state = const AsyncLoading()` will reintroduce a splash flash on every mutation.
4. Run `flutter test` and `dart analyze`. The new `test/app_test.dart` and the extended `auth_providers_test.dart` will fail loudly if the gate is removed or the `copyWithPrevious` change is reverted.

### Note on `copyWithPrevious`

`AsyncValue.copyWithPrevious` is annotated `@internal` in Riverpod 3.x, so the analyzer reports `invalid_use_of_internal_member`. This is a known wart — the pattern is documented as the recommended way to preserve previous data across loading transitions, and the annotation is widely treated as a false positive in real Riverpod 3 codebases. The three call sites in `auth_providers.dart` carry an inline `// ignore` directive with a comment explaining why.

## Expected Conflicts

| File | Resolution |
|---|---|
| `lib/app.dart` | If customized, re-apply your changes around the new initial-load gate. Make sure `final authAsync = ref.watch(authStateRepoProvider);` runs before the splash branch and that the splash branch returns *before* `MaterialApp.router(...)`. |
| `lib/features/auth/data/providers/auth_providers.dart` | If you replaced `AuthStateRepo` with your own implementation (e.g., a Supabase- or Firebase-backed notifier), apply the `copyWithPrevious(state)` pattern to your `AsyncLoading` transitions in `login`/`register`/`logout`. |
| `test/features/auth/data/providers/auth_providers_test.dart` | Accept the new `isAuthenticated provider and loading transitions` group wholesale. |
| `test/app_test.dart` | New file — accept wholesale. |

## Can Skip?

**No** — projects with a real backend will silently strand users on `/login` after every cold restart without this fix. Projects still on the mock backend can technically skip it, but it costs nothing and removes a footgun for the moment they swap in a real backend.

## Background

The race lives at the seam between `AuthGuard` (synchronous, `_ref.read(isAuthenticatedProvider)`) and `AuthStateRepo.build()` (async, `await repository.getCurrentUser()`). `isAuthenticatedProvider` collapses `AsyncLoading` → `false` via `whenOrNull(data: ...) ?? false`, so on cold start the very first navigation always sees "unauthenticated" and `replaceAll([LoginRoute()])` pins the user to `/login`. Once `build()` resolves with a restored session, `authStateListenableProvider` does fire — but by then the active route is `/login`, which has no guard, so nothing pulls the user back into the protected shell. The mock backend hides the bug because its post-resolution answer also happens to be `false`.

The fix gates the router at the `App` widget level so the guard's first read sees a resolved value, sidestepping the auto_route guard contract entirely (guards cannot be async). The secondary `copyWithPrevious(state)` change ensures the gate distinguishes "first load in progress" from "in-flight mutation after first load" — without it, `login`/`register`/`logout` would each re-trigger the splash.
