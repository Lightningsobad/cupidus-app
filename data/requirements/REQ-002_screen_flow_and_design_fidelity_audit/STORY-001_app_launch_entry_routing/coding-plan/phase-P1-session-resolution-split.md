# Phase P1 – Split AC2 (expired) from AC3 (no session) at the gate (ADR-3, ADR-4)

## 1. Objective

Today `CupidSessionSignedOut` always resolves to `welcome`, so a user whose
prior session expired is dumped on `welcome` instead of `login` — AC2 is
unsatisfiable. Add the device-local history marker that lets the gate tell the
two apart, and wire its writer and reader.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-session-resolution-split.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO — shares `service_locator.dart` with P0.
- Status: DONE
- Write Scope:
  - `mobile/lib/core/auth/auth_history_store.dart` (new)
  - `mobile/lib/core/auth/cupid_auth.dart` (one `export` line)
  - `mobile/lib/core/di/service_locator.dart` (registration only)
  - `mobile/lib/features/auth/presentation/session_gate_cubit.dart`
  - `mobile/lib/features/auth/data/auth_repository.dart`
  - `mobile/test/core/auth/auth_history_store_test.dart` (new)
  - `mobile/test/features/auth/presentation/session_gate_cubit_test.dart` (new)
  - `mobile/test/features/auth/data/auth_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Test Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test`
- Risk Surfaces:
  - R2 AC2/AC3 split correctness
- Source Of Truth:
  - `../architecture/solution.md` ADR-3 (store), ADR-4 (resolution table)
  - `../ux/uiux-spec.md` Routing Decision Table
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one atomic behavior — make the gate able to distinguish
    "was signed in before" from "never signed in", end to end.
  - Source/Test File Count: 8 paths, of which 2 are one-line edits (barrel
    export, locator registration). Real source/test surface is 6 files.
  - Split Required: NO.
  - Split Rationale: the only available cut is store-then-consumers, but the
    store's sole consumers are the same specialist in the same lane in
    sequence — forbidden by the contract-phase condition. Any other cut leaves
    a gate that compiles but silently keeps the AC2 defect.

## 2. Required Reads

- `../architecture/solution.md` ADR-3, ADR-4, and finding D3
- `../ux/uiux-spec.md` Routing Decision Table
- `mobile/lib/core/couple/couple_pairing_store.dart` — the established
  `SharedPreferences` + `SessionScopedStore` pattern to copy
- `mobile/lib/core/di/service_locator.dart:147-154` — the registration idiom

## 3. Tasks

1. `auth_history_store.dart`: `AuthHistoryStore implements SessionScopedStore`,
   backed by an injectable `Future<SharedPreferences> Function()` defaulting to
   `SharedPreferences.getInstance` (same seam as every other store in this
   codebase). Expose `hasPreviousSession()`, `lastEmail()`,
   `markAuthenticated({String? email})`, and `clearOnSignOut()`. Keys are
   namespaced under `auth.`.
2. `cupid_auth.dart`: export the new file. Feature code must reach the store
   through this barrel only, per the barrel's own invariant.
3. `service_locator.dart`: register `AuthHistoryStore` as a lazy singleton and
   call `getIt<CupidSession>().registerScopedStore(store)` inside the factory,
   exactly like `CouplePairingStore`. This is what makes a deliberate sign-out
   clear the marker (AC3) — do not add a second sign-out path.
4. `auth_repository.dart`: add an optional `AuthHistoryStore?` constructor
   parameter (mirroring the existing optional `BackendUserIdStore?`, so no
   existing call site breaks) and a private `_onAuthenticated(String? email)`
   that marks the store. Call it from all five entry points
   (`signInWithEmail`, `registerWithEmail`, `signInWithGoogle`,
   `signInWithApple`, `signInWithFacebook`) immediately after the gateway call
   succeeds and before `_syncBackendProfile()`, so a backend-sync network
   failure does not lose the fact that Firebase auth succeeded.
5. `session_gate_cubit.dart`: inject the store and replace the
   `CupidSessionSignedOut` branch — `hasPreviousSession() == true` emits
   `SessionGateSessionExpired(prefillEmail: await lastEmail())`, otherwise
   `SessionGateUnauthenticated()`. Leave the `CupidSessionSignedIn` branch and
   the `idTokenTimeout` optimistic-success rule untouched. Issue no HTTP
   request (ADR-011h).
6. Tests: cover all four rows of ADR-4's resolution table, plus
   `clearOnSignOut()` resetting a marked store back to the `welcome` outcome.

## 4. Acceptance Criteria

- Signed-out + marker set → `SessionGateSessionExpired` (AC2 resolution).
- Signed-out + marker absent → `SessionGateUnauthenticated` (AC3 resolution).
- Signed-in behavior unchanged, including timeout-as-success.
- `CupidSession.signOut()` clears the marker through the existing scoped-store
  teardown, with no second sign-out path added.
- The gate still issues zero HTTP requests.
- `flutter analyze` clean; all tests in scope pass.

## 5. Planned Outputs

- The eight files in Write Scope.
- `coding-plan/test-results.md` entry for this phase.

## 6. Test Scope

- `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test test/core/auth/ test/features/auth/`
- `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze`
- Excluded: e2e, emulator/simulator lifecycle, signing.

## 7. Status

DONE — 2026-08-13. Evidence in `coding-plan/test-results.md` "Phase P1".
`flutter test test/core/auth/ test/features/auth/` = 55 passed, full
`flutter test` = 951 passed, `flutter analyze lib test` = 79 info-level issues,
zero errors, zero warnings.

Carry-over for P2: `SplashScreen._defaultSessionGateCubit` must pass
`authHistoryStore: getIt<AuthHistoryStore>()`. The gate parameter is optional
because `splash_screen.dart` is outside this phase's Write Scope, so AC2 is
mechanised and tested here but not yet reachable in a production launch.
