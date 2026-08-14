# Master Coding Plan – STORY-010 Design Fidelity — Onboarding Profile Setup

## 1. Planning Metadata

- Story ID: STORY-010_onboarding_profile_design_fidelity
- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Complexity: standard · Story-Class: standard · Lane: mobile (single lane)
- Design source (locked): `cupid-app-design-system/project/Cupid Screens.dc.html`
  canvas `profile` (lines 93-119), plus
  `cupid-app-design-system/project/Zodiac Icon.dc.html` for the zodiac glyph.
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  dependency, or third-party integration change. Two existing `--dart-define`
  preview flags (`PREVIEW`, `PREVIEW_PROFILE`) are reused unchanged.
- Artifact note: this story's Tech Lead write scope is `master-plan.md` only, so
  phase detail is inline in section 6 instead of a separate `phase-P1-*.md`
  file, and no `architecture/solution.md` is produced. The decision table in
  section 3 is the authoritative architecture record for this story.

## 2. Scope Restatement And Hard Constraints

Non-negotiable inputs from Product Owner + Scrum Master (already decided; the
implementer must not re-litigate):

- C1. Build a genuinely distinct onboarding profile-setup screen: its own file,
  its own widget class, no shared screen implementation with
  `ProfileEditScreen`.
- C2. `ProfileEditScreen` work already on this branch (through reviewed HEAD
  `49c7eab`) STAYS. It is not reverted, not modified, not "cleaned up" by this
  story. It becomes STORY-029's inherited starting point after this branch
  merges to the requirement integration branch.
- C3. Do-not-touch file set for this story:
  - `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart`
  - `mobile/test/features/account/presentation/screens/profile_edit_screen_test.dart`
  - `mobile/lib/features/account/presentation/profile_edit_cubit.dart`
  - `mobile/lib/features/account/domain/zodiac.dart` and
    `mobile/lib/features/account/domain/cupid_profile.dart` are read-only
    consumption only (import and call; no edits), so STORY-029 inherits them
    unchanged.
  - Known cosmetic artifact of C3: `profile_edit_screen_test.dart:153` has a
    group literally named "STORY-010 design fidelity against the `profile`
    canvas". After this story that name is historically wrong. Do NOT rename it
    — it is inside the do-not-touch set. It is recorded here so the reviewer
    does not read it as a scope leak.
- C4. No live onboarding navigation wiring. STORY-002 owns
  `permissions -> profile -> invite/joincode`. This story must not edit any
  router, `permissions` screen, `register_screen.dart`, `welcome_screen.dart`,
  `splash_screen.dart`, or `app_shell.dart` forward-transition logic.
- C5. No new feature, state, or interaction that the locked canvas does not
  author.

## 3. Tech Lead Decisions

### D1 — Screen file, class name, and directory

| Item | Value |
|------|-------|
| Screen file | `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart` |
| Screen class | `OnboardingProfileSetupScreen` |
| Route file | `mobile/lib/features/onboarding/presentation/onboarding_profile_setup_route.dart` |
| Route class | `OnboardingProfileSetupRoute` (`static const String name = '/onboarding/profile'`) |
| Zodiac glyph file | `mobile/lib/features/onboarding/presentation/widgets/zodiac_glyph.dart` |
| Widget test | `mobile/test/features/onboarding/presentation/screens/onboarding_profile_setup_screen_test.dart` |
| Glyph test | `mobile/test/features/onboarding/presentation/widgets/zodiac_glyph_test.dart` |

Why a brand-new `features/onboarding/` tree rather than `features/account/`:

- It is the structural expression of C1. Nothing in the new tree can be
  confused with, or accidentally coupled to, STORY-029's `features/account/`
  screen.
- The canvas itself places `profile` in the onboarding chain
  (`BACK_TO.profile == 'permissions'`, `NO_TABS[profile] == 1`), while canvas
  `me` is a bottom-tab destination. The directory now matches the design's own
  taxonomy.
- Parallel-delivery benefit: every new file lands in a directory no other
  REQ-002 story writes to, so the only integration-merge contact point with
  sibling stories is the single edited file in D3.

### D2 — Route registration approach: route-factory class, not a global routes table

There is no `routes:`/`onGenerateRoute` table anywhere in this app; navigation
is imperative `MaterialPageRoute` everywhere. The established pattern for
"a screen that needs one unambiguous entry point" is the route-factory class at
`mobile/lib/features/pet/presentation/pet_route.dart`. Mirror it exactly:

```dart
class OnboardingProfileSetupRoute {
  const OnboardingProfileSetupRoute._();
  static const String name = '/onboarding/profile';
  static Route<void> route({required CupidProfile profile, required VoidCallback onContinue});
  static Future<void> push(BuildContext context, {required CupidProfile profile, required VoidCallback onContinue});
}
```

- `route()` sets `settings: const RouteSettings(name: name)` like `PetRoute`.
- Adding this class is NOT a live navigation transition: nothing in the shipped
  app calls `push()` after this story. It exists so STORY-002's wiring is a
  one-line call from the permissions step instead of a second discovery pass.
  This satisfies In Scope §3 without breaching C4/AC4.
- Do not register a global named-route map; introducing one would be an
  architecture change far outside this story.

### D3 — Preview/canvas registration: repoint canvas `profile` to the new screen

`mobile/lib/main_preview.dart` maps DESIGN canvas ids to shipped screens. Today
`'profile'` (line 185) builds `ProfileEditScreen` via `_buildProfile` (line
401). Under the revised scope, canvas `profile` IS the onboarding setup screen,
so the `'profile'` entry must build `OnboardingProfileSetupScreen`. Without this
the AC1/AC2 comparison cannot run through the established capture pipeline at
all.

Exact edit set inside `main_preview.dart` (this is the ONLY existing source file
this story modifies):

1. `_buildProfile` returns `OnboardingProfileSetupScreen` instead of
   `ProfileEditScreen`, keeping the existing `FutureBuilder` +
   `_PreviewAccountRepository` + `_previewProfileFixture` +
   `--dart-define=PREVIEW_PROFILE=fixture` machinery unchanged. Pass a no-op
   `onContinue` (the harness has no destination; see D6).
2. Replace the `profile_edit_screen.dart` import (line 54) with the new screen's
   import. The old import must go or `flutter analyze` fails on `unused_import`.
3. Update the `'profile'` entry's `seedNote` to name the new screen.
4. `wrapInShell` stays absent/false — `NO_TABS[profile] == 1` in the design
   source, so no bottom tab bar.

Consequences to record, not to fix here:

- `ProfileEditScreen` ends up with no canvas id in the preview registry. That is
  correct: the Me-hub "edit" affordance (`Cupid Screens.dc.html:982`) has no
  design-specified target canvas of its own. STORY-029 decides its fidelity
  target and may add its own registry entry then.
- `profile_edit_screen_test.dart` does not import `main_preview.dart` (verified),
  so this repoint cannot break it. Re-running that test unchanged is part of the
  P1 gate.

### D4 — Data source for the three display fields

- Source of truth: `GET /users/me` via
  `AccountRepository.fetchProfile()` → `CupidProfile`
  (`displayName`, `birthday`, `language`, `photoUrl`).
- The screen is PRESENTATIONAL: it takes an already-fetched
  `required CupidProfile profile` and performs no I/O, no cubit, no
  `FutureBuilder`.
  - Rationale 1: the canvas authors no loading state and no error state.
    A screen that owns its own fetch would have to invent both, breaching C5
    and making the AC1/AC2 comparison dishonest.
  - Rationale 2: this mirrors the existing precedent — `me_screen.dart:58`
    pushes a profile screen with an already-fetched `CupidProfile`.
  - Rationale 3: the preview harness already owns the fetch
    (`_buildProfile`'s `FutureBuilder`), so nothing needs to be rebuilt.
  - Consequence for STORY-002: its wiring step must resolve a `CupidProfile`
    (fetch, or reuse whatever the onboarding chain already holds) before
    calling `OnboardingProfileSetupRoute.push`. This is stated in section 7 as
    the handoff note.
- No fetch is added and no new repository method is added by this story.

### D5 — Render as authored (display step), not an editable form

In Scope §2 permits in-place editing only if a concrete product reason requires
it. There is none, and there is a concrete reason against it:

- The canvas renders `{{ myName }}`, `{{ myDob }}`, `{{ langLabel }}` as static
  text with no input chrome, no focus state, and no save affordance. Turning
  them into inputs would be a visible AC1 deviation on a story whose entire
  purpose is exact fidelity.
- The app already has an editable profile surface (`ProfileEditScreen`,
  STORY-029). Duplicating edit+PATCH here would be exactly the shared-behavior
  overlap C1 exists to prevent.

Formatting rules (all derived from the canvas' own placeholder values):

| Field | Source | Rule |
|-------|--------|------|
| Display name | `profile.displayName` | verbatim; `null` → `'—'` |
| Date of birth | `profile.birthday` | `DateFormat('dd/MM/yyyy')` (`intl` already a dependency) matching canvas `03/03/2001`; `null` → `'—'` |
| Zodiac | derived from `profile.birthday` via existing `zodiacSignFor()` in `features/account/domain/zodiac.dart` | canvas says "tính tự động"; derive, do not read `profile.zodiacSign`, so value and helper text cannot disagree. `birthday == null` → hide the whole chip (same precedent as `profile_edit_screen.dart:213`) |
| Language | `profile.language` | `'vi' → 'Tiếng Việt'`, `'en' → 'English'`, matching canvas `langLabel`; unknown code → show the raw code |

The `'—'` fallbacks and the hidden chip are engineering fallbacks for nullable
backend fields, not new design states: `register_screen.dart:135` only ever
sets `displayName`, so `birthday` really can be null at this point in the real
chain. The fixture used for capture is fully populated, so the AC1 comparison
is always against the populated rendering.

### D6 — Interaction contract (what is live, what is inert)

Read from the canvas markup, not from intuition:

| Element | Canvas markup | Implementation |
|---------|---------------|----------------|
| CTA "Tiếp tục → Love Contract" | `onClick="{{ goContract }}"` | rendered ENABLED, wired to a `required VoidCallback onContinue` constructor parameter. This story supplies no destination; the preview harness passes a no-op and STORY-002 passes the real transition. `onContinue` is required (not nullable) precisely so the button can never render in a disabled/greyed state during capture, which would itself be an AC1 deviation |
| Camera badge on the avatar | `cursor:pointer`, no `onClick` | inert, wrapped in `ExcludeSemantics` (same precedent as `profile_edit_screen.dart:350`) so it is never announced as a button that does nothing. No `image_picker` work in this story (C5) |
| Language card chevron `›` | no `onClick` on the card | inert visual affordance only; no tap target, no language switcher |
| Header back | canvas `canBack` is true (`BACK_TO.profile == 'permissions'`) | `onBack: () => Navigator.of(context).maybePop()` — the design-authored back affordance, same as `invite_screen.dart:132`. This is chrome, not a new forward transition, so it does not breach C4/AC4 |

### D7 — Screen chrome

Canvas `profile` is absent from `NO_CHROME` and present in `NO_TABS`, so: shared
header, no bottom tabs.

- `Scaffold(appBar: CupidHeader(...), backgroundColor: colors.colorBackground,
  body: SafeArea(child: SingleChildScrollView(...)))` — the `invite_screen.dart`
  structure.
- Header title: `L.t_profile` = `'Hồ sơ của bạn'` / `'Your profile'`
  (`Cupid Screens.dc.html:1764`, `:1776`). It must NOT reuse the existing
  `profile_edit_title` ARB key ("Chỉnh sửa hồ sơ") — different screen, different
  string.
- Localization mechanism: the file-local `viEn(vi, en)` `BuildContext` extension
  pattern used by the neighbouring onboarding/pairing screens
  (`invite_screen.dart:131`, `app_shell.dart:122`,
  `preview_app_shell_chrome.dart:90`). Do NOT add ARB keys or regenerate
  `l10n/generated/*` for this story: the ARB files are a cross-story shared
  surface in a parallel wave, and this screen's strings are all
  canvas-verbatim two-locale literals. `backLabel: viEn('Quay lại', 'Back')`.
- `SingleChildScrollView` is required despite the canvas being a fixed frame:
  the content plus header exceeds the safe area on small devices. It introduces
  no visible chrome at the capture size.

### D8 — Zodiac glyph

The chip in the canvas (line 109) embeds
`<dc-import name="Zodiac Icon" sign="{{ myZodiacSign }}" width/height 26px>`.
There is no zodiac asset in the app and `flutter_svg` is NOT a dependency
(`pubspec.yaml` has `image_picker`, `cached_network_image`, `intl` only), so:

- Implement `ZodiacGlyph` as a `CustomPainter` over a `100x100` logical
  viewBox scaled to the requested size, porting the stroke paths from
  `Zodiac Icon.dc.html` (`stroke-width: 6`, round cap, round join, `fill: none`,
  plus the `r=48` background disc at `cx/cy = 50`).
- Port all 12 signs. Sign metadata comes from that file's own `SIGNS`/`EL` maps
  (`Zodiac Icon.dc.html:106-125`): element per sign, and element colors
  `fire #FF9576 / disc rgba(255,149,118,.16)`,
  `earth #5FD3BC / rgba(95,211,188,.16)`,
  `air #B78CF5 / rgba(183,140,245,.18)`,
  `water #FF7FB6 / rgba(255,127,182,.16)`.
- Those hex values are design-component constants, not app theme tokens.
  Annotate them with a short `@ds-adherence-ignore` comment naming
  `Zodiac Icon.dc.html`, following the existing precedent at
  `profile_edit_screen.dart:296`.
- The same file owns the vi/en display labels from `SIGNS`
  (`Bạch Dương/Kim Ngưu/Song Tử/Cự Giải/Sư Tử/Xử Nữ/Thiên Bình/Bọ Cạp/Nhân Mã/
  Ma Kết/Bảo Bình/Song Ngư`), mapped from the English sign string returned by
  the existing `zodiacSignFor()`. Do not edit `zodiac.dart` to add labels (C3).
- Keep the glyph feature-local for now. Promotion to
  `design_system/icons/` is deliberately deferred: it would force an edit to the
  shared `design_system/design_system.dart` barrel, which is the file most
  likely to conflict at requirement integration in this parallel wave. Record
  the promotion path as a note for whoever needs the glyph on a second screen.

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: path `mobile`, type `flutter-app`,
    `testCommand: flutter test`, `buildCommand: flutter build apk --debug`
    (`data/devops/system/runtime-command-registry.json` → `mobile-app`).
- Backend: no change. No API, DTO, migration, or contract change.
- DevOps: no change. No registry, env, or deployment change.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | PENDING |

Phase sizing rationale (single phase is deliberate):

- P1 touches 6 files: 4 new source/test files in a new directory, 1 new glyph
  file plus its test, and 1 edited existing file. That is one specialist
  lifecycle.
- Splitting the glyph into its own phase was considered and rejected: it is the
  same lane, same specialist, same behavior cluster (one screen's authored
  content), and the split would buy a second dispatch plus a second verification
  pass for two files.
- No trailing verification phase: P1 owns its own tests, its own static-analysis
  gate, and its own visual-fidelity capture.

## 6. Phase P1 — Onboarding profile setup screen (inline phase detail)

Goal: canvas `profile` exists in the app as its own screen, renders correctly
standalone, and matches the locked design source in dark + `vi`.

### 6.1 Files

New:

1. `mobile/lib/features/onboarding/presentation/widgets/zodiac_glyph.dart`
2. `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart`
3. `mobile/lib/features/onboarding/presentation/onboarding_profile_setup_route.dart`
4. `mobile/test/features/onboarding/presentation/widgets/zodiac_glyph_test.dart`
5. `mobile/test/features/onboarding/presentation/screens/onboarding_profile_setup_screen_test.dart`

Edited (the only existing source file in scope):

6. `mobile/lib/main_preview.dart` — exactly the four changes in D3.

Any other existing file appearing in the diff is a scope breach.

### 6.2 Build order

1. `zodiac_glyph.dart` — 12-sign painter + element colors + vi/en labels (D8).
2. `onboarding_profile_setup_screen.dart` — chrome (D7), avatar block, three
   cards, CTA (D5/D6), private `_viEn` helper, private `_AvatarSlot`-style and
   `_FieldCard`-style widgets defined LOCALLY in this file. Do not import
   anything from `profile_edit_screen.dart` (its helpers are private anyway) and
   do not extract a shared widget from it.
3. `onboarding_profile_setup_route.dart` — `PetRoute` mirror (D2).
4. `main_preview.dart` repoint (D3).
5. Tests.

### 6.3 Canvas → Flutter token mapping (fidelity target)

Body container: `padding:22px 20px 40px` → `EdgeInsets.fromLTRB(20, 22, 20, 40)`;
column gap `22`.

| Canvas | Flutter |
|--------|---------|
| avatar `104x104`, `border-radius:50%`, `box-shadow:var(--shadow)` | `104` circle, `platformTokens.elevationShadow` |
| avatar empty placeholder | app person glyph via `CupidIcon`, `size: 52`, `colors.colorTextMuted` (the canvas `<image-slot>`'s "drop an image" chrome is canvas tooling, not product design — same reading as `profile_edit_screen.dart:296-299`) |
| avatar populated | `DecorationImage(image: NetworkImage(profile.photoUrl!), fit: BoxFit.cover)` |
| camera badge `36x36`, `right:-10`, `bottom:-6`, `var(--grad-hot)`, `3px solid var(--bg)`, `var(--glow)`, icon `photo_camera` 19px | `colors.gradientHot`, `Border.all(color: colors.colorBackground, width: 3)`, `colors.glowShadow`, `CupidIcon` 19px |
| caption `12.5px var(--tx2)` "Ảnh sẽ được crop tròn" | `type.caption` + `colors.colorTextMuted`, gap `12` above |
| card `background:var(--surf)`, `border-radius:var(--r-card)`, `padding:14px 16px` | `colors.colorSurface`, `platformTokens.radiusCard`, `EdgeInsets.symmetric(horizontal: 16, vertical: 14)` |
| card gap `12` | `SizedBox(height: 12)` |
| label `11px`, `letter-spacing:.06em`, uppercase, `var(--tx2)`, `margin-bottom:5px` | `type.caption.copyWith(color: colors.colorTextMuted, letterSpacing: 0.66)` on `label.toUpperCase()`, gap `5` |
| value `17px/600` | nearest typography token with `fontWeight: FontWeight.w600` |
| zodiac chip `padding:5px 12px 5px 5px`, `border-radius:999`, `var(--surf2)`, `12.5px/700`, gap `7`, glyph `26x26` | `colors.colorSurfaceAlt`, `BorderRadius.circular(999)`, `ZodiacGlyph(size: 26)` |
| zodiac helper `11.5px var(--tx2)`, `margin-top:8px` | `type.caption` + `colors.colorTextMuted`, gap `8` |
| language chevron `›` `20px var(--tx2)` | `CupidIcon` chevron-right glyph at `20`, `colors.colorTextMuted`. Do NOT render the literal `›` character — the app font has known missing-glyph (tofu) behavior for non-ASCII punctuation, and a tofu box is an automatic AC1 failure |
| CTA `height:52`, `var(--r-btn)`, `linear-gradient(95deg,var(--pink),var(--purple))`, `16.5px/700`, `var(--glow)` | prefer `CupidPrimaryButton`. Verify its rendered height/radius/gradient/type against these values first; if it deviates, build the CTA locally inside this screen file and record why. Do NOT modify `cupid_primary_button.dart` — it is shared with every other screen's fidelity |

Typography rule: use the design-system typography tokens. Where a token's
rendered size differs perceptibly from the canvas px value, keep the token and
record it as a token-level finding in the visual-fidelity report rather than
hard-coding a one-off `fontSize` on this screen — tokens are shared across all
4 theme/locale combinations (Out of Scope, OQ5).

### 6.4 Tests (P1 owns these)

`zodiac_glyph_test.dart`:

- all 12 signs build without exception at `size: 26`;
- element color mapping is correct for one sign per element;
- unknown/unsupported sign string falls back to the design component's own
  default (`cancer`, `Zodiac Icon.dc.html:129`) rather than throwing.

`onboarding_profile_setup_screen_test.dart` (dark + `vi`, wrapped like existing
screen tests):

1. renders the header title `Hồ sơ của bạn` and the three labels
   `TÊN GỌI` / `NGÀY SINH` / `NGÔN NGỮ`;
2. renders values from a populated `CupidProfile`: name verbatim,
   `03/03/2001` for `DateTime(2001, 3, 3)`, `Tiếng Việt` for `language: 'vi'`;
3. zodiac chip shows `Song Ngư` plus a `ZodiacGlyph` for that birthday;
4. AC3 empty avatar state: placeholder glyph present, decoration has no
   `DecorationImage`;
5. AC3 populated avatar state: assert the `BoxDecoration`'s `DecorationImage`
   provider is a `NetworkImage` with the expected url — assert on widget
   configuration, do not pump a real image fetch (there is no `HttpOverrides`
   test helper in this repo and a live fetch would fail the test);
6. `null` `displayName`/`birthday` renders `'—'` and hides the zodiac chip
   without throwing;
7. CTA is enabled and invokes `onContinue` exactly once on tap;
8. AC4 standalone render: the screen builds inside a bare `MaterialApp` with no
   router, no shell, no seeded navigation, and pushes no route by itself.

### 6.5 Gates

- `flutter analyze` clean (no new warnings; `unused_import` in
  `main_preview.dart` is the expected trap — see D3.2).
- `flutter test` for the `mobile` package, green, including an explicit re-run
  of the untouched
  `test/features/account/presentation/screens/profile_edit_screen_test.dart`
  to prove the D3 repoint did not disturb STORY-029's inherited work.
- Visual fidelity capture for canvas `profile` in dark + `vi` through the
  existing harness:
  `flutter run -t lib/main_preview.dart --dart-define=PREVIEW=profile
  --dart-define=PREVIEW_PROFILE=fixture --dart-define=PREVIEW_BRIGHTNESS=dark`
  (screen id can also be switched at runtime via `cupidpreview://screen/profile`).
  The existing fixture (`displayName: 'Linh'`, `birthday: 2001-03-03`,
  `language: 'vi'`) already matches the canvas' own placeholder values
  (`myName: 'Linh'`, `myDob: '03/03/2001'`, `Song Ngư`, `Tiếng Việt`), so it
  needs no change.
- `visual-fidelity/visual-fidelity-report.md` in this story folder is STALE — it
  documents the superseded ProfileEditScreen round. Mobile Developer rewrites it
  for the new screen; it must not be appended to as if it were the same subject.
- Story runtime startup smoke: scoped to the preview-harness launch above
  (`mobile-app`); no backend or emulator lifecycle work beyond it.

### 6.6 AC mapping

| AC | Covered by |
|----|------------|
| AC1 (exact match, dark + `vi`) | 6.3 mapping + 6.5 capture + tests 1-3 |
| AC2 (deviations corrected in the app, re-verified) | 6.5 capture loop, report rewritten |
| AC3 (avatar empty + populated) | D8/6.3 avatar rows + tests 4-5 |
| AC4 (renders standalone, adds no live navigation) | D2 + D6 + test 8; no router/onboarding file in the diff |

## 7. Notes And Downstream Handoff

- For Scrum Master → STORY-002's implementer (its AC2 wiring):
  push `OnboardingProfileSetupRoute.push(context, profile: <CupidProfile>,
  onContinue: <next step>)` from
  `mobile/lib/features/onboarding/presentation/onboarding_profile_setup_route.dart`;
  screen class `OnboardingProfileSetupScreen`; route name `/onboarding/profile`.
  STORY-002 must resolve the `CupidProfile` before pushing (D4) and owns the
  CTA destination (D6). Note the design's own CTA target is `contract`
  (`goContract`) while STORY-002's chain text says `invite`/`join-code` — that
  reconciliation is STORY-002's decision, not this story's.
- For STORY-029: it inherits `ProfileEditScreen` exactly as this branch leaves
  it, including the round-2 deferred findings R3/R7/R8 and D-2/D-5, plus the
  fact that it no longer holds a preview canvas id (D3) and that its test file
  carries a now-misleading STORY-010 group name (C3).
- Deferred by design, not forgotten: avatar upload/crop behavior (the badge is
  inert per D6), language switching from the third card, and promotion of
  `ZodiacGlyph` into `design_system/icons/` (D8).
