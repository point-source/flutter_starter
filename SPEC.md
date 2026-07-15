# Make the Starter Networking Baseline Backend-Neutral — Technical Spec

The starter begins as a runnable, mock-first Flutter application. A real backend
is a project decision made after adoption, not a choice the base template makes
on the adopter's behalf.

## The base starter has no real-backend networking stack §spec:backend-neutral-base

*Status: complete*

A fresh starter contains no Dio/Retrofit dependencies, shared REST client,
REST-client generation, or tests and generated artifacts whose only purpose is
to support that stack. Its example features continue to run against mock-backed
repositories, and choosing no backend remains a complete, supported starting
state. Removing the REST reference surface does not remove the repository
boundary, explicit result handling, or the ability to replace a mock repository
with a project-selected implementation.

**Observable behavior / test path:** A developer creates a fresh app, resolves
its dependencies, analyzes and tests it, and launches its example flow without
selecting a backend or supplying network configuration. Searching the app's
default dependencies, generated surface, and runtime code reveals no Dio or
Retrofit requirement. The same flow produces the expected mock data and explicit
success or failure states.

**Decision and driving constraint:** The system removes REST reference
infrastructure from the base rather than merely describing it as optional. The
driving constraint is backend neutrality: dormant code and dependencies still
shape contributor decisions and force SDK-backed adopters to carry a deletion
delta. The existing mock-first repository boundary already proves that the app
can remain useful without a concrete networking stack, so no replacement backend
is introduced.

**Alternatives considered:** Keeping Dio/Retrofit as shipped reference
infrastructure was rejected because its visible presence continues to privilege
REST even when no feature uses it. Replacing Dio with Supabase, Firebase, or
another SDK was rejected because it exchanges one backend assumption for another.
Shipping multiple backend examples was rejected because it increases the default
dependency and concept surface while making no single project more complete.

**Tradeoffs:** REST teams lose a worked client inside every fresh checkout and
must make an explicit opt-in. In return, all teams receive a smaller and more
truthful base, and non-REST teams no longer begin by deleting code. The starter
continues to teach stable application boundaries but no longer treats one
transport implementation as part of those boundaries.

§req:problem-statement, §req:success-criteria, §req:user-stories,
§req:quality-attributes, §req:constraints, §req:priorities

---

## REST with Dio is a deliberate supported opt-in §spec:dio-rest-opt-in

*Status: complete*

A team that chooses a REST backend can explicitly add the starter's supported
Dio/Retrofit capability. The opt-in supplies the coherent REST foundation needed
by REST-backed repositories and makes its added dependencies, configuration
needs, error mapping, and maintenance ownership clear before the team accepts
them. Feature-level REST generation is available only after that foundation has
been selected; requesting REST output without its prerequisite fails early with
an actionable explanation rather than leaving a partially configured project.

**Observable behavior / test path:** Starting from a fresh neutral app, a
developer follows the documented opt-in once and can then add a REST-backed
feature whose repository returns the same public result contract as a mock or
SDK-backed repository. The app resolves, analyzes, and tests successfully. If
the developer requests REST-backed feature material before opting in, the request
stops without partial output and tells them how to make the explicit choice.

**Decision and driving constraint:** REST support is retained as an optional,
cohesive capability rather than as latent base-template code or disconnected
feature fragments. The driving constraint is that opt-in must be genuine: the
base cannot depend on Dio/Retrofit before selection, while a selected REST path
must remain understandable and must not generate code whose shared foundation is
missing. This preserves the evolution path for REST adopters without weakening
the neutral default.

**Alternatives considered:** Keeping only the existing feature switch was
rejected because generated REST features can assume infrastructure the neutral
base no longer contains. A copy-and-paste recipe was rejected as the supported
path because it drifts silently and offers no reliable completeness check. A
separate REST edition of the whole starter was rejected because parallel
templates duplicate unrelated architecture and make improvements harder to sync.
Removing all REST guidance was rejected because REST remains a valid backend
choice and the starter already has a coherent pattern worth preserving as an
explicit option.

**Tradeoffs:** The opt-in has its own compatibility surface and requires ongoing
maintenance, and REST teams perform an extra intentional step. That cost buys a
safe failure mode and prevents every non-REST consumer from inheriting the same
dependencies. The optional capability recommends a REST shape but does not make
that shape part of the backend-neutral application contract.

§req:success-criteria, §req:user-stories, §req:quality-attributes,
§req:constraints, §req:priorities

---

## Repository and failure guidance is backend-agnostic §spec:backend-agnostic-contracts

*Status: complete*

The starter's human-facing and agent-facing guidance describes repositories as
the boundary between product code and any external data source. Repositories
return the shared explicit result contract and translate backend-specific errors
into application failures; no transport exception, SDK exception, or provider
type escapes into presentation or domain behavior. Examples in the neutral base
compile conceptually against APIs the base actually provides and do not name
nonexistent conversion helpers.

Architecture decisions that recommend Dio/Retrofit apply only to projects that
have selected the REST capability. The default architecture rules present REST,
SDK-backed services, custom clients, local sources, and mocks as alternative
repository implementations rather than ranking one as current infrastructure.

**Observable behavior / test path:** A contributor or AI agent follows only the
base starter guidance to add a mock-backed or SDK-backed repository. The feature
handles success and failure through the documented result contract without
adding Dio, importing backend types above the repository boundary, or discovering
that a documented helper does not exist. A REST-opted-in project can follow its
REST-specific guidance and reach the same user-visible success and failure
states.

**Decision and driving constraint:** The system standardizes the boundary and
observable error behavior, not the mechanism that produces errors. The driving
constraint is documentation reliability across multiple valid backends: guidance
that tells contributors to catch one library's exception recreates coupling even
after that library leaves the base. REST-specific recommendations remain scoped
to the explicit REST choice so they can still be concrete where appropriate.

**Alternatives considered:** Generalizing every backend into a universal network
exception hierarchy was rejected because SDK, transport, local, and mock failure
modes do not share a truthful low-level taxonomy. Removing the result and failure
contract was rejected because explicit, testable failure behavior is valuable
independently of backend choice. Leaving accepted REST decisions unqualified was
rejected because it contradicts the base starter's observable contents and would
continue to steer future work toward Dio.

**Tradeoffs:** Backend-neutral guidance cannot teach every provider's detailed
failure API; project-specific guidance must supply that detail after a backend is
chosen. In exchange, product-facing code and tests remain stable when the data
source changes, and neutral examples cannot become stale against an absent REST
library.

§req:problem-statement, §req:success-criteria, §req:user-stories,
§req:quality-attributes, §req:constraints, §req:priorities

---

## Backend configuration appears only after a backend is selected §spec:explicit-backend-configuration

*Status: complete*

The base starter exposes neither a default API URL nor an SSL-pinning switch.
When a project selects a backend, it defines configuration in the terms that
backend actually consumes, and any security control exposed to operators
corresponds to protection enforced by the running application. REST opt-in may
introduce a REST endpoint value, but it does not claim that certificate pinning
exists unless the selected capability implements and verifies pinning behavior.

**Observable behavior / test path:** A developer launches a fresh starter in
each supported environment without supplying an API URL or SSL-pinning setting,
and the app neither prompts for them nor reports them as available controls. A
project that opts into a backend receives a clear failure when a configuration
value that backend truly requires is absent. Changing a documented security
control has a testable effect on connection acceptance; otherwise that control
is not presented.

**Decision and driving constraint:** Remove the two REST-oriented concepts from
the neutral base instead of renaming them into a speculative universal backend
configuration. The driving constraint is configuration honesty. Supabase,
Firebase, REST services, local stores, and custom SDKs do not share one useful
endpoint or transport-security contract, and an unimplemented pinning toggle
misstates the application's protection. Explicit backend-owned values are more
accurate than a weak abstraction.

**Alternatives considered:** A generalized `backendUrl` was rejected because
many SDKs require several provider-specific values or manage endpoints
internally, so the name would remain misleading. Keeping the API URL as an
unused convenience was rejected because unused configuration biases the design
and complicates onboarding. Keeping the SSL-pinning switch as a future hook was
rejected because a security setting that changes no runtime behavior creates
false assurance.

**Tradeoffs:** Teams cannot rely on one predeclared location for all future
backend settings and must add explicit configuration when they make a backend
choice. That small setup cost keeps the base minimal and makes security posture
inspectable: a visible control either works or does not exist.

§req:success-criteria, §req:user-stories, §req:quality-attributes,
§req:constraints, §req:priorities

---

## Existing REST adopters migrate deliberately §spec:rest-adopter-migration

*Status: not started*

The baseline change applies to new starter output and future template-owned
guidance; it does not silently rewrite a downstream project's chosen backend.
Existing projects that use the shipped Dio infrastructure can retain it as
project-owned REST code or adopt the supported REST opt-in shape through an
explicit migration. Existing projects that already removed Dio can accept the
new baseline without reintroducing REST artifacts or preserving a local
removal-only delta. Migration guidance distinguishes files and choices a project
must retain from obsolete template defaults, and it calls out any action that
could change runtime networking behavior.

**Observable behavior / test path:** A maintainer tests the template update
against two representative downstream projects: one that actively uses the
current Dio stack and one that removed it for an SDK backend. The REST project is
not left with missing dependencies or a partially removed client without an
explicit migration decision; the SDK-backed project completes the sync without
REST code or configuration returning. Both projects can analyze and run after
following the applicable migration path.

**Decision and driving constraint:** Compatibility is provided through a
documented, deliberate migration rather than by keeping the old REST baseline
indefinitely or automatically deleting downstream code. The driving constraint
is template sync friendliness without destructive assumptions: active REST
projects have user-owned behavior worth protecting, but preserving dormant
defaults would perpetuate the divergence this change exists to remove.

**Alternatives considered:** Maintaining the old base indefinitely for existing
REST consumers was rejected because it prevents the starter from becoming
neutral. Automatically removing or transforming every downstream REST use was
rejected because the template cannot safely infer whether customized networking
code is still required. Providing no migration contract was rejected because a
baseline change of this breadth would otherwise fail unpredictably for projects
that accepted the original reference stack.

**Tradeoffs:** Active REST adopters must make and review a one-time migration
choice, and the template does not promise that their old copied infrastructure
evolves automatically forever. This favors a clean long-term baseline and safe,
visible change over zero-effort compatibility with an architecture the starter
no longer selects by default.

§req:success-criteria, §req:user-stories, §req:quality-attributes,
§req:constraints, §req:priorities
