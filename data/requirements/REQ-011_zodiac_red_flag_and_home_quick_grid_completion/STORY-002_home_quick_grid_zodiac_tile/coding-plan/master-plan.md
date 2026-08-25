# Master Coding Plan – Home Dashboard Quick Grid (Zodiac Red Flag Tile)

## 1. Planning Metadata

- Story ID: STORY-002_home_quick_grid_zodiac_tile
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  dependency, or third-party integration changes.

## 2. Planning Goal

- Shared contract owner: none — single mobile lane; the only consumed contract
  (`ZodiacRedFlagScreen.routeName`) is already shipped by STORY-001.
- Contract-first phase required: NO — the one shared symbol added here
  (`CupidIcons.autoAwesome`) has exactly one consumer, in the same lane, written
  by the same specialist in sequence; it is folded into P1.
- Parallel execution possible: NO
- Critical path: P1
- Parallelism notes: single phase, single specialist lifecycle (4 files).

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app.testCommand` (`flutter test`) and
    `mobile-app.buildCommand`; the Flutter SDK is resolved via
    `FLUTTER_SDK_PATH` (default `$HOME/flutter`), not a bare `flutter` on PATH.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-home-quick-grid-zodiac-tile.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- P1 fits one specialist lifecycle (roughly six source/test files max): 2 source
  files + 2 test files.
- No trailing verification/testing phase exists; P1 owns its own targeted tests
  and mobile build/static-analysis gate.
- P1's test scope excludes backend e2e/test_e2e, Playwright/browser e2e, mobile
  e2e, emulator/simulator lifecycle, signing, store gates, and runtime startup
  smoke.

## 6. Notes

- P1 is also the entry-point phase: the capability's discoverable surface (the
  Zodiac Red Flag tile inside the already-reachable Home quick grid) is wired in
  the same phase that builds it. No route or shell change is needed — AC3.
