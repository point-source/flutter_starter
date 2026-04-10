# Migration: 008 -- Reusable web deployment workflow

> **Partially superseded by migration 009.** The `cloudflare_branch` input
> introduced here was renamed to `preview` (boolean) when the workflow
> migrated from Cloudflare Pages to Cloudflare Workers static assets. See
> [009-cloudflare-workers-migration.md](009-cloudflare-workers-migration.md)
> for the rename details. Everything else in this note (the
> `workflow_call` shape, `ref` input, `deployment_url` output) is still
> current.

## Summary

Makes the `deploy-web.yml` workflow reusable via `workflow_call` so other
workflows can call it as a building block for automated deployments (push to
production, push to staging, PR previews). Adds two new optional inputs (`ref`,
`cloudflare_branch`) and a `deployment_url` output. Manual dispatch continues
to work as before with two new optional fields.

## Risk Level

**Low**

- Modified one workflow file only, no changes to application code or
  dependencies.
- Existing manual deployments are unaffected -- the new inputs have sensible
  defaults and the original behavior is preserved when they are omitted.

## Files Added

```
docs/migrations/008-reusable-web-deployment-workflow.md   # This file
```

## Files Modified

```
.github/workflows/deploy-web.yml    # Added workflow_call trigger, new inputs/outputs
docs/WEB_DEPLOYMENT.md              # Added automated deployment docs and examples
docs/proposals/001-ephemeral-preview-environments.md   # Updated Layer 1/2 status
docs/ROADMAP.md                     # Updated status
```

## Breaking Changes

_None._

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```
2. If you have automated deployment workflows that call `deploy-web.yml`, no
   changes are needed -- the new inputs are optional with backward-compatible
   defaults.
3. If you want to set up automated deployments (push-to-deploy, PR previews),
   see the new [Automated Deployments](../WEB_DEPLOYMENT.md#automated-deployments)
   section in the web deployment guide for copy-paste workflow files.

## Expected Conflicts

| File | Resolution |
|---|---|
| `.github/workflows/deploy-web.yml` | If you customized the workflow, accept the template's trigger block changes and re-apply your customizations to the steps |
| `docs/WEB_DEPLOYMENT.md` | Accept template additions (automated deployment section), keep your customizations |

## Can Skip?

**Yes** -- this adds optional reusable workflow support only. Manual deployment
continues to work without changes. No other changes depend on it.
