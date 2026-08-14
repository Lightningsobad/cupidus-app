VISUAL_FIDELITY: PASS

# STORY-029 — Me / Profile Visual Fidelity Report

- Story: STORY-029 (`me_profile_design_fidelity`)
- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Lane: mobile
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-029`
- BaseHead: `92930ec38ccbe1e87128a9dd2ff4681edf87fb03`
- Audit target: enabled dark theme, `vi` locale

## Scope And Sources

| Item | Path |
| --- | --- |
| Locked design source | `cupid-app-design-system/project/Cupid Screens.dc.html`, `isMe` section (lines 977-1001) |
| Zodiac component source | `cupid-app-design-system/project/Zodiac Icon.dc.html` |
| Screen under audit | `mobile/lib/features/account/presentation/screens/me_screen.dart` |
| State feeding the screen | `mobile/lib/features/account/presentation/account_cubit.dart` |
| Design system additions | `mobile/lib/design_system/icons/cupid_zodiac_icon.dart`, `mobile/lib/design_system/icons/cupid_icons.dart` |
| Capture entrypoint | `mobile/lib/main_preview.dart` (`PREVIEW=me`, `PREVIEW_ME_FIXTURE=true`) |
| Design reference | `visual-fidelity/design-reference-me-android.png` (406x900) |
| Implemented capture | `visual-fidelity/implemented-me-emulator-5560.png` (405x900) |

`profile_edit_screen.dart` was re-read but not changed: the `profile` canvas id
is the onboarding profile-setup step (STORY-010 scope, explicitly Out of Scope
here), and the design source ships no separate canvas for the account-side
profile edit form. Nothing in this story's ACs applies to it.

### Token-mapping rule used

The design source is raw CSS on an off-scale pixel ladder. This audit follows
the convention already established and review-approved in this requirement
(see STORY-022's report): map *design roles* onto the shared token scale, and
transcribe only genuinely un-tokenizable geometry as named constants carrying
the source value in their doc comment.

| Design source value | Mapped to |
| --- | --- |
| `padding:8px 16px 40px` (screen) | `EdgeInsets.fromLTRB(md, sm, md, xl)` |
| `gap:13px` (card stack), `gap:15px`, `gap:13px` (row) | `CupidSpacing.md` |
| `gap:11px`, `margin-top:12px`, `padding:…10px` (pill) | `CupidSpacing.sm` |
| `margin-top:6px` / `3px`, `gap:7px` / `6px` / `5px` | `CupidSpacing.xs` |
| `padding:22px 20px` (profile card) | `EdgeInsets.all(CupidSpacing.lg)` |
| `padding:4px 17px` (settings card) | `symmetric(horizontal: md, vertical: xs)` |
| `padding:17px` (divorce card) | `EdgeInsets.all(CupidSpacing.md)` |
| `font-family:Nunito;font-weight:900;font-size:21px` (name) | `type.display` at `type.cardTitle.fontSize` |
| `font-size:14.5px;font-weight:700` (row title) | `type.body` + `FontWeight.w700` |
| `font-size:12px` / `11.5px` (caption, trailing value, subtitle) | `type.caption` |
| `font-family:'Roboto Mono';font-size:10px` (version) | `type.labelMono` at `_versionFontSize` |
| `--surf` / `--surf2` / `--line` / `--tx` / `--tx2` | `colorSurface` / `colorSurfaceAlt` / `colorLine` / `colorText` / `colorTextMuted` |
| `--mint` / `--amber` / `--purple` / `--peach` / `--pink` / `--ghost` | `colorMint` / `colorAmber` / `colorAccentPurple` / `colorPeach` / `colorAccentPink` / `colorGhost` |
| `--r-card` / `999px` | `platform.radiusCard` / `999` |
| `--shadow` | `platform.elevationShadow` |

Each badge tint was verified byte-for-byte against `CupidColorTokens`, not
approximated: `rgba(121,226,205,.18)` = `colorMint` `#79E2CD`,
`rgba(255,201,126,.18)` = `colorAmber` `#FFC97E`, `rgba(183,140,245,.18)` =
`colorAccentPurple` `#B78CF5`, `rgba(255,171,147,.18)` = `colorPeach`
`#FFAB93`, `rgba(255,127,182,.18)` = `colorAccentPink` `#FF7FB6`.

Literals kept as named constants: avatar `64`, edit/zodiac glyph `22`, badge
`38` at radius `13`, badge glyph `20`, trailing glyph `19`, row vertical
padding `14`, pill glyph `12`, pill/version type `10`, pill radius `999`. The
row rhythm in particular must not round — `14 -> 16` would accumulate ~28px of
drift across the seven rows and visibly desynchronise the card height.

## Findings And Corrections

All findings were corrected in app code (AC2), not documented only.

### F-01 — Profile summary card was not the design's gradient hero

- Before: a plain surface card, name in `type.body`, no zodiac, no birthday.
- Design: `linear-gradient(150deg,rgba(255,127,182,.2),rgba(183,140,245,.18))`,
  `1px solid var(--line)` border, no shadow; 64px circular avatar carrying
  `var(--shadow)`; name in Nunito 900/21px; a muted 12px caption row of
  `[zodiac glyph] {{myZodiac}} · {{myDob}}`; trailing `edit` glyph in the
  *line* variant at 22px.
- After: `_ProfileSummaryCard`. The 150deg angle uses the CSS-angle convention
  already encoded in `CupidColorTokens` (`begin = (-sin, cos)`,
  `end = (sin, -cos)`), so it composes with the existing gradient tokens
  instead of introducing a second convention. The card is the tap target for
  the edit route, matching the design's own `image-slot`/`edit` affordance.

### F-02 — The `Zodiac Icon` design component had no counterpart in the app

- Before: nothing. The caption row did not exist, so neither did the glyph.
- Design: `dc-import name="Zodiac Icon" sign="{{ myZodiacSign }}"` at 22x22 — a
  tinted backing disc plus a stroked sign glyph plus two decorative dots, with
  a four-element palette (`EL` map) driving both.
- After: new `mobile/lib/design_system/icons/cupid_zodiac_icon.dart`. No SVG
  runtime is bundled, so the component is ported as a `CustomPainter` in the
  design's own `0 0 100 100` viewBox and scaled at paint time. All twelve `d`
  strings are stored verbatim and read by a minimal absolute-command path
  parser rather than hand-transcribed into `Path` calls, so the glyph geometry
  cannot silently drift from source. Element inks and disc opacities are
  verbatim from `EL` (air is `.18`, the other three `.16`).
  `CupidZodiacSign.tryParse` maps the profile contract's English sign name.

### F-03 — Three of the seven settings rows were missing, and the order was wrong

- Before: four rows (privacy, notifications, Typing Ghost, Love Contract).
- Design: seven rows in a fixed order — `shield_moon` / `notifications` /
  `palette` / `{{shareIcon}}` / `blur_on` / `draw` / `translate`.
- After: `_SettingsCard` renders all seven in source order. `Kho Theme`,
  `Ảnh chia sẻ` and `Ngôn ngữ` are new. The share row resolves
  `{{shareIcon}}` per platform (`ios_share` on iOS, `share` on material),
  matching how the design source parameterises that one glyph.
- Row labels with no existing ARB key use the file-local `viEn` helper, the
  same per-file pattern as `features/chat/presentation/chat_strings.dart`,
  because `mobile/lib/l10n/` is outside this story's write scope.

### F-04 — Row chrome did not match the design's list treatment

- Before: Material `ListTile`-style rows with default leading icons, no tinted
  badges, no per-row divider rule.
- Design: each row is a 38x38 badge at `border-radius:13px` filled with the
  glyph colour at `.18`, a 20px glyph, a `14.5px/700` label, an optional 12px
  muted trailing value, an optional 19px `chevron_right`, `14px 0` vertical
  padding, and `1px solid var(--line)` below every row *except the last*.
- After: `_MenuRow` reproduces all of it, including the last-row divider
  suppression and the two chevron-less rows (`Typing Ghost`, `Ngôn ngữ` —
  the design gives those a value instead of a forward affordance).

### F-05 — Trailing values were absent

- Before: no row showed a value.
- Design: `{{ ghostBtnLabel }}` on Typing Ghost and `{{ langLabel }}` on
  Ngôn ngữ.
- After: both bind to real profile state — `profile.isGhostModeEnabled`
  renders `ON`/`OFF`, `profile.language` renders `Tiếng Việt`/`English`. No
  authored placeholder: the values are what the loaded `CupidProfile` says.

### F-06 — Digital Divorce teaser card was missing

- Before: nothing below the settings list.
- Design: a `--surf` card with a `--ghost` `heart_broken` glyph, `Digital
  Divorce` title, an 11.5px muted subtitle, a trailing chevron, and a
  `999px` `--surf2` pill (`schedule` glyph + `Phase 1.5`) at 10px.
- After: `_DigitalDivorceCard`. Rendered without an `onClick` binding because
  the design source states none, and §10 of the UX system memory confirms
  Digital Divorce is Phase 1.5 — so the card is an announcement, not a route.

### F-07 — Version line was missing

- Before: nothing.
- Design: centred `Roboto Mono` 10px `--tx2`
  `Cupid 1.0.0 (MVP) · iOS 15+ / Android 8+`, `padding:6px 0`.
- After: rendered from `type.labelMono`, whose role is documented as unsized,
  at the design's explicit 10px.

### F-08 — Ten `MaterialSymbolsRounded` codepoints were unavailable

- Before: `CupidIcons` had no constant for `share`, `edit`, `notifications`,
  `palette`, `blur_on`, `draw`, `translate`, `heart_broken`, `schedule` or
  `person`.
- After: all ten added, each codepoint read out of the bundled
  `MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools` and recorded in
  the constant's doc comment. None were recalled from memory.

### F-09 — Preview entry could not render this screen without live credentials

This is capture-infrastructure, not user-visible, but it is what makes the
comparison evidence reproducible.

- Before: `_buildMe` issued a live `GET /users/me` (so a capture needed
  uncommitted `PREVIEW_EMAIL`/`PREVIEW_PASSWORD`) *and* passed an
  `AuthRepository`, rendering a sign-out row that neither production nor the
  design source has — `AppShell._openAccountHub`, the only production caller,
  passes none.
- After: `PREVIEW_ME_FIXTURE` hands `MeScreen` an authored `CupidProfile`
  through a new `resolveProfile` override, exactly mirroring the existing
  `PREVIEW_HOME_FIXTURE` / `HomeScreen.resolveProfile` precedent, and the
  spurious `AuthRepository` is dropped. The captured state is now faked, not
  driven, as the visual-fidelity reference requires.

## Accepted Deviations (deferred, with reason)

These are visible in the side-by-side captures and are deliberately *not*
fixed here. Each is outside this story's write scope or forbidden by its own
Out of Scope section.

### D-01 — Ambient `--sky` screen wash

The design canvas paints `--sky` (a three-layer radial-gradient stack) on the
`[data-plat]` screen shell, so it appears behind *every* screen, not just
`me`. In the app it is carried as an unrendered CSS string on
`CupidColorTokens.skyGradient`, whose own doc comment defers the rendering
approach to "the story that first paints this decoration". Exactly one screen
paints it today — `features/pairing/presentation/screens/waiting_screen.dart`,
using file-private `_CssEllipse`/`_sky*Wash` helpers. Painting it here would
mean either duplicating ~90 lines of gradient machinery into a feature screen
or promoting it into `design_system/` while `waiting_screen` keeps its private
copy, and `features/pairing/` is outside this story's write scope so the
refactor cannot be completed. This is app-shell background scope; the flat
`colorBackground` is the status quo every previously-approved fidelity story in
this requirement rendered against.

### D-02 — Bottom navigation: 5 tabs in the design, 3 tabs + FAB in the app

The design shows `Nhà / Trò chuyện / Pet / Ví chung / Tôi` with `Tôi` active
and no floating action button; the app ships three tabs plus a pink FAB that
opens the account hub as a pushed route. That structure lives in
`mobile/lib/core/navigation/app_shell.dart` (mirrored for capture by
`preview/preview_app_shell_chrome.dart`), which is outside this story's write
scope. AC4 is explicit that this story "does not change how the screen is
reached", so leaving navigation untouched satisfies it rather than violating
it. This belongs to the requirement's screen-flow scope.

### D-03 — `Kho Theme` row has no trailing swatch or theme name

The design row ends with a 16x16 `border-radius:5px` swatch filled from
`{{ curThemeSwatch }}` plus a 12px `{{ curThemeName }}`. No theme feature
exists in the app: `themes` and `themedetail` are both listed in
`main_preview.dart`'s `_notImplementedCanvasIds`, and there is no theme store,
no current-theme state, and no swatch to read. Rendering an invented theme
name would be "a new feature … not already present in the locked design
source", which this story's Out of Scope section forbids. The row itself,
its badge, its label and its chevron are all present and correct; only the
value binding waits on the owning story.

### D-04 — Avatar placeholder

The design shows the canvas `image-slot` authoring affordance ("Drop an
image"). The app renders the `person` glyph on `colorSurfaceAlt` when
`profile.photoUrl` is null and the real image when it is set. The canvas
placeholder is an authoring artifact, not a shipped state.

## Verification

| Gate | Command | Result |
| --- | --- | --- |
| Static analysis | `flutter analyze lib/design_system lib/features/account lib/main_preview.dart lib/preview test/features/account` | No issues found |
| Widget/unit tests | `flutter test test/features/account/presentation/screens/me_screen_test.dart test/features/account/presentation/account_cubit_test.dart` | 15/15 passed |
| Build | `flutter build apk --debug --target=lib/main_preview.dart --dart-define=PREVIEW=me --dart-define=PREVIEW_ME_FIXTURE=true` | Built `app-debug.apk` |
| Capture | `capture-mobile-screen.sh --label=me --device=emulator-5560` | `MOBILE_CAPTURE: OK` 405x900 |

Five tests were added to `me_screen_test.dart` covering the new surface: the
seven design rows in source order, the zodiac glyph and formatted birthday,
both profile-driven trailing values, the Digital Divorce card and version
line, and the profile card opening the edit route.

## Acceptance Criteria

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 — layout, spacing, colour/token usage and typography match | MET, with D-01..D-04 deferred as scoped above | Side-by-side captures; token-mapping table |
| AC2 — deviations corrected in the app, not merely documented | MET | F-01..F-09 are code changes; re-captured after the final change |
| AC3 — Level-3 data-sensitivity visual treatment correct | MET | §8 assigns the lock affordance to Level 1 only; Profile is Level 3 ("standard server / TLS 1.3") and the design source specifies no additional treatment on this screen. The entry into the 3-tier privacy controls is present with its `shield_moon` badge. |
| AC4 — no new entry point; reachability unchanged | MET | No navigation file touched; see D-02 |
