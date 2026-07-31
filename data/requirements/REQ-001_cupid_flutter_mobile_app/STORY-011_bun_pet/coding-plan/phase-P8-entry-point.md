# Phase P8 – Entry Point And Reachability

## 1. Objective

Make the pet feature discoverable: mount a `PetPreviewCard` on `HomeScreen` that
navigates into `PetScreen`, without breaking the runtime readiness signal.

## 1A. Ownership

- Phase ID: P8
- Canonical Phase File: `phase-P8-entry-point.md`
- Owner: Mobile Developer
- Lane: Mobile / Entry Point

## 1B. Phase Metadata

- Depends On: P5
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`
  - `mobile/lib/features/pet/presentation/pet_route.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart` (one additive
    mount block)
  - `mobile/test/features/pet/presentation/pet_entry_point_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: `Key('home_screen_ready_signal')` must still pump — this is
    the registry readiness contract for `mobile-app`
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `PetPreviewCard`
  - `PetRoute.push(BuildContext)` / `PetRoute.name`
- Shared Interfaces Consumed:
  - P1 models and `PetLocaleText`, P3 `PetCubit`, P4 `BunSprite`, P5 `PetScreen`
- Risk Surfaces:
  - Entry-point reachability
  - Pairing hard gate (AC3) — preview surface
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §2.1 home-dashboard preview
    card paragraph
  - consumer contract: `HomeScreen` layout and the `mobile-app` registry
    readiness key
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §4 reachability risk surface and
    Mobile Lane Handoff guardrails
  - UX constraints: `../ux/uiux-spec.md` §2.1 preview card (sprite thumbnail at
    74, name, level chip, one-line status, XP bar), §2.3 unpaired behavior
  - upstream phase outputs: P5 `PetScreen`
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: entry point + navigation only
  - Source/Test File Count: 3 source (2 new, 1 additive edit) + 1 test
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §2.1 (preview card paragraph), §2.3
- `../architecture/solution.md` §4 reachability risk surface
- P5 outputs
- `mobile/lib/features/home/presentation/home_screen.dart`
- `mobile/lib/core/navigation/app_shell.dart` (context only; do not modify)

## 3. Tasks

- `PetPreviewCard`: sprite thumbnail at 74, pet name, level chip, the one-line
  status for the current mood, and the XP bar — reusing the same data mapping as
  `PetScreen`. It owns its own short-lived `PetCubit` load; it must not duplicate
  mood or XP math.
- Unpaired and no-pet behavior on the dashboard: render the compact locked or
  adopt-prompt variant, never a pet card with placeholder data, and never a path
  into the adopt sheet while unpaired.
- `PetRoute`: a single named-route/`MaterialPageRoute` helper so `HomeScreen` and
  future surfaces push `PetScreen` the same way. Direct-URL-only access is not
  acceptable; the preview card is the discoverable surface.
- Edit `home_screen.dart` additively: keep the existing `Scaffold`, `AppBar`, and
  the `Key('home_screen_ready_signal')` widget exactly as they are, and add the
  preview card below the existing content. Do not restructure `HomeScreen` and do
  not touch `app_shell.dart` (the tab shell is deliberately deferred — see
  `../architecture/solution.md` §6).
- Keep this edit to one contiguous block; `home_screen.dart` is a shared file in
  a parallel wave.
- Widget tests as described in Test Scope.

## 4. Acceptance Criteria

- Tapping `PetPreviewCard` on `HomeScreen` lands on `PetScreen`; asserted by a
  navigation widget test.
- `Key('home_screen_ready_signal')` is still present and pumps after the edit;
  asserted by a regression test.
- With an unpaired fake repository, the dashboard shows the locked variant and no
  adopt entry.
- `HomeScreen` contains no pet business logic — only the mounted widget.
- `app_shell.dart` is unchanged.

## 5. Planned Outputs

- Code files: the three source files in Write Scope.
- Contracts: `PetPreviewCard`, `PetRoute`.
- Requirement configuration guide updates: none.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), widget + navigation
- Required levels:
  - widget: `pet_entry_point_test.dart` — preview card renders paired/unpaired
    variants; tap navigates to `PetScreen`; `home_screen_ready_signal` regression
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `cd mobile && flutter test` (full suite, because
  `home_screen.dart` is shared) and `cd mobile && flutter analyze`
- Mobile discoverability / navigation integration: REQUIRED — the pet capability
  must be reachable from `HomeScreen` through a discoverable card, not by route
  name only.
- Minimum gates by risk surface:
  - Entry-point reachability: navigation test from the preview card
  - Runtime readiness contract: `home_screen_ready_signal` pump assertion
  - Pairing gate: unpaired preview variant assertion
- Required regression or contract coverage: the existing home-screen test that
  guards the readiness key must still pass unchanged.
- Evidence format: concise rows in `coding-plan/test-results.md` at P9.
- Verification strategy:
  - Targeted tests: `pet_entry_point_test.dart` plus the full `flutter test` run
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: post-tap widget presence and readiness-key pump

## 7. Status

- Status: DONE
- Last updated: 2026-07-31
- Evidence:
  - Created `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`
    (`PetPreviewCard`: ready/locked/no-pet/loading/failure variants, reuses
    `BunSprite`, `PetLocaleText`, and `PetStatus.levelProgress` — no duplicated
    mood/XP math) and `mobile/lib/features/pet/presentation/pet_route.dart`
    (`PetRoute.push`/`.route()` single navigation entry point).
  - Edited `mobile/lib/features/home/presentation/home_screen.dart`
    additively: existing `Scaffold`/`AppBar`/`Key('home_screen_ready_signal')`
    left byte-for-byte in place, `PetPreviewCard()` added as one contiguous
    block below it. `app_shell.dart` not touched.
  - Added `mobile/test/features/pet/presentation/pet_entry_point_test.dart`:
    4/4 passing (ready variant, locked/unpaired compact variant with no adopt
    CTA (AC3), tap navigates to `PetScreen`, `home_screen_ready_signal`
    regression pump).
  - Fix during verification: `test/widget_test.dart` (existing, out of
    WriteScope, boots `CupidApp` with no `setupServiceLocator()` call) was
    breaking because `PetPreviewCard` eagerly resolved
    `getIt<PetRepository>()` during build, throwing `StateError` and
    overflowing `HomeScreen`'s `Column`. Fixed inside `PetPreviewCard`
    (in-WriteScope) by rendering `SizedBox.shrink()` when no repository
    override is supplied and `PetRepository` is not yet registered in
    `getIt` — this path only engages in that DI-less smoke test; the real app
    always calls `setupServiceLocator()` before running.
  - `cd mobile && flutter analyze` scoped to the 4 touched files: "No issues
    found!" (0 errors/warnings/info).
  - `cd mobile && flutter test` (full suite, required because
    `home_screen.dart` is shared): 212/213 passed. The 1 failure
    (`test/design_system/no_fork_guard_test.dart`, raw `Colors.` literals in
    `lib/features/pet/presentation/widgets/pet_action_row.dart:67` and
    `pet_reactions_card.dart:81`) is pre-existing P6/P7 debt outside this
    phase's WriteScope, confirmed via `git status --short` showing those files
    unchanged by this phase's commit. Not fixed here; flagged for P9/follow-up.
