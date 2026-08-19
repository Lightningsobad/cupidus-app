# Master Coding Plan – Chat Header Arrow Glyph Rendering Hardening

## 1. Planning Metadata

- Story ID: STORY-058_chat_header_arrow_glyph_rendering_hardening
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes.

## 2. Planning Goal

- Shared contract owner: none. `CupidHeader.title` stays a plain `String` on
  both remedy paths, so no cross-lane contract is produced or consumed.
- Contract-first phase required: NO
- Parallel execution possible: NO
- Critical path: P0 (single phase).
- Parallelism notes: single-lane mobile story; the glyph fix, its test-literal
  updates, the device capture, and the AC6 doc correction are one behavior
  cluster inside one specialist lifecycle.

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` for the phase test
    gate — AC1/AC4 require an on-device build/install/capture, which is planned
    as the requirement mobile visual audit in `phase-P0` section 6, not as a
    startup-smoke gate. Command source: runtime registry `buildCommand`
    (`flutter build apk --debug`) and `launch.path` (`scripts/run-mobile.sh`).

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-separator-glyph-remedy.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- Mobile implementation phases must fit one specialist lifecycle (roughly six
  source/test files max) or be split. P0 writes at most four source/test files.
- No trailing verification/testing phase exists; P0 owns its own targeted tests
  and static analysis.

## 6. Notes

- P0 is deliberately a decision tree, not a fixed edit list: `## 3. Tasks` runs a
  static font-coverage check first and selects Path A or Path B from its result,
  because a wrong first guess costs a full build/install/capture cycle. The
  phase's write scope is the union of both paths; the executed path decides
  which files are actually touched, and the phase records which one was used.
