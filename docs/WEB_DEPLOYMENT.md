# Web Deployment Guide

This project includes a GitHub Actions workflow for deploying the Flutter web
build to a static hosting provider. The workflow is **optional** -- it has no
effect unless you configure the required secrets and variables for your chosen
provider.

Currently supported providers:

| Provider | Workflow value | Status |
|---|---|---|
| [Cloudflare Pages](https://pages.cloudflare.com/) | `cloudflare-pages` | Available |

Adding a new provider is straightforward -- see
[Adding a New Provider](#adding-a-new-provider) at the end of this guide.

## Common Setup

### Building Locally

The web build uses the same environment config as mobile builds:

```bash
# Development (mock backend)
flutter build web --release --dart-define-from-file=config/development.json

# Staging
flutter build web --release --dart-define-from-file=config/staging.json

# Production
flutter build web --release --dart-define-from-file=config/production.json
```

Output is written to `build/web/`.

### Local Preview

After building, preview the site locally:

```bash
# Python (built-in)
python3 -m http.server 8080 -d build/web

# Or use any static file server
npx serve build/web
```

### SPA Routing

Flutter web apps using **path-based URL strategy** (which `auto_route` supports)
need the server to rewrite all paths to `index.html`. Without this, refreshing
or deep-linking to a route like `/dashboard` returns a 404.

Flutter's **default hash-based strategy** (`/#/dashboard`) works without any
server configuration. If you switch to path-based URLs, create a `web/_redirects`
file so it is included in the build output:

```
/* /index.html 200
```

> **Note:** This `_redirects` format works on Cloudflare Pages and Netlify.
> Other providers may use different mechanisms (e.g., `vercel.json` rewrites,
> Firebase `firebase.json` rewrites). Check your provider's documentation.

### Base Href

By default, `flutter build web` sets the base href to `/`, which works when
serving from the root of a domain (e.g., `https://myapp.pages.dev/`). If you
need to serve from a subpath, pass `--base-href`:

```bash
flutter build web --release --base-href=/my-app/ --dart-define-from-file=config/production.json
```

## Running a Manual Deployment

1. Go to your repository's **Actions** tab on GitHub
2. Select the **Deploy Web** workflow in the sidebar
3. Click **Run workflow**
4. Choose your **hosting provider** and **target environment**
5. Optionally set **Git ref** to build from a specific branch, tag, or commit SHA
   (leave empty to use the branch selected in the dropdown above)
6. Optionally set **Cloudflare Pages branch name** to create a preview deployment
   (leave empty for a production deployment)
7. Click **Run workflow** to start

The workflow provisions the environment config from templates, applies any
secret overrides (e.g., `API_URL`), builds the Flutter web app, and deploys to
your chosen provider.

### Workflow Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `provider` | Yes | -- | Hosting provider (`cloudflare-pages`) |
| `environment` | Yes | -- | Config to build with (`staging` or `production`) |
| `ref` | No | current branch | Git ref to checkout (branch, tag, SHA) |
| `cloudflare_branch` | No | _(empty)_ | Cloudflare Pages branch name. Empty = production deploy. Any value = preview deploy at `<value>.<project>.pages.dev` |

### Workflow Outputs

| Output | Description |
|---|---|
| `deployment_url` | URL of the deployed site (from the Cloudflare wrangler action) |

---

## Automated Deployments

The Deploy Web workflow supports
[`workflow_call`](https://docs.github.com/en/actions/sharing-automations/reusing-workflows),
meaning other workflows can call it as a reusable building block. This enables
fully automated deployment pipelines without duplicating the build logic.

The sections below provide complete, copy-paste workflow files for three common
patterns. Create each file in `.github/workflows/` in your repository.

### Prerequisites

All automated workflows require the same Cloudflare secrets and variables
described in the [Cloudflare Pages](#cloudflare-pages) section below. Make sure
those are configured before enabling any of the workflows below.

### Deploy on Push to Production

Automatically deploys to Cloudflare Pages production when a commit lands on
`main` (e.g., via a merged PR).

Create `.github/workflows/deploy-web-production.yml`:

```yaml
name: Deploy Web (Production)

on:
  push:
    branches: [main]

jobs:
  deploy:
    uses: ./.github/workflows/deploy-web.yml
    with:
      provider: cloudflare-pages
      environment: production
    secrets:
      CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

`cloudflare_branch` is omitted (empty), so Cloudflare treats this as a
production deployment.

### Deploy on Push to Staging

Automatically deploys to a Cloudflare Pages preview URL when a commit lands on
`develop` or `staging`.

Create `.github/workflows/deploy-web-staging.yml`:

```yaml
name: Deploy Web (Staging)

on:
  push:
    branches: [develop, staging]

jobs:
  deploy:
    uses: ./.github/workflows/deploy-web.yml
    with:
      provider: cloudflare-pages
      environment: staging
      cloudflare_branch: staging
    secrets:
      CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

`cloudflare_branch: staging` causes the deployment to appear at
`staging.<project>.pages.dev` rather than the production URL.

### PR Preview Deployments

Automatically builds and deploys a preview for every pull request opened
against `main` or `staging`. Posts the preview URL as a PR comment and updates
it on each push. The preview is a Cloudflare Pages preview deployment at
`pr-<number>.<project>.pages.dev`.

Create `.github/workflows/deploy-web-preview.yml`:

```yaml
name: Deploy Web (PR Preview)

on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main, staging]

concurrency:
  group: deploy-web-preview-pr-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  deploy:
    uses: ./.github/workflows/deploy-web.yml
    with:
      provider: cloudflare-pages
      environment: staging
      ref: ${{ github.event.pull_request.head.sha }}
      cloudflare_branch: pr-${{ github.event.pull_request.number }}
    secrets:
      CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}

  comment:
    needs: deploy
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - name: Find existing comment
        uses: peter-evans/find-comment@v3
        id: find
        with:
          issue-number: ${{ github.event.pull_request.number }}
          comment-author: 'github-actions[bot]'
          body-includes: '<!-- deploy-web-preview -->'

      - name: Post or update preview URL
        uses: peter-evans/create-or-update-comment@v4
        with:
          issue-number: ${{ github.event.pull_request.number }}
          comment-id: ${{ steps.find.outputs.comment-id }}
          edit-mode: replace
          body: |
            <!-- deploy-web-preview -->
            ### Web Preview

            | | |
            |---|---|
            | **URL** | ${{ needs.deploy.outputs.deployment_url }} |
            | **Commit** | ${{ github.event.pull_request.head.sha }} |
            | **Environment** | staging |
```

**How it works:**

- `ref` checks out the PR's head commit (not the merge commit)
- `cloudflare_branch: pr-<number>` creates a unique preview URL per PR
- The `comment` job reads `deployment_url` from the reusable workflow's output
- `peter-evans/find-comment` + `create-or-update-comment` keep a single,
  updated comment (no spam on force-pushes)
- The `concurrency` group cancels in-progress builds when new commits are
  pushed to the PR, so only the latest commit is deployed

**Cloudflare preview cleanup:** Cloudflare Pages preview deployments persist
but cost nothing (they are static assets on the free tier). No explicit
teardown is required. If you want to actively delete previews on PR close, you
can add a separate job triggered by `pull_request: [closed]` that calls the
Cloudflare API.

### Combining Workflows

You can enable any combination of the above. They do not conflict:

- **Production + Staging** -- merge to `main` deploys to production; merge to
  `develop` deploys to staging
- **Production + PR Preview** -- PRs get a preview URL; merging to `main`
  deploys to production
- **All three** -- full pipeline: PR preview → merge to `develop` for staging →
  merge to `main` for production

The reusable workflow's concurrency group (`deploy-web-<environment>`) prevents
overlapping deploys to the same environment. The PR preview workflow uses its
own concurrency group (`deploy-web-preview-pr-<number>`) so previews and
production deploys never block each other.

---

## Cloudflare Pages

### Prerequisites

- A [Cloudflare account](https://dash.cloudflare.com/sign-up)
- A Cloudflare Pages project (created via the dashboard or CLI)

### 1. Create a Pages Project

In the Cloudflare dashboard:

1. Go to **Workers & Pages** > **Create**
2. Select the **Pages** tab, then **Upload assets** (direct upload)
3. Name your project (e.g., `my-app-staging`, `my-app-production`)
4. Upload a placeholder file to finish creation -- the GitHub Action will
   overwrite it on the first deploy

Or use the Wrangler CLI:

```bash
npx wrangler pages project create my-app-staging
```

> **Tip:** Create separate projects for staging and production if you want
> isolated environments. Use a single project if you prefer Cloudflare's
> built-in preview/production branch model.

### 2. Create an API Token

1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click **Create Token**
3. Use the **Custom token** template
4. Permissions: **Account** > **Cloudflare Pages** > **Edit**
5. Account Resources: select the account that owns the Pages project
6. Create the token and copy it

### 3. Configure GitHub Secrets and Variables

In your GitHub repository, go to **Settings** > **Secrets and variables** >
**Actions**.

**Secrets** (sensitive values):

| Secret | Description |
|---|---|
| `CLOUDFLARE_API_TOKEN` | API token with Cloudflare Pages: Edit permission |

**Variables** (non-sensitive values):

| Variable | Description | Example |
|---|---|---|
| `CLOUDFLARE_ACCOUNT_ID` | Your Cloudflare account ID (visible in dashboard URL) | `abc123def456` |
| `CLOUDFLARE_PROJECT_NAME` | The Pages project name to deploy to | `my-app-staging` |

> **Environment-specific projects:** If you use separate Cloudflare Pages
> projects for staging and production, you can configure these variables as
> [GitHub environment variables](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
> rather than repository variables. Create `staging` and `production`
> environments in GitHub and set `CLOUDFLARE_PROJECT_NAME` (and optionally
> `CLOUDFLARE_ACCOUNT_ID`) per environment.

### 4. Custom Domains

After your first deployment, configure a custom domain in the Cloudflare Pages
dashboard under your project's **Custom domains** tab. Cloudflare handles SSL
automatically.

---

## Adding a New Provider

To add support for a new hosting provider (e.g., Vercel, Netlify, Firebase
Hosting):

### 1. Update the Workflow

In `.github/workflows/deploy-web.yml`:

**Add the provider to both choice lists** (`workflow_dispatch` and
`workflow_call`):

```yaml
# In workflow_dispatch.inputs.provider.options:
options:
  - cloudflare-pages
  - your-new-provider    # ← add here

# In workflow_call.inputs.provider (string type -- document valid values)
```

**Add a conditional deployment step** after the existing provider blocks:

```yaml
# ── Your New Provider ─────────────────────────────────────────────
- name: Deploy to Your New Provider
  id: deploy-your-provider
  if: inputs.provider == 'your-new-provider'
  # ... provider-specific action or CLI command
  # The built web app is in build/web/
```

> **Note:** Use `inputs.provider` (not `github.event.inputs.provider`) so the
> condition works for both manual and reusable workflow invocations. If your
> provider's action exposes a deployment URL output, wire it through the job
> outputs so callers can use it.

### 2. Document the Required Secrets

Add a section to this file (above this one) documenting:

- Prerequisites (account, project setup)
- Required GitHub secrets and variables
- Any provider-specific configuration (e.g., rewrite rules for SPA routing)

### 3. Update the Provider Table

Add your provider to the table at the top of this file.
