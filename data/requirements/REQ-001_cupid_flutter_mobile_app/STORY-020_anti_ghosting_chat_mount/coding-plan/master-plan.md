# Master Coding Plan – STORY-020 Anti-Ghosting Chat Mount

## 1. Planning Metadata

- Story ID: STORY-020
- Complexity: XS
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes.

Input deviation: this story has no `../requirements/requirements.md`. It is a
retro-audit RED-PATCH whose scope and single AC live directly in
`../story_master.md`; phases read that file in its place.

## 2. Planning Goal

- Shared contract owner: none — this story consumes the existing
  `GhostStateRow(partnerId:)` seam published by STORY-008.
- Contract-first phase required: NO
- Parallel execution possible: NO
- Critical path: P1 is the whole story.
- Parallelism notes: single lane, single phase.

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` for the
    implementation phase, command/source `data/devops/system/runtime-command-registry.json`.
    Running-app evidence for AC1 is collected through the phase's mobile
    visual audit, not through a phase-level startup smoke gate.

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-mobile-chat-ghost-state-mount.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- No duplicate files exist for a phase id.
- P1 writes two source/test files, well inside the roughly-six-file
  specialist lifecycle cap; no split required.
- No standalone contract phase exists; there is no cross-lane contract.
- No trailing verification/testing phase exists; P1 owns its own tests and
  static analysis.
- P1's test scope excludes backend e2e, Playwright/browser e2e, mobile e2e,
  traces, and scenario reruns.
