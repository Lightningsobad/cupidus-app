# Master Coding Plan – Support FAQ Page

## 1. Planning Metadata

- Story ID: STORY-007 (REQ-006)
- Complexity: standard
- OQ Constraints Source: `../requirements/requirements.md` `## Open Question Impact`
  (OQ-REQ006-1 and OQ-REQ006-2 both RESOLVED; no scope is blocked in this story)
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes; the page is static markup only.

## 2. Planning Goal

- Shared contract owner: STORY-001 (`web/` shell, tokens, routes). This story is
  a pure consumer and publishes no contract of its own.
- Contract-first phase required: NO — the only contract involved was authored
  and merged by STORY-001; nothing in this story is produced for another lane.
- Parallel execution possible: NO — single frontend lane, single file.
- Critical path: P1.
- Parallelism notes: none. Splitting the header, FAQ list, and contact block
  into separate phases would split one behavior cluster that writes one file.

## 4. Lane Summary

- Impacted runtime services/apps:
  - `web-frontend`: `frontend`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `web-frontend` (`buildCommand: npm run build`,
    `checkCommand: npm run check`, `devCommand: npm run dev`). Requires Node
    >=22.12.0 per the registry `engines` note; the machine default node is
    v20.20.2, so use the pinned toolchain, never ambient `node`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Frontend Developer | Frontend | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-support-faq-page.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Backend/frontend/mobile implementation phases must fit one specialist
  lifecycle (roughly six source/test files max) or be split. P1 writes one
  source file and is far inside that cap.
- No trailing verification/testing phase exists; P1 owns its own build,
  type-check, rendered checks, and visual audit evidence.
- P1 is the entry-point phase: it is what makes the existing `/support` route
  render real content reachable from the header and footer links.

## 6. Notes

- P1 is blocked from producing AC-6 evidence until the requirement-level
  design-source fidelity lock is repointed from `Cupid App.dc.html` to
  `Cupid Web.dc.html` (`../../req_master.md`, Technical Constraints,
  Design-Source line). That repoint is not this story's work; if it has not
  happened when P1 reaches its visual audit, stop and report rather than audit
  against the mobile canvas.
