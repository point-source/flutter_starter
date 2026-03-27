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

## Running a Deployment

1. Go to your repository's **Actions** tab on GitHub
2. Select the **Deploy Web** workflow in the sidebar
3. Click **Run workflow**
4. Choose your **hosting provider** and **target environment**
5. Click **Run workflow** to start

The workflow provisions the environment config from templates, applies any
secret overrides (e.g., `API_URL`), builds the Flutter web app, and deploys to
your chosen provider.

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

**Add the provider to the choice list:**

```yaml
inputs:
  provider:
    description: 'Hosting provider'
    required: true
    type: choice
    options:
      - cloudflare-pages
      - your-new-provider    # ← add here
```

**Add a conditional deployment step** after the existing provider blocks:

```yaml
# ── Your New Provider ─────────────────────────────────────────────
- name: Deploy to Your New Provider
  if: github.event.inputs.provider == 'your-new-provider'
  # ... provider-specific action or CLI command
  # The built web app is in build/web/
```

### 2. Document the Required Secrets

Add a section to this file (above this one) documenting:

- Prerequisites (account, project setup)
- Required GitHub secrets and variables
- Any provider-specific configuration (e.g., rewrite rules for SPA routing)

### 3. Update the Provider Table

Add your provider to the table at the top of this file.
