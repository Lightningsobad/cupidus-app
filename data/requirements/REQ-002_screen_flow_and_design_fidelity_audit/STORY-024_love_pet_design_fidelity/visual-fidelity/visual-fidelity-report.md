# Visual Fidelity Report — STORY-024 Love Pet ("Bún") Design Fidelity

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-024_love_pet_design_fidelity
- Role: mobile-dev
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-024`
- BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`

## 1. Comparison Basis

| Item | Value |
| --- | --- |
| Design source | `cupid-app-design-system/project/Cupid Screens.dc.html`, `<sc-if value="{{ isPet }}">` block, lines 629–689 |
| Sprite source | `cupid-app-design-system/project/Bun Sprite.dc.html` |
| Token source | `[data-plat]` / `body[data-theme="dark"]` custom-property block in the same design file |
| App configuration compared | dark theme + `vi` locale (per handoff) |
| Screen under audit | `mobile/lib/features/pet/presentation/pet_screen.dart` and its `widgets/` subtree |

### CSS variable → Flutter token mapping used throughout

| Design CSS var | Flutter token |
| --- | --- |
| `--grad` `linear-gradient(120deg,#FF9CC4,#C79BF0 52%,#8FE6D3)` | `CupidColorTokens.gradientDream` |
| `--grad-hot` | `CupidColorTokens.gradientHot` |
| `--surf` / `--surf2` / `--line` / `--tx` / `--tx2` | `colorSurface` / `colorSurfaceAlt` / `colorLine` / `colorText` / `colorTextMuted` |
| `--shadow` | `CupidPlatformTokens.elevationShadow` |
| `--glow` | `CupidColorTokens.glowShadow` |
| `--r-card` / `--r-sm` / `--r-btn` | `radiusCard` / `radiusSmall` / `radiusButton` |
| `--tap` | `CupidPlatformTokens.tapTarget` |
| `--pink` | `colorAccentPink` |
| mint / amber / peach reaction accents | `colorMint` / `colorAmber` / `colorPeach` |

No raw color literal, `Colors.*`, or platform check was introduced under `lib/features`; the
no-fork guard (`mobile/test/design_system/no_fork_guard_test.dart`) stays green.

## 2. Deviations Found And Fixed

### 2.1 Hero card — `pet_hero_card.dart`

| # | Design source | Before | After |
| --- | --- | --- | --- |
| 1 | `border:1px solid var(--line)` | no border | `Border.all(color: colors.colorLine)` |
| 2 | `box-shadow:var(--shadow)` | no shadow | `boxShadow: platformTokens.elevationShadow` |
| 3 | `linear-gradient(178deg,#7B4FBE,#B0518C 52%,#5E7E96)` | 120deg, no mid stop | 178deg alignments + `stops: [0.0, 0.52, 1.0]` (see §4) |
| 4 | Lv pill `background:rgba(255,255,255,.2)` | `colorSurface` @ 22% (dark plum, reads as a hole) | `colorText` @ 20% |
| 5 | Lv pill `border:1px solid rgba(255,255,255,.28)` | no border | `colorText` @ 28% |
| 6 | Lv pill `padding:6px 16px` | horizontal `CupidSpacing.sm` (8) | horizontal `CupidSpacing.md` (16) |
| 7 | Lv pill `font-weight:800`, UI font | `labelMono` (Roboto Mono) | `caption.copyWith(fontWeight: w800, color: colorText)` |
| 8 | pill → name `margin-top:14px` | `CupidSpacing.sm` (8) | `CupidSpacing.md` (16) |
| 9 | pet name `Nunito;900;34px;letter-spacing:-.02em` | `cardTitle` (UI font, w600, 22) | `display` + `letterSpacing: -0.02 * fontSize` |
| 10 | pet line `13.5px; rgba(255,255,255,.82)` | `body` (17) at full `colorText` | `caption` at `colorText` @ 82% |

### 2.2 XP card — `pet_xp_card.dart`

| # | Design source | Before | After |
| --- | --- | --- | --- |
| 11 | card `box-shadow:var(--shadow)` | no shadow | `platformTokens.elevationShadow` |
| 12 | XP label `12.5px;700` at default text color | `caption` muted, no weight | `caption.copyWith(fontWeight: w700, color: colorText)` |
| 13 | `{{petXpPct}}%` readout, Roboto Mono 12px, `var(--pink)` | absent | `labelMono.copyWith(fontSize: 12, color: colorAccentPink)`, right-aligned on a baseline-aligned header row |
| 14 | bar `height:12px;border-radius:7px` | 8px `LinearProgressIndicator` | 12px `SizedBox` clipped to `radiusSmall` |
| 15 | fill `background:var(--grad)` | solid `colorAccentPink` | `gradientDream` inside `FractionallySizedBox(widthFactor: progress)` over a `ColoredBox(colorSurfaceAlt)` track (`--surf2`) |

Accessibility note for #14/#15: replacing `LinearProgressIndicator` removes its implicit
progress semantics, so the bar is wrapped in `Semantics(value: '<n>%')` to keep the value
announced by screen readers.

### 2.3 Stats tiles — `pet_stats_row.dart`

| # | Design source | Before | After |
| --- | --- | --- | --- |
| 16 | tile `box-shadow:var(--shadow)` | no shadow | `platformTokens.elevationShadow` |
| 17 | tile content centered | `crossAxisAlignment: start`, no `textAlign` | centered `Column` + `TextAlign.center` on all three `Text`s |
| 18 | value `Nunito;900;19px` | `cardTitle` (UI font, w600, 22) | `display.copyWith(fontSize: 19)` |
| 19 | tile `padding:14px 10px` | `EdgeInsets.all(16)` | `symmetric(vertical: md, horizontal: sm)` |
| 20 | grid `gap:11px` | `CupidSpacing.md` (16) | `CupidSpacing.sm` (8) |

### 2.4 Reactions card — `pet_reactions_card.dart`

| # | Design source | Before | After |
| --- | --- | --- | --- |
| 21 | card `box-shadow:var(--shadow)` | no shadow | `platformTokens.elevationShadow` |
| 22 | title `12px;700;letter-spacing:.05em;text-transform:uppercase;color:var(--tx2)` | `cardTitle` (22) at `colorText`, sentence case | uppercased `caption.copyWith(fontWeight: w700, letterSpacing: 0.05 * fontSize, color: colorTextMuted)` |
| 23 | tiles tinted `rgba(121,226,205,.14)` / `rgba(255,201,126,.14)` / `rgba(255,171,147,.14)`, `border-radius:var(--r-sm)`, `padding:12px 6px` | untinted, unpadded, no radius | `accent.withValues(alpha: 0.14)` per role + `radiusSmall` + `symmetric(vertical: sm, horizontal: xs)` |
| 24 | caption `11px;700` in the tile's role color | `caption` at `colorTextMuted` | `caption.copyWith(fontWeight: w700, color: accent)` |
| 25 | tiles `flex:1`, `gap:10px` | `MainAxisAlignment.spaceEvenly` | three `Expanded` tiles separated by `SizedBox(width: CupidSpacing.sm)` |

Reaction caption strings were left byte-identical (`'Bơ một chút'`, `'Bơ lâu ghê'`); copy is
outside this story's named audit dimensions and existing tests assert them.

### 2.5 Action row — `pet_action_row.dart`

| # | Design source | Before | After |
| --- | --- | --- | --- |
| 26 | `gap:9px` | `CupidSpacing.md` (16) | `CupidSpacing.sm` (8) |
| 27 | primary `box-shadow:var(--glow)` | no glow | `boxShadow: primary ? colors.glowShadow : null` |
| 28 | secondary icon `color:var(--pink)` | `colorText` | `primary ? colorText : colorAccentPink` |
| 29 | label `font-weight:800` | `body` at w400 | `body.copyWith(fontWeight: w800)` |

### 2.6 Screen frame — `pet_screen.dart`

| # | Design source | Before | After |
| --- | --- | --- | --- |
| 30 | card column `padding:0 16px` | `EdgeInsets.all(CupidSpacing.lg)` (24) | `fromLTRB(md, sm, md, xl)` = `(16, 8, 16, 32)` |
| 31 | hero → XP `gap:13px` band, tightest first gap | `CupidSpacing.md` (16) | `CupidSpacing.sm` (8) |
| 32 | error surface uses the same card treatment | padding 24, no shadow | padding `md` + `elevationShadow` |

## 3. Verified Correct — No Change Needed

- `BunSprite` (`widgets/bun_sprite.dart`) is a faithful pure-Flutter port of
  `Bun Sprite.dc.html` geometry and palette; hero sprite renders at 206 and reaction
  sprites at 46, matching the design's declared sizes. AC3 (pet vector rendering) was
  already satisfied — no sprite change was required.
- Button pill radius (`--r-btn: 999`), card radius (`--r-card`), and small radius
  (`--r-sm`) already resolve through `CupidPlatformTokens`.
- Primary CTA already used `gradientHot`; XP track already used `--surf2`.
- Button height already uses `platformTokens.tapTarget` (44 iOS / 48 Material), which is
  intentionally kept over the design's flat `height:46px` so the tap-target a11y
  invariant and its existing test keep holding.

## 4. Design-System File Touched, With Justification

`mobile/lib/design_system/tokens/pet_hero_gradient.dart` was corrected in place.

- It is an existing **single-consumer additive token** created for `PetHeroCard`, not a
  shared token. Verified with `git grep -n "PetHeroGradient" -- mobile`: the only two
  matches are its own declaration file and `pet_hero_card.dart`.
- Its stored value was simply wrong against the design source — it encoded `120deg` with
  no mid stop, while the source declares
  `linear-gradient(178deg,#7B4FBE,#B0518C 52%,#5E7E96)`. Leaving it would have left AC1
  unmet with no alternative fix site.
- Derivation recorded in the file's dartdoc: for a CSS angle θ (0deg = to top, clockwise),
  `begin = (-sinθ, cosθ)` and `end = (sinθ, -cosθ)`; θ = 178deg yields
  `Alignment(-0.03489949670250097, -0.9993908270190958)` →
  `Alignment(0.03489949670250097, 0.9993908270190958)`.
- **No shared token and no `design_system/adaptive/` component was modified**, and no new
  shared token was added. This follows the STORY-003/006 precedent.

## 5. Deferred, With Rationale

| ID | Item | Rationale |
| --- | --- | --- |
| D1 | Hero corner radius: design uses a one-off `34px`; app keeps `radiusCard` (26 iOS / 24 Material) | No 34 token exists; adding a shape token is shared design-system work outside this story's WriteScope and forbidden-by-default list. Visual delta is small and consistent with every other card on the screen. |
| D2 | Hero decorative/motion layer: radial "breathe" glows, ✧/✦ drift sparkles, `popIn` entry, blurred ground-shadow ellipse | Animation is explicitly deferred by this story's own user-story text and Out of Scope. |
| D3 | Design's "Đổi bạn nhỏ / Switch companion" species picker grid inside the XP card | The app deliberately keeps species selection in the adopt sheet per `ux/uiux-spec.md` §2.1 — a documented REQ-001 information-architecture decision, not a fidelity regression. |
| D4 | Design's 3-up stats grid with per-tile icons (`favorite`, `local_fire_department`, `military_tech`) | The app renders 2 tiles because `day streak` and `badges` have no backing `pets` field (`ux/uiux-spec.md` §2.1 item 4, §5 Open Item 2). Icons deferred separately: `CupidIcons` ships no `favorite` / `military_tech` glyph, and adding one means editing `design_system/icons/cupid_icons.dart` with codepoints that must be verified against the bundled font cmap — shared design-system work, out of scope per the stop rule. |
| D5 | Hero copy is pure `#fff` in the design; the app uses `colorText` (dark `#F7EEFB`) and alpha ramps of it | There is no white / on-hero token, and `Colors.white` is banned under `lib/features` by the no-fork guard. In dark theme (the audited configuration) the delta is imperceptible. In light theme `colorText` is `#3E2645`, which would be low-contrast over the purple hero — but light theme is not user-enabled (OQ5), so it is out of this story's audited configuration. Flagged for the design-system token owner. |
| D6 | Design's exact px type sizes (`11.5`, `12.5`, `10.5`, `13.5`, `14`) mapped to nearest token role (`caption` 13 / `body` 17) rather than raw sizes | Keeps typography flowing through `CupidTypographyTokens` instead of forking sizes into feature code. Two exceptions where the gap was visually material and the size is verbatim design-source data: the stat value (`display` scaled to 19) and the XP percent (`labelMono` is intentionally unsized by design — "callers size it per context"). |
| D7 | `PetLockedCard` / `PetAdoptPromptCard` in `pet_guard_states.dart` left unchanged | These states do not exist in the design source's `isPet` block. They come from `ux/uiux-spec.md` §8's shared pairing-gate pattern ("reuse the Private Gallery locked pattern verbatim"); restyling them here would fork that shared pattern. |

No blocker was hit: no fix required editing a shared design-system component in place, and
no backend/API change was needed.

## 6. Files Changed

Implementation:
- `mobile/lib/features/pet/presentation/pet_screen.dart`
- `mobile/lib/features/pet/presentation/widgets/pet_hero_card.dart`
- `mobile/lib/features/pet/presentation/widgets/pet_xp_card.dart`
- `mobile/lib/features/pet/presentation/widgets/pet_stats_row.dart`
- `mobile/lib/features/pet/presentation/widgets/pet_action_row.dart`
- `mobile/lib/features/pet/presentation/widgets/pet_reactions_card.dart`
- `mobile/lib/design_system/tokens/pet_hero_gradient.dart` (single-consumer token, §4)

Tests:
- `mobile/test/features/pet/presentation/pet_design_fidelity_test.dart` (new, 8 tests)
- `mobile/test/features/pet/presentation/widgets/pet_engagement_test.dart` (updated for the
  gradient XP bar that replaced `LinearProgressIndicator`)

## 7. Verification

All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-024/mobile`
with `PATH="/Users/alantravala/flutter/bin:$PATH"`.

| Command | Result |
| --- | --- |
| `flutter gen-l10n` | Regenerated `l10n/generated/` (cleared 3 pre-existing analyzer errors in `test/features/pet/presentation/pet_entry_point_test.dart` caused by the un-generated l10n output; not a code change) |
| `flutter analyze lib/features/pet lib/design_system/tokens/pet_hero_gradient.dart test/features/pet` | `Analyzing 3 items... No issues found! (ran in 1.9s)` — **0 errors, 0 warnings** |
| `flutter test test/features/pet test/design_system` | `00:04 +137: All tests passed!` — **137 passed, 0 failed** |
| `flutter test test/features/pet/presentation/pet_design_fidelity_test.dart --reporter compact` | `00:06 +8: All tests passed!` — **8 passed, 0 failed** |
| `flutter test --reporter failures-only` (full mobile suite) | `+929: All tests passed!` — **929 passed, 0 failed** |
| `git grep -n "PetHeroGradient" -- mobile` | 2 files only (`pet_hero_gradient.dart`, `pet_hero_card.dart`) — confirms the single-consumer claim in §4 |

### New fidelity test coverage (`pet_design_fidelity_test.dart`)

1. Hero carries the 178deg gradient, `colorLine` hairline border, and `elevationShadow`.
2. Pet name renders in Nunito / w900 / 34.
3. Level pill uses the translucent light fill + matching hairline border + w800 UI font.
4. Reaction tiles tint in order `[colorSurface, mint@14%, amber@14%, peach@14%]`.
5. Reactions title is uppercase, muted, w700, `letterSpacing ≈ 0.65`.
6. Stat value is Nunito / w900 / 19 and the tile `Column` is center-aligned.
7. Primary CTA has `glowShadow`; secondary CTA glyph is `colorAccentPink` and has no glow.
8. Screen scroll padding is exactly `EdgeInsets.fromLTRB(16, 8, 16, 32)`.

Plus the updated `pet_engagement_test.dart` assertions: `FractionallySizedBox.widthFactor`
≈ 0.26 with a `26%` readout, `gradientDream` fill, and `colorSurfaceAlt` track.
