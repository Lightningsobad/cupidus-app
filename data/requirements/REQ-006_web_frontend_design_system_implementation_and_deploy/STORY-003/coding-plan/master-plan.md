# Master Coding Plan – Zodiac Compatibility Preview Page (REQ-006 / STORY-003)

## 1. Planning Metadata

- Story ID: STORY-003
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes; the page is static content in an existing
  static build.

## 2. Planning Goal

- Shared contract owner: Frontend Developer (P1 owns `web/src/data/zodiac.ts`
  and `ZodiacIcon.astro`, which P2 consumes)
- Contract-first phase required: NO — the same specialist implements the data
  module, the icon, and every in-story consumer in sequence in one lane, so the
  contract is folded into P1 alongside its first two consumers.
- Parallel execution possible: NO — P2 imports P1's data module and icon.
- Critical path: P1 -> P2
- Parallelism notes: single lane, strictly sequential. The split exists only
  because the story's 7 source files exceed one specialist lifecycle.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Zodiac glyph fidelity | P1 |
| Fixed-count sections (AC-4/5/6) | P1 (12 signs, 4 elements), P2 (6 leaderboard rows) |
| Bilingual span completeness | P1 and P2 |
| Shell immutability under parallel merge | P1 and P2 |
| Per-page `<title>` (AC-9, DEF-2) | P2 |
| Rendered visual fidelity (AC-10) | P2 (all five sections must be present before the requirement-level audit can run) |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `web`: `frontend`, runtime registry id `web-frontend`, startup smoke
    `NOT_APPLICABLE` (static Astro build; no service is started by either
    phase), build command source runtime registry `buildCommand`
    (`npm run build`) and `checkCommand` (`npm run check`), run from `web/` on
    Node >= 22.12.0 per the registry `engines.note`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Frontend Developer | Frontend | None | NO | NOT_STARTED |
| P2 | Frontend Developer | Frontend | P1 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-zodiac-data-icon-and-sign-directory.md` |
| P2 | `phase-P2-zodiac-page-assembly-and-entry-point.md` |

Artifact hygiene:

- Each phase id above maps to exactly one canonical `phase-Px-*.md` file.
- Backend/frontend/mobile implementation phases must fit one specialist
  lifecycle (roughly six source/test files max) or be split. P1 writes 4 files,
  P2 writes 3; the story's 7 total files do not fit one lifecycle, which is the
  only reason two phases exist.
- No trailing verification/testing phase exists; each phase owns its own
  build/type-check and dist assertions, recorded in `test-results.md`.
- Implementation phase test scopes exclude Playwright/browser e2e, traces,
  scenario reruns, repository-root local script gates, and runtime startup
  smoke.

## 6. Notes

- P2 is the entry-point phase: `/zodiac` and its header/footer nav items already
  exist from STORY-001, so P2's discoverability duty is to fill the route body
  and prove the existing nav path reaches the rendered page (AC-1) — not to add
  a nav item, which the STORY-001 contract forbids.
- AC-10 is verified once at the requirement level
  (`frontend-dev` `Mode: requirement-visual-audit`), not inside either phase.
