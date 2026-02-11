# ADR 003: Dio + Retrofit for Networking

## Status

Accepted

## Context

The application needs a structured HTTP client layer with:

- Interceptor chains for authentication, token refresh, logging, and error mapping.
- Code-generated API service classes that mirror the REST contract.
- Per-feature service definitions that are testable in isolation.
- Centralized timeout, base URL, and header configuration.

Alternatives considered:

- **http package**: Lightweight but lacks interceptors, making cross-cutting concerns (auth headers, refresh) difficult to implement cleanly.
- **Chopper**: Code-generated HTTP client similar to Retrofit but with a smaller community and less active development.
- **GraphQL (graphql_flutter, ferry)**: Not applicable; the template targets REST APIs.

## Decision

Use **Dio** as the HTTP client and **Retrofit** (with **retrofit_generator**) for code-generated API service classes.

Architecture:

- A single `Dio` instance is created in `dio_provider.dart` with the full interceptor chain: `AuthInterceptor` -> `RefreshTokenInterceptor` -> `LoggingInterceptor` -> `ErrorInterceptor`.
- A separate "plain" Dio instance (no auth/refresh interceptors) is created for the refresh token endpoint to avoid interceptor recursion.
- Each feature defines a Retrofit `@RestApi()` abstract class (e.g., `AuthService`, `ProfileService`) that takes `Dio` as a constructor parameter.
- `ErrorInterceptor` maps `DioException` to `AppException` subtypes, which repositories then convert to `Failure` values.

## Consequences

### Positive

- **Interceptor chain**: Cross-cutting concerns are cleanly separated into composable interceptors.
- **Type-safe APIs**: Retrofit generates request/response serialization code from annotated method signatures.
- **Testability**: Services can be mocked at the interface level; Dio itself can be mocked for interceptor tests.
- **Token refresh**: `QueuedInterceptor` in `RefreshTokenInterceptor` serializes concurrent 401 handling automatically.

### Negative

- **Two-library dependency**: Both Dio and Retrofit must be maintained and kept compatible.
- **Code generation**: Each service produces a `.g.dart` file via `build_runner`.
- **Interceptor ordering matters**: Incorrect ordering (e.g., error interceptor before auth) breaks the pipeline silently.

### Neutral

- The `ErrorInterceptor` -> repository -> `Result<T>` chain ensures exceptions never leak to the UI layer.
- Dio's `BaseOptions` centralizes timeout and base URL configuration sourced from `AppEnvironment`.
