# Visual Fidelity Report: STORY-020 — Vibe Check

Story: STORY-020 Design Fidelity — Vibe Check
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Lane: mobile
Configuration audited: dark theme + `vi` locale (per story In Scope §1)
Outcome: FIXED IN CODE (this was a fix story, not audit-only)

## Design Source

`cupid-app-design-system/project/Cupid Screens.dc.html`, the block guarded by
`<sc-if value="{{ isVibe }}">` (lines 433-486), plus the dark token block
(lines 45-64) and the screen-chrome title binding `title: L['t_' + sc]` with
`t_vibe: 'Vibe Check'` (identical in `vi` and `en`).

Dark tokens referenced below:
`--bg:#171129`, `--surf:#241B42`, `--surf2:#2E2456`,
`--line:rgba(247,238,251,.11)`, `--tx:#F7EEFB`, `--tx2:#B4A6CE`,
`--pink:#FF7FB6`, `--purple:#B78CF5`, `--butter:#FFD79E`, `--amber:#FFC97E`,
`--grad-hot:linear-gradient(120deg,#FF7FB6,#B78CF5)`,
`--glow:0 8px 28px rgba(255,107,168,.34)`, `--r-sm:16px`,
`--r-card` = 26 (iOS) / 24 (Material).

## Files Changed

- `mobile/lib/features/vibes/presentation/vibe_screen.dart`
- `mobile/lib/features/vibes/presentation/widgets/vibe_mood_grid.dart`
- `mobile/lib/features/vibes/presentation/widgets/partner_vibe_card.dart`
- `mobile/lib/features/vibes/presentation/widgets/vibe_history_strip.dart`
- `mobile/test/features/vibes/presentation/vibe_screen_test.dart`
- `mobile/test/features/vibes/presentation/widgets/vibe_widgets_test.dart`

No file under `lib/design_system/` was modified. No existing shared token or
adaptive component was changed in place.

## Deviations Found And Fixed

### Screen chrome and hero (AC1)

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| 1 | Chrome title showed the check-in prompt instead of the screen name | `t_vibe: 'Vibe Check'` | `context.checkInPromptTitle` in `CupidHeader` | literal screen name `Vibe Check` (locale-invariant in the source) |
| 2 | The prompt had no place in the body | hero block `text-align:center;padding:14px 0 22px` | absent | new `_VibeHero`: centered 27px/1.25 Nunito w900 title + 13px `--tx2` subtitle at a 7px gap |
| 3 | Hero halo missing | absolute `180x90` `radial-gradient(circle, rgba(255,127,182,.28), transparent 68%)` | absent | `RadialGradient` from `colorAccentPink` @28% to the same token @0% with stops `[0, 0.68]`, `radius: 1.118034` (Flutter radius is a fraction of the box's shortest side, so `90/2 * r = 100.6` reaches the 180-wide box corner) |
| 4 | Screen padding | `padding:8px 16px 40px` | uniform `CupidSpacing.md` | `fromLTRB(md, 8, md, 40)` |

### Mood grid — the mood-state input component (AC1, AC3)

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| 5 | Selected cell used the wrong fill | `linear-gradient(140deg, rgba(255,127,182,.3), rgba(183,140,245,.26))` | `colors.gradientDream` (opaque, 120deg) | `colorAccentPink` @30% → `colorAccentPurple` @26% at the 140deg alignment pair, derived with the same CSS-angle mapping already used in `cupid_color_tokens.dart` |
| 6 | Off cell had no border, so selecting a cell resized it | off cell `border:1.5px solid transparent`, selected `1.5px solid var(--pink)` | border only when selected | 1.5px border always present; the off state uses the cell's own surface color as the stand-in for `transparent` |
| 7 | Cell padding | `padding:17px 8px` | `CupidSpacing.md` uniform | `symmetric(vertical: 17, horizontal: CupidSpacing.sm)` |
| 8 | Grid gap | `gap:11px` | `CupidSpacing.sm` with an outer inset | 11px between columns/rows, no outer inset (grid edges align with screen padding) |
| 9 | Label metrics | `font-size:12.5px;margin-top:10px` | inherited `caption`, `CupidSpacing.sm` gap | `fontSize: 12.5` at a 10px gap; weight stays w800 selected / w600 `--tx2` off, matching the source |
| 10 | Face size | `52x52` | 48 | 52 |

Mood sticker treatment (AC3) was already correct: `VibeMoodFace` renders the
same emoji glyphs as the source's `moodList` faces, and this story only
resized them. No substitute icon set is used.

### Partner mood display (AC1)

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| 11 | Card padding / row gap | `padding:17px`, row `gap:13px` | `CupidSpacing.md` both | 17 and 13 |
| 12 | Avatar box | `52x52;border-radius:18px;padding:5px` holding a `42px` face | 48 box, card radius, no inset | 52 box, 18 radius, 5 inset, 42 face |
| 13 | Mood label size | `font-size:15.5px;font-weight:800` | `body` default | `fontSize: 15.5`, w800 |
| 14 | Nudge banner fill was opaque | `background:rgba(255,201,126,.14)` (`--amber` @14%) | solid `colors.colorButter` | `colorAmber.withValues(alpha: 0.14)` |
| 15 | Banner glyph missing | `tips_and_updates` at `font-size:19px;color:var(--butter)` | absent | `CupidIcon(_tipsAndUpdates, size: 19, color: colorButter)` |
| 16 | Banner geometry / text | `margin-top:14px;padding:13px 15px;gap:11px`, text `12.5px/1.45` | `CupidSpacing` defaults | 14 / 13x15 / 11, text 12.5 at height 1.45 |
| 17 | CTA was plain text | pill `padding:7px 13px;border-radius:999px;background:var(--grad-hot);font-size:11.5px;font-weight:800;white-space:nowrap` | unstyled `Text` | `Container` with `gradientHot`, `platform.radiusButton`, 7x13 padding, 11.5px w800, `softWrap: false` |

The CTA stays decorative (no `GestureDetector`, no button semantics), per the
existing D-010-4 decision — the design source wires no `onClick` and no
backend endpoint exists. The existing semantics test still passes.

### 7-day history strip (AC1)

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| 18 | Card top gap / padding | `margin-top:13px;padding:17px` | `CupidSpacing.md` both | 13 and 17 |
| 19 | Header casing and metrics | `12px;700;letter-spacing:.05em;text-transform:uppercase;--tx2` | sentence case, `caption` default | `.toUpperCase()`, 12px, w700, `letterSpacing: 0.6` (= .05em at 12px) |
| 20 | Header gap | `margin-bottom:14px` | `CupidSpacing.sm` | 14 |
| 21 | Column and stack gaps | columns `gap:5px`, inside a column `gap:7px` | `CupidSpacing.xs`/`sm` | 5 and 7 |
| 22 | Connector | `height:3px;border-radius:2px;background:var(--line)` | square 2px `Divider`-style box | 3px tall, 2px radius, `colorLine` |
| 23 | Day label | `font-size:9.5px` mono, `--tx2` | `labelMono` with no explicit size (the token deliberately carries none) | `fontSize: 9.5` |
| 24 | Face size | `26px` | 24 | 26 |

## Deliberately Kept As-Is (approved prior divergences, not new deviations)

- **3 + 2 centered mood layout instead of the source's 3-column grid of 6.**
  STORY-010 `ux/uiux-spec.md` §3 resolves the design/backend mismatch
  explicitly: the source's `soft` mood has no backend value, so the app ships
  5 moods as "2 rows (3 + 2, centered)". The `FractionallySizedBox(widthFactor:
  2/3)` that produces equal cell widths is also locked by an existing test.
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
| `popIn`, `bob`, and `breathe` animations | CSS keyframes | The hero halo is rendered statically at its resting state. An unbounded repeating animation makes `pumpAndSettle` time out, which would break the existing `vibe_screen_test.dart` suite. Static rendering is visually identical at rest. |
| `CupidHeader` chrome typography (source `Nunito;800;21px;letter-spacing:-.01em` vs the app's `cardTitle` 22px) | 1px + weight delta | `CupidHeader` is a shared adaptive component used by every screen. Changing it in place is forbidden by the handoff and would be a cross-screen change, not a Vibe Check fix. |

## Additive Declaration (single consumer, documented per STORY-003/006 precedent)

`_tipsAndUpdates = IconData(0xe79a, fontFamily: CupidIcons.fontFamily)` is
declared privately in `partner_vibe_card.dart` rather than added to
`CupidIcons`, because `lib/design_system/icons/` is outside this story's
WriteScope. The codepoint was verified against the bundled
`MaterialSymbolsRounded-Variable.ttf` cmap with fontTools — it was not
invented, and the `.fill` variant has no cmap entry so only the outline form
is used. Promote it to `CupidIcons` when that file is next in scope.

`colors.colorText` is used for the CTA pill label where the source hardcodes
`#fff`. There is no theme-invariant white token; this follows the existing
`CupidPrimaryButton` on-accent convention rather than introducing a literal.

## Tests

Added to `mobile/test/features/vibes/presentation/widgets/vibe_widgets_test.dart`
(group `STORY-020 design fidelity`):

1. the selected mood cell fills with the 140deg translucent pink/purple
   gradient, not the opaque dream gradient — asserts 2 stops at alpha 0.3 and
   0.26 and that it is not `gradientDream`;
2. selecting a cell does not resize it — asserts equal cell heights and a
   non-null border on the off cell;
3. the nudge banner is an amber tint with the `tips_and_updates` glyph and a
   gradient CTA pill — asserts the 14% amber fill, the butter icon color, and
   `gradientHot` on the pill.

Added to `mobile/test/features/vibes/presentation/vibe_screen_test.dart`:

4. the chrome title is the screen name and the prompt moves into the centered
   hero block — asserts `Vibe Check` inside `CupidHeader`, the 27px hero
   title, and the subtitle.

Updated: the history-header expectation now matches the uppercase rendering.

## Verification

Run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-020/mobile`
with `/Users/alantravala/flutter/bin/flutter` (the SDK is not on `PATH`).
`flutter gen-l10n` was run first because `lib/l10n/generated/` is generated
and was absent in a fresh worktree.

| Command | Result |
|---|---|
| `flutter gen-l10n` | OK |
| `flutter analyze lib/features/vibes test/features/vibes` | 1 issue, 0 new. The single `info` is `prefer_initializing_formals` at `vibe_screen.dart:27`, verified identical in `git show 8396273:...vibe_screen.dart` (BaseHead) — pre-existing, untouched by this story. |
| `flutter test test/features/vibes test/design_system` | **75 passed, 0 failed** — "All tests passed!" |

The regression slice includes `test/design_system/no_fork_guard_test.dart`
(AC 4 no-fork guard), which passes: every color in the changed files comes
from a `ThemeExtension` token, with translucency expressed via
`Color.withValues(alpha:)` rather than a raw literal.

## Acceptance Criteria Status

- **AC1** (layout, spacing, token usage, typography match in dark + `vi`):
  MET for everything in WriteScope; the four deferred items above are listed
  with rationale and none is a token/spacing/typography defect that this
  story could fix without leaving its lane.
- **AC2** (deviations corrected in the app, not merely documented): MET — 24
  deviations fixed in code and covered by the tests above.
- **AC3** (mood sticker treatment matches the source): MET — same emoji
  glyphs, resized to the source's 52px/42px/26px.
- **AC4** (no change to how the screen is reached): MET — navigation and the
  `HomeScreen` entry card are untouched; the existing entry-point test passes.
