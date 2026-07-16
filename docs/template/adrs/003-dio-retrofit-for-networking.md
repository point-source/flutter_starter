# ADR 003: Dio + Retrofit for Opted-in REST Networking

## Status

Accepted — applies only after the project installs the `dio_rest` capability.

**Scope update:** The backend-neutral starter does not contain Dio, Retrofit,
`core/http/`, REST configuration, or REST code generation. This decision becomes
active for a project only when it deliberately runs `mason make dio_rest`. See
ADR-011 for the neutral mock-first baseline.

## Context

A project that has selected a custom REST API may need a structured HTTP client
with typed endpoints, configuration, logging, and transport-error handling. That
need is specific to the REST choice; SDK-backed, local, custom-client, and
mock-only projects do not benefit from inheriting the same dependencies.

Alternatives considered for REST projects included the `http` package, Chopper,
GraphQL clients, and a copy-and-paste recipe. The supported capability retains
the established Dio/Retrofit pattern as a coherent opt-in rather than making it
part of every starter app.

## Decision

When a project explicitly installs `dio_rest`:

- Dio is the REST transport client.
- Retrofit and `retrofit_generator` provide typed per-feature REST services.
- The capability owns `lib/core/http/`, `REST_API_URL`, its dependencies,
  generator configuration, tests, and capability marker.
- REST services and transport models remain in the data layer.
- REST repositories catch `DioException`/`DioApiException`, map them to
  application `Failure` values, and return the same `Result<T>` contract used by
  every other repository implementation.
- Concrete setup and maintenance instructions live in the generated
  `docs/project/REST_DIO.md` file.

This ADR does not select REST for the base starter and does not make transport
types part of domain or presentation APIs.

## Consequences

### Positive

- REST teams receive a cohesive, tested capability instead of disconnected
  feature fragments.
- Retrofit services provide typed endpoint wrappers and generated serialization.
- Transport details stay behind the repository boundary.
- Feature-level REST generation fails early until the capability is installed.

### Negative

- Opted-in projects own two additional libraries and their compatibility.
- REST services add code generation and capability-specific configuration.
- Client/interceptor ordering and transport security require project review.

### Neutral

- Mock, SDK, local, custom-client, and REST implementations remain peers behind
  repository interfaces.
- Removing the capability is a coordinated project migration, not deletion of
  dormant base files.
