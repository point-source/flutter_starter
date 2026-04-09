# Design Proposals

> **Template proposals.** This directory contains design proposals for the
> `flutter_starter` template, not your derived project. For your project's
> proposals, use `docs/project/`.

This directory contains design proposals for significant future work items.
Proposals capture the problem, research findings, trade-offs, and a rough
implementation plan before the work begins.

## When to Write a Proposal

Write a proposal when a roadmap item:

- Involves multiple systems or services (e.g., CI + backend + frontend)
- Has non-obvious trade-offs or open questions
- Would benefit from discussion before implementation

Not every roadmap item needs a proposal. Small improvements can live as a
paragraph in [ROADMAP.md](../ROADMAP.md) until they grow complex enough to
warrant one.

## Format

Proposals are numbered sequentially (`001-`, `002-`, ...) with a descriptive
slug. There is no rigid template -- include whatever sections make the proposal
clear:

- **Problem** -- what is missing or broken
- **Vision** -- what the end state looks like
- **Research** -- key findings, external docs, service capabilities
- **Approach** -- recommended path, possibly in phases
- **Open Questions** -- unresolved decisions
- **References** -- links to external documentation

## Lifecycle

| Stage | Meaning |
|---|---|
| **Draft** | Under research, not yet actionable |
| **Ready** | Research complete, ready to implement |
| **In Progress** | Implementation underway |
| **Done** | Implemented; proposal kept for historical context |

Update the status at the top of each proposal as it progresses.
