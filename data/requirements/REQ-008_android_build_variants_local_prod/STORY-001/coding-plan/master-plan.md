# Master Coding Plan – Android Studio Build Variants For Local/Prod Backend

## 1. Planning Metadata

- Story ID: REQ-008_android_build_variants_local_prod/STORY-001
- Complexity: standard
- Requirement Configuration Guide impact: REQUIRED — the developer-facing way to
  choose a backend target changes from a CLI `--dart-define` to an Android
  Studio Build Variant, and `pubspec.yaml` gains a `default-flavor` entry.
- Input deviation: `../ux/` is absent — UX-Spec is WAIVED in `story_master.md`
  (developer-only build tooling, no end-user surface).

## 2. Planning Goal

- Shared contract owner: Mobile Developer.
- Contract-first phase required: NO — the only shared surface is the
  flavor-name -> config mapping inside `CupidApiConfig`, and the same Mobile
  Developer writes it and all of its in-story consumers back to back in one
  lane. Per architecture solution section 4, it is folded into P0.
- Parallel execution possible: NO — single lane, single phase.
- Critical path: P0.
- Parallelism notes: none; the Gradle flavor block and the Dart default
  resolution are two halves of one build-time value chain and cannot be
  verified independently.

## 3A. Risk Surface To Phase Mapping

> Authoritative risk table: `../architecture/solution.md` section 4.

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Build Variants panel exposure (AC1) | P0 |
| Per-variant base URL resolution (AC2-AC4) | P0 |
| Existing local build path (AC5) | P0 |
| Google Sign-In package match | P0 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` for the phase
    (Reviewer/requirement-level mobile audit owns device runtime evidence),
    command/source: runtime registry `mobile-app.buildCommand`
    (`flutter build apk --debug`) and `mobile-app.testCommand` (`flutter test`).
    Note: that bare `buildCommand` is itself the AC5 regression probe once
    flavors exist, and the registry entry needs no edit.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-android-flavor-backend-selection.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- No duplicate files exist for any phase id.
- P0 holds 5 source/test/doc files, inside the roughly six-file single
  specialist lifecycle cap, so no split is required.
- No standalone contract phase exists: the same specialist implements the
  flavor-name mapping and every in-story consumer in sequence in one lane.
- No trailing verification/testing phase exists; P0 owns its own targeted tests
  and mobile build/static-analysis.

## 6. Notes

- Sequencing note planning owns: within P0, `pubspec.yaml`'s `default-flavor`
  must land in the same change as the Gradle flavor block. Between those two
  edits the repository is in a knowingly broken state — flavors exist while
  `flutter build apk --debug` still looks for the unflavored `app-debug.apk`.
  Do not commit or report the flavor block on its own.
