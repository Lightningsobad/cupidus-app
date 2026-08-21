# Master Coding Plan – Pet Universe Showcase Page

## 1. Planning Metadata

- Story ID: STORY-002 (REQ-006)
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes; the page is static and makes no network
  call.

## 2. Planning Goal

- Shared contract owner: Frontend Developer (`../architecture/contract-summary.md`
  — per-page `<title>` convention and page content data modules, consumed by
  STORY-003…STORY-008).
- Contract-first phase required: NO — the contract is a call-site convention plus
  one data-module export, produced and consumed by the same specialist in the
  same lane in one sitting. Isolating it would be a phase whose whole output is a
  prop value.
- Parallel execution possible: NO — single frontend lane, single phase.
- Critical path: P1.
- Parallelism notes: none. The five files in P1 are one behavior cluster (one
  page body and the components only that page mounts) and fit one specialist
  lifecycle, so splitting them would buy an extra dispatch and an extra
  verification pass for no isolation.

## 4. Lane Summary

- Impacted runtime services/apps:
  - `web-frontend`: `frontend`, startup smoke `OPTIONAL` (needed only to render
    the page for visual inspection, not as a phase gate), command/source runtime
    registry `devCommand` = `npm run dev`, build `npm run build`, check
    `npm run check`; port from `DEVSTACK_PORT_WEB` in `.env.devstack`, never
    Astro's default 4321.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Frontend Developer | Frontend | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-pets-page-body-and-entry-point.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- P1 writes five source files, within the roughly-six-file specialist lifecycle
  cap; no split required.
- No standalone contract phase, no trailing verification phase.
- P1's test scope excludes Playwright/browser e2e, traces, scenario reruns,
  repository-root local script gates, and runtime startup smoke.

## 6. Notes

- P1 is also the entry-point phase: the `pets` route and all four navigation
  affordances (header pill, mobile `<select>`, footer link, Home's "Meet them
  all" CTA) already exist from STORY-001, so wiring means passing `page="pets"`
  so the active-nav treatment fires, and proving the route now resolves to real
  content instead of an empty stub. There is no second surface to mount.
- The requirement-level `frontend-dev` `Mode: requirement-visual-audit` and the
  full UI-lane review gate still run after this story; P1's visual inspection
  does not substitute for either.
