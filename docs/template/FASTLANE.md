# Fastlane Setup Guide

This project uses [Fastlane](https://fastlane.tools/) to automate builds and
deployments to the Apple App Store and Google Play Store.

Fastlane is configured **per-platform** following the
[official Flutter CD guide](https://docs.flutter.dev/deployment/cd#fastlane):
- `ios/fastlane/` — iOS lanes (TestFlight, App Store)
- `android/fastlane/` — Android lanes (Play Store)

## Prerequisites

- **Ruby** 3.4+ (see `ios/.ruby-version` and `android/.ruby-version`)
- **Bundler** (`gem install bundler`)
- **Xcode** (latest stable, with command-line tools)
- **Android SDK** with Java 17
- **Flutter** (stable channel)

Install Fastlane and dependencies for each platform:

```bash
cd ios && bundle install
cd android && bundle install
```

## Preflight Check

Before configuring anything, you can run the preflight check to see what still
needs to be set up:

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

## First-Time Setup

### 1. Update App Identifiers

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

### 2. iOS Code Signing (match)

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

### 3. App Store Connect API Key

For CI deployments, use an App Store Connect API key instead of Apple ID
credentials.

1. Go to [App Store Connect > Users and Access > Integrations > App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api)
2. Create a new key with **App Manager** role
3. Download the `.p8` file and note the **Key ID** and **Issuer ID**
4. Store these as GitHub repository secrets (see [CI/CD Setup](#cicd-setup))

### 4. Android Upload Keystore

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

### 5. Google Play Service Account

1. Go to [Google Play Console > Setup > API access](https://play.google.com/console/developers/api-access)
2. Create or link a Google Cloud project
3. Create a service account with **Release Manager** role
4. Download the JSON key file
5. Save it as `android/fastlane/google-play-key.json` (gitignored)

> **Note:** You must upload your first AAB manually via the Play Console before
> Fastlane can upload subsequent builds.

## Local Usage

### iOS

```bash
cd ios

# Sync code signing certificates
bundle exec fastlane certificates

# Build and upload to TestFlight (staging)
bundle exec fastlane beta

# Build and upload to TestFlight (production)
bundle exec fastlane beta environment:production

# Build and upload to App Store
bundle exec fastlane release
```

### Android

```bash
cd android

# Build and upload to Play Store internal testing (staging)
bundle exec fastlane beta

# Build and upload to Play Store internal testing (production)
bundle exec fastlane beta environment:production

# Build and upload to Play Store production
bundle exec fastlane release
```

### Options

All lanes accept these optional parameters:

| Parameter | Description | Example |
|---|---|---|
| `environment` | Config environment (`staging` or `production`) | `environment:staging` |
| `build_number` | Override build number | `build_number:42` |

## CI/CD Setup

The project includes a GitHub Actions workflow (`.github/workflows/deploy.yml`)
that can be triggered manually to deploy to either platform.

### Required GitHub Secrets

#### iOS Secrets

| Secret | Description |
|---|---|
| `MATCH_PASSWORD` | Encryption password for your match certificates repo |
| `MATCH_GIT_PRIVATE_KEY` | SSH private key with access to the certificates repo |
| `MATCH_GIT_URL` | Git URL of the certificates repo |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect API issuer ID |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect API private key (`.p8` contents) |

#### Android Secrets

| Secret | Description |
|---|---|
| `ANDROID_KEYSTORE` | Base64-encoded upload keystore (`base64 -i android/keystore/upload.jks`) |
| `ANDROID_KEY_PROPERTIES` | Contents of `android/key.properties` |
| `GOOGLE_PLAY_JSON_KEY` | Contents of the Google Play service account JSON key |

#### GitHub Variables (Settings > Secrets and Variables > Variables)

| Variable | Description |
|---|---|
| `APP_IDENTIFIER` | iOS bundle identifier |
| `APPLE_ID` | Apple ID email |
| `TEAM_ID` | Apple Developer Team ID |
| `ITC_TEAM_ID` | App Store Connect Team ID |
| `PACKAGE_NAME` | Android package name |
| `API_URL` | (Optional) API URL override for builds |

### Running a Deployment

1. Go to **Actions > Deploy** in your GitHub repository
2. Click **Run workflow**
3. Select platform (ios / android / both), environment, and lane
4. Click **Run workflow**

The build number is automatically set to the GitHub Actions run number.
A preflight check runs before every deploy to catch misconfiguration early.

## Customization

### Adding Firebase App Distribution

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

### Separate Bundle IDs per Environment

If you want different bundle IDs for staging and production (e.g., to install
both side-by-side), create `ios/fastlane/.env.staging` and
`android/fastlane/.env.staging`:

```env
APP_IDENTIFIER=com.yourcompany.yourapp.staging
```

You will also need separate match profiles and App Store entries for each
bundle ID.
