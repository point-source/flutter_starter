# ADR 005: Sealed Result Type for Error Handling

## Status

Accepted

## Context

Dart's native error handling relies on throwing and catching exceptions. This has several problems for application architecture:

- Exceptions are invisible in function signatures -- callers do not know a function can fail without reading the implementation.
- `try`/`catch` blocks are easily forgotten, leading to unhandled exceptions that crash the app.
- Nested `try`/`catch` creates deeply indented, hard-to-follow control flow.
- There is no compiler enforcement of exhaustive error handling.

Alternatives considered:

- **fpdart (Either)**: Functional programming library providing `Either<L, R>`. However, Dart's lack of native union return types makes `Either` verbose (`.fold()`, `.match()`, `Left`/`Right` names are not domain-meaningful). Adds a heavy dependency for a single type.
- **dartz**: Similar to fpdart but less maintained.
- **try/catch everywhere**: Familiar but violates the principle of making failure handling explicit.
- **Multiple return values**: Not supported in Dart.

## Decision

Implement a custom **sealed `Result<T>`** type with two subtypes: `Success<T>` and `Err<T>`.

The `Result` type provides:

- `when()` -- pattern-match on success or failure.
- `map()` -- transform the success value, leaving failures untouched.
- `flatMap()` -- chain result-producing operations.
- `getOrElse()` / `getOrNull()` -- extract the value with a fallback.
- `isSuccess` / `isFailure` -- simple boolean checks.

The `Failure` hierarchy is a separate abstract class tree:

- Infrastructure failures (`NetworkFailure`, `ServerFailure`, `CacheFailure`) in `core/error/failures.dart`.
- Feature-specific failures (e.g., `AuthFailure`, `ProfileFailure`) in each feature's `domain/failures/` directory.
- All failures carry a `message` and optional `stackTrace`.

Pattern: Repositories return `Result<T>`. ViewModels consume results via `.when()`. Feature-specific failures use `switch` only when different UI responses are needed per failure type.

## Consequences

### Positive

- **Explicit failure**: `Future<Result<User>>` makes the possibility of failure visible in the type signature.
- **Forced handling**: Callers must address both success and failure paths; the compiler helps via exhaustive pattern matching on sealed types.
- **Composable**: `map` and `flatMap` enable chaining without nested try/catch.
- **No stack unwinding**: Failures are values flowing through the type system, not exceptions interrupting control flow.
- **Zero dependencies**: Custom implementation with no external library dependency.

### Negative

- **Wrapping overhead**: Every repository method must wrap service calls in `try`/`catch` and return `Success` or `Err`.
- **Custom code to maintain**: Unlike using a well-tested library, the Result type is owned by the project.
- **Two error systems**: `DioApiException` is used at the service boundary (thrown/caught), while `Failure` is used above the repository boundary (returned as values). Developers must understand the boundary.

### Neutral

- Exceptions (`DioApiException` subtypes) still exist in the data layer -- they are thrown by services/interceptors and caught at the repository boundary.
- The `UnexpectedFailure` catch-all prevents unknown exceptions from escaping the Result wrapper.
