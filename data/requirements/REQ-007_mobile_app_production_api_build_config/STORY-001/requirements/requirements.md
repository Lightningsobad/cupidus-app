# Story Requirements: STORY-001 Production API Build Flavor For Mobile App

## Identity

- Parent requirement: REQ-007_mobile_app_production_api_build_config
- Story master: `data/requirements/REQ-007_mobile_app_production_api_build_config/STORY-001/story_master.md`
- Complexity: standard
- Implementation lane: mobile-dev

## Actor / Capability / Business Value

- Actor: Internal team member building/installing the mobile app (end users benefit indirectly once a production build is distributed).
- Capability: Build the existing Flutter mobile app (REQ-001) against a second, "production" configuration/flavor whose API base URL points at the live production API (`api.cupidus.app`), while the existing local-dev build configuration continues to work unchanged.
- Business value: Makes it possible to produce and validate a mobile app build that talks to the real production backend, unblocking any future production distribution of the app.

## Acceptance Criteria

1. A second build configuration/flavor named "production" exists for the Flutter app, using Flutter's standard flavor/`--dart-define` mechanism (not a bespoke config system), whose API base URL resolves to `api.cupidus.app`.
2. The existing local-dev build configuration/flavor still builds and runs exactly as before this story — no behavior change to the local-dev API base URL or build path.
3. The production-flavor build is built and installed on a real emulator/simulator (not just compiled) and is observed making a live network call that resolves to `api.cupidus.app`.
4. The local-dev-flavor build is built and installed on a real emulator/simulator (or otherwise confirmed per the mobile-dev runtime verification gate) and is observed still calling the local-dev API, confirming the production flavor did not silently change or leak into the local-dev configuration.
5. Selecting which flavor to build is a build-time decision (e.g. flavor name or `--dart-define` value passed at build time), not a runtime toggle exposed anywhere in the app UI.

## Business Rules / Guardrails

- Additive only: the existing local-dev build path must keep working unchanged; this story introduces a second configuration, it does not replace or cut over the first.
- Use Flutter's standard flavor/`--dart-define` mechanism per bootstrap ADR-009 / System Architecture Memory, unless Tech Lead records an explicit reason to diverge.
- Depends on REQ-005 (`api.cupidus.app` live) — already DONE, so this story is unblocked.

## Edge Cases / Failure Modes

- Production build must not silently fall back to, or accidentally call, the local-dev API base URL (e.g. due to a missing/misconfigured build-time value defaulting to local dev).
- Local-dev build must remain unaffected by the addition of the production flavor/config (no shared mutable config state that could leak the production URL into a local-dev build or vice versa).

## Out of Scope

- Changes to the production API itself (REQ-005, already DONE).
- App store distribution, release signing, or CI/CD pipeline changes.
- Any new user-facing feature or UI change.
- A staging build flavor (only local vs. production was requested).

## Open Question Impact

### Scope Items BLOCKED in this story

- None.

### Scope Items NOT BLOCKED in this story

- All scope items (AC 1-5) are not blocked. req_master.md carries one non-blocking implementation note (API base URL mechanism: flavor vs. `--dart-define`) to be confirmed by Tech Lead during story planning; it does not block product scope definition.
