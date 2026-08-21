# Master Coding Plan – STORY-008 Privacy & Terms Page

## 1. Planning Metadata

- Story ID: STORY-008
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes; the page is fully static.

## 2. Planning Goal

- Shared contract owner: STORY-001 (`../../STORY-001/architecture/contract-summary.md`),
  already merged. This story produces no new cross-lane contract.
- Contract-first phase required: NO — single lane, single specialist, and the
  only contract involved is an already-merged upstream one.
- Parallel execution possible: NO — the whole story is one file.
- Critical path: P1.
- Parallelism notes: none within the story.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Verbatim bilingual legal copy | P1 |
| Rendered visual fidelity | P1 |
| Shell immutability | P1 |
| Per-page localized `<title>` (AC-5) | P1 |
| Entry-point reachability (AC-1) | P1 |
| Heading and landmark semantics | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `web-frontend`: `frontend`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `buildCommand` = `npm run build`, `checkCommand` =
    `npm run check` (both run from `web/`, Node >= 22.12.0).

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Frontend Developer | Frontend | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-legal-page-body-and-entry-point.md` |

Artifact hygiene:

- Each phase id above maps to exactly one canonical `phase-Px-*.md` file.
- P1 writes one source file, well inside the roughly-six source/test file cap for
  one specialist lifecycle; no split applies.
- No standalone contract phase exists: the only contract is upstream and merged.
- No trailing verification/testing phase exists; P1 owns its own test scope.
- P1's test scope excludes Playwright/browser e2e, traces, scenario reruns,
  repository-root local script gates, and runtime startup smoke.

## 6. Notes

- P1 is the story's entry-point phase in the sense of the frontend entry-point
  rule: the `/legal` route and both footer "Legal" links already exist from
  STORY-001, so the wiring work is filling that already-discoverable target and
  proving reachability from the footer, not adding a new navigation surface.
  Adding a header nav item would be a fidelity regression, not an improvement.
- The requirement-level rendered visual audit
  (`Mode: requirement-visual-audit`, `req_master.md` Technical Constraints) runs
  once at requirement scope and is not this phase's gate; P1 still owns the
  story-scoped visual inspection listed in its test scope.
