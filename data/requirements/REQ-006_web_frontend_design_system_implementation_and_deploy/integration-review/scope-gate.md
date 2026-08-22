# Review Scope Gate: REQ-006 Web frontend implementation from design system & production deploy

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `requirement-integration-review`
- Review report path: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/integration-review/review-report.md`
- Scope gate path: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/integration-review/scope-gate.md`
- Integration branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-006_web_frontend_design_system_implementation_and_deploy`
- Diff baseline: `a648a5a..6459088` (pass 1); `a648a5a..1443b93` (pass 2 re-run)

## Pass 2 — Re-run Scope (2026-08-22)

Pass 1 returned `PATCH_REQUIRED` with blocking findings INT-2..INT-5. This pass
re-verifies their closure at the current worktree HEAD `1443b93` and decides the
final outcome. The pass-1 scope above is unchanged and is NOT re-executed; the
pass-2 slice is deliberately narrow:

- Re-run both requirement gates at current HEAD (rule 12g3): `integration_build`
  and `integration_runtime_smoke`. Pass-1 results are treated as stale because
  three commits landed after them (`bc34270`, `08d0af9`/`4a50c57`/`ce7d53e`,
  `1443b93`).
- Verify `A-1` (header language toggle + CTA clipped below ~543px) directly by
  rendering the current build myself, and verify no desktop regression against
  the pre-rework capture — not via the story-level report.
- Confirm INT-2, INT-3, INT-4, INT-5 closure against primary evidence.
- Files added to scope for pass 2 only: `web/src/components/shell/SiteHeader.astro`
  (the single changed file in the A-1 rework), `web/src/data/site-nav.ts`,
  `integration-review/frontend-visual-audit.md`, `req_master.md` on `main`,
  `STORY-001/review/review-report.md`. Five files — well inside budget.

Query keys for pass 2: `A-1`, `justify-content:flex-end`, `flex-wrap`,
`navItems`, `Configuration Documentation`, `User Stories`, `Outcome:`,
`FRONTEND_VISUAL_AUDIT_COMPLETE`.

Scope status: `PROCEED`.

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: the requirement-level
  diff is 253 changed files, but only ~30 of those are source/config; the rest
  are per-story artifacts and PNG evidence already covered by 8 passing story
  reviews. This integration review does NOT re-review per-screen
  implementation. It is scoped to the requirement-level integration surfaces
  only: (1) the shared design-canvas render tooling contract
  (`cupid-app-design-system/support.js`, `data/devops/system/design-fidelity-config.json`),
  (2) the shared app shell / nav contract that binds all 8 screens together,
  (3) requirement-level gates (integration build + runtime smoke, requirement
  frontend visual audit, requirement state consistency), and (4) cross-story
  evidence contradictions. That keeps the source/config slice under the 20-file
  integration-review budget without a scoped-slice split.
- Current story or bug status: all 8 stories TERMINAL with story-review
  `Outcome: DEFERRED_ONLY`, all merged into the integration branch. Requirement
  status is `IN_PROGRESS`.

## Governing Inputs

- Primary artifacts:
  - `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`
  - `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/requirements/requirements.md`
  - `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`
  - `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/deployment/configuration-guide.md`
  - `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/scrum-master-checkpoint.md`
- Existing review findings: the 8 story review reports
  (`STORY-001..STORY-008/review/review-report.md`), all `DEFERRED_ONLY`
- Test evidence: the 8 `STORY-00N/visual-fidelity/visual-fidelity-report.md`
  files and `STORY-00N/coding-plan/test-results.md`
- Extra artifacts required beyond the default minimum: none

## Source/Test Files In Scope

Shared / requirement-level integration surfaces only (16 files):

1. `cupid-app-design-system/support.js` (shared design-canvas render tooling — changed by the STORY-002 merge)
2. `cupid-app-design-system/Cupid Web.dc.html` (design source of truth — read via targeted `git grep` for `dc-import` hosts only, not a full read)
3. `data/devops/system/design-fidelity-config.json`
4. `data/devops/system/runtime-command-registry.json`
5. `web/src/data/site-nav.ts` (shared cross-screen nav contract)
6. `web/src/components/shell/SiteHeader.astro`
7. `web/src/components/shell/SiteFooter.astro`
8. `web/src/layouts/SiteLayout.astro`
9. `web/src/scripts/theme-lang-boot.ts`
10. `web/src/styles/tokens.css`
11. `web/src/styles/global.css`
12. `web/astro.config.mjs`
13. `web/package.json`
14. `scripts/build.sh`
15. `scripts/start-dev.sh`
16. `.github/workflows/deploy-web.yml` (+ `.github/workflows/scripts/vps-deploy-web.sh` as its callee)

Explicitly OUT of scope (already covered by the 8 passing story reviews, not
re-reviewed here): all `web/src/pages/*.astro` bodies, all
`web/src/components/{home,pets,zodiac,share,blog,about}/*`, all
`web/src/components/sprites/*`, and all `web/src/data/*-content.ts`. Their
route existence is checked only as an 8-route completeness assertion.

## Evidence Files In Scope

- `data/requirements/REQ-006_.../STORY-001/review/review-report.md`
- `data/requirements/REQ-006_.../STORY-002/review/review-report.md`
- `data/requirements/REQ-006_.../STORY-003/review/review-report.md`
- `data/requirements/REQ-006_.../STORY-004/review/review-report.md`
- `data/requirements/REQ-006_.../STORY-005/review/review-report.md`
- `data/requirements/REQ-006_.../STORY-006/review/review-report.md`
- `data/requirements/REQ-006_.../STORY-007/review/review-report.md`
- `data/requirements/REQ-006_.../STORY-008/review/review-report.md`
- `data/requirements/REQ-006_.../STORY-00N/visual-fidelity/visual-fidelity-report.md` (N = 1..8)
- `data/requirements/REQ-006_.../design-fidelity-tooling-fix.md`
- `data/requirements/REQ-006_.../deployment/configuration-guide.md`
- Merge commits: `8c6f2fd`, `6459088` (supersedes `d0c5a04`), `001f4c2`,
  `619ad99`, `e93ca05`, `74fd90f`, `5bc6570`, `bb7dc56`

## Risk Surfaces And Critical Gates

- Touched risk surfaces:
  1. **Shared design-canvas render tooling** (`cupid-app-design-system/support.js`
     `HOST_STYLE_PROPS`) — changed mid-requirement, after 7 of 8 screens had
     already recorded `VISUAL_FIDELITY: PASS`.
  2. **Shared design-fidelity config** (`design-fidelity-config.json`) — canvas
     entry re-locked from `Cupid App.dc.html` to `Cupid Web.dc.html`,
     `hide_selectors` removed, `app_render` block added.
  3. **Shared app shell / cross-screen nav contract** (`site-nav.ts`,
     `SiteHeader.astro`, `SiteFooter.astro`, `SiteLayout.astro`,
     `theme-lang-boot.ts`) — written by STORY-001, consumed by 7 later stories
     merged in parallel.
  4. **Requirement-level visual-fidelity standard** — the user's hard
     acceptance requirement is "giống 100%"; the design-reference waiver
     recorded in `design-fidelity-tooling-fix.md` governs 7 of 8 screens.
  5. **Runtime/deploy configuration consistency** (`runtime-command-registry.json`,
     `scripts/build.sh`, `scripts/start-dev.sh`, `deploy-web.yml`,
     `deployment/configuration-guide.md`).
- Source-of-truth artifacts or contracts:
  - `cupid-app-design-system/Cupid Web.dc.html` (design)
  - `data/requirements/REQ-006_.../requirements/requirements.md` (requirement ACs)
  - `data/devops/system/design-fidelity-config.json` (fidelity lock)
  - `data/devops/system/runtime-command-registry.json` (runtime commands)
  - `data/requirements/REQ-006_.../design-fidelity-tooling-fix.md` (evidence standard)
- Critical gates to verify:
  - G1: the `support.js` `HOST_STYLE_PROPS` change did not silently invalidate
    the already-recorded `VISUAL_FIDELITY: PASS` for STORY-001 and
    STORY-003..008 — verified by enumerating every `dc-import` host in
    `Cupid Web.dc.html` and checking which ones declare a `flex*` property.
  - G2: cross-story evidence consistency — no story review or evidence file
    asserts a fact that another merged story's evidence contradicts.
  - G3: 8-route completeness and shared shell/nav contract consistency across
    all 8 screens.
  - G4: **Integration Build & Runtime** — reviewer rule 12g3 requires
    `## Integration Build & Runtime` in this directory with BOTH
    `- Build: PASS — <cmd>` and `- Runtime/Smoke: PASS — <cmd>`, unless
    `req_master.md` records `Integration-Verify: WAIVED — <reason>`.
  - G5: requirement-level frontend visual audit
    (`frontend-dev Mode: requirement-visual-audit`), which `req_master.md`
    Technical Constraints explicitly names as a pre-DONE gate.
  - G6: requirement state consistency — `req_master.md` story table vs actual
    merged/TERMINAL story status.
  - G7: runtime/config guide consistency (registry commands, reserved devstack
    web port, deploy workflow target domain).
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `REQUIRED when requirement had frontend participation` — this requirement is frontend-only, so REQUIRED
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `NOT_APPLICABLE` (no mobile participation in REQ-006)
- Missing gate evidence or blocker: G4 and G5 evidence files do not exist in
  `integration-review/` (the directory held no tracked files before this gate
  was written) — carried into Phase 2 as findings, not as a Phase 2 stop.

## Query Keys

- `HOST_STYLE_PROPS`, `hostPositionStyle`, `flex`, `flex-shrink`, `flex-basis`, `flex-grow` (support.js:445-460)
- `dc-import` (all 22 occurrences in `Cupid Web.dc.html`; flex-bearing hosts at :222,:230,:238,:246,:254,:262)
- `BLK-VF-1`, `VISUAL_FIDELITY`, `design-reference`, `render-design-canvas`, `--screen=`, `startPage`
- `Fix 2`, `structurally unproducible`, `remains impossible in this repo`, `available only for `home``
- `Integration-Verify`, `Integration Build & Runtime`, `requirement-visual-audit`
- `entry`, `content_fingerprint`, `hide_selectors`, `app_render`, `ready_url` (design-fidelity-config.json)
- `NAV_ITEMS`, `href`, `/pets`, `/zodiac`, `/share`, `/blog`, `/about`, `/support`, `/legal` (site-nav.ts, SiteHeader/SiteFooter)
- `DEVSTACK_PORT_WEB`, `21021`, `npm run build`, `npm run preview` (registry, scripts, config)
- `cupidus.app`, `84.247.140.178` (deploy-web.yml, configuration-guide.md)
- Requirement ACs from `requirements/requirements.md`
- Files over roughly 20 KB (`scrum-master-checkpoint.md`, `Cupid Web.dc.html`,
  `web/package-lock.json`) are read only via the query keys above or targeted
  `git grep`, never as full reads. `package-lock.json` is not read at all.

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: `N/A`
- If `NO`, exact blocker or re-scope instruction: `N/A`
