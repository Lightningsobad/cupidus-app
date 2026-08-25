# UX Spec: STORY-002 Vibe-Check Card Design Fidelity

Design source: `cupid-app-design-system/Cupid Screens.dc.html`, `isHome`
block, lines 274-289 (the `goVibe` card). Configuration: dark theme + `vi`
locale only (`[data-plat]` + `body[data-theme="dark"]` tokens, lines 23-26).

Target widget: `mobile/lib/features/vibes/presentation/widgets/vibe_entry_card.dart`
(`VibeEntryCard`), already mounted on `home_screen.dart`. No new file, no new
route.

## 1. Audit finding

The current `VibeEntryCard` renders a **single-row** card: one mood face
(`today` only) + a stacked title/"Lịch sử" text column + a trailing chevron
icon. The design source's card is a **two-tile** layout: a header row
(icon + "Vibe Check" title, "Lịch sử" link right-aligned) followed by two
side-by-side sub-tiles — "you" and "partner" — each with its own mood face
and mood label. There is no chevron in the design source; the entire card
`div` carries the single `onClick={{ goVibe }}`.

Concrete deviations to correct:
1. Missing two-tile row entirely (today only, no partner tile).
2. Missing header-row structure (icon + title left, "Lịch sử" pink label
   right) — current version stacks title above "Lịch sử" in one column
   instead.
3. Wrong tap affordance: a trailing chevron icon is not in the design
   source; remove it. The design source's own affordance for "this card is
   tappable" is the pink "Lịch sử" label plus the two visually-boxed
   sub-tiles, not a chevron.
4. Card padding is `CupidSpacing.md` (16) on all sides; design source uses
   `17px` on all sides.
5. Mood face size is `40`; design source's per-tile face is `36px`
   (`--r-sm` sub-tile, matches `VibeMoodFace`'s own default `size: 36`).
6. No `colorSurfaceAlt` (`--surf2`) sub-tile background is used anywhere in
   the current widget.

## 2. Structure (top to bottom, matches lines 274-289 exactly)

```
Semantics(button: true, label: title)
  GestureDetector(onTap: onTap)                          # whole-card tap, unchanged behavior
    ConstrainedBox(minHeight: platform.tapTarget)
      Container                                            # outer card
        padding: EdgeInsets.all(17)                        # design: padding:17px
        color: colors.colorSurface                         # design: var(--surf)
        borderRadius: platform.radiusCard                  # design: var(--r-card)
        boxShadow: platform.elevationShadow                # design: var(--shadow)
        Column (mainAxisSize: min, crossAxisAlignment: start)
          Row                                               # header row
            mainAxisAlignment: spaceBetween
            Row (left group)                                # icon + title
              [mood glyph — see §5 open item] size 19, color colorAccentPink
              SizedBox(width: 8)                             # design: gap:8px
              Text('Cảm xúc hằng ngày' / vi: giữ nguyên chuỗi hiện có)
            Text('Lịch sử' / 'History')                     # right-aligned, pink
          SizedBox(height: 14)                               # design: margin-bottom:14px
          Row                                                # two-tile row
            gap: 10                                          # design: gap:10px
            Expanded(_VibeMiniTile(mood: today, label: 'Bạn'/'You'))
            Expanded(_VibeMiniTile(mood: partnerToday, label: partner label — see §4))
```

`_VibeMiniTile` (both tiles share this shape, lines 280-287):

```
Container
  padding: EdgeInsets.all(12)                                # design: padding:12px
  color: colors.colorSurfaceAlt                              # design: var(--surf2)
  borderRadius: platform.radiusSmall                          # design: var(--r-sm)
  Row
    VibeMoodFace(mood: mood, size: 36)                        # design default size, matches 36px
    SizedBox(width: 11)                                       # design: gap:11px
    Expanded(min-width:0 → wrap in Expanded, Column already clips via ellipsis)
      Column (crossAxisAlignment: start, mainAxisSize: min)
        Text(label)                                            # "Bạn"/"You" or partner label — caption role
        Text(moodLabel, overflow: ellipsis)                    # bold mood value
```

## 3. Typography (exact px, no existing token matches — follow the
established `type.<role>.copyWith(fontSize: ...)` pattern already used by
`_MilestonePill` in `home_screen.dart` and `PartnerVibeCard`; do not invent
new `CupidTypographyTokens` fields for this story)

| Element | Source (line) | Base role | Overrides |
|---|---|---|---|
| "Vibe Check" title (`Cảm xúc hằng ngày`) | 276, `font-size:12.5px;font-weight:700;letter-spacing:.03em` | `type.caption` | `fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 12.5 * 0.03, color: colors.colorText` |
| "Lịch sử" / "History" link | 277, `font-size:11.5px;color:var(--pink);font-weight:700` | `type.caption` | `fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.colorAccentPink` |
| Tile label ("Bạn"/partner label) | 282/286, `font-size:11px;color:var(--tx2)` | `type.caption` | `fontSize: 11, color: colors.colorTextMuted` |
| Tile mood value | 282/286, `font-size:13.5px;font-weight:800` | `type.body` | `fontSize: 13.5, fontWeight: FontWeight.w800, color: colors.colorText`, `overflow: TextOverflow.ellipsis`, `whiteSpace` has no Flutter equivalent needed (single line) |

Keep the existing title copy from `vibe_entry_card.dart` (`'Cảm xúc hằng ngày'`
/ `'Daily Vibe Check'`) and `'Lịch sử'`/`'History'` — those strings are
already correct per `vibe_strings.dart` precedent; only the styling and
layout position change.

## 4. Partner tile label — no fabricated name

The design source binds `{{ partnerName }}` as the right tile's label
(line 286). `VibeEntryCard` has no partner-name prop today, and
`PartnerVibeCard` (`vibe_screen.dart`'s own partner tile, already shipped)
never renders the partner's actual name either — it shows only the mood
label. STORY-006 (couple title / partner-name display) is the story that
adds a partner-profile data source to Home, and REQ-010's own guardrail for
that story is "no fabricated partner name" when the data is unavailable.

Decision for this story: reuse a generic partner label, not a literal name,
consistent with `PartnerVibeCard`'s existing precedent and REQ-010's
no-fabrication rule:
- vi: `'Đối tác'`
- en: `'Partner'`

Add this string next to the existing `historyLabel`/`title` locals in
`vibe_entry_card.dart` (or `vibe_strings.dart` if a shared extension method
is preferred — dev's call, no new file required either way). Do not thread
a `partnerName` prop through for this story; that is STORY-006 scope.

## 5. Open item — header icon glyph (`mood`)

The design source's header icon is the Material Symbols `mood` glyph
(line 276, `data-icon`, `font-size:19px;color:var(--pink)`). `CupidIcons`
(`design_system/icons/cupid_icons.dart`) currently has no `mood` entry, and
that file's own sourcing rule forbids inventing an unverified codepoint
(same rule `_MilestonePill` in `home_screen.dart` already followed by
omitting the `bedtime` glyph it couldn't verify).

Direction for dev: confirm the `mood` codepoint in the bundled
`MaterialSymbolsRounded-Variable.ttf` cmap first (same verification
`PartnerVibeCard` did for its own local `tips_and_updates` icon,
`partner_vibe_card.dart` lines 40-48) —
- If confirmed: add `mood` to `CupidIcons` (this file is not out of this
  story's write scope, unlike `PartnerVibeCard`'s case) and render it at
  `size: 19, color: colors.colorAccentPink`.
- If not confirmed: omit the glyph and keep only the title text in the
  header-row left group, matching the `_MilestonePill` omission precedent.
Either outcome satisfies AC1 — the design source's own comparison is layout/
spacing/token/typography fidelity, and glyph omission-on-unverified-codepoint
is this codebase's established, already-reviewed way of handling that gap.

## 6. Spacing/radius/color token map

| Design token | Flutter token |
|---|---|
| `padding:17px` (outer card) | literal `17` (no `CupidSpacing` step matches; follow `PartnerVibeCard`'s own literal-`17` precedent, line 21 of `partner_vibe_card.dart`) |
| `gap:8px` (header icon↔title) | `CupidSpacing.sm` (8) |
| `margin-bottom:14px` (header→tiles) | literal `14` |
| `gap:10px` (tile↔tile) | literal `10` |
| `padding:12px` (per tile) | literal `12` |
| `gap:11px` (tile face↔text) | `CupidSpacing.sm + 3` → literal `11` (no exact step) |
| `var(--surf)` | `colors.colorSurface` |
| `var(--surf2)` | `colors.colorSurfaceAlt` |
| `var(--r-card)` | `platform.radiusCard` |
| `var(--r-sm)` | `platform.radiusSmall` |
| `var(--shadow)` | `platform.elevationShadow` |
| `var(--pink)` | `colors.colorAccentPink` |
| `var(--tx)` | `colors.colorText` |
| `var(--tx2)` | `colors.colorTextMuted` |

Declare these as named `const double` constants at the top of
`vibe_entry_card.dart`, matching the established pattern in
`home_screen.dart` (`_milestoneFontSize` etc.) and `partner_vibe_card.dart`
(`_cardPadding` etc.) — do not inline magic numbers.

## 7. Interaction / accessibility (AC3 — no new entry point)

- Keep exactly one `Semantics(button: true, label: title)` +
  `GestureDetector(onTap: onTap)` wrapping the whole card, as today. The two
  mini-tiles and the "Lịch sử" label are not separately tappable in the
  design source (both sit inside the single `onClick={{ goVibe }}` div) —
  do not add a second `GestureDetector`/`InkWell` around either tile or the
  history label.
- Keep `ExcludeSemantics` around the visual content so the two per-tile mood
  faces don't announce as separate interactive elements; the outer
  `Semantics.label` (card title) remains the single accessible name, same as
  today.
- No new tap target, no new route: `onTap` still pushes the already-shipped
  `VibeScreen`, unchanged from the current wiring in `home_screen.dart`.

## 8. Responsive behavior

Single fixed layout — this card renders inside Home's existing 16px-padded
column (`home_screen.dart` line 265 `padding:0 16px`), one width, no
breakpoints. The two tiles use `Expanded` so they split the available width
evenly regardless of device width; no separate phone/tablet variant exists
in the design source for this card.

## 9. Acceptance criteria mapping

- AC1 (layout/spacing/token/typography match exactly) → §2 structure, §3
  typography, §6 token map.
- AC2 (deviation corrected in rendered app, re-verified) → dev must
  visually re-capture the Home screen (dark + `vi`) after the fix and diff
  against `cupid-app-design-system`, same evidence pattern as prior
  `REQ-002` design-fidelity stories.
- AC3 (tap still reaches `VibeScreen`, no new entry point) → §7.
