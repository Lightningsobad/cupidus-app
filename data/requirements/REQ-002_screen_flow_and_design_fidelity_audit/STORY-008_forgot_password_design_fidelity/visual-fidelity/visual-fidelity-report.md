# Visual Fidelity Report: STORY-008 Forgot Password

Story: STORY-008 Design Fidelity — Forgot Password
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Screen: `forgot` (Epic 1, NO_CHROME / NO_TABS)
Lane: mobile
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-008`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`

## Design source of truth

- File: `cupid-app-design-system/project/Cupid Screens.dc.html`
- Block: `<sc-if value="{{ isForgot }}">`, lines 1513-1530
- Token definitions: lines 23-26 (`[data-plat]`, `[data-plat="md"]`,
  `body[data-theme="dark"]`)
- Audited configuration: dark theme + `vi` locale (the only combination
  enabled for users; OQ5 leaves light/`en` visual QA out of scope)

## Implementation under audit

- `mobile/lib/features/auth/presentation/screens/forgot_screen.dart`
- Test: `mobile/test/features/auth/presentation/screens/forgot_screen_test.dart`
  (new — no screen test existed for `forgot`)

## Token equivalence used throughout

Every CSS custom property in the `isForgot` block resolves to an existing
Flutter token with an identical value, so no new token was needed:

| Design source | Dark value | Flutter token |
| --- | --- | --- |
| `var(--bg)` | `#171129` | `colors.colorBackground` |
| `var(--surf)` | `#241B42` | `colors.colorSurface` |
| `var(--tx)` | `#F7EEFB` | `colors.colorText` |
| `var(--tx2)` | `#B4A6CE` | `colors.colorTextMuted` |
| `var(--purple)` | `#B78CF5` = `rgb(183,140,245)` | `colors.colorAccentPurple` |
| `var(--mint)` | `#79E2CD` = `rgb(121,226,205)` | `colors.colorMint` |
| `var(--red)` | `#FF6F91` | `colors.colorRed` |
| `var(--r-card)` | `24px` (md) / `26px` (ios) | `platform.radiusCard` |
| `var(--shadow)` | `0 6px 18px rgba(80,30,110,.16)` (md) | `platform.elevationShadow` |

## Deviations found and fixed

### D1 — Hero lock badge was missing entirely

- Design source (line 1515): `width:72px;height:72px;border-radius:26px;`
  `background:rgba(183,140,245,.2)` with a centered `lock_reset` glyph at
  `font-size:36px;color:var(--purple)`.
- Before: no badge at all; the screen opened directly on the title.
- Fix: left-aligned 72x72 `Container`, `BorderRadius.circular(26)`,
  `colors.colorAccentPurple.withValues(alpha: 0.2)`, centered `CupidIcon` at
  size 36 in `colors.colorAccentPurple`.
- See residual R1 for the glyph identity.

### D2 — Title used the wrong type role

- Design source (line 1517): `font-family:Nunito;font-weight:900;`
  `font-size:25px;line-height:1.25`.
- Before: `context.cupidType.cardTitle` — the platform UI font (Roboto/SF Pro)
  at weight 600, size 22, default line height. Wrong family, wrong weight,
  wrong size.
- Fix: `type.display.copyWith(fontSize: 25, height: 1.25)`. `display` is the
  Nunito/w900 role, so only the size and line height are overridden from the
  design source.

### D3 — Lead paragraph copy and metrics did not match

- Design source (line 1518): `font-size:13px;line-height:1.6;`
  `color:var(--tx2);margin-top:9px`, copy
  "Nhập email, tụi mình gửi link đặt lại. Đừng lo, kỷ niệm vẫn còn nguyên."
- Before: a shortened invented line ("Nhập email để nhận liên kết đặt lại mật
  khẩu."), `body` role (17px), no line height, `CupidSpacing.sm` (8) gap.
- Fix: design-source copy restored for both locales, `type.caption` (13px)
  with `height: 1.6` in `colors.colorTextMuted`, gap set to the source's 9.

### D4 — Email field was an unstyled Material `TextField`

- Design source (lines 1520-1522): a surface card —
  `background:var(--surf);border-radius:var(--r-card);padding:13px 16px;`
  `box-shadow:var(--shadow)` — containing an uppercase 11px label
  (`letter-spacing:.06em;color:var(--tx2);margin-bottom:6px`) above a
  borderless 16px input in `var(--tx)`.
- Before: a bare `TextField` with a floating `labelText`, stock M3 underline
  border, no surface, no shadow, no card radius.
- Fix: `Container` with `colors.colorSurface`, `platform.radiusCard`,
  `platform.elevationShadow` and `EdgeInsets.symmetric(horizontal: 16,`
  `vertical: 13)`; inside it an uppercase `type.caption` label at 11px with
  `letterSpacing: 11 * 0.06` in `colorTextMuted`, a 6px gap, then the field
  with `isCollapsed: true`, `border: InputBorder.none`,
  `contentPadding: EdgeInsets.zero` and `type.body.copyWith(fontSize: 16)`.

### D5 — Primary CTA label was not the design-source copy

- Design source (line 1524): "Gửi link đặt lại" / "Send reset link".
- Before: "Gửi liên kết" / "Send link".
- Fix: label replaced with the design-source strings. CTA container styling is
  residual R2.

### D6 — Private Gallery reassurance note was missing entirely

- Design source (lines 1525-1527): `display:flex;gap:11px;padding:15px 16px;`
  `border-radius:var(--r-card);background:rgba(121,226,205,.12);`
  `border:1px solid rgba(121,226,205,.32)`, a `shield_moon` glyph at 20px in
  `var(--mint)`, and 12.5px/1.55 body text in `var(--tx2)` with the word
  "không" / "not" emphasised in `var(--tx)`.
- Before: absent.
- Fix: `Container` with `colors.colorMint.withValues(alpha: 0.12)`,
  `Border.all(color: colors.colorMint.withValues(alpha: 0.32))`,
  `platform.radiusCard`, `EdgeInsets.symmetric(horizontal: 16, vertical: 15)`;
  a `Row` with an icon at 20 in `colorMint`, an 11px gap, and a `Text.rich`
  carrying the design-source copy with the emphasised span at
  `FontWeight.w700` in `colors.colorText`. See residual R1 for the glyph.

### D7 — Screen padding and section rhythm did not match

- Design source (line 1514): `padding:20px 20px 40px;`
  `display:flex;flex-direction:column;gap:16px`.
- Before: `EdgeInsets.all(CupidSpacing.lg)` (24 on all sides) plus a
  `CupidSpacing.xl` (32) spacer above the title, with mixed 8/24 gaps between
  sections.
- Fix: `EdgeInsets.fromLTRB(20, 20, 20, 40)`, the leading 32 spacer removed,
  and a uniform `CupidSpacing.md` (16) gap between top-level sections, which
  is exactly the source's `gap:16px`.

## State audit (AC 3)

| State | Design source | Result |
| --- | --- | --- |
| Empty | Card + uppercase label, no placeholder text | Matches after D4. |
| Filled | 16px input text in `var(--tx)` | Matches after D4. |
| Error / invalid email | **Not present in the design source** — the `isForgot` block has no error treatment | The app's existing failure line is retained and re-styled to the source's supporting-text metrics (12.5px / 1.55) in `colors.colorRed` (`var(--red)`), matching the small-supporting-text scale used elsewhere in the block. No error visual was invented beyond that. |
| Submitted / confirmation | **Not present in the design source** — the source CTA navigates straight to `login` | The app's existing "Đã gửi email đặt lại mật khẩu." confirmation is retained (removing it would break real reset behaviour, and navigation is Scope A / STORY-001-002) and re-styled to the same 12.5 / 1.55 metrics in `colors.colorMint` (`var(--mint)`, the source's trust/success role). |
| Busy | Not present in the design source | Unchanged: CTA `onPressed` is nulled while in flight. |

## Residual deviations (blocked by this story's WriteScope)

These are real remaining differences from the design source. Both are owned by
`mobile/lib/design_system/**`, which is outside this story's declared
WriteScope, so they were not changed here.

### R1 — Icon glyphs are substitutes

- Design source uses `lock_reset` (hero badge) and `shield_moon` (note icon).
- `CupidIcons` exposes neither; the file's own contract requires codepoints
  verified against the bundled `MaterialSymbolsRounded-Variable.ttf` cmap and
  it lives outside WriteScope. Both slots therefore render `CupidIcons.lock`.
- Everything else about both icons (size, color, variant, placement) matches
  the source.
- Follow-up: add `lockReset` (badge) and `shieldMoon` (note) to
  `mobile/lib/design_system/icons/cupid_icons.dart` with cmap-verified
  codepoints, then swap the two call sites in `forgot_screen.dart`.

### R2 — Primary CTA container styling

- Design source (line 1524): `height:54px;border-radius:var(--r-btn);`
  `background:var(--grad-hot);color:#fff;font-size:16.5px;font-weight:800;`
  `box-shadow:var(--glow)`.
- `CupidPrimaryButton` renders a flat `colorAccentPink` fill at
  `platform.tapTarget` height (48 on Material), a 20dp radius on Material, and
  a `type.body` label — no `gradientHot` fill and no `glowShadow`.
- Forking a screen-local gradient CTA inside `forgot_screen.dart` would
  contradict `architecture/solution.md` D3/ADR-004 (feature code consumes the
  design system's adaptive widgets, never a per-screen fork) and would make
  `forgot` inconsistent with `login`, `register` and `otp`.
- Follow-up: this is a design-system-level fix in
  `mobile/lib/design_system/adaptive/cupid_primary_button.dart` affecting every
  screen with a primary CTA. It should be its own story, not a STORY-008 edit.

## Verification evidence

All commands run in the story worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-008/mobile`
with Flutter 3.44.1 / Dart 3.12.1.

1. `flutter analyze lib/features/auth/presentation/screens/forgot_screen.dart test/features/auth/presentation/screens/forgot_screen_test.dart`
   → `No issues found! (ran in 0.8s)`
2. `flutter test test/features/auth/presentation/screens/forgot_screen_test.dart`
   → `+4: All tests passed!`
3. `flutter test` (full suite, regression check)
   → `+924: All tests passed!`
4. `flutter analyze lib test`
   → `77 issues found`, all `info`-level and all pre-existing in unrelated
   files (`prefer_initializing_formals`, `use_null_aware_elements`,
   `deprecated_member_use`). Zero issues in `forgot_screen.dart` or its test,
   confirmed by run 1.

Note: bare `flutter analyze` (no path argument) also walks
`mobile/build/ios/SourcePackages/checkouts/flutterfire/**`, vendored
third-party sources present in this worktree's build directory. Those errors
are pre-existing environment noise unrelated to this story, which is why the
gate was run scoped to `lib` and `test`.

The no-fork guard (`mobile/test/design_system/no_fork_guard_test.dart`) passes:
the screen contains no raw color literal, no `Colors.` reference and no
platform branch — every color comes from `CupidColorTokens` and every radius
and shadow from `CupidPlatformTokens`.

## Test coverage added

`forgot_screen_test.dart` (4 cases, previously no test existed for this
screen):

1. Empty state renders the design-source vi copy, the `EMAIL` uppercase label,
   the Nunito/w900/25px title in `colorText`, and a borderless 16px input.
2. Hero badge tint `colorAccentPurple @ 0.2` and note surface tint
   `colorMint @ 0.12` with a border are both present.
3. Submitted state shows the confirmation line and stays on the screen.
4. Failed state renders the failure line in `colorRed`.

## Acceptance criteria

- AC 1 (layout / spacing / token / typography match): MET for everything in
  this story's WriteScope; R1 and R2 remain and are design-system-owned.
- AC 2 (deviations corrected in the app, not just documented): MET — D1-D7 are
  code changes in `forgot_screen.dart`, verified by tests.
- AC 3 (form-field / response states): MET — see the state audit table; the
  two states absent from the design source are documented rather than invented.
- AC 4 (no new entry point): MET — `ForgotScreen`'s constructor, route and
  `LoginScreen` push site are unchanged; no navigation logic was touched.
