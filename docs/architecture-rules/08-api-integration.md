# Architecture Rule 08: API Integration

## Overview

Features default to **mock repository implementations**. When connecting a real backend, Dio + Retrofit is the reference REST API integration, but it is one option among several. Features may also integrate SDK-based backends (e.g., Supabase, Firebase) where the SDK itself acts as the service layer.

For REST APIs, the project uses **Retrofit** for code-generated service classes and **Dio** for the HTTP client with a composable interceptor chain. Dio infrastructure lives in `core/http/`. Each feature defines its own Retrofit service, and all services share a single configured Dio instance.

## Retrofit Service Definition (Dio Backend)

Each feature's API surface is defined as an abstract Retrofit class:

```dart
// features/auth/data/services/auth_service.dart
@RestApi(parser: .DartMappable)
abstract class AuthService {
  factory AuthService(Dio dio) = _AuthService;

  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST('/auth/logout')
  Future<void> logout();

  @GET('/auth/me')
  Future<UserDto> getCurrentUser();
}
```

Key rules:

- One service per feature (e.g., `AuthService`, `ProfileService`).
- Services are stateless -- they receive Dio via constructor and do nothing else.
- Return types are DTOs (from `data/models/`), not domain entities.
- Request bodies use `@Body()` with request DTO classes.

## Service Provider

Each service gets a Riverpod provider, typically defined alongside the ViewModel:

```dart
@riverpod
AuthService authService(Ref ref) {
  return AuthService(ref.read(dioProvider));
}
```

## Dio Configuration

The main Dio instance is created in `core/http/dio_provider.dart`:

```dart
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final logger = ref.read(loggerProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnvironment.current.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage),
    RefreshTokenInterceptor(
      tokenStorage: tokenStorage,
      dio: refreshDio,           // Separate Dio to avoid recursion
      onAuthExpired: () => ref.invalidateSelf(),
    ),
    LoggingInterceptor(logger),
    ErrorInterceptor(),
  ]);

  return dio;
}
```

## Interceptor Chain

Interceptors execute in the order they are added:

| Order | Interceptor | Responsibility |
|-------|------------|----------------|
| 1 | `AuthInterceptor` | Adds `Authorization: Bearer <token>` header |
| 2 | `RefreshTokenInterceptor` | Intercepts 401, refreshes token, retries request |
| 3 | `LoggingInterceptor` | Logs request/response with sensitive data redaction |
| 4 | `ErrorInterceptor` | Maps `DioException` to `DioApiException` subtypes |

### AuthInterceptor

Reads the access token from `ITokenStorage` and adds it to request headers:

```dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);
  final ITokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

### RefreshTokenInterceptor

Extends `QueuedInterceptor` to serialize concurrent 401 handling:

- On 401, acquires the queue lock, calls the refresh endpoint.
- Uses a **separate Dio instance** (no auth/refresh interceptors) to avoid recursion.
- On success, saves new tokens and retries the original request.
- On failure, clears tokens and calls `onAuthExpired` callback.

### ErrorInterceptor

Maps `DioException` types to `DioApiException` subtypes for structured error handling in repositories.

## Auth Flow Summary

```
Request -> AuthInterceptor (adds token) -> Server
                                              |
                                        401 Unauthorized
                                              |
RefreshTokenInterceptor (queues requests, calls /auth/refresh)
  |                             |
  Success                       Failure
  |                             |
  Retry original request        Clear tokens, call onAuthExpired
```

## SDK-Based Backends

When using an SDK-based backend (e.g., Supabase, Firebase), the SDK client replaces the Retrofit service layer. There is no need for Retrofit or Dio in these features.

- The repository implementation calls the SDK client directly.
- Backend-specific exceptions (e.g., `AuthException` from Supabase) are caught in the repository and mapped to feature-specific `Failure` types.
- `DioApiException` and the Dio interceptor chain are not involved.
- DTOs and mappers may still be needed when SDK response types differ from domain entities.

## Feature Default: Mock Implementations

Features start with a **mock repository** that returns hardcoded or in-memory data. This enables UI development and testing without a backend.

- The repository provider wires the mock implementation by default.
- To connect a real backend, implement the repository interface against Dio/Retrofit or an SDK, then swap the provider binding.
- Services are Dio/Retrofit-specific. DTOs and mappers may be needed for any backend whose response types differ from domain entities.

## Adding a New API Feature (Dio/Retrofit)

1. Create DTOs in `features/<name>/data/models/`.
2. Create the Retrofit service in `features/<name>/data/services/`.
3. Create a Riverpod provider for the service.
4. Run `dart run build_runner build`.
5. Implement the repository interface, calling the service and returning `Result<T>`.
6. Update the repository provider to wire the real implementation instead of the mock.

## DO

- Use one Retrofit service per feature.
- Share the single `dioProvider` across all services.
- Use `@Body()` for request bodies, `@Query()` for query parameters, `@Path()` for path parameters.
- Map all DioExceptions to DioApiExceptions in the ErrorInterceptor.
- Use the separate "refresh Dio" for token refresh calls.

## DO NOT

- Do not create Dio instances outside of `core/http/dio_provider.dart`.
- Do not add feature-specific interceptors to the shared Dio instance.
- Do not call Dio directly from repositories -- always go through a Retrofit service.
- Do not return raw `Response` objects from services -- use typed DTOs.
- Do not handle authentication logic in individual services -- let the interceptor chain handle it.
