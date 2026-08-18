# Visual Fidelity Report: STORY-048 Pairing Choice Viewport Regression Hardening

VISUAL_FIDELITY: PASS

## Scope Of This Report

This story is a **functional overflow fix** (RWB-20260816-022), not a new
design-fidelity surface. The `guard-story-done-evidence.sh` DONE gate requires
a visual-fidelity pair for any `ui_surface: true` screen with a locked
`design_source`, so this pair is produced to satisfy that gate and to record
that the fix left the locked portrait frame untouched.

Read this as **capture-and-record**, not as re-derivation. The portrait
equivalence asserted here was already proven twice, independently, before this
report existed (see "Evidence For AC2 Equivalence"). Nothing in the fix's
correctness argument rests on this image pair — the regression itself is proven
by the AC1 widget test, not by these screenshots.

## Evidence Pair

| Side | File | Size | Provenance |
|------|------|------|-----------|
| Design reference | `design-reference-pairingchoice-android.png` | 406x900 | Reused **as-is** from STORY-045, byte-for-byte. Originally rendered by STORY-034 (`render-design-canvas.js --screen=pairingchoice --platform=android --theme=dark --lang=vi`). Not re-rendered: this story changed no design source, no token, and no design-bearing property, so a re-render could only introduce noise. Same reuse pattern STORY-045 itself records. |
| Implementation | `implemented-pairingchoice-emulator-5560.png` | 405x900 | Captured 2026-08-18 from `emulator-5560` against the current working tree **with this story's `SingleChildScrollView` fix in place**. |

Same-state pairing, matching STORY-045's conditions: dark theme, `vi` locale,
unpaired onboarding state, Android 412x915dp design frame vs `emulator-5560` at
1080x2400 @420dpi = 411x914dp logical, `font_scale` 1.0. Dimensionally
equivalent, so the comparison is 1:1 in image pixels (the reference carries a
device bezel offsetting it ~5px down and ~7px right).

## How The Implementation Capture Was Produced

The handoff named
`capture-mobile-screen.sh --device=emulator-5560 --route=cupidpreview://screen/pairingchoice --settle-ms=9000`.
**That script does not exist** — not in the working tree, not anywhere under
`/Users/alantravala/workspace/snapsofts/`, and not at any commit in this
repository's history (`git log --all -- "*capture-mobile-screen.sh"` is empty),
despite STORY-045's report citing it as provenance. Same for
`render-design-canvas.js`. Both appear to have been ad-hoc local tooling that
was never committed.

The capture was therefore reproduced directly against the repo's own preview
harness (`mobile/lib/main_preview.dart`, whose `cupidpreview://screen/<id>`
scheme is registered in `mobile/android/app/src/debug/AndroidManifest.xml`),
matching the named parameters exactly — same device, same route, same 9000ms
settle:

1. `flutter build apk --debug -t lib/main_preview.dart` — **required**. The APK
   already installed on `emulator-5560` predates this story, so deep-linking the
   running build would have captured the *unfixed* screen and silently produced
   false evidence.
2. `adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk`
3. `adb -s emulator-5560 shell settings put system font_scale 1.0`
4. `adb -s emulator-5560 shell am start -a android.intent.action.VIEW -d "cupidpreview://screen/pairingchoice" com.snapsofts.cupid`
5. `adb -s emulator-5560 shell 'sleep 9; screencap -p ...'` (the 9000ms settle)
6. Downscaled 1080x2400 -> 405x900 (exactly 0.375) with `sips`, matching
   STORY-045's stored dimensions.

One trap worth recording for the next capture on this harness: the harness reads
its screen id from `--dart-define=PREVIEW=<id>` at startup and only ever
overwrites it via `didPushRouteInformation`. A **cold start** carrying the deep
link therefore lands on the preview *index*, not the target screen — the first
capture attempt here did exactly that. The deep link must be sent to an
**already-running** instance (`Activity not started, intent has been delivered to
currently running top-most instance`). The stored PNG is from the second,
verified attempt; the index-screen capture was discarded.

The harness pins `Locale('vi')`, `Brightness.dark`, and
`MediaQuery.withNoTextScaling`, and mounts `CupidAppBackground` at the same
place the real composition root does, so these conditions are structural rather
than dependent on emulator settings.

## Comparison Result: PASS

The implementation capture matches the design reference on every element the
design source locks: title string, two-line wrap point, top-anchored vertical
offset, gradient+glow pill CTA with its label, and the secondary text link
below it.

Against **STORY-045's own approved implementation capture**, the new capture is
visually indistinguishable. The only two differences are provably non-design:

- Status-bar clock (`6:29` vs `11:29`) — capture wall-clock time.
- Positions of the few decorative particles in `CupidAppBackground` — that
  layer is randomized per run and is not design-locked; STORY-034's and
  STORY-045's captures differ from each other in the same way.

## Evidence For AC2 Equivalence (not re-derived here)

This report does **not** re-measure the portrait frame. Equivalence was already
established twice, independently, and this pair is consistent with both:

1. **Implementer probe (mobile-dev, AC2).** A throwaway widget-geometry probe
   recorded the rects of the title, CTA, secondary `TextButton`, and its label
   at three portrait viewports (360x800, 412x915, and the 800x600 test
   default), run once with the fix applied and once against the git-restored
   `main` HEAD file. All 12 measurements were identical to three decimal
   places, e.g. at 360x800: title `t=150.000 h=105.000`, CTA `t=287.000
   h=54.000`, secondary `t=349.000 h=56.000`.
2. **Reviewer re-measurement.** The STORY-048 review independently re-measured
   the same portrait geometry pre/post fix and reached the same
   pixel-identical conclusion, returning `Outcome: CLEAN`.

The structural reason both agree: the fix keeps the existing
`Align(topCenter)`, which is what supplies the *loose* horizontal constraint,
and `SingleChildScrollView` passes the cross-axis constraint through unchanged.
The title therefore still wraps at exactly the design-locked 28dp-inset bound,
and with content shorter than the viewport the scroll view sizes to its child —
so in portrait the render tree produces identical output.

Accordingly the AC2 exception path did **not** trigger, and STORY-045's
`visual-fidelity/` directory was not touched, re-rendered, or re-approved.

## What This Pair Does And Does Not Prove

**Does not prove the fix works.** This is a portrait-frame comparison. The
regression it addresses only manifests at reduced/landscape viewport heights
(AC1), which a portrait capture does not exercise at all. Reading this PASS as
evidence that the overflow is fixed would be wrong.

**The AC1 proof is the widget test**,
`does not overflow on a rotated short viewport (AC1)` in
`mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`.
It was written before the fix and run against unfixed `main` HEAD, where it
reproduced the regression concretely as
`FlutterError:<A RenderFlex overflowed by 72 pixels on the bottom.>`, then
passed after the fix. (Note for the record: 72dp is larger than the ~13-38dp
STORY-045's reviewer derived arithmetically — the original finding understated
the severity.)

**What this pair does prove** is the complement: that buying AC1's viewport
tolerance cost nothing in the locked portrait frame.

## Verification State At Capture Time

- `flutter test --no-pub` (full suite): 1285 passed, 2 skipped, 0 failures.
- `flutter test --no-pub` (this screen's file): 5/5 passed.
- `flutter analyze --no-pub lib test`: 80 issues, all `info`, all pre-existing;
  zero errors, zero warnings.
- Flutter 3.44.1 stable / Dart 3.12.1.
