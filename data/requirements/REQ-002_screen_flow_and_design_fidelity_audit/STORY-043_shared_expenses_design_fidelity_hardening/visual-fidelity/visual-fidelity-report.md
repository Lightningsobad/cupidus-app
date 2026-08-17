# Visual Fidelity Report: STORY-043 Shared Expenses Design Fidelity Hardening

VISUAL_FIDELITY: PASS

Scope: RWB-20260816-011 — close STORY-028's zero-rendered-evidence gap for the
Shared Expenses screen. This is verification/evidence work: STORY-028's
deviations were already landed and source-verified, and this story re-verifies
them against an actual render on both platform silhouettes.

Design-Screen: `expense` (resolved with
`render-design-canvas.js --list-screens` before capture, not guessed).

## Evidence

| File | What it is |
|---|---|
| `implemented-expense-emulator-5560.png` | Material silhouette, dark + `vi`, top of scroll (AC1) |
| `implemented-expense-fab-overlap-emulator-5560.png` | Material silhouette at maximum scroll (M-1) |
| `implemented-expense-filtered-emulator-5560.png` | Material silhouette with the `Khác` category chip selected (AC5/M-2, chip selected-state) |
| `implemented-expense-ios-emulator-5560.png` | iOS silhouette, top of scroll (AC3) |
| `implemented-expense-ios-cta-emulator-5560.png` | iOS silhouette scrolled to the full-width CTA (AC3) |
| `design-reference-expense-android.png` | `render-design-canvas.js --screen=expense`, Android variant (AC2) |
| `design-reference-expense-ios.png` | `render-design-canvas.js --screen=expense`, iOS variant (AC2) |

All paths are relative to
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-043_shared_expenses_design_fidelity_hardening/visual-fidelity/`.

**Provenance.** All five `implemented-*` captures come from the same post-fix
build — the source tree with N-1 and N-2 landed — and every one of them shows
the corrected strings (`dd/MM` zero-padded, `480.000₫` with no space before the
unit). The two iOS captures were re-taken in review round 2: the round-1 pair
predated the N-1/N-2 build and still showed `17/8` and `480.000 ₫`, which the
reviewer caught as B-1. Any future re-capture must replace the whole
`implemented-*` set from one build, not a subset, so a pre-/post-fix mix cannot
recur unnoticed. Cross-check for a reader: the Android trio and the iOS pair
must agree on the date and currency formatting of any row they share.

### Capture setup (AC1)

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=expense --dart-define=PREVIEW_EXPENSE_FIXTURE=true
adb -s emulator-5560 install -r -t build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --device=emulator-5560 --settle-ms=25000 --label=expense
```

The iOS silhouette adds `--dart-define=PREVIEW_PLATFORM=ios` (STORY-017's
`CupidPlatformOverride` precedent). Theme and locale are the app's shipped
dark + `vi` configuration (OQ5 RESOLVED), not overridden for capture.

`--dart-define=PREVIEW_EXPENSE_FIXTURE=true` is required: `ExpenseHistoryCubit`
is a read-through cache over `GET /expenses` plus Drift, so an unauthenticated
preview resolves neither and lands on the `isNeverSynced` empty state, where
none of the AC-bearing surfaces exists. The fixture replays the design source's
own `expense` state — its five drawn rows plus the filler its
"Xem tất cả 18 khoản" footer implies — weighted so `ExpenseMonthSummary` derives
the canvas' own `4.350.000₫` total, 18-item count and 7-bucket bar profile from
real domain code rather than hard-coded pixels. It writes to an in-memory
`CupidDatabase`, so the capture is not polluted by residue from a prior preview
session.

### Measurement basis

Device 1080x2400 @ density 420 (411.4 dp wide); the sanctioned capture tool
downscales to 405x900, i.e. 0.984 px per dp, so capture pixels read as dp within
1%. Geometry and colour below were sampled programmatically from the PNGs (raw
scanline decode), not estimated by eye. The design reference renders inside a
device frame, so absolute x/y differ between the two images; only intra-image
distances and colours are compared.

### Deviation count reconciliation

STORY-028's report states "25 deviations". Its own tables enumerate 32 rows:
A1 + B1-B3 + C1-C9 + D1-D4 + E1-E8 = 25, plus the AC1 expense-list table
F1-F7 = 7 more. The "25" figure excludes the F series. All 32 are re-verified
below, so AC3's 25 are a strict subset of what this report covers.

## AC3 — all enumerated deviations under a real render

Verdict column is what the render shows, not what the source says.

### A — add action placement

| # | Design source | Rendered verdict |
|---|---|---|
| A1 | add action is not a header action: Material draws a sticky FAB (L881), iOS a full-width CTA in the content flow (L884) | MATCH. Material capture has an empty header actions area and a bottom-right FAB; iOS capture has no FAB at all and ends with the full-width CTA (`implemented-expense-ios-cta-emulator-5560.png`) |

### B — screen container

| # | Design source | Rendered verdict |
|---|---|---|
| B1 | whole block scrolls together | MATCH. Summary card, chart, chips and list card all translate together under scroll; only the FAB stays fixed (compare top vs max-scroll captures) |
| B2 | `padding:8px 16px 40px` | MATCH. Card left edge measured at x=16 in the capture; bottom padding confirmed at max scroll (list card ends clear of the viewport bottom) |
| B3 | uniform `13px` section gap | MATCH, measured on both sides: implemented summary-card bottom y=336 → chip row top y=349 (13); design reference y=316 → y=329 (13) |

### C — summary card

| # | Design source | Rendered verdict |
|---|---|---|
| C1 | card uses `--surf` + `--shadow` | MATCH. Card surface samples `rgb(36,27,67)` implemented vs `rgb(36,27,66)` design — same token |
| C2 | card `padding:20px` | MATCH. Card left edge x=16, chart plot starts x=36 → 20 |
| C3 | two-column header row, `align-items:flex-end`, `space-between` | MATCH. Period caption + total on the left, delta caption + value right-aligned, bottom-aligned in both |
| C4 | total Nunito `w900 31px`, `line-height 1.15` | MATCH. Digit glyph shape, weight and cap height are visually indistinguishable side by side at 3x zoom |
| C5 | `₫` as a `16px`, `--tx2` span inside the total | MATCH. Both render the unit attached to the last digit at roughly half the digit height in the muted tone |
| C6 | period caption `12px`, `--tx2` | MATCH (copy differs — see Residuals) |
| C7 | delta caption `11px` / value `14px w800` | MATCH |
| C8 | increase uses `--peach` | MATCH. Implemented `+450.000₫` and design `+12%` render the same peach |
| C9 | chart top gap `18px` | MATCH |

### D — weekday chart

| # | Design source | Rendered verdict |
|---|---|---|
| D1 | equal-width bars, `gap:4px`, plot `height:76px`, bottom-aligned | MATCH, measured. Implemented bars span x=36-79, 84-128, 133-176, 181-224, 229-272, 277-321, 326-369 — seven equal bars separated by exactly 4px, all seated on a common baseline y=295. Design reference: same 7-bar, 4px-gap structure |
| D2 | `border-radius:6px 6px 0 0` | MATCH. Bar tops are rounded, bar bottoms square against the baseline, in both |
| D3 | non-peak `rgba(255,127,182,.35)`, peak `--grad-hot` | MATCH, numerically. Non-peak bar samples `rgb(114,63,108)` implemented vs `rgb(112,61,107)` design; both equal `colorAccentPink` at 0.35 composited on `rgb(36,27,66)`. The peak bar carries the pink→purple gradient in both |
| D4 | separate label row `8px` below, `Roboto Mono 9.5px`, `--tx2` | MATCH. Labels sit outside the plot on their own row, mono, muted, at the same size (label text differs — see Residuals) |

### E — category chips

| # | Design source | Rendered verdict |
|---|---|---|
| E1 | `border-radius:999px` | MATCH. Corner radius equals half the pill height: sampling 4px in from a chip's left edge gives a 26px vertical extent against a 48px full height, exactly the chord of a half-height-radius arc |
| E2 | selected `--grad-hot` | MATCH, and state-driven: the filtered capture shows the gradient move from `Tất cả` to `Khác` on tap |
| E3 | unselected `--surf` | MATCH |
| E4 | chip padding `9px 15px` | Vertical padding is overridden by the tap-target minimum — see Residuals. Horizontal padding MATCH |
| E5 | chip gap `9px` | MATCH |
| E6 | `12.5px`, selected `w800` / unselected `w700` | MATCH |
| E7 | selected `#fff`, unselected `--tx2` | MATCH, confirmed across the selection change in the filtered capture |
| E8 | leading category icon `16px` + `6px` gap; "All" is label-only | MATCH. `Tất cả` carries no glyph in either render; every other chip has a leading glyph at the same size and gap (glyph artwork differs — see Residuals) |

### F — expense list

| # | Design source | Rendered verdict |
|---|---|---|
| F1 | list card `--surf` + `--shadow`, `padding:4px 17px` | MATCH, measured. Implemented card left edge x=16 with the row icon tile starting at x=33 (17px inset); first divider at y=535 against a card top of y=465, i.e. 4 + 66 — the same 4px vertical inset the design shows (card top y=376, first divider y=446) |
| F2 | `border-bottom` on rows | MATCH as implemented, deliberately divergent on the last row — see AC6/M-3. The filtered capture shows the last row of a 4-row card with no trailing hairline |
| F3 | row `padding:14px 0` | MATCH, measured. Row pitch 67px implemented vs 68px design (40px tile + 14px above and below) |
| F4 | tile `40x40`, `radius 14`, accent at 18%, glyph `21px`, one accent per category | MATCH, numerically. Tile width measured 40 in both; food tile fill samples `rgb(76,59,77)` implemented vs `rgb(75,58,77)` design — both `colorAmber` at 0.18 on the card surface — and the glyph samples `rgb(255,205,127)` vs `rgb(255,201,126)`. The filtered capture confirms the per-category mapping holds when the list is re-filtered |
| F5 | row `gap:13px` | MATCH |
| F6 | two lines: title `14px w700` ellipsis, subtitle `11px --tx2` at `margin-top:2px` | MATCH on structure and type. Both lines render at the specified sizes, weights and colours with a 2px gap, on every row of both platform captures, and the subtitle now reads `Bạn · 17/08` (N-1). The single-line **ellipsis clamp is source-verified only**: `maxLines: 1` + `TextOverflow.ellipsis` are present, but no fixture title is long enough to trigger them — the longest, "Quà cho Bún (đồ ăn mèo thật)", renders in full on both silhouettes. `design-reference-expense-ios.png` does ellipsise that same title ("…đồ ăn mèo th…") because the design canvas lays it out in a narrower column, so the reference is not evidence about the app's clamp either way |
| F7 | amount `Roboto Mono 13px w500` | MATCH on both platforms, re-verified against the round-2 iOS captures: mono digits, right-aligned, and the unit attached (`480.000₫`, `1.500.000₫`) per N-2 |

## AC2 — design references, both platform variants

Both variants were rendered from the locked `cupid-app-design-system` source
(`--location=cupid-app-design-system --entry="Cupid App.dc.html"`, taken from
`data/devops/system/design-fidelity-config.json`) at
`design-reference-expense-android.png` (406x900) and
`design-reference-expense-ios.png` (416x900).

The two variants also settle a question a single-width render would have left
open: the Android reference fits four chips on one line while the iOS reference
wraps the fourth onto a second line. That is the design source's own
`flex-wrap:wrap` container (L862) reflowing at a different effective width, not
a horizontal scroller — so the app's `Wrap` is the correct structure, and its
two-line layout for six categories is the same behaviour, not a deviation.

## AC3 — platform split under a real dual-platform render

| Platform | Design source | Rendered verdict |
|---|---|---|
| Material | sticky FAB, bottom-right (L881) | MATCH on placement. `implemented-expense-emulator-5560.png` shows a bottom-right floating add action pinned across scroll; header carries no add affordance |
| iOS | no FAB; full-width CTA in the content flow with `margin-top:14px` (L884) | MATCH, re-verified on the round-2 post-fix captures. `implemented-expense-ios-emulator-5560.png` has no FAB anywhere; `implemented-expense-ios-cta-emulator-5560.png` shows the full-width gradient CTA "Ghi một khoản" below the list at the same 14px offset. Both now render the N-1/N-2 strings, so the iOS half of the dual-platform evidence depicts the delivered build |

Shared-component visual detail inside those two affordances is D-1/D-2 and stays
out of scope — see AC4.

## New findings from the render (fixed)

Both are genuinely new: neither appears in STORY-028's 32 enumerated rows, and
neither is detectable by source-to-source comparison because both are string
formatting that only shows up against the design source's own rendered strings.
Both are inside this story's two in-scope files.

| # | Finding | Design source | Was | Now |
|---|---|---|---|---|
| N-1 | Row date was not zero-padded | `{{ x.date }}` renders `27/07` (L873) | `17/8`, `8/8` — width shifts row to row | `dd/MM` via `padLeft`, giving `17/08`; the subtitle column now holds a constant width |
| N-2 | Row amount had a space before the unit | `{{ x.amt }}` renders `480.000₫` (L874) | `480.000 ₫` | `480.000₫`. This also aligns the row with the summary card's own total, which already rendered the unit attached, and with Dream Jar's shipped VND strings. The row's `Semantics` label keeps its space so a screen reader announces the unit as a separate word |

Both fixes are visible in all five `implemented-*` captures — on both platform
silhouettes — and match the design reference exactly.

## New findings from the render (not fixed)

| # | Finding | Disposition |
|---|---|---|
| N-3 | The preview harness, not the product: `PreviewAppShellChrome` supplies its own account-hub FAB, and with `wrapInShell: true` it painted over this screen's `CupidAddAction`, so the first capture attempt showed a person glyph where the add action belongs | Fixed in the dev-only preview registry, not in product code. `home_screen.dart` pushes `ExpensesEntryPoint` onto the root navigator and `app_shell.dart` builds tab bodies with no nested `Navigator`, so runtime renders this screen above the shell with neither tab bar nor account-hub FAB. The registry entry now matches runtime, the same call already recorded for `ghostset` |

## AC4 — D-1, D-2, M-1

**D-1 (`CupidAddAction`) — stays out of scope, gap re-measured and wider than
recorded.** Design: `60x60`, `border-radius:20px`, `--grad-hot`,
`box-shadow:0 8px 24px rgba(255,127,182,.45)`, `27px` glyph (L881). Rendered:
a flat `colorAccentPink` **circle** at the Material FAB default size, no
gradient, no glow, smaller glyph. STORY-028 described the gap as size/fill/glow;
the render adds shape — `CupidAddAction` passes
`BorderRadius.circular(platformTokens.radiusButton)`, and with `radiusButton`
being the pill token that resolves to a circle on a square FAB, not to the
design's 20px rounded square. The widget is shared with Dream Jar, Gallery and
Home under `mobile/lib/design_system/adaptive/**`, so the shared-component
exclusion (same class as RWB-012/RWB-018) is re-confirmed and the sharpened
description should travel to the split-out design-system rework item.

**D-2 (`CupidPrimaryButton`) — stays out of scope, gap is now much narrower
than STORY-028 recorded.** STORY-028 described the shipped button as flat pink
with no glow, no icon and `type.body`. The render disagrees: the iOS CTA
already draws `gradientHot`, `glowShadow`, a pill radius and a `w800` label.
The remaining gap against this screen's canvas block is `height 54` vs `52`,
`fontSize 16.5` vs `15.5`, and the missing leading `add` glyph with its 8px gap.
Same shared-component deferral; the stale description should be corrected on the
rework item so the design-system story is not scoped against an obsolete
baseline.

**M-1 (FAB overlap) — travels with D-1 per AC4, but is no longer a prediction.**
STORY-028's reviewer judged the overlap "marginal" at the current 56x56 FAB and
expected it to become visible only once D-1 raises the FAB to 60x60.
`implemented-expense-fab-overlap-emulator-5560.png` shows it is already visible
today: at maximum scroll the last row ("Nồi chiên không đầu") has its amount
clipped to `1.200` by the FAB. The round-2 iOS capture isolates it: the same
row, at the same scroll extent, renders its full `1.200.000₫` there, because iOS
has no FAB to overlay it — M-1 is Material-only, not a shared layout fault.
The cause is unchanged — the design keeps its FAB
inside the content flow (`position:sticky` plus `margin-top:16px` before the
container's `padding-bottom:40px`, so no row can sit behind it) while the
implementation uses `Scaffold.floatingActionButton`, a pure overlay, with the
scroll view's bottom padding still at the mock's 40. Per AC4 this is not
remediated here; it routes with D-1, upgraded from reasoned to observed.

## AC5 — M-2 and M-4

**M-2 (empty filtered result renders a bare card strip) — non-blocking, stays
deferred.** Not reachable from this capture: the design canvas' own dataset
spans all five categories, so every chip matches at least one loaded row.
`implemented-expense-filtered-emulator-5560.png` exercises the same code path
with the `Khác` chip selected and shows the list card contracting cleanly around
four rows, with the trailing hairline correctly suppressed. The card's vertical
inset was measured at 4px above the first row, so with zero matching rows the
unconditional `DecoratedSliver` degenerates to an ~8px `colorSurface` strip
exactly as STORY-028's reviewer described. Disposition unchanged and explicitly
re-confirmed: cosmetic only, and the design source has no filtered-empty state
to deviate from, so it is not a fidelity defect for this screen.

**M-4 (1px gap) — confirmed below the visible-deviation threshold.** The total
block sits `CupidSpacing.xs` (4) below the period caption where the mock
specifies `margin-top:5px`. At the capture's 0.984 px/dp the difference is under
one pixel and is not resolvable in either render. No change.

## AC6 — M-3

Re-confirmed as docs-only; no code change is required, and none was made.

The inaccuracy still exists. `STORY-028_shared_expenses_design_fidelity/visual-fidelity/visual-fidelity-report.md`
line 109 justifies suppressing the last row's hairline with "as in the mock".
The mock does the opposite: `Cupid Screens.dc.html` L871 puts
`border-bottom:1px solid var(--line)` on *every* `sc-for` row, because the
"Xem tất cả 18 khoản" footer (L877) follows the last one. Suppressing the
trailing hairline remains the correct implementation precisely because that
footer is correctly excluded as out of scope — a hairline with nothing beneath
it would itself be a deviation. Only the stated reason is wrong.

Correct wording for that line: *"the last row in the card omits it, because the
mock's trailing hairline exists only to separate the last row from the
out-of-scope 'Xem tất cả 18 khoản' footer."*

STORY-028 is a closed story with an approved review; its evidence artifact was
deliberately left untouched rather than edited in place. The correction is
recorded here for Scrum Master or Reviewer to apply where they judge it belongs.

## AC7 — Navigation

Unchanged by this story. Shared Expenses is still reached through the existing
`_ExpensesEntryCard` affordance on Home, which pushes `ExpensesEntryPoint`; that
route resolves the pairing gate before showing `ExpenseHistoryScreen`. No entry
point, route or navigation widget was added, removed or renamed. The only
navigation-adjacent edit is the dev-only preview registry (N-3), which is not
reachable from a production build.

## Residuals (measured, not fixed)

None of these is a regression; each is a deliberate prior decision or an
inherent mock-versus-live difference, and each is now backed by a render.

1. **Chip height 48 vs 33.** Measured: implemented pill spans y=349-396 (48),
   design 329-362 (33). The tap-target minimum wins over the mock's box, which
   the same design source mandates in its own platform-adaptation table. This is
   STORY-028's upheld judgement call, now quantified.
2. **Chart normalization.** Measured: the design's peak bar is 60px in a ~75px
   plot (its authored 80%), the implemented peak is 74px in the same plot (100%).
   The app derives bar heights from data and normalizes the maximum to full
   height; the mock's percentages are authored artwork. Bars therefore read
   uniformly ~1.25x taller, while the *relative* profile matches.
3. **Weekday labels.** Design shows placeholder `T1..T7`; the app renders the
   correct Vietnamese `T2..CN`. The app is right.
4. **Period caption copy.** "Tổng tháng này" vs the mock's "Tháng 7/2026".
5. **Delta unit.** Absolute VND (`+450.000₫`) vs the mock's `+12%`.
6. **Item-count caption.** The app adds "18 khoản chi" under the total; the mock
   has none. A knock-on: because the header row is bottom-aligned, the taller
   left column pushes the delta value slightly lower than in the mock.
7. **"Xem tất cả 18 khoản" footer** is in the mock and correctly absent from the
   app (the app pages instead).
8. **Row attribution copy.** "Bạn" / "Người ấy" per ADR-015.2 vs the mock's
   "Minh" / "Linh".
9. **Row glyph artwork.** The mock draws bespoke per-row glyphs (ramen bowl,
   coffee cup, film strip, taxi, gift); the app draws one Material Symbols glyph
   per category per ADR-004d. Tile geometry, tint and accent all match; only the
   artwork differs.

Items 4-8 are STORY-028's explicit "deliberately not changed" set, re-confirmed
against the render rather than re-litigated.

## Tool limitation

`render-design-canvas.js` exposes no scroll flag and applies its `--hide`
selectors before the `[data-screen-btn]` click, so design surface below the fold
cannot be captured with the sanctioned tool. That is why the design source's
"Xem tất cả 18 khoản" footer and the iOS full-width CTA do not appear in
`design-reference-expense-ios.png`; both were verified against the design source
markup (`Cupid Screens.dc.html` L877 and L884) instead. Same limitation
STORY-042 recorded. The implemented side has no such limit — the app was
scrolled and captured directly, which is how M-1 and the iOS CTA got real
evidence.

## Files changed

- `mobile/lib/features/expenses/presentation/widgets/expense_list_item.dart` —
  N-1 (`_dateLabel` zero-padded to `dd/MM`) and N-2 (amount unit attached).
- `mobile/lib/main_preview.dart` — dev-only: `PREVIEW_EXPENSE_FIXTURE` seeded
  state for the `expense` entry, and the registry entry corrected to
  `wrapInShell` off (N-3). Not reachable from a production build.

No production screen, route or navigation code was modified.

## Shared design-system impact

None. `mobile/lib/design_system/**` was not touched, and no shared adaptive
widget was forked into a local copy. D-1 and D-2 remain the only fidelity items
that require a change there, and both stay routed to a design-system-scoped
story.

## Gates

| Gate | Command | Result |
|---|---|---|
| Analyze | `flutter analyze lib test` | 80 issues — 0 error, 0 warning, 80 info. All pre-existing; none in `expense*` or `main_preview.dart`. Same count as STORY-042's recorded baseline |
| Test | `flutter test` | 1270 passed, 2 skipped, 0 failed |
| Build (Material) | `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=expense --dart-define=PREVIEW_EXPENSE_FIXTURE=true` | Built `build/app/outputs/flutter-apk/app-debug.apk` |
| Build (iOS silhouette) | same, plus `--dart-define=PREVIEW_PLATFORM=ios` | Built; this is the binary behind the round-2 iOS captures |
| Runtime | install + launch on `emulator-5560`, both platform silhouettes | Screen renders; scroll, category filtering and the platform add-action split all exercised on device |
