# Phase P5 – Pairing-Required Gate, Route, And Discoverable Entry Point

## 1. Objective

Satisfy AC4 with a defensive pairing gate, register the feature route, wire DI,
and make the feature reachable from a discoverable surface so it is not an
orphaned capability.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-pairing-gate-entry-point.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/expenses/data/pairing_state_reader.dart`
  - `mobile/lib/features/expenses/presentation/widgets/pairing_required_gate.dart`
  - `mobile/lib/features/expenses/expenses_route.dart`
  - `mobile/lib/core/di/service_locator.dart` (additive registration only)
  - `mobile/lib/features/home/presentation/home_screen.dart` (minimal additive entry affordance)
  - `mobile/test/features/expenses/pairing_gate_test.dart`
  - `mobile/test/features/expenses/expenses_entry_point_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A for this phase
  - Readiness Check: `Key('home_screen_ready_signal')` must still be present and pumpable after the `home_screen.dart` edit
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `PairingStateReader.isPaired()`
  - `expensesRoute` named route → gated `ExpenseHistoryScreen`
  - a discoverable entry affordance
- Shared Interfaces Consumed:
  - P1 `ExpensesNotPairedFailure`
  - P3 `ExpenseHistoryScreen`, `expense_strings.dart`
  - `CupidApi.dio` (for `GET /users/me` if no pairing source exists yet)
- Risk Surfaces:
  - Unpaired gating (AC4)
  - Entry-point discoverability and shared-file merge conflict (R-015.2)
  - `mobile-app` readiness key preservation
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §6; `../architecture/solution.md` ADR-015.7, §8 R-015.2
  - consumer contract: P6 verifies AC4 and navigation through this phase's route
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC4
  - architecture: ADR-015.7 (pairing state keyed on `partnerId`; 404 as corroborating signal), §8 R-015.2
  - OQ constraints: A1 — no new endpoint; use `GET /users/me` as-is
  - upstream phase outputs: P1 failures, P3 screen, P4 sheet
  - UX constraints: §6 (dedicated Pairing-Required gate, not a generic error or an empty list; single primary action routing into the existing pairing flow)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: the feature is reachable and correctly closed to unpaired users
  - Source/Test File Count: 3 new source + 2 additive edits + 2 test
  - Split Required: NO

## 1C. Entry-Point Constraint — Read Before Editing

The UX spec's entry point (Money tab → `jar` screen → "Chi tiêu chung" card) does
**not exist**: `app_shell.dart` returns `HomeScreen` directly and the 5-tab shell
and Dream Jar screen belong to other stories.

- Keep the `home_screen.dart` edit **minimal and additive** — one named affordance
  that navigates to `expensesRoute`. Every sibling story may also touch this file;
  a large edit will conflict (R-015.2).
- **Preserve `Key('home_screen_ready_signal')`** exactly. It is the `mobile-app`
  runtime readiness contract in the registry; removing or moving it breaks the
  repo's dev/build readiness signal.
- Do not build the 5-tab shell and do not create a `jar` screen. When the shell
  story lands, the entry moves to the Money tab; `expensesRoute` stays stable.

## 2. Required Reads

- `../ux/uiux-spec.md` §6
- `../architecture/solution.md` ADR-015.7 and §8 R-015.2
- `mobile/lib/features/auth/presentation/screens/splash_screen.dart` — the existing
  auth-check-gate shape this gate mirrors (keyed on pairing state instead of auth)
- `mobile/lib/core/di/service_locator.dart` — existing registration style
- `mobile/lib/features/home/presentation/home_screen.dart` — current placeholder content

## 3. Tasks

- Create `PairingStateReader` exposing `Future<bool> isPaired()`:
  - if a pairing-state source from STORY-005 exists on the integration branch,
    consume it;
  - otherwise read `GET /users/me` via `_api.dio.get<Object?>('/users/me')` and
    test `partnerId != null`.
  - Do not add an endpoint (A1).
- Create `PairingRequiredGate`: a dedicated screen (not a generic error, not a
  silently-empty list) with the UX §6 explanatory copy and one primary action
  routing into the existing pairing flow. Add its strings to `expense_strings.dart`.
- Create `expenses_route.dart` exposing the named route and a builder that resolves
  pairing state first, showing `PairingRequiredGate` when unpaired and
  `ExpenseHistoryScreen` when paired.
- Wire the secondary corroborating signal: if any expenses call returns
  `ExpensesNotPairedFailure` while the screen is open, flip to the gate so a stale
  cached pairing state cannot leave the feature open (ADR-015.7).
- Register `ExpensesRepository`, `ExpenseDao`, `PairingStateReader`, and the Cubits
  in `service_locator.dart`, matching the existing registration style.
- Add the minimal discoverable entry affordance in `home_screen.dart` per §1C.

## 4. Acceptance Criteria

- An unpaired user reaching the route sees `PairingRequiredGate`, never the expense
  screen, never a generic error, never an empty list (AC4).
- A paired user reaching the route sees `ExpenseHistoryScreen`.
- An `ExpensesNotPairedFailure` received while the screen is open flips to the gate.
- The feature is reachable by tapping a visible affordance — direct-route-only
  access is not acceptable.
- `Key('home_screen_ready_signal')` is still present and pumpable.
- `flutter analyze` clean.

## 5. Planned Outputs

- Code directories or files: the Write Scope files
- Contracts or schemas: `PairingStateReader`, `expensesRoute`
- Requirement configuration guide updates: none
- Notes or evidence: test output in §7

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, navigation + gating
- Required levels:
  - unit: `PairingStateReader` — `partnerId` present ⇒ paired; null ⇒ unpaired
  - widget: unpaired ⇒ gate rendered and expense screen absent; paired ⇒ expense
    screen rendered; `ExpensesNotPairedFailure` mid-session ⇒ gate; entry affordance
    tap navigates to the history screen; `home_screen_ready_signal` still pumpable
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: gate is a dedicated screen, not a snackbar/dialog/empty list;
  DI registrations resolve without duplicate registration errors
- Mobile discoverability / navigation integration: **required** — a widget test must
  navigate from the entry affordance to `ExpenseHistoryScreen`, proving the
  capability is not orphaned
- Minimum gates by risk surface: AC4 ⇒ unpaired gate widget test; R-015.2 ⇒
  readiness-key preservation test; discoverability ⇒ entry-point navigation test
- Required regression or contract coverage: the existing home-screen readiness
  widget test must still pass unchanged
- Evidence format: `flutter test` + `flutter analyze` output excerpt in §7
- Verification strategy:
  - Targeted tests/regression/contract checks: the two test files above plus the
    existing home-screen test
  - Build/type-check/lint command when required: `flutter analyze`, `flutter test test/features/expenses/ test/features/home/`
  - Required assertion evidence: passing unpaired-gate test and entry-point
    navigation test

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
