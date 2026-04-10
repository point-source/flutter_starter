# Migration: 009 -- Cloudflare Workers (static assets) for web deploys

## Summary

Migrates the web deployment workflow (`.github/workflows/deploy-web.yml`)
from **Cloudflare Pages** (`wrangler pages deploy`) to **Cloudflare Workers
static assets** (`wrangler deploy` / `wrangler versions upload`).
Cloudflare is steering new and existing static-site projects toward
Workers + static assets and away from Pages -- the Workers runtime is now
the supported path for new projects, has native SPA fallback, and uses the
same `cloudflare/wrangler-action@v3` GitHub Action that the workflow
already invokes.

The Flutter build pipeline itself does not change -- `flutter build web`
output in `build/web/` is still what gets uploaded. Only the upload
mechanism, the SPA-routing config location, the workflow input shape, and
the Cloudflare API token permission change.

Reference:
[Migrating from Pages to Workers](https://developers.cloudflare.com/workers/static-assets/migration-guides/migrate-from-pages/).

## Risk Level

**Medium**

- Workflow file changes are small and surgical, but the deploy step,
  workflow inputs, and the GitHub variable name all change at once.
- Derived projects must rotate the Cloudflare API token (Pages: Edit →
  Workers Scripts: Edit) and rename a GitHub variable before they can
  resume deploying.
- Caller workflows (`deploy-web-production.yml`, `deploy-web-staging.yml`,
  `deploy-web-preview.yml`) need their `provider:` value and (for the PR
  preview) input renamed.
- The existing Cloudflare Pages project keeps serving until you cut DNS
  over to the new Worker, so it is safe to run both side-by-side during
  the cutover.

## Files Added

```
wrangler.toml                                                      # Workers static-assets config (repo root)
docs/template/migrations/009-cloudflare-workers-migration.md       # This file
```

## Files Modified

```
.github/workflows/deploy-web.yml                                   # Provider rename, preview input, wrangler deploy/versions upload
docs/template/DEPLOYMENT.md                                        # Web chapter rewritten for Workers
docs/template/proposals/001-ephemeral-preview-environments.md      # Layer 1/2 wording, research findings
docs/template/migrations/008-reusable-web-deployment-workflow.md   # Added "superseded by 009" banner
```

## Breaking Changes

Yes -- four renames that derived projects must apply together:

1. **Workflow provider value:** `cloudflare-pages` → `cloudflare-workers`.
   Both the `workflow_dispatch` choice list and any caller workflow that
   passes `provider:` need updating.
2. **Workflow input:** `cloudflare_branch` (string) → `preview` (boolean).
   - `preview: false` (or omitted) → `wrangler deploy` (rolls production).
   - `preview: true` → `wrangler versions upload` (returns a unique
     versioned preview URL without affecting production).
3. **GitHub variable rename:** `CLOUDFLARE_PROJECT_NAME` →
   `CLOUDFLARE_WORKER_NAME`. The value is the Worker name (e.g.
   `my-app-staging`); Workers are created on first deploy, so no manual
   project setup is required.
4. **Cloudflare API token permission:** the existing token's
   *Cloudflare Pages: Edit* permission no longer suffices. Re-issue with
   **Account → Workers Scripts: Edit** and **Account → Account Settings:
   Read**, then update the `CLOUDFLARE_API_TOKEN` secret.

`CLOUDFLARE_ACCOUNT_ID` is unchanged.

## Migration Steps

1. **Fetch and merge the template update:**
   ```bash
   git fetch template
   git merge template/main
   ```

2. **Re-issue the Cloudflare API token** with the new permissions:
   - Go to https://dash.cloudflare.com/profile/api-tokens
   - **Create Token → Custom token**
   - Permissions:
     - Account → **Workers Scripts: Edit**
     - Account → **Account Settings: Read**
   - Account Resources: select the account that owns the deploy
   - Copy the token and update the `CLOUDFLARE_API_TOKEN` GitHub secret
     (repository or environment-scoped, matching your existing setup).

3. **Rename the GitHub variable** in **Settings → Secrets and variables →
   Actions → Variables**:
   - Add `CLOUDFLARE_WORKER_NAME` with the same value previously stored in
     `CLOUDFLARE_PROJECT_NAME` (e.g. `my-app-staging`,
     `my-app-production`). If you set the variable per GitHub environment
     for staging/production isolation, do the rename in each environment.
   - Delete the old `CLOUDFLARE_PROJECT_NAME` variable once the rename is
     in place.

   > **Note (added by migration 013):** when this migration originally
   > shipped, the per-environment scoping recommended above was actually
   > broken — the `web:` job in `deploy-web.yml` had no `environment:`
   > binding, so `${{ vars.CLOUDFLARE_WORKER_NAME }}` silently expanded to
   > empty string and `wrangler deploy --name=` failed.
   > [Migration 013](013-per-env-config-secret.md) fixes this by binding
   > the deploy jobs to `environment: ${{ inputs.environment }}` and
   > consolidates the env-suffixed `CONFIG_*` secrets into a single
   > per-environment `CONFIG_FILE`. If you are applying both migrations
   > together, follow migration 013's steps to set up
   > `CLOUDFLARE_WORKER_NAME` and `CONFIG_FILE` inside the `staging` and
   > `production` GitHub Environments at the same time.

4. **Update any caller workflows.** If you copy-pasted the example
   workflows from the [Calling deploy-web.yml from another workflow](../DEPLOYMENT.md#calling-deploy-webyml-from-another-workflow)
   section, you'll have one or more of:

   - `.github/workflows/deploy-web-production.yml`
   - `.github/workflows/deploy-web-staging.yml`
   - `.github/workflows/deploy-web-preview.yml`

   In each, change `provider: cloudflare-pages` →
   `provider: cloudflare-workers`. In the staging caller, drop the
   `cloudflare_branch: staging` line. In the PR preview caller, replace
   `cloudflare_branch: pr-${{ github.event.pull_request.number }}` with
   `preview: true`. The current versions of these examples in
   DEPLOYMENT.md are already updated -- copy them again if it's easier.

5. **First deploy creates the Worker.** No manual project setup needed --
   `wrangler deploy --name $CLOUDFLARE_WORKER_NAME` creates the Worker on
   the first run. The previous Cloudflare Pages project keeps serving its
   last deployment until you point DNS at the new Worker, so you can run
   both side-by-side during the cutover.

6. **Migrate any custom domains.** Configure the domain on the new Worker
   under **Workers & Pages → your worker → Settings → Domains & Routes**
   in the Cloudflare dashboard. Once the Worker route is live, you can
   delete the old Pages project.

7. **Delete `web/_redirects`** if you previously created one for SPA
   routing. Workers static assets handle SPA fallback via
   `not_found_handling = "single-page-application"` in the new
   `wrangler.toml`, so the file is no longer consulted on Cloudflare. (If
   you also deploy to Netlify or another `_redirects`-aware host, leave it
   in place.)

## Expected Conflicts

| File | Resolution |
|---|---|
| `.github/workflows/deploy-web.yml` | If you customized the deploy step or added other providers, accept the template's deploy step rewrite and re-apply your customizations. |
| `docs/template/DEPLOYMENT.md` | Accept the template's Web chapter rewrite; re-apply any project-specific notes you added under the Web section. |
| `wrangler.toml` (new file) | If you already have a wrangler config, merge the `[assets]` block and `not_found_handling = "single-page-application"` line into yours. |

## Can Skip?

**No** if you currently use the template's Cloudflare Pages deploy. The
old workflow keeps working for now (Pages is not yet shut off), but new
template updates assume the Workers shape, and `wrangler pages deploy` is
on Cloudflare's deprecation track.

**Yes** if you do not deploy via this workflow at all (e.g. you deploy web
manually, use a different provider, or do not ship a web build). The
`wrangler.toml` and workflow changes are inert without
`CLOUDFLARE_WORKER_NAME` set.
