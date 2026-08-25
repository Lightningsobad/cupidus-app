# Master Coding Plan – Home Header Share Days-Together Action

## 1. Planning Metadata

- Story ID: STORY-004
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — the change adds one
  Flutter package; no env var, secret, or configured third-party endpoint.

## 2. Planning Goal

- Shared contract owner: none — single mobile lane, no cross-lane consumer.
- Contract-first phase required: NO — one specialist writes the dependency and
  its only consumer back to back in one lane.
- Parallel execution possible: NO
- Critical path: P0
- Parallelism notes: single phase; nothing to parallelize.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Unverified third-party API shape | P0 |
| Native plugin breaks app launch | P0 (gate runs after the phase's debug build is installed on a device) |
| Share payload correctness across locale and null-days | P0 |
| Header layout regression | P0 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `REQUIRED`, command/source runtime
    registry `mobile-app` (`runCommand` / `scripts/run-mobile.sh`, Flutter SDK
    resolved via `FLUTTER_SDK_PATH`, default `$HOME/flutter`). Smoke is REQUIRED
    because this story adds the app's first native plugin, and plugin
    registration failures surface only at app launch — never in `flutter test`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-home-header-share-action.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- Backend/frontend/mobile implementation phases must fit one specialist
  lifecycle (roughly six source/test files max) or be split. P0 writes 4 files
  (plus at most 2 conditional native manifests) and fits one lifecycle.
- No standalone contract phase exists: the dependency addition and its only
  consumer share the same owner and lane in sequence.
- No trailing verification/testing phase exists.
- Implementation phase test scope excludes e2e, Playwright, traces, and runtime
  startup smoke.

## 6. Notes

- The dependency addition and the UI change are deliberately kept in ONE phase.
  Splitting them would produce a phase whose entire output is a single
  `pubspec.yaml` line, and would let a build pass while nothing consumes the
  plugin — hiding exactly the plugin-registration failure the startup smoke
  exists to catch.
- STORY-005 (`goNotifs`) will append a second child to the header actions row
  this phase creates, in the same `home_screen.dart` file. If both stories run in
  the same wave, expect a merge touchpoint on that file.
