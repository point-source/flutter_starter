# Architecture Rule 11: Security

## Overview

Security controls belong to the backend and data source that actually enforce
them. The backend-neutral starter does not claim an HTTP security posture,
certificate pinning, token-refresh protocol, or API-key scheme before a project
selects a backend.

## Repository Boundary

Treat source requests, responses, SDK models, storage records, and exceptions as
data-layer details. Repositories expose domain entities and safe application
failures only.

- Never pass raw source exception messages to the UI.
- Never include credentials, tokens, request payloads, full request URIs, or
  provider secrets in `Failure.message`.
- Redact sensitive fields before operational logging.
- Keep authentication/session types from the selected backend out of domain and
  presentation APIs.

## Local Secrets and Tokens

Use `ITokenStorage` for authentication tokens when the selected backend requires
app-managed tokens. Its implementation uses `flutter_secure_storage`.

- Store access and refresh tokens only in secure storage.
- Do not store tokens in `SharedPreferences`, config JSON, generated files, or
  source control.
- Clear local tokens/session state on logout even if remote logout fails.
- Do not expose token values through providers watched by UI code.
- If an SDK manages sessions itself, follow the SDK's supported secure lifecycle
  rather than copying tokens into the starter's storage abstraction.

## Configuration

- Commit templates and placeholders, never real secrets.
- Supply backend credentials through the deployment environment or approved
  secret store.
- Add only configuration the selected backend consumes.
- Do not expose a security toggle unless changing it has tested runtime effect.
- Mobile and web clients cannot safely hold server secrets. Public client keys
  must still be restricted by the selected provider's authorization controls.

## Authentication and Refresh

Session refresh is backend-specific. An SDK may manage refresh internally, a
custom client may expose a refresh callback, and a REST API may require a queued
refresh request. Implement and test the chosen protocol inside its capability or
data layer; do not encode one protocol into the domain repository interface.

Regardless of mechanism:

1. Serialize refresh when concurrent operations could race.
2. Prevent refresh recursion.
3. Replace stored credentials atomically when possible.
4. Clear invalid session state after terminal refresh failure.
5. Notify application auth state without exposing raw backend errors.
6. Test concurrent expiry, refresh failure, logout, and cold-start restoration.

## Transport Security

Use the selected backend's supported secure transport in staging and production.
The base starter has no certificate-pinning setting. A project must not document
pinning unless the running client enforces it and tests demonstrate the behavior.

After the supported Dio/Retrofit REST capability is explicitly installed, its
generated `docs/project/REST_DIO.md` documents the transport configuration it
actually provides. Project-specific additions such as authentication
interceptors or pinning require their own decision and tests.

## Logging and Monitoring

- Route logs through `IAppLogger`; never use `print()` for operational data.
- Redact authorization headers, cookies, tokens, password fields, query secrets,
  and sensitive payload values.
- Prefer stable operation names and safe identifiers over full URLs or records.
- Report unexpected exceptions with a stack trace, but sanitize attached context.
- Treat monitoring DSNs and release metadata according to provider guidance;
  never assume that obfuscation makes a secret safe for a client app.

## DO

- Keep backend security behavior inside the selected source/capability.
- Return safe `Failure` values above the repository boundary.
- Use secure storage for app-managed credentials.
- Add tests for every security control the project presents to operators.
- Record backend-specific security decisions in `docs/project/decisions/`.

## DO NOT

- Do not hardcode API keys, passwords, private keys, or tokens.
- Do not log credentials, raw payloads, or full sensitive request URIs.
- Do not put SDK/transport exceptions in presentation state.
- Do not describe an optional REST mechanism as base infrastructure.
- Do not add dormant security toggles for future implementations.
