# Phase P1 – Privacy screen ghost-mode toggle (AC2) + AC3 non-regression

## 1. Objective

Make `User.isGhostModeEnabled` genuinely editable from the privacy screen
through the already-existing `PATCH /users/me` contract, exactly as specified in
`../ux/uiux-spec.md` §2-5, without touching the chat lane or the notification
settings surface.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-privacy-ghost-toggle.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/account/data/account_repository.dart`
  - `mobile/lib/features/account/presentation/screens/privacy_screen.dart`
  - `mobile/lib/features/account/presentation/screens/me_screen.dart` (call site only, line 123)
  - `mobile/lib/main_preview.dart` (call site only, line 363)
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/account/presentation/screens/privacy_screen_test.dart`
  - `mobile/test/features/account/data/account_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `mobile-app.buildCommand` (not required by this phase; static analysis is the gate)
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Risk Surfaces:
  - Two client writers of `isGhostModeEnabled`
  - AC3 device-local notification behavior
  - AC4 no admin/data-export affordance
  - Static tier cards must not hide behind a spinner
  - Stale view-only invariant in source
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` sections 1, 3, 4
  - consumer contract: existing `PATCH /users/me` via generated
    `UpdateProfileDto.isGhostModeEnabled`
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §1 Key Discovery, §4 risk table
    and Mobile Lane guardrails
  - UX constraints (required — this phase is UI): `../ux/uiux-spec.md` §2
    (placement), §3 (component + l10n keys), §4 (states), §5 (accessibility)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one atomic behavior — make one boolean field editable end to
    end on one screen.
  - Source/Test File Count: 8 paths, of which 2 are single-line call-site
    compile fixes forced by the new constructor signature and 2 are ARB key
    additions. Real source/test surface is 4 files.
  - Split Required: NO
  - Split Rationale: the only legal split is repository-parameter + l10n as a
    first phase, but that phase's whole output would be one optional parameter
    and a set of string keys whose sole consumer is the same specialist in the
    same lane in sequence — forbidden by the contract-phase condition. Any other
    cut leaves a non-compiling intermediate state.

## 2. Required Reads

- `../architecture/solution.md`
- `../ux/uiux-spec.md` §2-5

## 3. Tasks

1. `account_repository.dart`: add `bool? isGhostModeEnabled` to
   `updateProfile()`'s named parameters and forward it into the
   `UpdateProfileDto` constructor. The generated DTO already declares the field
   (`mobile/openapi/cupid_api/lib/src/model/update_profile_dto.dart:37`) — do
   not regenerate the client. Leave the trailing `return fetchProfile();`
   behavior unchanged; `profile_edit_screen` depends on it.
2. ARB files: add the 8 keys named in `../ux/uiux-spec.md` §3 and §5
   (`privacy_controls_section_label`, `privacy_controls_ghost_mode_title`,
   `privacy_controls_ghost_mode_subtitle`, `privacy_controls_load_error`,
   `privacy_controls_update_error`, `privacy_controls_ghost_mode_semantic_on`,
   `..._semantic_off`, `..._semantic_loading`) with the exact vi/en copy given
   there. Regenerate `l10n/generated/` with the project's existing l10n step.
3. `privacy_screen.dart`:
   - Change the class to take `required this.accountRepository`
     (`AccountRepository`), mirroring `MeScreen`'s constructor-injection
     convention, and wrap its body in
     `BlocProvider<AccountCubit>(create: (_) => AccountCubit(repository: accountRepository), ...)`.
     Do not add a `..load()` cascade — `AccountCubit`'s constructor already
     calls `load()` (`account_cubit.dart:31-33`).
   - Insert `_PrivacyControlsSection` between the Level 1 and Level 2
     `_TierCard`s per `../ux/uiux-spec.md` §2. Scope its `BlocBuilder` to that
     section only; the `ListView` and the three tier cards must render
     immediately in every state.
   - Duplicate the `_TogglePill` shape as a private widget in this file. Do not
     import from or edit `notification_settings_screen.dart`, and do not promote
     the widget into `design_system/`.
   - Implement the states from §4: inert pill on load/failure, optimistic flip
     on tap with taps ignored while in flight, `AccountCubit.applyUpdated()`
     with the returned profile on success, rollback + `SnackBar` on failure.
   - Rewrite the file's leading doc comment (currently lines 6-10) so it no
     longer asserts the superseded "no toggle, no PATCH, no
     `isGhostModeEnabled`" invariant. Cite STORY-021 and `req_master.md`
     § Open Question Triage entry #5 as the decision that changed it.
4. Update the two call sites so the app still compiles: `me_screen.dart:123`
   passes its own `accountRepository`; `main_preview.dart:363` passes
   `getIt<AccountRepository>()`, mirroring line 359's existing pattern. If
   `flutter analyze` reports any other `PrivacyScreen(` call site, fix it here.
5. Tests: extend `account_repository_test.dart` for the new parameter; rewrite
   `privacy_screen_test.dart` per `## 6`.

## 4. Acceptance Criteria

- Tapping the control calls `updateProfile(isGhostModeEnabled: <new value>)`
  exactly once and emits `AccountLoaded` with the returned profile.
- A failed PATCH leaves the pill in its pre-tap position and shows the
  `privacy_controls_update_error` SnackBar; the row is tappable again after.
- During `AccountLoading` and `AccountFailed` the pill is inert and the three
  tier cards are still on screen.
- `git diff` shows zero changes under `mobile/lib/features/chat/`,
  `notification_settings_screen.dart`, `notification_settings_cubit.dart`, and
  `notification_preferences_store.dart`.
- No "Export all my data" or admin affordance exists on the privacy screen.

## 5. Planned Outputs

- Code: the 8 paths in `## 1B` plus regenerated `mobile/lib/l10n/generated/`.
- Notes or evidence: `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `features/account/`
- Required levels:
  - unit: `account_repository_test.dart` — `updateProfile` sends
    `isGhostModeEnabled` when passed and omits it when null (existing
    partial-PATCH behavior must not regress).
  - integration: `privacy_screen_test.dart` widget tests against a fake
    `AccountRepository` covering all four states in `../ux/uiux-spec.md` §4.
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile/`,
    clean.
- Required checks:
  - Rewrite the assertion at `privacy_screen_test.dart:30-36`. It currently
    reads `find.byType(Switch), findsNothing` under the name "renders no toggle
    and no export button" — because the new control is a custom pill and not a
    Material `Switch`, that assertion stays green while its name becomes false.
    Keep the `find.textContaining('Export'), findsNothing` half (AC4 guard),
    drop the "no toggle" claim, and add positive assertions for the new control.
  - Accessibility: assert the `Semantics` label changes between the on, off, and
    loading strings from `../ux/uiux-spec.md` §5.
- Mobile discoverability / navigation integration: no new route or nav item is
  introduced. The control lives on the already-reachable privacy screen
  (`me_screen.dart:117-126` menu row); assert it renders on that existing route
  rather than adding an entry point.
- Required regression or contract coverage: run
  `notification_settings_screen_test.dart`,
  `notification_settings_cubit_test.dart`, and
  `notification_preferences_store_test.dart` **unmodified** — this is the AC3
  non-regression gate. Also run `me_screen_test.dart` for the call-site change.
  If any of those four files needs editing to pass, stop: the change leaked out
  of scope.
- Evidence format: `coding-plan/test-results.md` with the exact commands and
  pass/fail counts.
- Verification strategy:
  - Targeted tests: `flutter test test/features/account/`
  - Static analysis: `flutter analyze`
  - Flutter is not on PATH on this machine; resolve it via
    `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`.
  - Required assertion evidence: the four acceptance bullets in `## 4`, each
    backed by a named test.

## 7. Status

- Status: DONE
- Last updated: 2026-08-12
- Evidence: `coding-plan/test-results.md` — `flutter analyze` clean on the 6
  changed Dart files; `flutter test test/features/account/` 85/85 passed,
  including the four unmodified AC3 non-regression files.
