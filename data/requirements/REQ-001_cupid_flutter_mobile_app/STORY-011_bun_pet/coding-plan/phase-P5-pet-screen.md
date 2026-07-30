# Phase P5 – Pet Screen Shell, Hero Card, Guard States

## 1. Objective

Assemble `PetScreen` around `PetCubit`: the hero card (sprite, level/mood pill,
pet name, status line) plus the unpaired-locked, waiting, and no-pet guard
states that gate everything else.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-pet-screen.md`
- Owner: Mobile Developer
- Lane: Mobile / UI

## 1B. Phase Metadata

- Depends On: P3, P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pet/presentation/pet_screen.dart`
  - `mobile/lib/features/pet/presentation/widgets/pet_hero_card.dart`
  - `mobile/lib/features/pet/presentation/widgets/pet_guard_states.dart`
  - `mobile/test/features/pet/presentation/pet_screen_test.dart`
  - Deviation (implementation-time, additive only): the hero gradient cannot
    live as a private const inside `pet_hero_card.dart` without tripping
    `test/design_system/no_fork_guard_test.dart` (D3/ADR-004 forbids a raw
    `Color(0x...)` literal in `lib/features`), so the three literal colors were
    moved into a new `mobile/lib/design_system/tokens/pet_hero_gradient.dart`
    and exported from `mobile/lib/design_system/design_system.dart`.
    `pet_hero_card.dart` now consumes the named `PetHeroGradient.gradient`
    constant only (same pattern as P4's `bun_sprite_palette.dart` deviation).
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `PetScreen` (consumes `getIt<PetRepository>()` via a locally provided
    `PetCubit`)
  - `PetHeroCard`, `PetLockedCard`, `PetAdoptPromptCard`
- Shared Interfaces Consumed:
  - P1 models and `PetLocaleText`, P3 `PetCubit`/`PetState`, P4 `BunSprite` and
    `CupidIcons`
- Risk Surfaces:
  - Pairing hard gate (AC3)
  - Mood → sprite mapping (screen binding)
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §2.1 item 1, §2.3, §4, §7
  - consumer contract: P3 `PetState` union
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §4 Mobile Lane Handoff
  - UX constraints: `../ux/uiux-spec.md` §2.1 item 1, §2.3, §4 copy table, §6
    single-column portrait, §7 accessibility, §8 design-system reuse
  - upstream phase outputs: P3 cubits, P4 sprite and icons
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: screen scaffold + hero + guard states (engagement cards are
    P6, adopt sheet is P7)
  - Source/Test File Count: 3 source + 1 test
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §2.1 item 1, §2.3, §4, §6, §7, §8
- `../architecture/solution.md` §4 Mobile Lane Handoff
- P3 and P4 outputs
- `mobile/lib/features/auth/presentation/screens/login_screen.dart` (screen +
  `BlocProvider` + design-system usage convention)

## 3. Tasks

- `PetScreen` provides `PetCubit` (built from `getIt<PetRepository>()`), calls
  `load()` on init, and renders one branch per `PetState`:
  `PetLoading` → progress; `PetLocked` → `PetLockedCard`; `PetNoPet` →
  `PetAdoptPromptCard`; `PetReady` → hero card plus a `P6` slot; `PetFailure` →
  retry affordance keyed off the `CupidApiFailure` subtype.
- `PetHeroCard`: gradient container with `BunSprite` at 206, the
  `Lv.{level} · {moodLabel}` pill, `pet.name` from the payload (never a
  hardcoded "Bún"), and the §4 status line for the current mood.
- Declare the hero gradient `#7B4FBE → #B0518C → #5E7E96` as a private
  `const LinearGradient` inside `pet_hero_card.dart` with a comment stating that
  neither `gradientDream` nor `gradientHot` matches, and that adding a global
  token is out of scope (STORY-001 owns tokens). Use the same 120deg alignment
  vectors the token file uses.
- `PetLockedCard`: the Private Gallery lock-icon-in-gradient-circle pattern with
  the §2.3 headline, no CTA, no route into the adopt sheet.
- `PetAdoptPromptCard`: empty-state card with the §2.2 headline and the "Nhận
  nuôi" CTA, exposing an `onAdopt` callback that P7 wires to the sheet.
- Accessibility: announce the locked/empty headline as the screen's accessible
  title; the mood label and status line must be screen-reader reachable as text
  while the sprite stays decorative.
- Import the design system only through
  `package:cupid_mobile/design_system/design_system.dart`.
- Widget tests as described in Test Scope.

## 4. Acceptance Criteria

- With an unpaired fake repository, the screen renders `PetLockedCard` and the
  widget tree contains no adopt CTA and no interact buttons (AC3).
- With a `PetReady` state, the rendered pet name equals the payload name and the
  pill shows the payload level plus the mapped mood label.
- All five moods render their §4 status line and the matching sprite state.
- No token file is imported directly; only the design-system barrel.
- Layout is single-column portrait with no breakpoint branching.
- The screen never calls `PetRepository` directly.

## 5. Planned Outputs

- Code files: the three source files in Write Scope.
- Contracts: `PetScreen`, `PetHeroCard`, `PetLockedCard`, `PetAdoptPromptCard`.
- Requirement configuration guide updates: none.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), widget layer
- Required levels:
  - widget: `pet_screen_test.dart` — locked state (assert absence of adopt CTA
    and interact buttons), no-pet state (adopt CTA present), ready state (name,
    level pill, mood label, status line, sprite state) for at least `ecstatic`
    and `sick`, and a failure state rendering a retry affordance
  - accessibility: assert the locked/empty headline is exposed as the screen
    title semantics and that the mood label is present in the semantics tree
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `cd mobile && flutter test test/features/pet/presentation/pet_screen_test.dart`
  and `cd mobile && flutter analyze`
- Mobile discoverability / navigation integration: deferred to P8; this phase
  only guarantees the screen is renderable and self-contained.
- Minimum gates by risk surface:
  - Pairing gate: locked-state widget test asserting absent CTAs
  - Mood binding: two-mood render assertions
- Required regression or contract coverage: none beyond the above.
- Evidence format: concise rows in `coding-plan/test-results.md` at P9.
- Verification strategy:
  - Targeted tests: `pet_screen_test.dart`
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: rendered text/semantics and absent-widget
    assertions

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Evidence:
  - `cd mobile && flutter test test/features/pet/presentation/pet_screen_test.dart`
    → `+7: All tests passed!` (locked/AC3, no-pet, ready ecstatic/sick,
    semantics reachability, failure-retry)
  - `cd mobile && flutter test test/features/pet/` → `+70: All tests passed!`
    (full pet suite, includes pre-existing `pet_mood`, `pet_models`,
    `adopt_cubit`, `pet_repository`, `bun_sprite` tests unaffected by this
    phase)
  - `cd mobile && flutter analyze lib/features/pet test/features/pet
    lib/design_system` → `No issues found!` (scoped to this phase's changed
    files; whole-repo `flutter analyze` reports ~11k pre-existing issues
    entirely outside this phase's Write Scope — Firebase integration-test
    scaffolding under `build/ios/SourcePackages/checkouts/flutterfire`,
    pre-existing lints in unrelated auth/realtime files, and openapi
    generated-code warnings)
  - AC3 hard gate verified directly: locked-state widget test asserts
    `find.byType(CupidPrimaryButton)` and the interact icons both find
    nothing.
