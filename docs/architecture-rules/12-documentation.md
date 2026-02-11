# Architecture Rule 12: Documentation

## Overview

Documentation serves two audiences: **human developers** reading code and docs, and **AI coding agents** (Claude Code, Cursor, Copilot) that consume project context to generate correct code. All public APIs require docstrings. Architecture decisions are recorded in ADRs. Patterns are documented in architecture rules.

## Docstrings (Required on All Public APIs)

Every public class, method, property, and top-level function must have a `///` doc comment.

### Format

- **First line**: Single sentence describing *what* it does, in imperative mood ("Creates...", "Returns...", "Handles...").
- **Additional lines** (when needed): *Why* it exists, edge cases, usage examples.
- **Parameters**: Document non-obvious parameters using `[paramName]` inline references.

### Examples

```dart
/// Attempts to log in with the given [email] and [password].
///
/// Returns [Success] with the authenticated [User] on success,
/// or [Err] with an [AuthFailure] on failure (invalid credentials,
/// network error, etc.).
Future<Result<User>> login(String email, String password);
```

```dart
/// Provides the main [Dio] instance with all interceptors configured.
///
/// This is the Dio instance that all retrofit services should use.
/// It includes auth, refresh, logging, and error interceptors.
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) { ... }
```

```dart
/// Store authentication tokens in [FlutterSecureStorage].
///
/// Tokens are written under the keys [_accessTokenKey] and
/// [_refreshTokenKey]. All reads and writes delegate directly to the
/// underlying [FlutterSecureStorage] instance supplied at construction.
class SecureTokenStorage implements ITokenStorage { ... }
```

### When to Add Detail

Add the extended description (beyond the first line) when:

- The behavior is non-obvious or has edge cases.
- The method has side effects (token persistence, state invalidation).
- The class plays a specific role in the architecture (worth calling out).
- Usage examples would help the reader.

## Inline Comments

### Rule: Explain WHY, Not WHAT

The code shows what happens. Comments explain why.

```dart
// GOOD: explains why
// Always clear tokens locally even if the server call fails,
// so the user is never stuck in a stale auth state.
await _tokenStorage.clearTokens();

// BAD: explains what (the code already says this)
// Clear the tokens
await _tokenStorage.clearTokens();
```

### When Required

- Workarounds for framework bugs or library limitations.
- Non-obvious business rules that are not self-documenting.
- Performance optimizations that sacrifice readability.
- Regular expressions (explain what the pattern matches).
- Magic numbers or constants without self-documenting names.

### When NOT Needed

- Self-explanatory code (`final user = response.user.toDomain();`).
- Standard patterns documented in architecture rules.
- Simple variable assignments or constructor calls.

## File-Level Comments

Each file starts with a `///` doc comment on the primary class or function, explaining its role in the architecture:

```dart
/// Retrofit service for authentication API endpoints.
///
/// Defines the HTTP contract for login, registration, logout, and
/// session retrieval. The generated implementation delegates to [Dio]
/// and handles JSON serialisation via dart_mappable.
library;

// ... imports and code
```

Use the `library;` directive to attach the file-level doc comment to the library itself, making it visible in generated documentation.

## Generated Code

- **Never document** generated files (`.g.dart`, `.gr.dart`, `.mapper.dart`).
- **Always document** the source annotations that drive generation:
  - The `@RestApi()` class and its methods.
  - The `@riverpod` / `@Riverpod` annotated functions and classes.
  - The `@MappableClass()` class and its fields.
  - The `@RoutePage()` widget.

## ADRs (Architecture Decision Records)

Location: `docs/adrs/`

Format:
1. **Title**: `NNN-short-descriptive-name.md`
2. **Status**: Accepted, Superseded, or Deprecated.
3. **Context**: The problem or decision point.
4. **Decision**: What was chosen and why.
5. **Consequences**: Positive, negative, and neutral trade-offs.

Update ADRs when:
- A technology choice changes (create a new ADR, mark the old one as Superseded).
- A decision is revisited with new information.

## Architecture Rules

Location: `docs/architecture-rules/`

Format:
1. **Overview**: One-paragraph summary of the rule.
2. **Pattern description**: How the pattern works, with code examples.
3. **DO / DO NOT**: Concrete rules for following the pattern.

Update architecture rules when:
- A pattern evolves or a new convention is established.
- Common mistakes are discovered during code review.

## CLAUDE.md

The root-level `CLAUDE.md` file provides AI coding agents with:
- Project overview and architecture summary.
- Pointers to `docs/architecture-rules/` for detailed patterns.
- Coding conventions (naming, imports, file organization).
- Common commands (build, test, code gen, lint).
- Reference to the auth feature as the canonical implementation.

Update `CLAUDE.md` when:
- New conventions are established.
- New commands or workflows are added.
- The project structure changes.

## DO

- Write docstrings on every public class, method, property, and top-level function.
- Use imperative mood for the first line ("Creates...", "Returns...", "Handles...").
- Document the *why* in inline comments, not the *what*.
- Keep ADRs up to date when decisions change.
- Update architecture rules when patterns evolve.
- Document source annotations, not generated output.

## DO NOT

- Do not write doc comments on private members unless the logic is non-obvious.
- Do not document generated files.
- Do not use `//` comments to disable code -- remove dead code entirely.
- Do not write comments that restate the code (`// increment counter` above `counter++`).
- Do not let documentation drift from the actual implementation -- if the code changes, update the docs.
- Do not create documentation files unless explicitly required or updating existing ones.
