# Master Coding Plan – Pairing-Method Choice Screen Redesign

## 1. Planning Metadata

- Story ID: STORY-001 (REQ-012)
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (sole lane).
- Contract-first phase required: NO — the only shared artifact is the four new
  `CupidIcons` glyph constants, and their only consumer is the same specialist
  in the same lane in the same phase (`solution.md` section 4, glyph risk row).
- Parallel execution possible: NO — single phase, single lane.
- Critical path: P0.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Missing glyph codepoints | P0 |
| No-fork colour guard | P0 |
| Header badge gradient axis | P0 |
| Existing screen tests assert the old two-option shape | P0 |
| Chrome / stack-root guards | P0 |
| Stale design reference for AC4 | P0, then requirement mobile visual audit |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` at phase level
    (story-level runtime smoke is the Scrum Master gate, not this phase's).

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-pairing-choice-three-row-rebuild.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- P0 writes 4 source/test files, inside one specialist lifecycle (roughly six
  source/test files max), so no split is required.
- The glyph constants are not a separate phase: their consumers share P0's
  owner and lane in sequence.
- No trailing verification/testing phase; P0 owns its own targeted tests and
  mobile build/static-analysis.

## 6. Notes

- The screen is already mounted and discoverable (`pair_gate_shell.dart:139`,
  `service_locator.dart:423`, `main_preview.dart:221`). P0 preserves that mount
  rather than creating an entry point; the discoverability check is in P0's
  `## 6. Test Scope`.
- DECISION_REQUIRED before this story can claim full design parity: the design
  source's "later, look around first" link has no reachable destination
  (`solution.md` D1). P0 ships without it. Product Owner must confirm the
  omission or open a follow-up story for a pair-gate browse path.
