# Visual Fidelity Report: STORY-042 Love Timeline (Rendered Evidence)

VISUAL_FIDELITY: PASS

Story: STORY-042 Hardening — Love Timeline Visual Fidelity Evidence
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Fixes: STORY-025_love_timeline_design_fidelity (RWB-20260816-009)
Lane: mobile
Audited configuration: dark theme + `vi` locale, fixture active
Round: 1

This is the rendered-evidence pass STORY-025 never had. STORY-025 verified
design HTML against Dart source and widget tests only; every claim below is
re-checked against an actual pixel pair.

## Evidence

| File | What it is |
|------|------------|
| `implemented-timeline-emulator-5560.png` | 405x900, emulator-5560, top of screen |
| `implemented-timeline-bottom-emulator-5560.png` | 405x900, same build scrolled to the last row + add-memory button |
| `design-reference-timeline-android.png` | 406x900, `render-design-canvas.js --screen=timeline --platform=android --theme=dark --lang=vi` |
| `design-reference-timeline-android-scrolled-diagnostic.png` | 406x900, scrolled design render — diagnostic, see "Tool limitation" |
| `ac4-progress-ring-comparison.png` | 4x crop, design (left) vs app (right) |
| `ac4-dashed-border-comparison.png` | 4x crop, design (top) vs app (bottom) |

Design source of truth: `cupid-app-design-system/project/Cupid Screens.dc.html`
block `<sc-if value="{{ isTimeline }}">` (L699-730), sample rows L2279-2285.

### Capture setup (AC1)

`mobile/lib/main_preview.dart` gained a dev-only
`--dart-define=PREVIEW_TIMELINE_FIXTURE=true` guard on its `'timeline'` entry,
mirroring the existing `PREVIEW_HOME_FIXTURE`/`_previewHomeProfile` pattern.
When the define is absent — the default — the entry builds exactly as before
and `TimelineScreen` resolves the live `AccountRepository`/`TimelineRepository`
from the composition root, so live behaviour is unchanged. When it is set, the
entry supplies `TimelineScreen`'s existing optional `accountRepository`
parameter with a fixture whose `CupidProfile.relationshipStartDate` is
`now - 246 days` (the design's own anchor), plus a `TimelineRepository` fixture
replaying the design's own five sample rows.

Build/capture commands actually run:

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=timeline --dart-define=PREVIEW_TIMELINE_FIXTURE=true
adb -s emulator-5560 install -r -t build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --device=emulator-5560 --settle-ms=25000 --label=timeline
```

### Measurement basis

`emulator-5560` is 1080x2400 px at density 420 = 411.43 x 914.29 dp, captured
at 405x900 → **0.98437 PNG px per dp**. The design frame render includes the
phone bezel; screen content is inset ~8.5 px and scales **0.985 PNG px per CSS
px**, calibrated on the entry-card left/right edges (known CSS 42 and 379.5).
All numbers below are normalized to screen coordinates. Sub-pixel edges are
taken from anti-aliasing coverage; a stroke's position is its ink centroid.

## AC3 — STORY-025's 20 deviations re-verified in the render

| # | Element | Rendered verdict |
|---|---------|------------------|
| 1 | Screen container `padding:10px 16px 40px` | MATCH — countdown card top at 115 px in both; left/right margin 16 in both |
| 2 | Countdown card box, border, 140deg gradient | MATCH — height 88.5 px app / 89.5 px design, same gradient direction and 1px line border |
| 3 | Countdown headline 20px/900 | MATCH — "Còn 53 ngày" same size, weight, baseline |
| 4 | Countdown subtitle 12.5px muted, gap 4 | MATCH — see residual R-4 on the date *value* |
| 5 | Progress ring 56x56 conic 82% + inner 44 + 13px label | MATCH — see AC4 |
| 6 | Single continuous 2px rail, gradient to transparent | MATCH — one unbroken line across all rows, centre 23.5 px in both (spec 16+7+1 = 24) |
| 7 | Gutter `padding-left:26` | MATCH — entry-card left edge 41.3 px app / 41.5 px design (= 42 dp) |
| 8 | Dot 16 fill + 3px `--bg` ring | MATCH **after this story's fix** — was a 10 px fill, see AC5 |
| 9 | Entry card padding `15px 16px` | MATCH horizontally; vertical inflated by font metrics, see R-1 |
| 10 | Entry card `box-shadow:var(--shadow)` | MATCH — gap luminance drops to 23-25 below every card in both |
| 11 | Header row `align-items:center`, gap 9 | MATCH — icon, title and date share one centred row in both |
| 12 | Per-entry icon colour (pink/mint/peach/butter/purple) | MATCH — identical five-row accent sequence |
| 13 | Icon glyphs incl. `savings` and `draw` | MATCH — same glyph per row, no fallback boxes |
| 14 | Date format `dd/MM/yy` | MATCH — 18/01/26, 02/01/26, 11/11/25, 26/11/25, 25/11/25 identical |
| 15 | Body `margin-top:7` | MATCH as spec; measured gap +3 px from font metrics (R-1) |
| 16 | Photo `margin-top:11` | MATCH as spec; measured offset +2.5 px from R-1 |
| 17 | Photo placeholder full `<image-slot>` empty state | MATCH — frame 111 px app / 110 px design (spec 112), dashed ring, glyph, "Ảnh kỷ niệm"; ring rhythm corrected by the AC4 fix |
| 18 | Auto-added pill box, 12px icon, 5px gap, 10px text | MATCH — pill height 15 px in both |
| 19 | Add-memory pill `1.5px dashed var(--line)` | MATCH **after this story's fix** — see AC4 |
| 20 | Add-memory label 15px/800, gap 8, 20px pink icon | MATCH |

18 of 20 matched as delivered by STORY-025. Two (#8, #19) did not survive
contact with a real render and were fixed here.

## AC4 — Explicit re-verification of the two flagged risks

### Conic ring seam (`timeline_countdown_card.dart`, `TimelineProgressRing`)

PASS, no fix needed. See `ac4-progress-ring-comparison.png`. In both renders
the pink arc starts at exactly 12 o'clock and sweeps clockwise, the `--surf2`
remainder occupies the upper-left, the arc thickness and the 44 px inner disc
are identical, and the "82%" label is centred. `GradientRotation(-math.pi / 2)`
reproduces `conic-gradient(var(--pink) 82%, var(--surf2) 0)` with no visible
seam or start-angle artifact. M-2's residual risk is discharged.

### Dashed border (`timeline_dashed_border.dart`, `_DashedBorderPainter`)

FAIL as delivered, fixed here. See `ac4-dashed-border-comparison.png`.

**Dash rhythm.** Measured on the "Thêm kỷ niệm" button's top border, luminance
profile across the stroke row:

- design: repeating 5.0 px period, ink ≈2.85 px per period (≈2.9 CSS dash /
  ≈2.2 CSS gap)
- app before fix: 10.0 px period, dash 5.7 px, gap 4.3 px — exactly the
  `_dashPattern = [6, 4]` constant, i.e. **double** the design's rhythm and
  visibly sparser
- app after fix: 5.0 px period, ink ≈2.96 px per period

`_dashPattern` is now `[3, 2]`. This also tightens the photo placeholder's
dashed ring, whose design counterpart measures the same 5 px period.

**Stroke straddle.** `RRect.fromRectAndRadius(Offset.zero & size, …)` puts the
path on the box boundary, and Flutter centres a stroke on its path, so 0.75 dp
of a 1.5 dp stroke was painted *outside* the box. A CSS border is always drawn
inside the border box. Measured on the raw 2x design render (device px, before
any downscale): the button's border-box left edge computes to 49.93 and the
border ink occupies exactly 50-51 — flush inside, never outside. The painter
now deflates the rect by `strokeWidth / 2` and reduces the corner radius by the
same amount, so the ink starts at the box edge and grows inward. Post-fix the
app's stroke ink starts at ≈15.85 dp against the design's 16.0 (was 15.25 dp).
M-3's residual risk is discharged.

## AC5 — Additional deviation surfaced by the render

**Connector dot fill diameter.** Design source (L710):
`width:16px;height:16px;border:3px solid var(--bg)`. STORY-025 read this as
border-box and shipped `Container(width: 16, height: 16)` with
`Border.all(width: 3)` — its report explicitly argued "Flutter's `Border.all`
inside a fixed-size `Container` is border-box natively, so this needed no
compensation". The render disproves that: `Cupid Screens.dc.html` has **no**
global `box-sizing` reset, so the design's dot is content-box — the ring grows
the box to 22 px and the coloured fill stays 16 px. Flutter's `Border.all`
paints inside the box, so the shipped widget rendered a **10 px** fill inside a
16 px box.

Measured design dot fill: 15.3 px wide, centre at 26.65. Shipped app dot fill:
10 px, centre 24. After sizing the box to `_dotSize + _dotBorder * 2 = 22`:
15.8 px wide, centre 26.6 — a 0.05 px match on both axes.

The `left:-26px` offset places the *box*, not the fill, so the fill centre
correctly lands 3 px right of the rail centre (23.5) in the design too; the
fixed app reproduces that offset rather than the on-rail centring STORY-025
assumed. Locked by a new widget test asserting the 22 dp box, the 16 dp fill,
the 3 dp `colorBackground` ring, and the 27 dp fill centre.

## AC7 — Navigation

Unchanged. `TimelineScreen` is still a plain `Scaffold` + `CupidHeader` with
`onBack: () => Navigator.of(context).maybePop()`; no route, shell entry, or
tab wiring was touched. The screen is reached exactly as before.

## Residuals (measured, not fixed)

- **R-1 — entry card renders 101.6 dp tall vs the design's 96.6 CSS (+5 dp).**
  Row gaps (23 px), card width, horizontal padding, and every inter-block
  spacing constant (7/10/11) match exactly; the delta is entirely line-height.
  Flutter's Nunito ascent/descent make the header row and the pill text taller
  than the browser's `normal` line-height, and the accepted 12 dp date override
  (design 9.5px) contributes. Distribution: +2.5 px before the first ink, +1 px
  across the inner blocks, +1.5 px below the pill. Correcting it means
  overriding `height` on shared typography tokens, which would move every
  screen — the same cross-story spacing class as **M-4**, explicitly out of
  scope for this story.
- **R-2 — header title copy.** Design canvas shows the untranslated "Love
  Timeline"; the app shows "Dòng thời gian yêu thương". l10n/ARB consolidation
  is **M-5**, out of scope.
- **R-3 — bottom bar.** The design canvas draws the product's 5-tab bar with
  "Pet" active; the capture shows `PreviewAppShellChrome`'s 3 tabs + FAB. That
  is preview-harness chrome, not timeline surface, and does not exist in the
  real app shell.
- **R-4 — milestone date.** Design hardcodes 20/09/2026; the fixture anchors on
  `now - 246 days`, so the absolute date tracks the capture day (09/10/2026).
  Every derived value the design asserts — 53 days remaining, milestone 300,
  82% — matches exactly.
- **R-5 — star field.** Both renders show small twinkling dots at different
  positions. These are `CupidStarField`'s three animated stars, mounted app-wide
  by `CupidAppBackground` via `MaterialApp.builder`; the design's own canvas has
  the same stars. Different visible subsets only because opacity twinkles at
  different phases. Not a timeline deviation, and shared-shell background is
  **D-1**/STORY-032 territory.
- **R-6 — status bar and gesture bar.** Device chrome.

## Tool limitation (recorded for the requirement)

`render-design-canvas.js` has no scroll flag, and its `--hide` selectors are
applied *before* the `[data-screen-btn]` click (tool L317-349), so they do not
survive the screen re-render. The design's below-the-fold surface — the last
entry row and the entire "Thêm kỷ niệm" dashed button — therefore cannot be
captured by the sanctioned tool, which is why STORY-025's flagged M-3 could not
have been checked from `design-reference-timeline-android.png` alone.

`design-reference-timeline-android-scrolled-diagnostic.png` was produced by a
throwaway Playwright script that replicates the tool's own flow — loopback HTTP
serve of `cupid-app-design-system/project`, `Cupid App.dc.html` entry, dark +
`vi` toggles, animation freeze, `[data-screen-btn="timeline"]` click, the
config's `hide_selectors`, screenshot of `[data-plat="md"]`, LANCZOS downscale
to 406x900 — plus one extra step: scrolling the overflowing screen-body element
to its end (207 px). It is diagnostic evidence for AC4, not a sanctioned
artifact. A `--scroll` flag on `render-design-canvas.js` would make this
reproducible for every long screen in the requirement; that is a devops/tooling
change, not mobile scope.

## Files changed

- `mobile/lib/main_preview.dart` — dev-only timeline fixture (AC1)
- `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart` —
  connector dot box sizing (AC5)
- `mobile/lib/features/timeline/presentation/widgets/timeline_dashed_border.dart` —
  dash pattern and stroke inset (AC4)
- `mobile/test/features/timeline/presentation/timeline_design_fidelity_test.dart` —
  regression test for the dot geometry

## Shared design-system impact

None. No file under `mobile/lib/design_system/` was created, modified, or
forked; no new token was required. `test/design_system/no_fork_guard_test.dart`
passes.

## Gates

- `flutter analyze lib test` — 80 pre-existing `info` diagnostics, none in any
  file touched by this story; the four changed files analyze clean
- `flutter test` — 1270 passed, 2 skipped, 0 failed
- `flutter build apk --debug` with the preview target — built
