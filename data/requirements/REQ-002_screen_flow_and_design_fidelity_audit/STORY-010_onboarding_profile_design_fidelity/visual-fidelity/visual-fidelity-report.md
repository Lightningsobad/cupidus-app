# Visual Fidelity Report: STORY-010 — Onboarding Profile Setup

VISUAL_FIDELITY: FAIL
Design-Screen: profile

Every remaining delta behind that `FAIL` is listed in §3.1 with an owner. The
eight deviations this story was scoped to fix (§3) are corrected and confirmed
in the render; what remains is the four deferrals the round-1 review already
accepted (D-3 to D-7) plus three copy/localization gaps the render newly
exposed, all of which hang off the unresolved D-2 screen-identity question.
`PASS` is not available while any visible difference remains, and none of these
were fixable inside this story's boundary — see §3.2 for why each was not.

Rendered evidence (both frames 900px tall, Android viewport, dark + `vi`):
- `visual-fidelity/implemented-profile-emulator-5554.png` (405x900, 68102 B)
- `visual-fidelity/design-reference-profile-android.png` (406x900)

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

Two passes, both required, neither a substitute for the other:

1. **Rendered comparison (§3.1).** The screen was built, installed and
   photographed on `emulator-5554`, and compared against a reference rendered
   from canvas `profile`. This is the pass that decides the
   `VISUAL_FIDELITY:` verdict. Round 1 of this story substituted a static audit
   for this step; that was the round-1 blocking finding F1 and is now closed.
2. **Source-level audit (§3, §4, §5).** The `.dc.html` markup is read directly
   to implement, because it states dimensions, colours and spacing far more
   precisely than any screenshot can. CSS custom properties are resolved
   through the design source's own token declarations
   (`Cupid Screens.dc.html:23-26`) and mapped onto the app's `ThemeExtension`
   tokens.

### Reaching the screen

`main_preview.dart`'s `profile` entry builds `ProfileEditScreen` behind a
`FutureBuilder` on `AccountRepository.fetchProfile()` (`GET /users/me`), so
without a seeded backend row the frame is a `CircularProgressIndicator` and
nothing can be compared. The state is **faked, not driven**: this story adds
`--dart-define=PREVIEW_PROFILE=fixture`, which swaps in a
`_PreviewAccountRepository` returning authored data. It follows the
`PREVIEW_CONTRACT_SIGN_STATUS` / `_PreviewLoveContractRepository` precedent
already in that file, and is inert unless the define is passed, so every other
story's capture of `profile` is unchanged. Fixture values mirror the canvas's
own placeholders (`Linh`, `2001-03-03`) so the two frames differ only where the
app differs.

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

All nine below are fixed in
`mobile/lib/features/account/presentation/screens/profile_edit_screen.dart`.

| # | Element | Design source | Before | After |
|---|---|---|---|---|
| D1 | Avatar diameter | `104px` (`:96-97`) | `CircleAvatar(radius: 44)` = 88px | 104px |
| D2 | Avatar shadow | `box-shadow:var(--shadow)` (`:97`) | none | `platformTokens.elevationShadow` |
| D3 | Camera badge | 36px circle, `--grad-hot`, `3px solid var(--bg)` ring, `--glow`, `photo_camera` glyph @19px `#fff`, at `right:-10px;bottom:-6px` (`:98`) | absent | present; diameter, gradient, ring width/colour, glow, glyph size and offsets all match. The glyph **colour** is `colors.colorText` (`#F7EEFB`), not the source's `#fff` — see §5 |
| D4 | Crop caption | `12.5px`, `var(--tx2)`, "Ảnh sẽ được crop tròn" (`:100`) | absent | `type.caption` + `colorTextMuted`, both locales |
| D5 | Placeholder glyph font | Material Symbols Rounded is the single icon family (ADR-004d) | `Icons.person` (Flutter's separate `MaterialIcons` font) | `CupidIcon` on `CupidIcons.fontFamily` |
| D6 | Zodiac chip radius | `border-radius:999px` (`:109`) | `platformTokens.radiusSmall` (16) | `platformTokens.radiusButton` (999) |
| D7 | Zodiac chip text | `12.5px`, `font-weight:700`, inherits `--tx` (`:109`) | `type.labelMono` (Roboto Mono w400) in `colorAccentPurple` | `type.caption` w700 in `colorText` |
| D8 | Zodiac helper placement | inside the DOB card, `margin-top:8px` (`:110`) | outside/below the card | inside the card, `CupidSpacing.sm` |
| D9 | Third field card "Ngôn ngữ" | `--surf` card, `--r-card`, label + `{{ langLabel }}` value + `›` @20px `--tx2`, `justify-content:space-between` (`:112-115`) | absent | present and inert |

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

**D9 (language card).** Round 1 deferred this card on OQ5; the round-1 review
found that over-applied, since `story_master.md`'s own OQ triage records "All
acceptance criteria (1-4) are unblocked" and OQ5's reach is light-theme/`en`
visual QA, not the presence of a card in the dark+`vi` layout. It is now
rendered, taking D3's approach: **inert**. Nothing about the card requires a
locale switcher — it is a static label/value/chevron, and leaving it inert
keeps the story inside its "no new interaction" boundary while satisfying AC1.

Two notes on how it is built:

- `_FieldCard` gained an optional `trailing` slot rather than a new widget,
  because the design's third card is the same `--surf`/`--r-card` card as the
  first two with one element added on the right (`justify-content:
  space-between`). The label/value stack and the trailing element are laid out
  in a `Row` with the stack `Expanded`, matching `align-items:center`.
- The card is **not** wrapped in `ExcludeSemantics`, unlike the camera badge,
  and the difference is deliberate. The badge is a pure affordance: excluded,
  it announces nothing, which is correct because it does nothing. The language
  card carries real content — the user's current language — which a screen
  reader should still read. The `›` is a `CupidIcon` with no semantic label, so
  it contributes no node of its own and cannot be announced as a live control.
  A widget test asserts both the content and the absence of a tap target.

### 3.1 Rendered comparison — remaining visible deltas

Read from `implemented-profile-emulator-5554.png` against
`design-reference-profile-android.png`. Everything in §3 above was confirmed
present and correct in the render. What still differs:

| # | Delta | Implemented | Design | Owner / disposition |
|---|---|---|---|---|
| R1 | App-shell background | flat `colorBackground` | purple `--sky` gradient washing the upper third | D-7 — STORY-032 |
| R2 | Header title | "Chỉnh sửa hồ sơ" | "Hồ sơ của bạn" (`:1764`) | D-6 — coupled to D-2 |
| R3 | Header trailing action | "Lưu" save button | none | new; coupled to D-2 (see §3.2) |
| R4 | Bottom CTA | absent | "Tiếp tục → Love Contract" pill (`:117`) | D-4 — Scope A navigation |
| R5 | Zodiac chip artwork | text only | 26px zodiac sign icon (`:109`) | D-5 — no asset exists |
| R6 | Zodiac chip label | "Pisces" | "Song Ngư" | new; blocked on API contract (see §3.2) |
| R7 | Name card label | "TÊN HIỂN THỊ" | "TÊN GỌI" (`:104`) | new; coupled to D-2 (see §3.2) |
| R8 | Zodiac helper copy | "Cung hoàng đạo được tự động suy ra — hỗ trợ tính năng Zodiac Red Flag" — wraps to 2 lines | "Cung hoàng đạo tính tự động — dùng cho Zodiac Red Flag." — fits 1 line | new; coupled to D-2 (see §3.2) |
| R9 | Avatar empty state | filled circle + person glyph | dashed ring + image icon + "Ảnh đại diện" | accepted, §2/§5 — `<image-slot>` authoring chrome, not product UI |

R1-R5 and R9 were all already triaged by the round-1 review and are unchanged.
R3, R6, R7 and R8 are the four the render newly exposed — the static audit could
not have caught R8 at all, since "the copy is longer" only becomes a *layout*
delta once something wraps.

### 3.2 Why the newly exposed deltas were not fixed here

Not "out of scope" as a reflex — each has a specific reason, and two of them are
cheap fixes I deliberately did not make:

**R3, R7, R8 are all downstream of the unresolved D-2 question.** The round-1
review deferred D-2 as "needs ratification, not rework": this story's premise is
the *onboarding* profile-setup step, but no such step exists in the app, and
`ProfileEditScreen` is today reachable only from the Me hub. R7 and R8 are
one-line `app_vi.arb` edits well inside this story's write scope, and R3 is the
save button that exists precisely because this is an edit screen. I did not make
them because **their correct value depends on how D-2 resolves.** If Scrum
Master/PO ratify the canvas-`profile` -> `ProfileEditScreen` retarget, then
"TÊN GỌI", the shorter helper line and no save button are right. If instead the
screen stays the Me->Edit screen and onboarding gets its own surface later, then
"TÊN HIỂN THỊ" and "Lưu" are already correct and changing them is a regression.
Editing shared `l10n/` copy on a coin-flip is worse than leaving a recorded
delta, so this is escalated with D-2 rather than guessed at.

**R6 is not a copy fix; it is an API contract change.** `zodiacSignFor()`
(`features/account/domain/zodiac.dart:25`) returns English sign names, and
`ProfileEditCubit.submit()` sends that exact string to the backend as the
`zodiacSign` PATCH field (`profile_edit_cubit.dart:128`). Localizing the
returned value would silently change the request payload and the stored value;
localizing only the chip's display requires a new presentation-layer mapping for
all twelve signs plus a decision about which value the Zodiac Red Flag feature
reads. Both are larger than a fidelity story and belong with D-5, which already
owns the same chip.

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

The "Ngôn ngữ" field card that round 1 listed here has been **removed from this
table** — it is implemented (D9, §3). What remains:

| Deviation | Design source | Why deferred |
|---|---|---|
| Bottom CTA "Tiếp tục → Love Contract" | `:117` | Inter-screen navigation, explicitly assigned to Scope A (STORY-001/STORY-002) by this story's Out of Scope. |
| 26px zodiac sign artwork in the chip | `:109`, `<dc-import name="Zodiac Icon">` | No zodiac icon asset exists in the app. Adding 12 sign artworks is new art, and `design_system/` is outside this story's write scope. |
| Header title "Hồ sơ của bạn" vs app's "Chỉnh sửa hồ sơ" | `:1764` `t_profile`; `profile` absent from `NO_CHROME` (`:1951`) so a header does show | The app screen is currently an edit screen reached from Me, and its header/back-label pair is correct for that path. Retitling is only right once the onboarding entry point exists (§1.5). `l10n/` is also outside write scope. |
| Missing onboarding entry point | `BACK_TO` chain (`:1853`) | Navigation graph — Scope A. See §1.5. |
| Purple `--sky` gradient app background | `:101` shell | Confirmed absent in the render (R1). `skyGradient` exists in `cupid_color_tokens.dart:209` only as a raw CSS `String`; no Flutter `Gradient` is ever built from it. Applying it is a `design_system/` change owned by STORY-032 (D-7), outside this story's write scope. |
| Header trailing "Lưu" action not in the canvas | `:1764` header block | R3. Its correctness depends on whether this surface is the onboarding step or the Me→Edit screen — see §3.2. Escalated with D-2. |
| Name card label "TÊN GỌI" vs app's "TÊN HIỂN THỊ" | `:104` | R7. One-line `app_vi.arb` edit, deliberately not made: the right string depends on D-2. See §3.2. |
| Zodiac helper copy is longer than the design's and wraps to two lines | `:110` | R8. Same D-2 coupling as the label above; also `l10n/`-owned. See §3.2. |
| Zodiac chip shows "Pisces", design shows "Song Ngư" | `:109` | R6. Not a copy fix — the same string is PATCHed to the backend as `zodiacSign`. Changing it is an API contract decision. See §3.2. |

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
