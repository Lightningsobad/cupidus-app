# Visual Fidelity Report: STORY-055 Design System FAB/CTA Shape and Sizing Fidelity

VISUAL_FIDELITY: PASS

Scope: RWB-20260816-021 — D-1 (`CupidAddAction` Material FAB) and D-2
(`CupidPrimaryButton` height/font-size/leading glyph). Both are shared
`design_system/adaptive/**` components; the Expense History screen is the
rendered anchor because it is the only screen carrying both in the exact
configuration STORY-043 already rendered.

Design-Screen: `expense` — reused from STORY-043, not re-resolved. Per this
story's `## Out of Scope`, `design-reference-expense-android.png` and
`design-reference-expense-ios.png` were **not** re-rendered; they are
byte-identical copies of STORY-043's pair
(`sha256 f8f5873ae8a6391141d95736e3e2af4496fb20471c0080f8b0e4f21f13a6ae69`
for the Android reference, verified against the source file after copy).

## Evidence

| File | What it is |
|---|---|
| `implemented-expense-emulator-5560.png` | Material silhouette, dark + `vi`, top of scroll (AC1, AC5) |
| `implemented-expense-fab-overlap-emulator-5560.png` | Material silhouette at maximum scroll (AC4 / M-1) |
| `implemented-expense-ios-emulator-5560.png` | iOS silhouette, dark + `vi`, top of scroll (AC5) |
| `implemented-expense-ios-cta-emulator-5560.png` | iOS silhouette scrolled to the full-width CTA (AC2, AC5) |
| `design-reference-expense-android.png` | STORY-043's existing Android reference, reused as-is |
| `design-reference-expense-ios.png` | STORY-043's existing iOS reference, reused as-is |

All paths are relative to this file's directory.

**Provenance.** All four `implemented-*` captures come from post-fix builds of
the same source tree (D-1 + D-2 landed). The two Material captures come from one
build (`--dart-define=PREVIEW=expense --dart-define=PREVIEW_EXPENSE_FIXTURE=true`)
and the two iOS captures from the same build plus
`--dart-define=PREVIEW_PLATFORM=ios`. No capture predates the fix.

### Capture setup

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=expense --dart-define=PREVIEW_EXPENSE_FIXTURE=true
adb -s emulator-5560 install -r -t build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --out=<this directory> --device=emulator-5560 --settle-ms=25000 --label=expense
```

The iOS silhouette adds `--dart-define=PREVIEW_PLATFORM=ios`. Theme and locale
are the app's shipped dark + `vi` configuration (OQ5 RESOLVED), not overridden.
`emulator-5560` was already running and was reused; no device was created,
booted, wiped, or repaired.

## AC1 — D-1 `CupidAddAction` Material FAB

Design source, `cupid-app-design-system/project/Cupid Screens.dc.html` line 881
(`isMD` add-action block), read directly rather than taken from the registry
paraphrase:

```
width:60px;height:60px;border-radius:20px;background:var(--grad-hot);
box-shadow:0 8px 24px rgba(255,127,182,.45)
```

with the glyph at `font-size:27px`.

| Property | Before | After | Design source | Verdict |
|---|---|---|---|---|
| Shape | `BorderRadius.circular(radiusButton)` → pill/circle | `BorderRadius.circular(20)` rounded square | `border-radius:20px` | MATCH |
| Fill | flat `colors.colorAccentPink` | `colors.gradientHot` | `var(--grad-hot)` | MATCH |
| Shadow | none | `colors.glowShadow` | `0 8px 24px rgba(255,127,182,.45)` | MATCH (see note) |
| Size | unset → Material default 56x56 | explicit 60x60 | `60px`/`60px` | MATCH |
| Glyph | default icon size | `27` | `font-size:27px` | MATCH |

Confirmed in `implemented-expense-emulator-5560.png`: the FAB renders as a
gradient (pink→purple) rounded square with a visible glow, matching the FAB in
`design-reference-expense-android.png`. Asserted in code by
`test/design_system/adaptive_widgets_test.dart`, "Material FAB is a 60pt rounded
square on the hot gradient" (size, gradient, boxShadow, borderRadius, glyph
size).

**Note on the glow token (requirements.md `## Assumptions`).** AC1 mandates
`colors.glowShadow`, and that is what is implemented. For the record, the FAB
block in the design source hardcodes `0 8px 24px rgba(255,127,182,.45)` rather
than referencing `var(--glow)` (which the iOS CTA block on line 884 does use).
Against the dark-theme `glowShadow` token
(`0 8px 28px rgba(255,107,168,.34)`) that is a blur difference of 4px and a
slightly warmer, more opaque colour. The divergence is not visually material at
the rendered size and does not change this story's verdict; it is recorded here
rather than silently substituted, so a future token decision has the measurement
if the team ever wants a FAB-specific glow token.

## AC2 — D-2 `CupidPrimaryButton`

Design source line 884 (`isIOS` CTA block):

```
height:52px;border-radius:var(--r-btn);background:var(--grad-hot);color:#fff;
display:flex;align-items:center;justify-content:center;gap:8px;
font-size:15.5px;font-weight:800;box-shadow:var(--glow)
```

with the leading glyph at `font-size:21px`.

| Property | Before | After | Design source | Verdict |
|---|---|---|---|---|
| Height | `54` | `52` | `height:52px` | MATCH |
| Label size | `16.5` | `15.5` | `font-size:15.5px` | MATCH |
| Label weight | `w800` | `w800` (unchanged) | `font-weight:800` | MATCH |
| Leading glyph | absent | `CupidIcons.add` at `21`, opt-in | `font-size:21px` | MATCH |
| Gap before label | n/a | `8` | `gap:8px` | MATCH |

The leading glyph size (21) was read from the design source directly; it is not
stated in the requirements and was not invented.

Confirmed in `implemented-expense-ios-cta-emulator-5560.png`: the CTA renders
the `+` glyph followed by a gap and the label "Ghi một khoản" on the gradient
pill with its glow. Asserted in code by the "opts in to a leading glyph with an
8pt gap" test (glyph size, and the measured 8pt gap between the glyph's right
edge and the label's left edge, on both platforms).

`leadingIcon` is optional and defaults to `null`, so the Expense History iOS
add-action CTA is the only call site that gains a glyph. The "paints the hot
gradient, the glow and the 52pt CTA band" test now also asserts that a
`CupidPrimaryButton` built without `leadingIcon` contains no `Icon` descendant,
so a future accidental default cannot slip in unnoticed.

## AC3 — No regression across every real consumer

- `flutter analyze lib test`: 0 errors, 0 warnings. 80 pre-existing `info`
  lints, none in any file this story touched.
- `flutter analyze` on the three touched files: `No issues found!`
- `flutter test`: `+1313 ~2: All other tests passed!` (1313 passed, 2 skipped,
  0 failures).

All 25 enumerated call sites compile unchanged: `leadingIcon` is an additive
optional parameter, so `CupidPrimaryButton(label:, onPressed:)` and
`CupidAddAction(onPressed:)` keep their existing signatures.

Rendered spot-check beyond the anchor is covered by the widget tests, which
build both components on both platform silhouettes; the height/font-size change
is a 2pt shrink inside an already-`SizedBox`-constrained band and introduces no
overflow or clipping.

## AC4 — M-1 (FAB overlap): re-confirmed, NOT fixed

`implemented-expense-fab-overlap-emulator-5560.png`, taken at maximum scroll on
the Material silhouette after the D-1 fix, shows the last row
("Nồi chiên không đầu") with its amount still clipped — rendered as `1.20…`
where the full value is `1.200.000₫`. **M-1 is still present and unchanged in
kind after D-1.**

The clipping is marginally wider than STORY-043 recorded, which is the expected
consequence of D-1 growing the FAB from 56x56 to 60x60 without a compensating
change to the scroll view's bottom padding. This is exactly the outcome
`story_master.md` predicted, and is the reason no AC in this story claims M-1
"clears" once D-1 lands.

M-1 is **Material-only**, re-confirmed by direct observation rather than
inference: in `implemented-expense-ios-cta-emulator-5560.png` the same row at
the same scroll extent renders its full `1.200.000₫`, because the iOS silhouette
has no FAB overlay.

**Root cause and why no fix is here.** The design keeps its add-action inside
the scrolling content flow (`position:sticky`, `margin-top:16px`, ahead of the
container's `padding-bottom:40px`), so no row can sit behind it. The
implementation uses `Scaffold.floatingActionButton`, a pure overlay, with the
scroll view's bottom padding still at the design's in-flow value of 40
(`_screenPadding` in `expense_history_screen.dart`). That padding is a
**screen-level property of `expense_history_screen.dart`**, not a property of
`CupidAddAction`, and therefore sits outside this story's
`design_system/adaptive/**` write scope. **No `expense_history_screen.dart`
scroll or padding logic was changed** (the only edit to that file in this story
is the one-argument `leadingIcon:` addition required by AC2). Closing M-1
requires a separate, screen-level item against the Expense History screen's own
bottom padding.

## Verdict

- D-1: PASS
- D-2: PASS
- AC3 no-regression: PASS
- M-1: confirmed still present, Material-only, out of write scope, documented
  only — as AC4 requires.

VISUAL_FIDELITY: PASS
