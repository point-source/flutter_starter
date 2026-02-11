# ADR 007: Feature-First Architecture

## Status

Accepted

## Context

Flutter projects commonly use one of two high-level directory structures:

1. **Layer-first**: Top-level directories for each architectural layer (`data/`, `domain/`, `presentation/`), with features nested inside each layer.
2. **Feature-first**: Top-level directories for each feature (`auth/`, `profile/`, `settings/`), with layers nested inside each feature.

The template needs a structure that:

- Scales from a handful of features to dozens without becoming unwieldy.
- Makes feature boundaries clear for team ownership and code review.
- Supports adding new features without touching existing ones.
- Is navigable by both humans and AI coding agents.

## Decision

Use **feature-first** architecture. Each feature is a self-contained directory under `lib/features/` containing its own `data/`, `domain/`, and `ui/` layers.

Shared infrastructure lives in `lib/core/`, organized by concern (error handling, networking, routing, storage, theming, logging).

Directory structure:

```
lib/
  core/          # Shared infrastructure (no feature logic)
    env/
    error/
    network/
    routing/
    storage/
    theme/
    logging/
    presentation/
    utils/
    l10n/
  features/
    auth/        # Self-contained feature
      data/
        services/
        models/
        mappers/
        repositories/
      domain/
        entities/
        repositories/
        failures/
      ui/
        view_models/
        pages/
        widgets/
    dashboard/
    profile/
    settings/
```

## Consequences

### Positive

- **Feature isolation**: Adding, removing, or modifying a feature affects only its own directory subtree.
- **Team scalability**: Different developers or teams can own different features with minimal merge conflicts.
- **Discoverability**: Finding all code related to "auth" means looking in one directory, not three.
- **Consistent structure**: Every feature follows the same internal layout, making the codebase predictable.

### Negative

- **Shared code tension**: Logic shared between features must live in `core/` or a shared feature, which requires judgment about when to extract.
- **Cross-feature dependencies**: When feature A needs data from feature B, the dependency must flow through providers rather than direct imports of internal files.
- **Domain layer may feel redundant**: For simple features (e.g., settings with no API), the domain layer is optional and may be skipped.

### Neutral

- The `auth` feature serves as the canonical reference implementation that all new features should follow.
- Mason bricks automate the creation of new features with the correct directory structure.
