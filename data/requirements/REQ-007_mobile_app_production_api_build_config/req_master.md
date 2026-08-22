# Requirement Master: REQ-007 Mobile app production API build configuration
Status: DONE

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Business Scope

The existing Flutter mobile app (REQ-001) currently only builds against the
local development API. The user wants the mobile app to be able to point at
the production API set up under REQ-005 (`api.cupidus.app`), while keeping
the current local-dev workflow intact. Concretely:

1. Add a second build configuration/flavor ("production") alongside the
   existing local build, so the app can be built either against local dev
   or against the production API domain.
2. Validate the production-flavor build on an emulator/simulator (build,
   install, and confirm it actually talks to `api.cupidus.app` rather than
   local dev).

## Technical Constraints

- Depends on REQ-005: `api.cupidus.app` must be live and reachable before
  the production build flavor can be meaningfully validated end-to-end.
- Must not break or replace the existing local-development build path;
  this is additive (two build configs), not a cutover.
- Mobile stack is Flutter (per bootstrap ADR-009 / System Architecture
  Memory) — use Flutter's standard flavor/environment mechanism (e.g.
  `--dart-define` / flavors) rather than inventing a bespoke config system,
  unless Tech Lead records an explicit reason to diverge.
- Validation must be a real emulator/simulator run of the production-flavor
  build (per the requirement-level `mobile-dev` visual/runtime audit gate),
  not just a successful compile.

## Dependencies

- Depends on REQ-005 (production domain + CI/CD standardization) for a live
  `api.cupidus.app` target to build and validate against.

## Open Questions

- None yet; API base URL should simply become an environment/build-time
  value (`local` vs `production`) — confirm exact mechanism during Tech
  Lead story planning.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Production API build flavor for mobile app | standard | DONE | data/requirements/REQ-007_mobile_app_production_api_build_config/STORY-001/story_master.md |
