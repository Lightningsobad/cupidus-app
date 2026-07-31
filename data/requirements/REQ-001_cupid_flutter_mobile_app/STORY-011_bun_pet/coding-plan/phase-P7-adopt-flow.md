# Phase P7 – Adopt Flow

## 1. Objective

Build the net-new adopt bottom sheet (species picker + name field + submit
states) and wire it to the `PetAdoptPromptCard` CTA.

## 1A. Ownership

- Phase ID: P7
- Canonical Phase File: `phase-P7-adopt-flow.md`
- Owner: Mobile Developer
- Lane: Mobile / UI

## 1B. Phase Metadata

- Depends On: P5
- Parallelizable: YES (independent of P6)
- Write Scope:
  - `mobile/lib/features/pet/presentation/widgets/adopt_sheet.dart`
  - `mobile/lib/features/pet/presentation/widgets/species_picker.dart`
  - `mobile/lib/features/pet/presentation/pet_screen.dart` (wire the
    `PetAdoptPromptCard` `onAdopt` callback only)
  - `mobile/test/features/pet/presentation/widgets/adopt_sheet_test.dart`
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
  - `showAdoptSheet(BuildContext, {required AdoptCubit cubit})`
  - `SpeciesPicker`
- Shared Interfaces Consumed:
  - P1 `PetSpecies` and `PetLocaleText`, P3 `AdoptCubit`/`AdoptState`, P4
    `CupidIcons` and `BunSprite`, P5 `PetAdoptPromptCard`
- Risk Surfaces:
  - Adopt input validation
  - Pairing hard gate (AC3) — sheet reachability
- Source Of Truth:
  - authoritative artifact: `backend/src/modules/pets/dto/adopt-pet.dto.ts`
    (species enum, name 1-30), `pets.service.ts` `adopt` preconditions
  - consumer contract: P3 `AdoptState` union
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` D3, §3 assumptions 3-5
  - UX constraints: `../ux/uiux-spec.md` §2.2 (entry point, sheet, submit
    states), §5 Open Items 3-5, §6 sheet sizing, §7 modal accessibility, §8 sheet
    chrome and `popIn`
  - upstream phase outputs: P3 `AdoptCubit`, P5 prompt card
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one modal flow
  - Source/Test File Count: 3 source (2 new, 1 additive edit) + 1 test
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §2.2, §5 Open Items 3-5, §6, §7, §8
- `../architecture/solution.md` D3, §3 assumptions
- P3 and P5 outputs
- `mobile/lib/features/auth/presentation/sign_out_confirm_dialog.dart` (modal
  focus/dismiss convention)

## 3. Tasks

- `showAdoptSheet`: content-height bottom sheet using
  `CupidPlatformTokens.radiusSheet` and safe-area bottom padding. No new sheet
  variant.
- `SpeciesPicker`: three horizontally scrollable cards for `cat`, `dog`, and
  `bunny`, exposed as a single-select radio-group semantic. Use labelled
  `CupidIcons.pets`-family icons, not custom art (UX Open Item 4).
- Name field: inline validation mirroring `AdoptPetDto` (trimmed length 1-30);
  the primary CTA stays disabled until both species and name are valid, driven by
  `AdoptState.isValid` rather than local widget state.
- Submit states per `../ux/uiux-spec.md` §2.2 item 3:
  - `AdoptSucceeded` → dismiss the sheet, trigger `PetCubit.load()`, and animate
    the hero card in with the existing `popIn` vocabulary.
  - `AdoptConflict` → inline error naming the existing pet when available, plus a
    "Xong" / "Done" button that dismisses and refreshes.
  - `AdoptRejectedNotYet` → friendly "not yet" copy; do not surface a raw error
    and do not compute a 24h countdown (architecture D3).
  - `AdoptFailed` → generic retry copy derived from the `CupidApiFailure`.
- Wire `PetAdoptPromptCard.onAdopt` in `pet_screen.dart` to open the sheet. The
  sheet must be unreachable from the `PetLocked` branch — no route, no deep link,
  no callback registered in that branch.
- Accessibility: modal focus trap with return-focus-on-dismiss; the species
  picker is keyboard/switch navigable as a radio group.
- Widget tests as described in Test Scope.

## 4. Acceptance Criteria

- The CTA is disabled for an empty name, a whitespace-only name, and a
  31-character name, and enabled at 1 and 30 characters with a species selected.
- The submitted body contains exactly `{ species, name }` with the backend enum
  string for species.
- `AdoptConflict` renders inline in the sheet and its "Done" action dismisses and
  triggers a reload.
- `AdoptRejectedNotYet` renders friendly copy with no HTTP status, no error icon,
  and no countdown.
- From a `PetLocked` state there is no reachable path to the sheet; asserted in
  tests.
- The species picker exposes single-select radio semantics.

## 5. Planned Outputs

- Code files: the three source files in Write Scope.
- Contracts: `showAdoptSheet`, `SpeciesPicker`.
- Requirement configuration guide updates: none.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), widget layer
- Required levels:
  - widget: `adopt_sheet_test.dart` — CTA gating at name lengths 0/1/30/31 and
    with/without species; submitted body shape via a fake `AdoptCubit`
    repository; `AdoptSucceeded` dismiss + reload; `AdoptConflict` inline error
    and Done action; `AdoptRejectedNotYet` copy assertion; locked-state
    unreachability assertion
  - accessibility: radio-group semantics for the picker and focus return after
    dismiss
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `cd mobile && flutter test test/features/pet/presentation`
  and `cd mobile && flutter analyze`
- Mobile discoverability / navigation integration: the adopt CTA must be reached
  through `PetAdoptPromptCard` inside `PetScreen`; no direct-route-only access.
- Minimum gates by risk surface:
  - Adopt validation: boundary-length CTA gating test
  - Pairing gate: locked-state unreachability test
- Required regression or contract coverage: re-run `pet_screen_test.dart` after
  the `pet_screen.dart` callback edit.
- Evidence format: concise rows in `coding-plan/test-results.md` at P9.
- Verification strategy:
  - Targeted tests: `adopt_sheet_test.dart` plus the P5 screen test
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: CTA enabled state, submitted body, rendered
    error copy, semantics roles

## 7. Status

- Status: DONE
- Last updated: 2026-07-31
- Deviation (implementation-time, additive only): `pet_screen.dart`'s
  `_PetView` was a zero-field `StatelessWidget`; it now takes an explicit
  `repository` field (threaded from `PetScreen.build()`'s existing
  `repository ?? getIt<PetRepository>()` resolution) so the `onAdopt`
  callback can construct a fresh `AdoptCubit` per sheet open. Still within
  this phase's declared `pet_screen.dart` write scope ("wire the
  `PetAdoptPromptCard` `onAdopt` callback only") — no other branch of the
  screen's switch was touched.
- Deviation (implementation-time, scope trade-off): the Tasks section's
  "animate the hero card in with the existing `popIn` vocabulary" on
  `AdoptSucceeded` was not implemented. No `popIn` animation vocabulary
  exists anywhere in `mobile/lib` (confirmed by search), and adding one would
  require editing P5's `pet_hero_card.dart`/`pet_screen.dart` switch beyond
  this phase's write scope. The binding Acceptance Criteria (§4) does not
  require this animation; `AdoptSucceeded` still dismisses the sheet and
  triggers `PetCubit.load()` synchronously.
- Deviation (test technique): `PetAdoptPromptCard`/`CupidPrimaryButton` are
  outside this phase's write scope and expose no `FocusNode` param for tests
  to seed a "focus was already on the trigger" baseline (the pattern used by
  the existing `sign_out_action_test.dart` precedent, which does expose a
  `focusNode` param on `SignOutAction`). The focus-return test instead wraps
  the test harness root in its own `Focus`/`FocusNode`, requests focus on it
  before opening the sheet, and asserts it regains focus after the sheet is
  dismissed — exercising the same framework trap/restore path without
  editing out-of-scope production files.
- Evidence:
  - `cd mobile && flutter test test/features/pet/presentation/widgets/adopt_sheet_test.dart`
    → `+13: All tests passed!` (CTA gating at name lengths 0/1/30/31 with/
    without species; submitted body shape `{species, name}` with trimmed
    name via `FakePetRepository`; `AdoptSucceeded` dismiss + reload;
    `AdoptConflict` inline error + Done dismiss/reload; `AdoptRejectedNotYet`
    friendly copy with no HTTP status/hour/day text; `AdoptFailed` generic
    retry copy; species-picker radio-group semantics
    (`isInMutuallyExclusiveGroup`/`isButton`/`isSelected`); focus trap +
    return-on-dismiss; `PetLocked` unreachability)
  - `cd mobile && flutter test test/features/pet/presentation` →
    `+70: All tests passed!` (full presentation suite, including the
    regression re-run of `pet_screen_test.dart` after the `pet_screen.dart`
    callback edit)
  - `cd mobile && flutter analyze lib/features/pet test/features/pet` →
    `No issues found!` (scoped to this phase's changed files; whole-repo
    `flutter analyze` reports ~11k pre-existing issues with zero matches
    under `features/pet` beyond one lint fixed during this phase — see next
    line — consistent with P5/P6's findings)
  - Fixed during implementation: `unnecessary_underscores` lint in
    `species_picker.dart`'s `separatorBuilder` (multiple `_` params), and a
    2px `RenderFlex` overflow in `_SpeciesCard`'s icon+label column under
    test-font metrics (fixed by tightening vertical padding and setting
    `mainAxisSize: MainAxisSize.min` on the card's `Column`) — both
    confirmed clean by the analyze/test evidence above.
