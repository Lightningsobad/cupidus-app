# STORY-004 — Welcome Screen Visual Fidelity Report

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-004_welcome_design_fidelity
- Screen: `welcome`
- Lane: mobile
- Audited target: `mobile/lib/features/auth/presentation/screens/welcome_screen.dart`
- Design source of truth: `cupid-app-design-system/project/Cupid Screens.dc.html`,
  `<sc-if value="{{ isWelcome }}">` block (lines 68–91)
- Audit conditions: dark theme, `vi` locale (per AC1)
- Outcome: 11 deviations found and corrected in code; 2 deviations documented
  as deferred (blocked by story WriteScope)

## Method

The design source is the HTML/CSS prototype bundle, not a static image, so each
declared CSS property in the `isWelcome` block was read literally and compared
against the rendered Flutter widget tree. Every corrected value below is
transcribed from the CSS, then expressed through the design-system token
contract (`CupidColorTokens`, `CupidPlatformTokens`, `CupidTypographyTokens`)
rather than as a raw literal, because `mobile/test/design_system/no_fork_guard_test.dart`
forbids raw color literals and platform branches inside `lib/features`.

## Corrected deviations

### D1 — Background gradient direction and stop order

- Design source: `background:linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,#FF3366 100%)`
  — a near-vertical sweep, purple at the top running into pink/red at the bottom.
- Was: `colors.gradientHot` applied with the token's own `120deg` alignments, so
  the sweep ran diagonally and in the opposite hue order.
- Now: the `165deg` sweep is expressed in the same `(-sin θ, cos θ)` /
  `(sin θ, -cos θ)` form the token file uses, as `_gradient165Begin` /
  `_gradient165End`, and `gradientHot.colors` is reversed so purple sits at the
  top and pink at the bottom.
- Residual: exact stop hexes are deferred — see D13.

### D2 — Content alignment

- Design source: the hero column declares no `align-items`, so its children are
  block-level and left-aligned; `text-align:center` appears only on the legal
  footnote.
- Was: hero content centered.
- Now: hero `Column` uses `crossAxisAlignment: CrossAxisAlignment.start`; no
  `textAlign` on the wordmark, tagline, or sub-copy. Only the footnote keeps
  `textAlign: TextAlign.center`.

### D3 — Screen composition (hero vs. CTA block)

- Design source: two siblings in a `flex-direction:column` page — a `flex:1`
  hero that centers itself in the remaining space, and a CTA block pinned to
  the bottom.
- Was: one single centered column holding both copy and buttons.
- Now: `Column` of `Expanded(child: _WelcomeHero())` (which centers on its main
  axis) plus a bottom-pinned `_WelcomeCtaBlock`.

### D4 — Padding

- Design source: hero `padding:var(--safe-top) 28px 0`; CTA block
  `padding:0 20px calc(var(--safe-bot) + 20px)`.
- Was: uniform `EdgeInsets.all(CupidSpacing.lg)` (24) for the whole screen.
- Now: hero `EdgeInsets.symmetric(horizontal: 28)`, CTA block
  `EdgeInsets.fromLTRB(20, 0, 20, 20)` inside a `SafeArea` (which supplies the
  `--safe-top` / `--safe-bot` equivalent). These values sit off the 8pt
  `CupidSpacing` grid, so they are carried verbatim as named file-local
  constants with a comment recording why they are not snapped to a token.

### D5 — Wordmark metrics

- Design source: `font-family:Nunito;font-weight:900;font-size:60px;line-height:.95;letter-spacing:-.03em;color:#fff`.
- Was: `type.display` at its default 34pt with no line-height or tracking
  override.
- Now: `type.display` (already Nunito w900) with `fontSize: 60`, `height: 0.95`,
  and `letterSpacing: -1.8` (`-.03em` resolved at 60pt).

### D6 — Missing accent rule under the wordmark

- Design source: `width:52px;height:4px;border-radius:2px;background:rgba(255,255,255,.55);margin:18px 0 16px`.
- Was: absent entirely.
- Now: a `DecoratedBox` of `52 × 4` with `BorderRadius.circular(2)` filled at
  `colors.colorText.withValues(alpha: 0.55)`, wrapped in
  `EdgeInsets.only(top: 18, bottom: 16)`.

### D7 — Tagline typography and measure

- Design source: `font-family:Nunito;font-weight:700;font-size:23px;line-height:1.3;color:#fff;max-width:280px`,
  copy `Yêu nghiêm túc.<br>Chia tay đàng hoàng.`
- Was: `type.cardTitle` (UI font, w600, 22pt), centered, unconstrained width.
- Now: `type.display` (the Nunito family) overridden to `w700 / 23 / height 1.3`,
  left-aligned, inside `ConstrainedBox(maxWidth: 280)`, with the explicit line
  break preserved.

### D8 — Missing sub-copy paragraph

- Design source: `font-size:14px;line-height:1.55;color:rgba(255,255,255,.78);margin-top:12px;max-width:270px`,
  copy `App cho hai người. Không có newsfeed, không có người thứ ba.`
- Was: absent entirely.
- Now: `type.body` overridden to `14 / height 1.55` at
  `colorText.withValues(alpha: 0.78)`, inside `ConstrainedBox(maxWidth: 270)`,
  preceded by `SizedBox(height: 12)`.

### D9 — CTA stack structure and styling (AC3)

- Design source: three `height:52px;border-radius:var(--r-btn)` rows in a
  `gap:10px` column, each `font-size:16px;font-weight:600`:
  - Apple — `background:#000;color:#fff`, wrapped in `<sc-if value="{{ isIOS }}">`
  - Google — `background:#fff;color:#1A1A2E;box-shadow:0 2px 10px rgba(0,0,0,.14)`
  - Email — `border:1.5px solid rgba(255,255,255,.5);color:#fff`, no fill
- Was: two identically-styled `CupidPrimaryButton`s plus a bare `TextButton`,
  with no fixed height, no explicit gap, and no per-provider treatment.
- Now: a `crossAxisAlignment: stretch` column of three 52pt rows separated by
  `SizedBox(height: 10)`:
  - Apple: filled `_FilledCta`, dark fill / light label, `elevation: 0`, rendered
    only when `CupidPlatform.of(context) == CupidPlatform.ios`.
  - Google: filled `_FilledCta`, light fill / dark label, `elevation: 2` to
    stand in for the CSS drop shadow.
  - Email: `OutlinedButton` with a `1.5` px side at
    `colorText.withValues(alpha: 0.5)`.
- Pill radius comes from `context.cupidPlatform.radiusButton` (the `--r-btn`
  equivalent, `999` on both platform tokens), so the platform-adaptive button
  treatment is token-driven rather than forked.

### D10 — Missing legal footnote

- Design source: `text-align:center;font-size:11.5px;line-height:1.5;color:rgba(255,255,255,.65);margin-top:6px`,
  copy `Đăng ký nghĩa là bạn chấp nhận bị dỗi khi seen không trả lời.`
- Was: absent entirely.
- Now: `type.caption` overridden to `11.5 / height 1.5` at
  `colorText.withValues(alpha: 0.65)`, centered, after `SizedBox(height: 6)`.

### D11 — Extra CTA not present in the design source

- Design source: defines exactly three CTAs plus the footnote. There is no
  register/sign-up link on `welcome`.
- Was: an additional `Chưa có tài khoản? Đăng ký` `TextButton` pushing
  `RegisterScreen`.
- Now: removed, along with the now-unused `register_screen.dart` import and the
  `_openRegister` helper.
- Navigation impact: none. `RegisterScreen` remains reachable through the login
  screen's own register link (`mobile/lib/features/auth/presentation/screens/login_screen.dart:230`),
  which this story did not touch. No route, no gate, and no entry point into or
  out of `welcome` was modified, satisfying AC4 and the handoff's
  navigation-out-of-bounds rule.

## Deferred deviations

### D12 — Brand glyphs on the Apple and Google CTAs

- Design source: the Apple row leads with an ` ` glyph; the Google row leads
  with an inline 4-color Google "G" SVG, `gap:9px` before the label.
- Not fixed: shipping these requires adding vector/font assets under
  `mobile/assets/**` and registering them in `mobile/pubspec.yaml`, both outside
  this story's WriteScope.
- Current state: both CTAs render label-only. Fill, foreground, height, radius,
  gap, and label typography already match.
- Recommendation: raise a follow-up story for the brand-asset pipeline; it is
  shared with any other screen that shows provider marks.

### D13 — Literal brand hex values

- Design source hardcodes `#7B2FBE / #FF4B8C / #FF3366` (gradient stops),
  `#000` (Apple fill), `#fff` (light fill and text), and `#1A1A2E` (Google
  label).
- Not fixed literally: `mobile/lib/design_system/` is outside this story's
  WriteScope, so no new `CupidColorTokens` brand fields could be introduced, and
  `no_fork_guard_test.dart` forbids writing the hexes directly into
  `lib/features`.
- Mapping applied instead — nearest existing token, visually equivalent in the
  audited dark theme:
  - `#fff` → `colors.colorText` (`#F7EEFB`)
  - `#000` and `#1A1A2E` → `colors.colorBackground` (`#171129`)
  - gradient stops → `colors.gradientHot.colors` reversed, on the corrected
    `165deg` sweep
- Scope note: OQ5 places light theme and the `en` locale out of user-facing
  visual QA scope for this requirement (infra-only, not enabled for users), so
  this mapping is exact enough for every configuration a user can currently
  reach.
- Recommendation: a design-system story adding explicit brand-color tokens would
  let these resolve to the literal source values under any future theme.

## Verification evidence

All commands run inside the story worktree, in
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-004/mobile`,
using the local SDK at `/Users/alantravala/flutter/bin/flutter` (Flutter 3.44.1,
Dart 3.12.1 — the SDK is not on `PATH`).

1. `flutter gen-l10n` — required first; `lib/l10n/generated/app_l10n.dart` is
   gitignored, and without it the pre-existing baseline reports
   `Target of URI doesn't exist` / `Undefined name 'AppL10n'` across the app.
2. `flutter analyze lib/features/auth test/features/auth` — no errors, no
   warnings in the changed files. The only remaining output is three
   pre-existing `prefer_initializing_formals` infos in
   `lib/features/auth/data/auth_repository.dart:21` and
   `lib/features/auth/presentation/screens/splash_screen.dart:34,35`, neither of
   which this story touched.
3. `flutter test test/features/auth test/design_system test/widget_test.dart test/core/navigation`
   — `+61: All tests passed!`, including
   `test/design_system/no_fork_guard_test.dart` (confirms the corrected screen
   still consumes the design system purely through tokens) and the splash
   routing suite (confirms `WelcomeScreen` is still reached unchanged, AC4).

### Tests added

`mobile/test/features/auth/presentation/screens/welcome_screen_test.dart` (new,
6 widget tests) pins the corrected fidelity so it cannot silently regress:

- hero copy renders in `vi` (wordmark, tagline, sub-copy, footnote)
- hero content is left-aligned and vertically centered, tagline has no
  `textAlign` (D2)
- background gradient equals the reversed `gradientHot` token stops on the
  `165deg` alignments (D1)
- all CTAs are 52pt tall, separated by a 10pt gap, with the platform token's
  pill radius (D9, AC3)
- the Apple CTA appears only under `CupidPlatform.ios` (D9)
- no register CTA is present on `welcome` (D11)

## AC coverage

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 — dark theme + `vi` matches the design source in layout, spacing, tokens, typography | Met, with D12/D13 deferred | D1–D11 corrected; widget suite asserts alignment, gradient, geometry |
| AC2 — deviations corrected in the rendered app, not merely documented | Met | All fixes land in `welcome_screen.dart`; this report documents, it does not substitute |
| AC3 — CTA styling matches (radius, platform-adaptive treatment) | Met, D12 deferred | D9; radius sourced from `CupidPlatformTokens.radiusButton`, Apple CTA gated on `CupidPlatform` |
| AC4 — no change to how the screen is reached | Met | No routing/gate code touched; splash routing suite still green; register still reachable via `login_screen.dart:230` |
