VISUAL_FIDELITY: FAIL

# Visual Fidelity — STORY-002 Home Quick Grid, Zodiac Red Flag Tile (P1)

Design-Screen: `home`
Platform: android
Theme/locale compared: dark theme + `vi` (the story's stated comparison
conditions, `ux/ux-spec.md` §4)
Produced for: review finding F1
(`review/review-report.md` §9), which required story-level render+compare
evidence for AC1.

One deviation fails the comparison: **the Zodiac tile's subtitle renders in
`colorTextMuted` where the design source specifies `var(--peach)`** (§5, D1).
Everything else in AC1's stated comparison surface — the 2-column layout, equal
tile widths, the 12px gap, both 38x38 icon plates and their accents, both
titles, the subtitle type ramp, and the tiles' position in the card column —
matches, several of them to the exact token hex. See §4.

## 1. Artifacts

| Role | File | Size |
| --- | --- | --- |
| Design reference | `design-reference-home-android.png` | 406x900 |
| Implemented capture | `implemented-home-emulator-5554.png` | 405x900 |

Same device geometry as the sibling story's evidence
(`../../STORY-001_zodiac_red_flag_screen/visual-fidelity/`, 406x900 / 405x900),
so both stories' images describe the same viewport.

## 2. How the two sides were produced

Design side — the Home node. `Cupid App.dc.html` is the render entry;
`Cupid Screens.dc.html` is the screen library, which is where the grid block
itself lives (lines 305-326).

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --surface=mobile --entry="Cupid App.dc.html" \
  --location=<worktree>/cupid-app-design-system \
  --screen=home --platform=android --theme=dark --lang=vi \
  --out=<story>/visual-fidelity
```

Implemented side — the `home` preview canvas. State was FAKED, never navigated
to: the fixture flag serves authored Home data, so the capture depends on no
login, no pairing and no live backend.

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true \
  --target-platform android-arm64
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk
adb -s emulator-5554 shell am start -a android.intent.action.VIEW \
  -d "cupidpreview://screen/home" com.snapsofts.cupid
capture-mobile-screen.sh --out=<story>/visual-fidelity --label=home \
  --device=emulator-5554 --width=540 --density=210 --settle-ms=25000
```

`--width=540 --density=210` puts the device at 411dp logical width, i.e. the
design canvas' own 412dp Android viewport, so the two images describe the same
layout rather than the same pixel count at a different text scale. Install,
launch and capture ran inside one `--lease-exec` device lease; the display size
was restored on exit.

STORY-001's two recorded traps were both live here:

- The first attempt photographed the Flutter splash. `--settle-ms=20000` on a
  cold debug-JIT start was still not enough on this emulator; the accepted
  capture warms the app first and then settles 25s.
- `--density` is not optional. Omitting it renders at ~270dp and makes every
  measurement below meaningless.

## 3. Reading the two images at the same scale

The design render draws a device frame; the implemented capture does not. The
design's screen viewport is inset by the bezel to x=10..396 (387px wide for
412dp, 0.939 px/dp). The implemented capture is full-bleed: 405px for 411dp,
0.985 px/dp. Every dp figure in §4 is the measured pixel run divided by the
matching scale. Without that correction the raw pixel runs (design 174, impl
181) look like a 7px width deviation that does not exist.

## 4. Matched, element by element

Measured off the two PNGs, not read off the source.

| Element | Design | Implemented | Result |
| --- | --- | --- | --- |
| Grid is one 2-column row holding both tiles | 2 tiles at y-row | 2 tiles at y-row | match |
| Left tile = Synced Alarm, right tile = Zodiac Red Flag | left/right | left/right | match |
| Tile widths equal to each other | 174 / 174 px | 181 / 181 px | match |
| Tile width | 185.3 dp | 183.7 dp | match (scale rounding) |
| Inter-tile gap (`gap:12px`) | 12 px → 12.8 dp | 12 px → 12.2 dp | match |
| Tile height | 112 px → 119.3 dp | 118 px → 119.7 dp | match |
| Horizontal screen padding | 14 px → 14.9 dp | 16 px → 16.2 dp | match (scale rounding) |
| Tile surface (`--surf` / `colorSurface`) | `#241B42` | `#241B42` | match, exact |
| Alarm icon plate fill (`rgba(255,201,126,.2)`) | `#4E3C4D` | `#503E4E` | match |
| Zodiac icon plate fill (`rgba(255,171,147,.2)`) | `#4F3751` | `#503852` | match |
| Icon plate size / radius | 38x38, `13px` | 38x38, `radiusSmall` | match |
| Alarm glyph colour (`--amber` `#FFC97E`) | `#FFC97E` | `#FFC97E` | match, exact |
| Zodiac glyph colour (`--peach` `#FFAB93`) | `#FFAB93` | `#FFAB93` | match, exact |
| Zodiac glyph is `auto_awesome` (4-point sparkle cluster) | sparkle | sparkle | match |
| Title ramp: 14px / `w800` / `--tx` `#F7EEFB` | `#F7EEFB` | `#F7EEFB` | match, exact |
| Subtitle ramp: 11.5px, single line | 11.5px | 11.5px ellipsized | match |
| Alarm subtitle colour (`--tx2` `#B4A6CE`) | `#B4A6CE` | `#B4A6CE` | match, exact |
| **Zodiac subtitle colour (`--peach` `#FFAB93`)** | `#FFAB93` | `#B4A6CE` | **deviation D1** |
| Grid's position in the card column (below Vibe) | below Vibe | below Vibe | match |

Token corroboration for the exact-hex rows:
`mobile/lib/design_system/tokens/cupid_color_tokens.dart:87,88,98,99` carry
`#F7EEFB` / `#B4A6CE` / `#FFC97E` / `#FFAB93`, which are `--tx` / `--tx2` /
`--amber` / `--peach` from `Cupid Screens.dc.html:23,26` verbatim. The captures
agree with both, so this is a rendered match and not just a token match.

The title row peak-samples as `#FFFFFF` on the device against `#F7EEFB` in the
design render. That is Android's bold-glyph rasterization gamma overshoot on a
`w800` face, not a token difference — the token is `#F7EEFB` exactly, and the
same overshoot appears on untouched Home titles in the same capture.

## 5. Deviations

### D1 — FAIL: Zodiac tile subtitle renders muted where the design specifies peach

`Cupid Screens.dc.html:314` specifies the Zodiac tile's subtitle as
`font-size:11.5px;color:var(--peach)` — `#FFAB93`. The tile's subtitle is one of
only two accent-coloured subtitles in the design's 4-tile grid (Zodiac = peach
at L314, Dream Jar = mint at L319); Synced Alarm (L309) and Anti-Ghosting (L324)
use `--tx2`. So the accent is a deliberate per-tile choice in the design source,
not a by-product of the sample content.

The implementation renders it `colorTextMuted` (`#B4A6CE`), identical to the
Synced Alarm tile beside it. Measured stroke peaks: design `#FAA790`, implemented
`#B6A7CF`. Visible at 1:1 — warm salmon versus grey-lavender.

Cause: `_QuickGridTile` in
`mobile/lib/features/home/presentation/home_screen.dart` hard-codes
`color: colors.colorTextMuted` on the subtitle `Text` for every tile it renders.
It already takes a per-tile `accent`, so the tile has the colour available; it
just does not apply it to the subtitle.

This is not a spec violation by the implementation. `ux/ux-spec.md` §3 item 5
specifies the subtitle's size, `maxLines` and overflow and is silent on colour,
even though §1 of the same spec records that the design's tiles carry an
"11.5px colored subtitle". The implementation followed the spec exactly; the
spec dropped the colour. AC1 is measured against the design source, so the
deviation is still real and still fails the comparison.

Not fixed here: the fix is a source change in `mobile/lib/**`, which this
evidence-only patch is explicitly forbidden from making. Routing decision
(one-line per-tile `subtitleColor`, versus ruling the muted subtitle an accepted
deviation because the implemented copy is static teaser text rather than the
design's live "Xung đột 7/10 hôm nay" score) belongs to Designer/PO, not to this
report.

## 6. Accepted and spec-mandated differences (not deviations)

1. **4 tiles in the design, 2 in the grid.** The design's grid holds Synced
   Alarm, Zodiac Red Flag, Dream Jar and Anti-Ghosting
   (`Cupid Screens.dc.html:305-326`). This story grids only the first two; Dream
   Jar and Anti-Ghosting remain full-width entry cards below and above. Excluded
   by `story_master.md` Out of Scope and `ux/ux-spec.md` §6, and AC1's subject is
   the two named tiles. Recorded here as an accepted, scoped deviation — it is
   the most conspicuous difference between the two images and is deliberate.
   Already carried as a requirement-level observation in `review/review-report.md`
   §8.1.
2. **Synced Alarm glyph: `alarm` in the design, `notifications_active`
   shipped.** `ux/ux-spec.md` §3.1 mandates keeping
   `CupidIcons.notificationsActive` unchanged from the entry card being
   reshaped. Spec-mandated.
3. **Synced Alarm title: "Synced Alarm" in the design, "Nhắc nhở đồng bộ"
   shipped.** `ux/ux-spec.md` §3.1 names the ADR-002 wording and says explicitly
   "do not revert to the design mock's literal". Spec-mandated.
4. **Both subtitle strings differ from the design's sample content.** The design
   ships `{{ alarmLine }}` ("06:30 · còn 1 người") and "Xung đột 7/10 hôm nay".
   The Synced Alarm subtitle stays `reminderNotificationsRowSubtitle` unchanged
   (§3.1) and the Zodiac subtitle is deliberately static teaser copy, not live
   `ZodiacConflictIndex` data (§3.2 — personalization is STORY-001's surface and
   out of scope here). Spec-mandated. This is the same class of delta as
   STORY-001's §4.2 "content prose".
5. **Pet card position and state.** The design places the Bún pet card between
   Vibe Check and the grid; the capture shows it below the grid, in a "Không thể
   tải Bún" error state. Home's card order is pre-existing REQ-010 composition,
   the error state is the preview fixture serving no pet data, and `ux/ux-spec.md`
   §3 pins this story's insertion point relative to `VibeEntryCard` and
   `DreamJarEntryCard` — which the capture satisfies. Outside this story; no
   action.
6. **Design frame and status bar.** The design render draws a device bezel and a
   9:30 status bar; the device capture shows the emulator's own 7:12 bar. Render
   harness difference, handled by the §3 scale correction.

## 7. Verification run for this patch

Both commands were run in this session, in the story worktree, after the
captures:

- `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=home
  --dart-define=PREVIEW_HOME_FIXTURE=true --target-platform android-arm64` —
  built `app-local-debug.apk`.
- `flutter test test/features/home/home_quick_grid_test.dart` — 6 passed, 1
  skipped, 0 failed.

No file under `mobile/lib/**` or `mobile/test/**` was modified by this patch.
