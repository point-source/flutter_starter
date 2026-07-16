# Migration: 014 -- Backend-neutral networking baseline

> [!CAUTION]
> ## Runtime networking behavior warning
>
> Do not resolve this template update until you choose one path below. Replacing
> the former client can change the endpoint, authentication headers and token refresh,
> interceptor order, timeouts, error mapping, and logging, TLS and
> certificate-pinning behavior, generated services, and backend provider binding.
> A clean merge is not proof that those behaviors survived.

## Summary

The base starter no longer ships Dio, Retrofit, shared HTTP code, an API URL, or
an SSL-pinning toggle. REST remains supported through the explicit
`mason make dio_rest` capability. Projects that actively use the former shipped
stack must retain it as project-owned code or deliberately migrate it; projects
that already removed it should accept the neutral baseline without recreating a
removal-only patch.

## Risk Level

**High** -- the template deletes former shared networking files and changes
backend configuration and guidance. An incorrect conflict resolution can compile
while changing requests at runtime.

## Files Added

```text
bricks/dio_rest/                                      # Explicit REST capability
scripts/check-rest-opt-in.sh                          # Clean opt-in acceptance
scripts/check-rest-adopter-migration.sh               # Downstream sync acceptance
test/fixtures/rest_adopter_migration/                 # Representative adopters
docs/template/migrations/014-backend-neutral-networking.md
```

## Files Modified

```text
pubspec.yaml                                          # Base Dio/Retrofit removed
build.yaml                                            # Base Retrofit builder removed
lib/core/env/app_environment.dart                     # REST config removed
docs/template/TEMPLATE_SYNC.md                        # Backend ownership clarified
docs/template/CLAUDE.md                               # Backend-neutral guidance
docs/template/ARCHITECTURE.md                         # Explicit capability model
```

## Files Removed from the Base

```text
lib/core/http/**
test/core/http/**
```

These paths are removed only from the template baseline. If a downstream app
uses them, they contain project behavior and must not be silently deleted.

## Breaking Changes

- The base no longer declares `dio`, `retrofit`, or `retrofit_generator`.
- The base no longer enables the Retrofit builder.
- The base no longer provides the former shared Dio provider or its auth,
  refresh, logging, and error interceptors.
- `AppEnvironment.apiBaseUrl`, `API_URL`, and the old
  `AppEnvironment.sslPinningEnabled` claim are absent from the neutral base.
- REST feature generation now requires `mason make dio_rest` first.
- Selected backend clients and their configuration are project-owned after
  selection; template sync must not overwrite or delete them automatically.

## Migration Steps

### 1. Stop before resolving networking changes

Create the normal template-update branch, fetch the configured template remote,
and start the merge according to [TEMPLATE_SYNC.md](../TEMPLATE_SYNC.md). Before
accepting either side for the files above, inventory the current app:

```bash
rg -n 'dio|retrofit|API_URL|REST_API_URL|sslPinning|certificate' \
  pubspec.yaml build.yaml lib test config docs/project
rg -n 'dioProvider|Dio\(' lib test
```

Trace which repository providers the running app selects for every environment.
Then choose exactly one path. If you cannot establish whether the old client is
used, stop the merge and investigate; do not treat absence of a merge conflict
as permission to delete it.

### 2A. Retain as project-owned

Choose this path when production or development traffic still uses the former
shared client and you do not want to change its runtime behavior in this update.

1. Keep `lib/core/http/**`, its tests, all used Retrofit services, and generated
   sources. Resolve template deletions in favor of the downstream project.
2. Keep `dio`, `retrofit`, `retrofit_generator`, and the matching builder rules.
   Run code generation and confirm no service loses its generated implementation.
3. Keep the endpoint input the client actually reads. If that remains `API_URL`
   and `AppEnvironment.apiBaseUrl`, do not rename it merely to resemble the new
   capability.
4. Keep the complete authentication and refresh chain, including public-route
   exceptions, token storage, retry behavior, auth-expiry callbacks, and
   interceptor order.
5. Keep project timeouts, error mapping, and logging. Confirm user-visible
   failures do not start exposing transport messages, bodies, or request URIs.
6. Keep any real TLS and certificate-pinning behavior and its tests. Delete an
   SSL toggle only if it was a claim with no implementation; changing enforced
   pinning is a separate security migration.
7. Record the retained client, dependencies, builder configuration, endpoint,
   and tests in `docs/project/`. They no longer receive automatic template
   networking updates.
8. Run the verification checklist below against the same environments and auth
   states used before the merge.

This path intentionally takes the neutral documentation and architecture
improvements without replacing a live transport implementation.

### 2B. Adopt the supported opt-in

Choose this path only when the team wants to replace the former shared shape with
the maintained capability and can review a networking behavior change.

1. Save tests or an inventory for the old endpoint selection, authentication
   headers and token refresh, interceptor order, timeouts, error mapping, and
   logging, TLS and certificate-pinning behavior, generated services, and
   backend provider binding.
2. Accept the template removal of the old HTTP foundation, REST dependencies,
   builder rules, and obsolete base configuration as one coordinated change.
3. Install the capability from the project root:

   ```bash
   mason get
   mason make dio_rest
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Migrate each endpoint deliberately from `API_URL` to `REST_API_URL`. The
   capability requires a non-empty absolute HTTP(S) value and has no former
   environment fallback; update every active `config/<environment>.json` as
   well as the committed examples.
5. Reapply required project behavior. The capability's client includes REST
   logging and safe error translation, but it does **not** recreate the former
   auth header, token refresh, auth-expiry callback, or certificate pinning.
6. Update Retrofit services and repository provider bindings to use the selected
   capability client. Keep Dio types and exceptions below the repository
   boundary and return the same public `Result<T>` contract.
7. Re-run endpoint, authenticated/expired-token, timeout, failure, TLS, and
   provider-selection tests before accepting the migration.

### 2C. SDK or no backend

Choose this path when the downstream project already removed Dio or never used
the former stack.

1. Accept the neutral template deletions and backend-neutral documentation.
2. Do **not** run `mason make dio_rest` and do not accept REST capability output.
3. Keep the selected SDK, local source, custom client, or mock repository and its
   project configuration. Confirm its provider binding is unchanged.
4. Remove any stale `dio`, `retrofit`, or `retrofit_generator` declaration,
   Retrofit builder, `lib/core/http/`, `API_URL`, `REST_API_URL`, SSL toggle, or
   `.flutter_starter/capabilities/dio_rest.json` marker.
5. Review the completed sync diff. There should be no patch whose only purpose
   is re-deleting REST artifacts delivered by the template.

Useful negative checks:

```bash
rg -n 'dio|retrofit|API_URL|REST_API_URL|sslPinning|ENABLE_SSL_PINNING' \
  pubspec.yaml build.yaml lib test config .flutter_starter || true
test ! -d lib/core/http
```

An SDK package may legitimately contain the word `http` internally; evaluate
matches by ownership instead of deleting backend code mechanically.

## Runtime Review Checklist

For path 2A or 2B, reviewers must explicitly confirm:

- [ ] Endpoint key, value, validation, and fallback semantics in every environment
- [ ] Authentication headers, public-route exclusions, and token refresh/expiry
- [ ] Interceptor membership and order
- [ ] Connect, receive, and send timeouts
- [ ] Error mapping, retry behavior, safe user messages, and logging
- [ ] TLS validation and any implemented certificate pinning
- [ ] Retrofit generator inputs and generated services
- [ ] Backend provider binding used by the running feature

Any unchecked item is an unresolved runtime behavior decision, not a harmless
template conflict.

## Verification

All paths:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart analyze --fatal-warnings
flutter test
flutter build bundle --debug --dart-define-from-file=config/development.json
```

Template maintainers can exercise the representative retained-REST and
SDK/no-REST projects with:

```bash
./scripts/check-rest-opt-in.sh
./scripts/check-rest-adopter-migration.sh
```

For an active REST app, also run a request against a controlled endpoint and
test authenticated, expired-token, timeout, and mapped-error cases. For an SDK
app, launch the SDK-backed flow and repeat the negative scans after code
generation.

## Expected Conflicts

| File or area | Resolution |
|---|---|
| `pubspec.yaml`, `pubspec.lock` | Retain REST dependencies only for path 2A, regenerate for 2B, remove stale entries for 2C |
| `build.yaml` | Retain the old Retrofit builder for 2A, take capability output for 2B, keep it absent for 2C |
| `lib/core/http/**` | Preserve as project-owned for 2A, replace deliberately for 2B, keep absent for 2C |
| `lib/core/env/app_environment.dart` | Preserve only configuration still consumed by project code |
| `config/**` | Never overwrite secrets; preserve the selected backend's consumed values |
| Provider files and generated sources | Keep the selected backend binding and regenerate only after resolving source files |

## Can Skip?

**No.** Every downstream project must classify its backend path. SDK/no-backend
projects usually have no code migration beyond accepting the neutral baseline,
but they still need the negative verification so REST artifacts do not return.
