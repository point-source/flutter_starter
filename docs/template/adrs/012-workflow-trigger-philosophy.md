# ADR 012: Workflow Trigger Philosophy

## Status

Accepted

## Context

The template ships three GitHub Actions workflows that derived projects
inherit on first fork: `ci.yml` (lint + test + build smoke + codegen
freshness), `deploy.yml` (mobile store deploys via Fastlane), and
`deploy-web.yml` (web hosting deploys). Each workflow has very different
characteristics:

- **`ci.yml`** is a *baseline merge gate*. It needs no real secrets (the
  optional `CONFIG_DEVELOPMENT` secret falls back to a committed example
  file), runs in a couple of minutes, and provides value the moment a
  derived project forks the template -- no setup required.
- **`deploy.yml`** and **`deploy-web.yml`** are *side-effecting deploys*.
  They need real signing keys / store credentials / hosting API tokens
  before they do anything useful, and a misfire publishes a binary to
  TestFlight / the Play Store / a public hosting target.

The original trigger configuration treated these uniformly: `ci.yml`
auto-fired on both `pull_request: [main]` and `push: [main]`, while the
deploy workflows were `workflow_dispatch` only. The `push: [main]`
trigger on `ci.yml` had two problems that surfaced as the template
matured:

1. **Redundant runs in PR-based workflows.** When a PR is merged into
   `main`, the same SHA was already validated at PR-open time. Re-running
   the identical checks on `push: [main]` doesn't catch new regressions
   -- it just re-validates green code. Modern PR-based workflows
   (which the template otherwise assumes -- branch protection, status
   checks, etc.) treat the PR check *as* the merge gate, so a post-merge
   re-run is wasted CI minutes without any new coverage.

2. **Collision with downstream automation.** Derived projects that add
   their own `push: [main]`-triggered workflows (release-gate
   workflows, deploy-on-merge pipelines, custom changelog generators)
   end up with two workflows lint/test-ing the same SHA in parallel.
   The fuse_tools downstream project hit exactly this and had to drop
   `push: [main]` from `ci.yml` locally to avoid the collision.

The deploy workflows had the opposite shape from the start: never
auto-trigger (because publishing requires intent), always reusable via
`workflow_call` (so derived projects can layer their own automation on
top -- e.g. a tag-push workflow that calls `deploy.yml` with
`platform: both lane: store_production`).

What was missing was a stated *philosophy* that explained why the two
shapes differed and that future template workflows should follow.

Alternatives considered for the trigger philosophy:

- **Uniform auto-on-push for everything.** Keeps things simple but means
  deploys would auto-fire on `push: [main]`, which is unsafe for
  side-effecting workflows. Rejected -- the cost of an unintended
  deploy is much higher than the cost of clicking a button.
- **Uniform manual-only for everything.** Symmetric, but loses CI's
  most valuable property: PRs get checked automatically without
  anyone having to remember. Rejected -- CI's whole point is being
  invisible until it catches something.
- **Push + PR for `ci.yml`, manual for deploys (the original mix).**
  The collision case above. Rejected.
- **PR-only for `ci.yml`, manual for deploys, all workflows reusable
  via `workflow_call`.** The chosen shape. See Decision below.

Alternatives considered for *where to record this*:

- **Architecture rule.** All existing rules in
  `docs/template/architecture-rules/` are about Dart/Flutter code
  patterns (Riverpod, navigation, error handling, testing, etc.).
  Adding a workflow-trigger rule would expand the rule set into a new
  domain on the strength of a single application. Rejected as
  premature -- if the principle later gets a second application
  (e.g. a fourth template workflow), a rule can be extracted from
  this ADR.
- **Inline comment in `ci.yml` only.** Insufficient: the rationale
  generalizes beyond `ci.yml`, and it explains *why* deploy workflows
  are manual too -- which doesn't fit in a comment in `ci.yml`.
- **A new top-level guide doc** (e.g. `docs/template/CI.md` or
  `docs/template/WORKFLOWS.md`). Risk of duplicating
  `DEPLOYMENT.md`'s mechanics-focused content. The actual content
  here is a *decision*, not a how-to.

## Decision

Each template workflow declares the minimum set of triggers that
**(a)** auto-fire only in contexts where the workflow provably earns its
keep on a fresh fork, and **(b)** support manual + reusable triggering
so derived projects can layer their own automation without having to
fork or duplicate the template's workflow files.

Concretely:

| Workflow | Auto-trigger | Manual | Reusable | Why |
|---|---|---|---|---|
| `ci.yml` | `pull_request: [main]` | `workflow_dispatch` | `workflow_call` | The PR check *is* the merge gate. No `push: [main]` -- redundant on PR-based workflows and collides with downstream `push: [main]` automation. |
| `deploy.yml` | *(none)* | `workflow_dispatch` | `workflow_call` | Side-effecting; requires signing keys + store credentials before it works. Auto-firing on push would publish without intent. |
| `deploy-web.yml` | *(none)* | `workflow_dispatch` | `workflow_call` | Same reasoning as `deploy.yml` -- side-effecting, requires hosting credentials. |

The principle in one sentence: **auto where the trigger earns its
keep, manual where caution is needed, reusable everywhere**.

Future template workflows must follow this principle. When adding a
new workflow, ask:

1. Does this workflow do anything *useful and safe* on a fresh fork
   without configuration? If yes, it can have an auto-trigger; pick the
   trigger that catches the events the workflow is designed to react to
   and no more. If no, it should be `workflow_dispatch` only.
2. Would a derived project ever want to wire this into their own
   automation? If yes (almost always), declare `workflow_call` so they
   can `uses:` it instead of duplicating it.
3. Is there a context where a maintainer would want to run this without
   a triggering event (debugging, ad-hoc validation, re-running after a
   flake)? If yes (almost always), declare `workflow_dispatch`.

Derived projects that want stricter coverage on a specific workflow
remain free to add triggers themselves. For example, a project that
allows direct pushes to `main` and wants `ci.yml` to validate them can
add `push: [main]` back in their own copy with one line, or wire a
project-owned workflow that uses `workflow_run: { workflows: [CI] }`
to react to CI completion. The template's defaults are *minimum
intrusive*, not *minimum capable*.

## Consequences

### Positive

- **No collision with downstream automation.** Derived projects can add
  any `push: [main]`-triggered workflow they want (release gates,
  deploy-on-merge, changelog generation, Slack notifications) without
  fighting the template's defaults.
- **No redundant CI runs.** PR check is the merge gate; no re-run on
  the same SHA after merge. Saves CI minutes on private repos where
  GitHub Actions usage is metered.
- **Consistent reusable shape.** Every template workflow exposes
  `workflow_call`, so derived projects compose them without forking.
  Combined with `workflow_dispatch`, every workflow can be triggered
  three ways: by an event, by a human, or by another workflow.
- **Self-explanatory deploy semantics.** "Deploys are manual because
  they need configuration" matches the documentation in `DEPLOYMENT.md`
  and the user mental model.
- **Clear rule for future workflows.** The three-question test in the
  Decision section gives template maintainers a deterministic way to
  pick triggers when adding new workflows.

### Negative

- **Direct pushes to `main` aren't auto-validated by `ci.yml`.** If a
  maintainer pushes directly to `main` (bypassing PR review and branch
  protection), the bad commit isn't caught until the next PR runs CI
  against it. Trade-off: this is the rare path in a well-disciplined
  workflow, branch protection should generally prevent it, and the
  next PR catches any regression cheaply. Projects that want stricter
  enforcement can add `push: [main]` back themselves -- the template's
  default is the *common* case.
- **Manual deploys mean a human in the loop for every release.** This
  is intentional (caution on side-effecting actions) but means
  high-frequency release cadences need a derived-project caller
  workflow that wraps `deploy.yml` via `workflow_call`. The template
  documents this pattern but doesn't ship a default caller.

### Neutral

- The principle generalizes to any future workflow the template adds.
  If the principle later acquires a second application that needs
  stricter prescriptive enforcement, an architecture rule can be
  extracted from this ADR -- but until then, one ADR is enough.
- The `BREAKING CHANGE` for `lane=beta`/`lane=release` rename in commit
  `e64c57f` is unrelated to this ADR but demonstrates the same
  underlying value: keep the surface area intentional and force
  maintainers to think about what each declared trigger / lane / input
  is buying.
