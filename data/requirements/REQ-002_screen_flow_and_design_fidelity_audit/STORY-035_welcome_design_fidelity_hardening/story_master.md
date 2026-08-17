# Story Master: STORY-035 Hardening - Welcome Screen Visual Fidelity Evidence

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-004_welcome_design_fidelity
Scope: Retro-hardening (RWB-20260816-002)
Screen: welcome, Epic 1 (Core connection / onboarding), NO_CHROME / NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [x] Implementation (Development) — rework for review cycle 1 applied
  2026-08-16. F1 CLEARED: `Positioned.fill(child: CupidStarField())` added as
  the last child of a `StackFit.expand` Stack over the welcome backdrop, guarded
  by a new widget test, re-captured and re-measured (all three particles within
  0.8 logical px of the reference, no landmark regression). F2 CLEARED:
  `coding-plan/test-results.md` now carries `## Entry Point Reachability`
  (`Reachable: YES`, `splash_screen.dart:113`) and `## Story Runtime Startup
  Smoke` run against the real `lib/main.dart` entry point — passed, so no
  `Runtime-Smoke: WAIVED` is claimed. Checked because both in-Write-Scope
  blocking findings (F1, F2) are cleared; D1, the backdrop gradient axis in
  `mobile/lib/design_system/tokens/cupid_color_tokens.dart`, was already
  Reviewer-confirmed in cycle 1 as correctly out of this phase's Write Scope
  and routed separately, so it does not gate this phase's own implementation
  checkbox. AC2's `VISUAL_FIDELITY: PASS` and AC3's "no visible deviation" were
  deliberately withheld while D1 stood; both are now recorded, since P1 below
  resolved D1 (`visual-fidelity/visual-fidelity-report.md` 4.3 and 7).
- [x] Review (Reviewer) — cycle 2, `Outcome: DEFERRED_ONLY` (0 blocking
  findings, 1 deferred: D1). F1 and F2 independently re-verified RESOLVED by
  Reviewer (`review/review-report.md`, Iris-QC, 2026-08-16). D1 was correctly
  deferred as of this cycle, but the user then explicitly chose to widen this
  story's Write Scope and fix D1 inline rather than route it separately — see
  Phase P1 below. Cycle 2's DEFERRED_ONLY verdict stands as history. Cycle 3
  (below) covers Phase P1 and closes the story.
- [x] Review (Reviewer) — cycle 3, `Outcome: CLEAN` (0 blocking findings, 0
  deferred findings). D1 independently re-measured by Reviewer using a
  different method from mobile-dev's (least-squares plane fit of the blue
  channel vs. mobile-dev's sub-pixel iso-colour-line analyzer): 14.99-15.01
  deg vs the design's 15.00 deg — RESOLVED. All AC1-5 PASS. `review/
  review-report.md` cycle 3, Iris-QC, 2026-08-17. Reviewer flagged a commit-
  hygiene note (the two new P1 files are untracked and must be staged
  explicitly, not via `git add -u`/`git commit -a`, since `cupid_color_
  tokens.dart` imports `cupid_css_angle_gradient.dart`) — handled at story
  boundary completion below.
- [x] Implementation P1 (D1 gradient-axis fix) — DONE 2026-08-17. D1 RESOLVED:
  welcome's backdrop axis now measures **15.01 deg** off vertical against the
  design reference's 14.98 deg, up from **6.86 deg** pre-fix, and all four corner
  colours agree within 1/255 (the extent half of the CSS contract, not just the
  axis). Fix is a new `CupidCssAngleGradient extends LinearGradient` overriding
  `createShader`, wired into the four `gradientBrandBackdrop` / `gradientHot`
  construction sites; colours, stops, `Alignment` constants,
  `gradientDream` / `_gradient120*` and all ~20 consumer widget files untouched.
  The ~20 `gradientHot` consumers are covered numerically by a box-shape matrix
  test (4 aspect classes, angle and extent to 1e-9, plus explicit assertions of
  the pre-fix math's wrong values so the matrix cannot pass vacuously) per Tech
  Lead's sizing decision. Gates all green: axis test 15/15, full `flutter test`
  `+1264 ~2` 0 failures, `no_fork_guard_test.dart` 1/1, all 7
  `*_design_fidelity_test.dart` 50/50, `flutter analyze` 0 attributable,
  `flutter build apk --debug` on both entry points.
  `visual-fidelity/visual-fidelity-report.md` now records
  `VISUAL_FIDELITY: PASS`, satisfying AC2, and no visible deviation remains on
  the rendered pair, satisfying AC3. Review cycle 3 covering P1 is still required
  before DONE.

## Depends On
- NONE. Independent of every other REQ-002 hardening item; must not reopen
  STORY-004's or STORY-033's closed git boundary/branch.

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-002 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-004_welcome_design_fidelity's Design Fidelity row `UNVERIFIED`: its own
`visual-fidelity/` directory holds only `visual-fidelity-report.md`, no
images either side. That report's comparison method was reading the
CSS/HTML prototype literally against the Flutter widget tree — the same gap
already tracked as IF-7 in `req_master.md`, and the direct cause of
`BUG-20260816-001` reaching integration undetected. REQ-002's audit verdict
is RED-PATCH.

## In Scope
1. Capture `implemented-welcome-<device>.png` from the running app (dark
   theme + `vi` locale, per STORY-004's own configuration).
2. Render `design-reference-welcome-<platform>.png` via
   `render-design-canvas.js --screen=welcome`. Note:
   `STORY-033_app_shell_design_system_deltas`'s own folder already contains
   a matched `design-reference-welcome-android.png` /
   `implemented-welcome-emulator-5554.png` pair for the same screen — that
   does not satisfy this story's own evidence-pair requirement, but it may
   be reused as a starting reference/baseline if the welcome screen has not
   changed since STORY-033.
3. Re-compare both renders against STORY-004's existing AC1-3 (layout,
   spacing, color/token usage, typography, CTA styling); if any deviation is
   found by the rendered comparison (as opposed to the prior literal
   prototype-vs-widget-tree method), correct it in the app code — this is a
   fix, not merely a re-documentation.
4. Place the matched, same-screen evidence pair in this story's own
   `visual-fidelity/` directory with a `visual-fidelity-report.md` recording
   `VISUAL_FIDELITY: PASS`.

## Out of Scope
- Any screen other than `welcome`.
- Whether welcome is the correct destination for a given session state —
  Scope A (STORY-001/STORY-002) owns entry-point/navigation correctness.
- Light theme / `en` locale visual QA (OQ5 — infra-only, not enabled for
  users yet).
- Any other `RWB-20260816-*` item — each is tracked and worked separately.

## Acceptance Criteria
1. Given the `welcome` screen's implementation, when its comparison against
   `cupid-app-design-system` is performed for this story, then the
   comparison method is rendered-output-to-rendered-output — a rendered
   `implemented-welcome-<device>.png` captured from the running app compared
   against a rendered `design-reference-welcome-<platform>.png` generated by
   `render-design-canvas.js --screen=welcome` — and not the CSS/HTML
   prototype source read literally against the Flutter widget tree.
2. Given the rendered comparison in AC1, when the story is delivered, then
   this story's own `visual-fidelity/` directory physically contains the
   matched, same-screen `implemented-welcome-<device>.png` /
   `design-reference-welcome-<platform>.png` pair plus a
   `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`.
3. Given the welcome screen rendered in the enabled dark theme + `vi`
   locale, when its rendered output is compared against the rendered
   `design-reference-welcome-<platform>.png`, then layout, spacing,
   color/token usage, and typography match exactly with no visible
   deviation.
4. Given any deviation is found by the rendered comparison in AC1-3 (as
   opposed to STORY-004's prior literal prototype-vs-widget-tree method),
   when the story is delivered, then the deviation is corrected directly in
   the app code — not merely re-documented — and re-verified by re-rendering
   both sides and re-comparing.
5. Given the sign-in and create-account CTAs on the welcome screen, when
   their rendered output is compared against the rendered design reference,
   then their styling (Dream Gradient, pill radius, platform-adaptive button
   treatment per `cupid-app-design-system` §3) matches exactly with no
   visible deviation.

## System Integration And Discoverability
- UI-facing story: YES. Existing user-visible surface: the current welcome
  screen, already reachable in the shipped app. No new entry point.

## Dependencies
- Depends on: NONE.

## Open Question Impact
Re-checked against the central registry
(`data/intake/bootstrap/conflicts_open_questions.md`). Only OQ5 (light
theme / `en` locale) is in scope-adjacent to this story; it remains
unresolved at the registry level (build all 4 token/ARB combinations, only
enable dark + `vi` at v1) and, consistent with STORY-004's own precedent
(STORY-004 Out of Scope excluded light/`en` visual QA on the same grounds),
stays out of scope here — no AC above requires light theme or `en` locale
rendering. No other open or resolved registry item constrains this story.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.
