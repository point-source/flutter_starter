# Migration: 011 -- Config-from-secret, reusable mobile deploy, and consolidated DEPLOYMENT.md

## Summary

Three related changes to the deployment workflows and their documentation:

1. **Whole-file app config from a single secret per environment.** All three
   workflows (`ci.yml`, `deploy.yml`, `deploy-web.yml`) now read the full JSON
   body of `config/<env>.json` from a `CONFIG_<ENV>` secret and write it to
   disk before the build. This replaces the previous per-key `jq` overrides
   that only handled `API_URL`. Real API URLs, Sentry DSNs, and any other
   sensitive runtime config can now stay out of the repository entirely.
2. **`deploy.yml` is now reusable.** It supports `workflow_call` in addition
   to `workflow_dispatch`, mirroring the structure `deploy-web.yml` already
   had. Derived projects can wire mobile deploys into custom automation (tag
   pushes, scheduled releases, post-merge actions) without forking the
   workflow file.
3. **`docs/template/FASTLANE.md` and `docs/template/WEB_DEPLOYMENT.md` have
   been replaced by a single consolidated `docs/template/DEPLOYMENT.md`.** The
   new file covers iOS, Android, and Web in one place, with a shared "App
   Configuration Secrets" section at the top so the `CONFIG_<ENV>` model is
   explained once and referenced from all three platforms. The old
   `FASTLANE.md` name was misleading anyway — Fastlane is the implementation,
   the topic is mobile deployment.

## Risk Level

**Medium-low.**

- The `workflow_call` addition to `deploy.yml` is purely additive — manual
  dispatch behaviour and the existing dropdowns are unchanged.
- The move from `vars.API_URL` (deploy workflows) and `secrets.API_URL`
  (`ci.yml`) to `CONFIG_<ENV>` is a **breaking config change** for any
  derived project that already wired up either of those. Builds will keep
  succeeding because the workflows fall back to the committed
  `config/examples/<env>.json` defaults when the new secrets are absent —
  but the resulting build will use placeholder values until you set the
  new secrets.
- The doc rename breaks any inbound links that pointed at `FASTLANE.md` or
  `WEB_DEPLOYMENT.md`. The template's own inbound links (Fastlane comments,
  preflight script, ROADMAP, proposal, CLAUDE.md doc index) have all been
  updated to point at `DEPLOYMENT.md`. Derived projects with their own
  inbound links to either old file will need to do the same one-line update.

## Files Modified

```
.github/workflows/deploy.yml         # workflow_call + new override step
.github/workflows/deploy-web.yml     # new override step + new secrets declared
.github/workflows/ci.yml             # build job override step only
docs/template/CLAUDE.md              # doc index entry repointed to DEPLOYMENT.md
docs/template/ROADMAP.md             # link repointed to DEPLOYMENT.md
docs/template/proposals/001-ephemeral-preview-environments.md  # link repointed
ios/fastlane/.env.default            # comment repointed to DEPLOYMENT.md
ios/fastlane/Fastfile                # error message repointed to DEPLOYMENT.md
android/fastlane/.env.default        # comment repointed to DEPLOYMENT.md
android/fastlane/Fastfile            # error message repointed to DEPLOYMENT.md
scripts/preflight.sh                 # error message repointed to DEPLOYMENT.md
```

## Files Added

```
docs/template/DEPLOYMENT.md          # New consolidated deployment guide
docs/template/migrations/011-config-secret-and-reusable-mobile-deploy.md  # This file
```

## Files Removed

```
docs/template/FASTLANE.md            # Folded into DEPLOYMENT.md (mobile section)
docs/template/WEB_DEPLOYMENT.md      # Folded into DEPLOYMENT.md (web section)
```

## Breaking Changes

- **`vars.API_URL` is no longer read.** Both `deploy.yml` and `deploy-web.yml`
  used to override the `API_URL` field in `config/<env>.json` from a GitHub
  Actions variable. That step is gone. If you relied on it, the deployed app
  will fall back to whatever `API_URL` is committed in
  `config/examples/<env>.json` until you migrate to a `CONFIG_<ENV>` secret.
- **`secrets.API_URL` is no longer read by `ci.yml`.** The `build` job's
  ad-hoc `jq` override has been replaced by the same `CONFIG_<ENV>` pattern
  used by the deploy workflows. CI builds use `config/development.json`,
  which almost always means the committed `BACKEND=mock` defaults are fine
  and no secret is needed at all.
- **`docs/template/FASTLANE.md` and `docs/template/WEB_DEPLOYMENT.md` no
  longer exist.** All content lives in the new `docs/template/DEPLOYMENT.md`.
  Any inbound links in your project's docs, scripts, or onboarding material
  need a one-line update.

## Migration Steps

1. Fetch and merge the template update:
   ```bash
   git fetch template
   git merge template/main
   ```

2. **Create the new app-config secrets.** In your repository's
   **Settings → Secrets and variables → Actions**, create one secret per
   environment you actually deploy. The value of each secret is the full JSON
   body of the matching config file. For example, the value of
   `CONFIG_PRODUCTION` should look like:

   ```json
   {
     "ENVIRONMENT": "production",
     "API_URL": "https://api.yourcompany.com",
     "SENTRY_DSN": "https://abc123@sentry.io/456789",
     "BACKEND": "real"
   }
   ```

   | Secret | When you need it |
   |---|---|
   | `CONFIG_STAGING` | Deploying staging from `deploy.yml` or `deploy-web.yml` |
   | `CONFIG_PRODUCTION` | Deploying production from `deploy.yml` or `deploy-web.yml` |
   | `CONFIG_DEVELOPMENT` | Almost never — only if your CI build needs real backend values |

3. **Delete the old `vars.API_URL` variable** (or leave it; it is simply
   ignored now).

4. **If you had wired up `secrets.API_URL` for `ci.yml`,** delete it. The CI
   build now uses the committed `config/examples/development.json` defaults
   unless you create a `CONFIG_DEVELOPMENT` secret, which you almost never
   need to do.

5. **Update any inbound links to the deleted docs.** If your project's own
   docs, scripts, README, or onboarding material referenced
   `docs/template/FASTLANE.md` or `docs/template/WEB_DEPLOYMENT.md`, repoint
   them at `docs/template/DEPLOYMENT.md`. A quick grep:
   ```bash
   git grep -l 'FASTLANE\.md\|WEB_DEPLOYMENT\.md'
   ```

6. **If you had a customised local copy of either deleted file,** the merge
   will surface a delete/modify conflict. Resolve by:
   - Keeping `docs/template/DEPLOYMENT.md` from the template (it has all the
     stock content from both old files plus the new shared sections).
   - Re-applying any project-specific customisations from your old
     `FASTLANE.md` / `WEB_DEPLOYMENT.md` into the appropriate section of
     the new `DEPLOYMENT.md`.
   - Then deleting your local copies of the old files (`git rm`).

7. **Verify on a manual run.** Trigger `Deploy` (or `Deploy Web`) from the
   Actions tab, pick the environment you just configured, and confirm the
   build log shows:
   ```
   Wrote config/<env>.json from CONFIG_<ENV> secret
   ```
   If the log instead says
   ```
   No CONFIG_<ENV> secret set — using committed config/examples/<env>.json
   ```
   the secret is missing or named incorrectly.

8. **(Optional) Wire up automation via `workflow_call`.** With `deploy.yml`
   now reusable, you can create caller workflows that trigger mobile deploys
   on tag pushes, schedules, etc. See **Calling `deploy.yml` from another
   workflow** in `docs/template/DEPLOYMENT.md` for the canonical pattern.
   The same applies to `deploy-web.yml` — see **Calling `deploy-web.yml`
   from another workflow** in the same file.

## Expected Conflicts

| File | Resolution |
|---|---|
| `.github/workflows/deploy.yml` | If you customised the workflow, accept the template's `workflow_call` block and the new "Apply config from secret" steps, then re-apply your customisations to the surrounding steps |
| `.github/workflows/deploy-web.yml` | Accept the template's new override step and `secrets:` additions; keep your customisations |
| `.github/workflows/ci.yml` | Accept the template's new override step in the `build` job; keep your customisations to other jobs |
| `docs/template/FASTLANE.md` | **Delete** (the file is removed in this migration). Re-apply any local customisations into `docs/template/DEPLOYMENT.md` instead |
| `docs/template/WEB_DEPLOYMENT.md` | **Delete** (same as above). Re-apply local customisations into `docs/template/DEPLOYMENT.md` |
| `docs/template/CLAUDE.md` | Accept the template's repointed doc-index entry; keep your customisations |

## Can Skip?

**Not recommended.** The reusable-workflow part is purely additive and safe to
skip, but the config-from-secret refactor closes a real gap (no way to inject
secret values like `SENTRY_DSN` or a key-bearing `API_URL` without committing
them) and is a strict improvement. The doc consolidation is cosmetic but the
old file paths will return delete/modify conflicts on the next merge whether
you take this migration or not, so you may as well take them together.
