# Scope Gate — REQ-006 / STORY-002 Pet Universe Showcase Page (re-review)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: `full-story-review` (fresh re-review, RunId
  `RUN-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-002-reviewer2`)
- Review report path:
  `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/review/review-report.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-002`
- Diff baseline: `2e72902de51910c18ca1c6e8ca31faeedc14d823` (full story diff:
  20 files, of which 5 are source)
- Complexity: `standard`; Implementation Lane: `frontend`; UI-bearing: YES
- Prior review (`review-report.md`, Iris-QC-3) read as read-only context; its
  `Outcome: PATCH_REQUIRED` is NOT authoritative for this pass.

## Governing standard change since the prior pass

`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`
(user decision, 2026-08-21, second decision on that doc) sets the effective
visual-fidelity standard for this story:

- Implementation side: a real `render-running-app.js` capture at 375/768/1280
  against the built app is REQUIRED. Fix 1 (`app_render` config) is DONE.
- Design-reference side: `render-design-canvas.js` can only reach the canvas
  default `home`; for every other screen the design reference is this story's
  `ux/uiux-spec.md`, not a screen-specific canvas PNG.
- The absent screen-specific canvas render is a permanent DEFERRED finding
  citing that doc; it is not on its own grounds for `PATCH_REQUIRED`/`BLOCKED`.

## Source/test files in scope (5 changed, within the 12-file full-review budget)

- `web/src/pages/pets.astro`
- `web/src/components/pets/PetsHero.astro`
- `web/src/components/pets/PetRoster.astro`
- `web/src/components/pets/GrowthStages.astro`
- `web/src/data/pets-content.ts`

Read for entry-point verification only (not changed by this story):

- `web/src/data/site-nav.ts`
- `web/src/components/shell/SiteHeader.astro`
- `web/src/layouts/SiteLayout.astro`

## Evidence files in scope

- `STORY-002/coding-plan/test-results.md` — §`Entry Point Reachability`,
  §`Story Runtime Startup Smoke`, §4 screenshot/overflow rows (query-first)
- `STORY-002/requirements/requirements.md` (AC-1…AC-7, UI-Fidelity-AC, BR-1…BR-3)
- `STORY-002/ux/uiux-spec.md` — layout/spacing/type/color tables, the
  design-reference side of the visual check under the new standard
- `STORY-002/visual-fidelity/visual-fidelity-report.md` + rendered PNGs
- `REQ-006/design-fidelity-tooling-fix.md`
- `STORY-002/review/review-report.md` (prior pass, read-only context)

## Touched risk surfaces and critical gates

| Risk surface | Critical gate |
|---|---|
| Frontend static page body | `npm run build` in `web/` |
| Frontend discoverability / navigation integration | Rule 12e1 `## Entry Point Reachability` section + independent code verification of nav wiring |
| Design fidelity (UI-Fidelity-AC, `design_source` configured) | Rule 12e2 under the amended REQ-006 standard: Reviewer-owned `render-running-app.js` capture at 375/768/1280 compared against `ux/uiux-spec.md` |
| Runtime/configuration (frontend lane, non-trivial) | Rule 12g `## Story Runtime Startup Smoke` evidence |
| Verbatim copy integrity (BR-2/BR-3) | Copy diff vs design source `pets`/`stages` arrays |
| Shell immutability (STORY-001 contract) | Diff path check — no `layouts/`, `components/shell/`, `styles/`, `scripts/`, no `home-content.ts` |
| Responsive reflow (AC-7) | Rendered breakpoint inspection at 375/768/1280 |

## Query keys for Phase 2

`Entry Point Reachability`, `Reachable:`, `Story Runtime Startup Smoke`,
`VISUAL_FIDELITY`, `Design-Screen`, `page="pets"`, `aria-current`, `pets`,
`stages`, `minmax(330px`, `minmax(180px`, `title=`, `home-content`.

## Gate decision

Phase 2 may proceed. Scope is inside the `full-story-review` budget (5 changed
source files, 3 read-only shell files, no governing artifact over ~20 KB needing
a full read). The two prior evidence-form blockers (12e1, 12g) and the
visual-fidelity axis are re-verified against current worktree state and a fresh
Reviewer-owned `render-running-app.js` capture before the verdict is written.
