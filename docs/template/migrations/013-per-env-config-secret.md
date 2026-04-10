# Migration: 013 -- Per-environment CONFIG_FILE secret + GitHub Environment binding

## Summary

Two related changes that together fix a latent bug and consolidate the
template's per-environment configuration story:

1. **Bind deploy jobs to GitHub Environments.** The `web:` job in
   `.github/workflows/deploy-web.yml` and the `ios:` / `android:` jobs in
   `.github/workflows/deploy.yml` now declare
   `environment: ${{ inputs.environment }}` so that environment-scoped
   secrets and variables actually resolve. Previously they did not, which
   meant `${{ vars.CLOUDFLARE_WORKER_NAME }}` silently expanded to empty
   string when set per GitHub Environment (as migration 009 and the old
   `DEPLOYMENT.md` recommended), and `wrangler deploy --name=` failed with
   `You need to provide a name when publishing a worker`.
2. **Consolidate `CONFIG_*` secrets into a single `CONFIG_FILE`.** The
   env-suffixed `CONFIG_STAGING`, `CONFIG_PRODUCTION`, and unused
   `CONFIG_DEVELOPMENT` secrets are replaced by a single `CONFIG_FILE`
   secret placed inside each GitHub Environment. The workflows drop the
   shell indirection (`var=CONFIG_$(uppercase ENV_NAME)`) and read
   `CONFIG_FILE` directly, with the GitHub Environment binding picking the
   right value.

After this migration, the per-environment story is uniform: `CONFIG_FILE`,
`CLOUDFLARE_WORKER_NAME`, and any other per-env value all live inside the
matching `staging` / `production` GitHub Environment, and the workflows
consume them through `environment:` binding rather than secret-name
indirection.

## Risk Level

**High.**

- Breaking change: secret names rename and the workflows no longer read
  `CONFIG_STAGING` / `CONFIG_PRODUCTION` / `CONFIG_DEVELOPMENT` at all.
  Derived projects must move the existing values into per-environment
  `CONFIG_FILE` secrets before the next deploy.
- GitHub Environments named `staging` and `production` become a hard
  requirement. GitHub auto-creates them on first reference, so the
  workflow does not fail at parse time, but secrets must be placed inside
  them manually (auto-creation produces empty environments).
- Caller workflows that explicitly forward `CONFIG_STAGING` /
  `CONFIG_PRODUCTION` via the `secrets:` block must drop those entries —
  the env binding now handles `CONFIG_FILE` directly.
- The `ci.yml` workflow is **not** changed by this migration. It still
  uses `CONFIG_DEVELOPMENT` at the repository level for its hardcoded
  development smoke build (no environment multiplexing). If you do not
  use that secret today, no action is needed for `ci.yml`.

## Files Modified

```
.github/workflows/deploy-web.yml                                       # environment: binding, CONFIG_FILE, simplified apply step
.github/workflows/deploy.yml                                           # environment: binding on ios/android, CONFIG_FILE, simplified apply steps
docs/template/DEPLOYMENT.md                                            # Rewrote App Configuration Secrets section, updated tables and caller examples
docs/template/migrations/009-cloudflare-workers-migration.md           # Forward-reference note in step 3
docs/template/migrations/011-config-secret-and-reusable-mobile-deploy.md  # Added "partially superseded by 013" banner
```

## Files Added

```
docs/template/migrations/013-per-env-config-secret.md              # This file
```

## Breaking Changes

1. **Secret rename:** `CONFIG_STAGING`, `CONFIG_PRODUCTION`, and
   `CONFIG_DEVELOPMENT` are removed from `deploy-web.yml` and `deploy.yml`.
   Replaced by a single `CONFIG_FILE` secret per GitHub Environment.
2. **GitHub Environment requirement:** the `web:`, `ios:`, and `android:`
   jobs now bind to `environment: ${{ inputs.environment }}`. The
   environments named `staging` and `production` must exist and (for any
   non-default config) must contain a `CONFIG_FILE` secret.
3. **Caller workflows:** any caller workflow forwarding `CONFIG_STAGING` /
   `CONFIG_PRODUCTION` via `secrets:` must drop those entries. The env
   binding on the called job resolves `CONFIG_FILE` from the matching
   environment automatically.

## Migration Steps

1. **Fetch and merge the template update:**
   ```bash
   git fetch template
   git merge template/main
   ```

2. **Create or confirm GitHub Environments.** In your repository, go to
   **Settings → Environments** and ensure both `staging` and `production`
   exist. Create them if they don't.

3. **Move existing CONFIG values into the matching environments.** For
   each environment:
   - Open the environment settings.
   - Add a new **environment secret** named `CONFIG_FILE`.
   - Set its value to the full JSON body that was previously stored in
     the repository-level `CONFIG_STAGING` (for `staging`) or
     `CONFIG_PRODUCTION` (for `production`).

4. **Move per-environment variables into the same environments.** If you
   were using `CLOUDFLARE_WORKER_NAME` (or any other per-env variable) at
   the repository level — or had created the GitHub Environments but the
   variables were silently broken — make sure each environment has its
   own value (e.g. `my-app-staging` in `staging`, `my-app-production` in
   `production`).

5. **Delete the old repository-level secrets.** From **Settings → Secrets
   and variables → Actions → Secrets**, delete:
   - `CONFIG_STAGING`
   - `CONFIG_PRODUCTION`
   - `CONFIG_DEVELOPMENT` (if it existed)

   These are no longer read by `deploy-web.yml` or `deploy.yml`. (If
   `ci.yml` was using `CONFIG_DEVELOPMENT`, leave that one alone — it
   stays at the repository level.)

6. **Update caller workflows.** If you copy-pasted the example reusable
   workflows from
   [Calling deploy-web.yml from another workflow](../DEPLOYMENT.md#calling-deploy-webyml-from-another-workflow)
   or [Calling deploy.yml from another workflow](../DEPLOYMENT.md#calling-deployyml-from-another-workflow),
   open the resulting `.github/workflows/deploy-web-*.yml` and
   `.github/workflows/deploy-*.yml` files and remove any `CONFIG_STAGING`,
   `CONFIG_PRODUCTION`, or `CONFIG_DEVELOPMENT` lines from the `secrets:`
   blocks. The current versions of the examples in `DEPLOYMENT.md` are
   already updated — you can copy them again if it's easier.

7. **First deploy after the migration.** Trigger `Deploy Web` (or
   `Deploy`) via `workflow_dispatch` against `staging` and confirm:
   - The **Apply config from secret** step logs
     `Wrote config/staging.json from CONFIG_FILE secret in the staging environment`.
   - For web deploys, the wrangler step shows
     `wrangler deploy --name=<staging-worker-name>` (not `--name=`).

## Expected Conflicts

| File | Resolution |
|---|---|
| `.github/workflows/deploy-web.yml` | Accept the template's `environment:` binding, `CONFIG_FILE` secret declaration, and rewritten Apply step. Re-apply any project-specific customizations (extra providers, custom build flags). |
| `.github/workflows/deploy.yml` | Same as above for the `ios:` and `android:` jobs. The `validate:` job is unchanged. |
| `docs/template/DEPLOYMENT.md` | Accept the rewritten App Configuration Secrets section and the updated caller workflow examples. Re-apply any project-specific notes. |

## Can Skip?

**No.** The template's `deploy-web.yml` and `deploy.yml` no longer read
`CONFIG_STAGING` / `CONFIG_PRODUCTION` after this migration, and the
Cloudflare Workers deploy is broken at HEAD without
[migration 009's](009-cloudflare-workers-migration.md) per-environment
`CLOUDFLARE_WORKER_NAME` setup actually working — which only this
migration enables.
