# Make the Starter Networking Baseline Backend-Neutral

## Problem statement §req:problem-statement

The Flutter starter template is intended to let teams begin with a runnable,
mock-first app and choose their backend only when the product needs one. Today,
the base template still presents a REST/Dio shape as if it were the normal
starting point: Dio/Retrofit dependencies are present, shared HTTP code is in the
starter app, REST-oriented configuration appears in the environment model, and
agent-facing documentation describes Dio/Retrofit as current infrastructure.

That default is costly for teams whose apps use Supabase, Firebase, custom SDKs,
or no backend yet. They inherit networking code and configuration they do not
use, they must carry local removals during template syncs, and contributors or
AI agents can be nudged toward a REST architecture the project did not choose.
Most known adopters so far have used Supabase, but the requirement is not to
make the template Supabase-specific. The requirement is to make the starter's
visible baseline genuinely backend-neutral while preserving a simple mock-backed
starting experience.

## Success criteria §req:success-criteria

- A fresh starter app can be installed, analyzed, tested, and run with mock data
  without selecting, configuring, or understanding any real backend.
- A fresh starter app does not expose Dio/Retrofit as part of its default visible
  surface: consumers do not see those dependencies, generated base files,
  default code paths, configuration prompts, or agent-facing instructions unless
  they intentionally opt into REST networking material.
- A downstream SDK-backed or no-backend project can sync the template without
  carrying a local patch whose only purpose is to remove Dio/Retrofit code,
  dependencies, REST configuration, or REST-biased agent guidance.
- A contributor or AI agent adding a feature sees repository and `Result`
  expectations described in backend-agnostic terms, so the default path does not
  steer new work toward REST/Dio when the project has not chosen it.
- Any backend-related configuration visible in the base starter is demonstrably
  useful beyond a REST backend, or it is absent from the base starter. The starter
  does not expose security controls that imply a protection users can enable when
  no such protection is present in the running app.
- A team that later wants REST/Dio networking can identify that it is an explicit
  choice rather than a hidden default. A polished automated opt-in flow is
  desirable, but it is secondary to keeping the base starter free of REST/Dio
  assumptions.

## User stories §req:user-stories

- As a developer starting an SDK-backed app, I can create a new project from the
  starter and begin feature work without first deleting a REST stack I will never
  use.
- As a developer maintaining an existing SDK-backed app, I can sync template
  updates without repeatedly resolving local differences caused by removing
  Dio/Retrofit from my project.
- As a developer building UI before a backend is chosen, I can run the starter
  with mock data so that early product work is not blocked by backend selection.
- As a contributor or AI agent adding a repository-backed feature, I can follow
  the documented `Result` and failure-handling contract without being told that
  backend failures must originate from Dio.
- As a team choosing REST later, I can recognize REST/Dio as an explicit product
  decision and add it intentionally, rather than inheriting it from the starter
  before the app needs it.
- As a template maintainer, I can describe the starter as backend-neutral with a
  straight face because its default app, docs, and configuration all match that
  promise.

## Quality attributes §req:quality-attributes

- **Backend neutrality** — the base starter works equally well as the starting
  point for SDK-backed, REST-backed, custom-backend, and mock-only apps because it
  does not privilege one backend style by default.
- **Low onboarding friction** — a new user can run the starter immediately with
  mock data and a small set of concepts; backend selection is not part of the
  first-run path.
- **Dependency minimalism** — the default dependency set contains what the
  starter app uses, not dormant reference infrastructure for a backend the
  consumer may never choose.
- **Documentation reliability** — human-facing and agent-facing guidance must
  describe the default app accurately enough that following it does not introduce
  an unintended backend architecture.
- **Configuration honesty** — configuration exposed by the starter must
  correspond to behavior the user can observe or to backend-agnostic concepts the
  starter actually needs.
- **Template sync friendliness** — downstream projects that do not use REST/Dio
  should receive template improvements without repeatedly re-removing the same
  networking assumptions.

## Constraints §req:constraints

- The base starter must not require Dio, Retrofit, Retrofit code generation, or
  shared Dio HTTP infrastructure unless the consumer has explicitly opted into
  REST/Dio networking.
- The starter must remain runnable without a real backend. A minimal mock-backed
  experience is part of the base product, not an optional add-on.
- The template should not be tailored to Supabase, Firebase, or any other single
  backend provider. Popular SDK-backed adopters are evidence that REST defaults
  are too specific, not a reason to replace one backend assumption with another.
- Existing REST adopters do not define the default baseline. It is acceptable for
  them to take deliberate migration or opt-in steps if that is the cost of making
  the base starter clean.
- REST-oriented environment values and security toggles belong in the base only
  if they are useful to the backend-neutral starter experience. Values that only
  make sense for a REST client, or that imply unimplemented security behavior,
  should not appear as default app concepts.
- The exact opt-in mechanism for REST/Dio is a specification decision. The
  requirement is that opt-in be explicit and that the starter app not depend on
  Dio/Retrofit before that choice is made.

## Priorities §req:priorities

1. **Make the default starter genuinely backend-neutral** — this has the highest
   impact because it removes the repeated local divergence carried by SDK-backed
   adopters and aligns the product with its mock-first promise.
2. **Preserve an out-of-the-box mock app** — backend neutrality is valuable only
   if the starter still runs immediately and demonstrates the app architecture
   without requiring a live service.
3. **Keep agents and contributors on neutral rails** — documentation is part of
   the product surface for this template. If the docs imply REST/Dio as the
   normal path, future work will recreate the same drift even after code is
   cleaned up.
4. **Remove misleading configuration concepts** — REST URLs and unimplemented
   security toggles are smaller than dependencies, but they still shape user
   expectations and should not survive as default concepts unless they serve the
   backend-neutral app.
5. **Make REST opt-in understandable without compromising the base** — REST/Dio
   remains a valid choice for some teams, but convenience for that path is
   secondary to ensuring no consumer gets it by accident.
