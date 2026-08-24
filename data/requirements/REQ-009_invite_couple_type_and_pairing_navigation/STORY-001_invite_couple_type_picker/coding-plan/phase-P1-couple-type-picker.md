# Phase P1 – Couple-Type Picker On The Invite Screen

## 1. Objective

The invite screen renders the 4-card couple-type grid below the pairing code,
gates its Continue CTA on exactly one selection, persists that selection to
`CupidProfile.coupleType`, and pre-selects the persisted value on return.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-couple-type-picker.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pairing/presentation/couple_type.dart` (new)
  - `mobile/lib/features/pairing/presentation/invite_cubit.dart`
  - `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
  - `mobile/test/features/pairing/presentation/invite_cubit_test.dart`
  - `mobile/test/features/pairing/presentation/invite_screen_test.dart`
  - `mobile/lib/main_preview.dart` (optional, fixture seed only)
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
    (`flutter build apk --debug`)
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `../architecture/contract-summary.md` sections 2-3 (wire values + Continue
    submit seam consumed by STORY-002)
- Shared Interfaces Consumed:
  - `AccountRepository.fetchProfile()` / `.updateProfile(coupleType:)`
    (`mobile/lib/features/account/data/account_repository.dart`), unchanged
- Risk Surfaces:
  - Couple-type wire enum fidelity
  - Countdown re-emit dropping selection
  - Pre-fill on return (AC5)
  - Continue gating and single-select (AC2/AC3)
  - Icon codepoint fidelity
  - Preview/build compatibility
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md`
    sections 1, 4; `../ux/ux-spec.md` §6.5, §6.7, §6.8
  - consumer contract: `../architecture/contract-summary.md`
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md`
    `### Business Rules And Guardrails` (the authored vi/en catalog — copy
    verbatim, do not re-author)
  - architecture: `../architecture/solution.md` sections 1, 4;
    `../architecture/contract-summary.md`
  - UX constraints: `../ux/ux-spec.md` §6.5 (component contract), §6.7 (glyph
    table + copy table), §6.8 (measurable fidelity criteria — this is the
    fidelity anchor, there is no rendered design source for this node)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one selectable-grid capability on one screen — catalog,
    state, render, persistence, and its tests are one behavior cluster.
  - Source/Test File Count: 5 (+1 optional preview fixture)
  - Split Required: NO
  - Split Rationale: fits one specialist lifecycle; splitting the enum from its
    only two consumers would isolate a contract whose consumers share this
    phase's owner and lane in sequence.

## 2. Required Reads

- `../requirements/requirements.md` `### Business Rules And Guardrails`
- `../architecture/solution.md` sections 1, 4
- `../architecture/contract-summary.md`
- `../ux/ux-spec.md` §6.5, §6.7, §6.8

## 3. Tasks

1. **Resolve the icon codepoints first.** Before writing any `IconData`, read
   the cmap of `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` with
   `fontTools` and record the codepoints for `location_city`, `auto_awesome`,
   and `all_inclusive` in `coding-plan/test-results.md`. Do not invent a
   codepoint from memory (`mobile/lib/design_system/icons/cupid_icons.dart:7-11`).
   If `fontTools`/python cannot run, stop with a blocker — do not guess.
   `flight_takeoff` is already confirmed: reuse `CupidIcons.flightTakeoff`
   (0xe905), do not redeclare it.
2. Create `couple_type.dart`: an `enum CoupleType` with the 4 cases in the
   §6.7 grid order, each carrying `wireValue`, `icon`, and the vi/en label and
   subtext; plus `CoupleType? coupleTypeFromWire(String?)` returning `null` for
   unknown/absent values. Declare the 3 new glyphs as file-local `IconData`
   constants using `CupidIcons.fontFamily`, mirroring `invite_screen.dart:47-58`
   — do NOT add them to `mobile/lib/design_system/`.
3. Extend `InviteReady` with `selectedCoupleType` (`CoupleType?`) and
   `isSaving` (`bool`), and make `_emitReady` carry both forward from the
   current state so the 30s countdown tick cannot reset the selection.
4. Extend `InviteCubit` with optional (null-defaulted) `fetchCoupleType` and
   `saveCoupleType` seams, a best-effort profile read started concurrently with
   `generateInvitation` (a failure must yield `InviteReady` with a null
   selection, never `InviteFailed`), `selectCoupleType(CoupleType)`, and
   `submitCoupleType()` returning `Future<bool>` per
   `../architecture/contract-summary.md` section 3.
5. Wire the defaults in `InviteScreen._defaultInviteCubit` to
   `getIt<AccountRepository>()`; the generated `UpdateProfileDtoCoupleTypeEnum`
   must be mapped at that seam and must not appear in the cubit or the widgets.
6. Render `_CoupleTypeSection` / `_CoupleTypeGrid` / the per-cell widget in
   `invite_screen.dart` inside the existing `InviteReady` branch's
   `SingleChildScrollView`, below `_InviteCodeCard`, followed by the
   `CupidPrimaryButton` Continue CTA, exactly per `../ux/ux-spec.md` §6.8
   (spacing, radius, border, gradient, glow, typography, tap target) and §6.5
   (semantics: `Semantics(button: true, selected: ...)` wrapping an
   `ExcludeSemantics` `GestureDetector`, matching `_MoodCell`).
7. Wire Continue: `enabled: selectedCoupleType != null && !isSaving`,
   `onPressed` → `submitCoupleType()`; on `false` show a vi/en `SnackBar` and
   leave the selection intact. Add no navigation — STORY-002 owns the
   destination. Leave `_copyAndAdvance` unchanged.
8. Optionally seed `main_preview.dart`'s invite fixture with
   `fetchCoupleType: () async => 'SAME_CITY'` so the design canvas captures a
   selected state. Do not make any cubit parameter required.
9. Add the tests named in section 6 and record evidence in
   `coding-plan/test-results.md`.

## 4. Acceptance Criteria

- AC1: the section renders below the code card with exactly 4 cards in catalog
  order, each with its icon, vi label, and vi subtext, then Continue below.
- AC2: with no selection, Continue is present and disabled.
- AC3: tapping a card selects exactly one card and enables Continue; tapping
  another card moves the selection, never adds a second.
- AC4: pressing Continue calls `updateProfile` once with the mapped wire value.
- AC5: an `InviteReady` seeded from a profile whose `coupleType` is set renders
  that card already selected and Continue already enabled on first paint.
- AC7: `joincode_screen.dart` is untouched and renders no couple-type picker.
- The selection survives a countdown tick.
- `flutter analyze` is clean and `flutter build apk --debug` succeeds.

## 5. Planned Outputs

- Code: the six paths listed in `## 1B. Write Scope`.
- Contracts: none new beyond `../architecture/contract-summary.md` (already
  written; implement against it, do not restate it in code comments).
- Notes or evidence: `coding-plan/test-results.md`, including the fontTools
  cmap output from task 1.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `invite` screen (dark theme, `vi` locale)
- Required levels:
  - unit: `invite_cubit_test.dart` — wire-value mapping for all 4 cases and
    unknown → `null`; pre-fill from a seeded profile; profile-read failure
    still reaching `InviteReady`; selection surviving an injected
    `timerFactory` tick; `submitCoupleType()` returning `true`/`false` and
    calling the save seam exactly once.
  - integration: N/A
  - mobile build/type-check/static-analysis: `flutter analyze` clean and
    `flutter build apk --debug` succeeding.
  - visual inspection: the §6.8 criteria are asserted as widget-test finder
    assertions (card count, order, selected-state count == 1, Continue enabled
    state); no rendered design-source comparison exists for this node.
- Required checks: `invite_screen_test.dart` — AC1 layout order, AC2 disabled
  CTA, AC3 single-select swap, AC4 save invoked with the mapped value, AC5
  pre-selected first paint, plus a regression assertion that `joincode_screen`
  renders no couple-type card (AC7).
- Mobile discoverability / navigation integration: the entry point already
  exists — `invite` is an existing, already-reachable screen in the pairing
  graph and this phase adds content inside its existing `InviteReady` branch.
  The widget test must mount the real `InviteScreen` (not the section widget in
  isolation) so the section is proven reachable through the shipped screen.
- Minimum gates by risk surface: see `../architecture/solution.md` section 4;
  every row's gate is one of the tests above.
- Required regression or contract coverage: the existing `invite_cubit_test.dart`
  and `invite_screen_test.dart` cases must still pass unmodified in intent —
  the code card, countdown, share/copy, and error/retry behavior are unchanged.
- Evidence format: exact commands and pass/fail counts in
  `coding-plan/test-results.md`, plus the fontTools cmap output.
- Verification strategy:
  - Targeted tests: `flutter test test/features/pairing/`
  - Build/static-analysis command: `flutter analyze` then
    `flutter build apk --debug` (resolve the SDK via `FLUTTER_SDK_PATH`,
    default `$HOME/flutter`; it is not on PATH on this machine)
  - Required assertion evidence: the save seam captured its call argument as
    the expected wire literal, and exactly one card reports
    `selected: true` after a selection change.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-24
