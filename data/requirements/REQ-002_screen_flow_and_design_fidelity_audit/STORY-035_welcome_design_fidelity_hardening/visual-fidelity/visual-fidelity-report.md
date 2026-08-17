# Visual Fidelity Report — Welcome Screen (STORY-035, Phases P0 + P1)

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-035_welcome_design_fidelity_hardening (RED-PATCH for RWB-20260816-002)
- Screen: `welcome`
- Scope per OQ5: dark theme, `vi` locale, Android only
- Date: 2026-08-16 (P0), 2026-08-17 (P1 gradient-axis fix)
- Author: Alex-Mobile-Dev (`mobile-dev`)

## 1. Method — and why it differs from STORY-004

STORY-004 compared the **design source text** (CSS/HTML of the prototype) against
the **Flutter widget tree**. That is defect **IF-7**: it can only prove that two
descriptions agree, never that two *renders* agree. It is exactly the failure
mode that let the two deviations in section 4 ship undetected — the widget tree
said `CrossAxisAlignment.start`, and the screen still rendered centred.

This report uses a **rendered-output-to-rendered-output** comparison. Both sides
are real rasters produced by their own renderer:

- design side: the Claude Design canvas rendered by Chromium at the Android
  frame size (412x915 logical px),
- implementation side: the actual Flutter app running on an Android emulator at
  1080x2400 @ density 420 (dpr 2.625 = 411.4x914.3 logical px).

The two viewports are the same to within 0.6 logical px, so measurements are
directly comparable. All findings below come from **this story's own fresh
pair**. No STORY-004, STORY-033, or BUG-20260816-001 capture was used, read, or
relied on.

Measurement was done with PIL on the two PNGs: near-white thresholding plus a
row-median, contrast-relative ink detector (needed because the accent rule,
sub-copy, footnote and email outline are all sub-1.0 alpha and a plain white
threshold cannot see them), band grouping, and sub-pixel iso-colour-line
interpolation for the gradient axis.

## 2. Verbatim commands

### 2.1 Design reference

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --entry="Cupid App.dc.html" --screen=welcome --platform=android --theme=dark --lang=vi --label=welcome --out=data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-035_welcome_design_fidelity_hardening/visual-fidelity
```

Result: `DESIGN_CANVAS: OK .../design-reference-welcome-android.png 406x900`, exit 0.

Note for future runs: the phase file's stated entry is not sufficient.
`Cupid Screens.dc.html` is the imported **component**, not the canvas —
`--list-screens` on it reports `screens: [], toggles: [], platforms: ["ios"]`
and any `--theme`/`--lang` fails with `DESIGN_CANVAS_TOGGLE_MISSING`. The canvas
is `Cupid App.dc.html` (38 screens including `welcome`; toggles `dark, light,
vi, en`; platforms `ios, android`).

### 2.2 Implementation capture

```
export PATH="/Users/alantravala/flutter/bin:$PATH"
cd mobile
flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=welcome
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
adb -s emulator-5560 exec-out screencap -p > ../data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-035_welcome_design_fidelity_hardening/visual-fidelity/implemented-welcome-emulator-5560.png
```

All exit 0. `PREVIEW_BRIGHTNESS` defaults to `dark` and the app's default locale
is `vi`, which satisfies OQ5 without extra defines.

Freshness check: a re-capture taken after the final build differs from the
committed artifact only inside the status-bar clock digits (difference bounding
box `(133, 50, 174, 78)`); every pixel below y=78 is identical. The delivered
capture is the current build.

Re-capture after the review rework (fix 4.4): the same command sequence was run
again after the star-field change and `implemented-welcome-emulator-5560.png` was
replaced. A landmark re-sweep of the new capture returns values identical to the
pre-rework capture for every hero, CTA and footnote landmark in section 5.1/5.2,
plus three new bright bands at logical y 82.0-86.2, 128.6-133.5 and 237.7-243.0
(the particles). No regression, and the fix is visible in the render.

Re-capture after Phase P1 (fix 4.3): both sides were regenerated from scratch —
the design reference re-rendered (`DESIGN_CANVAS: OK ... 406x900`, exit 0) and
the implementation rebuilt, reinstalled and re-captured with the same commands
above. The delivered pair is the P1 pair. Measurements in 4.3 and 5 come from it.

## 3. Artifacts

| Side | File | Size |
|---|---|---|
| Design reference | `design-reference-welcome-android.png` | 406x900 |
| Implementation | `implemented-welcome-emulator-5560.png` | 1080x2400 |

## 4. Deviations found, and what was done

### 4.1 Hero block rendered horizontally centred — FIXED

**Rendered evidence (pre-fix).** Every hero element sat +42 logical px right of
the design: measured hero left edge ~72 against the design's ~30, while the CTA
pills below were correct at ~20. The widget tree looked correct the whole time —
this is the deviation IF-7 was structurally unable to see.

**Root cause.** The outer `Column` in `_WelcomeView.build` used the default
`CrossAxisAlignment.center`, so `Expanded(child: _WelcomeHero())` received
*loose* width constraints. The hero shrink-wrapped to its widest child
(`_subCopyWidth` 270 + `_heroPadding` 28 x2 = 326) and was then centred inside
412: (412 - 326) / 2 = 43, + 28 = 71. Predicted 71, measured 72.5.

**Fix** (`mobile/lib/features/auth/presentation/screens/welcome_screen.dart`):
set `crossAxisAlignment: CrossAxisAlignment.stretch` on that Column so the hero
receives tight cross-axis constraints and honours its own padding.

**Re-verified** by rebuilding, reinstalling and re-capturing: all hero landmarks
now land within ~1 logical px of the reference (section 5).

### 4.2 Footnote gap 10 logical px short — FIXED

**Rendered evidence (pre-fix).** Email-pill bottom to footnote ink top measured
REF 20.2 vs IMPL 7.9.

**Root cause.** The design's CTA column is `display:flex; ... gap:10px`
(`Cupid Screens.dc.html` line 80) and the footnote additionally carries
`margin-top:6px` (line 86). CSS flex `gap` applies between *every* pair of
children, so the footnote's margin **stacks on top of** the gap: 10 + 6 = 16.
The implementation had only the 6.

**Fix**: added `const double _footnoteMargin = 6;` and changed the spacer to
`SizedBox(height: _ctaGap + _footnoteMargin)`.

**Re-verified**: post-fix IMPL 21.4 vs REF 20.2.

### 4.3 Backdrop gradient axis angle — RESOLVED in Phase P1 (D1)

Escalated from P0 as `SCOPE_BOUNDARY_BLOCKED` (D1). Tech Lead issued a widened,
defect-scoped Write Scope carve-out for the two axis pairs, and the fix landed in
Phase P1.

**Rendered evidence, before and after.** Gradient axis tilt off vertical, by
sub-pixel iso-colour-line interpolation on two iso-blue target levels (B=170,
150), measured with the same analyzer on both pairs:

| Side | Axis tilt off vertical |
|---|---|
| Design reference | 14.98 deg |
| Implementation **before** P1 | **6.86 deg** (delta 8.12) |
| Implementation **after** P1 | **15.01 deg** (delta 0.03) |
| CSS `linear-gradient(165deg, ...)` expects | 15.00 deg |

The post-fix reading is stable across both target levels: 15.01 at B=170 and
15.01 at B=150.

Corner colours at 8% inset, before and after. Before, the two on-axis endpoints
matched exactly while the two off-axis corners carried the whole error — the
signature of a correct colour ramp swept along the wrong direction. After, all
four agree:

| Corner | Delta before P1 | Delta after P1 |
|---|---|---|
| TL | dR +0 dG +0 dB +1 | dR +0 dG +0 dB +1 |
| TR | dR **-18** dG +0 dB **+8** | dR +0 dG +0 dB +1 |
| BL | dR +0 dG **-4** dB **-7** | 0 |
| BR | 0 | 0 |

**Root cause** (`mobile/lib/design_system/tokens/cupid_color_tokens.dart`):

```dart
const Alignment _gradient165Begin = Alignment(
  -0.25881904510252074,   // sin(165deg)
  -0.9659258262890683,    // cos(165deg)
);
```

The trig is right but the container is wrong. Flutter's `Alignment` is
**normalised to the box aspect ratio** (`centerX + x * W / 2`), whereas CSS
`linear-gradient(<angle>)` is a true geometric angle. On a 412x915 box the
painted direction collapsed to `atan((0.2588 x 412) / (0.9659 x 915))` =
**6.88 deg**, matching the 6.86 deg measured. The colour stops, the endpoints and
the token choice were all correct; only the axis was wrong, and wrong by
construction rather than by drift.

**Fix.** New `mobile/lib/design_system/tokens/cupid_css_angle_gradient.dart`:
`CupidCssAngleGradient extends LinearGradient` and overrides `createShader` to
paint the CSS gradient line — through the box centre, along the `begin`-to-`end`
direction, with the CSS gradient-line length `|W*sin0| + |H*cos0|`. The four
constructor sites for `gradientBrandBackdrop` and `gradientHot` (dark and light)
now use it. No colour, no stop, and no `Alignment` constant changed.

Both halves of the CSS contract are corrected, not just the axis. A bare
`GradientRotation` would fix the angle and leave the gradient-line extent
box-normalised, which slides every declared stop percentage — visibly moving
`gradientBrandBackdrop`'s 58% pink band. That is why the extent is asserted
alongside the angle.

**Cross-screen coverage.** `gradientHot` has ~20 consumers, mostly 380x52-class
pills where the same defect rendered 0.69 deg instead of the declared 5.00 deg off
horizontal — an error too small for a screenshot comparison to resolve. Those
consumers are therefore verified **numerically** rather than by per-screen
capture: `mobile/test/design_system/gradient_axis_test.dart` asserts both tokens
against a box-shape matrix spanning every consumer aspect class (412x915 backdrop,
400x400 square, 380x52 wide pill, 52x380 tall narrow), checking angle and extent
to 1e-9, and separately asserts the pre-fix math's wrong values so the matrix
cannot pass vacuously. The square case is included precisely because both maths
agree there — a square-only matrix would have passed against the original defect.

The direct-shader consumer at `waiting_screen.dart:281`
(`colors.gradientHot.createShader(bounds)`, which bypasses `BoxDecoration`) needed
no special case: the override is on the instance, so that path is corrected
automatically. Asserted for LTR and RTL.

Also explicitly **not** done, per the handoff: `gradientBrandBackdrop` was left
in place. It is the correct token. Substituting a reversed `gradientHot` would
be a regression, and the existing test pins against exactly that substitution.
`gradientDream` / `_gradient120*` were left untouched — no measured defect, and
the test asserts `gradientDream` is *not* a `CupidCssAngleGradient`.

### 4.4 Twinkle star particles absent from the backdrop — FIXED

Found by Reviewer (Iris-QC) on re-review of the first evidence pair; my own
region sweep had been scoped to the hero/CTA landmarks and the gradient, and did
not cover the particle layer. The finding is correct.

**Rendered evidence (pre-fix).** The design reference carries three `twinkle`
particles in the upper backdrop; the implemented capture had none. A bright-blob
sweep over logical y 40-300 returned three blobs on the design side and zero on
the implementation side.

**Root cause.** `CupidAppBackground` already mounts a `CupidStarField` above
every route (`cupid_app.dart:59`, and `main_preview.dart:895` for the capture
harness), but `WelcomeScreen.build` paints a full-bleed **opaque**
`DecoratedBox(gradient: colors.gradientBrandBackdrop)` inside `SizedBox.expand`,
which occludes that layer completely. The source treats the particles as
`position:absolute` siblings of the screen body, so CSS paints them *above* each
screen's own opaque background — `CupidStarField`'s own docstring states this and
prescribes the fix.

**Fix**, mirroring the pattern already in `vow_screen.dart:270-272`: wrap the
welcome body in a `Stack` and add `const Positioned.fill(child: CupidStarField())`
as the last child, above the backdrop.

One non-obvious detail: the `Stack` must be `fit: StackFit.expand`. With the
default loose fit the body would shrink-wrap, and the
`CrossAxisAlignment.stretch` from fix 4.1 would then size the hero to its widest
child — silently reintroducing the exact centring defect 4.1 removed. The widget
test asserts the fit for that reason.

`CupidStarField` builds its own `IgnorePointer` + `ExcludeSemantics` (the
source's `pointer-events:none`), so sitting above the CTAs cannot swallow their
taps. The test asserts that too.

**Re-verified** by rebuilding, reinstalling and re-capturing. All three
particles now render, at matching positions (section 5.4).

## 5. Region-by-region findings (this story's fresh pair, post-fix)

All values in logical px.

### 5.1 Horizontal

| Landmark | Reference | Implementation | Delta |
|---|---|---|---|
| Wordmark "Cupid" ink left | 30.7 | 29.8 | -0.9 |
| Accent rule left | 28.6 | 27.8 | -0.8 |
| Accent rule width x height | 55.1 x 4.2 | 52.3 x 4.2 | spec is 52 x 4 |
| Tagline line 1 left | 28.6 | 28.6 | 0.0 |
| Tagline line 2 left | 29.7 | 29.4 | -0.3 |
| Sub-copy line 1 left | 28.6 | 28.2 | -0.4 |
| Sub-copy line 1 right (wrap width) | 282.8 | 281.9 | -0.9 |
| Sub-copy line 2 left | 28.6 | 29.0 | +0.4 |
| Google pill left / right | 21.2 / 389.8 | 20.2 / 391.4 | within AA + shadow |
| Email pill left / right | 20.1 / 390.8 | 20.2 / 391.4 | +0.1 / +0.6 |
| Footnote ink left / right | 46.6 / 360.1 | 44.6 / 365.8 | centred, within AA |

Every horizontal landmark agrees within ~1 logical px except the accent rule
width and the footnote ink extents, both of which are anti-aliasing/hinting
differences on sub-1.0-alpha elements rather than layout differences (the
implementation's accent rule measures 52.3 against a spec of exactly 52).

### 5.2 Vertical (inset-independent deltas)

| Delta | Reference | Implementation | Diff |
|---|---|---|---|
| Wordmark bottom to accent rule top | 17.0 | 16.0 | -1.0 |
| Accent rule bottom to tagline L1 top | 21.2 | 21.4 | +0.2 |
| Tagline L1 top to L2 top | 31.8 | 30.1 | -1.7 |
| Tagline L2 bottom to sub-copy L1 top | 20.1 | 20.6 | +0.5 |
| Sub-copy L1 top to L2 top | 23.3 | 22.1 | -1.2 |
| Google pill height | 51.9 | 51.9 | 0.0 |
| Google pill bottom to Email pill top | 13.8 | 11.9 | design shadow inflates REF; true gap 10 |
| Email pill bottom to footnote ink top | 20.2 | 21.4 | +1.2 (was 7.9 pre-fix) |

Hero vertical centring, which is the design's `flex:1; justify-content:center`:

- Implementation: safe-area top 48.8 to wordmark ink top 284.2 = **235.4** above;
  sub-copy ink bottom 489.1 to Google pill top 724.4 = **235.3** below.
  Symmetric to 0.1 logical px.
- Reference: 235.1 below, implying the canvas frame's `--safe-top` is ~4.3.

### 5.3 Opacity / contrast

Alpha estimated by solving `c = a*255 + (1-a)*bg` at ink peaks, normalised
against the known-opaque tagline (Flutter's anti-aliasing never reaches a peak
of 255; the tagline calibrates the peak factor at 0.89).

| Element | Design spec | Reference | Implementation |
|---|---|---|---|
| Accent rule | .55 | .55 | .56 |
| Sub-copy | .78 | .80 | .78 |
| Footnote | .65 | .64 | .70 |

The footnote reads at essentially the same contrast on both sides. This
**disproves** the UX spec's "near-zero contrast" hypothesis for the footnote —
it was treated as a hypothesis to test against a fresh render, not as a work
item, and the render does not support it. No change made.

### 5.4 Twinkle star particles (post-fix)

Bright-blob sweep over logical y 40-300, thresholded against the per-row median
luminance so the smoothly-varying backdrop does not register.

| Particle | Reference centre | Implementation centre | Delta |
|---|---|---|---|
| pink, d=4 | (343.8, 84.5) | (344.1, 84.3) | (+0.3, -0.2) |
| white, d=6 | (35.2, 131.6) | (36.0, 131.0) | (+0.8, -0.6) |
| lavender, d=5 | (380.9, 240.4) | (380.7, 240.3) | (-0.2, -0.1) |

Peak hues also agree: lavender (206,180,255) vs (205,175,251); pink (255,217,234)
vs (246,203,230).

Two properties are deliberately **not** asserted as exact matches:

- **Per-particle opacity.** The `twinkle` keyframes run continuously on both
  sides (periods 3.4s / 4.6s / 5.2s, opacity 0.25-1.0), so any two captures
  sample different phases. Presence, position, diameter and hue are the
  checkable properties; instantaneous alpha is not.
- **Absolute y.** The particles are positioned as fractions of their fill box.
  The implementation's box is the full 915.6 logical screen; the design canvas's
  is the 869.5 logical gradient region. The measured ratio 915.6/869.5 = 1.053
  accounts for the entire absolute offset, and both sides sit within ~0.5 px of
  the same fractions (0.09, 0.14, 0.26 of height). Same chrome-inset difference
  already described in 5.6, not a placement difference.

### 5.5 Criteria confirmed matching

- Hero left-alignment at the design's 28px padding (after fix 4.1).
- Accent rule present, correct size and opacity.
- Tagline and sub-copy wrap at the same widths (sub-copy right edge 281.9 vs 282.8).
- Google CTA is a filled white pill carrying the real multicolour "G" glyph.
- Email CTA is an outlined pill, not a bare text link.
- Pill corner radius matches on both sides.
- CTA block is bottom-pinned with 20px horizontal padding.
- Apple CTA correctly absent on Android.
- Backdrop gradient axis 15.01 deg against the reference's 14.98 deg, and all
  four corner colours within 1/255 (after fix 4.3).
- All three twinkle particles present at matching fractional positions,
  diameters and hues (after fix 4.4).

### 5.6 Ruled out as non-deviations

- **Footnote to screen bottom** (REF 31.7 vs IMPL 22.2): device chrome, not a
  layout bug. The emulator reports `statusBars` 128px = 48.8 logical and
  `navigationBars` 63px = 24.0 logical; the design canvas frame uses
  `--safe-top` ~4.3 and `--safe-bot` ~10. Both sides implement the CSS's
  `calc(var(--safe-bot) + 20px)` correctly — the implementation's 20px above the
  safe area matches the source exactly. Only the inset values differ.
- Font anti-aliasing differences between Chromium and Skia.
- Status bar treatment: the design frame paints an opaque strip; the app is
  edge-to-edge. Excluded by the phase's ignore list.
- The reference image's device bezel.

## 6. Code changed

### Phase P1 (fix 4.3), inside the Tech Lead carve-out

- `mobile/lib/design_system/tokens/cupid_css_angle_gradient.dart` (new) —
  `CupidCssAngleGradient extends LinearGradient`, overriding `createShader`.
  It derives the CSS direction from the existing `begin`/`end` pair rather than
  storing an angle, so `const` construction, `==` and `hashCode` semantics are
  unchanged and the pre-fix `Alignment` constants remain the natural degradation
  path if `lerp`/`scale` ever drops the subclass.
- `mobile/lib/design_system/tokens/cupid_color_tokens.dart` — one import, two doc
  comments, and the four `const LinearGradient(` -> `const CupidCssAngleGradient(`
  construction sites for `gradientBrandBackdrop` and `gradientHot` in both themes.
  Field types stay `LinearGradient`, so `copyWith` and `lerp` compile with no
  consumer edits.
- `mobile/test/design_system/gradient_axis_test.dart` (new) — 15 tests.

`git diff e28a6c2 --stat` touches **zero** consumer widget files. `gradientDream`,
`_gradient120*`, every other token, every other design-system file,
`mobile/assets/**` and `mobile/pubspec.yaml` are untouched.

### Phase P0 and cycle-1 rework

Three changes, all inside the P0 Write Scope:

- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart`
  - `CrossAxisAlignment.stretch` on the outer Column (fix 4.1)
  - `_footnoteMargin` constant and `SizedBox(height: _ctaGap + _footnoteMargin)` (fix 4.2)
  - body wrapped in `Stack(fit: StackFit.expand, ...)` with
    `const Positioned.fill(child: CupidStarField())` as the **last** child
    (fix 4.4). `StackFit.expand` is load-bearing: with the default loose fit the
    body shrink-wraps and the `CrossAxisAlignment.stretch` from fix 4.1 would
    size the hero to its widest child, silently reintroducing defect 4.1.
- `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart`
  - new test `hero block starts at the design left padding, not centered`,
    asserting **painted x** via `tester.getTopLeft(...).dx` rather than the
    widget-tree property. The pre-existing test asserted only
    `hero.crossAxisAlignment == CrossAxisAlignment.start` and passed while the
    screen rendered centred — a textbook IF-7 illustration, now guarded.
  - new test `the shared twinkle star field paints over the backdrop`, asserting
    presence, last-child ordering, `StackFit.expand`, and the `IgnorePointer`
    that keeps the particles from swallowing CTA taps.
  - footnote gap assertion `_ctaGapExpectation + _footnoteMarginExpectation`
  - supporting constants `_heroPaddingExpectation`, `_footnoteMarginExpectation`

In P0 no file under `mobile/lib/design_system/**` was modified; the design-system
files above were changed only in P1, under Tech Lead's explicit carve-out. No
file under `mobile/assets/**`, `mobile/pubspec.yaml`, any other screen, or any
STORY-004 / STORY-033 / BUG-20260816-001 artifact was modified in either phase.

## 7. Verdict

```
VISUAL_FIDELITY: PASS
```

All four rendered deviations on record are fixed and re-verified against a
freshly re-captured pair:

| # | Deviation | Before | After |
|---|---|---|---|
| 4.1 | Hero block centred instead of left-aligned | hero left 72 vs 30 | within ~1 px |
| 4.2 | Footnote gap short | 7.9 vs 20.2 | 21.4 vs 20.2 |
| 4.3 | Backdrop gradient axis (D1) | **6.86 deg** vs 14.98 | **15.01 deg** vs 14.98 |
| 4.4 | Twinkle particles absent | 0 of 3 | 3 of 3, within ~1 px |

D1 is **RESOLVED**. The P0 `SCOPE_BOUNDARY_BLOCKED` escalation is closed by the
Phase P1 carve-out: the fix landed in
`mobile/lib/design_system/tokens/cupid_css_angle_gradient.dart` plus the four
construction sites in `cupid_color_tokens.dart`, and both halves of the CSS
contract (declared angle and gradient-line extent) now hold on every consumer box
shape. The ~20 `gradientHot` consumers are covered numerically by the box-shape
matrix rather than by per-screen captures, per Tech Lead's sizing decision.

No new visible deviation surfaced from the corrected geometry on this screen, and
the full suite plus every `*_design_fidelity_test.dart` pass unchanged (section 6
of `coding-plan/test-results.md`).
