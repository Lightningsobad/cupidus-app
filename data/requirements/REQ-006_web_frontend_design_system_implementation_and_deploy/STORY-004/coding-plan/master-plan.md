# Master Coding Plan – Pairing Invite Landing Page

## 1. Planning Metadata

- Story ID: STORY-004 (REQ-006)
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes; the page is static markup inside an
  already-configured Astro workspace.

## 2. Planning Goal

- Shared contract owner: STORY-001 (`web/` shell, tokens, routes) — consumed
  read-only, not produced here.
- Contract-first phase required: NO — this story publishes no contract; it is a
  single frontend lane with one specialist and no in-story consumer.
- Parallel execution possible: NO — one lane, one phase.
- Critical path: P1.
- Parallelism notes: the six planned files are one behavior cluster (one page
  body) and all six sections land in the same `share.astro` composition, so
  splitting would separate phases that write the same file.

## 4. Lane Summary

- Impacted runtime services/apps:
  - `web-frontend`: `frontend`, startup smoke `NOT_APPLICABLE` for the
    implementation phase, command/source runtime registry `web-frontend`
    (`buildCommand: npm run build`, `checkCommand: npm run check`,
    `devCommand: npm run dev`). Node >= 22.12.0 is required by
    `engines.note`; the ambient default is v20, so the build must run under a
    pinned Node 22.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Frontend Developer | Frontend | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-invite-page-body-and-entry-point.md` |

Artifact hygiene:

- Each phase id above maps to exactly one canonical `phase-Px-*.md` file.
- P1 holds roughly six source files, which fits one specialist lifecycle; no
  split is required and none is planned.
- No standalone contract phase exists — there is no contract to publish.
- No trailing verification/testing phase exists; P1 owns its own targeted
  checks and build/type-check.
- P1's test scope excludes backend e2e, Playwright/browser e2e, traces,
  scenario reruns, repository-root local script gates, and runtime startup
  smoke.

## 6. Notes

- P1 is also the entry-point phase. The `/share` route file and the header's
  "Invite" nav item already exist from STORY-001, so entry-point work here is
  filling the route body and proving reachability from the nav, not creating a
  route or a nav item (AC-1).
