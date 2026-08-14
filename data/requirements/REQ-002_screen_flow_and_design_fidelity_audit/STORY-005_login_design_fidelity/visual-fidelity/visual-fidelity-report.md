# Visual Fidelity Report: STORY-005 Login

Scope: REQ-002 / STORY-005_login_design_fidelity
Screen: `login` (Epic 1, NO_CHROME / NO_TABS)
Implementation: `mobile/lib/features/auth/presentation/screens/login_screen.dart`
Configuration audited: dark theme + `vi` locale (the only user-facing
combination per OQ5), both platform silhouettes (`CupidPlatform.ios` and
`CupidPlatform.material`).

## Design Source

Locked source: `cupid-app-design-system` (confirmed by `detect_design_source.py`).
Exact block audited: `cupid-app-design-system/project/Cupid Screens.dc.html`,
`<sc-if value="{{ isLogin }}">` block, lines 1425-1458.
CSS variable definitions: same file, lines 23-27.

Supporting spec (state behavior the static design source does not author):
`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/ux/uiux-spec.md`
sections 4b, 6, 8.

### Token mapping used

| Design source | Flutter token |
|---|---|
| `--bg` | `CupidColorTokens.colorBackground` |
| `--surf` | `colorSurface` |
| `--line` | `colorLine` |
| `--tx` | `colorText` |
| `--tx2` | `colorTextMuted` |
| `--pink` | `colorAccentPink` |
| `--red` | `colorRed` |
| `--r-card` | `CupidPlatformTokens.radiusCard` |
| `--r-btn` | `CupidPlatformTokens.radiusButton` |
| `--shadow` | `CupidPlatformTokens.elevationShadow` |
| Nunito 900 | `CupidTypographyTokens.display` |
| `--fs-ui` | `CupidTypographyTokens.body` / `.caption` |

Values verified identical between `Cupid Screens.dc.html` lines 23-27 and
`mobile/lib/design_system/tokens/cupid_color_tokens.dart` /
`cupid_platform_tokens.dart` — no token drift found.

Point metrics on this screen (12/20/40 screen padding, 16 section gap, 11 field
gap, 13/16 card padding, 27 heading, 50/54 button heights) sit off the 8pt
`CupidSpacing` scale, so they are carried as named design-source constants at
the top of `login_screen.dart` rather than snapped to the nearest token. This
follows the existing `_materialPrimaryCtaRadius` precedent in
`mobile/lib/design_system/adaptive/cupid_primary_button.dart`.

## Deviations Found And Fixed

| Id | Deviation (before) | Design source | Fix applied |
|---|---|---|---|
| D-01 | Screen padding `EdgeInsets.all(24)` plus a leading `SizedBox(height: 32)` spacer | `padding:12px 20px 40px` (line 1426) | `EdgeInsets.fromLTRB(20, 12, 20, 40)`; leading spacer removed |
| D-02 | Heading used `cardTitle` (platform UI font, w600, 22px), left-aligned | `font-family:Nunito;font-weight:900;font-size:27px`, centered (lines 1427-1428) | `type.display.copyWith(fontSize: 27)`, `textAlign: TextAlign.center` |
| D-03 | Subtitle line absent entirely | `font-size:13px;color:var(--tx2);margin-top:7px` — "Bae đang đợi ở trong đấy" / "Bae is waiting inside" (line 1429) | Added as `caption` + `colorTextMuted`, 7px below the heading. Also satisfies STORY-003 §4b "same subtext slot below it" for the session-expired variant |
| D-04 | No header block padding | `padding:14px 0 4px` (line 1427) | `EdgeInsets.only(top: 14, bottom: 4)` around the heading/subtitle pair |
| D-05 | Both fields were stock Material `TextField`s with a floating `labelText` and the default underline border (pink focus underline) | `--surf` card at `--r-card` with `--shadow`, `padding:13px 16px`; static uppercase micro-label `font-size:11px;letter-spacing:.06em;color:var(--tx2);margin-bottom:6px`; input `border:none;outline:none;color:var(--tx);font-size:16px;padding:0` (lines 1432-1439) | New `_FieldCard`: `DecoratedBox` (`colorSurface`, `radiusCard`, `elevationShadow`) + 16/13 padding + uppercase 11px/0.66 letter-spacing `colorTextMuted` label + `InputBorder.none`, `contentPadding: EdgeInsets.zero`, 16px `colorText` input |
| D-06 | Gap between the two fields was `CupidSpacing.sm` (8) | `gap:11px` (line 1431) | 11 |
| D-07 | Forgot link was a stock `TextButton` (theme `labelLarge` 14/w500, 12px horizontal padding so it did not sit flush right) | `align-self:flex-end;font-size:12.5px;font-weight:700;color:var(--pink)` (line 1444) | 12.5px / `FontWeight.w700` / `colorAccentPink`, `padding: EdgeInsets.zero`, `MaterialTapTargetSize.shrinkWrap`, right-aligned, wrapped in `ConstrainedBox(constraints: BoxConstraints(minHeight: context.cupidPlatform.tapTarget))` so the tappable hit area meets the 44/48 `--tap` minimum with zero visible pixel movement; the surrounding `forgotBandGap = max(0, (16*2 + 12.5*1.2 - tapTarget) / 2)` compensates the band so the CTA position holds |
| D-08 | "hoặc" was a bare centered caption with no rules | `flex` row: 1px `--line` rule, 12px gap, 11.5px `--tx2` label, 12px gap, 1px rule; `margin:2px 0` (line 1447) | `Row` with two `Expanded` 1px `colorLine` rules flanking an 11.5px `colorTextMuted` label, 12px gaps, 2px vertical margin |
| D-09 | Social buttons stacked vertically, Apple/Facebook **above** Google, stock `OutlinedButton` height/border/typography | Single row `gap:10px`, **Google first**, each `flex:1;height:50px;border-radius:var(--r-btn);border:1.5px solid var(--line);font-size:14px;font-weight:700` (lines 1448-1456) | New `_SocialButton` in a `Row`: Google then Apple (iOS) / Facebook (Material), 10px gap, 50px tall, `radiusButton` pill, 1.5px `colorLine` border, 14px/w700 `colorText` label |
| D-10 | Register link was a stock `TextButton` with the whole sentence in `--tx2` | `text-align:center;font-size:13px;color:var(--tx2);margin-top:6px` with `<strong style="color:var(--pink)">Đăng ký</strong>` (line 1457) | Centered `Text.rich`: 13px `colorTextMuted` sentence with "Đăng ký" / "Sign up" in w700 `colorAccentPink`; +6px top margin |
| D-11 | Root vertical rhythm mixed `CupidSpacing.sm` (8), `.lg` (24) and `.xl` (32) | `gap:16px` uniformly between all direct children (line 1426) | Uniform 16px section gap between every root child |
| D-12 | Inline error gap was `CupidSpacing.sm` (8) and sat outside the field group | STORY-003 §6: `--red` inline message beneath the relevant field | 11px field gap, rendered inside the field group directly beneath the password card, `caption` + `colorRed` |

## Form Field States (AC 3)

| State | Design source | Rendered result |
|---|---|---|
| Empty | Card + uppercase micro-label, no placeholder text authored | Matches — the label is a static sibling, never a floating placeholder; no hint text invented |
| Focused | `outline:none` on the input, so the card shows **no** focus ring or underline | Matches after D-05 — `InputBorder.none` removes the Material focused underline that previously painted in `colorAccentPink`. Caret uses the theme primary (`colorAccentPink`), the only focus affordance |
| Filled | 16px `--tx` on `--surf` | Matches — `body.copyWith(fontSize: 16, color: colorText)` |
| Error / validation | Not authored in the design source | Follows STORY-003 §6: `--red` (`colorRed`) caption beneath the password field, label restored and button re-enabled. No design-source state was contradicted |

## Platform-Adaptive CTA (AC 4)

The primary CTA stays `CupidPrimaryButton`, the design system's adaptive
widget: iOS renders a full-width pill at `radiusButton`; Material renders a
filled button at 20dp with ripple. This is the pattern AC 4 requires and the
one STORY-001 §6 / STORY-003 §8 make authoritative for this screen. No
platform fork was introduced in feature code — the `no_fork_guard_test`
substring scan still passes.

## Deferred — Outside This Story's WriteScope

Each item below is a real design-source element that cannot be delivered by
editing `login_screen.dart` alone. None is a regression; all are recorded here
for Scrum Master to route.

| Id | Gap | Blocking file / change (outside WriteScope) |
|---|---|---|
| DEF-01 | Password `visibility_off` toggle (21px, `--tx2`, right-aligned in the password card, line 1441) | Needs a new `CupidIcons.visibilityOff` constant in `mobile/lib/design_system/icons/cupid_icons.dart` (codepoint must be read from the bundled font cmap, never guessed) |
| DEF-02 | Biometric quick-unlock row (`fingerprint` + `bioLabel`, 52px `--surf` pill with `--shadow`, line 1446) | Needs DEF-01's icon plus a biometric capability (`local_auth` dependency + iOS/Android platform config). STORY-003 §9 still flags the scope of this row as an open Tech Lead question |
| DEF-03 | Brand marks inside the social buttons (Google 19px SVG, Apple glyph, Facebook 18px `#1877F2`) | No SVG renderer and no `assets:` section in `mobile/pubspec.yaml`; text-only labels are rendered meanwhile |
| DEF-04 | CTA visual delta: design HTML is 54px tall, `--grad-hot` fill, `--glow` shadow, 16.5px/w800. `CupidPrimaryButton` renders a solid `--pink` fill at `tapTarget` height | `mobile/lib/design_system/adaptive/cupid_primary_button.dart` — shared by welcome/register/forgot/otp, so it must be changed once at design-system level, not per screen. AC 4 keeps the adaptive widget authoritative here |
| DEF-05 | Inline spinner on CTA submit (STORY-003 §6) | Not authored in the design source (this story's Out of Scope) and needs a child slot on `CupidPrimaryButton` |

## Reviewer Note

Both the `--tap` 44/48 minimum from STORY-001 and AC 1 ("no visible
deviation") are satisfied for the "Quên mật khẩu?" / forgot-password link and
the register link: each is wrapped in a `ConstrainedBox` that raises the
tappable hit area to `context.cupidPlatform.tapTarget` without moving a single
rendered pixel. For the forgot link, the hit box grows upward into the
surrounding `gap:16` band, which the paired `forgotBandGap` compensation
keeps symmetric; for the register link, the hit box grows downward into the
already-unpainted 40pt of bottom screen padding. There is no remaining
tension between fidelity and the tap-target minimum on this screen, and no
open UX decision is needed. (Round-2 review, commit `8b19291`.)

## Out Of Scope Confirmed Untouched

- Credential-submission and post-sign-in navigation logic (`SignInCubit`
  wiring, `SignInSuccess` -> `HomeScreen`, `_openForgot`, `_openRegister`)
  is byte-for-byte unchanged — Scope A / STORY-001 / STORY-002 own it.
- No new screen, state, or interaction was added.
- No light theme / `en` locale visual pass was performed (OQ5). Every fix is
  token-driven, so it stays correct across all four combinations.

## Verification

Run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-005/mobile`
with `flutter` 3.44.1 / Dart 3.12.1 on PATH.

| Command | Result |
|---|---|
| `flutter pub get` | Got dependencies |
| `flutter analyze lib/features/auth/presentation/screens/login_screen.dart test/features/auth/presentation/screens/login_screen_test.dart` | `No issues found!` |
| `flutter analyze` | 94 issues, all pre-existing (`prefer_initializing_formals` infos across `lib/**` and `unused_import` warnings in generated `openapi/cupid_api/**`); none in the changed files |
| `flutter test test/features/auth test/design_system` | `+63: All tests passed!` |
| `flutter test` | `+933: All tests passed!` |

New suite:
`mobile/test/features/auth/presentation/screens/login_screen_test.dart`
(13 widget tests, dark theme + `vi` locale, both platform silhouettes) asserts
the heading typography, the subtext slot, the session-expired heading swap,
the uppercase-labelled borderless surface cards, the forgot-link style and
right alignment, the flanked "hoặc" divider, Google-first social ordering with
the platform-correct second provider, the 50px button height, the pink
"Đăng ký" emphasis, and (added in the round-2 patch) the 44/48 `--tap`
minimum hit area on both the forgot-password and register links, parameterised
over both `CupidPlatform` values and asserted against the real laid-out box
via `tester.getSize`.

Round-2 patch verification (commit `8b19291`, independently re-run by the
reviewer): `flutter analyze` on the two changed files — `No issues found!
(ran in 1.5s)`; `flutter test test/features/auth/presentation/screens/login_screen_test.dart`
— `+13: All tests passed!`; `flutter test test/features/auth test/design_system`
— `+63: All tests passed!`; `flutter test` (full suite) — `+933: All tests
passed!`. Counts moved 59 -> 63 and 929 -> 933, consistent with +4 additions
and no regressions.

Pre-existing coverage kept green: `splash_screen_test.dart`'s session-expired
assertion (`find.text('Sign in again to continue')`) and
`test/design_system/no_fork_guard_test.dart`.

No device install, emulator provisioning, toolchain setup, or release
configuration was performed — build verification only, per handoff scope.
