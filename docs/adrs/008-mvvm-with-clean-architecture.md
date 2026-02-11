# ADR 008: MVVM with Clean Architecture Layers

## Status

Accepted

## Context

The application needs a clear separation of concerns within each feature. The Flutter Architecture Guide recommends MVVM (Model-View-ViewModel), while Clean Architecture provides layering rules for data flow and dependency direction.

Requirements:

- Views should be declarative and free of business logic.
- Business logic should be testable without Flutter framework dependencies.
- Data sources should be swappable (mock server, local cache, real API).
- The dependency direction should flow inward (UI -> Domain -> Data), with domain having no external dependencies.

Alternatives considered:

- **BLoC pattern**: Event-driven state management. Adds ceremony with event classes and explicit state transitions. Well-suited for complex state machines but overkill for CRUD screens.
- **MVC**: Traditional but blurs the line between controller and view in Flutter's widget model.
- **Pure Clean Architecture**: Three strict layers with use cases as the only domain-layer construct. Often results in thin use cases that just proxy repository calls.

## Decision

Adopt **MVVM** (as recommended by the Flutter Architecture Guide) combined with **Clean Architecture layering**, with the following adaptations:

### Three Layers

1. **UI Layer**: Views (widgets) + ViewModels (Riverpod `AsyncNotifier` classes).
2. **Domain Layer**: Entities, repository interfaces, feature-specific failures. Optional -- only add use cases when business logic spans multiple repositories.
3. **Data Layer**: Repository implementations, Retrofit services, DTOs, mappers.

### Key Rules

- Views know only their ViewModel (accessed via a Riverpod provider).
- ViewModels call repository interfaces (or use cases when needed).
- Repositories call services and map DTOs to domain entities.
- Services are stateless HTTP wrappers (Retrofit-generated).
- Dependency direction: UI depends on Domain, Domain depends on nothing, Data implements Domain interfaces.

### Domain Layer is Optional

The domain layer exists only when a feature has:

- Entities distinct from DTOs (different shape, computed fields, domain validation).
- Feature-specific failures that warrant a sealed hierarchy.
- Use cases that orchestrate logic across multiple repositories.

For simple features (e.g., settings), the UI layer may depend directly on data-layer repositories.

## Consequences

### Positive

- **Testability**: ViewModels are tested by overriding repository providers. Repositories are tested by mocking services. No Flutter widgets needed for business logic tests.
- **Separation of concerns**: Views handle rendering, ViewModels handle state, repositories handle data orchestration, services handle HTTP.
- **Flexible domain layer**: Not forcing use cases where they add no value reduces boilerplate.
- **Framework alignment**: MVVM matches the Flutter Architecture Guide, making onboarding easier.

### Negative

- **Layer count**: Three layers per feature can feel heavy for trivial features. Mitigated by making the domain layer optional.
- **Mapper boilerplate**: DTO-to-entity mapping adds extension methods that are mostly field-by-field copies.
- **Indirect data access**: The repository interface in domain and implementation in data creates indirection that may feel unnecessary for small features.

### Neutral

- The `auth` feature demonstrates the full three-layer pattern as the reference implementation.
- The `settings` feature demonstrates the simplified pattern (UI + data, no domain layer).
