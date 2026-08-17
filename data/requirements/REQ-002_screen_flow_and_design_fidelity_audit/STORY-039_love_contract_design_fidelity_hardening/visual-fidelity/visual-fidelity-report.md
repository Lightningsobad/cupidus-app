# STORY-039 — Love Contract Screen Visual Fidelity

VISUAL_FIDELITY: PASS

## Scope Of This Comparison

STORY-039 is the RED-PATCH retro story for STORY-015. It re-runs the
rendered-to-rendered design comparison for the `contract` screen and closes the
two defects the retro raised:

- **DEF-1** — `clause_toggle_row.dart` used a circular Material glyph pair
  (`check_circle` / `radio_button_unchecked`) with the `§N` id in the leading
  column, instead of the design source's 24x24 radius-9 box in the leading
  column with the `§N` id trailing.
- **DEF-2** — `hold_to_sign_button.dart` was a flat pill with no glow, a
  left-to-right progress fill and a trailing spinner, instead of the design
  source's 64px `--r-card` slab with `--glow`, a right-to-left dim overlay and a
  conic-gradient touch puck.

Excluded from pass/fail per `story_master.md` AC1 and re-confirmed as excluded
by this render (see "Confirmed Out Of Scope"): DEF-3, F-1, F-2, F-3, F-5.

## Evidence Pair

| Role | File | Size | Theme / locale |
| --- | --- | --- | --- |
| Design reference | `design-reference-contract-android.png` | 406x900 | dark / `vi` |
| Implemented app | `implemented-contract-emulator-5560.png` | 405x900 | dark / `vi` |

Both sides render a 412x915 Android viewport downscaled to 900 px tall, so the
scale factor is `900/915 = 0.98361` on both sides and **image pixels are
directly comparable between the two files** without renormalisation. Design
pixels quoted below are image pixels divided by that factor.

One framing difference must be held constant when reading horizontal numbers:
the design canvas paints a phone shell *inside* its 412 px canvas. Its bezel
occupies image columns `1..8` and `398..405`, so the reference's inner screen is
389 image px (395.5 design px) wide, while the capture is the device's full
412 dp screen (405 image px). Horizontal geometry is therefore compared as
**insets relative to the card**, never as absolute widths.

## Method

1. `render-design-canvas.js --entry="Cupid App.dc.html" --screen=contract
   --platform=android --theme=dark --lang=vi --max-edge=900` for the reference.
2. `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=contract
   --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=partnerAlreadySigned`, then
   `capture-mobile-screen.sh --label=contract --device=emulator-5560 --width=412
   --density=160 --max-edge=900` for the implemented side. The state is faked by
   the preview fixture, never driven through the backend.
3. Both PNGs decoded with a stdlib `zlib`/`struct` reader and probed
   programmatically (edge runs, bounding boxes, corner-inset profiles, channel
   samples, dash duty-cycle detection). No measurement below is eyeballed.

### Why `partnerAlreadySigned` is the capture state

The design canvas renders its `myUnsigned` branch (line 160). Of the states the
preview harness can fake without touching `lib/main_preview.dart` — which is
outside this story's write scope — `partnerAlreadySigned` is the only one that
renders **both** DEF surfaces at once: the clause list with mixed on/off toggles
(DEF-1) and the unsigned hold control (DEF-2). It maps onto the same design
`myUnsigned` branch and differs from it only by the extra acknowledgment line
and the hidden add-clause row (ADR-019e hides it for the partner viewer). Those
two differences are state, not fidelity, and are called out where they affect a
D-item.

## Measured Comparison (image px; design px = image px / 0.98361)

### DEF-1 surface — clause toggle

| Property | Design source | Reference | App | Delta |
| --- | --- | --- | --- | --- |
| Checkbox box W x H (line 141/144: `24px`) | 23.6 x 23.6 | 24 x 23 | 24 x 24 | <=1 |
| Filled-pixel ratio inside the bbox (radius signature; `border-radius:9px` -> 0.879, a circle would be 0.785, a square 1.000) | 0.879 | 0.857 | 0.842 | 0.015 |
| Checkbox fill TL / BR (`--grad-hot`) | `#FF7FB6` -> `#B78CF5` | (240,128,193) / (196,137,232) | (243,129,193) / (197,138,233) | <=3 per channel |
| Checkbox left inset from card edge (`padding:8px` list + `padding:12px` row) | 20 | 20.3 | 19.3 | 1.0 |
| Clause row pitch (`12 + 24 + 12`) | 48 | 47.0 | 48.0 | 1.0 |
| Column order | box, text, `§N` | box, text, `§N` | box, text, `§N` | identical |

### DEF-2 surface — hold-to-sign control

| Property | Design source | Reference | App | Delta |
| --- | --- | --- | --- | --- |
| Control height (line 161: `height:64px`) | 62.9 | 63 | 63 | 0 |
| Corner-inset profile, rows 0..13 from the top edge (`--r-card` = 24) | — | 17,14,12,11,9,8,7,6,5,4,4,3,3,2 | 18,15,13,11,10,8,7,6,6,5,4,3,3,3 | <=2 |
| Fill at rest, L / R (`linear-gradient(95deg,--pink,--purple)` under `rgba(0,0,0,.28)`) | — | (182,91,132) / (132,100,175) | (182,91,132) / (133,101,175) | <=1 per channel |
| Touch puck ring diameter (line 163: `32px`) | 31.5 | 30 | 31 | 1 |
| Touch puck inner disc W x H (line 163: `24px`) | 23.6 | 24 x 22 | 24 x 23 | <=1 |
| Puck inner disc colour (`--pink`) | — | (255,127,182) | (255,127,182) | 0 |
| Glow (`--glow` = `0 8px 28px rgba(255,107,168,.34)`) | present | present | present | — |

The fill row is the single most load-bearing measurement in this report. The
reference's resting button is `--grad-hot` seen *through* the `rgba(0,0,0,.28)`
dim, because `holdInvPct` is `100 - hold` and therefore 100 at rest (design
source line 2155). The app now reproduces both endpoints to within 1/255, which
is only possible if the gradient, the dim colour, the dim opacity and the dim's
full-bleed coverage are all correct simultaneously.

### Shared card chrome

| Property | Design source | Reference | App | Delta |
| --- | --- | --- | --- | --- |
| Card horizontal margin (line 130: `padding:18px 16px 40px`) | 16 | 15.2 | 16.3 | 1.1 |
| Dashed rule 1 (header -> clause list), duty cycle | ~0.5 | 0.43 | 0.41 | 0.02 |
| Dashed rule 2 (clause list -> sign section), duty cycle | ~0.5 | 0.31 | 0.39 | 0.08 |
| Dash pitch along a rule | — | 4.96 | 5.93 | 0.97 |
| Sequence-label ink band top | — | y=143 | y=143 | 0 |
| Sign-section horizontal padding (line 152: `padding:16px 20px 22px`) | 20 | 20.3 | 15.3 | 5.0 (F-3, excluded) |

## Deviation Found And Fixed In App Code (AC4)

### DEF-2a — the dim overlay rendered with zero height

The first post-fix render still showed the resting button at full `--grad-hot`
brightness ((250,127,185)-class pixels) where the reference showed the dimmed
(182,91,132) / (132,100,175) pair. The dim layer was present but invisible.

- Cause: the overlay was `Align(centerRight) -> FractionallySizedBox(widthFactor:
  1 - progress) -> ColoredBox`. `FractionallySizedBox` only tightens the axis it
  is given a factor for; with no `heightFactor` the childless `ColoredBox`
  collapsed to its smallest size, i.e. zero height. The layer painted a
  full-width, zero-tall band.
- Design source line 162 is `position:absolute;inset:0` — the layer spans the
  full height and only its **width** tracks the dwell.
- Fix: `Positioned.fill -> Align(centerRight) -> FractionallySizedBox(heightFactor:
  1, widthFactor: 1 - progress) -> ColoredBox`.
- After the fix both gradient endpoints match the reference to within 1/255
  (table above), and the DEF-2 regression test asserts `widthFactor == 1.0` and
  `alignment == Alignment.centerRight` at rest.

## DEF-1 / DEF-2 Disposition

| Id | Item | Disposition |
| --- | --- | --- |
| DEF-1 | Clause toggle used circular glyphs, `§N` leading | **Fixed this story.** `_ClauseCheckbox` is a 24x24 `BorderRadius.circular(9)` box: `gradientHot` fill behind a 16px `CupidIcons.check` when on, bare `1.5` `colorLine` outline when off. Column order is now box / text / `§N`, with the `§N` at 9.5px mono and `CupidSpacing.xs` (4) top padding. Geometry, fill gradient and radius signature all verified above. |
| DEF-2 | Hold control was a flat no-glow pill with a left-to-right fill and a spinner | **Fixed this story.** 64px slab at `platformTokens.radiusCard`, `colors.glowShadow`, right-anchored dim overlay receding right-to-left, and a 32px `SweepGradient` touch puck around a 24px `colorAccentPink` disc carrying the 15px `touch_app` glyph. The spinner and the `FractionallySizedBox` left fill are gone. |
| DEF-2a | Dim overlay had zero height (found by this render) | **Fixed this story.** See above. |

## D-1 Through D-13 Re-verification (AC2)

| Id | Item | Disposition in this render |
| --- | --- | --- |
| D-1 | Screen was three loose blocks, design is one unified card | Re-confirmed. One continuous `--surf` card at `--r-card` carries header, clause list and sign section in both renders; the footer lock note is the only element outside it, in both. |
| D-2 | Missing dashed section separators | Re-confirmed. An automated dash detector (duty cycle between 0.25 and 0.75, plain rows 4 px above and below) finds exactly two rules on each side: reference y=235 / y=482, app y=243 / y=463. Duty cycles agree to 0.02 and 0.08. Dash pitch is residual R-2. |
| D-3 | Header had no gradient wash | Re-confirmed. Sampling the header's left edge every 24 px shows the same two-stop wash on both sides (reference (74,35,79) -> (71,34,81), app (75,45,87) -> (74,45,88)), terminating at the first dashed rule. Absolute channel offset is the `--surf` base difference tracked as F-1, excluded. |
| D-4 | Sequence label at the wrong size, tracking and case | Re-confirmed. The label's ink band starts at y=143 on **both** sides, and `love_contract_screen_fidelity_test.dart` pins `Roboto Mono` / 10 px / 1.8 tracking / `colorAccentPink` / uppercase. |
| D-5 | Contract title had no line-height compression | Re-confirmed as compressed: the title ink band is a single 24-27 px band immediately under the label on both sides, not a loose two-line box. Its 27 vs 24 px ink height is the type-size question F-2, excluded. |
| D-6 | Header inner rhythm was half the design's | Re-confirmed. Label -> title -> subtitle render as three separated bands on both sides (reference 143/163/204, app 143/170/211) rather than the pre-STORY-015 collapsed pair. The 5-7 px band-to-band drift follows from the F-2 title size, excluded. |
| D-7 | Duplicated plus glyph on the add-clause affordance | Re-confirmed by test, not by this render: the capture state is the partner viewer, which hides the add-clause row (ADR-019e). `love_contract_screen_fidelity_test.dart` asserts exactly one `+ Thêm điều khoản riêng` text and no `CupidIcons.add` inside the button. |
| D-8 | Add-clause row sat outside the clause list block | Re-confirmed by structure, not by this render (same partner-viewer reason). The row is built inside the clause-list section of `love_contract_screen.dart`, above the second dashed rule. |
| D-9 | Sign caption was only shown in the unsigned states | Re-confirmed **in this render, which is exactly the state D-9 was about**: the capture is `partnerAlreadySigned`, and the caption `Giữ ngón tay để ký — cam kết thì phải nặng tay một chút` is present directly above the hold control, matching the reference. |
| D-10 | Signed card used the wrong tint, border and layout | Re-confirmed by test, not by this render (the capture is unsigned for this viewer). Two fidelity tests pin `colorGreen` @ 12% fill, `colorGreen` @ 40% hairline, `radiusCard`, `minHeight: 64` and the green 18px check for both the self-signed and both-signed states. |
| D-11 | Footer lock note had no lock glyph | Re-confirmed. Both renders show the mint lock glyph followed by `Bản hợp đồng lưu ở Level 2 — mã hoá đầu-cuối`, centred, outside the card. |
| D-12 | Screen padding did not follow the design's asymmetric block | Re-confirmed. Card horizontal margin measures 15.2 (reference) vs 16.3 (app) against the design's `16`, a 1.1 px delta that is entirely the design shell's slightly narrower inner screen. |
| D-13 | Sign-action error banner floated outside the card | Re-confirmed by structure, not by this render (no error state in a static capture). The banner is built inside the card's sign section, above the caption, in `love_contract_screen.dart`. |

No D-item regressed, and no D-item was found to have been claimed but not
delivered.

## Confirmed Out Of Scope

| Id | Item | Status after this render |
| --- | --- | --- |
| DEF-3 | Both-signed CTA (`Cả hai đã ký → Fingerprint Vow`, design line 170) | Still out of scope — Scope A territory per `story_master.md` AC1. Not touched. Not reachable in this capture state either way. |
| F-1 | Token hue vs design source hue | Still excluded per AC1. Visible in this render as the header-wash base offset ((74,35,79) vs (75,45,87)) and the `--surf` channel offset. Deliberately not "fixed". |
| F-2 | Token type size vs design source size | Still excluded per AC1. Visible as the title ink height (27 vs 24 px) and the resulting 5-7 px header band drift. Deliberately not "fixed". |
| F-3 | Token padding vs design source padding | Still excluded per AC1. Visible as the sign-section horizontal padding (20.3 vs 15.3 px — the app snaps the design's `20` to `CupidSpacing.md` = 16). Deliberately not "fixed". |
| F-5 | Copy diff | Still excluded. The reference subtitle reads `Giữa Minh & Linh · có hiệu lực đến khi cả hai cùng huỷ`; the app renders `Có hiệu lực đến khi cả hai huỷ`. Not touched. |

### Observed but not a fidelity defect

- **Clause counter `2/20 điều khoản`.** Present in the app, absent from the
  design canvas. It is the localized `loveContractClauseCounter` string backing
  the product's 20-clause cap (exercised by `the 20-clause cap disables the
  add-clause action`), not a STORY-015 chrome deviation. Removing it would be a
  product-copy change, outside this story's scope; it belongs to the F-5 copy
  family. Its row is why the app's clause list starts ~26 px lower than the
  reference's.
- **Acknowledgment line `Minh Anh đã ký, đến lượt bạn`** and the **hidden
  add-clause row** are consequences of the `partnerAlreadySigned` capture state
  (ADR-019e), not deviations.

## Residuals Within Tolerance

### R-1 — clause row pitch 1 px taller than the reference
The app's clause rows sit at a 48.0 px pitch against the reference's 47.0. The
design row box is `12 + 24 + 12 = 48`, so both are correct to within
antialiasing; the app additionally keeps
`ConstrainedBox(minHeight: platformTokens.tapTarget)` (48 dp) as an
accessibility floor, which cannot make the row shorter than the design and in
this configuration coincides with it exactly.

### R-2 — dash pitch along the dashed rules
Reference dashes repeat every 4.96 px, the app's every 5.93 px. The design
source only specifies `1px dashed var(--line)`; the dash period is left to the
renderer, and CSS and Flutter's dashed painter pick different defaults. Duty
cycle — the property that determines how the rule reads at a glance — matches
to 0.02 and 0.08.

### R-3 — clause checkbox uses the 95deg `gradientHot` token
Design line 141 cites `var(--grad-hot)`, declared at `120deg`; the app paints
the token, which is normalised to 95deg. On a 24x24 box the difference is
unmeasurable: the fill corners match the reference to within 3/255.

### R-4 — literal 12 px row geometry
`_rowPadding` and `_rowGap` are the design source's literal `12` from line 139,
which is not a `CupidSpacing` step. These are DEF-1 row geometry (the thing this
story exists to fix), distinct from the card-*section* padding tracked as the
excluded F-3 policy question, so they are written as documented local constants
rather than snapped to a token.

### R-5 — `touch_app` icon declared locally
`_iconTouchApp` (`0xe913`) is declared in `hold_to_sign_button.dart` rather than
added to `CupidIcons`, because `design_system/` is outside this story's write
scope. The codepoint was confirmed against the bundled
`MaterialSymbolsRounded-Variable.ttf` `cmap` (glyph 6243, single codepoint, no
alias), never guessed. Promoting it to `CupidIcons` is a follow-up, not a defect.

## Verification Run In This Session

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/love_contracts test/features/love_contracts` | `No issues found! (ran in 2.2s)` |
| `flutter test test/features/love_contracts` | `00:02 +82: All tests passed!` |
| `flutter test` (full mobile suite) | `+1267 ~2: All other tests passed!` (exit 0) |
| `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=contract --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=partnerAlreadySigned` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |
| `render-design-canvas.js --entry="Cupid App.dc.html" --screen=contract --platform=android --theme=dark --lang=vi --max-edge=900` | `DESIGN_CANVAS: OK ... design-reference-contract-android.png 406x900` |
| `capture-mobile-screen.sh --label=contract --device=emulator-5560 --width=412 --density=160 --max-edge=900` | `MOBILE_CAPTURE: OK ... implemented-contract-emulator-5560.png 405x900` |

Toolchain: Flutter 3.44.1 / Dart 3.12.1. Device: `emulator-5560`, Android 16
(API 36). The capture temporarily set the display to 412x915 @ 160 dpi and the
script restored it on exit.

## Files Changed

- `mobile/lib/features/love_contracts/presentation/widgets/clause_toggle_row.dart`
  — DEF-1.
- `mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`
  — DEF-2 and DEF-2a.
- `mobile/test/features/love_contracts/presentation/love_contract_screen_test.dart`
  — the on/off affordance assertion now tracks a checkbox-shape change instead
  of an icon-codepoint change.
- `mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart`
  — added the DEF-1 and DEF-2 regression tests; scoped the both-signed
  check-glyph finder to the signed card, which the DEF-1 fix made ambiguous.

`love_contract_screen.dart` needed no change: both defects were inside the two
widgets.
