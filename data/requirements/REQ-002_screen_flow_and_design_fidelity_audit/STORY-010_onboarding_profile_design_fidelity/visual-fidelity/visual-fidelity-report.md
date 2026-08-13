# Visual Fidelity Report: STORY-010 — Onboarding Profile Setup

Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-010 Design Fidelity — Onboarding Profile Setup
Lane: mobile
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-010`
BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`
Design reference: `cupid-app-design-system` (locked)
Configuration audited: dark theme + `vi` locale (the only user-enabled
combination; `CupidFeatureFlags.enableLightTheme` / `enableEnLocale` are off in
`mobile/lib/app/cupid_app.dart`).

---

## 1. Screen Identification (required by the handoff before any edit)

The handoff flagged that the source file for this screen was unconfirmed and
required verification via the actual navigation graph / route table rather than
assumption. Result of that investigation:

### 1.1 The design canvas

The locked design source defines the onboarding profile step as canvas id
`profile`:

- `cupid-app-design-system/project/Cupid Screens.dc.html:1863` —
  `{ id: 'profile', icon: 'account_circle', vi: 'Hồ sơ ban đầu', en: 'Set up profile' }`
- `Cupid Screens.dc.html:1853` — `BACK_TO = { ..., profile: 'permissions', invite: 'profile' }`,
  placing it between `permissions` and `invite` in the onboarding chain.
- `Cupid Screens.dc.html:93-119` — the `isProfile` markup block (the spec
  audited in §3 below).

This is unambiguously distinct from canvas `me` (the Epic 6 hub), which is
STORY-029's screen.

### 1.2 The app's onboarding navigation graph

Traced forward from the app root:

- `mobile/lib/app/cupid_app.dart:43` — `home: PairGateShell(...)`
- `mobile/lib/features/auth/presentation/screens/splash_screen.dart:103` —
  `SessionGateUnauthenticated() => WelcomeScreen(...)`
- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart:45` —
  pushes `RegisterScreen`
- `mobile/lib/features/auth/presentation/screens/register_screen.dart:62-64` —
  on `RegisterSuccess`, `pushReplacement` straight to `HomeScreen`

**Finding: the app's onboarding chain has no profile-setup step.** There is no
`onboarding/` or `profile_setup/` directory anywhere under `mobile/lib`, and the
string `onboarding` does not appear in `mobile/lib` at all. The design source's
`permissions -> profile -> invite` sub-chain is not implemented as a routed
onboarding step.

### 1.3 The repo's own canvas -> screen mapping

The preview registry is the repository's authoritative design-canvas-to-screen
map (it is what renders each canvas id for capture):

- `mobile/lib/main_preview.dart:185-188` — canvas `'profile'` -> `_buildProfile`
- `mobile/lib/main_preview.dart:370-384` — `_buildProfile` -> `ProfileEditScreen`
- `mobile/lib/main_preview.dart:166-170` — canvas `'me'` -> `_buildMe` -> `MeScreen`

### 1.4 Conclusion and STORY-029 boundary

`mobile/lib/features/account/presentation/screens/profile_edit_screen.dart` is
the repository's single implementation of design canvas `profile`, and is
therefore this story's target. It is **not** reused for onboarding in the
routing sense — today it is only reachable from the Me hub
(`me_screen.dart:59`) — but it is the only surface that realizes the `profile`
canvas, so it is where canvas-`profile` fidelity is owned.

**No overlap with STORY-029.** STORY-029's `story_master.md` scopes it to "the
post-pairing 'me' tab in the 5-tab bottom nav", i.e. canvas `me` ->
`me_screen.dart`. This story touched only `profile_edit_screen.dart` and its
test. `me_screen.dart` was not modified.

### 1.5 Deviation raised to Scrum Master, not fixed here

The missing onboarding entry point (`register -> profile -> invite`) is a
*navigation-graph* gap, not a visual one. This story's Out of Scope explicitly
assigns inter-screen navigation to Scope A (STORY-001/STORY-002), and AC4
requires that this story not change how the screen is reached. Flagged for
Scrum Master routing; deliberately not implemented here.

---

## 2. Method

Static audit of the rendered widget tree against the design source's `isProfile`
markup, with CSS custom properties resolved through the design source's own
token declarations (`Cupid Screens.dc.html:23-26`) and mapped onto the app's
`ThemeExtension` tokens.

Token mapping used throughout:

| Design source var | Dark value | App token |
|---|---|---|
| `--bg` | `#171129` | `colors.colorBackground` |
| `--surf` | `#241B42` | `colors.colorSurface` |
| `--surf2` | `#2E2456` | `colors.colorSurfaceAlt` |
| `--tx` | `#F7EEFB` | `colors.colorText` |
| `--tx2` | `#B4A6CE` | `colors.colorTextMuted` |
| `--grad-hot` | `linear-gradient(120deg,#FF7FB6,#B78CF5)` | `colors.gradientHot` |
| `--glow` | `0 8px 28px rgba(255,107,168,.34)` | `colors.glowShadow` |
| `--shadow` | `0 6px 18px rgba(80,30,110,.16)` (md) | `platformTokens.elevationShadow` |
| `--r-card` | `24px` (md) | `platformTokens.radiusCard` |
| `--r-btn` | `999px` | `platformTokens.radiusButton` |

Note on the `<image-slot>` in the design markup: `image-slot.js:1` declares
itself `@ds-adherence-ignore -- omelette starter scaffold (raw elements/hex/px
by design)`, and its dartdoc describes a drag-and-drop authoring affordance with
a default "Drop an image" caption. It is design-tool scaffolding, not product
UI. Only its **rendered frame** (104px, circle-cropped, `--shadow`) is product
design; its empty-state chrome has no product equivalent and is served by the
app's own person-glyph placeholder. This is the reading applied to AC3.

---

## 3. Deviations Found And Corrected

All eight below are fixed in
`mobile/lib/features/account/presentation/screens/profile_edit_screen.dart`.

| # | Element | Design source | Before | After |
|---|---|---|---|---|
| D1 | Avatar diameter | `104px` (`:96-97`) | `CircleAvatar(radius: 44)` = 88px | 104px |
| D2 | Avatar shadow | `box-shadow:var(--shadow)` (`:97`) | none | `platformTokens.elevationShadow` |
| D3 | Camera badge | 36px circle, `--grad-hot`, `3px solid var(--bg)` ring, `--glow`, `photo_camera` glyph @19px `#fff`, at `right:-10px;bottom:-6px` (`:98`) | absent | present, matching all six values |
| D4 | Crop caption | `12.5px`, `var(--tx2)`, "Ảnh sẽ được crop tròn" (`:100`) | absent | `type.caption` + `colorTextMuted`, both locales |
| D5 | Placeholder glyph font | Material Symbols Rounded is the single icon family (ADR-004d) | `Icons.person` (Flutter's separate `MaterialIcons` font) | `CupidIcon` on `CupidIcons.fontFamily` |
| D6 | Zodiac chip radius | `border-radius:999px` (`:109`) | `platformTokens.radiusSmall` (16) | `platformTokens.radiusButton` (999) |
| D7 | Zodiac chip text | `12.5px`, `font-weight:700`, inherits `--tx` (`:109`) | `type.labelMono` (Roboto Mono w400) in `colorAccentPurple` | `type.caption` w700 in `colorText` |
| D8 | Zodiac helper placement | inside the DOB card, `margin-top:8px` (`:110`) | outside/below the card | inside the card, `CupidSpacing.sm` |

Notes on specific fixes:

**D3 (camera badge).** Rendered **inert** and wrapped in `ExcludeSemantics`.
`coding-plan/master-plan.md` §6.2 P2 explicitly sanctions this state ("the
camera badge is either absent or inert until P3"), and inert keeps the story
inside its "no new interaction" boundary while satisfying AC3's styling
requirement. Excluding it from the semantics tree prevents a screen reader
announcing a button that does nothing.

**D5.** `Icons.person` resolves against Flutter's bundled `MaterialIcons` font,
a second icon family, which ADR-004d forbids ("no second icon package"). The
glyph codepoints used (`photo_camera` `0xe412`, `person` `0xe7fd`) were read
from the bundled `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap
via `fontTools`, per the standing rule in `cupid_icons.dart` that codepoints are
never invented from memory. They are declared file-locally because
`design_system/icons/` is outside this story's write scope — the same pattern
already used by `love_contract_screen.dart:429` and `gallery_viewer_screen.dart:15`.

**D7.** The design source opts into Roboto Mono explicitly where it wants it
(e.g. the contract number at `:125`, `font-family:'Roboto Mono'`) and does not
do so for this chip, so the UI font at weight 700 in the primary text color is
the faithful rendering.

---

## 4. Conformances Verified (already correct, no change)

- Screen background `--bg` -> `colors.colorBackground` (`:101`).
- Field card surface `--surf`, radius `--r-card` -> `colorSurface` /
  `radiusCard` (`_FieldCard`).
- Field label: uppercase, muted, letter-spaced -> matches `:104` treatment.
- Field value `17px` / weight 600 -> `type.body` (17) `.copyWith(w600)`, exact.
- Zodiac chip fill `--surf2` -> `colorSurfaceAlt`, already correct.
- `NO_TABS` — `Cupid Screens.dc.html:1952` lists `profile`; the screen renders
  no tab bar. Correct.

---

## 5. Accepted Non-Deviations (design-system contract, not defects)

The app quantizes the design source's raw CSS pixel spacing onto its locked 8pt
grid (`CupidSpacing`, `ux/uiux-spec.md` §4). Introducing raw off-grid values
would fork the token system, so these gaps are intentional and are **not**
recorded as deviations:

| Design source | App token | Delta |
|---|---|---|
| body padding `22px 20px 40px` | `EdgeInsets.all(CupidSpacing.lg)` (24) | on-grid |
| block gap `22px` | `CupidSpacing.lg` (24) | on-grid |
| card gap `12px` | `CupidSpacing.sm` (8) | on-grid |
| card padding `14px 16px` | `CupidSpacing.md` (16) | on-grid |
| label `11px`, caption `12.5px`, helper `11.5px` | `type.caption` (13) | nearest role |

Geometry with no covering token (104 / 36 / 19 / 3 / -10 / -6) is transcribed
verbatim from the design source as named constants, following the existing
`CupidPrimaryButton._materialPrimaryCtaRadius` precedent.

---

## 6. Deviations Deferred (out of this story's scope)

| Deviation | Design source | Why deferred |
|---|---|---|
| Third field card "Ngôn ngữ" + chevron | `:112-115` | New interaction (locale switching). OQ5 keeps `en` locale infra-only and not user-enabled, so the control would have nothing valid to switch to. Needs a Product Owner / OQ5 decision. |
| Bottom CTA "Tiếp tục → Love Contract" | `:117` | Inter-screen navigation, explicitly assigned to Scope A (STORY-001/STORY-002) by this story's Out of Scope. |
| 26px zodiac sign artwork in the chip | `:109`, `<dc-import name="Zodiac Icon">` | No zodiac icon asset exists in the app. Adding 12 sign artworks is new art, and `design_system/` is outside this story's write scope. |
| Header title "Hồ sơ của bạn" vs app's "Chỉnh sửa hồ sơ" | `:1764` `t_profile`; `profile` absent from `NO_CHROME` (`:1951`) so a header does show | The app screen is currently an edit screen reached from Me, and its header/back-label pair is correct for that path. Retitling is only right once the onboarding entry point exists (§1.5). `l10n/` is also outside write scope. |
| Missing onboarding entry point | `BACK_TO` chain (`:1853`) | Navigation graph — Scope A. See §1.5. |

---

## 7. Verification

All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-010/mobile`
with `/Users/alantravala/flutter/bin` on `PATH`.

Pre-step (fresh worktree had no generated localizations; all baseline
`AppL10n` analyzer errors came from this and are unrelated to the change):

```
flutter gen-l10n
```

Static analysis:

```
flutter analyze lib/features/account test/features/account
-> No issues found! (ran in 2.9s)
```

Scoped tests (the touched screen):

```
flutter test test/features/account/presentation/screens/profile_edit_screen_test.dart
-> 00:01 +8: All tests passed!
```

Regression sweep (whole account feature + design-system guards, including
`no_fork_guard_test.dart`, `contrast_test.dart`, `theme_matrix_test.dart`,
`icon_variant_test.dart`):

```
flutter test test/features/account test/design_system
-> 00:05 +123: All tests passed!
```

`no_fork_guard_test.dart` passing confirms the new code introduces no raw color
literal, no `Colors.*`, and no platform branch in `lib/features`.

### Tests added

Five fidelity tests in
`mobile/test/features/account/presentation/screens/profile_edit_screen_test.dart`
under group `STORY-010 design fidelity against the 'profile' canvas`:

1. avatar slot is a 104px circle carrying the elevation shadow (D1, D2)
2. camera badge is a 36px gradient circle ringed in the background color and
   hidden from a11y (D3)
3. crop caption renders in the active locale — asserts both `vi` and `en` (D4)
4. zodiac chip is a pill in the primary text color, not a mono accent tag
   (D6, D7)
5. zodiac helper sits inside the date-of-birth card (D8)

The three pre-existing behavior tests still pass unchanged.

---

## 8. Acceptance Criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC1 — layout, spacing, color/token usage, typography match in dark + `vi` | **MET (with §6 deferrals)** | Eight deviations corrected (§3); conformances confirmed (§4); grid quantization is design-system contract (§5). Remaining gaps in §6 are out of this story's scope by its own Out of Scope / OQ5 boundaries, not unaddressed defects. |
| AC2 — deviations corrected in the app, not merely documented | **MET** | All of D1-D8 are code changes in `profile_edit_screen.dart`, each covered by a passing test. |
| AC3 — avatar slot matches the `<image-slot>` upload/crop widget in empty and populated states | **MET** | Frame now 104px circle-cropped with `--shadow`; camera badge present at exact design geometry; crop caption present. Empty state renders the person glyph, populated state renders the photo via `DecorationImage(fit: BoxFit.cover)` matching the slot's `fit="cover"` default. Slot scaffolding chrome correctly excluded (§2). |
| AC4 — no new entry point; reachability unchanged | **MET** | No navigation code touched. The pre-existing `MeScreen -> ProfileEditScreen` push (`me_screen.dart:59`) is unchanged; the missing onboarding entry point is flagged to Scope A, not added (§1.5). |

---

## 9. Files Changed

- `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart`
- `mobile/test/features/account/presentation/screens/profile_edit_screen_test.dart`

No other file was modified. (`flutter pub get` incidentally bumped
`mobile/ios/.../Package.resolved`; that build side effect was reverted so the
branch diff stays inside the declared write scope.)
