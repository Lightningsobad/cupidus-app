# Visual Fidelity Report: STORY-011 Invite / Create Pairing Code

Story: REQ-002 / STORY-011_invite_code_design_fidelity
Screen: `invite` (tạo mã), NO_CHROME:no / NO_TABS:yes
Configuration audited: dark theme + `vi` locale (the enabled combination)
Implementation file:
`mobile/lib/features/pairing/presentation/screens/invite_screen.dart`

## Design Source

Locked reference: `cupid-app-design-system`.

- Screen markup: `cupid-app-design-system/project/Cupid Screens.dc.html`,
  `<sc-if value="{{ isInvite }}">` block, lines 168-178.
- Token definitions: same file, lines 23-27 (`[data-plat]`,
  `[data-plat="md"]`, `body[data-theme="dark"]`).
- Header title binding: same file, line 2115 (`title: L['t_' + sc]`) resolving
  to `t_invite` at line 1764 (`'Ghép đôi'`) / line 1776 (`'Pair up'`).

Supporting (already-derived) spec, used only to resolve intent where the raw
markup and the frozen backend contract disagree:
`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-005_pairing/ux/uiux-spec.md`
§3 — "card shows the code (mono, large, gradient-clip text per existing
design), a 'Share invite' pill ... and a secondary copy-to-clipboard icon
button".

Per §1 of that spec and plan §1 D2, the design source's couple-type picker
and "Continue → Fingerprint Vow" CTA (source lines 179-199) are deliberately
excluded from this screen and were **not** added by this story — they are
separate product scope, not a fidelity deviation.

## Deviations Found And Fixed

| # | Design source | Before | After |
|---|---|---|---|
| D1 | Content sits in a card: `background:var(--surf); border-radius:var(--r-card); padding:22px 20px; box-shadow:var(--shadow)` | No card at all — bare text/buttons directly on `--bg` | `DecoratedBox` with `colors.colorSurface`, `context.cupidPlatform.radiusCard`, `context.cupidPlatform.elevationShadow`, `EdgeInsets.symmetric(horizontal: 20, vertical: 22)` |
| D2 | Visible label above the code: `font-size:12.5px; color:var(--tx2)` — "Mã ghép đôi của bạn" | String existed only as an invisible `Semantics(label:)`; nothing rendered | Visible `Text` at 12.5px / `colorTextMuted`; redundant `Semantics` wrapper dropped so the code is announced once, after its now-visible label |
| D3 | Code type: `font-family:'Roboto Mono'; font-weight:500; font-size:36px; letter-spacing:.16em` | `labelMono` at `fontSize: 40`, default weight 400, no letter-spacing | `type.labelMono.copyWith(fontSize: 36, fontWeight: FontWeight.w500, letterSpacing: 36 * 0.16)` |
| D4 | Code fill: `linear-gradient(95deg,var(--pink),var(--purple))` clipped to the text | Flat `colors.colorText` | `ShaderMask(blendMode: BlendMode.srcIn)` with a 95deg `LinearGradient` from `colorAccentPink` to `colorAccentPurple`, using the same CSS-angle → `Alignment` convention `CupidColorTokens` uses for its 120deg gradients |
| D5 | Code block margins: `margin:10px 0 4px` | `CupidSpacing.sm` (8) above and below | `SizedBox(height: 10)` above, `CupidSpacing.xs` (4) below |
| D6 | Sub-caption line: `font-size:11.5px; color:var(--tx2)` | `caption` role at its default 13px | Shared `cardCaption` style at 11.5px / `colorTextMuted`, applied to both the "Mã 6 ký tự" line and the expiry countdown |
| D7 | Actions are a **row**: `display:flex; gap:9px; margin-top:18px` | Two full-width actions stacked vertically with `CupidSpacing.xl` (32) then `CupidSpacing.sm` (8) between them | `Row` with `Expanded` share button + `SizedBox(width: 9)` + fixed copy button, `SizedBox(height: 18)` above |
| D8 | Share CTA: `height:48px; border-radius:var(--r-btn); background:var(--grad-hot); box-shadow:var(--glow); font-size:15px; font-weight:700`, with an `ios_share` icon at 19px and an 8px gap | `CupidPrimaryButton` — flat `colorAccentPink`, Material 20dp radius, no glow, no icon, `body` type at 17px/w400 | `_ShareInviteButton`: gradient `colors.gradientHot`, `radiusButton` (pill), `colors.glowShadow`, 48 high, `CupidIcon(ios_share, size: 19)` + `CupidSpacing.sm` gap + 15px/w700 label |
| D9 | Copy action: **icon-only** `48x48; border-radius:var(--r-btn); border:1.5px solid var(--line)`, `content_copy` glyph at 19px in `var(--tx2)` | Full-width `OutlinedButton` with the visible text label "Sao chép mã" | `_CopyCodeButton`: 48x48, pill radius, `Border.all(color: colors.colorLine, width: 1.5)`, `CupidIcon(content_copy, size: 19, color: colorTextMuted)`; the label survives as the `Tooltip`/semantics text so the action stays screen-reader accessible |
| D10 | Screen padding: `padding:18px 20px 40px`, content anchored to the top of the content area | `EdgeInsets.all(CupidSpacing.lg)` (24) inside a vertically-centering `Center` | `EdgeInsets.fromLTRB(20, 18, 20, 40)` on the `SingleChildScrollView`; `Center` removed so the card sits at the top like the source |
| D11 | Header title for `invite` resolves to `t_invite` = "Ghép đôi" / "Pair up" | "Mời ghép đôi" / "Invite" | "Ghép đôi" / "Pair up" |

## Token Mapping Used

| Design source var | Flutter token |
|---|---|
| `--surf` | `CupidColorTokens.colorSurface` |
| `--tx2` | `CupidColorTokens.colorTextMuted` |
| `--line` | `CupidColorTokens.colorLine` |
| `--pink` / `--purple` | `colorAccentPink` / `colorAccentPurple` |
| `--grad-hot` | `CupidColorTokens.gradientHot` |
| `--glow` | `CupidColorTokens.glowShadow` |
| `--shadow` | `CupidPlatformTokens.elevationShadow` |
| `--r-card` | `CupidPlatformTokens.radiusCard` |
| `--r-btn` | `CupidPlatformTokens.radiusButton` |
| `--bg` | `CupidColorTokens.colorBackground` (already correct before this story) |

Because these are shared theme tokens rather than per-theme literals, the
fixes stay correct in the light/`en` combinations that OQ5 leaves out of
user-facing scope.

## Deliberate Non-Changes

- **"Mã 6 ký tự" / "6-character code" kept.** It is absent from the raw
  markup, but STORY-005 §3's "Code-format correction needed" explicitly
  requires it in place of the mockup's "8-character code" copy, because the
  backend emits a 6-char hex code. Removing it would regress an earlier
  accepted correction.
- **Expiry copy kept as a live countdown** ("Hết hạn sau 23h 40m") rather
  than the mockup's hardcoded "Hết hạn sau 15 phút" — same §3 correction, 24h
  backend TTL.
- **Loading and error states left as-is.** The design source defines no
  `invite` loading or failure state, so there is nothing to compare them
  against; `_InviteError` was not restyled.
- **Couple-type picker and "Continue → Fingerprint Vow" CTA not added** (see
  Design Source section above).
- **Pairing/invite business logic untouched** — code generation, clipboard
  payloads, `SemanticsService` announcements, and the advance-to-`waiting`
  navigation are byte-for-byte unchanged, per this story's out-of-scope line.

## Known Approximations

1. **Share CTA foreground.** The source specifies `color:#fff` on the
   gradient pill. The design system has no pure-white token; `colorText` is
   used, matching the existing `CupidPrimaryButton` precedent. In the audited
   dark theme this is `#F7EEFB`.
2. **Icon constants are local to the screen file.** `ios_share` (0xe6b8) and
   `content_copy` (0xe14d) are not yet members of `CupidIcons`, and
   `mobile/lib/design_system/` is outside this story's write scope, so they
   are declared as private constants in `invite_screen.dart` using
   `CupidIcons.fontFamily` (no second icon family is introduced, ADR-004d
   holds). Both codepoints were read from the bundled
   `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap with
   `fontTools`, not recalled from memory. **Follow-up:** promote them to
   `CupidIcons` in a story whose write scope includes `design_system/`.
3. **Card/spacing literals.** 9/10/18/20/22/40 and the 12.5/11.5px caption
   sizes have no `CupidSpacing` or typography-token equivalent, so they are
   transcribed verbatim into named private constants at the top of the screen
   file, following the `_materialPrimaryCtaRadius` precedent inside the
   design system itself.
4. CSS `letter-spacing` adds trailing space after the final character, which
   nudges centering by ~2.9px versus Flutter's `letterSpacing`. Not
   compensated for; below the visible-deviation threshold.

## Verification

All commands run in the story worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-011/mobile`.

- `flutter analyze lib/features/pairing/presentation/screens/invite_screen.dart test/features/pairing/presentation/invite_screen_test.dart`
  → 3 issues, all pre-existing `prefer_initializing_formals` infos on the
  untouched cubit-factory constructors. No errors, no warnings, nothing new.
- `flutter test test/features/pairing/presentation/invite_screen_test.dart test/design_system/no_fork_guard_test.dart`
  → `+8: All tests passed!` (7 invite screen tests + the AC-4 no-fork guard).
- `flutter test test/features/pairing test/design_system/no_fork_guard_test.dart`
  → `+71: All tests passed!` (full pairing feature regression).
- `dart format` applied to both changed files.

`flutter gen-l10n` was run once to materialize
`lib/l10n/generated/app_l10n.dart`, which is generated (not committed) and
was missing in a fresh worktree; without it `pair_gate_cubit_test.dart` does
not compile. That is a pre-existing worktree bootstrap step, not a change
made by this story.

### Test coverage added

`mobile/test/features/pairing/presentation/invite_screen_test.dart` gains
`the code card matches the design source treatment`, which asserts the card's
surface color / `radiusCard` / `elevationShadow`, the `ShaderMask` over the
code, the Roboto Mono 36px w500 `0.16em` code style, and that the copy action
is a 48x48 icon-only control rather than a labelled `OutlinedButton`.

Two existing tests moved from `find.text('Copy code')` to
`find.byTooltip('Copy code')` because the copy button is now icon-only by
design.

## Acceptance Criteria Status

| AC | Status | Evidence |
|---|---|---|
| 1 — layout, spacing, color/token, typography match in dark + `vi` | MET | D1-D11 all corrected against the source markup; token mapping table above |
| 2 — deviations corrected in the app, not just documented | MET | All eleven fixes landed in `invite_screen.dart`; re-verified by the new widget test |
| 3 — code display/share component matches, incl. mono treatment | MET | D3/D4/D8/D9: Roboto Mono w500 36px `.16em` with the 95deg pink→purple clip; gradient share pill with glow; icon-only outlined copy button |
| 4 — no new entry point required | MET | Navigation, routing, and the `waiting` advance are unchanged |
