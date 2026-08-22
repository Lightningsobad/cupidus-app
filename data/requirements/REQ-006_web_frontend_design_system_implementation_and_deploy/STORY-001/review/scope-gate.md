# Scope Gate — REQ-006 / STORY-001

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: `full-story-review` (parallel story review, `Flow: parallel-story`)
Review report path: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/review/review-report.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-001`
BaseHead: `a648a5a1039752cb31891e657d9b47a165ba3579`
Story: `standard` complexity, `shared` lane, `shared-foundation` class, 6 coding-plan phases.

## Scope size decision

The story diff touches 53 files. That is above the nominal `full-story-review`
budget of 12 touched source/test/config files, so the file set was clustered
before Phase 2 rather than reviewed file-by-file. Clustering is legitimate here
because the diff is a greenfield scaffold, not 53 independent change surfaces:

| Cluster | Files | Review treatment |
|---------|-------|------------------|
| Generated lockfile | `web/package-lock.json` (5771 lines) | Not read; integrity checked via `package.json` dependency set only |
| Route stubs | 7 of 8 `web/src/pages/*.astro` (5–6 lines each) | Read as one cluster; verified identical shape + `page` prop |
| Pet sprites | 6 `web/src/components/sprites/*Sprite.astro` (43–45 lines each) | Read as one cluster; structural equivalence + one deep verbatim check |
| Reviewed individually | see "Source files in scope" below | Full read / diff-hunk read |

Recorded as deferred process note DEF-4 in the report so Scrum Master can decide
whether future scaffold stories are split into `scoped-slice` passes.

## Source / test / config files in scope (individually reviewed)

1. `web/src/styles/tokens.css`
2. `web/src/styles/global.css`
3. `web/src/layouts/SiteLayout.astro`
4. `web/src/components/shell/SiteHeader.astro`
5. `web/src/components/shell/SiteFooter.astro`
6. `web/src/components/shell/NebulaBackdrop.astro`
7. `web/src/components/home/Hero.astro`
8. `web/src/components/home/PetCast.astro`
9. `web/src/components/home/FeatureGrid.astro` + `HowItWorks.astro`
10. `web/src/data/site-nav.ts` + `web/src/data/home-content.ts`
11. `web/src/scripts/theme-lang-boot.ts`
12. `web/src/pages/index.astro`
13. `web/astro.config.mjs`, `web/package.json`, `web/tsconfig.json`, `web/.gitignore`
14. `scripts/start-dev.sh`, `scripts/build.sh`
15. `.github/workflows/deploy-web.yml`, `.github/workflows/scripts/vps-deploy-web.sh`
16. `data/devops/system/runtime-command-registry.json`

## Evidence files in scope

- `coding-plan/test-results.md` (query keys: `P1`, `P2`, `P3`, `P4`, `P5`, `P6`,
  `build_gate`, `markup-equivalence`, `Entry Point Reachability`,
  `Story Runtime Startup Smoke`)
- `coding-plan/master-plan.md` + `phase-P1..P6` (query anchors: each file's own
  `Test Scope` / `Acceptance` heading)
- `requirements/requirements.md` (AC-1..AC-8, `Open Question Impact`)
- `ux/uiux-spec.md` (query keys: breakpoint, header, footer, hero, sprite)
- `architecture/solution.md`, `architecture/contract-summary.md`
- `deployment/configuration-guide.md` (§5 `VPS_SSH_PRIVATE_KEY` caveat)
- `data/devops/system/design-fidelity-config.json` (worktree copy)
- Design source `cupid-app-design-system/Cupid Web.dc.html` ranges `:16-17`,
  `:117-139`, `:164-189`, `:211`

## Touched risk surfaces and critical gates

| Risk surface | Critical gate | Where verified |
|--------------|---------------|----------------|
| Frontend interaction (theme/lang toggles) | build + type-check + runtime DOM assertions | `test-results.md` P2/P5 |
| Frontend discoverability / navigation integration | `## Entry Point Reachability` + independent code read of nav wiring | `site-nav.ts`, `SiteHeader.astro` |
| Local storage / persistence | boot-script correctness + DOM assertion evidence | `theme-lang-boot.ts` |
| Runtime / configuration | registry-backed `## Story Runtime Startup Smoke` (12g, `shared` lane) | `test-results.md`, runtime registry |
| Operational command / deploy | configuration-guide accuracy vs delivered CI (12a) | `deployment/configuration-guide.md`, `deploy-web.yml` |
| UI-bearing story, `design_source` configured, `ui_surface: true` | rendered `VISUAL_FIDELITY` verdict (12e2) — Reviewer-owned render for non-mobile lane | `visual-fidelity/` (produced this run) |

## Visual fidelity gate plan

No `visual-fidelity/` folder existed at review start and UX produced no
design-reference images (UX ran before `design_source.entry` was resolved). Per
12e2 the non-mobile lane makes the render Reviewer-owned, so both image sets are
produced this run with the bundle tools only:

- `render-design-canvas.js --location=cupid-app-design-system --entry="Cupid Web.dc.html" --screen=<home> --platform=all`
- `render-running-app.js --label=home --route=/`

No hand-rolled Playwright/Puppeteer, no `playwright test`.

## Phase 2 authorization

Phase 2 may proceed. No blocking input is missing at the gate.

---

# Scope Gate — Pass 3 (A-1 rework re-review)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: `compact-story-review` (`Flow: story`, ordinary Git boundary)
Review report path: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/review/review-report.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-001`
BaseHead: `4a50c57264f17a936d08ac5188fc6810d80ce925`
Diff baseline for the rework: `0c2c213702a94f205eb43eb85fc2d43d866ee9fd` (the story's prior MERGED state)

Scope: requirement-integration finding **A-1** only — header VI/EN language toggle
and "Tải app" CTA clipped / pointer-unreachable below ~543px on all 8 routes. The
story was already MERGED and DONE and is reopened for this one narrow rework cycle.
Everything else in the pass-1/pass-2 review is carried, not re-reviewed.

## Source/Test Files In Scope

Exactly the 3 files in `git diff --name-only 0c2c213..4a50c57`:

1. `web/src/components/shell/SiteHeader.astro` — the only code change (line 16,
   header inner-row flex declaration). Reviewed by diff hunk plus full read of the
   93-line component for the logo and actions-cluster declarations at `:17` / `:36`.
2. `data/requirements/REQ-006_.../STORY-001/ux/uiux-spec.md` — new §6.1 "Mobile
   Actions Wrap" plus 2 pointer lines in §6.7/§6.8. Read via diff hunks only.
3. `data/requirements/REQ-006_.../STORY-001/story_master.md` — checkbox bookkeeping
   only (`Implementation (Development)` checked); no implementation content.

Out of scope by explicit handoff instruction: STORY-001's original AC set, the 6
non-home screens' overall fidelity (TERMINAL/PASS this requirement), and the
V-1 / D-INT-1 implementation surfaces.

## Evidence Files In Scope

- `review/a1-verification/*.png` — 45 rendered captures produced this pass.
- `visual-fidelity/implemented-home-1400.png` — pre-rework capture, used as the
  exact same-width desktop A/B baseline for the nav-position regression check.
- `data/devops/system/design-fidelity-config.json` — `app_render` block only,
  to confirm which port the bundle renderer would otherwise bind/reuse.

## Focused Query Keys

`justify-content`, `flex-wrap`, `gap:10px 28px`, `margin-right:auto`,
`margin-left:auto`, `[data-nav]`, `[data-navm]`, `cupid-hdr-cta`, `data-set-lang`.

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Result |
|--------------|---------------|--------|
| Frontend interaction (header controls reachable/unclipped) | rendered capture across 320-1024 on all 8 routes | PASS — A-1 closed |
| Frontend discoverability (language toggle + CTA pointer-reachable) | same captures, VI default state | PASS |
| Visual regression (desktop `[data-nav]` position) | same-width A/B vs pre-rework 1400 capture | PASS — positionally identical |
| Typed/generated contract | `npm run check` | PASS — 27 files, 0/0/0 |
| Build | `npm run build` | PASS — 8 pages |

Runtime startup smoke is not re-required: it was satisfied at pass 2 and this
rework changes one CSS declaration in an already-booting static app.

## Render Method

Fresh `npm run build` + `astro preview` from THIS worktree on private port 21877
(deliberately not the reserved `DEVSTACK_PORT_WEB`/21021, which
`render-running-app.js` would silently reuse from another agent's checkout during a
parallel wave). Captures via bundle tool
`.ai-team-bundle/runtime/tools/visual-capture.js --mode=url`. Node `v22.17.1`.
No hand-rolled Playwright/Puppeteer, no `playwright test`.

## Phase 2 authorization

Phase 2 may proceed. No blocking input is missing at the gate.
