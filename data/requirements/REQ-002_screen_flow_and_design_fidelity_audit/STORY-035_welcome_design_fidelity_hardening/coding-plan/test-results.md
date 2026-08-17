# Test Results — STORY-035 Phases P0 and P1

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-035_welcome_design_fidelity_hardening
- Phases: P0 — welcome rendered fidelity evidence (sections 1-5);
  P1 — CSS gradient-axis fix (sections 6-7)
- Lane: mobile-dev (Alex-Mobile-Dev)
- Date: 2026-08-16 (P0), 2026-08-17 (P1)
- Toolchain: Flutter 3.44.1 / Dart 3.12.1
- Flutter SDK is not on the default PATH; every command below is prefixed with
  `export PATH="/Users/alantravala/flutter/bin:$PATH"` and run from
  `/Users/alantravala/workspace/snapsofts/cupid-apps/mobile`.

## 1. Static analysis

```
flutter analyze lib test --no-fatal-infos --no-fatal-warnings
```

- Exit code: **0**
- Result: 80 issues found, all `info`, all pre-existing
  (`prefer_initializing_formals` x78, `use_null_aware_elements` x1,
  `deprecated_member_use` x1).
- Issues attributable to this story: **0**. Neither
  `lib/features/auth/presentation/screens/welcome_screen.dart` nor
  `test/features/auth/presentation/screens/welcome_screen_test.dart` appears
  anywhere in the analyzer output.

## 2. Scoped widget tests

```
flutter test test/features/auth/presentation/screens/welcome_screen_test.dart
```

- Exit code: **0**
- Passed: **9** / Failed: **0** / Skipped: **0**

| # | Test | Result |
|---|---|---|
| 1 | renders the design source hero block in vi | pass |
| 2 | hero content is left-aligned, not centered | pass |
| 3 | **hero block starts at the design left padding, not centered** (new) | pass |
| 4 | **the shared twinkle star field paints over the backdrop** (new, review rework) | pass |
| 5 | background is the three-stop brand backdrop on the 165deg sweep, not the two-stop button gradient | pass |
| 6 | Google CTA carries the multicolour brand mark before its label | pass |
| 7 | CTAs are 52pt pills stacked with the design source gap (extended) | pass |
| 8 | Apple CTA is iOS-only | pass |
| 9 | carries no CTA the design source does not define | pass |

Test 4 is new in the review rework. It asserts `find.byType(CupidStarField)`,
that the star layer is the **last** child of the backdrop `Stack`, that the stack
uses `StackFit.expand`, and that the layer's `IgnorePointer` is active so the
particles cannot swallow CTA taps.

Test 3 is new in this story. It asserts the **painted** x of the wordmark,
tagline and sub-copy via `tester.getTopLeft(...).dx` instead of reading a
widget-tree property. Test 2 already asserted
`hero.crossAxisAlignment == CrossAxisAlignment.start` and passed the entire time
the screen was rendering centred — that is defect IF-7 in one line, and test 3
is the guard that closes it.

Test 6 gained an assertion that the Email-pill-bottom to footnote-top distance
is `_ctaGapExpectation + _footnoteMarginExpectation` (10 + 6 = 16), pinning the
CSS flex `gap` + `margin-top` stacking the implementation had collapsed to 6.

## 3. Full regression suite

```
flutter test
```

(the `testCommand` recorded in `data/devops/system/runtime-command-registry.json`)

- Exit code: **0**
- Passed: **1249** / Failed: **0** / Skipped: **2**
- Final reporter line: `+1249 ~2: All other tests passed!`

The design-system fork guard was additionally run on its own, because fix 4.4
consumes a design-system widget from a feature screen:

```
flutter test test/design_system/no_fork_guard_test.dart
```

- Exit code: **0** — 1 passed. `CupidStarField` is used as-is from
  `lib/design_system/decorations/`; nothing was forked or reimplemented locally
  to work around either the gradient finding or the star-layer finding.

## 4. Build gate

```
flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=welcome
```

- Exit code: **0**
- Output: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`
- Pre-existing non-blocking warnings only (Gradle native-access notice; KGP
  notice for the `sign_in_with_apple` plugin). Neither is introduced by this
  story.

The **real** entry point was built separately, because `lib/main_preview.dart` is
a capture harness and proves nothing about the shipped composition root:

```
flutter build apk --debug
```

- Exit code: **0** (default target `lib/main.dart`)

## 5. Rendered verification

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --entry="Cupid App.dc.html" --screen=welcome --platform=android --theme=dark --lang=vi --label=welcome --out=data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-035_welcome_design_fidelity_hardening/visual-fidelity
```

- Exit code: **0** — `DESIGN_CANVAS: OK ... 406x900`

```
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
adb -s emulator-5560 exec-out screencap -p > ../data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-035_welcome_design_fidelity_hardening/visual-fidelity/implemented-welcome-emulator-5560.png
```

- Exit code: **0** — 1080x2400 @ density 420
- A re-capture after the final build differs from the committed artifact only
  inside the status-bar clock digits (difference bounding box
  `(133, 50, 174, 78)`); everything below y=78 is identical.

Both sides were re-rendered after the review rework (fix 4.4) with the same two
commands; `implemented-welcome-emulator-5560.png` in the artifact directory is
the post-fix capture.

Full region-by-region analysis is in
`../visual-fidelity/visual-fidelity-report.md`.

## Entry Point Reachability

**Reachable: YES**

`WelcomeScreen` is mounted by the session gate in
`mobile/lib/features/auth/presentation/screens/splash_screen.dart:113`, for the
`SessionGateUnauthenticated()` state. It is not preview-only or dead code: an
unauthenticated cold start lands on it directly, which is also what the runtime
smoke below observed on device.

## Story Runtime Startup Smoke

Run against the **real** entry point (`lib/main.dart`), not the
`lib/main_preview.dart` capture harness.

```
flutter build apk --debug
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
adb -s emulator-5560 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
adb -s emulator-5560 logcat -d -s "flutter" "AndroidRuntime"
```

- Build and install: exit **0**
- Launch: `Status: ok`, `LaunchState: COLD`, `TotalTime: 11057` (debug build,
  first cold start after install)
- Resumed activity confirmed:
  `topResumedActivity=...com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
- Log: **no** `AndroidRuntime` entries, no Dart exception, no Flutter error
  screen. Only informational lines (Impeller backend selection, Dart VM service
  listening).
- First screen reached: the welcome screen, through the session gate, with the
  debug banner and the twinkle particles visible.

Startup smoke: **PASS** — scoped to this story's app, no waiver needed.

## 6. Phase P1 gate results (CSS gradient-axis fix, D1)

Every gate below was re-run after the token change. The change is in a token
consumed by ~20 widgets, so the full suite is mandatory here rather than optional.

| Gate | Command | Exit | Result |
|---|---|---|---|
| New axis test | `flutter test test/design_system/gradient_axis_test.dart` | 0 | 15 passed / 0 failed |
| Fork guard | `flutter test test/design_system/no_fork_guard_test.dart` | 0 | 1 passed |
| Design fidelity (7 files) | `flutter test <7 x *_design_fidelity_test.dart>` | 0 | 50 passed / 0 failed |
| Full regression | `flutter test` | 0 | `+1264 ~2: All other tests passed!` |
| Static analysis | `flutter analyze lib test --no-fatal-infos --no-fatal-warnings` | 0 | 80 pre-existing infos, 0 attributable |
| Build (real entry) | `flutter build apk --debug` | 0 | `✓ Built ... app-debug.apk` |
| Build (preview) | `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=welcome` | 0 | `✓ Built ... app-debug.apk` |

Notes:

- Full suite went 1249 -> **1264** passing (+15 = the new axis test); 2 skipped
  before and after; zero failures and zero ` [E]` lines. No consumer regressed.
- The 7 design-fidelity files run are chat, ghost_settings_screen, dream_jar,
  gallery, waiting_screen, pet and timeline. `waiting_screen` is the one that
  exercises the direct `gradientHot.createShader(bounds)` path.
- `flutter analyze` output contains no entry for
  `lib/design_system/tokens/cupid_color_tokens.dart`,
  `lib/design_system/tokens/cupid_css_angle_gradient.dart`, or
  `test/design_system/gradient_axis_test.dart`.
- `no_fork_guard_test.dart` guards `lib/features`, `lib/app` and `lib/core`, so
  the new `lib/design_system/tokens/` file is outside its remit; it was still run
  to prove the fix was not worked around by forking anything into a feature.

### 6.1 What the new axis test proves

`mobile/test/design_system/gradient_axis_test.dart`, 15 tests in four groups:

- 8 tests: both tokens x 4 box shapes (412x915 backdrop, 400x400 square,
  380x52 wide pill, 52x380 tall narrow), each asserting the geometric angle
  equals the declared CSS angle within **1e-9**, the gradient-line length equals
  `|W*sin0| + |H*cos0|` within **1e-9**, and the line is centred on the box.
- 3 tests proving the matrix is **not vacuous** — it asserts the pre-fix
  box-normalized math's wrong values explicitly:

  | Token | Box | Pre-fix (box-normalized) | Post-fix (CSS) |
  |---|---|---|---|
  | `gradientBrandBackdrop` (165deg) | 412x915 | **173.12** (6.88 off vertical) | **165.000** |
  | `gradientBrandBackdrop` | 400x400 | 165 (degenerate, agrees) | 165 |
  | `gradientHot` (95deg) | 380x52 | **90.69** (0.69 off horizontal) | **95.000** |

  The square case is asserted precisely because both maths agree there: a
  square-only matrix would have passed against the original defect.
- 3 tests that the fix reaches every consumer: both tokens are
  `CupidCssAngleGradient` in dark **and** light; the direct
  `createShader(bounds)` path (`waiting_screen.dart:281`) returns a shader in LTR
  and RTL; and `LinearGradient.lerp` between the two themes does not silently
  drop the subclass.
- 1 test that colours and stops are byte-identical to their pre-fix values and
  that `gradientDream` is **not** a `CupidCssAngleGradient`.

One assertion needed adjusting during authoring: comparing the gradient-line
midpoint to `rect.center` with exact `Offset` equality failed on the tall-narrow
box by one ULP. It now compares the two components with `closeTo(..., 1e-9)`.

## 7. Rendered re-verification (P1)

Both sides regenerated from scratch with the section 5 commands.

- Design reference re-render: exit **0** — `DESIGN_CANVAS: OK ... 406x900`
- Preview build, install, launch, capture: all exit **0**;
  `Status: ok`, `LaunchState: COLD`, `TotalTime: 6029`
- Backdrop axis re-measured with the same sub-pixel iso-colour-line analyzer:

  | Side | Axis tilt off vertical |
  |---|---|
  | Design reference | 14.98 (14.90 at B=170, 15.06 at B=150) |
  | Implementation **before** P1 | **6.86** |
  | Implementation **after** P1 | **15.01** (15.01 at B=170, 15.01 at B=150) |
  | CSS `linear-gradient(165deg)` expects | 15.00 |

- Corner colours at 8% inset, after P1: TL and TR differ by `dB +1`, BL and BR
  are exact. Before P1 the off-axis corners carried `dR -18 / dB +8` (TR) and
  `dG -4 / dB -7` (BL). Matching corners confirm the **extent** half of the fix
  landed, not just the axis — a wrong gradient-line length would have slid the
  58% stop and shown up here.
- No new visible deviation surfaced on the welcome screen from the corrected
  geometry.

## 8. Phase outcome

**P0 and P1 gates all pass.** The P0 `SCOPE_BOUNDARY_BLOCKED` escalation (D1) is
resolved under Tech Lead's Phase P1 carve-out. All four rendered deviations are
fixed and re-verified against a fresh capture pair, and
`visual-fidelity/visual-fidelity-report.md` now records `VISUAL_FIDELITY: PASS`.

`git diff e28a6c2 --stat` touches zero consumer widget files; the P1 code change
is confined to `mobile/lib/design_system/tokens/cupid_color_tokens.dart`, the one
new sibling `cupid_css_angle_gradient.dart`, and
`mobile/test/design_system/gradient_axis_test.dart`.
