# Roadmap

Future work items and planned improvements for the Flutter Starter template.
Items with significant complexity have detailed design proposals in
[`docs/proposals/`](proposals/).

To add an item, place it under the appropriate category with a short
description. If it needs deeper design work, create a proposal in
`docs/proposals/` and link it here.

---

## CI/CD & Deployment

### Ephemeral Preview Environments

Automatically spin up isolated frontend (Cloudflare Pages) + backend (Supabase
branch) environments for pull requests, with seeded data and automatic cleanup
on merge.

**Proposal:** [001-ephemeral-preview-environments](proposals/001-ephemeral-preview-environments.md)
**Status:** Draft -- Layer 1 (manual web deploy + reusable workflow) is
complete. Layer 2 (automated frontend previews) is ready to implement -- see
[Automated Deployments](WEB_DEPLOYMENT.md#automated-deployments) for
copy-paste caller workflows.
