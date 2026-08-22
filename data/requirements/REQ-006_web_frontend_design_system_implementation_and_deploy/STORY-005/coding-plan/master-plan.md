# Master Coding Plan – STORY-005 Cupid Journal Blog Page

## 1. Planning Metadata

- Story ID: STORY-005 (REQ-006)
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes; the page is compile-time static.

## 2. Planning Goal

- Shared contract owner: STORY-001 (`../../STORY-001/architecture/contract-summary.md`);
  this story only consumes it.
- Contract-first phase required: NO — single frontend lane, single specialist,
  no in-story contract published to another lane or repository.
- Parallel execution possible: NO — one phase.
- Critical path: P1.
- Parallelism notes: the three files in P1 are written by one specialist in one
  pass; splitting them would cost a second dispatch and a second verification
  pass to re-prove the same page.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Rendered visual fidelity | P1 complete; rendered reference from `render-design-canvas.js --screen=blog` available to the review gate |
| Bilingual copy fidelity | P1 complete |
| Shell immutability | P1 diff reviewed against `BaseHead` |
| False interactive promise | P1 complete |
| Per-page title (AC-9) | P1 complete |
| Node engine floor | Pinned Node >=22.12.0 selected before P1's build commands |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `web-frontend`: `frontend`, startup smoke `NOT_APPLICABLE` for the
    implementation phase, command/source runtime registry `web-frontend`
    (`buildCommand: npm run build`, `checkCommand: npm run check`,
    `devCommand: npm run dev`), run from `web/`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Frontend Developer | Frontend | None | NO | NOT_STARTED |

P1 is also this story's entry-point phase: it mounts the page body into the
already-live `/blog` route and verifies the header nav's "Blog" item reaches it
with the active treatment, so the capability is discoverable rather than
direct-URL-only.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-blog-page-body.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file; no
  duplicates exist.
- The frontend implementation phase fits one specialist lifecycle (roughly six
  source/test files max); P1 writes three.
- No standalone contract phase exists: the consumed contract belongs to
  STORY-001 and this story publishes none.
- No trailing verification/testing phase exists; P1 owns its own targeted
  checks and build/type-check.
- P1's test scope excludes backend e2e, Playwright/browser e2e, traces,
  scenario reruns, repository-root local script gates, and runtime startup
  smoke.

## 6. Notes

- The AC-7 review gate is a story-exit dependency, not a P1 task: the full
  UI-lane gate is already configured (`design_source.entry: "Cupid Web.dc.html"`,
  `locked: true`, `ui_surface: true` in
  `data/devops/system/design-fidelity-config.json`). Producing the rendered
  reference (`render-design-canvas.js --screen=blog`) is review/DevOps tooling
  work; if it is unavailable, the story stops at the gate rather than in P1.
