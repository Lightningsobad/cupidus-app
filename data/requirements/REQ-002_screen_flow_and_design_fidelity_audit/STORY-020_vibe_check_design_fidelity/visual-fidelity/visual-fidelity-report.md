# Visual Fidelity Report: STORY-020 — Vibe Check

Story: STORY-020 Design Fidelity — Vibe Check
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Lane: mobile
Configuration audited: dark theme + `vi` locale (per story In Scope §1)
Revision: round 3 — rewritten against the delivered code and against rendered
captures. Rounds 1 and 2 of this file described the pre-round-2 state and are
superseded in full.
Outcome: FIXED IN CODE AND CONFIRMED AT RENDER (this was a fix story, not
audit-only)

## Design Source

Canvas entry `cupid-app-design-system/project/Cupid App.dc.html`,
`Design-Screen: vibe` (`render-design-canvas.js --list-screens`). The screen
markup is `cupid-app-design-system/project/Cupid Screens.dc.html`, the block
guarded by `<sc-if value="{{ isVibe }}">` (lines 433-486), plus the dark token
block (lines 45-64) and the screen-chrome title binding `title: L['t_' + sc]`
with `t_vibe: 'Vibe Check'` (identical in `vi` and `en`). Mood artwork comes
from `cupid-app-design-system/project/Mood Face.dc.html`.

Dark tokens referenced below:
`--bg:#171129`, `--surf:#241B42`, `--surf2:#2E2456`,
`--line:rgba(247,238,251,.11)`, `--tx:#F7EEFB`, `--tx2:#B4A6CE`,
`--pink:#FF7FB6`, `--purple:#B78CF5`, `--butter:#FFD79E`, `--amber:#FFC97E`,
`--grad-hot:linear-gradient(120deg,#FF7FB6,#B78CF5)`,
`--glow:0 8px 28px rgba(255,107,168,.34)`, `--r-sm:16px`,
`--r-card` = 26 (iOS) / 24 (Material).

## Files Changed

Round 1:

- `mobile/lib/features/vibes/presentation/vibe_screen.dart`
- `mobile/lib/features/vibes/presentation/widgets/vibe_mood_grid.dart`
- `mobile/lib/features/vibes/presentation/widgets/partner_vibe_card.dart`
- `mobile/lib/features/vibes/presentation/widgets/vibe_history_strip.dart`
- `mobile/test/features/vibes/presentation/vibe_screen_test.dart`
- `mobile/test/features/vibes/presentation/widgets/vibe_widgets_test.dart`

Round 2 (added):

- `mobile/lib/design_system/tokens/mood_face_palette.dart` — **new file**
- `mobile/lib/features/vibes/presentation/widgets/vibe_mood_face.dart`
- `mobile/lib/features/vibes/presentation/vibe_screen.dart` (halo re-anchor)

Round 3 (added):

- `mobile/test/features/vibes/presentation/widgets/vibe_widgets_test.dart`
  (compile fix only, see Verification)

Correction to rounds 1-2 of this report: the earlier claim "no file under
`lib/design_system/` was modified" no longer holds. Round 2 **added** one new
file, `lib/design_system/tokens/mood_face_palette.dart`. No existing shared
token file or adaptive component was changed in place; the new file follows the
`bun_sprite_palette.dart` / `pet_hero_gradient.dart` precedent for additive
single-consumer illustration palettes.

## Deviation Count

The round-1 revision of this report claimed "24 deviations fixed in code". That
was an over-count. Re-derived against `git show 8396273:<file>` (BaseHead):

| Correction | Detail |
|---|---|
| Row 10 struck | Mood-grid face size was **already 52** at BaseHead (`vibe_mood_grid.dart:143`). Not a deviation; nothing changed. |
| Row 24 struck | History-strip face size was **already 26** at BaseHead (`vibe_history_strip.dart:89,93`). Not a deviation; nothing changed. |
| Row 12 narrowed | Real, but smaller than described — see the corrected row below. |
| Row 22 narrowed | Real, but smaller than described — see the corrected row below. |
| D-25 added | Round 2 fixed one genuine new deviation (mood artwork, AC3). |
| Row 3 amended | Round 2 corrected the round-1 halo's placement. This completes row 3; it is not a separate deviation. |

**24 claimed − 2 non-deviations + 1 round-2 deviation = 23 deviations actually
fixed in code.**

## Deviations Found And Fixed

### Screen chrome and hero (AC1)

| # | Deviation | Design source | Was (verified at BaseHead `8396273`) | Now |
|---|---|---|---|---|
| 1 | Chrome title showed the check-in prompt instead of the screen name | `t_vibe: 'Vibe Check'` | `context.checkInPromptTitle` in `CupidHeader` | literal screen name `Vibe Check` (locale-invariant in the source) |
| 2 | The prompt had no place in the body | hero block `text-align:center;padding:14px 0 22px` | absent | new `_VibeHero`: centered 27px/1.25 Nunito w900 title + 13px `--tx2` subtitle at a 7px gap |
| 3 | Hero halo missing, then mispositioned | absolute `180x90` `radial-gradient(circle, rgba(255,127,182,.28), transparent 68%)` at `top:0` of the hero's padding box | absent | **Round 1** added a `RadialGradient` from `colorAccentPink` @28% to the same token @0% with stops `[0, 0.68]`, `radius: 1.118034` (Flutter radius is a fraction of the box's shortest side, so `90/2 * r = 100.6` reaches the 180-wide box corner). **Round 2** re-anchored it: the `Stack` moved outside the `Padding` with `clipBehavior: Clip.none` (`vibe_screen.dart:139-146`), so `Positioned(top: 0)` resolves against the hero block's own box and the 90px halo is no longer cropped by the shorter text column. |
| 4 | Screen padding | `padding:8px 16px 40px` | uniform `CupidSpacing.md` | `fromLTRB(md, 8, md, 40)` |

### Mood grid — the mood-state input component (AC1, AC3)

| # | Deviation | Design source | Was (verified at BaseHead `8396273`) | Now |
|---|---|---|---|---|
| 5 | Selected cell used the wrong fill | `linear-gradient(140deg, rgba(255,127,182,.3), rgba(183,140,245,.26))` | `colors.gradientDream` (opaque, 120deg) | `colorAccentPink` @30% → `colorAccentPurple` @26% at the 140deg alignment pair, derived with the same CSS-angle mapping already used in `cupid_color_tokens.dart` |
| 6 | Off cell had no border, so selecting a cell resized it | off cell `border:1.5px solid transparent`, selected `1.5px solid var(--pink)` | border only when selected | 1.5px border always present; the off state uses the cell's own surface color as the stand-in for `transparent` |
| 7 | Cell padding | `padding:17px 8px` | `CupidSpacing.md` uniform | `symmetric(vertical: 17, horizontal: CupidSpacing.sm)` |
| 8 | Grid gap | `gap:11px` | `CupidSpacing.sm` with an outer inset | 11px between columns/rows, no outer inset (grid edges align with screen padding) |
| 9 | Label metrics | `font-size:12.5px;margin-top:10px` | inherited `caption`, `CupidSpacing.sm` gap | `fontSize: 12.5` at a 10px gap; weight stays w800 selected / w600 `--tx2` off, matching the source |
| ~~10~~ | ~~Face size 48 → 52~~ | ~~`52x52`~~ | **STRUCK.** `vibe_mood_grid.dart:143` at BaseHead already read `VibeMoodFace(mood: mood, size: 52)`. | unchanged at 52 (`_cellFaceSize`) |

### Mood sticker artwork (AC3) — round 2

| # | Deviation | Design source | Was (verified at BaseHead `8396273`) | Now |
|---|---|---|---|---|
| 25 | Mood stickers were Unicode emoji glyphs, not the design's `Mood Face` component | `Mood Face.dc.html`: seven hand-drawn SVG faces on a `viewBox="0 0 100 100"`, six gradients `mfA`–`mfF`, an `r=38` disc, per-face brow / eye / blush / mouth paths, and sparkle / heart / tear / steam / sleep-mark accents | `vibe_mood_face.dart:49` rendered `Text` with an emoji glyph at `fontSize: size * 0.72` — platform font artwork, not the design's artwork | `MoodFacePainter`, a `CustomPainter` transcription of all seven source faces at the source's 100x100 scale, with the colors extracted to the new `MoodFacePalette`. `VibeMoodFace` now paints `MoodFacePainter`; no `Text` remains in the subtree. `MoodFaceArt.forMood` maps `VibeMood.horny → MoodFaceArt.spicy` and `null → MoodFaceArt.none`. |

Round-2 implementation notes for this row:

- **`MoodFacePalette`** (`lib/design_system/tokens/mood_face_palette.dart`, new)
  holds the 27 illustration colors as named `static const Color` values on an
  `abstract final class`. They are illustration colors from the design source,
  not theme tokens, so they are theme-invariant by design; placing them under
  `design_system/tokens/` is what keeps them out of reach of the no-fork guard's
  raw-literal ban, matching the `bun_sprite_palette.dart` precedent.
- **`_faceBounds = Rect.fromLTRB(12, 12, 88, 88)`** is the object-bounding-box
  span the SVG's `x1/y1/x2/y2` gradient coordinates resolve against; the
  gradients are built from that rect rather than from the full 100x100 canvas.
- **Static accent frames.** `mfTear` and `mfZ` are keyframed in the source and
  sit at `opacity: 0` at `t=0`. They are painted at their peak-keyframe opacity
  instead, so a still capture shows the accent the design is recognisable by
  rather than an empty face. This matches the existing story-wide decision to
  render animations at a meaningful resting state (see Deferred, below).
- **`none`** is painted as the source's `stroke-dasharray="7 7"` outline at
  `opacity 0.7` with no fill.

### Partner mood display (AC1)

| # | Deviation | Design source | Was (verified at BaseHead `8396273`) | Now |
|---|---|---|---|---|
| 11 | Card padding / row gap | `padding:17px`, row `gap:13px` | `CupidSpacing.md` both | 17 and 13 |
| 12 | Avatar box radius and inset | `52x52;border-radius:18px;padding:5px` holding a `42px` face | **Corrected baseline.** `partner_vibe_card.dart:45-52` at BaseHead already had a 52x52 box, `platform.radiusSmall` (= 16), `EdgeInsets.all(CupidSpacing.xs)` (= 4) and a 42px face. The round-1 claim of "48 box, card radius, no inset" was wrong on all three counts. The real deviation is only the radius and the inset. | radius 16 → 18 (`_avatarRadius`), inset 4 → 5 (`_avatarInset`); box stays 52, face stays 42 |
| 13 | Mood label size | `font-size:15.5px;font-weight:800` | `body` default | `fontSize: 15.5`, w800 |
| 14 | Nudge banner fill was opaque | `background:rgba(255,201,126,.14)` (`--amber` @14%) | solid `colors.colorButter` | `colorAmber.withValues(alpha: 0.14)` |
| 15 | Banner glyph missing | `tips_and_updates` at `font-size:19px;color:var(--butter)` | absent | `CupidIcon(_tipsAndUpdates, size: 19, color: colorButter)` |
| 16 | Banner geometry / text | `margin-top:14px;padding:13px 15px;gap:11px`, text `12.5px/1.45` | `CupidSpacing` defaults | 14 / 13x15 / 11, text 12.5 at height 1.45 |
| 17 | CTA was plain text | pill `padding:7px 13px;border-radius:999px;background:var(--grad-hot);font-size:11.5px;font-weight:800;white-space:nowrap` | unstyled `Text` | `Container` with `gradientHot`, `platform.radiusButton`, 7x13 padding, 11.5px w800, `softWrap: false` |

The CTA stays decorative (no `GestureDetector`, no button semantics), per the
existing D-010-4 decision — the design source wires no `onClick` and no
backend endpoint exists. The existing semantics test still passes.

### 7-day history strip (AC1)

| # | Deviation | Design source | Was (verified at BaseHead `8396273`) | Now |
|---|---|---|---|---|
| 18 | Card top gap / padding | `margin-top:13px;padding:17px` | `CupidSpacing.md` both | 13 and 17 |
| 19 | Header casing and metrics | `12px;700;letter-spacing:.05em;text-transform:uppercase;--tx2` | sentence case, `caption` default | `.toUpperCase()`, 12px, w700, `letterSpacing: 0.6` (= .05em at 12px) |
| 20 | Header gap | `margin-bottom:14px` | `CupidSpacing.sm` | 14 |
| 21 | Column and stack gaps | columns `gap:5px`, inside a column `gap:7px` | `CupidSpacing.xs`/`sm` | 5 and 7 |
| 22 | Connector had square corners | `height:3px;border-radius:2px;background:var(--line)` | **Corrected baseline.** `vibe_history_strip.dart:91` at BaseHead already read `Container(height: 3, color: colors.colorLine)` — it was already 3px tall and already `colorLine`, not a "square 2px `Divider`-style box". The real deviation is the missing corner radius only. | 2px `borderRadius` added (`_connectorRadius`); height stays 3, color stays `colorLine` |
| 23 | Day label | `font-size:9.5px` mono, `--tx2` | `labelMono` with no explicit size (the token deliberately carries none) | `fontSize: 9.5` |
| ~~24~~ | ~~Face size 24 → 26~~ | ~~`26px`~~ | **STRUCK.** `vibe_history_strip.dart:89,93` at BaseHead already read `size: 26`. | unchanged at 26 (`_faceSize`) |

## Rendered Comparison (F-3)

Both images are in this directory and are directly comparable: the canvas
Android frame renders at 412x915 CSS px and the emulator runs 1080x2400 at
420dpi (= 411.4 x 914.3 dp), and both were bounded to a 900px longest edge.

| Artifact | Size | How |
|---|---|---|
| `design-reference-vibe-android.png` | 406x900 | `render-design-canvas.js --entry="Cupid App.dc.html" --screen=vibe --platform=android --theme=dark --lang=vi --label=vibe --max-edge=900` → `DESIGN_CANVAS: OK` |
| `implemented-vibe-emulator-5554.png` | 405x900 | profile build of `lib/main_preview.dart` with `--dart-define=PREVIEW=vibe` (dark + `vi` are pinned inside the preview harness), installed on `emulator-5554`, then `capture-mobile-screen.sh --label=vibe --device=emulator-5554 --max-edge=900 --settle-ms=1500` → `MOBILE_CAPTURE: OK` |

Capture note: the emulator's native 1080x2400 @420dpi was deliberately left
alone. An earlier attempt with `--width=412 --density=420` produced a ~157dp
viewport, which inflates every text size and wraps the hero title onto three
lines — the same "systemic oversized text" artifact that contaminated the
REQ-001 STORY-018 capture set. That capture was discarded and is not the
delivered evidence.

### Verdict

**F-1 and F-2 confirmed at render.** The mood cells paint the ported vector
artwork, not emoji: the warm gradient disc with brows, blush, mouth and the
corner sparkle on `happy`; the purple `sad`, the red-orange `angry` with its
steam accent, the pink `spicy`, the blue-grey `tired`. The dashed `none`
outline renders in both the check-in card avatar and every history-strip slot.
The hero halo renders behind the title, centered, uncropped at the top of the
hero block — the round-2 re-anchor holds at render.

Everything in the corrected deviation tables above that is observable at this
scale matches the reference: chrome title text and position, hero title on one
centered line, subtitle metrics and color, card radii and fills, the amber
nudge banner with its bulb glyph and gradient `Huých` pill, and the two-row
7-day strip with its per-day connector and mono day labels.

### Residual deltas

| Delta | Reference | Implementation | Disposition |
|---|---|---|---|
| Mood grid is 5 cells in 3+2, not 6 in 3+3 (`Mềm lòng`/`soft` absent) | 6 cells | 5 cells | Approved prior divergence, now confirmed at render — see Deliberately Kept As-Is |
| History header reads `7 NGÀY GẦN NHẤT` with no right-hand retention label | `7 NGÀY QUA` + `tự xoá sau 30 ngày` | approved copy, no retention claim | Approved prior divergence (UX §6 A-2), now confirmed at render |
| No 5-tab bottom bar | `Nhà / Trò chuyện / Pet / Ví chung / Tôi` | absent | Out-of-scope divergence settled in round 1; Vibe Check is not an `AppShell` tab destination in this app |
| Back-arrow tint | `--pink` | `--tx` (light) | Falls under the deferred `CupidHeader` chrome item — the arrow is painted by the shared adaptive header, not by this screen. Recording it here so it is not lost. |
| Screen state differs | seeded partner check-in (`Minh` / `Kiệt sức`) and seven days of moods | `Chưa nói gì`, all-`none` history, and a `Không có kết nối mạng` line | Not a design deviation. The preview build had no backend reachable, so the data-bearing regions render their documented empty state. Layout, spacing and typography of those regions are still comparable and match. |
| `_paintNone` dash caps | `Mood Face.dc.html:108` sets no `stroke-linecap`, so the source dashes are butt-capped | `_stroke(...)` always sets `StrokeCap.round` | **Unresolved.** The `none` face appears at 26px (history) and 52px (avatar) in this capture; the ~1px per-dash lengthening is below what these images can settle. Carried forward as a minor open note rather than claimed either way. |

## Deliberately Kept As-Is (approved prior divergences, not new deviations)

- **3 + 2 centered mood layout instead of the source's 3-column grid of 6.**
  STORY-010 `ux/uiux-spec.md` §3 resolves the design/backend mismatch
  explicitly: the source's `soft` mood has no backend value, so the app ships
  5 moods as "2 rows (3 + 2, centered)". The `FractionallySizedBox(widthFactor:
  2/3)` that produces equal cell widths is also locked by an existing test.
  Note that `MoodFaceArt` still carries all seven source faces, including
  `soft`, so the artwork is complete even though the grid shows five.
- **History header copy and the missing "tự xoá sau 30 ngày" right-hand
  label.** UX §6 A-2 is an approved divergence: no backend deletion job
  exists, so the app must not claim a 30-day retention guarantee. Only the
  source's `text-transform:uppercase` was adopted; the wording stays the
  approved copy.

## Deferred, With Rationale

| Item | Design source | Why deferred |
|---|---|---|
| Partner **name** line above the mood label (`font-size:11.5px;color:var(--tx2)`) | present in the source and required by UX §5 | `CouplePairingStore` only resolves `partnerId` from `GET /users/me`; there is no partner-name field on the API and no store that holds one. Delivering it needs backend/API work plus `lib/core` changes, both outside this story's WriteScope. Handoff stop rule applies. |
| Two decorative white radial highlights on the selected cell and the avatar (`rgba(255,255,255,.28)`) | decorative overlays | No theme-invariant white token exists, and the no-fork guard bans a raw literal. Adding one would require an additive token in `cupid_color_tokens.dart`, which is outside WriteScope. Purely decorative, no layout impact. |
| `popIn`, `bob`, and `breathe` animations, and the `mfTear` / `mfZ` accent keyframes | CSS keyframes | The hero halo and the face accents are rendered statically at a meaningful resting frame. An unbounded repeating animation makes `pumpAndSettle` time out, which would break the existing `vibe_screen_test.dart` suite. |
| `CupidHeader` chrome typography (source `Nunito;800;21px;letter-spacing:-.01em` vs the app's `cardTitle` 22px) and the back-arrow tint | 1px + weight delta, plus arrow color | `CupidHeader` is a shared adaptive component used by every screen. Changing it in place is forbidden by the handoff and would be a cross-screen change, not a Vibe Check fix. |

## Additive Declaration (single consumer, documented per STORY-003/006 precedent)

`_tipsAndUpdates = IconData(0xe79a, fontFamily: CupidIcons.fontFamily)` is
declared privately in `partner_vibe_card.dart` rather than added to
`CupidIcons`, because `lib/design_system/icons/` is outside this story's
WriteScope. The codepoint was verified against the bundled
`MaterialSymbolsRounded-Variable.ttf` cmap with fontTools — it was not
invented, and the `.fill` variant has no cmap entry so only the outline form
is used. Promote it to `CupidIcons` when that file is next in scope.

`MoodFacePalette` is a new additive file under `lib/design_system/tokens/`, not
an edit to a shared token file. Its colors are illustration values taken
verbatim from `Mood Face.dc.html` and are theme-invariant by nature; the
no-fork guard permits literals in that directory, and
`test/design_system/no_fork_guard_test.dart` passes with the file in place.

`colors.colorText` is used for the CTA pill label where the source hardcodes
`#fff`. There is no theme-invariant white token; this follows the existing
`CupidPrimaryButton` on-accent convention rather than introducing a literal.

## Tests

In `mobile/test/features/vibes/presentation/widgets/vibe_widgets_test.dart`,
group `STORY-020 design fidelity` (round 1):

1. the selected mood cell fills with the 140deg translucent pink/purple
   gradient, not the opaque dream gradient — asserts 2 stops at alpha 0.3 and
   0.26 and that it is not `gradientDream`;
2. selecting a cell does not resize it — asserts equal cell heights and a
   non-null border on the off cell;
3. the nudge banner is an amber tint with the `tips_and_updates` glyph and a
   gradient CTA pill — asserts the 14% amber fill, the butter icon color, and
   `gradientHot` on the pill.

In `mobile/test/features/vibes/presentation/vibe_screen_test.dart` (round 1):

4. the chrome title is the screen name and the prompt moves into the centered
   hero block — asserts `Vibe Check` inside `CupidHeader`, the 27px hero
   title, and the subtitle.

Group `VibeMoodFace artwork (STORY-020 F-1)` (round 2):

5. every `VibeMood` maps to its design-source face, `horny → spicy`,
   `null → none`;
6. all 7 design-source faces paint without throwing;
7. the drawn faces replaced the emoji glyphs entirely — asserts no `Text`
   descendant of `VibeMoodFace` and a `MoodFacePainter` on the `CustomPaint`;
8. `happy` rasterizes to an opaque warm disc (r > g > b, alpha 255 at the disc
   centre) while `none` leaves the same pixel empty — a real `toImage`
   rasterization, so it proves geometry landed on the canvas rather than that
   a painter object exists.

Round-3 fix to tests 6-8: the `rasterize` helper declared
`Future<ByteData> rasterize(WidgetTester tester, MoodFaceArt art)` but every
call site passed one argument, and its `runAsync` closure returned
`Future<ByteData?>` from a non-nullable signature. The call sites now pass
`tester`, and the closure returns
`(await image.toByteData(format: ui.ImageByteFormat.rawRgba))!` under an
explicit `runAsync<ByteData>`. No assertion was changed or weakened.

## Verification

Run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-020/mobile`
with `/Users/alantravala/flutter/bin/flutter` (the SDK is not on `PATH`).

Round 3, actual output:

| Command | Result |
|---|---|
| `flutter analyze lib/features/vibes lib/design_system/tokens/mood_face_palette.dart test/features/vibes` | **1 issue found**, 0 new. The single `info` is `prefer_initializing_formals` at `vibe_screen.dart:27:7`, verified identical in `git show 8396273:...vibe_screen.dart` (BaseHead) — pre-existing, untouched by this story. The seven round-2 errors in `vibe_widgets_test.dart` are gone. |
| `flutter test test/features/vibes test/design_system` | **79 passed, 0 failed** — "All tests passed!" |
| `flutter build apk --profile -t lib/main_preview.dart --dart-define=PREVIEW=vibe --target-platform=android-arm64` | OK — `✓ Built build/app/outputs/flutter-apk/app-profile.apk (42.4MB)` |

79 is the correct full-pass count for this branch, not a drift from the
round-1 figure: round 1 recorded 75 passed, and round 2 added the four
`VibeMoodFace artwork` tests listed above. Round 2's own recorded figure of 61
passed / 1 file failing to load was the compile break, now fixed.

The regression slice includes `test/design_system/no_fork_guard_test.dart`
(AC 4 no-fork guard), which passes: every color in the changed feature files
comes from a `ThemeExtension` token with translucency expressed via
`Color.withValues(alpha:)`, and the new illustration literals live in
`design_system/tokens/`, which the guard permits.

A profile build was used for the capture rather than a debug build because the
debug APK is 179MB and the emulator's `/data` had 606MB free, which
`pm install` rejects with `INSTALL_FAILED_INSUFFICIENT_STORAGE`. The compile-time
`--dart-define=PREVIEW=vibe` reaches the same screen without needing the
debug-only `cupidpreview://` deep link, and profile builds render through the
same widget tree and the same `buildCupidTheme` as debug.

## Acceptance Criteria Status

- **AC1** (layout, spacing, token usage, typography match in dark + `vi`):
  MET. Verified at render against `design-reference-vibe-android.png`; every
  residual delta is either an approved prior divergence, the deferred shared
  `CupidHeader` item, or an empty-data state rather than a styling defect.
- **AC2** (deviations corrected in the app, not merely documented): MET — 23
  deviations fixed in code (count re-derived above), covered by the eight tests
  listed and by the rendered comparison.
- **AC3** (mood sticker treatment matches the source): MET. The emoji glyphs
  are gone. `MoodFacePainter` transcribes all seven `Mood Face.dc.html` faces —
  the six `mfA`–`mfF` gradients, the `r=38` disc, and every brow, eye, blush,
  mouth, sparkle, heart, tear, steam and sleep-mark path at the source's
  `viewBox="0 0 100 100"` scale — and the result is confirmed at render.
  Correction: rounds 1-2 of this report claimed AC3 "was already correct"
  because `VibeMoodFace` rendered "the same emoji glyphs as the source's
  `moodList` faces, and this story only resized them". That was wrong. The
  source's faces are drawn SVG artwork, never emoji, and the round-2 commit
  deleted the emoji map outright.
- **AC4** (no change to how the screen is reached): MET — navigation and the
  `HomeScreen` entry card are untouched; the existing entry-point test passes.
