# Migrate Apple Builds from CocoaPods to Swift Package Manager

## Problem statement §req:problem-statement

Flutter now resolves Apple plugins through Swift Package Manager (SPM), but this
project's `ios/` and `macos/` directories still carry the older CocoaPods
integration alongside it. On macOS, every plugin the project uses is already a
Swift Package, so the leftover CocoaPods wiring is pure legacy: the build emits a
warning instructing the developer to remove it, and in environments where
CocoaPods is not installed the build fails outright with
`Error: CocoaPods not installed or not in valid state`.

This blocks anyone trying to build the Apple targets on a machine or CI image
that does not have the CocoaPods toolchain, and it adds build time and
maintenance overhead even where it does succeed. As a starter template intended
to be a clean reference implementation, carrying two competing native dependency
systems sends the wrong signal to every team that forks it. The goal is to make
Apple builds depend only on Swift Package Manager, so the project builds cleanly
without the CocoaPods toolchain present and stays a faithful, modern reference.

## Success criteria §req:success-criteria

- Building the app for iOS produces no CocoaPods-related warning or error, and
  the built app runs with every plugin functioning (secure storage, connectivity,
  deep links, package info, launching URLs, Sentry reporting).
- Building the app for macOS produces no CocoaPods-related warning or error, and
  the built app runs with every plugin functioning.
- A build succeeds on a machine or CI image that does not have the CocoaPods
  toolchain installed — the absence of CocoaPods is no longer a failure.
- An automated CI check builds both the iOS and the macOS targets on every
  change and fails if either the CocoaPods regression returns or an Apple build
  otherwise breaks.
- A developer who freshly clones the repository can build both Apple targets by
  following the project's documented steps, without separately installing or
  configuring CocoaPods.

## User stories §req:user-stories

- As a developer on a machine without CocoaPods, I can build and run the iOS and
  macOS apps so that I am not forced to install a native toolchain the project no
  longer needs.
- As a developer building the macOS app today, I no longer see the "remove
  CocoaPods integration" warning, so my build output is clean and I trust the
  project is set up correctly.
- As a maintainer of this template, I can point adopters to a project that uses a
  single, current native dependency system, so forks start from a modern baseline
  rather than inheriting legacy scaffolding.
- As a reviewer merging a change, I can rely on CI to catch any accidental
  reintroduction of CocoaPods or breakage of an Apple build before it lands.
- As an end user of an app built from this template, the iOS and macOS apps
  behave exactly as before the migration — nothing about the app's features or
  reliability regresses.

## Quality attributes §req:quality-attributes

- **Build reproducibility** — Apple builds succeed on a clean image with only the
  standard Flutter and Xcode toolchain; no CocoaPods gem or `pod` binary required.
- **Build performance** — removing the redundant CocoaPods step should not slow
  Apple builds and is expected to reduce build time.
- **Functional parity** — all plugins currently in use continue to work
  identically on both Apple platforms after the migration.
- **Compatibility** — raising the minimum supported iOS/macOS version is
  acceptable if the migration requires it (see Constraints).
- **Regression safety** — the CocoaPods-free state is protected by automated CI so
  it cannot silently degrade over time.

## Constraints §req:constraints

- Both Apple platforms (`ios/` and `macos/`) are in scope; neither should carry
  CocoaPods integration when the work is complete.
- CocoaPods is to be fully removed, not merely disabled — the Podfile and Pods
  scaffolding come out for a clean project, with no CocoaPods fallback retained.
- Raising the app's minimum supported iOS and/or macOS version is permitted where
  Swift Package Manager requires it; dropping support for older OS versions is an
  accepted tradeoff.
- The CI Apple build guard must cover both iOS and macOS (the most thorough, and
  most expensive, option was chosen deliberately). CI today only builds web, so
  this adds new Apple build coverage.
- The app's user-facing behavior and feature set must not change; this is an
  infrastructure migration only.
- Follow Flutter's official guidance for app developers migrating to Swift
  Package Manager as the reference for the migration mechanics.

## Priorities §req:priorities

1. **Restore buildability without CocoaPods** — highest impact and the reason the
   task exists. macOS builds currently hard-fail where CocoaPods is absent;
   removing that dependency unblocks every affected developer and CI image.
2. **Complete both platforms cleanly** — doing iOS and macOS together in one pass,
   with CocoaPods fully removed, is what keeps this a trustworthy reference
   template and avoids leaving a half-migrated state that confuses adopters.
3. **Lock it in with CI** — the both-platforms CI guard is essential to prevent
   silent regression, but it depends on the migration itself being correct first,
   so it follows the migration work rather than leading it.
