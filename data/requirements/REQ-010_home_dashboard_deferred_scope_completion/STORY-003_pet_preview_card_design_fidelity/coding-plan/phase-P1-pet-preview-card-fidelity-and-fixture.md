# Phase P1 – Pet Preview Card Ready-State Fidelity And Preview Fixture

## 1. Objective

The `PetReady` variant of the Home pet preview card renders exactly as the
locked design source specifies, and the design-fidelity capture harness can
photograph that variant instead of an authentication failure placeholder.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-pet-preview-card-fidelity-and-fixture.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/lib/main_preview.dart`
  - `mobile/test/features/pet/presentation/widgets/pet_preview_card_design_fidelity_test.dart`
  - `mobile/test/features/home/home_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `devCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `HomeScreen({PetRepository? petRepository})` optional injection seam
  - `PREVIEW_PET_FIXTURE` dart-define on the `main_preview` entrypoint
- Risk Surfaces:
  - Ready-state chrome fidelity
  - Undepicted compact states unchanged
  - XP bar restructure
  - Fixture must not alter production behaviour
  - Tap target / entry-point reachability (AC4)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` section 4;
    `../ux/uiux-spec.md` §0-§5 owns every per-property correction
  - consumer contract: none (single lane, no external consumer)
- Primary Inputs Summary:
  - requirements: `../story_master.md` acceptance criteria AC1-AC4
  - architecture: `../architecture/solution.md` sections 1, 4, 6
  - upstream phase outputs: none
  - UX constraints: `../ux/uiux-spec.md` §0-§5 — required, it is the
    property-level correction table this phase implements
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one widget's ready-state repaint plus the injection path
    that makes that same repaint capturable
  - Source/Test File Count: 5 (3 source, 2 test)
  - Split Required: NO
  - Split Rationale: within one specialist lifecycle, and the fixture is the
    precondition for this phase's own AC1 rendered evidence

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md`

## 3. Tasks

1. Extract the tap contract: move the `Semantics(button:true, label:'Mở Bún')` +
   `GestureDetector(onTap: PetRoute.push)` wrapper out of `_PreviewShell` into a
   single small widget used by both shells. `_PreviewShell`'s decoration and
   padding stay byte-identical (`../ux/uiux-spec.md` §0).
2. Add the ready-only shell: gradient, border, clip, and glow per
   `../ux/uiux-spec.md` §1-§2. Use `colors.colorAccentPink.withAlpha(51)` →
   `colors.colorMint.withAlpha(41)` at 130°, `Border.all(color: colors.colorLine,
   width: 1)`, `ClipRRect` at `platformTokens.radiusCard`, and a `LayoutBuilder`
   -resolved `right: constraints.maxWidth * 0.12`, `top: -14`, 74×74 circular
   `RadialGradient` glow with `stops: [0.0, 0.7]`, wrapped in `IgnorePointer`.
   No `AnimationController`.
3. Restructure `_PreviewReady` per `../ux/uiux-spec.md` §3: center-aligned outer
   row; one baseline row holding the Nunito 17/w900 pet name and the level chip;
   chip text `'Lv.${status.pet.level}'` only, `colorAccentPink.withAlpha(56)`
   background, `BorderRadius.circular(6)`, `labelMono` at `fontSize: 10` in
   `colorAccentPink`; status caption at `fontSize: 12` in `colorTextMuted`.
4. Rebuild the XP bar with the `pet_xp_card.dart:68-89` pattern: `ClipRRect` →
   `Stack` → `Positioned.fill(ColoredBox(colors.colorSurface))` +
   `FractionallySizedBox(widthFactor: status.levelProgress.clamp(0.0, 1.0),
   child: DecoratedBox(gradient: colors.gradientDream))`, 8px tall, preceded by
   `SizedBox(height: CupidSpacing.sm)`. Do not reimplement level math.
5. Add the injection seam: optional `PetRepository? petRepository` on
   `HomeScreen`, following the existing `resolveProfile` field pattern, passed to
   the already-mounted `PetPreviewCard` at `home_screen.dart:191` (the mount
   loses `const`; it stays in the same position in the card column).
6. Add the fixture in `main_preview.dart`: a
   `const bool _petFixture = bool.fromEnvironment('PREVIEW_PET_FIXTURE');` gate
   and a `_PreviewPetRepository implements PetRepository` double next to its
   siblings, returning `PetPairing(isPaired: true)` and an authored `PetStatus`.
   Extend `_buildHome` to pass the double only when the define is set. Confirm
   in `pet_cubit.dart` which calls gate `PetReady` before authoring the values,
   and choose `totalInteractions` so `(totalInteractions % 50) / 50` matches the
   design canvas' rendered bar fill while `floor(totalInteractions / 50) + 1`
   equals the authored `level`; use `level: 3, totalInteractions: 145` (0.90) if
   the design canvas' own percentage cannot be resolved. Do not import anything
   from `mobile/test/`.
7. Capture the fixture-backed Home render (dark theme, `vi` locale) with the same
   design-fidelity preview path STORY-017 used for `PREVIEW_HOME_FIXTURE`, and
   compare the pet card against the design source's `isHome` pet node.

## 4. Acceptance Criteria

- Rendered ready-state card matches `../ux/uiux-spec.md` §1-§3 on background,
  border, clip, glow, row alignment, name/chip baseline row, chip fill/radius/
  type, caption size, and XP bar track/height/gradient (AC1, AC2).
- The captured Home evidence shows a populated `PetReady` card, not the
  "Không thể tải Bún" failure state (AC3).
- `PetLoading`, `PetLocked`, `PetNoPet`, and `PetFailure` render exactly as
  before: flat `colorSurface`, no gradient, no border, no glow.
- Tapping the card still reaches the pet feature from every state, and the card
  remains mounted in the same Home card-column position (AC4).
- A default `HomeScreen()` with the define omitted resolves the pet repository
  from the service locator exactly as today.

## 5. Planned Outputs

- Code: the three `mobile/lib/...` files in Write Scope.
- Tests: `pet_preview_card_design_fidelity_test.dart` (new), extended
  `home_screen_test.dart`.
- Notes or evidence: `coding-plan/test-results.md`, plus the captured render and
  its design-source comparison under the story's visual-fidelity evidence path.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile widget layer, dark theme + `vi` locale.
- Required levels:
  - unit: none beyond the widget tests below
  - mobile build/type-check/static-analysis: `flutter analyze` over the changed
    files, and the `mobile-app` registry `buildCommand`
  - visual inspection: fixture-backed Home capture vs. the design source's
    `isHome` pet node
- Required checks:
  - ready-shell decoration assertions (gradient stops and colors, border,
    `ClipRRect`, glow size/offset/`IgnorePointer`)
  - compact-state regression assertions for all four undepicted states
  - chip text is `Lv.N` with no mood suffix; chip fill, radius, and text color
  - XP bar track color, 8px height, `gradientDream` fill, and `widthFactor`
    equal to `levelProgress`
  - default `HomeScreen()` passes no repository override
- Mobile discoverability / navigation integration: tap on the ready card reaches
  `PetRoute`; `PetPreviewCard` still mounted in the Home card column.
- Minimum gates by risk surface: every row in `../architecture/solution.md`
  section 4 has at least one assertion above; the two fidelity rows additionally
  require the rendered capture.
- Required regression or contract coverage: existing
  `pet_entry_point_test.dart` and `home_screen_test.dart` stay green.
- Evidence format: test command + pass/fail counts in
  `coding-plan/test-results.md`; capture path plus per-property comparison in the
  visual-fidelity evidence file.
- Requirement mobile visual audit: YES
- Verification strategy:
  - Targeted tests: `flutter test test/features/pet/ test/features/home/`
  - Build/type-check: `flutter analyze` plus the registry `buildCommand`
  - Required assertion evidence: named widget-test assertions per risk surface,
    and the fixture-backed capture for AC1/AC3

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
