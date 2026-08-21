# Scope Gate — REQ-006 / STORY-008 (Privacy & Terms Page)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: `full-story-review` (UI lane, parallel story review)
- Review report path: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/review/review-report.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-008`
- Diff baseline: `bc499987466ae3cbacf8f7b9157a6b9a3aab857c..8ce3e2f0fed6d00a6abd1b542605201482f437de`

## Source / Test / Config Files In Scope

| Path | Why |
|------|-----|
| `web/src/pages/legal.astro` | the only changed source file in the story diff |
| `web/src/layouts/SiteLayout.astro` | `title` prop + single `<main>` contract (read-only, regression check) |
| `web/src/components/shell/SiteFooter.astro` | independent entry-point verification (AC-1) |
| `web/src/data/site-nav.ts` | 7-item header nav + footer Legal column wiring (AC-1) |
| `data/devops/system/design-fidelity-config.json` | `design_source` / `ui_surface` / `app_render` resolution for rule 12e2 |
| `cupid-app-design-system/Cupid Web.dc.html` (`:639-653`, `:823-829`) | design source of truth for AC-2 / AC-3 / UI-Fidelity-AC |

## Evidence Files In Scope

| Path | Sections |
|------|----------|
| `STORY-008/coding-plan/test-results.md` | §1 build gate, §2 diff scope, §3 static assertions, §4 measured layout, §5 title, §6 rendered inspection, §7 entry point, §8 shell regression, §10 deviations |
| `STORY-008/coding-plan/phase-P1-legal-page-body-and-entry-point.md` | §4 Acceptance Criteria, §6 Test Scope, §7 Status |
| `STORY-008/requirements/requirements.md` | AC-1..AC-5, UI-Fidelity-AC, Open Question Impact |
| `STORY-008/ux/uiux-spec.md` | §5.1, §6.6, §6.7, §6.8 (ranged reads; file is 21.5 KB) |
| `STORY-008/architecture/solution.md` | §1 Key Discovery, §4 risk/gate table |
| `STORY-001/architecture/contract-summary.md` | shell immutability (§6) — satisfied by the empty shell diff, no read needed |
| `STORY-008/story_master.md` | complexity, lane, `Runtime-Smoke` declaration |

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Verify by |
|--------------|---------------|-----------|
| Verbatim bilingual legal copy | all 10 VI + 10 EN strings present, source order | diff vs `Cupid Web.dc.html:823-829` |
| Rendered visual fidelity (UI-bearing, `design_source` configured) | rule 12e2 rendered screenshot vs design reference | `render-running-app.js` executed by Reviewer |
| Frontend discoverability / navigation integration | rule 12e1 `## Entry Point Reachability` + independent code verification | `SiteFooter.astro`, `site-nav.ts`, built `dist/index.html` |
| Heading / landmark semantics | one `<main>`, one `<h1>`, five `<h2>` | built `dist/legal/index.html` |
| Per-page localized `<title>` (AC-5) | title on load + on `data-lang` mutation, no reload | `legal.astro` inline script + evidence §5 |
| Runtime / configuration (frontend lane, non-trivial) | rule 12g `## Story Runtime Startup Smoke` or `Runtime-Smoke: WAIVED` | `test-results.md`, `story_master.md` |
| Shell immutability | story diff contains no shell file | `git diff --name-only <BaseHead>` |

## Focused Query Keys

`sections` array, `data-vi`/`data-en`, `MutationObserver`, `document.body.dataset.lang`,
`title=`, `<main>`, `<h1>`, `<h2>`, `hrefFor('legal')`, `navItems`, `footerCols`,
`app_render`, `design_source`, `Entry Point Reachability`, `Story Runtime Startup Smoke`.

## Phase 2 Decision

Proceed to focused verification. Scope is within the `full-story-review` budget
(6 source/config files, 0 governing artifacts over 20 KB read in full — the
21.5 KB UX spec was read only in ranges).
