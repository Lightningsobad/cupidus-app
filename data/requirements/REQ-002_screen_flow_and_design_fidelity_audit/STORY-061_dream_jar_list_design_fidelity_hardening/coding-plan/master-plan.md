# Master Coding Plan – STORY-061 Dream Jar List Design Fidelity Hardening

## 1. Planning Metadata

- Story ID: STORY-061_dream_jar_list_design_fidelity_hardening
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (single lane).
- Contract-first phase required: NO — the only shared shape
  (`DreamJarListReady`'s active/completed split) is produced and consumed by the
  same specialist in the same phase, so it is folded into P1 per the contract
  phase condition.
- Parallel execution possible: NO — one lane, and P2 owns the combined AC1-AC8
  visual audit that requires P1's surface to already be present.
- Critical path: P1 -> P2.
- Parallelism notes: P1 and P2 touch disjoint files, but P2's AC9 evidence pair
  must depict AC1-AC7 as well, so P2 runs second.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Summary-pill / completed-row data split | P1 |
| Shell destination regression | P2 |
| Gallery entry-point orphaning | P2 (same phase as the tab-set change) |
| Preview/production shell divergence | P2 |
| Design-reference conformance (AC9) | P1 and P2 both landed |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (no phase changes
    app startup, DI registration, or native config), command/source runtime
    registry id `mobile-app` in `data/devops/system/runtime-command-registry.json`

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-jarlist-screen-fidelity.md` |
| P2 | `phase-P2-five-tab-shell.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- AC1-AC7 are one phase, not seven: they are a single behavior cluster (the
  `jarlist` ready-state composition) and all but the ARB edits land in
  `dream_jar_list_screen.dart`. Splitting them would split one file across
  phases, which the phase-sizing rule forbids.
- Backend/frontend/mobile implementation phases must fit one specialist
  lifecycle (roughly six source/test files max) or be split.
- No trailing verification/testing phase exists; each phase owns its own
  targeted tests and build/analysis.

## 6. Notes

- AC10 requires no phase. Its corrected disposition is written in
  `../architecture/solution.md` §3 ("AC10 disposition"). Reviewer should verify
  AC10 against that text, not against AC10's original wording, which asserts a
  runtime shape the code did not have — see `solution.md` `### Key Discovery`
  item 2.
- P2 carries a scope addition Product Owner did not pre-authorize: a Gallery
  entry card on `HomeScreen`. It exists only to stop AC8 from orphaning the
  shipped epic-4 gallery, whose sole production entry point is the tab AC8
  removes (`solution.md` `### Key Discovery` item 3).
