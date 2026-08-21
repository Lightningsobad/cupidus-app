# Review Report — REQ-006 / STORY-002 Pet Universe Showcase Page

Outcome: PATCH_REQUIRED

- Review type: `full-story-review`
- Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/review/scope-gate.md`
- Reviewed at: 2026-08-21
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-002`
- Diff: `88cf9e9a1be14b50db586716fe6eb986da2807df..09c11aa` (5 files, +100/−2)
- Complexity `standard`, lane `frontend`, UI-bearing, `design_source` configured and locked

## Rationale

The code is good. The evidence package is incomplete in three places that the
DONE gate and the reviewer stop gate each enforce independently, so the story
cannot close as written. Nothing found requires a code change to `web/src/**`;
two items are evidence sections the lane can add directly, and one is a design
reference that needs a routing decision.

## Reviewed inputs and code scope

| Kind | Files |
|---|---|
| Changed source | `web/src/pages/pets.astro`, `web/src/components/pets/{PetsHero,PetRoster,GrowthStages}.astro`, `web/src/data/pets-content.ts` |
| Read for entry-point verification | `web/src/layouts/SiteLayout.astro`, `web/src/components/shell/SiteHeader.astro`, `web/src/data/site-nav.ts` |
| Governing | `requirements/requirements.md`, `coding-plan/phase-P1-pets-page-body-and-entry-point.md` §4/§6, `STORY-001/architecture/contract-summary.md` |
| Evidence | `coding-plan/test-results.md`, `STORY-001/visual-fidelity/visual-fidelity-report.md` |
| Design source | `cupid-app-design-system/Cupid Web.dc.html:213-283`, `:679`, `:709`, `:741-747`, `:756-760` (ranged reads) |

Independently re-run by Reviewer, not taken on trust:
`npm run build` PASS (8 static pages, Node v22.17.1);
`astro preview --port 21021` → `GET /pets` 200, `GET /` 200;
three rendered captures of the built page at 375/768/1400.

## Acceptance criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 navigation & active state | PASS | `site-nav.ts:31` `{key:'pets',href:'/pets'}` → `SiteHeader.astro:26` `aria-current={page===it.key?'page':undefined}` and `:12-13` pink pill/`var(--acc-pink)`; `:33` `<option value="/pets" selected={page===it.key}>`; driven by `pets.astro` `page="pets"`. Confirmed in the 1400 and 375 renders. |
| AC-2 hero content | PASS | `PetsHero.astro` matches `Cupid Web.dc.html:215-219` verbatim, both languages; eyebrow correctly left unwrapped as in the source. |
| AC-3 pet roster | PASS | Six cards, design order Bo/Bun/Kem/Mochi/Sua/Xoài, from the shared `pets` array (`:741-747`); sprite, name, trait, description all present in the render. No placeholder. |
| AC-4 growth stages | PASS | `pets-content.ts` `stages` is character-identical to `:756-760`; all four render in `01→04` order. |
| AC-5 theme & language parity | PASS | Every VI/EN pair ships both spans; per-pet tints are literals from the shared array, theme-independent, with Bo `rgba(255,127,182,.12)` and Xoài `rgba(255,127,182,.1)` kept distinct. |
| AC-6 per-page title (DEF-2 carry-forward) | PASS | `pets.astro` `title="Pets — Cupid"` → `SiteLayout.astro:25` `<title>{title}</title>`; layout default is `'Cupid'`, so this is genuinely per-page. |
| AC-7 responsive layout | PASS | 375 render measured at 1:1: card right corner visible, ~13 px right gutter vs 32 px left, nothing clipped, no document h-scroll. See deferred DEF-1. |
| UI-Fidelity-AC | UNVERIFIED | Blocking finding BLK-3. |

## Touched risk surfaces and critical gates

| Risk surface | Gate | Result |
|---|---|---|
| Frontend static page body | `npm run check` / `npm run build` | PASS (build re-run by Reviewer) |
| Frontend discoverability / navigation integration | 12e1 `## Entry Point Reachability` + code verification | Code PASS, evidence section MISSING → BLK-1 |
| Design fidelity (`design_source` configured) | 12e2 rendered comparison | BLOCKED → BLK-3 |
| Runtime / configuration | 12g `## Story Runtime Startup Smoke` | MISSING → BLK-2 |
| Verbatim copy integrity (BR-2/BR-3) | Copy diff vs `:741-747`, `:756-760` | PASS |
| Shell immutability (STORY-001 contract) | Diff path check | PASS — diff touches only the five in-scope files; no `layouts/`, `components/shell/`, `styles/`, `scripts/`, no `home-content.ts` |
| Home regression (`pets` now shared) | Rendered check | PASS |

Configuration guide: phase metadata records `Update Required: NO` and the diff
adds no env var, service, port, or manual setup step. No configuration-guide
change is owed.

## Blocking findings

### BLK-1 — `## Entry Point Reachability` section missing (reviewer rule 12e1)

`coding-plan/test-results.md` has no `## Entry Point Reachability` section and
no `Reachable: YES` line. The substance is present under `## 6. Discoverability
/ Navigation Integration`, and the entry point itself is real: verified in code
at `site-nav.ts:31`, `SiteHeader.astro:26` and `:33`, plus the footer column at
`site-nav.ts:46` and Home's `Meet them all` CTA. So this is a heading/format
gap, not a missing capability — but 12e1 makes the named section non-waivable
and `validate-done-gate.sh` enforces it independently, so the story cannot be
marked DONE without it.

- Owner: `frontend-dev`
- Fix: add `## Entry Point Reachability` to `test-results.md` with
  `Reachable: YES` and the concrete path (header nav `Pets` pill → `/pets`;
  mobile `<select>` option; footer `Dàn pet` / `Pets`; Home `Xem tất cả` /
  `Meet them all` CTA).

### BLK-2 — `## Story Runtime Startup Smoke` evidence missing (reviewer rule 12g)

The story is non-trivial with lane `frontend`, so registry-backed runtime
startup smoke is mandatory. `test-results.md` has no `## Story Runtime Startup
Smoke` section, and `story_master.md` records no `Runtime-Smoke: WAIVED —
<reason>`. The phase file's `Startup Smoke: OPTIONAL` is a Tech Lead
phase-level note; it does not satisfy the story-level gate or the DONE gate.

This is `PATCH_REQUIRED` rather than `BLOCKED` because the smoke demonstrably
runs — Reviewer performed it while preparing the render: `npm run build` PASS,
then `astro preview --port 21021 --host 127.0.0.1` with the registry readiness
check `GET http://127.0.0.1:21021/pets` → 200 (and `/` → 200), server stopped
afterwards.

- Owner: `frontend-dev` (or `devops` if Scrum Master prefers the registry lane)
- Fix: run the `web-frontend` registry startup command, record the section with
  the command, port, readiness result, and shutdown.

### BLK-3 — no rendered design-fidelity comparison (reviewer rule 12e2)

`STORY-002/visual-fidelity/` did not exist at review time: no report, no
`VISUAL_FIDELITY` verdict, no images, and no `Design-Screen` recorded anywhere
in the story. `test-results.md` §4 "Screenshot passes" describes prose
observations only; per 12e2 a typed verdict or a prose comparison is not
evidence, and this requirement's UI-Fidelity-AC ("giống 100%") is precisely the
AC the rendered check exists to protect.

Reviewer owns the render for this lane and performed the half that is possible.
`visual-fidelity/implemented-pets-{375,768,1400}.png` now exist, captured from
the production build with `visual-capture.js --mode=url`. The design half could
not be captured, and the cause is a tooling/config gap rather than an
implementation defect:

- `render-design-canvas.js --list-screens` on `Cupid Web.dc.html` returns
  `{"screens":[],"toggles":[],"platforms":[]}` — the canvas has no
  `[data-screen-btn]`, `[data-tog]` or `[data-plat]`, so `--screen`,
  `--theme`, `--lang` and `--platform` are all inert.
- The Pets screen is the `isPets` branch selected by the `startPage` prop
  (enum declared at `Cupid Web.dc.html:679`, default `home`; consumed at
  `:709`). Neither bundle renderer can set a canvas prop, and the canvas never
  reads the page from the URL, a cookie, or storage — `?startPage=pets` was
  tested and the captured image is the Home screen.
- Reaching it would need a hand-rolled browser script, which 12e2 prohibits;
  and Reviewer must not self-provision `design_source` config, which it did not.

Full detail, including what the implementation renders do establish and a
declaration-by-declaration comparison of `:213-283` against the five
implementation files (every inline style and VI/EN literal reproduced exactly),
is in `visual-fidelity/visual-fidelity-report.md`, recorded as
`VISUAL_FIDELITY: BLOCKED — DESIGN_SCREEN_NOT_FORCEABLE`. That source-level
comparison is deliberately NOT treated as a pass.

- Owner: Scrum Master to route; `ui-ux-designer` to resolve
- Decision needed: how a non-default state of this canvas becomes a
  `design-reference-*.png`. This is not STORY-002-specific — Zodiac, Invite,
  Blog, About, Support and Legal are all non-default `isX` states of the same
  entry, so every remaining REQ-006 page story hits it. Options worth weighing:
  extend `render-design-canvas.js` with a prop/state selector, record a
  per-screen `design_source` entry that pins `startPage`, or grant an audited
  exemption for this canvas at requirement level.

## Deferred findings

### DEF-1 — asymmetric page gutter at ≤394 px, inherited from the design

Below 394 px viewport the roster's `minmax(330px,1fr)` track (design `:220`)
exceeds the section's content box and overhangs it by `394 − viewport` px, so
the right gutter shrinks while the left stays at 32 px (~13 px vs 32 px at
375). Measured at 1:1 on the capture: nothing is clipped and the document does
not scroll horizontally, so AC-7 holds at its declared 375 px floor. The
implementation is faithful to the design value, and changing it is a design
decision, not a page-body one. `test-results.md` §8 raises the same point; note
its 375 px figure measures the card against the viewport edge rather than
against the section content box, so the two descriptions differ in framing, not
in outcome.

### DEF-2 — `test-results.md` §4 overflow assertion is structurally weak

The recorded check is `documentElement.scrollWidth === clientWidth`. The shell
sets `overflow-x:hidden` (`SiteLayout.astro:34`), which makes that comparison
true even when a child overhangs, so it cannot detect the DEF-1 class of issue.
Not blocking here — the rendered measurement independently confirms the page is
clean at 375 — but the assertion should not be reused as the overflow gate for
later REQ-006 page stories.

### DEF-3 — `Design-Screen` was never recorded

No `Design-Screen: <id>` appears anywhere in `STORY-002/`. 12e2 calls this out
as a finding in its own right: when the id is unrecorded, the design screen was
resolved silently and nobody can re-check the choice. Resolved during this
review as `isPets` from the requirement's own design anchor, and recorded in
`visual-fidelity/visual-fidelity-report.md`. Worth making a standing field for
the remaining REQ-006 page stories.

## Traceability

- Requirements: AC-1…AC-7 verified above; UI-Fidelity-AC unverified per BLK-3;
  BR-1 (presentational only — no fetch, no storage write in the diff) PASS;
  BR-2/BR-3 (verbatim copy) PASS against `:741-747` and `:756-760`.
- Architecture: `STORY-001/architecture/contract-summary.md` shell contract
  honoured — `SiteLayout` used as an envelope, `page`/`title` props only, no
  shell file touched, `home-content.ts` unmodified, `data-vi`/`data-en`
  mechanism reused rather than reimplemented.
- OQ discipline: OQ-REQ006-1 and OQ-REQ006-2 are both RESOLVED; the story
  records no blocked scope and none was omitted. No OQ defect.
- Open Question Impact section present and consistent with the implementation.

## Notes for Scrum Master

- `story_master.md` still reads `Status: PENDING` with
  `- [ ] Implementation (Development)` unchecked despite the sealed
  implementation commit. Reviewer does not edit workflow state; flagging it so
  the bookkeeping is corrected as part of the rework routing.
- The handoff declared `WriteScope` as `review/review-report.md` only. Reviewer
  additionally wrote `review/scope-gate.md` (required by skill rule 5 for
  `full-story-review`) and `visual-fidelity/` (required by rule 12e2, which
  assigns the render to Reviewer for non-mobile UI lanes). Future reviewer
  handoffs for UI-bearing stories should declare those two paths.

## State recommendation

- Uncheck `Implementation (Development)`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Route BLK-1 and BLK-2 to `frontend-dev`; route BLK-3 to Scrum Master for a
  requirement-level design-reference decision before re-review.

Blocking findings: 3. Deferred findings: 3.
