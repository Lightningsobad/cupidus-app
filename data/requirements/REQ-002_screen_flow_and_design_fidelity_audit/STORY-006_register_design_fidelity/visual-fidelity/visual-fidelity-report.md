# Visual Fidelity Report — STORY-006 Register

Story: STORY-006 Design Fidelity — Register
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Lane: mobile
Screen: `register` (chromeless, `NO_TABS`)
Configuration audited: dark theme, `vi` locale, Material platform silhouette

## Design Source

Locked reference: `cupid-app-design-system`
Authoritative markup:
`cupid-app-design-system/project/Cupid Screens.dc.html`, `isRegister` block,
lines 1461-1492.
CSS custom-property definitions: same file, lines 23-27.

Token mapping verified line-by-line against the app's token layer — the design
source's CSS variables and `CupidColorTokens.dark()` /
`CupidPlatformTokens.material()` are value-identical:

| Design var | App token |
| --- | --- |
| `--bg` `#171129` | `colorBackground` |
| `--surf` `#241B42` | `colorSurface` |
| `--line` `rgba(247,238,251,.11)` | `colorLine` |
| `--tx` `#F7EEFB` | `colorText` |
| `--tx2` `#B4A6CE` | `colorTextMuted` |
| `--pink` `#FF7FB6` | `colorAccentPink` |
| `--mint` `#79E2CD` | `colorMint` |
| `--grad-hot` | `gradientHot` |
| `--shadow` | `CupidPlatformTokens.elevationShadow` |
| `--r-card` `24px` (md) | `radiusCard` |
| `--fs-ui` `Roboto` (md) | `uiFontFamily` |

## Files Changed

- `mobile/lib/features/auth/presentation/screens/register_screen.dart`
- `mobile/test/features/auth/presentation/screens/register_screen_test.dart`
  (new)

## Deviations Found And Fixed

### D1 — Title used the wrong typographic role (AC1)

- Design (line 1464): `font-family:Nunito; font-weight:900; font-size:26px;
  line-height:1.25`.
- Before: `context.cupidType.cardTitle` → Roboto, `w600`, 22px. Wrong family,
  wrong weight, wrong size.
- After: `type.display.copyWith(fontSize: 26, height: 1.25)`. `display` is the
  Nunito/`w900` token role; only the size is overridden, following the existing
  `labelMono.copyWith(fontSize: 28, ...)` precedent in `joincode_screen.dart`.

### D2 — Subtitle line missing entirely (AC1)

- Design (line 1465): 13px, `--tx2`, `margin-top:7px` —
  `Một người tạo, người kia ghép vào sau bằng mã.` /
  `One of you signs up, the other joins with a code.`
- Before: absent.
- After: rendered as `caption.copyWith(fontSize: 13, color: colorTextMuted)`
  with a 7px gap below the title.

### D3 — Fields rendered as stock Material inputs, not design surface cards (AC1, AC3)

This was the largest deviation on the screen.

- Design (lines 1467-1477): each field is a card —
  `background:var(--surf); border-radius:var(--r-card); padding:13px 16px;
  box-shadow:var(--shadow)` — containing an uppercase micro-label
  (`font-size:11px; letter-spacing:.06em; text-transform:uppercase;
  color:var(--tx2); margin-bottom:6px`) above a borderless 16px `--tx` input
  (`border:none; background:transparent; padding:0`).
- Before: bare `TextField` + `InputDecoration(labelText:)`. `buildCupidTheme`
  registers no `InputDecorationTheme`, so these rendered as default Material 3
  filled inputs: `surfaceContainerHighest` fill (not `--surf`), an underline
  border the design has no equivalent for, a floating animated label instead of
  a static uppercase micro-label, and body-size label text.
- After: new private `_FieldCard` widget reproducing the design card exactly —
  `colorSurface` fill, `radiusCard`, `elevationShadow`, 13x16 padding,
  `label.toUpperCase()` at 11px with `.06em` tracking in `colorTextMuted`, 6px
  gap, then a collapsed borderless `TextField` at 16px in `colorText`.

### D4 — Password strength meter missing (AC1, AC3, In-Scope item 3)

- Design (lines 1478-1484): 4 segments, `display:flex; gap:5px;
  margin-top:11px`, each `flex:1; height:5px; border-radius:3px`; 3 filled
  `--mint`, 1 `--line`; then an 11px `--mint` `font-weight:600` caption
  `Mạnh — Bae có đoán cũng chịu` at `margin-top:7px`.
- Before: absent.
- After: `_PasswordStrengthMeter` renders the 4-segment bar live from the typed
  password with the design's exact geometry and `colorMint`/`colorLine` fills.
  The design source's own sample password `loveyou247` scores 3/4 and shows the
  `Mạnh` caption, reproducing the rendered design state exactly (covered by a
  widget test).
  Design-source gap: the source specifies **only** the 3/4 "strong" state — no
  weak/medium copy or color exists. No copy or color was invented; the caption
  is simply withheld below the threshold.

### D5 — Terms/privacy consent row missing (AC1)

- Design (lines 1486-1489): `display:flex; gap:11px; align-items:flex-start;
  padding:2px 2px 0`; a 24x24 checkbox at `border-radius:9px` filled with
  `--grad-hot` holding a 16px white `check` glyph; beside it 12px
  `line-height:1.5` `--tx2` text with `Điều khoản` / `Chính sách riêng tư`
  links.
- Before: absent.
- After: `_TermsConsentRow` with the exact geometry, `gradientHot` fill, and
  `CupidIcons.check` at 16px. White is taken from `colorText` rather than a
  literal, matching how `CupidPrimaryButton` already resolves the design's
  `color:#fff`-on-gradient case.
  Unchecked state is not in the design source; it reuses the design source's own
  empty-input treatment from the adjacent OTP screen (line 1505:
  `background:var(--surf); border:1.5px solid var(--line)`) rather than an
  invented style.
  Scope note: the checkbox toggles its own visual state only. It deliberately
  does **not** gate the create-account CTA — submission behavior is out of
  bounds for this story per the handoff. Whether consent should block
  submission is a product decision for a follow-up story.

### D6 — Footer link styling (AC1)

- Design (line 1491): centered 13px `--tx2` sentence with the trailing
  `Đăng nhập` as a `--pink` `<strong>` segment.
- Before: a plain `TextButton` whose whole label rendered at Material's default
  primary color and body size, with Material button padding.
- After: `Text.rich` inside a centered `TextButton` — leading text in
  `colorTextMuted` at 13px, `Đăng nhập` in `colorAccentPink` at `w700`. The
  `TextButton` is retained for the tap target and disabled-while-busy behavior;
  its `onPressed` navigation is unchanged.

### D7 — Field label copy (AC1)

- Design (line 1468): `Tên gọi` / `Display name`.
- Before: `Tên hiển thị` / `Display name`.
- After: `Tên gọi`, matching the locked source. English copy was already
  correct.

### D8 — Screen padding and inter-element rhythm (AC1)

- Design (line 1462): container `padding:12px 20px 40px`, column `gap:14px`;
  header block `padding:6px 0`.
- Before: `EdgeInsets.all(24)` plus an extra leading `SizedBox(height: 32)`, and
  a mix of 8px/24px gaps that matched no design value.
- After: `EdgeInsets.fromLTRB(20, 12, 20, 40)`, a uniform 14px `_sectionGap`
  between every column child, and a 6px-vertical header block.
  Rationale for verbatim values: the design's 12/20/40/14/13/11/6 values sit off
  the `CupidSpacing` 8pt grid and have no token equivalent. They are declared as
  named constants with a design-source citation, following the documented
  `_materialPrimaryCtaRadius = 20` precedent in
  `design_system/adaptive/cupid_primary_button.dart` ("transcribed verbatim from
  the design source rather than invented").

## Validation States (AC3)

| State | Design source | App after fix |
| --- | --- | --- |
| Empty | Card with uppercase label, no placeholder (lines 1467-1477) | Same — label always visible, no floating-label animation, no placeholder |
| Filled | 16px `--tx` value on `--surf` card | Same |
| Focused | Not specified for the register cards. The same design source's active-input treatment is `border:1.5px solid var(--pink)` (line 1501) vs. inactive `var(--line)` (line 1505) | 1.5px `colorAccentPink` ring on the focused card; unfocused the 1.5px border is drawn in `colorSurface`, so no outline is visible and the card never changes size. Cited transcription, not invention. Also restores a focus affordance that was previously supplied only by the stock Material underline |
| Password strength | 3/4 mint segments + `Mạnh` caption (lines 1478-1484) | Reproduced exactly for the design's own sample value; see D4 |
| Error (e.g. duplicate account) | **No error styling exists anywhere in the design source** — no `--red` border and no `--red` text rule was found in `Cupid Screens.dc.html` | Existing token-driven treatment retained unchanged: `caption` in `colorRed` below the password card. No styling invented |

## Deviations Not Fixed (out of this story's write scope)

### N1 — Primary CTA visual treatment

- Design (line 1490): `height:54px; background:var(--grad-hot); color:#fff;
  font-size:16.5px; font-weight:800; box-shadow:var(--glow);
  border-radius:var(--r-btn)`.
- App: `CupidPrimaryButton` renders a solid `colorAccentPink` fill at
  `tapTarget` height (48 on Material), `body` type (17/`w400`), a 20dp radius,
  and no `glowShadow`.
- Not fixed here: `mobile/lib/design_system/adaptive/cupid_primary_button.dart`
  is outside this story's declared `WriteScope`, and the widget is shared by
  every screen in the app. Its current shape is also a deliberate
  `ux/uiux-spec.md` section 6 adaptation ("Filled button, 20dp corner radius"),
  so changing it is a design-system-level decision, not a register-screen fix.
- Recommendation: raise a design-system story to reconcile
  `CupidPrimaryButton` with `--grad-hot` / `--glow` / 54px, which will correct
  this on every screen at once.

### N2 — Screen background gradient (`--sky`)

The design source paints a 3-layer radial `--sky` gradient behind screen
content. `CupidColorTokens.skyGradient` carries the verbatim CSS string but no
screen paints it; the token's own dartdoc defers the rendering approach to "the
story that first paints this decoration". App-shell scope, not register scope.

### N3 — Screen header / back affordance

The design source excludes `register` from `NO_CHROME` (line 1951) and sets
`BACK_TO.register = 'welcome'` (line 1853), so the design screen carries a
header with a back control. `story_master.md` classifies this screen as
`NO_CHROME / NO_TABS`, and the handoff puts inter-screen navigation in Scope A.
Flagged for STORY-001 / STORY-002; deliberately not changed here.

## Verification

Run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-006/mobile`
with Flutter 3.44.1 / Dart 3.12.1.

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/auth/presentation/screens/register_screen.dart` | No issues found |
| `flutter analyze lib/features/auth test/features/auth` | 3 issues, all pre-existing `prefer_initializing_formals` infos in `auth_repository.dart` / `splash_screen.dart`; none in the changed files |
| `flutter test test/features/auth/presentation/screens/register_screen_test.dart` | 5 tests, all passed |
| `flutter test test/design_system test/features/auth` | 55 tests, all passed (includes the AC4 no-fork guard and the full auth suite — no regression) |

Note: bare `flutter analyze` at the package root also walks
`build/ios/SourcePackages/checkouts/flutterfire/**`, a pre-existing vendor
checkout that fails to resolve. That is unrelated to this story; the runs above
are scoped to `lib` / `test`.

### Test coverage added

`mobile/test/features/auth/presentation/screens/register_screen_test.dart`
asserts, in dark theme + `vi`:

1. Title renders Nunito / `w900` / 26px and the subtitle line is present.
2. All three fields render as `colorSurface` cards at `radiusCard` with
   `elevationShadow`, labelled `TÊN GỌI` / `EMAIL` / `MẬT KHẨU`.
3. Focusing a field paints the `colorAccentPink` ring; unfocused it is absent.
4. The design source's sample password `loveyou247` fills exactly 3 of 4
   segments in `colorMint` and shows the `Mạnh — Bae có đoán cũng chịu` caption.
5. The consent box renders with `gradientHot` and the check glyph, and toggles
   to the outlined empty state.

## Acceptance Criteria Status

- AC1 (layout / spacing / token / typography match): MET for register-screen
  code. Two residual deviations are documented as N1 and N2, both owned by the
  design-system / app-shell layer outside this story's write scope.
- AC2 (deviations corrected in the app, not merely documented): MET — D1-D8 are
  code fixes.
- AC3 (validation-state fidelity): MET — see the validation-states table. The
  design source specifies no error styling, so the existing token-driven error
  treatment was retained rather than invented.
- AC4 (no new entry point): MET — navigation into and out of this screen is
  unchanged.
