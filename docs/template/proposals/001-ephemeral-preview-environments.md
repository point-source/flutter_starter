# Proposal 001: Ephemeral Preview Environments

**Status:** Draft

## Problem

There is no way to spin up an isolated frontend + backend environment for
reviewing a pull request or testing the `develop` branch. Reviewers must either
run the app locally with mock data or trust CI alone. This limits QA/QC
coverage -- especially for changes that touch backend integration, auth flows,
or data-dependent UI.

## Vision

A PR (or push to `develop`) triggers an ephemeral environment:

- **Supabase preview branch** -- isolated database, auth, storage, and edge
  functions with seeded data
- **Cloudflare Workers static-assets preview deployment** -- Flutter web
  build pointed at the Supabase branch's API URL and anon key

The environment is accessible via a unique URL posted as a PR comment. When the
PR is merged or closed, the Supabase branch is cleaned up automatically;
Cloudflare ages out old Worker versions on its own.

## Research Findings

### Cloudflare Workers Preview Deployments

- The `wrangler versions upload` command uploads a draft version of a
  Worker without rolling production forward. Each upload returns a unique
  preview URL (`<version>-<worker>.<subdomain>.workers.dev`) that stays
  reachable until Cloudflare ages it out.
- This works with **direct upload** -- no need to connect the Cloudflare
  GitHub integration. Our existing `deploy-web.yml` workflow already wires
  this up via the `preview: true` input.
- Worker versions are retained subject to account limits; cost is
  negligible on the free tier for static assets.
- SPA routing is handled in `wrangler.toml` via
  `not_found_handling = "single-page-application"` -- no `_redirects`
  file needed.

Reference: https://developers.cloudflare.com/workers/static-assets/ and
https://developers.cloudflare.com/workers/configuration/versions-and-deployments/

### Supabase Branching

- Creates an isolated Supabase instance per branch (database, auth, storage,
  realtime, edge functions with secrets).
- **Preview branches** auto-pause after inactivity and auto-delete when the
  associated PR is merged or closed. This is the primary cost control mechanism.
- **Persistent branches** are available for long-lived environments (e.g., a
  permanent staging branch) that should not auto-pause.
- **Branches start empty** -- no data is cloned from the main project.
  Seeding must be configured explicitly via `seed.sql` or a seeding tool.
- Supabase has a GitHub integration that can automate branch creation per PR.

Reference: https://supabase.com/docs/guides/deployment/branching

### Data Seeding

Branches start with an empty database. Options for seeding:

1. **`seed.sql`** -- Supabase runs this automatically when a branch is created
   (if configured). Good for small, static seed data.
2. **`@snaplet/seed`** -- generates realistic synthetic data from your schema.
   Type-safe TypeScript API, deterministic output, handles foreign keys
   automatically. Does _not_ clone production data -- purely synthetic.
   Reference: https://github.com/supabase-community/seed
3. **Sanitized production subset** -- copy production data with PII
   stripped/anonymized. More realistic but adds complexity and privacy risk.

Recommendation: start with `@snaplet/seed` for synthetic data. It is
deterministic (reproducible), avoids PII concerns, and integrates into CI. A
sanitized production subset can be explored later if synthetic data proves
insufficient.

## Approach

A layered implementation, where each layer is independently useful:

### Layer 1: Manual Web Deployment + Reusable Workflow (Done)

`.github/workflows/deploy-web.yml` -- manually triggered Cloudflare Workers
static-assets deployment for staging/production. Originally wired to
Cloudflare Pages and migrated to Workers in migration 009. Supports
`workflow_call` with `ref`, `preview`, and `deployment_url` output, making
it a reusable building block for automated deployments.

### Layer 2: Frontend Preview Deployments (Ready to implement)

The reusable workflow interface is in place. Implementing Layer 2 requires
creating caller workflows that invoke `deploy-web.yml` via `workflow_call`.
See `docs/template/DEPLOYMENT.md` >
[Calling deploy-web.yml from another workflow](../DEPLOYMENT.md#calling-deploy-webyml-from-another-workflow)
for copy-paste workflow files covering:

- **Push to production** -- deploy on merge to `main`
- **Push to staging** -- deploy on merge to `develop`/`staging`
- **PR preview** -- deploy a preview URL per PR, post it as a comment

The web app is built with the **staging** config and deployed to Cloudflare
via `wrangler versions upload` (i.e. `preview: true`), which returns a
unique versioned preview URL per upload. This gives reviewers a live
preview URL for frontend-only changes, pointed at the shared staging
backend, without rolling the live staging Worker.

**What this enables:** visual review of UI changes without running locally.
**Limitation:** all PRs share the same staging backend -- no data isolation.

### Layer 3: Full Ephemeral Environments

A new workflow (or extension of Layer 2) that orchestrates both services:

1. **On PR open/synchronize:**
   - Create or reuse a Supabase preview branch (via GitHub integration or API)
   - Wait for the branch to be ready
   - Extract the branch's `API_URL` and `ANON_KEY`
   - Build the Flutter web app with those credentials injected into the config
   - Deploy to Cloudflare Workers via `wrangler versions upload` (i.e.
     `preview: true` on the reusable workflow)
   - Post the versioned preview URL as a PR comment

2. **On PR close/merge:**
   - Supabase auto-deletes the preview branch (built-in behavior)
   - Cloudflare ages out old Worker versions on its own (no cost)

3. **Data seeding:**
   - Configure `@snaplet/seed` with the project schema
   - Run the seed script as a step after Supabase branch creation
   - Or use Supabase's built-in `seed.sql` support

### Orchestration Challenges

The key complexity in Layer 3 is the **compile-time credential injection**.
Flutter web builds bake environment values into the JS bundle via
`--dart-define-from-file`. The workflow must:

1. Wait for the Supabase branch to be fully provisioned
2. Query its API URL and anon key
3. Write a temporary config JSON with those values
4. Build the Flutter web app against that config

This creates a serial dependency: Supabase branch ready → extract creds →
build → deploy. The workflow cannot parallelize the build and branch creation.

## Cost Control

- **Supabase preview branches** auto-pause after inactivity -- this is the
  primary cost lever. Only active review generates compute cost.
- **PR label gating** -- only create ephemeral environments for PRs with a
  specific label (e.g., `preview-env`). This avoids spinning up environments
  for trivial changes.
- **Persistent staging branch** -- for the `develop` branch, use a Supabase
  persistent branch instead of a preview branch, so it remains available for
  ongoing QA without auto-pausing.
- **Cloudflare Workers static assets** -- free-tier generous for static
  assets. Versioned preview uploads have negligible cost; Cloudflare ages
  out old versions automatically.

## Open Questions

1. **Supabase branch creation method** -- use the GitHub integration (automatic
   per PR) or the Supabase Management API (more control, explicit in workflow)?
   The GitHub integration is simpler but less flexible.

2. **Credential extraction** -- how to programmatically get the API URL and
   anon key for a Supabase preview branch? Likely via the Management API.

3. **Seed data scope** -- what data does the app need to be meaningfully
   testable? Auth users, sample content, feature flags? This determines the
   seed script complexity.

4. **`develop` branch treatment** -- should `develop` get a persistent Supabase
   branch (always-on staging) or a preview branch (auto-pauses)? Persistent is
   better for QA but has ongoing cost.

5. **PR comment bot** -- use `actions/github-script` to post the preview URL,
   or a dedicated action? Should it update the same comment on subsequent pushes
   or post new ones?

6. **Edge functions** -- if the project uses Supabase edge functions, do they
   need to be deployed to the preview branch as part of the workflow?

7. **Multiple providers** -- the `deploy-web.yml` workflow supports a provider
   choice. Should Layer 2/3 be provider-agnostic, or is Cloudflare the assumed
   target for preview deployments?
