# Phase P2 – Mount the splash gate as the app's entry route (ADR-1, ADR-2, ADR-5, ADR-6)

## 1. Objective

Fix the confirmed defect: the splash auth-check gate exists but is never
mounted, so cold launch skips the session check entirely. Make splash the
initial route, send its authenticated outcome to the authenticated app root,
and remove the affordance that navigates before the session resolves.

This is the phase that proves AC1, AC4, and AC5, and completes AC2/AC3.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-entry-route-wiring.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0, P1
- Parallelizable: NO
- Status: NOT_STARTED
- Write Scope:
  - `mobile/lib/app/cupid_app.dart`
  - `mobile/lib/features/auth/presentation/screens/splash_screen.dart`
  - `mobile/test/features/auth/presentation/splash_screen_test.dart`
  - `mobile/test/app/cupid_app_entry_routing_test.dart` (new)
  - `mobile/lib/main_preview.dart` (conditional — only if `_buildSplash` at
    line 389 fails to compile after the constructor change; the explicit
    `authRepository:` argument must remain supported as an override)
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Test Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test`
- Risk Surfaces:
  - R1 Initial-route swap
  - R3 AC4 no premature navigation
  - R4 AC5 resume invariant
  - R6 Splash visual overlap with STORY-003
- Source Of Truth:
  - `../architecture/solution.md` ADR-1, ADR-2, ADR-5, ADR-6
  - `../ux/uiux-spec.md` Splash Routing State Machine, Routing Decision Table,
    Resume Guard
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one atomic behavior — the app's cold-launch entry decision.
  - Source/Test File Count: 4 paths plus 1 conditional compile fix.
  - Split Required: NO. Splitting the `home:` swap from the destination fix
    would ship an intermediate state where every authenticated user lands on a
    bare `HomeScreen` with no tab shell — a worse defect than the one being
    fixed.

## 2. Required Reads

- `../architecture/solution.md` sections 2 (findings D1, D2, D4), 3 (ADR-1,
  ADR-2, ADR-5, ADR-6)
- `../ux/uiux-spec.md` (whole file — it is short and governs the state machine)
- `mobile/lib/core/navigation/pair_gate_shell.dart` — read only, to confirm the
  constructor arguments to forward. Do not modify it.

## 3. Tasks

1. `cupid_app.dart`: change `home:` from `PairGateShell(...)` to the splash
   gate. Keep the existing `createPairGateCubit` test seam by threading it
   through to the destination `PairGateShell` that splash builds, so full-app
   widget tests keep their injection point and do not need `getIt`.
2. `splash_screen.dart`: make `authRepository` optional, defaulting to
   `getIt<AuthRepository>()`, matching the screen's existing
   `createSessionGateCubit` / `resolvePairingStatus` seam style.
3. `splash_screen.dart`: change the `SessionGateAuthenticated` destination from
   `HomeScreen` to `PairGateShell`. Keep `pushReplacement` — it is what removes
   splash from the stack and disposes the gate subscription (ADR-5 invariant 2).
4. `splash_screen.dart`: delete `_onTapToContinue`, the wrapping
   `GestureDetector`, and the "Chạm để tiếp tục" / "Tap to continue" `Text`.
   Leave the gradient, the `Cupid` wordmark, `_BobbingDots`, and the
   "Đang mở khoá…" line exactly as they are — splash visuals belong to
   STORY-003.
5. Do not add any `WidgetsBindingObserver` or `AppLifecycleState` subscription
   to the launch path (ADR-5 invariant 1).
6. Tests — extend `splash_screen_test.dart` for the corrected destinations and
   add `cupid_app_entry_routing_test.dart` for the app-level assertions listed
   below.

## 4. Acceptance Criteria

- AC1: valid session → `PairGateShell` (not bare `HomeScreen`).
- AC2: expired prior session → `LoginScreen` with `sessionExpired: true`.
- AC3: no session → `WelcomeScreen`.
- AC4: with the session resolved at t=0, no navigation occurs before 2s; with
  the dwell elapsed but the gate still `Checking`, no navigation occurs; and
  there is no tap path off splash.
- AC5, tested as two invariants:
  - booting `CupidApp` mounts splash exactly once, and a simulated
    foreground/background lifecycle transition after routing neither re-mounts
    splash nor changes the current route;
  - a session-state emission arriving after splash has been replaced causes no
    navigation.
- A guard test asserts no `WidgetsBindingObserver` / `AppLifecycleState`
  subscription exists on the entry-routing path.
- `flutter analyze` clean; all tests in scope pass.

## 5. Planned Outputs

- The files in Write Scope.
- `coding-plan/test-results.md` entry for this phase.

## 6. Test Scope

- `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test test/app/ test/features/auth/`
- `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze`
- Excluded: e2e, emulator/simulator lifecycle, signing. Device capture is P3.

## 7. Status

DONE
