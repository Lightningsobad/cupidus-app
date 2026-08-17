VISUAL_FIDELITY: PASS

# STORY-038 — Paired Success Screen Visual Fidelity

Rendered-to-rendered comparison of the `paired` screen against its locked
design source, produced for AC1/AC2/AC5 of
`STORY-038_paired_success_design_fidelity_hardening`.

## Scope Of This Comparison

- Screen: `paired` (Design-Screen `paired`).
- Theme/locale: dark theme, `vi` locale, on both sides of the pair.
- Design source: `cupid-app-design-system/project/Cupid Screens.dc.html`,
  the `<sc-if value="{{ isPaired }}">` block at lines 1592-1608, with tokens at
  lines 23-27 and `@keyframes` at lines 28-40.
- App source: `mobile/lib/features/pairing/presentation/screens/paired_screen.dart`.
- Out of scope per `story_master.md`: D15 avatar initials, the CTA navigation
  seam (`onSignContract` stays nullable), light theme, and the `en` locale.

## Evidence Pair

| Role | File | Size | Theme / locale |
| --- | --- | --- | --- |
| Design reference | `design-reference-paired-android.png` | 406x900 | dark / `vi` |
| Implemented app | `implemented-paired-emulator-5560.png` | 405x900 | dark / `vi` |

Both files live in this story's own `visual-fidelity/` directory.

## Method

1. Design reference rendered with
   `.ai-team-bundle/runtime/tools/render-design-canvas.js` over the canvas
   bundle (`--location=cupid-app-design-system --entry="Cupid App.dc.html"`,
   screen `paired`, Android frame 412x915, `--max-edge=900`).
2. App capture taken with
   `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh` on
   `emulator-5560`, display temporarily resized to `--width=412 --density=160`
   (auto-reverted by the script), `--max-edge=900`, state faked through the
   preview harness (`lib/main_preview.dart`, `--dart-define=PREVIEW=paired`,
   deep link `cupidpreview://screen/paired`).
3. Scale calibration: the reference is 406 px for a 412 design-px frame
   (0.98330 px per design px); the capture is 405 px for a 412 dp display
   (0.98301 px per dp). The two are therefore ~1:1 comparable, and every number
   below is reported in design px / dp.
4. Every value below is a pixel measurement taken from the two PNGs with the
   same detector applied to both, not a reading of the source.

## Measured Comparison (design px / dp)

| Property | Design source | Reference | App | Delta |
| --- | --- | --- | --- | --- |
| Avatar element (border) box | 82 | 81.26 | 81.28 | 0.02 |
| Avatar visible disc | 76 | 75.26 | 75.28 | 0.02 |
| Cluster visible span | 136 | 135.26 | 135.30 | 0.04 |
| Left disc visible chord (occluded) | 57 | 56.95 | 55.95 | 1.00 |
| Cluster horizontal centring | 0 | +0.51 | +0.00 | 0.51 |
| `self` disc gradient TL / BR | `#FFB1D3` / `#C79BF0` | (243,172,216) / (209,159,234) | (249,175,214) / (205,157,237) | <=8 per channel |
| `partner` disc gradient TL / BR | `#A8F0DF` / `#C79BF0` | (173,222,226) / (192,171,236) | (171,230,225) / (196,164,238) | <=8 per channel |
| Heart ink horizontal offset | — | -4.07 | -4.07 | 0.00 |
| Title ink height | — | 26.44 | 26.45 | 0.01 |
| Title ink width | — | 284.76 | 289.93 | 5.17 |
| Title horizontal centring | 0 | +0.00 | +0.00 | 0.00 |
| Cluster bottom -> title ink top (`margin-top:28px`) | 28 + leading | 32.59 | 33.62 | 1.03 |
| Body line pitch (`13.5 x 1.6`) | 21.6 | 21.36 | 21.36 | 0.00 |
| Body line 1 ink width | — | 258.31 | 268.56 | 10.25 |
| Body line 1/2 wrap points | — | after `là của` / `lui đâu` | after `là của` / `lui đâu` | identical |
| Chip gap at the same probe depth (`gap:12px`) | 12 + corner bias | 20.34 | 20.35 | 0.01 |
| Chip widths (1/2/3) | — | 49.83 / 74.24 / 60.00 | 51.88 / 75.28 / 61.04 | <=2.05 |
| Chip row width | — | 224.75 | 228.89 | 4.14 |
| Chip height | — | 69.15 | 73.24 | 4.09 |
| Chip row horizontal centring | 0 | +0.51 | +0.00 | 0.51 |
| Chip bottom -> CTA top (`margin-top:30px`) | 30 | 30.51 | 30.52 | 0.01 |
| CTA pill height | 54 | 53.90 | 53.92 | 0.02 |
| CTA pill width | 300 (max-width) | 300.01 | 300.10 | 0.09 |
| CTA gradient left / right (`--grad-hot`) | — | (250,127,185) / (187,139,240) | (253,127,184) / (185,140,244) | <=4 per channel |
| CTA label ink height | — | 11.19 | 11.19 | 0.00 |
| CTA label ink width | — | 142.38 | 145.47 | 3.09 |
| CTA label vertical centring in pill | 0 | +0.00 | +0.00 | 0.00 |
| Wash pinkness (R-G) sampled every 40 px down the left edge | — | 33/32/29/27/24/22/19/12/6 | 33/32/30/27/25/22/18/11/6 | <=2 per sample |

## Deviation Found And Fixed In App Code (AC3)

### F1 — couple-presence avatar cluster rendered 6 dp too small (D3 surface)

The design writes each avatar as
`width:76px;height:76px;border:3px solid var(--bg)` with `margin-left:-22px` on
the second one. The canvas has no global `*{box-sizing:border-box}` rule —
`box-sizing` appears only inline on the toggle-switch elements — so those
avatars are **content-box**: each element measures 82x82 with a 76 px visible
gradient disc, and the cluster measures 82 + 82 - 22 = **142** wide.

Flutter strokes `Border.all` *inside* the box, so the shipped
`Container(width: 76, height: 76, border: Border.all(width: 3))` produced a 76 dp
element with only a **70 dp** visible disc, inside a 130 dp cluster with the
second avatar at `left: 54`. Derived exactly from the two sources:

| | Design | App before fix | App after fix |
| --- | --- | --- | --- |
| Avatar element box | 82 | 76 (-6) | 82 |
| Avatar visible disc | 76 | 70 (-6) | 76 |
| Second avatar offset | 60 | 54 (-6) | 60 |
| Cluster box width | 142 | 130 (-12) | 142 |
| Cluster visible span | 136 | 124 (-12) | 136 |

Fixed in `mobile/lib/features/pairing/presentation/screens/paired_screen.dart`
by declaring the avatar box at 82x82 (so Flutter's inside stroke leaves the
design's 76 dp disc) and the cluster at 142x82 with the second avatar at
`left: 60`. The fresh render pair above measures the corrected cluster at 81.28
vs 81.26 dp (element box), 75.28 vs 75.26 dp (disc) and 135.30 vs 135.26 dp
(span) — within 0.04 dp of the reference.

The floating heart keeps `top: -16` relative to the cluster box, so it tracks
the corrected geometry without further change; the render confirms the same
-4.07 dp ink offset on both sides.

## D1-D15 Re-verification (AC2)

Every deviation recorded by STORY-014 was re-checked against the actual rendered
app, not against STORY-014's prose. None were dropped.

| Id | Item | Disposition in this render |
| --- | --- | --- |
| D1 | Radial celebration wash | Re-confirmed. Pink amplitude and falloff match within 2/255 at every 40 px sample down the left edge. Wash centre inherits deviation A1. |
| D2 | Screen padding 40/26 | Re-confirmed in `EdgeInsets.symmetric(vertical: 40, horizontal: 26)`. Not directly measurable in the render: the widest child is the 300 dp CTA inside a 412 dp frame, so nothing reaches the horizontal padding edge. Vertical consequence is A1. |
| D3 | Couple-presence avatar cluster | **Not matching — fixed this story.** See F1. Now within 0.04 dp. |
| D4 | Floating heart | Re-confirmed. `top:-16` from the cluster box, horizontally centred on the cluster; both renders show the identical -4.07 dp ink offset, which proves the positioning math is the same. Glyph size differs by emoji font (residual R2). |
| D5 | Pop-in animation | Re-confirmed against `@keyframes popIn` (line 40) and `animation:popIn .6s cubic-bezier(.2,1.6,.4,1)`: 600 ms, `Cubic(0.2, 1.6, 0.4, 1)`, `scale 0.94 -> 1`, `translateY 8 -> 0`, `opacity 0 -> 1` with only opacity clamped against the curve's overshoot. |
| D6 | Bob animation | Re-confirmed against `@keyframes bob` (line 31) and `animation:bob 2s ease-in-out infinite`: a 1000 ms controller on `repeat(reverse: true)` with `Curves.easeInOut` and a -7 travel replays the keyframe's 0% -> 50% -> 100% over the full 2 s, and CSS applies its timing function per keyframe segment, so the two easings coincide. |
| D7 | Title copy | Re-confirmed in the render: `Ghép đôi thành công!`. |
| D8 | Title typography | Re-confirmed. Ink height 26.44 vs 26.45 dp; horizontally centred to 0.00 on both sides. Width residual R1. |
| D9 | Title gap | Re-confirmed. Cluster bottom to title ink top 32.59 vs 33.62 dp. |
| D10 | Supporting body line | Re-confirmed. Line pitch 21.36 dp on both sides against the design's `13.5 x 1.6`; identical wrap points; `max-width:275px` implemented exactly. Trailing emoji wrap is residual R1. |
| D11 | Stat chip row | Re-confirmed. Inter-chip gap 20.34 vs 20.35 dp measured at the same probe depth; row centring 0.51 dp apart; chip surface colour, 18 dp radius and 12/18 padding all match. Height residual R3. |
| D12 | Primary CTA | Re-confirmed. 300.01 vs 300.10 dp wide, 53.90 vs 53.92 dp tall, gradient endpoints within 4/255, pill fully rounded, glow present. |
| D13 | CTA typography | Re-confirmed. Ink height 11.19 dp on both sides, vertical centring identical. Width residual R1. |
| D14 | Content-overflow handling | Re-confirmed in code (`Center` + `SingleChildScrollView`) and exercised in this render: the app's body wraps to one more line than the reference and still lays out without clipping. |
| D15 | Avatar initials | Re-confirmed as **still correctly excluded**. The reference renders `M` and `L` inside the discs; the app renders none. Out of scope per `story_master.md`, unchanged by this story. |

## Approved Deviations, Not Defects

### A1 — vertical position of the whole content block

The design frame places the content block's centre 48.84 dp below the frame
centre; the app places it 12.74 dp below the screen centre, which is
approximately centred relative to its `SafeArea`.

Cause: the canvas' content container is
`min-height:100%;padding:40px 26px;justify-content:center` with default
content-box sizing, so its box is viewport + 80 px tall and overflows its
scroller by 80 px, pushing the centred children 40 px down. The app expresses
the same `justify-content:center` intent as `Center` inside `SafeArea`.

Not reproduced deliberately. Reproducing it would add an 80 dp phantom scroll
extent to a screen that otherwise fits, and the app already has to centre
against `SafeArea` because the design's `paired` frame carries no chrome and no
safe-area inset. Every internal spacing in the block matches within 1.03 dp,
which is what the design actually specifies.

This is consistent with the F1 fix rather than in tension with it: content-box
on the avatar changes the intrinsic rendered size of a visual element, which
must be reproduced; content-box on the page container only changes the scroll
extent of a viewport-sized box.

The radial wash centre inherits the same offset (~30 dp higher in the app),
because CSS paints that gradient on the same oversized box. Its colour,
amplitude and falloff match, and `RadialGradient(radius: 0.9)` remains the
correct farthest-corner equivalent for the app's own 412x915 box.

## Residuals Within Tolerance

### R1 — font advance width

Horizontal ink is consistently wider in the app at identical ink heights: title
+5.17 dp (+1.8%), body line 1 +10.25 dp (+4.0%), CTA label +3.09 dp (+2.2%),
chip widths +1 to +2 dp. Ink heights match to 0.01 dp and line pitch to 0.00 dp,
so this is advance width only, not a size or weight difference. Same class as
the residual recorded for STORY-037: the reference uses Chrome's font instance,
the app its bundled binary.

Visible consequence: the body's trailing `🎀` wraps to a third line in the app.
Line 2 measures 253.30 dp without it; adding the emoji crosses the design's
`max-width:275px`, which the app implements exactly. Both the max-width and the
copy are design-owned, so widening either to force a two-line wrap would be a
deviation from the locked source, not a fix.

### R2 — emoji glyph metrics

`💕` at the design's `font-size:26px` renders 16.27 x 21.36 dp in the reference
(Apple Color Emoji via Chrome) and 19.33 x 28.48 dp on the emulator (Noto Color
Emoji). Positioning is identical on both sides (-4.07 dp ink offset, same
`top:-16` anchor). Not correctable without hardcoding a font size that deviates
from the design's declared 26 px.

### R3 — chip height

Chip height 69.15 vs 73.24 dp (+4.09). The design declares no `line-height` for
the chip value (Nunito 900 22px) or its label (11px), so chip height is the sum
of two font-default line boxes, and those defaults differ between Chrome and
Flutter. Padding, radius, gap, colours and the value/label typography all match.

## Verification Run In This Session

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/pairing/presentation/screens/paired_screen.dart` | `No issues found! (ran in 1.1s)` |
| `flutter test test/features/pairing test/design_system` | `00:03 +159: All tests passed!` |
| `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=paired` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |
| `capture-mobile-screen.sh --label=paired --device=emulator-5560 --width=412 --density=160` | `MOBILE_CAPTURE: OK ... 405x900` |

Run from `mobile/` with Flutter 3.44.1 / Dart 3.12.1. The capture above is the
fresh post-fix render required by AC3; the reference was re-rendered from the
unmodified canvas bundle.

## Files Changed

- `mobile/lib/features/pairing/presentation/screens/paired_screen.dart`
