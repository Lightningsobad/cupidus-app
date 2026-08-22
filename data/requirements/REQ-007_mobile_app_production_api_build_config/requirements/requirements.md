# Requirement Breakdown: REQ-007 Mobile app production API build configuration

## Source Artifacts

- Requirement master: `data/requirements/REQ-007_mobile_app_production_api_build_config/req_master.md`
- Additional input files: None
- Existing related requirement artifacts: REQ-001 (mobile app, local-dev build baseline), REQ-005 (production domain `api.cupidus.app`, DONE)

## Context Summary

- Request summary: Add a production build flavor to the existing Flutter mobile app so it can point at the live production API (`api.cupidus.app`) instead of only the local-dev API, without breaking the existing local-dev build path, and validate the production build on a real emulator/simulator.
- Primary actors: Internal team members who build/install the production-flavor app; mobile app end users benefit indirectly once such a build is distributed.
- Problem to solve: The mobile app currently only builds against local dev, so there is no way to produce and validate a build that actually talks to the live production API.
- Business outcome: A build of the mobile app can be produced that connects to `api.cupidus.app`, confirmed via a real emulator/simulator run, while the existing local-dev build continues to work unchanged.
- Success signal: A production-flavor build is built, installed on an emulator/simulator, and observed making calls to `api.cupidus.app` (not local dev); the existing local build still works.
- Notes on current project context: Depends on REQ-005 (`api.cupidus.app` live), which is DONE. Mobile stack is Flutter per bootstrap ADR-009 / System Architecture Memory.

## Scope Decision

### In Scope

- A second build configuration/flavor ("production") using Flutter's standard flavor/`--dart-define` mechanism.
- The production flavor pointing to `api.cupidus.app` as its API base URL.
- Keeping the existing local-dev build flavor/path working unchanged (additive only).
- Building and installing the production-flavor build on a real emulator/simulator and confirming it talks to `api.cupidus.app` rather than local dev.

### Out of Scope

- Any change to the production API itself (covered by REQ-005, DONE).
- App store / production release distribution, release signing, or CI/CD pipeline changes for the mobile app (not requested).
- Any new user-facing feature or UI change in the app.
- A staging build flavor (only local vs. production was requested).

### Business Rules And Guardrails

- Must not break or replace the existing local-development build path — additive (two build configs), not a cutover.
- Must use Flutter's standard flavor/environment mechanism (flavors / `--dart-define`) rather than a bespoke config system, unless Tech Lead records an explicit reason to diverge.
- Validation must be a real emulator/simulator run of the production-flavor build confirming production API connectivity, not just a successful compile.

## Open Question Triage

| OQ ID | Status | Scope Items BLOCKED | Scope Items NOT BLOCKED | Decision |
|-------|--------|---------------------|------------------------|----------|
| N/A | — | None | All scope | req_master.md records no central-registry OQ id for this requirement — only a Tech-Lead-facing implementation note that the exact API base URL mechanism (flavor vs. `--dart-define`) should be confirmed during Tech Lead story planning. This is a non-blocking implementation detail, not a scope blocker. |

### OQs reviewed but not applicable to this requirement

- None — no central-registry OQ ids reference this requirement.

## Seed To Story Mapping

Not applicable — this requirement carries no `## Story Seeds` table from discovery.

### Distinct user outcomes in this requirement

1. A build of the mobile app that connects to the production API (`api.cupidus.app`), confirmed working via a real emulator/simulator run, while the existing local-dev build keeps working.

## Coverage Map

| Requirement / Need | Planned Story ID(s) | Notes |
|--------------------|---------------------|-------|
| Add production build flavor/config pointing at `api.cupidus.app` | STORY-001 | |
| Keep local-dev build path working | STORY-001 | Same slice — additive constraint on the same change, not a separate outcome |
| Validate production build on real emulator/simulator | STORY-001 | Built into the delivery slice's own mobile-dev verification/visual-runtime-audit gate, not a separate story (see below) |

## Recommended Story Sequence

| Story ID | Title | Complexity | Depends On | Why This Order | Observable After This Story |
|----------|-------|------------|------------|----------------|-----------------------------|
| STORY-001 | Production API build flavor for mobile app | standard | None | Single delivery slice: an unvalidated build-config change has no standalone stakeholder value, so the build mechanism and its real-device validation are one story, not two | A production-flavor build of the mobile app exists, installs on a real emulator/simulator, and is confirmed talking to `api.cupidus.app`; the existing local-dev build still works unchanged |

Validation was intentionally **not** split into its own story. `story-organization.md`
explicitly lists a dedicated testing/verification/"visual audit" story as an
anti-pattern, since every story already carries its own lane verification
(mobile-dev visual/runtime audit gate) as part of the same delivery slice, and
an unvalidated build-config change fails the standalone-value gate on its own.

## Story Index

| Story ID | Title | Brief File | Primary Scope | Key AC/OQ Anchors |
|----------|-------|------------|---------------|-------------------|
| STORY-001 | Production API build flavor for mobile app | `data/requirements/REQ-007_mobile_app_production_api_build_config/STORY-001/story_brief.md` | Add production build flavor pointing at `api.cupidus.app`, keep local-dev build working, validate on real emulator/simulator | req_master.md Business Scope items 1-2; Technical Constraints (additive-only, Flutter flavor mechanism, real-device validation, depends on REQ-005) |
