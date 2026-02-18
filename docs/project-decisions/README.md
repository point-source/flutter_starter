# Project Decisions

This directory is for **your project's** Architecture Decision Records (ADRs) -- decisions about the app you're building on top of `flutter_starter`, not decisions about the template itself.

Template-level ADRs (tech stack, architecture patterns, infrastructure choices) live in [`docs/adrs/`](../adrs/) and are maintained by the template.

## When to Write a Project ADR

Record a decision here when your team:

- Chooses a backend or third-party service (Supabase, Firebase, Stripe, etc.)
- Establishes a business-domain modeling convention
- Picks a deployment or CI/CD strategy
- Decides on a testing approach that differs from or extends the template's
- Makes any significant technical decision specific to your app

## Format

Follow the same format as template ADRs:

```markdown
# ADR NNN: Short Descriptive Title

## Status

Accepted | Superseded by [NNN] | Deprecated

## Context

The problem or decision point.

## Decision

What was chosen and why.

## Consequences

Positive, negative, and neutral trade-offs.
```

## Numbering

Start numbering at **100** to keep a clear visual separation from template ADRs (which use 001--011+). Collisions are already impossible since the directories are separate, but the numbering gap makes it obvious at a glance which category a decision belongs to.

## Examples

- `100-choose-supabase-for-backend.md`
- `101-use-stripe-for-payments.md`
- `102-deploy-to-cloud-run.md`
