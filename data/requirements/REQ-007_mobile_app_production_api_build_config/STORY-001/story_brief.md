# Story Brief: STORY-001 Production API Build Flavor For Mobile App

## Identity

- Parent requirement: REQ-007_mobile_app_production_api_build_config
- Story master: `data/requirements/REQ-007_mobile_app_production_api_build_config/STORY-001/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-007_mobile_app_production_api_build_config/STORY-001/requirements/requirements.md`

## Brief

- Actor: Internal team member building/installing the mobile app (end users benefit indirectly once a production build is distributed)
- Capability: Build the Flutter mobile app against a "production" flavor/configuration that points at the live production API (`api.cupidus.app`), alongside the existing local-dev build, and confirm via a real emulator/simulator run that the production build actually talks to `api.cupidus.app` rather than local dev.
- Business value: Makes it possible to produce and validate a mobile app build that runs against the real production backend, unblocking any future production distribution of the app.
- Key business rules or guardrails: Additive only — existing local-dev build path must keep working unchanged; use Flutter's standard flavor/`--dart-define` mechanism, not a bespoke config system, unless Tech Lead records an explicit reason to diverge.
- Key edge or failure case: Confirm the production build does not silently fall back to or accidentally call the local-dev API; confirm the local-dev build is unaffected by the new flavor/config.
- Existing system entry / discoverability seed: Not user-facing UI — this is a build-time configuration selected by whoever builds the app (developer/build tooling), not discovered through the app's own UI.
- Complexity: standard
- Why this complexity: Single mobile-only lane, additive change using a standard Flutter mechanism, but touches build configuration/environment plumbing and requires real-device validation, so it is more than trivial.
- Implementation lane seed: mobile-dev
- Depends on: REQ-005 (`api.cupidus.app` must be live — already DONE)

## Direct Anchors

- Requirement AC / BR anchors: req_master.md Business Scope items 1-2; Technical Constraints (additive-only, Flutter flavor mechanism, real emulator/simulator validation, depends on REQ-005)
- Open Question anchors: None blocking — req_master.md notes the exact API base URL mechanism (flavor vs. `--dart-define`) should be confirmed during Tech Lead story planning; this is a non-blocking implementation detail
- Related story dependencies: None (single-story requirement)

## Scope Seed

### In Scope

- Second build configuration/flavor ("production") for the Flutter app using flavors/`--dart-define`.
- Production flavor's API base URL set to `api.cupidus.app`.
- Existing local-dev flavor/build path continuing to work unchanged.
- Building, installing, and running the production-flavor build on a real emulator/simulator, and confirming it calls `api.cupidus.app` rather than local dev.

### Out of Scope

- Changes to the production API itself (REQ-005, already DONE).
- App store distribution, release signing, or CI/CD pipeline changes.
- Any new user-facing feature or UI change.
- A staging build flavor (only local vs. production was requested).
