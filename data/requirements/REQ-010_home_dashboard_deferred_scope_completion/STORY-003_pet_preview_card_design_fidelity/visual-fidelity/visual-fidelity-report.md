# Visual Fidelity — STORY-003 Pet preview card

VISUAL_FIDELITY: PASS

- Design-Screen: home
- Story: STORY-003_pet_preview_card_design_fidelity
- Phase: P1 (pet preview card fidelity and fixture)
- Compared component: the `isHome` pet preview node
  (`cupid-app-design-system/Cupid Screens.dc.html` lines 290-303) vs.
  `_PreviewReadyShell` + `_PreviewReady` in
  `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`
- Theme / locale: dark, `vi`
- Captured: 2026-08-25

## Artifacts

- Implemented: `implemented-home-android-emulator-5554.png` (405x900, PNG)
- Design reference: `design-reference-home-android.png` (406x900, PNG)

## How the state was reached

Faked, not driven. The Home render is the fixture-backed preview entrypoint, so
no auth, pairing or live backend was involved:

```
flutter build apk --debug --flavor local -t lib/main_preview.dart \
  --dart-define=PREVIEW=home \
  --dart-define=PREVIEW_HOME_FIXTURE=true \
  --dart-define=PREVIEW_PET_FIXTURE=true
```

`PREVIEW_PET_FIXTURE` installs `_PreviewPetRepository`, which resolves the card
to `PetReady` with the design canvas' own pet state (`petXp: 62, petLv: 3`,
species `bun`, canvas line 1979). Without it an unauthenticated `GET /users/me`
puts the card in `PetFailure` and the capture photographs "Không thể tải Bún" —
the failure state the design source never depicts (AC3).

Capture (device already running; no provisioning performed):

```
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --out=<story>/visual-fidelity --label=home-android \
  --device=emulator-5554 --settle-ms=1500
```

Design reference rendered from the locked design source with
`.ai-team-bundle/runtime/tools/render-design-canvas.js --screen=home`
(`data/devops/system/design-fidelity-config.json`, `locked: true`).

## Per-property comparison (uiux-spec §1-§3)

| # | Property | Design source | Implemented | Verdict |
|---|---|---|---|---|
| 1 | Card background | `linear-gradient(130deg, rgba(255,127,182,.2), rgba(121,226,205,.16))` | `LinearGradient` begin/end from 130°, `colorAccentPink.withAlpha(51)` → `colorMint.withAlpha(41)` | MATCH |
| 2 | Border | `1px solid var(--line)` | `Border.all(color: colors.colorLine, width: 1)` | MATCH |
| 3 | Clip | `overflow:hidden` at `var(--r-card)` | `ClipRRect` at `platformTokens.radiusCard` | MATCH |
| 4 | Glow circle | `74x74`, `top:-14`, `right:12%`, `radial-gradient(circle, rgba(255,255,255,.26), transparent 70%)`, `pointer-events:none` | 74x74 circle, `top: -14`, `right: constraints.maxWidth * 0.12`, white `alpha 66` → `alpha 0` at `stops: [0.0, 0.7]`, `IgnorePointer` | MATCH |
| 5 | Glow animation | `breathe 8s` | none (no `AnimationController`) | MATCH — capture is a settled frame; per plan task 2 the animation is deliberately not ported |
| 6 | Outer row | `display:flex; gap:15px; align-items:center` | `Row(crossAxisAlignment: center)` + `SizedBox(width: CupidSpacing.md)` (16) | MATCH — 16 vs 15 is the established token-rounding precedent, not visible at 1x |
| 7 | Sprite | `74x74` Pet Sprite | `BunSprite(state: …, size: 74)` | MATCH |
| 8 | Name/chip row | `display:flex; align-items:baseline; gap:8px` | `Row(crossAxisAlignment: baseline, textBaseline: alphabetic)` + `SizedBox(width: CupidSpacing.sm)` | MATCH |
| 9 | Pet name | Nunito 17 / w900 on `--tx` | `TextStyle(fontFamily: 'Nunito', fontWeight: w900, fontSize: 17, color: colorText)` | MATCH |
| 10 | Level chip fill | `rgba(255,127,182,.22)`, `border-radius:6px` | `colorAccentPink.withAlpha(56)`, `BorderRadius.circular(6)` | MATCH |
| 11 | Level chip text | `'Roboto Mono'` 10px on `var(--pink)`, reads `Lv.3` | `labelMono.copyWith(fontSize: 10, color: colorAccentPink)`, reads `'Lv.${status.pet.level}'` = `Lv.3` | MATCH — no mood suffix, as the design badge carries none |
| 12 | Status caption | 12px on `var(--tx2)`, `margin-top:3px` | `caption.copyWith(fontSize: 12, color: colorTextMuted)` after `SizedBox(height: CupidSpacing.xs)` (4) | MATCH — 4 vs 3 is token rounding |
| 13 | XP bar gap | `margin-top:10px` | `SizedBox(height: CupidSpacing.sm)` (8) | MATCH — nearest token, not visible at 1x |
| 14 | XP bar track | `height:8px; border-radius:5px; background:var(--surf)` | `SizedBox(height: 8)` + `ColoredBox(colorSurface)` clipped at `radiusSmall` | MATCH — radius ≥ height/2 renders the identical pill end |
| 15 | XP bar fill | `background:var(--grad)`, `width:{{petXpPct}}%` = 62% | `FractionallySizedBox(widthFactor: status.levelProgress.clamp(0,1))` = 0.62 over `DecoratedBox(gradient: gradientDream)` | MATCH |
| 16 | XP bar placement | child of the `flex:1;min-width:0` text column — starts at the caption's left edge, right of the sprite | nested inside the `Expanded` column, after the caption | MATCH |
| 17 | Tap target | `onClick="{{ goPet }}"; cursor:pointer` over the whole card | `_PreviewTapTarget` (`Semantics(button: true)` + `GestureDetector(onTap: PetRoute.push)`) wrapping both shells | MATCH |

### Deviation found and corrected during this phase

Property 16 was initially wrong. The first implementation emitted the XP bar as
a sibling of the outer `Row`, so it rendered full-bleed across the card padding
instead of starting at the caption's left edge. The rendered comparison is what
caught it — the widget tests were green either way, because the original
assertion checked the bar's own width against `cardWidth - 32` and therefore
encoded the wrong layout. Both the widget and its assertion were corrected; the
test now anchors the bar's left edge to the caption's left edge, which is the
property the design source actually fixes.

## Regions of the capture NOT owned by this story

The screenshots differ outside the pet card. Those regions are other stories'
scope and are deliberately not part of this verdict:

- The "Seen 5 phút rồi đấy" banner and the "Vibe Check" card — not yet built on
  the implemented Home.
- The `Synced Alarm` / `Zodiac Red Flag` two-column grid — the implemented Home
  still renders its older single-column entry cards.
- Header action icons (share, bell) and the two-avatar couple header.

STORY-017 shipped the Home shell and explicitly deferred the "Bún pet card"
(deferral F6) to a later story. This story is that owner, and the pet card is
the only region its acceptance criteria cover.

## Verdict

PASS for the story's compared component. Every row in the table above matches,
including the corrected XP bar placement, and the capture shows a populated
`PetReady` card rather than the failure state (AC3).
