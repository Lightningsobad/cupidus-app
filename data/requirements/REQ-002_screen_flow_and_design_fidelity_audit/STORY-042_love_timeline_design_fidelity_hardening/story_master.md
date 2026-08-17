# Story Master: STORY-042 Hardening - Love Timeline Visual Fidelity Evidence

Status: DONE
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-025_love_timeline_design_fidelity
Scope: Retro-hardening (RWB-20260816-009)
Screen: Love Timeline (countdown hero + entry list)
Design-Screen: timeline (confirm exact screen id via
`render-design-canvas.js --list-screens`)
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development)
- [ ] Review (Reviewer)

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-009 (source: REQ-002
audit report, `retro-audit/audit-report.md`, self-flagged again in
STORY-025's own round-2 review) found
STORY-025_love_timeline_design_fidelity's Design Fidelity evidence had zero
rendered evidence either side. The review report's own "Residual risks"
section states plainly: "no on-device, emulator or rendered-PNG capture
backs this review... consistent with the rest of the REQ-002 wave."
Verification was source-to-source (design HTML vs. Dart source) plus
widget tests only, never a real screenshot pair.

STORY-025's own review (`review/review-report.md`, round 2, story
merge-eligible after round-1 `PATCH_REQUIRED` B-1 fix) already found/
confirmed 20 deviations fixed in the timeline widgets (AC1-2 MET),
re-checked by the reviewer independently against `Cupid Screens.dc.html`
L691-722, but never visually confirmed against a render.

Findings carried forward from STORY-025's own round-2 review
(`## Round-1 findings status`, `## New minor findings`, `## Residual
risks`) for Product Owner disposition during scoping:
- **M-11** (reviewer-found, directly actionable for this story): the
  preview harness (`main_preview.dart`) reaches the live
  `AccountRepository` for the `timeline` entry, so an unauthenticated/
  unseeded preview session shows NO countdown hero — the screen's single
  most fidelity-critical element (gradient card, progress ring, countdown
  numerals) would be entirely absent from any capture without a seeded
  `relationshipStartDate` fixture. PO should scope this as a required
  fixture-setup step for this story's own evidence pass (mirror
  STORY-040/041's dev-only `PREVIEW_*` define pattern), not a separate
  rework item, since the capture is unusable without it.
- **D-1**: deferred to consolidated STORY-032 (shared app-shell
  background), unchanged/untouched "as instructed" per round 2 —
  STORY-032 is itself DONE; PO to confirm this is fully superseded / re-
  confirm out of scope for a screen-scoped hardening story.
- **M-4**: 9.5px-floor spacing inconsistency between STORY-025 and
  STORY-028 (`shared_expenses`); the reviewer explicitly flagged this as
  "not resolvable inside either story" and deferred it to requirement
  integration review — carry forward as note only, not this story's scope.
- **M-5**: feature-local `viEn` string literals instead of ARB entries —
  l10n consolidation debt, same blocker class as REQ-002's other
  l10n-blocked deltas (D-01/D-02/D-03 pattern from the anti-ghosting
  cycle) — re-confirm out of scope.
- **M-2/M-3** (dash pattern / stroke straddle) and the conic-ring seam:
  the report's own residual risks flag these as "most likely to differ
  once actually rendered" — this story's real render is the first chance
  to check them; PO should scope an explicit re-verification AC (mirror
  STORY-041's R-2 fold-in-as-AC pattern) rather than deferring again.
- **M-8/M-9/M-10/M-12**: non-blocking implementation-quality notes
  (async countdown layout shift, no caching, narrow catch clause, format
  scope wording) unrelated to visual fidelity — re-confirm out of scope,
  no action expected.

STORY-025's own `story_master.md` stays undisturbed (documented-not-
resolved in Background only), its closed git boundary/branch not reopened.

Exact remediation steps: see `rework-backlog.md` RWB-20260816-009 detail
section (already written, do not re-derive).

Disposition decisions (Product Owner):
- **M-11 — required fixture-setup, folded in as AC1.** Confirmed directly
  actionable and blocking for this story's own evidence pass: without it
  there is no countdown hero to photograph at all.
  `mobile/lib/main_preview.dart`'s `'timeline'` entry
  (`PreviewScreenEntry`) currently builds
  `TimelineScreen(createCubit: () => TimelineCubit(getIt<TimelineRepository>()))`
  with no `accountRepository` argument. `TimelineScreen`'s
  `_CountdownSection` already accepts an optional `accountRepository`
  parameter and falls back to `getIt<AccountRepository>()` only when it is
  omitted (`mobile/lib/features/timeline/presentation/screens/timeline_screen.dart`),
  so the seam to inject a fixture already exists — no new widget
  constructor parameter is needed, only a preview-side fixture value. Mirror
  STORY-017's `PREVIEW_HOME_FIXTURE` / `_previewHomeProfile` pattern (same
  file, `_buildHome`): add a dev-only `--dart-define=PREVIEW_TIMELINE_FIXTURE=true`
  guard that hands the `'timeline'` entry a fixture `AccountRepository`
  resolving a `CupidProfile` with a seeded `relationshipStartDate`, so the
  countdown hero (gradient card, progress ring, countdown numerals) renders
  deterministically without a live authenticated session.
- **D-1 — confirmed out of scope, fully superseded.** STORY-032 (shared
  app-shell background) is `DONE`, so the deferral this finding names has
  already landed elsewhere. Re-confirmed out of scope for this
  screen-scoped hardening story; no shared app-shell file touched here.
- **M-4 — confirmed out of scope, note only.** The reviewer already
  determined this cross-story 9.5px-floor spacing delta (STORY-025 vs.
  STORY-028) is "not resolvable inside either story" and deferred it to
  requirement integration review. A single screen-scoped hardening story
  cannot resolve a cross-story inconsistency; carried forward as a note
  only, no `timeline` file changed to chase this.
- **M-5 — confirmed out of scope.** Feature-local `viEn` literals instead
  of ARB entries is l10n consolidation debt, the same blocker class as the
  D-01/D-02/D-03 pattern already re-confirmed out of scope in every prior
  REQ-002 hardening story (`mobile/lib/l10n/arb/` is outside a
  screen-scoped story's `WriteScope`). Re-confirmed out of scope; no l10n
  file touched by this story.
- **M-2/M-3 + conic-ring seam — re-verification folded in, AC4.** Not
  deferred again. `timeline_dashed_border.dart`'s hand-rolled
  `_DashedBorderPainter` (`_dashPattern = [6, 4]`, used by the "Add a
  memory" pill and photo placeholder frame) and
  `timeline_countdown_card.dart`'s `TimelineProgressRing` (`SweepGradient`
  with a `-pi/2` `GradientRotation` reproducing the CSS
  `conic-gradient`'s 12-o'clock start) are exactly the kind of pixel-level
  detail a widget test's token assertions cannot catch but a real render
  can. This story's rendered capture is the first opportunity to check
  both; mirroring STORY-041's R-2 disposition, this is scoped as an
  explicit re-verification AC with a "fix if the render surfaces a
  mismatch" posture, not a further deferral.
- **M-8/M-9/M-10/M-12 — confirmed out of scope, no action.** Non-blocking
  implementation-quality notes (async countdown layout shift, no caching,
  narrow catch clause, format scope wording) unrelated to visual fidelity.
  Re-confirmed out of scope; no AC needed, carried forward as notes only.

## Depends On
- NONE. Independent of every other REQ-002 hardening item; must not reopen
  STORY-001's, STORY-002's, STORY-004's, STORY-006's, STORY-011's,
  STORY-014's, STORY-015's, STORY-018's, STORY-019's, STORY-022's,
  STORY-025's, STORY-034's, STORY-035's, STORY-036's, STORY-037's,
  STORY-038's, STORY-039's, STORY-040's, or STORY-041's closed git
  boundary/branch.

## User Story
As a Product Owner verifying REQ-002's design fidelity claims, I want the
Love Timeline screen's fidelity evidence to be a real rendered-to-rendered
comparison (an implemented app screenshot, captured with a seeded
`relationshipStartDate` fixture so the countdown hero actually renders, vs.
a rendered design canvas) that re-confirms all 20 of STORY-025's
originally-fixed deviations and directly re-checks the dashed-border dash
pattern, progress-ring stroke straddle, and conic-ring seam, so that the
screen's claimed fix is backed by proof instead of a token/widget-test-only
reading.

## In Scope
1. Add a dev-only preview fixture so the countdown hero is capturable:
   extend `mobile/lib/main_preview.dart`'s `'timeline'` entry with a
   `--dart-define=PREVIEW_TIMELINE_FIXTURE=true` guard (mirroring
   `_buildHome`'s `PREVIEW_HOME_FIXTURE` / `_previewHomeProfile` pattern)
   that supplies `TimelineScreen`'s existing optional `accountRepository`
   parameter with a fixture resolving a `CupidProfile` carrying a seeded
   `relationshipStartDate`, so the gradient card, progress ring, and
   countdown numerals render without a live authenticated session.
2. Capture `implemented-timeline-<device>.png` with the seeded countdown
   fixture active, in dark theme + `vi` locale (STORY-025's own
   configuration), and render `design-reference-timeline-<platform>.png`
   via `render-design-canvas.js --screen=timeline` (confirm the exact
   screen id via `--list-screens` if `timeline` does not resolve).
3. Re-compare the two rendered images against STORY-025's existing claimed
   scope: layout, spacing, color/token usage, and typography, and each of
   the 20 deviations (per `visual-fidelity/visual-fidelity-report.md` and
   the widget tests in `timeline_design_fidelity_test.dart`).
4. Explicit re-verification of the countdown ring and dashed-border
   painters as actually rendered, not merely re-asserted by the existing
   widget test: the conic-ring seam (`TimelineProgressRing`'s
   `SweepGradient` reproducing the CSS `conic-gradient`'s 12-o'clock
   start) and the dashed-border dash pattern / stroke straddle
   (`TimelineDashedBorder`'s `_dashPattern`, used by the "Add a memory"
   pill and photo placeholder frame). If either is found to visibly differ
   from the design source in the actual capture, correct it directly in
   the affected widget and re-verify with a fresh capture.
5. If the rendered-to-rendered comparison finds any of the 20 deviations
   not actually matching the design source, or surfaces any new deviation
   not caught by STORY-025's original audit or review, correct it directly
   in the app code — this is a fix, not merely a re-documentation
   exercise.
6. Place the matched, same-screen evidence pair
   (`implemented-timeline-<device>.png` and
   `design-reference-timeline-<platform>.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match.

## Out of Scope
- D-1 (shared app-shell background deferral): confirmed fully superseded —
  STORY-032 (the story it was deferred to) is `DONE`. Re-confirmed out of
  scope only; no shared app-shell file touched by this story.
- M-4 (9.5px-floor spacing inconsistency vs. STORY-028): confirmed
  unresolvable inside a single screen-scoped story, per the reviewer's own
  disposition deferring it to requirement integration review. Carried
  forward as a note only, no action taken here.
- M-5 (feature-local `viEn` literals instead of ARB entries): l10n
  consolidation debt, same blocker class as the D-01/D-02/D-03 pattern
  re-confirmed out of scope in every prior REQ-002 hardening story.
  Re-confirmed out of scope; no `mobile/lib/l10n/arb/` file touched.
- M-8/M-9/M-10/M-12 (async countdown layout shift, no caching, narrow
  catch clause, format scope wording): non-blocking implementation-quality
  notes unrelated to visual fidelity. Re-confirmed out of scope, no action
  taken.
- Any new feature, new screen state, or new interaction not already
  present in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet). Consistent with STORY-025's own precedent and
  every prior REQ-002 hardening story, no dedicated light/`en` rendered
  pass is required for this hardening story.
- Re-litigating STORY-025's original scope framing beyond what is already
  carried in `## Background` above — this story only adds the missing
  fixture and rendered evidence, re-verifies the ring/dashed-border
  detail, and fixes anything the rendered comparison confirms or newly
  surfaces.
- STORY-025's own `story_master.md` `Status` / Artifacts record: left
  undisturbed, documented-not-resolved only in this story's
  `## Background`, no reopening of its closed git boundary/branch.
- Timeline business logic (`TimelineRepository`, `TimelineCubit`, remote
  data source, Drift cache/DAO, create-entry flow): untouched, consistent
  with STORY-025's own scope boundary. The only production seam touched is
  the already-existing `TimelineScreen.accountRepository` injection point,
  and the fixture itself lives in `main_preview.dart` (dev-only, gated
  behind `PREVIEW_TIMELINE_FIXTURE`), not in production wiring.

## Acceptance Criteria
1. Given the preview harness (`main_preview.dart`) reaches the live
   `AccountRepository` for the `'timeline'` entry and shows no countdown
   hero without a seeded `relationshipStartDate`, when
   `--dart-define=PREVIEW_TIMELINE_FIXTURE=true` is set, then
   `TimelineScreen`'s existing `accountRepository` parameter is supplied a
   fixture resolving a `CupidProfile` with a seeded
   `relationshipStartDate`, and the countdown hero (gradient card,
   progress ring, countdown numerals) renders without a live authenticated
   session; the define is omitted by default so today's live-repository
   behaviour is unchanged.
2. Given the Love Timeline screen rendered in dark theme + `vi` locale
   with the `PREVIEW_TIMELINE_FIXTURE` countdown seed active, when
   `implemented-timeline-<device>.png` is compared against
   `design-reference-timeline-<platform>.png` (rendered via
   `render-design-canvas.js --screen=timeline`), then layout, spacing,
   color/token usage, and typography match exactly with no visible
   deviation.
3. Given each of STORY-025's 20 originally-fixed deviations (per its own
   `visual-fidelity/visual-fidelity-report.md` and
   `timeline_design_fidelity_test.dart`), when this story's rendered
   comparison is complete, then each is re-confirmed as matching the
   design source in the actual rendered app, not merely re-read as code or
   widget-test assertion.
4. Given the conic-ring seam (`TimelineProgressRing`'s `SweepGradient`
   reproducing the CSS `conic-gradient`'s 12-o'clock start) and the
   dashed-border dash pattern / stroke straddle (`TimelineDashedBorder`'s
   `_dashPattern`, used by the "Add a memory" pill and photo placeholder
   frame), when the actual rendered capture is inspected, then both are
   visibly confirmed to match the design source; if either is found to
   differ, it is corrected directly in the affected widget and
   re-verified with a fresh capture.
5. Given any deviation is found by the rendered-to-rendered comparison
   beyond the 20 original deviations or the ring/dashed-border
   re-verification — whether a previously-claimed fix that does not
   actually match or a newly-surfaced deviation — when the story is
   delivered, then it is corrected in the app code (not merely
   documented) and re-verified with a fresh render pair.
6. Given the comparison is complete and passing, when the story is
   delivered, then this story's own `visual-fidelity/` directory contains
   the matched `implemented-timeline-<device>.png` and
   `design-reference-timeline-<platform>.png` image pair plus a
   `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`, the
   20-deviation re-verification disposition, the fixture-setup note, and
   the ring/dashed-border re-verification result.
7. Given the screen is reached through its existing normal navigation
   path, when a user arrives at it, then no new entry point is required —
   this story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Love Timeline screen
  (countdown hero + entry list), already reachable in the shipped app via
  its existing navigation path — unchanged by this story.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE (confirms `## Depends On` above).
- Must not require any future story: confirmed. D-1, M-4, and M-5 are all
  fully out of scope (D-1 superseded by the already-`DONE` STORY-032, M-4
  already deferred by the original reviewer to requirement integration
  review, M-5 l10n-blocked like every other prior hardening story's
  literal-string findings) — none is a dependency of this story's own
  delivery.
- Must not reopen STORY-001's, STORY-002's, STORY-004's, STORY-006's,
  STORY-011's, STORY-014's, STORY-015's, STORY-018's, STORY-019's,
  STORY-022's, STORY-025's, STORY-034's, STORY-035's, STORY-036's,
  STORY-037's, STORY-038's, STORY-039's, STORY-040's, or STORY-041's
  closed git boundary/branch: confirmed.

## Open Question Impact
Re-checked against `data/intake/bootstrap/conflicts_open_questions.md`:
OQ5 (light theme / `en` locale) is the only open question touching this
screen's scope. It remains unresolved-but-non-blocking there, deferred to
Product Owner story breakdown per its own working assumption, and is
already excluded from this story's scope for the same reason STORY-025 and
every prior REQ-002 hardening story excluded it — dark + `vi` is the only
enabled user-facing configuration in v1. No other open item in the
registry touches the Love Timeline screen or this story's evidence-pairing
scope.

### Scope Items BLOCKED in this story
- None. No open question blocks any in-scope acceptance criterion.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-7) are unblocked.
