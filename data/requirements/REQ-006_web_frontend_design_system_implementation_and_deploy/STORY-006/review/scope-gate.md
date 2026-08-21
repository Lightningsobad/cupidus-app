# Scope Gate — REQ-006 / STORY-006 About & Press Kit Page

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: `full-story-review`
Review report path:
`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/review/review-report.md`

Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-006`
Diff baseline: `c744eaf133fc0bd92bc57bf0c1f4e37d1f371c05..8c5a907c63a57edcaf0fc9dc6e41d657f2c8d3ad`
Story class: `standard` / Implementation lane: `frontend` / Complexity: `standard`

## Source files in scope (9 code + 5 static assets)

| File | Why in scope |
|---|---|
| `web/src/pages/about.astro` | route + `<title>` (AC-1, AC-9), section composition |
| `web/src/data/about-content.ts` | all literal VI/EN copy (AC-2..AC-8, AC-11) |
| `web/src/components/about/AboutMission.astro` | AC-2 |
| `web/src/components/about/PrincipleGrid.astro` | AC-3 (exactly 4) |
| `web/src/components/about/StatCounters.astro` | AC-4 (exactly 3, unlocalized numerals) |
| `web/src/components/about/WhyPetCallout.astro` | AC-5 |
| `web/src/components/about/CompanyTimeline.astro` | AC-6 (exactly 5, semantic `<ol>/<li>`) |
| `web/src/components/about/TeamSection.astro` | AC-7 (exactly 3) |
| `web/src/components/about/PressKit.astro` | AC-8 (8 swatches, download CTA, always visible) |
| `web/public/press-kit/{cupid-lockup-dark.svg,cupid-lockup-light.svg,palette.txt,README.txt,cupid-press-kit.zip}` | AC-8 downloadable asset delivery |

## Evidence files in scope

- `coding-plan/test-results.md` (P1 + P2 command tables, assertion tables, entry-point table, deferred findings)
- `coding-plan/phase-P1-about-core-sections.md` — `Acceptance Criteria` + `Test Scope` only
- `coding-plan/phase-P2-timeline-team-press-kit.md` — `Acceptance Criteria` + `Test Scope` only

## Governing artifacts (query-first)

- `requirements/requirements.md` (~12 KB, read whole — AC list is the control)
- `ux/uiux-spec.md` (~36 KB — LARGE, query only: §6.2 line-cited values, §6.6, §6.8)
- `architecture/solution.md` (~12 KB — query: Key Discovery, Frontend Lane guardrails, press-kit asset decision)
- `STORY-001/architecture/contract-summary.md` (~8 KB — query: §6 shell immutability)
- `data/devops/system/design-fidelity-config.json` — `design_source` configured, `ui_surface: true`

## Touched risk surfaces and critical gates

| Risk surface | Critical gate | How verified |
|---|---|---|
| Frontend interaction / static page render | `astro check` + `astro build` exit 0 | test-results P1/P2 command tables |
| Frontend discoverability / navigation integration | reachable entry point verified IN CODE, not on trust (skill 12e1) | read `SiteHeader.astro` / `SiteFooter.astro` nav wiring + built `dist/about/index.html` |
| Shared contract (STORY-001 shell) | zero diff under `web/src/layouts`, `components/shell`, `styles`, `scripts` | independent `git diff --stat` at review time |
| Static asset delivery (press-kit zip) | asset present in `web/dist/` after build, CTA href resolves, `download` attr | independent build + file check |
| UI design fidelity (AC-10) | rendered per-story `visual-fidelity/` PASS (skill 12e2) — `design_source` IS configured | reviewer-owned render + compare attempt |
| Runtime startup smoke (12g, `frontend` lane, non-trivial) | `## Story Runtime Startup Smoke` evidence | check `test-results.md` |

## Query keys for Phase 2

`isAbout`, `showPressKit`, `principles`, `palette`, `startPage`, `data-vi`, `data-en`,
`press-kit`, `download`, `<ol`, `Minh Khôi`, `48.000+`, `2,1 triệu`, `document.title`,
`Press kit` (SiteFooter), `contract-summary §6`.

## Gate decision

Phase 2 may proceed. Scope is inside the `full-story-review` budget
(9 primary source files ≤ 12; one large governing artifact ≥ 20 KB — `uiux-spec.md` — ≤ 2).

Two handoff-flagged deferrals must be independently adjudicated, not accepted on the
implementer's word: (a) EN `<title>` shell-contract conflict, (b) footer "Press kit"
anchor target. Both hinge on whether the fix genuinely requires a `web/src/components/shell`
or `web/src/layouts` edit forbidden to a consumer story.
