# ADR 004: dart_mappable for Data Modeling

## Status

Accepted

## Context

The application needs data classes with:

- JSON serialization/deserialization for API communication.
- Value equality for state comparison and testing.
- `copyWith` for immutable updates.
- Minimal boilerplate while remaining readable.

Alternatives considered:

- **freezed**: The most popular code-gen data class solution. Provides unions, `copyWith`, and JSON serialization (via json_serializable). However, freezed generates verbose files with factory constructors that obscure the class structure, and its union types impose a factory-based pattern that conflicts with Dart 3 sealed classes.
- **json_serializable**: JSON-only; does not provide `copyWith` or value equality.
- **Manual implementation**: No build step but high boilerplate for `==`, `hashCode`, `copyWith`, and `toJson`/`fromJson`.

## Decision

Use **dart_mappable** with **dart_mappable_builder** for DTOs and domain entities that need JSON serialization and `copyWith`.

Usage strategy:

- **DTOs** (data layer): Annotated with `@MappableClass()` for JSON round-tripping. These mirror the API response shape.
- **Domain entities**: Also annotated with `@MappableClass()` for `copyWith` and value equality. JSON serialization on entities is available but rarely used directly.
- **Result, Failure, and state types**: Use plain Dart 3 `sealed class` syntax without dart_mappable, since these types never need JSON serialization and benefit from manual control over their constructors.
- **Immutable collections**: A global `MappableHook` converts between `IList`/`IMap` (fast_immutable_collections) and `List`/`Map` during serialization.

## Consequences

### Positive

- **Clean generated code**: dart_mappable generates `.mapper.dart` files that are smaller and more readable than freezed output.
- **Dart 3 alignment**: Works with standard class declarations and `const` constructors rather than factory-based patterns.
- **Selective usage**: Only applied to types that genuinely need serialization, keeping the error handling and state types simple.
- **Hook system**: `MappableHook` enables custom serialization for `IList`, `DateTime`, and other special types globally.

### Negative

- **Smaller ecosystem**: dart_mappable has a smaller community than freezed/json_serializable.
- **Code generation**: Another generator in the `build_runner` pipeline (`.mapper.dart` files).
- **Two patterns**: Developers must understand when to use `@MappableClass()` versus plain sealed classes.

### Neutral

- DTOs and entities live in separate directories (`data/models/` vs `domain/entities/`) and are connected by explicit mapper extensions.
- Generated `.mapper.dart` files are committed to the repository.
