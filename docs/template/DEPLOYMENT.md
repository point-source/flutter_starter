# Deployment Guide

This guide covers deploying the app to all three platforms supported by the
template:

| Platform | Workflow file | Tooling |
|---|---|---|
| iOS (TestFlight / App Store) | `.github/workflows/deploy.yml` | [Fastlane](https://fastlane.tools/) |
| Android (Google Play) | `.github/workflows/deploy.yml` | [Fastlane](https://fastlane.tools/) |
| Web (Cloudflare Pages, Netlify, etc.) | `.github/workflows/deploy-web.yml` | Provider-specific (Wrangler for Cloudflare) |

All three workflows are **manually triggered** by default (`workflow_dispatch`)
and **reusable** via `workflow_call`, so derived projects can wire automation
on top without forking the workflows themselves.

**Contents**

- [Terminology](#terminology)
- [Overview](#overview)
- [App Configuration Secrets (shared)](#app-configuration-secrets-shared)
- [iOS and Android (mobile)](#ios-and-android-mobile)
- [Web](#web)
- [Adding a new web hosting provider](#adding-a-new-web-hosting-provider)

---

## Terminology

Several terms in this guide look interchangeable but live on **three
orthogonal dimensions** — environment, lane, and branch. Mixing them up is the
most common source of "wait, did that just ship to production?" confusion.

### Environments

The **environment** is the config bundle baked into a Flutter build via
`--dart-define-from-file=config/<env>.json`. It controls *which API URL,
Sentry DSN, backend mode, and feature flags* the running app sees.

| Value | File | Typical use |
|---|---|---|
| `development` | `config/development.json` | Local `flutter run`, CI smoke builds. Rarely deployed. |
| `staging` | `config/staging.json` | Pre-release builds against the staging backend. |
| `production` | `config/production.json` | Builds against the live production backend. |

The canonical source is the `AppEnvironment` enum in
`lib/core/env/app_environment.dart`. Matching CI secrets are
`CONFIG_DEVELOPMENT` / `CONFIG_STAGING` / `CONFIG_PRODUCTION` — see
[App Configuration Secrets](#app-configuration-secrets-shared).

### Lanes

The **lane** is the [Fastlane](https://fastlane.tools/) lane that runs the
build, i.e. *which distribution target the binary is published to*. Lanes
only exist for mobile — the web workflow has no lane concept.

| Value | iOS destination | Android destination |
|---|---|---|
| `store_beta` | TestFlight | Google Play internal testing |
| `store_production` | App Store production | Google Play production |
| `github` | *(not supported)* | Signed APK attached to a GitHub Release |

Lane and environment are **independent**. The `store_beta` lane accepts
`environment:staging` (the default) or `environment:production`, so you can
ship either config to TestFlight / Play internal — useful for a final
pre-store smoke test against the production backend. The `store_production`
lane only accepts `environment:production`; both `deploy.yml` and the
Fastfile reject any other combination. The `github` lane is Android-only
(iOS has no direct-distribution analog) and accepts both environments;
staging builds are marked as **prereleases** on the GitHub Release, while
production builds become stable releases. See
[Direct APK distribution via GitHub Releases](#direct-apk-distribution-via-github-releases)
below.

| Lane | Environment | Meaning |
|---|---|---|
| `store_beta` | `staging` | **Default beta build.** Staging-config build → TestFlight / Play internal for QA. |
| `store_beta` | `production` | **Pre-store smoke test.** Production-config build → TestFlight / Play internal for final verification. |
| `store_production` | `production` | **Public release.** Production-config build → App Store / Play production. |
| `store_production` | `staging` | **Rejected.** `store_production` always uploads to the production store track; this combination would silently mislabel a staging build as a real release. |
| `github` | `staging` | **Internal APK drop.** Staging-config signed APK → GitHub Release marked as prerelease. Android only. |
| `github` | `production` | **Public APK release.** Production-config signed APK → stable GitHub Release. Android only. |

### Branches

The **branch** is your git workflow convention — *which long-lived branch
triggers which deploy*. The template **does not enforce** any branch model:
both `deploy.yml` and `deploy-web.yml` are `workflow_dispatch` (manual) by
default.

The recommended convention this template's example reusable-workflow snippets
assume is:

| Branch | Deploys to |
|---|---|
| `develop` | `staging` |
| `main` | `production` |
| Pull requests against `main` | Cloudflare Pages preview at `pr-<number>.<project>.pages.dev` |

To wire this up, copy the example workflows from
[Calling `deploy.yml` from another workflow](#calling-deployyml-from-another-workflow)
and [Calling `deploy-web.yml` from another workflow](#calling-deploy-webyml-from-another-workflow)
into your derived project's `.github/workflows/`. They are already keyed to
`develop` / `main` — adjust if your team uses different branch names.

---

## Overview

There are two distinct buckets of secrets that feed every deploy:

- **App configuration** — values baked into the Flutter build via
  `--dart-define-from-file` (API URL, Sentry DSN, backend mode, feature flags).
  These live in a single `CONFIG_<ENV>` secret per environment containing the
  full JSON body of the matching `config/<env>.json` file. See
  [App Configuration Secrets](#app-configuration-secrets-shared) below.
- **Workflow tooling** — credentials the workflow itself uses to do its job
  (signing keys, store API tokens, hosting provider tokens, future things like
  a Supabase project ref for edge function deploys). These stay as individual
  secrets because they are consumed by the workflow steps, not by the running
  app. They are documented in each platform's section below.

The "manually triggered + reusable" model means a fresh fork of this template
needs to set **zero** GitHub secrets to do a dry run — the workflows fall back
to the committed `config/examples/<env>.json` defaults and emit a log line
explaining that no secret was provided. Real deploys obviously need both kinds
of secrets configured.

---

## App Configuration Secrets (shared)

The deploy workflows inject environment-specific app config from a single
secret per environment containing the **full JSON body** of the matching
`config/<env>.json` file. This keeps real API URLs, Sentry DSNs, and any other
sensitive runtime config out of the repository entirely.

| Secret | Description | Required |
|---|---|---|
| `CONFIG_STAGING` | Full JSON body of `config/staging.json` | When deploying staging |
| `CONFIG_PRODUCTION` | Full JSON body of `config/production.json` | When deploying production |
| `CONFIG_DEVELOPMENT` | Full JSON body of `config/development.json` | Only if your CI build needs real values; usually unset |

Set each secret to the literal contents of the corresponding config file, e.g.
the value of `CONFIG_PRODUCTION` is something like:

```json
{
  "ENVIRONMENT": "production",
  "API_URL": "https://api.yourcompany.com",
  "SENTRY_DSN": "https://abc123@sentry.io/456789",
  "BACKEND": "real"
}
```

If a secret is unset for the target environment, the workflow falls back to
the committed `config/examples/<env>.json` (placeholder values) and prints a
log line. Manual deploys from a fresh fork therefore work end-to-end without
configuring anything — but the resulting build will use placeholder URLs and
DSNs.

### How config values reach the build

The flow on every workflow run is:

1. `./scripts/setup.sh` copies `config/examples/<env>.json` →
   `config/<env>.json` (committed defaults).
2. The **Apply config from secret** step looks up `CONFIG_<ENV>` for the
   target environment, validates it as JSON, and overwrites
   `config/<env>.json` with its contents. If the secret is unset the step
   leaves the committed defaults in place and prints a log line.
3. `flutter build ... --dart-define-from-file=config/<env>.json` consumes the
   resulting file.

Adding a new app config field is therefore a one-place change: edit the JSON
in your `CONFIG_<ENV>` secret. No workflow edit required.

---

## iOS and Android (mobile)

iOS and Android share a single workflow (`.github/workflows/deploy.yml`) and a
common tool ([Fastlane](https://fastlane.tools/)). Fastlane is configured
**per-platform** following the
[official Flutter CD guide](https://docs.flutter.dev/deployment/cd#fastlane):

- `ios/fastlane/` — iOS lanes (TestFlight, App Store)
- `android/fastlane/` — Android lanes (Play Store)

### Prerequisites

- **Ruby** 3.4+ (see `ios/.ruby-version` and `android/.ruby-version`)
- **Bundler** (`gem install bundler`)
- **Xcode** (latest stable, with command-line tools) — iOS only
- **Android SDK** with Java 17 — Android only
- **Flutter** (stable channel)

Install Fastlane and dependencies for each platform:

```bash
cd ios && bundle install
cd android && bundle install
```

### Preflight check

Before configuring anything, run the preflight check to see what still needs
to be set up:

```bash
# Check both platforms
./scripts/preflight.sh

# Check one platform
./scripts/preflight.sh ios
./scripts/preflight.sh android
```

The preflight script does not require Ruby or Fastlane — it runs as a plain
shell script. Each platform also has a `preflight` Fastlane lane:

```bash
cd ios && bundle exec fastlane preflight
cd android && bundle exec fastlane preflight
```

### First-time setup

#### 1. Update app identifiers

**iOS** — edit `ios/fastlane/.env.default`:

```env
APP_IDENTIFIER=com.yourcompany.yourapp
APPLE_ID=your-apple-id@example.com
TEAM_ID=YOUR_TEAM_ID
ITC_TEAM_ID=YOUR_ITC_TEAM_ID
```

**Android** — edit `android/fastlane/.env.default`:

```env
PACKAGE_NAME=com.yourcompany.yourapp
```

Also update the matching identifiers in:

- `android/app/build.gradle.kts` — `applicationId`
- `ios/Runner.xcodeproj` — Bundle Identifier (via Xcode)

#### 2. iOS code signing (match)

[match](https://docs.fastlane.tools/actions/match/) stores your certificates
and provisioning profiles in a private git repository, making it easy to share
across the team and CI.

**Create a certificates repository:**

```bash
# Create a new private repo on GitHub (e.g., your-org/certificates)
# Then initialize match:
cd ios
bundle exec fastlane match init
```

**Generate certificates and profiles:**

```bash
cd ios

# Development (for local builds)
bundle exec fastlane match development

# App Store (for TestFlight and production)
bundle exec fastlane match appstore
```

Update `ios/fastlane/.env.default` with your match repo URL:

```env
MATCH_GIT_URL=git@github.com:your-org/certificates.git
```

#### 3. App Store Connect API key

For CI deployments, use an App Store Connect API key instead of Apple ID
credentials.

1. Go to [App Store Connect → Users and Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api)
2. Create a new key with **App Manager** role
3. Download the `.p8` file and note the **Key ID** and **Issuer ID**
4. Store these as GitHub repository secrets (see [Required GitHub secrets](#required-github-secrets-mobile))

#### 4. Android upload keystore

Create a keystore for signing release builds:

```bash
mkdir -p android/keystore

keytool -genkey -v \
  -keystore android/keystore/upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Copy and fill in the signing config:

```bash
cp android/key.properties.example android/key.properties
# Edit android/key.properties with your keystore password and alias
```

> **Important:** Back up your keystore securely. If you lose it, you cannot
> update your app on Google Play.

#### 5. Google Play service account

1. Go to [Google Play Console → Setup → API access](https://play.google.com/console/developers/api-access)
2. Create or link a Google Cloud project
3. Create a service account with **Release Manager** role
4. Download the JSON key file
5. Save it as `android/fastlane/google-play-key.json` (gitignored)

> **Note:** You must upload your first AAB manually via the Play Console
> before Fastlane can upload subsequent builds.

### Local usage

#### iOS

```bash
cd ios

# Sync code signing certificates
bundle exec fastlane certificates

# Build and upload to TestFlight (staging)
bundle exec fastlane store_beta

# Build and upload to TestFlight (production)
bundle exec fastlane store_beta environment:production

# Build and upload to App Store (always builds the production environment)
bundle exec fastlane store_production
```

#### Android

```bash
cd android

# Build and upload to Play Store internal testing (staging)
bundle exec fastlane store_beta

# Build and upload to Play Store internal testing (production)
bundle exec fastlane store_beta environment:production

# Build and upload to Play Store production (always builds the production environment)
bundle exec fastlane store_production

# Build a signed APK locally for direct distribution (no upload — see
# Direct APK distribution via GitHub Releases below for the CI flow)
bundle exec fastlane github environment:production
```

#### Lane options

| Parameter | Description | Example |
|---|---|---|
| `environment` | Config environment to build with. `store_beta` and `github` accept `staging` (default for `store_beta`) or `production`; `store_production` only accepts `production` (and errors out otherwise). See [Terminology → Lanes](#lanes) for the full matrix. | `environment:production` |
| `build_number` | Override build number | `build_number:42` |

### Required GitHub secrets (mobile)

In addition to the shared
[App Configuration Secrets](#app-configuration-secrets-shared) above, the
mobile deploy workflow needs these tooling secrets.

#### iOS secrets

| Secret | Description |
|---|---|
| `MATCH_PASSWORD` | Encryption password for your match certificates repo |
| `MATCH_GIT_PRIVATE_KEY` | SSH private key with access to the certificates repo |
| `MATCH_GIT_URL` | Git URL of the certificates repo |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect API issuer ID |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect API private key (`.p8` contents) |

#### Android secrets

| Secret | Description |
|---|---|
| `ANDROID_KEYSTORE` | Base64-encoded upload keystore (`base64 -i android/keystore/upload.jks`) |
| `ANDROID_KEY_PROPERTIES` | Contents of `android/key.properties` |
| `GOOGLE_PLAY_JSON_KEY` | Contents of the Google Play service account JSON key |

#### GitHub Variables

(Settings → Secrets and variables → Variables)

| Variable | Description |
|---|---|
| `APP_IDENTIFIER` | iOS bundle identifier |
| `APPLE_ID` | Apple ID email |
| `TEAM_ID` | Apple Developer Team ID |
| `ITC_TEAM_ID` | App Store Connect Team ID |
| `PACKAGE_NAME` | Android package name |

### Running a manual mobile deployment

1. Go to **Actions → Deploy** in your GitHub repository
2. Click **Run workflow**
3. Select **platform** (`ios` / `android` / `both`), **environment**, and
   **lane**
4. Click **Run workflow**

The build number is automatically set to the GitHub Actions run number. A
preflight check runs before every deploy to catch misconfiguration early.

### Calling `deploy.yml` from another workflow

`deploy.yml` supports
[`workflow_call`](https://docs.github.com/en/actions/sharing-automations/reusing-workflows),
so other workflows in the same repository can invoke it as a reusable
building block — for example, deploying production on a tag push:

```yaml
name: Mobile Deploy on Tag

on:
  push:
    tags: ['v*']

jobs:
  deploy:
    uses: ./.github/workflows/deploy.yml
    with:
      platform: both
      environment: production
      lane: store_production
    secrets: inherit
```

`secrets: inherit` is the simplest path inside the same repository — every
secret declared in `deploy.yml` (including `CONFIG_PRODUCTION` and the
platform credentials) is forwarded automatically. If you call `deploy.yml`
from a different repository, list each secret explicitly instead:

```yaml
    secrets:
      CONFIG_PRODUCTION: ${{ secrets.CONFIG_PRODUCTION }}
      MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
      MATCH_GIT_PRIVATE_KEY: ${{ secrets.MATCH_GIT_PRIVATE_KEY }}
      MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
      APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
      APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
      APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
      ANDROID_KEYSTORE: ${{ secrets.ANDROID_KEYSTORE }}
      ANDROID_KEY_PROPERTIES: ${{ secrets.ANDROID_KEY_PROPERTIES }}
      GOOGLE_PLAY_JSON_KEY: ${{ secrets.GOOGLE_PLAY_JSON_KEY }}
```

The same `concurrency` group applies to both manual and reusable invocations,
so you cannot accidentally start two deploys for the same platform/environment
at the same time.

### Direct APK distribution via GitHub Releases

The `github` lane builds a signed Android APK and publishes it as a
**GitHub Release** instead of uploading to the Play Store. Use it when you
need internal, enterprise, or sideload distribution — situations where the
Play Store is the wrong channel (or unavailable).

The `github` lane is **Android-only**. iOS has no direct-distribution
analog in this template; setting `platform=ios` or `platform=both` with
`lane=github` is rejected by the workflow's validate job.

Both `staging` and `production` environments are accepted. Staging builds
are marked as **prereleases** on the GitHub Release; production builds
become stable releases. The signing key is the same one used by
`store_production` (read from `android/key.properties`); no Google Play
service account JSON is required.

#### Required secrets

Only the Android signing secrets and the matching environment config
secret are needed:

| Secret | Required |
|---|---|
| `ANDROID_KEYSTORE` | yes |
| `ANDROID_KEY_PROPERTIES` | yes |
| `CONFIG_STAGING` *or* `CONFIG_PRODUCTION` | yes (matching the environment) |

`GOOGLE_PLAY_JSON_KEY` is **not** required for `lane=github` — the
workflow's "Write Google Play service account key" and "Preflight check"
steps are skipped automatically when `lane=github`, since they exist
solely for Play Store uploads.

#### Triggering manually

1. Go to **Actions → Deploy**
2. Click **Run workflow**
3. Set **platform** = `android`, **environment** = `staging` or
   `production`, **lane** = `github`
4. Optionally fill in **tag_name** to override the default
   (`build-<run_number>-<environment>`)
5. Click **Run workflow**

The Android job builds a signed APK via `bundle exec fastlane github` and
then runs `gh release create` to publish a GitHub Release pinned to the
exact commit SHA, with auto-generated release notes (`gh release create
--generate-notes`).

#### Wiring it into a caller workflow

Because `deploy.yml` already supports `workflow_call`, a derived project
can wire automatic GitHub Releases (e.g. on push to `main`) without any
build logic of its own:

```yaml
name: Release on push to main

on:
  push:
    branches: [main]

jobs:
  release:
    uses: ./.github/workflows/deploy.yml
    with:
      platform: android
      environment: production
      lane: github
      tag_name: v${{ github.run_number }}
    secrets: inherit
```

That caller workflow contains zero build logic — `deploy.yml` builds the
APK *and* publishes the Release in a single called job. The Android job
in `deploy.yml` declares `permissions: contents: write` at the job level,
so no extra `permissions:` block is needed in the caller.

#### Tag name defaults

If you omit `tag_name`, the workflow uses
`build-<github.run_number>-<environment>` (for example,
`build-42-production`). This is unique per workflow run but **not** per
commit — re-running the same run reuses the same tag and `gh release
create` will fail. For real SemVer releases, override `tag_name`
explicitly (e.g. `v1.2.3`).

### Mobile customisation

#### Adding Firebase App Distribution

To distribute builds via Firebase instead of (or in addition to) the stores,
add the [fastlane-plugin-firebase_app_distribution](https://github.com/fastlane/fastlane-plugin-firebase_app_distribution)
plugin:

```bash
cd ios  # or android
bundle exec fastlane add_plugin firebase_app_distribution
```

Then add a lane to the platform's `Fastfile`:

```ruby
lane :firebase do |options|
  # Build the app...
  firebase_app_distribution(
    app: ENV['FIREBASE_APP_ID'],
    groups: 'testers'
  )
end
```

#### Separate bundle IDs per environment

If you want different bundle IDs for staging and production (e.g. to install
both side-by-side), create `ios/fastlane/.env.staging` and
`android/fastlane/.env.staging`:

```env
APP_IDENTIFIER=com.yourcompany.yourapp.staging
```

You will also need separate match profiles and App Store entries for each
bundle ID.

---

## Web

The template includes a GitHub Actions workflow
(`.github/workflows/deploy-web.yml`) for deploying the Flutter web build to a
static hosting provider. The workflow is **optional** — it has no effect
unless you configure the required secrets and variables for your chosen
provider.

Currently supported providers:

| Provider | Workflow value | Status |
|---|---|---|
| [Cloudflare Pages](https://pages.cloudflare.com/) | `cloudflare-pages` | Available |

Adding a new provider is straightforward — see
[Adding a new web hosting provider](#adding-a-new-web-hosting-provider) at
the end of this guide.

### Building locally

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

### Local preview

After building, preview the site locally:

```bash
# Python (built-in)
python3 -m http.server 8080 -d build/web

# Or use any static file server
npx serve build/web
```

### SPA routing

Flutter web apps using **path-based URL strategy** (which `auto_route`
supports) need the server to rewrite all paths to `index.html`. Without this,
refreshing or deep-linking to a route like `/dashboard` returns a 404.

Flutter's **default hash-based strategy** (`/#/dashboard`) works without any
server configuration. If you switch to path-based URLs, create a
`web/_redirects` file so it is included in the build output:

```
/* /index.html 200
```

> **Note:** This `_redirects` format works on Cloudflare Pages and Netlify.
> Other providers may use different mechanisms (e.g. `vercel.json` rewrites,
> Firebase `firebase.json` rewrites). Check your provider's documentation.

### Base href

By default, `flutter build web` sets the base href to `/`, which works when
serving from the root of a domain (e.g. `https://myapp.pages.dev/`). If you
need to serve from a subpath, pass `--base-href`:

```bash
flutter build web --release --base-href=/my-app/ --dart-define-from-file=config/production.json
```

### Cloudflare Pages setup

#### Prerequisites

- A [Cloudflare account](https://dash.cloudflare.com/sign-up)
- A Cloudflare Pages project (created via the dashboard or CLI)

#### 1. Create a Pages project

In the Cloudflare dashboard:

1. Go to **Workers & Pages → Create**
2. Select the **Pages** tab, then **Upload assets** (direct upload)
3. Name your project (e.g. `my-app-staging`, `my-app-production`)
4. Upload a placeholder file to finish creation — the GitHub Action will
   overwrite it on the first deploy

Or use the Wrangler CLI:

```bash
npx wrangler pages project create my-app-staging
```

> **Tip:** Create separate projects for staging and production if you want
> isolated environments. Use a single project if you prefer Cloudflare's
> built-in preview/production branch model.

#### 2. Create an API token

1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click **Create Token**
3. Use the **Custom token** template
4. Permissions: **Account → Cloudflare Pages → Edit**
5. Account Resources: select the account that owns the Pages project
6. Create the token and copy it

#### 3. Configure GitHub secrets and variables

In your GitHub repository, go to **Settings → Secrets and variables →
Actions**.

**Secrets** (sensitive values) — in addition to the shared
[`CONFIG_STAGING` / `CONFIG_PRODUCTION`](#app-configuration-secrets-shared)
secrets:

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

#### 4. Custom domains

After your first deployment, configure a custom domain in the Cloudflare
Pages dashboard under your project's **Custom domains** tab. Cloudflare
handles SSL automatically.

### Running a manual web deployment

1. Go to your repository's **Actions** tab on GitHub
2. Select the **Deploy Web** workflow in the sidebar
3. Click **Run workflow**
4. Choose your **hosting provider** and **target environment**
5. Optionally set **Git ref** to build from a specific branch, tag, or commit
   SHA (leave empty to use the branch selected in the dropdown above)
6. Optionally set **Cloudflare Pages branch name** to create a preview
   deployment (leave empty for a production deployment)
7. Click **Run workflow** to start

The workflow provisions the environment config from templates, overwrites it
with the contents of the `CONFIG_<ENVIRONMENT>` secret if one is set
(see [How config values reach the build](#how-config-values-reach-the-build)),
builds the Flutter web app, and deploys to your chosen provider.

#### Workflow inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `provider` | Yes | -- | Hosting provider (`cloudflare-pages`) |
| `environment` | Yes | -- | Config to build with (`staging` or `production`) |
| `ref` | No | current branch | Git ref to checkout (branch, tag, SHA) |
| `cloudflare_branch` | No | _(empty)_ | Cloudflare Pages branch name. Empty = production deploy. Any value = preview deploy at `<value>.<project>.pages.dev` |

#### Workflow outputs

| Output | Description |
|---|---|
| `deployment_url` | URL of the deployed site (from the Cloudflare wrangler action) |

### Calling `deploy-web.yml` from another workflow

`deploy-web.yml` is a reusable workflow (`workflow_call`), so other workflows
can call it as a building block. The sections below provide complete,
copy-paste workflow files implementing the **recommended branch convention**
(see [Terminology → Branches](#branches)): `develop` deploys to staging,
`main` deploys to production, and pull requests against `main` get a preview
URL. Create each file in `.github/workflows/` in your repository, and adjust
the branch names if your team uses a different model.

#### Deploy on push to production

Automatically deploys to Cloudflare Pages production when a commit lands on
`main` (e.g. via a merged PR).

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
      CONFIG_PRODUCTION: ${{ secrets.CONFIG_PRODUCTION }}
```

`cloudflare_branch` is omitted (empty), so Cloudflare treats this as a
production deployment.

> **Tip:** If you have multiple secrets to forward, you can use
> `secrets: inherit` instead of listing each one — every secret in the
> calling repository becomes available to the reusable workflow. The explicit
> form is shown here so it is obvious which secrets are actually consumed.

#### Deploy on push to staging

Automatically deploys to a Cloudflare Pages preview URL when a commit lands
on `develop` or `staging`.

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
      CONFIG_STAGING: ${{ secrets.CONFIG_STAGING }}
```

`cloudflare_branch: staging` causes the deployment to appear at
`staging.<project>.pages.dev` rather than the production URL.

#### PR preview deployments

Automatically builds and deploys a preview for every pull request opened
against `main` or `staging`. Posts the preview URL as a PR comment and
updates it on each push. The preview is a Cloudflare Pages preview deployment
at `pr-<number>.<project>.pages.dev`.

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
      CONFIG_STAGING: ${{ secrets.CONFIG_STAGING }}

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
teardown is required. If you want to actively delete previews on PR close,
you can add a separate job triggered by `pull_request: [closed]` that calls
the Cloudflare API.

#### Combining workflows

You can enable any combination of the above. They do not conflict:

- **Production + Staging** — merge to `main` deploys to production; merge to
  `develop` deploys to staging
- **Production + PR preview** — PRs get a preview URL; merging to `main`
  deploys to production
- **All three** — full pipeline: PR preview → merge to `develop` for staging
  → merge to `main` for production

The reusable workflow's concurrency group (`deploy-web-<environment>`)
prevents overlapping deploys to the same environment. The PR preview workflow
uses its own concurrency group (`deploy-web-preview-pr-<number>`) so previews
and production deploys never block each other.

---

## Adding a new web hosting provider

To add support for a new hosting provider (e.g. Vercel, Netlify, Firebase
Hosting):

### 1. Update the workflow

In `.github/workflows/deploy-web.yml`:

**Add the provider to both choice lists** (`workflow_dispatch` and
`workflow_call`):

```yaml
# In workflow_dispatch.inputs.provider.options:
options:
  - cloudflare-pages
  - your-new-provider    # ← add here

# In workflow_call.inputs.provider (string type — document valid values)
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

### 2. Document the required secrets

Add a section to this file (above this one) documenting:

- Prerequisites (account, project setup)
- Required GitHub secrets and variables
- Any provider-specific configuration (e.g. rewrite rules for SPA routing)

### 3. Update the provider table

Add your provider to the table at the top of the [Web](#web) section.
