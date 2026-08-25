# Master Coding Plan – Pet Preview Card Design Fidelity

## 1. Planning Metadata

- Story ID: STORY-003 (REQ-010)
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — the new
  `PREVIEW_PET_FIXTURE` dart-define is a local capture-harness switch on the
  `main_preview` entrypoint, not a deployed environment variable or secret.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (single lane, no cross-lane contract).
- Contract-first phase required: NO — the only new interface is one optional
  `HomeScreen` parameter, and the same specialist writes it and its single
  consumer in sequence.
- Parallel execution possible: NO
- Critical path: P1 is the whole story.
- Parallelism notes: none; one mobile lane, one dispatch.

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app` in
    `data/devops/system/runtime-command-registry.json`. The story's rendered
    evidence comes from the design-fidelity preview capture (`main_preview`
    entrypoint with `--dart-define=PREVIEW_PET_FIXTURE=true`), which is a mobile
    visual audit, not a startup-smoke gate.

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-pet-preview-card-fidelity-and-fixture.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Backend/frontend/mobile implementation phases must fit one specialist lifecycle
  (roughly six source/test files max) or be split. State this cap as "roughly
  six"; do not restate it as a smaller number.
- No two phases are separated only because they would write the same file, and
  no phase repeats a sibling phase's pattern for another variant of the same
  behavior cluster while both fit one lifecycle.
- No standalone contract phase exists when the same specialist implements the
  contract and all of its in-story consumers in sequence in one lane.
- No trailing verification/testing phase exists; each implementation phase owns
  its own targeted tests and build/type-check.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, traces, or scenario reruns.

## 6. Notes

- The visual corrections and the fixture path are one phase on purpose: AC1's
  rendered comparison is only capturable once the fixture resolves the card to
  `PetReady`, so splitting them would leave the first phase unable to produce
  its own evidence and force a second verification pass over the same five
  files.
