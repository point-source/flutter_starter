# Roadmap

> **Template document.** This roadmap describes planned improvements to the
> `flutter_starter` template itself, not your derived project. For your
> project's planning, use `docs/project/`.

Future work items and planned improvements for the Flutter Starter template.
Items with significant complexity have detailed design proposals in
[`docs/template/proposals/`](proposals/).

To add an item, place it under the appropriate category with a short
description. If it needs deeper design work, create a proposal in
`docs/template/proposals/` and link it here.

---

## CI/CD & Deployment

### Ephemeral Preview Environments

Automatically spin up isolated frontend (Cloudflare Workers static assets) +
backend (Supabase branch) environments for pull requests, with seeded data
and automatic cleanup on merge.

**Proposal:** [001-ephemeral-preview-environments](proposals/001-ephemeral-preview-environments.md)
**Status:** Draft -- Layer 1 (manual web deploy + reusable workflow) is
complete. Layer 2 (automated frontend previews) is ready to implement -- see
[Calling deploy-web.yml from another workflow](DEPLOYMENT.md#calling-deploy-webyml-from-another-workflow)
for copy-paste caller workflows.

---

## Reference Examples & Tests

The following canonical patterns are not yet demonstrated in any feature.
Adding them would make the template a more complete reference for teams
building production apps.

### Widget tests for pages

No page widget (`login_page.dart`, `register_page.dart`, `dashboard_page.dart`,
`profile_page.dart`, `settings_page.dart`) has a corresponding widget test.
The auth pages in particular should demonstrate the widget testing pattern
(ProviderScope overrides, pumping, AsyncValue assertions).

### Dashboard view model test

`lib/features/dashboard/ui/view_models/dashboard_view_model.dart` has no test
file. As the canonical "simple feature" reference, it should show the basic
notifier testing pattern even though the logic is minimal.

### `TaskChannel` usage example

`TaskChannel` is fully implemented and unit-tested in `core/tasks/`, but no
feature exercises it end-to-end. A natural fit would be an avatar upload in
the profile feature -- demonstrating progress, cancellation, and retry in a
real UI context.

### Family provider example

No `@riverpod` family (parameterised) providers exist under `lib/features/`.
A reference example -- e.g., `userById(String id)` or a paginated list keyed
by query -- would help teams adopt the pattern correctly.

### Pagination example

No feature demonstrates infinite scroll or paginated data loading with
Riverpod, which is one of the most common patterns in production apps.
