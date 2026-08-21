# Master Coding Plan – About & Press Kit Page

## 1. Planning Metadata

- Story ID: STORY-006
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret, or
  third-party integration changes; the press-kit asset ships inside the existing
  static build output.

## 2. Planning Goal

- Shared contract owner: STORY-001 (`../../STORY-001/architecture/contract-summary.md`),
  consumed unmodified. This story publishes no contract.
- Contract-first phase required: NO — single lane, single specialist, sequential
  phases; there is no contract to hand across a lane or repo boundary.
- Parallel execution possible: NO
- Critical path: P1 → P2
- Parallelism notes: both phases write `web/src/pages/about.astro`, so they are
  sequential by construction. The split is a sizing split, not a lane split.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| About page visual fidelity (AC-10) | P1 + P2 (full-page gate; runs at the requirement UI-lane review, not per phase) |
| VI/EN copy fidelity (AC-11) | per phase, over the sections that phase renders |
| Shell immutability (contract-summary §6) | per phase |
| Press-kit download target (AC-8) | P2 |
| Per-page title (AC-9) | P1 |
| Build/type integrity on pinned Node | per phase |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `web-frontend`: `frontend`, startup smoke `NOT_APPLICABLE` for implementation
    phases — the rendered check that AC-10 needs is the requirement UI-lane
    review gate, not a phase-level smoke. Build/check commands come from the
    runtime registry (`buildCommand` `npm run build`, `checkCommand`
    `npm run check`, `installCommand` `npm ci`), run from `web/` on Node >=22.12.0.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Frontend Developer | Frontend | None | NO | NOT_STARTED |
| P2 | Frontend Developer | Frontend | P1 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-about-core-sections.md` |
| P2 | `phase-P2-timeline-team-press-kit.md` |

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

- P1 is this story's entry-point phase. The `/about` route, the header "About"
  nav item, and the footer "Press kit" link already exist and already point here
  (STORY-001); P1 is what makes the route render a real page instead of an empty
  shell, so the capability is discoverable from the moment P1 lands.
- The nine deliverables are split 6/5 rather than shipped as one phase because
  one phase would exceed a single specialist lifecycle. P2's five press-kit
  asset files count as one bundle deliverable, not five source files.
