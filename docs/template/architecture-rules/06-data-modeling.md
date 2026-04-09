# Architecture Rule 06: Data Modeling

## Overview

Data models are split into **DTOs** (data transfer objects) in the data layer and **entities** in the domain layer. Both use `@MappableClass()` from dart_mappable. Mapper extensions convert between the two. Sealed classes for `Result`, `Failure`, and state types are written manually without dart_mappable.

## DTOs (Data Layer)

DTOs mirror the JSON shape returned by the API. They live in `features/<name>/data/models/`.

```dart
// features/auth/data/models/user_dto.dart
@MappableClass()
class UserDto with UserDtoMappable {
  const UserDto({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
}
```

Key rules:

- Field names match the JSON keys (use `@MappableField(key: 'json_key')` when they differ).
- All DTOs have `const` constructors.
- DTOs are never exposed to the UI layer.
- Generated `.mapper.dart` file provides `fromJson`, `toJson`, `copyWith`, and value equality.

## Entities (Domain Layer)

Entities represent domain concepts with meaningful names and types. They live in `features/<name>/domain/entities/`.

```dart
// features/auth/domain/entities/user.dart
@MappableClass()
class User with UserMappable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
}
```

Key rules:

- Entities may have computed properties, domain validation, or different field names than the DTO.
- Entities must not depend on data-layer classes (Dio, Retrofit, DTOs).
- Entities are the types used by ViewModels and Views.

## Mappers

Mapper extensions convert DTOs to entities. They live in `features/<name>/data/mappers/`.

```dart
// features/auth/data/mappers/user_mapper.dart
extension UserDtoMapper on UserDto {
  User toDomain() {
    return User(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
    );
  }
}
```

Key rules:

- Mappers are `extension` methods on the DTO, not standalone functions.
- The method is named `toDomain()`.
- Mapping is done in the repository, immediately after receiving the DTO from the service.
- For collections, use `.map((dto) => dto.toDomain()).toIList()` when using fast_immutable_collections.

## Request Models

Request DTOs represent the body of POST/PUT requests:

```dart
@MappableClass()
class LoginRequest with LoginRequestMappable {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
```

## Immutable Collections

Use `IList`, `IMap`, `ISet` from fast_immutable_collections for domain model collections. Register a global `MappableHook` to handle serialization:

```dart
// In bootstrap or a dedicated hooks file
MapperContainer.globals.use(
  SimpleHook(
    decode: (value) => IList.fromJson(value),
    encode: (value) => (value as IList).unlock,
  ),
);
```

## When NOT to Use dart_mappable

Use plain Dart 3 sealed classes (no `@MappableClass`) for:

- `Result<T>` and its subtypes (`Success`, `Err`).
- `Failure` and its subtypes.
- State types used by ViewModels (e.g., `AuthState`).
- Any type that never needs JSON serialization.

```dart
// Plain sealed class -- no dart_mappable
sealed class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.stackTrace]);
}
```

## DO

- Use `@MappableClass()` on all DTOs and domain entities.
- Keep DTOs in `data/models/` and entities in `domain/entities/`.
- Create mapper extensions in `data/mappers/` for every DTO-entity pair.
- Use `const` constructors on all model classes.
- Use `IList` instead of `List` in domain entities for immutability.

## DO NOT

- Do not expose DTOs to the UI layer -- always map to entities first.
- Do not put JSON annotations on domain entities (they should not know about the API format).
- Do not use dart_mappable for `Result`, `Failure`, or state union types.
- Do not create mutable models (no `var` fields, no setters).
- Do not write `==`, `hashCode`, `toString`, or `copyWith` manually when dart_mappable provides them.
