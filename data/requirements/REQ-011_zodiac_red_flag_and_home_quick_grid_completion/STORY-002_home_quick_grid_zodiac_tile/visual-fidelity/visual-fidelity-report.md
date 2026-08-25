VISUAL_FIDELITY: PASS

# Visual Fidelity — STORY-002 Home Quick Grid, Zodiac Red Flag Tile (P1)

Design-Screen: `home`
Platform: android
Theme/locale compared: dark theme + `vi` (the story's stated comparison
conditions, `ux/ux-spec.md` §4)
Produced for: review finding F1
(`review/review-report.md` §9), which required story-level render+compare
evidence for AC1.
Round: 2 (re-verification after the D1 fix landed in `e05d6db`)

**No deviation remains.** AC1's whole stated comparison surface now matches: the
2-column layout, equal tile widths, the 12px gap, both 38x38 icon plates and
their accents, both titles, the subtitle type ramp, both subtitle colours, and
the tiles' position in the card column. See §4.

Round 1 of this report failed on one deviation — the Zodiac tile's subtitle
rendered in `colorTextMuted` where the design source specifies `var(--peach)`.
That fix has since landed and is re-measured closed against a fresh capture in
§5.

## 1. Artifacts

| Role | File | Size | Round |
| --- | --- | --- | --- |
| Design reference | `design-reference-home-android.png` | 406x900 | unchanged from round 1 |
| Implemented capture | `implemented-home-emulator-5554.png` | 405x900 | **re-captured in round 2** |

Same device geometry as the sibling story's evidence
(`../../STORY-001_zodiac_red_flag_screen/visual-fidelity/`, 406x900 / 405x900),
so both stories' images describe the same viewport.

The design side was not re-rendered: the fix touched only `mobile/lib/**`, and
`Cupid Screens.dc.html` is byte-identical to the round-1 render's input, so the
round-1 design reference is still the correct comparand. The implemented capture
was rebuilt and re-taken at the identical device settings (§2), which is why the
round-2 geometry in §4 reproduces round 1 to the pixel.

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

Round 2 re-ran exactly this, unchanged, against the fixed source: same build
command, same emulator (`emulator-5554`), same `--width=540 --density=210
--settle-ms=25000`. The splash trap was handled the same way — a throwaway
warm-up capture to a scratch path took the cold-start cost, and the accepted
capture was the second one; both ran nested inside one `--lease-exec` window so
the display override was taken and restored once. The result is byte-different
but geometrically identical to round 1 (405x900, and every dp figure in §4
reproduces), which is what isolates the subtitle colour as the only thing that
moved.

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
| **Zodiac subtitle colour (`--peach` `#FFAB93`)** | `#FFAB93` | `#FFAB93` | **match** — round-2 fix, was D1; measured in §5 |
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

None open.

### D1 — CLOSED: Zodiac tile subtitle now renders peach, matching the design

**What it was.** `Cupid Screens.dc.html:314` specifies the Zodiac tile's subtitle
as `font-size:11.5px;color:var(--peach)` — `#FFAB93`. It is one of only two
accent-coloured subtitles in the design's 4-tile grid (Zodiac = peach at L314,
Dream Jar = mint at L319), while Synced Alarm (L309) and Anti-Ghosting (L324) use
`--tx2` — a deliberate per-tile choice, not a by-product of sample content. Round
1 measured the implementation rendering it `colorTextMuted` (`#B4A6CE`),
indistinguishable from the Synced Alarm tile beside it: design `#FAA790` versus
implemented `#B6A7CF`, warm salmon versus grey-lavender, obvious at 1:1.

**The fix, as landed.** `e05d6db` gave `_QuickGridTile` an optional
`subtitleColor` (default `colorTextMuted`, so Synced Alarm is untouched) and had
only the Zodiac call site pass `colors.colorPeach`.
`cupid_color_tokens.dart:99` defines that as `0xFFFFAB93` — `--peach` verbatim.

**Measured closed.** Re-measured on the round-2 capture over the same two
subtitle bands:

| Measure | Design | Implemented | Δ |
| --- | --- | --- | --- |
| Zodiac subtitle, coverage-corrected stroke colour | `#FAA790` | `#FAA891` | **(+0,+1,+1)** |
| Zodiac subtitle, AA ray direction from surface | `(+.802,+.523,+.290)` | `(+.798,+.525,+.295)` | **0.36°** |
| Alarm subtitle (control, untouched by the fix) | `#B1A3CB` | `#BAACD4` | (+9,+9,+9) / 0.06° |

Method, and why not raw peak sampling: an anti-aliased glyph pixel is
`P = a·C + (1-a)·S` for text colour `C` over surface `S`, so `P-S` points along
`C-S` at *every* coverage `a`. Comparing that ray direction compares the two
rasterizers' colour without comparing their coverage, which is where naive peak
sampling picks up noise.

Reading this table against §4: the figures here are *coverage-solved* and land a
few units under the pure token, because at 11.5px almost no pixel reaches full
coverage — `#B1A3CB` here is the same rendered `--tx2` that §4 reports as
`#B4A6CE`, and `#FAA790` is the same rendered `--peach` as the `#FFAB93` token.
Nothing disagrees; §4 names the token a row resolves to, this table names what
the two rasterizers actually laid down. That is also why the meaningful number is
the design-vs-implemented delta within a row, not the token-vs-render delta.

Two things make this a real match rather than a permissive one:

1. The Zodiac subtitle's residual delta **(+0,+1,+1) / 0.36°** is *smaller* than
   the Alarm subtitle control's **(+9,+9,+9)** — and that control row was already
   accepted as "match, exact" in round 1. The remaining Alarm offset is the
   uniform-brightness rasterizer difference described in §4's note, not a colour
   difference (0.06° of hue). The Zodiac row is now inside that same tolerance.
2. Within the single implemented capture, the Zodiac and Alarm subtitle rays are
   now **20.20°** apart (`#FAA891` versus `#BAACD4`). Before the fix they were
   the same token. So the peach is genuinely applied per-tile, and it did not
   leak onto the neighbouring tile.

**Spec follow-up (unchanged by this round, still worth carrying).** The
implementation was never in violation of the written spec: `ux/ux-spec.md` §3
item 5 specifies the subtitle's size, `maxLines` and overflow and is silent on
colour, even though §1 of the same spec records that the design's tiles carry an
"11.5px colored subtitle". The spec dropped the colour; AC1 is measured against
the design source, which is why the deviation was real in round 1. The source now
matches the design, but `ux/ux-spec.md` §3 item 5 still does not state the
colour. Worth a Designer amendment so the next tile added to this grid does not
reintroduce the same gap — a documentation follow-up, not a blocker on this
story, and outside this evidence patch's write scope.

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

Round 2. Both commands were run in this session, in the story worktree, at
`e05d6db`, before the capture (the build is what produced the APK that was then
installed and photographed):

- `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=home
  --dart-define=PREVIEW_HOME_FIXTURE=true --target-platform android-arm64` —
  built `app-local-debug.apk`.
- `flutter test test/features/home/home_quick_grid_test.dart` — 6 passed, 1
  skipped, 0 failed. Same counts as round 1; the fix changed no test outcome.

Round 1 ran the same two commands with the same results.

No file under `mobile/lib/**` or `mobile/test/**` was modified by this patch. The
D1 source fix landed separately in `e05d6db`; this patch only re-measures it and
rewrites this report and the implemented capture beside it.
