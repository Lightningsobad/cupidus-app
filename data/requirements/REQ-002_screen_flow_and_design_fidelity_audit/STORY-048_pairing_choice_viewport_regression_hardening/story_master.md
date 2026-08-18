# Story Master: STORY-048 Pairing Choice Viewport Regression Hardening

Status: DONE
Complexity: trivial
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-045_pairing_choice_design_fidelity_hardening
Scope: Retro-hardening (RWB-20260816-022) — `pairing_choice` short-viewport
/ landscape overflow regression only.
Screens: Pairing Choice (`pairing_choice`).

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development)
- [x] Review (Reviewer) — `Iris-QC` `compact-story-review`, Outcome: CLEAN, 0 blocking / 0 deferred. Evidence: review/review-report.md

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-022 (source:
`STORY-045_pairing_choice_design_fidelity_hardening`'s reviewer,
`review/review-report.md` finding DF1) — read directly, not re-derived,
before this story is scoped.

STORY-045's reviewer (Iris-QC) found that STORY-045's own fix for
RWB-20260816-012 (`Center` -> `Align(topCenter)` +
`EdgeInsets.fromLTRB(28, 150, 28, 0)` in `pairing_choice_screen.dart`)
removed the layout's tolerance for short viewports:

- Required height inside `SafeArea` rises from roughly 211dp (pre-fix) to
  roughly 350dp (150 top pad + 2-line title at 27x1.3x2 = 70.2 + `xl`
  spacing 32 + CTA 54 + `sm` spacing 8 + `TextButton` ~36).
- Neither `mobile/main.dart` nor
  `android/app/src/main/AndroidManifest.xml` locks orientation
  (`configChanges` includes `orientation|screenSize`), so landscape is
  reachable at runtime.
- On a 360x640dp phone rotated (usable height ~312dp) this overflows by
  roughly 38dp; on the STORY-045 capture device (`emulator-5560`) rotated it
  fits by only ~13dp and overflows once `font_scale` reaches ~1.3.
- Derived arithmetically from the widget tree and token values by the
  reviewer, not empirically reproduced (writing a probe test or capturing
  landscape was outside that compact-story-review's scope).

Classification: genuine regression introduced by STORY-045's own fix, not
pre-existing — but out of that story's acceptance surface (the locked design
source is a fixed portrait frame; no AC, UX section, or design reference
covers landscape or elevated font scale), so it did not invalidate
STORY-045's evidence pair or block its `DONE` status. It is nonetheless a
real functional overflow regression and is scoped here for a fix.

Exact remediation needed (reviewer's own recommendation, not yet triaged
into a formal AC by Product Owner): wrap the `Padding` in
`pairing_choice_screen.dart` in a `SingleChildScrollView`, following the
identical precedent already established on the sibling screen
`joincode_screen.dart:138` (same design-column-from-top transcription,
already guarded this way). Expected to be a one-line fix with no visual
change in portrait, so the existing STORY-045 evidence pair should not need
to be redone — but Product Owner should confirm scope (portrait-only
regression test vs. also asserting no-overflow at a rotated/short viewport)
before implementation.

Exact remediation steps: see `rework-backlog.md` RWB-20260816-022 detail
section and STORY-045's own `review/review-report.md` finding DF1 (already
read, do not re-derive).

## Product Owner Triage (2026-08-18)

### Regression confirmation
Read `pairing_choice_screen.dart` at current `main` HEAD: the `body` tree is
still `SafeArea -> Align(topCenter) -> Padding(EdgeInsets.fromLTRB(28, 150,
28, 0)) -> Column(...)`. No `SingleChildScrollView` or other scroll
fallback is present, so the reported overflow regression is confirmed still
live.

Read the precedent at `joincode_screen.dart:194-213`: `SafeArea -> Column
[..., Expanded(child: SingleChildScrollView(padding: ..., child:
Column(...)))]`. The scroll wrapper there carries the `EdgeInsets` directly
on `SingleChildScrollView.padding` rather than a separate `Padding` widget,
and there is no `Align`/`Center` wrapper — a `SingleChildScrollView`
naturally starts its child at the top, which is the same "flows from the
top of the frame" invariant `pairing_choice_screen.dart`'s existing code
comment already documents. Implementation should follow this precedent's
*effect* (top-anchored, scrollable, no overflow) rather than requiring a
literal structural match; whether `Align(topCenter)` stays, is removed, or
becomes redundant once wrapped in a scroll view is an implementation
decision, not a product decision.

### Acceptance Criteria

**AC1 — No layout overflow at reduced/rotated viewport height.**
`pairing_choice_screen.dart`'s content must render with no Flutter overflow
exception (no `RenderFlex overflowed`) at any viewport height down to the
reviewer's derived worst case: a 360x640dp phone rotated to landscape
(~312dp usable height inside `SafeArea`), including with system font scale
elevated to at least 1.3x. Achieve this via a scroll fallback (e.g.
`SingleChildScrollView`), following the `joincode_screen.dart` precedent's
effect described above.

**AC2 — No visible change in the locked portrait frame.**
The fix must produce no visible difference in the already-approved portrait
capture: title, `CupidSpacing.xl`/`CupidSpacing.sm` gaps, CTA, and the
secondary `TextButton` must render at the same position/size in the
default portrait viewport (the STORY-045 capture device/config) as at
current `main` HEAD. STORY-045's existing `visual-fidelity/` evidence pair
remains valid as-is and must NOT be redone. Exception: if the implementer
determines the chosen scroll wrapper does shift portrait layout, they must
stop and flag it back to Scrum Master rather than silently re-rendering or
re-approving evidence — this AC assumes no shift, per the reviewer's own
"expected to be a one-line fix with no visual change in portrait" framing.

**AC3 — Regression test required.**
Add a Flutter widget test that pumps `PairingChoiceScreen` with the
viewport constrained to a reduced/landscape height (e.g. set
`tester.view.physicalSize`/`devicePixelRatio` to emulate the ~360x640dp
rotated case, ~312dp usable height, per the reviewer's derivation) and
asserts `tester.takeException()` is null after `pumpAndSettle` (no overflow
exception thrown). This is a genuine functional regression, not cosmetic
only, so a test is warranted and no exemption applies. Place it alongside
existing tests for this screen following the existing test-file convention;
do not create a new test directory structure.

**AC4 — Scope boundary.**
Do not modify `invite_screen.dart`, `joincode_screen.dart`, `mobile/main.dart`,
or `android/app/src/main/AndroidManifest.xml` orientation/`configChanges`
handling — the reviewer's finding names orientation-locking only as an
alternative not chosen; the accepted remediation is scroll tolerance, not
restricting orientation. Do not reopen or modify STORY-045's evidence pair
or `DONE` status except via AC2's explicit exception path.

### Complexity and Lane
- **Complexity: trivial** — confirmed. The fix is a single scroll-fallback
  wrapper change confined to one widget file, plus one widget test; no new
  asset, token, API, or backend contract is involved.
- **Implementation Lane: mobile** — confirmed, single-lane. No
  backend/frontend/devops surface is touched.
- Per this requirement's established Lane Consistency Rule (STORY-045,
  STORY-046, STORY-047 precedent): given `Complexity: trivial` and
  `Implementation Lane: mobile` only, UX Design and Architecture are
  eligible for `SKIPPED:trivial`. Product Owner does not check those boxes
  directly — Scrum Master applies the rule.

## Mobile Implementation (2026-08-18)

### Change
`mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
— the `Padding` under `Align(topCenter)` is now wrapped in a
`SingleChildScrollView`. The `Align` is deliberately retained rather than
removed: it is what hands the subtree a *loose* horizontal constraint, and
`SingleChildScrollView` passes the cross-axis constraint through unchanged,
so the title still wraps at exactly the same bound the design source locks
(the 28dp inset comment on the `Padding` stays load-bearing). This follows
the `joincode_screen.dart` precedent's *effect* — top-anchored, scrollable,
no overflow — per the AC1 latitude, not its literal structure.

The remainder of the diff on that file is indentation-only reflow of the
`Column` subtree under the new wrapper (`dart format` shape); no token,
spacing, string, or callback changed.

### AC results

**AC1 — no overflow at reduced/rotated viewport: PASS, empirically.**
Not derived arithmetically. The new test was written first and run against
unfixed `main` HEAD, which reproduced the regression concretely:
`FlutterError:<A RenderFlex overflowed by 72 pixels on the bottom.>`. The
same test passes after the fix. This upgrades the reviewer's arithmetic
derivation (RWB-20260816-022 / STORY-045 DF1, ~13-38dp expected) to a
reproduced failure — the real overflow at font scale 1.3x is larger than
the derivation predicted.

**AC2 — no visible change in the locked portrait frame: PASS, verified by
measurement.** Rather than assume the wrapper was inert, a throwaway
geometry probe recorded the rect of the title, CTA, secondary `TextButton`,
and its label at three portrait viewports (360x800, 412x915, and the
800x600 test default), run once with the fix applied and once against the
restored `main` HEAD file. All values are identical to 3 decimal places in
every case, e.g. at 360x800: title `t=150.000 h=105.000`, CTA `t=287.000
h=54.000`, secondary `t=349.000 h=56.000`. The probe was temporary and is
not committed.

Consequence: the AC2 exception path did **not** trigger. STORY-045's
`visual-fidelity/` evidence pair was not touched, re-rendered, or
re-approved, and no new visual-fidelity evidence was captured for this
story — it is a functional regression fix with a proven-zero portrait
delta, not a new design-fidelity surface.

**AC3 — regression test: DONE.** Added `does not overflow on a rotated
short viewport (AC1)` to the existing
`mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
(existing convention, no new directory). It sets
`tester.view.physicalSize = Size(640, 360)` with `devicePixelRatio = 1.0`
plus `FakeViewPadding(top: 24, bottom: 24)` so `SafeArea` leaves the ~312dp
usable height the reviewer derived, pumps at `TextScaler.linear(1.3)`, and
asserts `tester.takeException()` is null after `pumpAndSettle`. The shared
`_harness()` gained an optional `textScaler` parameter applied through
`MaterialApp.builder`; the four pre-existing tests call it unchanged.

**AC4 — scope boundary: HELD.** `git diff` against `BaseHead`
`4fb2426` shows exactly two changed files under `mobile/`
(the screen and its test). `invite_screen.dart`, `joincode_screen.dart`,
`mobile/main.dart`, and `android/app/src/main/AndroidManifest.xml` are
untouched; no orientation lock or `configChanges` edit was made.

### Verification
- `flutter analyze --no-pub lib test` — 80 issues, all `info`, all
  pre-existing (`prefer_initializing_formals`, one `deprecated_member_use`
  in `reminder_firing_overlay.dart`). Zero errors, zero warnings, and no
  new issue attributable to this change. Note: bare `flutter analyze`
  reports unrelated errors from vendored `build/ios/SourcePackages/`
  Firebase checkouts, which are pre-existing build artifacts outside
  project source — hence the `lib test` scoping.
- `flutter test --no-pub` (full suite) — `+1285 ~2`: 1285 passed, 2
  skipped, 0 failures.
- `flutter test --no-pub test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
  — 5/5 passed.
- Flutter 3.44.1 stable / Dart 3.12.1. The SDK is not on `PATH` at
  `/Users/alantravala/flutter/bin`; commands were run with it prepended.

## Closed (2026-08-18)

Review `Outcome: CLEAN` (`review/review-report.md`) — all 4 ACs PASS, each
independently re-derived by the reviewer, 0 blocking / 0 deferred findings.
Visual-fidelity DONE gate satisfied by `visual-fidelity/visual-fidelity-report.md`
(`VISUAL_FIDELITY: PASS`) — capture-and-record only, citing the
already-proven pixel-identical portrait geometry rather than re-deriving it;
STORY-045's own evidence pair was not touched. RWB-20260816-022 resolved by
this story. Note for later REQ-002 stories: this story's evidence trail
found that `capture-mobile-screen.sh` and `render-design-canvas.js`, cited
as provenance in STORY-045's report, do not exist anywhere in this
repository's history — this story's capture instead used the committed
`mobile/lib/main_preview.dart` harness directly, with the exact reproducible
command sequence recorded in `visual-fidelity/visual-fidelity-report.md`.
