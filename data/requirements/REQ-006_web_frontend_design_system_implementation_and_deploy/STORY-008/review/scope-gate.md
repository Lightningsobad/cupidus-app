# Scope Gate — REQ-006 / STORY-008 Privacy & Terms Page

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: `full-story-review` (UI lane, parallel story review, re-review)
- Review report path: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/review/review-report.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-008`
- BaseHead diff: `git -C <Worktree> diff 2e72902de51910c18ca1c6e8ca31faeedc14d823`
- Re-review of a prior `PATCH_REQUIRED` pass (Iris-QC-7). Prior findings
  BLOCK-1 / BLOCK-2 / BLOCK-3 and DEF-1 are re-verified against current
  worktree state, not carried forward on trust.

## Source/Test/Config Files In Scope

| File | Why |
|------|-----|
| `web/src/pages/legal.astro` | the only source file in the story diff (+65/-1) |
| `web/src/lib/site-nav.ts` (footer Legal column rows) | rule 12e1 independent entry-point verification |
| `web/src/components/SiteFooter.astro` | rule 12e1 — confirms the column renders real anchors |
| `web/src/layouts/SiteLayout.astro` (`title` prop, `<main>`) | AC-5 + landmark, and shell-immutability check |
| `data/devops/system/design-fidelity-config.json` | rule 12e2 gating: `ui_surface`, `design_source`, `app_render` |

Budget: 5 source/config files (`full-story-review` limit 12). Two large
governing artifacts read query-first/ranged: `coding-plan/test-results.md`
(22 KB) and `ux/uiux-spec.md`.

## Evidence Files In Scope

- `coding-plan/test-results.md` §1 (build gate), §7, `## Entry Point Reachability`, `## Story Runtime Startup Smoke`, §10
- `ux/uiux-spec.md` §5.1, §6.2, §6.6, §6.7, §6.8
- `requirements/requirements.md` AC-1..AC-5, UI-Fidelity-AC, `## Open Question Impact`
- `architecture/solution.md` (targeted)
- `data/requirements/REQ-006_.../design-fidelity-tooling-fix.md` — the
  governing, user-confirmed standard for this story's visual-fidelity axis
- prior `review/review-report.md` (read-only context)
- Reviewer-produced `visual-fidelity/` render (this run)

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate |
|--------------|---------------|
| Verbatim bilingual legal copy (AC-2/AC-3) | 20-string VI/EN check vs design source + uiux-spec §6.2 |
| Frontend discoverability / navigation | rule 12e1 `## Entry Point Reachability` + independent code verification |
| Rendered visual fidelity | rule 12e2 as amended by `design-fidelity-tooling-fix.md`: real `render-running-app.js` capture at 375/768/1280 compared against uiux-spec §6.2/§6.8 |
| Runtime / configuration | rule 12g `## Story Runtime Startup Smoke` |
| Frontend build / type-check | `npm run check` + `npm run build` exit 0 |
| Shell immutability | story diff contains no shell file |
| Setup/configuration impact (rule 12a) | no env var / secret / integration added → no configuration-guide change |

## Query Keys For Phase 2

`legal.astro`, `sections`, `data-vi`/`data-en`, `hrefFor('legal')`,
`SiteFooter` Legal column, `SiteLayout` `title`, `<main>`, `max-width:820px`,
`gap:26px`, `padding-top:22px`, `Reachable: YES`,
`## Story Runtime Startup Smoke`, `app_render`, `VISUAL_FIDELITY`.

## Gate Decision

Phase 2 may proceed. The scope is within `full-story-review` budget and the
visual-fidelity axis is now producible on the implementation side
(`app_render` configured), so the review is not blocked at the gate.
