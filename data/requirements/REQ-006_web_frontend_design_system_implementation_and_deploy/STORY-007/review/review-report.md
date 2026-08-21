---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-21
reviewed_by: Reviewer
---

# Review Report: STORY-007 Support FAQ Page

Outcome: DEFERRED_ONLY

## Reviewed Inputs

- Review gate: `full-story-review` (pass 2, fresh re-review)
- Scope Gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-007/review/scope-gate.md`
- Requirements: `STORY-007/requirements/requirements.md` (AC-1..AC-7, BR-1..BR-3)
- Bug Report: `N/A`
- Diagnosis: `N/A`
- Fix Evidence: `N/A`
- UX: `STORY-007/ux/uiux-spec.md` §6.1-6.8
- Architecture: `STORY-007/coding-plan/phase-P1-support-faq-page.md` §1B, §4, §6
- Coding Plan: `STORY-007/coding-plan/master-plan.md` (phase inventory / write scope)
- Test Results: `STORY-007/coding-plan/test-results.md` §1-§15 plus
  `## Entry Point Reachability` and `## Story Runtime Startup Smoke`
- Previous review findings: pass-1 `review/review-report.md` — BLK-1, ACT-1,
  ACT-2, DEF-1, DEF-2. All five re-verified against current worktree state
  (see Blocking Finding Verification).
- Governing evidence standard:
  `REQ-006/design-fidelity-tooling-fix.md`, "User decision (2026-08-21, second
  decision on this doc)"

## Reviewed Scope

- Story complexity: `standard` (lane `frontend`)
- Bug status: `N/A`
- Code scope reviewed: `git -C <Worktree> diff 2e72902d` — one tracked source
  file, `web/src/pages/support.astro` (+48/-2). Read in full (small file, direct
  review target). Read-only cross-checks for AC-1:
  `web/src/data/site-nav.ts:29-37,52-60`,
  `web/src/components/shell/SiteHeader.astro:21-35`. Design source
  `cupid-app-design-system/Cupid Web.dc.html:614-637` read as a range.
- Evidence reviewed: `test-results.md`; 26 implementer PNGs plus 3 PNGs and a
  `visual-fidelity-report.md` produced by this review; both copies of
  `data/devops/system/design-fidelity-config.json` (worktree and control
  checkout).
- Risk surfaces reviewed: frontend interaction (native disclosure), frontend
  discoverability/navigation integration, typed contract/build, rendered visual
  fidelity, runtime/configuration, shared-shell contract.
- Critical gates reviewed: build/type-check, entry-point reachability (12e1),
  story runtime startup smoke (12g), rendered visual fidelity (12e2 under the
  REQ-006 standard), shell diff containment.
- Backend targeted verification gates: `NOT_APPLICABLE`
- Story runtime startup smoke: `PASS`
- Frontend targeted verification gates: `PASS`
- Frontend discoverability/navigation integration: `PASS`
- Requirement frontend visual audit: `NOT_APPLICABLE` — per reviewer rule 12g1
  the per-story rendered check is the visual gate and it passed; no
  requirement-level audit was routed.
- Mobile targeted verification gates: `NOT_APPLICABLE`
- Mobile discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement mobile visual audit: `NOT_APPLICABLE`
- Story artifacts reviewed: `story_master.md`, `requirements.md`,
  `uiux-spec.md`, `phase-P1-support-faq-page.md`, `test-results.md`, pass-1
  `review-report.md`
- Bug artifacts reviewed: `N/A`
- OQ context reviewed: `requirements.md` `## Open Question Impact` —
  OQ-REQ006-1 and OQ-REQ006-2 both RESOLVED, empty BLOCKED list, populated
  NOT-BLOCKED list. Nothing in the implementation is gated on an open question,
  and no unblocked AC was omitted on OQ grounds.

## Outcome Summary

- Review outcome: DEFERRED_ONLY
- Rationale: all seven acceptance criteria pass on independently verified
  evidence, and the three gates that blocked pass 1 are now closed. AC-6 was
  the pass-1 blocker; under the user-confirmed REQ-006 standard I produced the
  required implementation-side `render-running-app.js` capture at 375/768/1280
  against this branch's freshly built app and compared it to `uiux-spec.md`
  §6.1-6.3/§6.8 and the cited `Cupid Web.dc.html` lines — no visible deviation.
  ACT-1 and ACT-2 are closed by canonical evidence sections in
  `test-results.md`, both re-verified in code and against the registry contract
  rather than accepted on trust. What remains is four deferred items, none
  caused by this story's code.
- Blocking findings: 0
- Deferred findings: 4
- Dismissed observations: 1

### Acceptance criteria

| AC | Verdict | Evidence (independently verified) |
|---|---|---|
| AC-1 nav entry point | PASS | `site-nav.ts:36` puts `support` in `navItems`; `SiteHeader.astro:21-30` renders it as a real `<a href="/support">` in the desktop `<nav data-nav>` and `:31-35` as an `<option value="/support">` in the mobile `<select data-navm>`; `site-nav.ts:58` repeats it in the footer Company column. Confirmed visually: the 1280 render shows `Hỗ trợ` in the pink `aria-current` pill, the 375 render shows the `<select>` on `Hỗ trợ`. Discoverable, not direct-URL-only. |
| AC-2 heading + 6 entries | PASS | Diff maps a 6-element `faq` array to six `<details>`; all six questions render in the 375/768/1280 captures under the `Câu hỏi thường gặp` heading. |
| AC-3 / BR-3 independent disclosure | PASS | Zero `name` attributes on the six `<details>` in the diff, so each is an independent native disclosure; the page ships no script. `test-results.md` §7 records `010010` for two simultaneously open entries, and `implemented-support-*-entry3-open.png` shows entry 3 open with the other five closed. |
| AC-4 / BR-2 contact block | PASS | `href="mailto:hi@cupid.app"` verbatim in the diff; one `mailto:` anchor, no form/handler/fetch. Visible in all three captures. |
| AC-5 bilingual | PASS | Every string ships as a `data-vi`/`data-en` pair in the diff; all six VI questions and both VI contact strings match `Cupid Web.dc.html:814-821` and `:631-632`. `test-results.md` §3: 37/37 pairs, 0 blank spans across 16 width×theme×lang runs. |
| AC-6 visual fidelity | **PASS** | `visual-fidelity/visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS`, per-breakpoint verdicts at 375/768/1280 from this review's own `render-running-app.js` capture. Byte-level inline-style equivalence against `Cupid Web.dc.html:615-635` re-derived by the reviewer. See DEF-3 for the design-reference-side limitation. |
| AC-7 per-page `<title>` | PASS | Diff passes `title="Hỗ trợ & FAQ · Support & FAQ — Cupid"` to `SiteLayout`; `SiteLayout`'s `'Cupid'` default is unchanged (it is what the *other* worktree's server still serves — see the DEF-3 note on the port probe). |
| Shell immutability (STORY-001 contract §6) | PASS | `git diff --name-only 2e72902d` lists exactly one tracked source file. Nothing under `layouts/`, `components/`, `styles/`. |

## Traceability Summary

- Requirements: AC-1..AC-7 and BR-1..BR-3 all traced above. BR-1 (static seed
  content) holds — the `faq` array is a literal in the page, no CMS/API. BR-2
  holds — one static `mailto:` anchor. BR-3 holds — native `<details>`, no
  `name` grouping, no accordion library.
- Bug report: `N/A`
- Diagnosis: `N/A`
- Open Questions: both requirement-level OQs RESOLVED; OQ discipline clean, no
  over- or under-application.
- UX: `uiux-spec.md` §6.1 (50px heading held at 375 with no invented mobile
  downscale — the specific deviation §6.1 forbids, confirmed absent in the 375
  capture), §6.2 (no `details[open]` icon treatment added — confirmed absent in
  the diff), §6.3 (contact card wrap behaviour — confirmed at 375), §6.6 (focus
  rings `2px var(--acc-pink)` offset `2px`, icon `aria-hidden`), §6.8 (fidelity
  scope and responsive checkpoints).
- Architecture: `phase-P1-support-faq-page.md` §4 AC and §6 Test Scope. Write
  Scope (`web/src/pages/support.astro`) respected exactly; the `npm install`
  `package-lock.json` drift was reverted and the diff re-verified. §60-62
  records `Update Required: NO` for the configuration guide — correct, the
  story adds no env var, integration, or manual setup step.
- Testing evidence: `test-results.md` §1-§15 plus the two canonical gate
  sections. I did not rerun `npm run check`; I did rerun `npm run build`
  indirectly, since `app_render.start_cmd` builds before serving and the render
  succeeded — which is independent confirmation that the branch builds.

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Frontend interaction (native disclosure) | AC-3, BR-3, UX §6.2 | independent open/close, no JS state | PASS | 0 `name` attributes in the diff; §7 measured `010010` |
| Frontend discoverability / navigation | AC-1, reviewer 12e1 | `## Entry Point Reachability` + code verification | PASS | Section present with `Reachable: YES`; nav wiring read in `site-nav.ts` and `SiteHeader.astro`, not accepted on trust |
| Typed contract / build | phase §6 | `astro check`, `astro build` | PASS | §1: 0/0/0, 8 pages; build re-run by the renderer's `start_cmd` |
| Rendered visual fidelity | AC-6, UX §6.8, reviewer 12e2 | bundle-renderer capture + comparison | PASS | `visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS`, 375/768/1280; design-reference side per the REQ-006 standard (DEF-3) |
| Runtime / configuration | reviewer 12g | `## Story Runtime Startup Smoke` | PASS | Registry `web-frontend`, `GET /` → 200, `GET /support/` → 200, leased port, clean teardown |
| Shared shell contract | STORY-001 §6 | diff containment | PASS | One tracked source file |
| Browser runtime signals | phase §6 | console errors / failed requests | PASS | §11: 0 and 0 across 16 runs |

## Blocking Finding Verification

Re-verification of every pass-1 finding against current worktree state:

- **BLK-1 (AC-6 rendered comparison not producible) — RESOLVED.** The
  implementation-side render now works: `render-running-app.js` exited 0 and
  produced `implemented-support-{375,768,1280}.png` from this branch's built
  app. The design-reference side remains impossible for non-`home` screens, but
  the user-confirmed standard in `design-fidelity-tooling-fix.md` makes that a
  DEFERRED record (DEF-3), explicitly "not grounds for
  `PATCH_REQUIRED`/`BLOCKED` on its own". Two details worth recording because
  they are how this could have gone wrong silently: the story branch's own
  `design-fidelity-config.json` still has no `app_render` block (its base
  predates Fix 1), so the renderer had to be pointed at a reviewer-local scratch
  project root; and the pinned port 21021 was already serving a *different*
  worktree (`<title>Cupid</title>`, **0** `<details>` — the pre-STORY-007 empty
  page), so capturing there would have produced a confident PASS against the
  wrong code. Method and both deviations are recorded in
  `visual-fidelity/visual-fidelity-report.md`.
- **ACT-1 (missing `## Entry Point Reachability`) — RESOLVED.**
  `test-results.md` now carries the canonical heading with `Reachable: YES`,
  the concrete `/support` path, and three navigation-verified entry points. I
  independently confirmed the wiring in `site-nav.ts` and `SiteHeader.astro`
  and saw the active nav state in the renders.
- **ACT-2 (missing runtime startup smoke) — RESOLVED.** `test-results.md` now
  carries `## Story Runtime Startup Smoke` with `Runtime-Smoke: PASS`, run
  against the registry's declared readiness contract on a devstack-leased port
  with recorded teardown. The implementer correctly overrode the phase file's
  earlier `NOT_APPLICABLE` judgement after consulting the registry, and ran the
  smoke for real rather than taking the waiver — the right call.
- **DEF-1 (375px shell header clipping) — STILL PRESENT, still deferred.**
  Reconfirmed in this review's own `implemented-support-375.png`: only logo,
  mobile `<select>` and theme button are visible; the VI/EN toggle and `Tải app`
  CTA are clipped. Shell-owned, STORY-007 touched no shell file.
- **DEF-2 (`app_render` missing from config) — PARTIALLY RESOLVED.** Fix 1
  landed on `main`; it is absent from this story branch. Restated as DEF-4.

## Deferred Findings

- **DEF-1 (shell / STORY-001, pre-existing — do not fix in this story)** — at
  375px the shared header row clips: the VI/EN toggle and `Tải app` CTA are cut
  off at the right edge. `SiteLayout.astro:34`'s wrapper carries
  `overflow-x:hidden`, so the clipped content produces no
  `scrollWidth > clientWidth` — which is why `test-results.md` §10 reports 0
  overflow occurrences in good faith and why STORY-001's own report claims all
  five controls fit on one row at 375. They do not. Affects every page; route as
  a shell fix or a queued bug at requirement level.
- **DEF-3 (tooling, requirement-wide, recorded once per story)** — no
  screen-specific `design-reference-support-<bp>.png` exists, because
  `render-design-canvas.js` can only drive this canvas to its default
  `startPage: "home"` and Fix 2 is structurally blocked (the renderer is
  gitignored, generated bundle output from a separate source repo). Per the
  user decision in `REQ-006/design-fidelity-tooling-fix.md` the
  design-reference side is satisfied by `uiux-spec.md` §6.1-6.3/§6.8 plus the
  cited `Cupid Web.dc.html:614-637` line range, which I compared against
  directly. Not a defect to re-open at story level; closing it is an
  out-of-repo bundle-source task.
- **DEF-4 (config drift, requirement-level)** — this story branch's
  `data/devops/system/design-fidelity-config.json` has no `app_render` block,
  so `render-running-app.js` exits `4 APP_RENDER_NOT_CONFIGURED` against the
  worktree as-is. Fix 1 exists only on `main`. Separately, `main`'s copy of that
  file names a different `design_source` (`Cupid App.dc.html`, the mobile
  canvas) than the REQ-006 branches do (`Cupid Web.dc.html`), so merging the two
  copies is not purely additive. Worth resolving deliberately at the
  requirement integration gate rather than by whichever side wins a merge —
  otherwise the next REQ-006 story reviewer hits the same wall this review had
  to work around.
- **DEF-5 (documentation accuracy, cheap)** —
  `phase-P1-support-faq-page.md:199-201` and `test-results.md` §13.3 both state
  the bundle renderers are "not present in this worktree or anywhere under
  `$HOME`". That is incorrect: both exist at
  `/Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime/tools/`
  (gitignored, hence absent from the worktree), and this review used
  `render-running-app.js` successfully. Left uncorrected, the note invites the
  next reader to dismiss the working path as impossible. Also worth aligning:
  `phase-P1` §1B still records `Startup Smoke: NOT_APPLICABLE` while
  `test-results.md` records a real `Runtime-Smoke: PASS`.

### Dismissed observation

- The `--full-page` capture at 1280 shows roughly 850px of empty page
  background below the footer. This is the renderer's tall capture viewport
  interacting with the shell's full-height background layer, not page content —
  the same shell renders correctly in the implementer's viewport-sized 1440
  captures. Not a finding.

## Implementation Action Items

None. No rework is required from any implementation lane.

## Workflow State Recommendation

- Story status: `DONE`
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: `story_master.md` still records `Status: PENDING` with both
  `Implementation (Development)` and `Review (Reviewer)` unchecked, despite
  frontend-dev commit `a0807a8` and boundary commit `32ba71e`. Scrum Master
  should reconcile that bookkeeping, check both boxes, mark the story `DONE`,
  and merge `codex/REQ-006_..._-STORY-007` into
  `codex/REQ-006_..._-integration`. DEF-1 and DEF-4 should be carried to the
  requirement integration gate; DEF-3 needs no further action at story level;
  DEF-5 is an optional documentation touch-up.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
