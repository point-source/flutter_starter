# Migrate Apple Builds from CocoaPods to Swift Package Manager — Technical Spec

This spec covers the removal of CocoaPods from the `ios/` and `macos/` targets so
that Apple builds resolve native plugins exclusively through Swift Package Manager
(SPM). It is an infrastructure migration: no user-facing app behavior changes.

Grounding fact that shapes every decision below: **SPM is enabled by default in
Flutter as of 3.44**, so no per-machine flag or per-project opt-in is required for
a fresh clone or a CI runner to build against it. Flutter's build tooling already
reports that every plugin in use is available as a Swift Package. The work is
therefore not "adopt SPM" — that is done — but "retire the redundant CocoaPods
scaffolding that now only causes warnings and hard failures."

---

## Apple targets integrate plugins through Swift Package Manager only §spec:spm-only-integration

*Status: complete*

Both Apple targets build with SPM as the sole native dependency system. The
`ios/` and `macos/` directories carry no CocoaPods integration of any kind: no
`Podfile`, no `Podfile.lock`, no `Pods/` scaffolding, no `Pods.xcodeproj`
reference in the workspace, no `[CP]` build phases or `Pods_Runner` linkage in the
Xcode project, and no `#include? ".../Pods-Runner.*.xcconfig"` lines in the
`Flutter/*.xcconfig` files. Every plugin currently in use — secure storage,
connectivity, deep links (`app_links`), package info, URL launching, and Sentry
reporting — continues to function identically on both platforms after the change.

**Observable behavior / test path:** On a machine that has the standard Flutter +
Xcode toolchain but *no* `pod` binary and no CocoaPods gem, `flutter build ios`
and `flutter build macos` both complete with no CocoaPods warning and no
`Error: CocoaPods not installed or not in valid state`. The resulting apps launch
and every listed plugin works (e.g. a value written to secure storage survives a
relaunch, a deep link opens the app, connectivity state is reported, Sentry
receives an event).

**Decision and the constraint that drove it:** Remove CocoaPods *entirely* rather
than disable or hide it. The driving constraint is that macOS builds today
*hard-fail* wherever CocoaPods is absent (the failure the task exists to fix), and
the requirement is explicit that CocoaPods be fully removed with no fallback
retained. A clean reference template must not ship two competing native dependency
systems. A useful defensive property falls out of full removal: because there is
no `Podfile`, Flutter cannot silently fall back to a broken CocoaPods path — if
SPM were ever disabled, the build fails loudly at integration time rather than
producing a subtly wrong artifact.

**Minimum OS versions:** The current deployment targets (iOS 13.0, macOS 10.15)
already satisfy SPM's floor and every in-use plugin's declared platform minimum,
so no version bump is planned. The constraint that governs this: raising the
minimum iOS/macOS version is permitted *only if* a plugin's Swift Package manifest
declares a higher floor than the project sets, in which case the target is raised
to the lowest version that satisfies all plugins. Dropping support for older OS
versions is an accepted tradeoff, but it is not to be done gratuitously — the
observable trigger is a real build error, not a preference.

**Alternatives considered:**
- *Keep both systems, suppress the warning* (e.g. leave the `Podfile` and rely on
  the `#include?` optional include) — rejected: it does not fix the no-CocoaPods
  hard failure, and it perpetuates the dual-system state the template must not
  model.
- *Delete only the `Podfile` but leave the Xcode/workspace scaffolding* — rejected:
  a half-removed state leaves stale `[CP]` build phases and `Pods_Runner`
  references that break the build or confuse adopters.
- *Revert to CocoaPods and pin it* — rejected: the CocoaPods registry becomes
  read-only on 2026-12-02 and SPM is the forward path; reverting moves against
  both Flutter's guidance and the requirement.

**Tradeoffs:** The project loses the ability to fall back to CocoaPods for a
plugin that is not yet SPM-ready; this is acceptable because every plugin in use
is already a Swift Package (confirmed by Flutter's own build output). Adopters who
add a future plugin that is CocoaPods-only would need to re-enable SPM's fallback
themselves — an explicit, documented escape hatch rather than latent scaffolding.

*Follows Flutter's official app-developer guidance for the migration mechanics.*

§req:problem-statement, §req:success-criteria, §req:constraints, §req:quality-attributes, §req:user-stories, §req:priorities

---

## The release pipeline requires no CocoaPods toolchain §spec:release-pipeline-cocoapods-free

*Status: complete*

The iOS release path (Fastlane, invoked from `deploy.yml`) builds and ships
without any CocoaPods dependency. The `cocoapods` gem is removed from
`ios/Gemfile`, so `bundle install` on a release image installs neither the gem nor
its transitive toolchain, and no `pod install` runs during a build.

**Observable behavior / test path:** On a clean CI image, `bundle install` in
`ios/` succeeds without pulling `cocoapods`, and a Fastlane iOS build lane
completes end-to-end, producing a signed artifact, with no `pod` invocation in the
logs.

**Decision and the constraint that drove it:** Extend removal into the release
pipeline, not just the project scaffolding — the operator chose the fuller scope.
The driving constraint is the stated quality attribute that Apple builds require
"no CocoaPods gem or `pod` binary" and that CocoaPods be *fully* removed. Leaving
the gem in the `Gemfile` would contradict a clean reference template and leave a
vestigial dependency that a future change could accidentally reactivate.

**Alternatives considered:**
- *Remove project scaffolding only, keep the `cocoapods` gem* — rejected by the
  operator: smaller blast radius on the release path, but it leaves a contradictory
  leftover dependency in a template meant to model a clean baseline.

**Tradeoffs:** Touching the release pipeline carries more risk than editing only
the app project. The risk is bounded: Fastlane's build step only runs `pod
install` when a `Podfile` is present, and that file is removed by
§spec:spm-only-integration, so no lane relies on the gem once both changes land.
If a future Fastlane action were to require CocoaPods, it would need the gem
re-added deliberately — a visible, reviewed change.

§req:constraints, §req:quality-attributes, §req:user-stories

---

## CI guards the CocoaPods-free state on every change §spec:ci-apple-build-guard

*Status: not started*

Continuous integration builds both the iOS and the macOS targets on every pull
request and fails if either Apple build breaks. In addition to compiling, CI runs
a static regression check that fails if any CocoaPods artifact — a `Podfile`,
`Podfile.lock`, a `Pods/` directory, a `Pods.xcodeproj` workspace reference, or a
`Pods-Runner` xcconfig include — reappears anywhere in `ios/` or `macos/`.

**Observable behavior / test path:** Opening a PR triggers an iOS build job and a
macOS build job on macOS runners; both must pass for the merge gate. A PR that
reintroduces a `Podfile` (or any other CocoaPods artifact) fails the static check
with a clear message, even though the runner image happens to ship CocoaPods. A PR
that breaks an Apple build (e.g. a plugin that no longer resolves under SPM) fails
the corresponding build job.

**Decision and the constraint that drove it:** Guard with *both* a real build of
each platform *and* a cheap static anti-regression check — the operator's choice
over build-only. The driving constraint is regression safety: GitHub's
`macos-latest` runners ship CocoaPods pre-installed, so a re-added `Podfile` could
still build green under the runner's pod toolchain and slip through a build-only
guard. The static check closes that gap by asserting the *absence* of CocoaPods
artifacts directly, independent of what the runner has installed. Covering both
platforms (rather than macOS alone, where the original failure surfaced) was
deliberately chosen as the most thorough option despite being the most expensive.

The iOS build runs unsigned (no code-signing secrets), because the guard's job is
to prove that plugins resolve and the target compiles under SPM, not to exercise
signing or distribution — that remains the release pipeline's responsibility.

**Alternatives considered:**
- *Build only, no static check* — rejected by the operator: the pod-equipped
  runner could mask a re-added `Podfile`, defeating the regression-safety goal.
- *Guard a single platform* — rejected by the requirement: leaving one Apple
  target unguarded lets a regression land on it silently.

**Tradeoffs:** macOS runners are materially slower and costlier than the Linux
runners used by the existing web/lint/test jobs, and Apple builds are the longest
in the matrix, so every PR pays that time-and-cost premium. This was accepted as
the deliberate price of preventing silent regression. This guard depends on the
migration itself being correct first (it codifies the finished state), so it
follows the removal work rather than leading it.

§req:success-criteria, §req:constraints, §req:quality-attributes, §req:user-stories, §req:priorities

---

## A fresh clone builds both Apple targets without configuring CocoaPods §spec:fresh-clone-build-docs

*Status: complete*

A developer who freshly clones the repository can build both Apple targets by
following the project's documented setup steps, without separately installing or
configuring CocoaPods. The documented Apple prerequisites and build steps make no
reference to a `pod` toolchain, and any mention of CocoaPods in build/deploy docs
is removed or replaced with the SPM reality.

**Observable behavior / test path:** Following `docs/template/DEPLOYMENT.md` (and
the CLAUDE.md common-commands section) from a clean checkout — `./scripts/setup.sh`,
`flutter pub get`, `flutter build ios` / `flutter build macos` — succeeds on a
machine with only Flutter and Xcode installed, and the docs never instruct the
reader to install CocoaPods or run `pod install`.

**Decision and the constraint that drove it:** Rely on Flutter's default-on SPM
(3.44+) and keep the onboarding path free of any CocoaPods setup step; do not add
a per-machine `flutter config` instruction, because none is needed. The driving
constraint is the success criterion that a fresh clone build must not require
installing or configuring CocoaPods, plus the build-reproducibility quality
attribute (Apple builds succeed on a clean image with only the standard toolchain).
Documentation is treated as part of the deliverable because a reference template's
docs are a first-class interface: an adopter who reads "run `pod install`" would
reintroduce the very dependency being removed.

**Alternatives considered:**
- *Leave docs as-is* — rejected: current docs are largely CocoaPods-free already,
  but any residual gem/toolchain instruction (e.g. in the Fastlane prerequisites)
  that implies CocoaPods must be corrected so the documented path matches the
  CocoaPods-free reality.
- *Add an explicit "enable SPM" step to the docs* — rejected: SPM is on by default
  in supported Flutter versions, so the step would be noise that implies a
  configuration burden that does not exist.

**Tradeoffs:** This section's correctness is only as durable as the reader's
Flutter version; a developer pinned to a pre-3.44 Flutter would need SPM enabled
manually. That is out of scope — the project targets the stable channel, which is
well past 3.44 — but it is the one assumption a future reader should know about.

§req:success-criteria, §req:user-stories, §req:quality-attributes
