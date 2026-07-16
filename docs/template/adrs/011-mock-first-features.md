# ADR 011: Mock-First Feature Implementation

## Status

Accepted

## Context

The template originally shipped every feature with a full Dio/Retrofit data layer: service, DTOs, mappers, and a Dio-backed repository. This created several problems:

- **Tight coupling to Dio**: Features could not be developed or tested without the Dio HTTP stack, even when the actual backend might use a different SDK (Supabase, Firebase, Auth0).
- **Premature complexity**: New features started with boilerplate for an HTTP client that might never be used, slowing down initial development.
- **Difficult to swap backends**: Replacing Dio with an SDK-based backend required removing the generated service/DTO/mapper layer and rewriting the repository -- more work than starting from scratch.
- **Template assumptions**: The template assumed a custom REST API as the backend, but many projects use third-party services with their own SDKs.

Alternatives considered:

- **Keep Dio as default, add mock option**: This is the previous approach. It privileges one backend choice over others and adds complexity to the environment config.
- **Generate separate bricks per backend**: Too many bricks to maintain; the repository interface pattern already handles this.
- **No default implementation**: Features with only an interface and no implementation don't compile, slowing down iteration.

## Decision

Features default to **mock implementations**. The `mason make feature` command generates:

- Domain layer: entity, failure hierarchy, repository interface
- Data layer: mock repository (returns hardcoded data), providers (returning mock repo)
- UI layer: page and view model

No real-backend client is generated or installed by default. SDK, local,
custom-client, and REST implementations are peers behind the repository
interface. A project adds only the source it deliberately selects.

REST output is available only after `mason make dio_rest` installs the coherent
Dio/Retrofit capability. After that explicit choice, `mason make feature --dio`
or the REST repository/service bricks can generate capability-owned data-layer
material.

## Consequences

### Positive

- **Backend-agnostic**: The template works with any backend. Developers implement `IXxxRepository` with their chosen SDK.
- **Faster UI development**: Mock data is available immediately. No backend setup needed to build and iterate on screens.
- **Explicit backend choice**: Projects add an SDK, local source, custom client,
  or the supported REST capability only when selected.
- **Clean synchronization**: Non-REST projects receive no `core/http/` or
  Dio/Retrofit deletion delta.
- **Simpler mental model**: Features depend on interfaces, not HTTP implementation details.

### Negative

- **Mock data is static**: The default mock repositories return hardcoded data. Developers must implement a real backend for dynamic behavior.
- **Extra step for REST APIs**: Projects using a custom REST API install
  `dio_rest` before requesting REST feature material.

### Neutral

- The repository and `Result<T>` contract remains stable when the selected data
  source changes.
- An opted-in REST project owns `core/http/` and `DioApiException`; neither is a
  base-template concern.
