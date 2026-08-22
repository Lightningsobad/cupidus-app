---
requirement_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-22
reviewed_by: Reviewer
---

# Review Report: REQ-006 Web frontend implementation from design system & production deploy — Requirement Integration Review

Outcome: DEFERRED_ONLY

Pass 2 (re-run). Pass 1 (2026-08-22, worktree HEAD `6459088`) returned
`PATCH_REQUIRED` with blocking findings INT-2, INT-3, INT-4, INT-5. All four are
verified closed below, together with `A-1`, the blocking finding the requirement
visual audit raised while closing INT-3. No blocking finding remains.

## Reviewed Inputs

- Review gate: `requirement-integration-review`
- Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/integration-review/scope-gate.md` (`## Pass 2 — Re-run Scope`)
- Integration branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`
- Worktree HEAD this pass: `1443b93ae789420ad3895f677f5a02c9aae6f5e2`
- Diff baseline: `a648a5a..1443b93`
- Requirement visual audit: `integration-review/frontend-visual-audit.md` (+ `screenshots/`, `design-reference/`)
- Story gate for the A-1 rework: `STORY-001/review/review-report.md` (`Outcome: DEFERRED_ONLY`, Pass 3)
- Requirement state: `req_master.md` on `main` (canonical) and on this branch
- Pass-1 findings: the INT-2..INT-5 sections of this report's previous revision

## Reviewed Scope

Pass 1's requirement-level integration scope stands and was not re-executed. This
pass added five files: `web/src/components/shell/SiteHeader.astro` (the sole
changed file in the A-1 rework), `web/src/data/site-nav.ts`,
`frontend-visual-audit.md`, `req_master.md` on `main`, and
`STORY-001/review/review-report.md`.

- Backend targeted verification gates: `NOT_APPLICABLE` (static site, OQ-REQ006-2 RESOLVED)
- Frontend targeted verification gates: `PASS`
- Frontend discoverability/navigation integration: `PASS`
- Requirement frontend visual audit: `PASS` (INT-3 closed)
- Mobile gates / requirement mobile visual audit: `NOT_APPLICABLE` (no mobile participation)
- Integration build + runtime smoke: `PASS` (re-run at current HEAD, below)

## Integration Build & Runtime

Re-run by Reviewer against the merged integration branch at HEAD `1443b93`, in
the integration worktree, Node v22.17.1 (the version `web/package.json` `engines`
and the runtime registry require; the machine default `node` is v20.20.2 and
cannot run `astro@6`). Pass-1 results were discarded as stale — three commits
landed after them.

- Build: PASS — `cd web && npm ci && npm run check && npm run build` → `npm ci` added 331 packages; `astro check` on 52 files reported `0 errors, 0 warnings, 0 hints`; `astro build` reported `8 page(s) built`, `output: "static"`, exit 0.
- Runtime/Smoke: PASS — `cd web && npm run preview -- --port 21524 --host 127.0.0.1`, then `curl -s -o /dev/null -w "%{http_code}"` against all 8 requirement routes: `/` 200, `/pets/` 200, `/zodiac/` 200, `/share/` 200, `/blog/` 200, `/about/` 200, `/support/` 200, `/legal/` 200. Server stopped after capture.

Port note unchanged from pass 1: the reserved local web port is
`DEVSTACK_PORT_WEB` = 21021. A private port (21524) was used for smoke capture to
avoid colliding with other worktrees in this wave; the production/dev contract
still reads 21021 from `.env.devstack`.

## Outcome Summary

- Review outcome: DEFERRED_ONLY
- Blocking findings: 0
- Deferred findings: 7 (5 carried forward, 2 new)
- Rationale: pass 1 blocked on evidence integrity, not code. That evidence now
  exists and was re-verified against primary sources rather than accepted from
  the handoff summary. The requirement visual audit ran and produced measured
  rendered-vs-rendered comparisons for the six screens that previously had none;
  the one blocking defect it surfaced (`A-1`) was fixed in a one-line change to
  the shared header and is confirmed closed by this reviewer's own renders, with
  desktop fidelity confirmed pixel-identical to the pre-rework certified state.
  The two requirement-state findings are corrected on `main` and survive the
  pending merge. The merged tree builds clean and boots all 8 routes.

## Blocking Finding Verification

### INT-2 — Falsified no-render waiver — CLOSED

Pass 1 blocked because the waiver governing six screens rested on the premise
that driving the design canvas to a non-`home` screen was impossible, a premise
STORY-002's merged `pets` captures disproved. The user directed re-render rather
than re-affirmation, and that is what happened: 18 `design-reference-*.png` for
`zodiac`, `share`, `blog`, `about`, `support`, `legal` at 375/768/1280 are
committed on this branch (`33e8e17`), and all six now carry real
rendered-vs-rendered comparison in `frontend-visual-audit.md` Part B. The waiver
is no longer load-bearing for any screen. Closed.

### INT-3 — Requirement-level frontend visual audit never ran — CLOSED

`integration-review/frontend-visual-audit.md` exists, committed at `bc34270`,
with `FRONTEND_VISUAL_AUDIT_COMPLETE: YES`, alongside 30 screenshots and the 18
design references. It is a real audit, not a token: Part A measures shared shell
geometry, runtime health and theme/language persistence across all 8 screens;
Part B reports per-breakpoint pixel deltas, content-edge positions and ink-band
counts per screen. Verdicts are `PASS` at 1280 and 768 on all six screens, with
375 recorded honestly as `NOT COMPARABLE (reference invalid)` — the design canvas
has no mobile breakpoint, so its own 375px reference degenerates into a 432px
vertical nav stack. Recording that as "not comparable" rather than manufacturing
a PASS is the correct call and is the reason the audit is trustworthy. Closed.

### A-1 — Header language toggle and CTA clipped below ~543px — CLOSED (verified independently)

The audit's blocking finding. Fixed in one line on the header's inner container
(`SiteHeader.astro:16`), the only production change in the rework:

```
-<div style="...display:flex;align-items:center;gap:28px">
+<div style="...display:flex;align-items:center;justify-content:flex-end;flex-wrap:wrap;gap:10px 28px">
```

Verified against the current build by this reviewer, not via the story report.
Rendered with the bundle orchestrator against the current integration HEAD
(`render-running-app.js --project=<worktree> --route=/ --breakpoints=320,375,414,540,600,1280`,
exit 0), plus `/legal/` at 320/375 and `/zodiac/` at 375:

| Viewport | theme | VI/EN | CTA | verdict |
|---|---|---|---|---|
| 320 | visible | visible | visible | control cluster wraps to row 3, fully inside viewport |
| 375 | visible | visible | visible | cluster wraps to row 2, fully inside viewport |
| 540 | visible | visible | visible | cluster wraps to row 2, fully inside viewport |
| 1280 | visible | visible | visible | single row, unchanged |

Every control A-1 reported as clipped and pointer-unreachable is now rendered
inside the viewport at the narrowest width in A-1's own table (320px), on the
home, legal and zodiac routes. The shell is a single shared component touched
only by STORY-001 (`git log a648a5a..HEAD -- web/src/components/shell/`), so this
holds for all 8 screens.

**Desktop non-regression, measured rather than asserted.** The audit's
`screenshots/impl-home-1280.png` was captured at HEAD `33e8e17`, i.e. *before*
the rework, which makes it an exact pre-rework baseline. Diffing this reviewer's
post-rework 1280 render against it (both 1280×2048, per-pixel max-channel delta):

| Band | pixels over 24/255 | mean delta | max delta |
|---|---|---|---|
| Rows 0–79 (the 70px desktop header) | **0.0000%** | 0.03 | **1** |
| Full page | 0.8811% | 1.018 | 233 |

The header band is pixel-identical within a max channel delta of 1. The first
differing row anywhere on the page is row 134 — below the header — so the header
occupies identical pixels and nothing downstream is shifted; a height change
would have moved the header's bottom border inside rows 0–79 and did not. The
residual 0.88% below row 134 is the decorative starfield variance the audit
already characterised, not a layout delta (a real shift produces the 15–31%
signature seen in the audit's 768px reference analysis, not 0.88% at mean 1.0).

The CSS reasoning matches the measurement: the logo already carries
`margin-right:auto`, and an auto margin absorbs all positive free space before
`justify-content` is applied, so on a single-line desktop header
`justify-content:flex-end` is a no-op. It only takes effect once `flex-wrap:wrap`
produces a second line. This is why the fix is zero-tradeoff on desktop.

### INT-4 — `req_master.md` Configuration Documentation stale — CLOSED

Verified on `main` (commit `30d12e3`), which is canonical for this file.
`Status: NOT_REQUIRED` → `Status: REQUIRED`; `Pending User Setup: NONE` →
all three items recorded in full, including the VPS Caddy site block, the
unprovisioned `VPS_WEB_DEPLOY_PATH` secret, and the SSH forced-command scope risk
carried verbatim as `UNVERIFIED RISK, confirm before first real deploy`;
`Last Updated: 2026-08-22`. Closed.

### INT-5 — `req_master.md` story table showed STORY-002..008 `PENDING` — CLOSED

Verified on `main`: all 8 stories now read `DONE`. Closed.

**Correction to the premise, recorded because it was stated as established
fact.** The handoff asserts `req_master.md` "never flows through story
git-boundaries onto the integration branch". That is not accurate — three
STORY-001 commits on this branch do touch it (`cd64579`, `059d286`, `4357536`).
The conclusion survives anyway, and this reviewer verified *why* rather than
accepting it: a simulated merge (`git merge-tree --write-tree main HEAD`)
auto-merges `req_master.md` with no conflict, and the resulting blob carries
`Status: REQUIRED`, all three Pending User Setup items, and all 8 stories `DONE`.
The two sides edited disjoint hunks — `main` the Configuration block and the
story table, the integration branch the trailing `Design-Source:` line. INT-4 and
INT-5 therefore survive the closing merge intact. This was worth checking
directly: had the hunks overlapped, closing REQ-006 would have silently reverted
its own state fixes.

## Deferred Findings

### New this pass

- **D-INT-4 — merging this branch into `main` will conflict on 4 files; one
  resolution would destroy a shared contract.** `git merge-tree --write-tree main
  HEAD` reports conflicts in `data/devops/system/design-fidelity-config.json`
  (content) and, add/add, `STORY-002/review/review-report.md`,
  `STORY-002/ux/uiux-spec.md`, `STORY-002/visual-fidelity/visual-fidelity-report.md`
  (these three from `main`'s own evidence-sync commit `28be79c`, so either side
  is equivalent). The config is the consequential one and must not be resolved by
  taking this branch's side: `main` carries a **newer, restructured multi-surface
  config** (detected `2026-08-22T02:17:06Z`) with a `design_sources[]` array
  holding both `cupid-app` (mobile) and `cupid-web` (web), while this branch
  carries the older single-surface form locked to `Cupid Web.dc.html`
  (`2026-08-21T10:18:35Z`). Taking this branch's version would delete
  `design_sources[]` and the mobile surface entry with it. Not blocking: this is
  a Scrum-Master-owned merge operation, `git-story-boundary.sh merge` pauses on
  conflict rather than auto-resolving, and no silent-loss path exists. Recorded
  so the resolution is a decision rather than a discovery.
  **Resolution: keep `main`'s `design_sources[]` structure.**
- **D-INT-5 — mobile nav `<select>` displays "Trang chủ" on `/legal/`.** Observed
  while verifying A-1 at 320/375. `legal` is deliberately absent from `navItems`
  (`site-nav.ts:28` — footer-only, faithful to `Cupid Web.dc.html:715-718`), so
  no `<option>` is selected and the browser falls back to displaying the first
  one, implying the user is on Home. Desktop is consistent (no nav pill
  highlighted) because a `<select>` must always display something and a `<nav>`
  need not. Pre-existing since the STORY-001 P2 shell and not worsened by the A-1
  rework — the `<select>` was already visible at these widths in the audit's
  `finding-A1-header-clipped-375.png`. A disabled placeholder option would fix
  it. Cosmetic; route with the mobile UX pass below.

### Carried forward from pass 1 and the audit (re-confirmed, not re-litigated)

- **V-1** (STORY-003) — daily-compatibility sign row overflows its card by 5px
  right / 4px left at 375px; design-source-inherited from
  `Cupid Web.dc.html:293`. Owner: UI/UX Designer.
- **D-INT-1** (widened by the audit) — 8 inconsistent page `<title>` patterns,
  and only 3 of 8 respond to the language toggle, so a user browsing in English
  sees a Vietnamese tab title on 4 screens. Owner: Product Owner → Frontend
  Developer.
- **D-INT-2** — STORY-002 evidence captured on port 21023, which the runtime
  registry reserves for `docs`. Evidence hygiene only; the evidence itself is
  sound and server identity was verified before capture.
- **D-INT-3** — per-story deferred findings needed a landing point; the audit
  provided it and now carries V-1 and D-INT-1 explicitly.
- **DEF-8** (STORY-001) — one stale CSS-property sentence in `uiux-spec.md` §6.1:
  the alignment *mechanism* named there was superseded by the
  `justify-content:flex-end` fix after the literal spec text caused a desktop
  regression. The section's stated *intent* still matches shipped code.

`V-1`, `D-INT-5` and the mobile half of `A-1`'s history share one root cause —
the locked design source has no mobile breakpoint — and belong in a single UI/UX
mobile pass rather than three separate patches.

## Traceability

- **"giống 100%" visual-fidelity acceptance** (`req_master.md` Business Scope):
  now evidenced for all 8 screens. STORY-001 (home) and STORY-002 (pets) carry
  story-level rendered-vs-rendered evidence; the other six carry it at
  requirement level via `frontend-visual-audit.md` Part B, `PASS` at 1280 and 768
  on all six, with 375 recorded as not comparable for a documented and verified
  reason.
- **"global chrome built exactly once in STORY-001, reused unmodified"**
  (`requirements.md:80-83`): still VERIFIED CLEAN after the rework.
  `git log a648a5a..HEAD -- web/src/components/shell/ web/src/layouts/ web/src/data/site-nav.ts web/src/styles/ web/src/scripts/`
  shows the A-1 rework as a STORY-001 commit; no other story forked the shell.
- **"no backend endpoint change"** (`requirements.md:86-88`): VERIFIED CLEAN, the
  diff touches no `backend/` path.
- **Open questions**: OQ-REQ006-1 resolved by STORY-001 (Astro, `output: 'static'`);
  OQ-REQ006-2 resolved, consistent with the shipped tree.
- **Configuration guide**: `deployment/configuration-guide.md` is accurate and
  `req_master.md` on `main` now points at it correctly with its three pending
  user-setup items surfaced.
- **Story gates**: all 8 story reviews record `Outcome: DEFERRED_ONLY`;
  STORY-001's report records the A-1 rework as Pass 3 with 0 blocking.

## Pre-Deploy Items For The User (not review blockers)

`req_master.md` records `Production: REQUESTED`. Before the first production
deploy, three items from `configuration-guide.md` still need a human:

1. Append the `cupidus.app, www.cupidus.app` Caddy site block to
   `/etc/caddy/Caddyfile` on the VPS (`:82-98`).
2. Provision the `VPS_WEB_DEPLOY_PATH` GitHub Actions secret — currently a
   placeholder (`:110`).
3. Confirm the SSH forced-command wrapper accepts the
   `cd ${VPS_WEB_DEPLOY_PATH} && ` prefix, widen it, or provision a separate
   `VPS_WEB_SSH_PRIVATE_KEY` (`:115-131`). This is the item most likely to fail
   the first real `deploy-web.yml` run.

## Workflow State Recommendation

- Requirement status: `DONE` — this gate returns `DEFERRED_ONLY`, which satisfies
  the requirement-integration closure condition.
- Story status: `N/A` — all 8 member stories are TERMINAL and merged; no finding
  reopens one.
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: merge `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`
  into `main`, resolving the 4 conflicts per D-INT-4 — in particular keeping
  `main`'s `design_sources[]` multi-surface config. Then mark REQ-006 `DONE`.
  Deployment remains a separate, explicitly user-instructed step gated on the
  three pre-deploy items above.
- State update owner: `scrum-master` only. Reviewer does not edit requirement
  status files.
