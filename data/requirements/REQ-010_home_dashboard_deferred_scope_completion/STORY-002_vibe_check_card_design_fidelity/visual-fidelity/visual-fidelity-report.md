VISUAL_FIDELITY: PASS

# Visual Fidelity Report: REQ-010 / STORY-002 Vibe-Check Card Design Fidelity

Date: 2026-08-25
Role: mobile-dev
Screen: home
Design-Screen: home
Surface: mobile
Platform: android
Theme: dark
Locale: vi
Device: emulator-5554 (Android emulator, leased via
`capture-mobile-screen.sh --lease-exec`)

## Design Source Resolution

- Design source: `cupid-app-design-system` (locked; recorded in
  `data/devops/system/design-fidelity-config.json`, project configures two
  design sources so `--surface=mobile` was required to disambiguate).
- Canvas file: `Cupid Screens.dc.html`.
- Screen id `home` resolves to the `isHome` block; the vibe-check element is
  the `goVibe` card at lines 274-289. Confirmed by
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-002_vibe_check_card_design_fidelity/ux/uiux-spec.md`
  §1, which cites the same block and line range as the authoritative source
  for this card.

## Artifacts

- Design reference:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-002_vibe_check_card_design_fidelity/visual-fidelity/design-reference-home-android.png`
  (406x900), rendered with
  `node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=mobile --screen=home --platform=android --theme=dark --lang=vi`.
- Implemented capture:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-002_vibe_check_card_design_fidelity/visual-fidelity/implemented-home-emulator-5554.png`
  (405x900), captured from
  `flutter run -t lib/main_preview.dart --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true`
  through `capture-mobile-screen.sh --lease-exec --label=home --max-edge=900`.

Capture note: the first capture attempt photographed the Flutter splash frame
because the settle window fired before the first real frame. The run was
repeated with a 25s post-launch settle; the accepted capture (165199 bytes)
shows the rendered Home dashboard.

## Per-Delta Comparison

Each row is a deviation named in `ux/uiux-spec.md` §1, re-checked against the
side-by-side capture.

| # | Design source (lines 274-289) | Before this story | After this story | Verdict |
|---|---|---|---|---|
| D1 | Two sub-tiles ("you" / partner) below the header | Single mood row, no tiles | `Row` of two `Expanded` `_VibeMiniTile`s | MATCH |
| D2 | Header row: `mood` glyph + title on the left, `Lịch sử` link on the right | No header row | `Row(spaceBetween)` with `CupidIcons.mood` (19dp, `colorAccentPink`) + title, and the history label | MATCH |
| D3 | No chevron affordance on the card | Trailing `chevronRight` | Chevron removed; card body is the affordance | MATCH |
| D4 | Card padding 17 | 16 | `EdgeInsets.all(17)` | MATCH |
| D5 | Mood face 36 | 40 | `VibeMoodFace(size: 36)` in both tiles | MATCH |
| D6 | Sub-tiles filled with the alternate surface | No tile fill | `colorSurfaceAlt` + `radiusSmall` on both tiles | MATCH |

## Token And Typography Check (ux/uiux-spec.md §3, §6)

| Element | Spec | Implemented | Verdict |
|---|---|---|---|
| Card surface | `colorSurface`, `radiusCard`, `elevationShadow` | same | MATCH |
| Header glyph | `mood`, `colorAccentPink` | `CupidIcons.mood` = 0xe7f2, verified in the bundled `MaterialSymbolsRounded-Variable.ttf` cmap via fontTools (0xe7f3 is `mood_bad`, not substituted) | MATCH |
| Header title | 12.5 / w700 / letterSpacing 12.5*0.03 / `colorText` | same | MATCH |
| History link | 11.5 / w700 / `colorAccentPink` | same | MATCH |
| Tile label | 11 / `colorTextMuted` | same | MATCH |
| Tile mood | 13.5 / w800 / `colorText` / ellipsis | same | MATCH |
| Header-to-tiles gap | 14 | `SizedBox(height: 14)` | MATCH |
| Tile gap / inner gap / tile padding | 10 / 11 / 12 | same | MATCH |

## Accepted Differences (UX-spec-directed, not story deltas)

These remain visibly different from the raw canvas and are correct per the
approved UX spec. They are decisions, not unfixed deviations.

1. Title renders the `vi` copy `Cảm xúc hằng ngày` where the canvas hardcodes
   `Vibe Check`. `ux/uiux-spec.md` §3 explicitly directs keeping the existing
   `vibe_strings.dart` copy rather than importing the canvas's untranslated
   string.
2. Right tile label renders the generic `Đối tác` where the canvas binds
   `{{ partnerName }}` (sample value "Minh"). `ux/uiux-spec.md` §4 forbids a
   fabricated partner name; no partner-profile source reaches Home yet, and
   STORY-006 owns that data bind.
3. Both tiles render the waiting label `Chưa nói gì` where the canvas shows
   sample moods. v1 mounts the card with no mood snapshot so it does not
   duplicate `VibeScreen`'s own fetch — this is a data state, not a layout
   deviation. The `today` / `partnerToday` parameters are present and covered
   by test so the future bind needs no layout change.

## Interaction Check (AC3)

One `Semantics(button: true)` wrapping one `GestureDetector` over the whole
card; no per-tile tap targets and no new navigation destination were added.
`onTap` still pushes `VibeScreen` from `home_screen.dart`. Asserted by
`VibeEntryCard design fidelity (REQ-010 STORY-002) keeps exactly one tap
target, still wired to onTap`.

## Verdict

VISUAL_FIDELITY: PASS — every deviation named in the UX spec is corrected in
the rendered app and re-verified against the design reference capture. All
three acceptance criteria are met.
