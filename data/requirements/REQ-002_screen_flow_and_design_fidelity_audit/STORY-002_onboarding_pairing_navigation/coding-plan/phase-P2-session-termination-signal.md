# Phase P2 — Session Termination Signal (AC5 / AC6)

Owner: mobile-dev | Lane: mobile | Depends On: P1 | Parallelizable: Yes (with P3)
Status: DONE

Shares no write-scope file with P3. Buildable without the otp/permissions/vow
screens.

## Goal

Make a deliberate sign-out and a mid-session refresh failure **distinguishable**
and make each one actually navigate.

## Problem Being Fixed (D6)

`mobile/lib/core/di/service_locator.dart:79` wires
`onSessionExpired: () => getIt<CupidSession>().signOut()`. Both a deliberate
sign-out and a refresh failure therefore collapse into the same
`CupidSession` state, so no listener can tell them apart — and today no
listener navigates on either. AC5 (→ welcome) and AC6 (→ login) cannot differ
until this signal exists.

## Write Scope

- `mobile/lib/core/auth/session_termination.dart` (new)
- `mobile/lib/core/navigation/session_termination_listener.dart` (new)
- `mobile/lib/core/auth/cupid_auth_interceptor.dart` (edit)
- `mobile/lib/core/di/service_locator.dart` (edit)
- `mobile/lib/features/auth/presentation/sign_out_cubit.dart` (edit)
- `mobile/lib/features/auth/presentation/sign_out_action.dart` (edit)
- `mobile/lib/core/navigation/pair_gate_shell.dart` (mount listener only)
- `mobile/test/core/auth/**`, `mobile/test/core/navigation/**`

## Primary Inputs

- `../architecture/solution.md` ADR-6, defect D6
- `mobile/lib/core/auth/cupid_auth_interceptor.dart` (`_onSessionExpired`, line 62)
- `mobile/lib/core/di/service_locator.dart:76-81`
- `mobile/lib/features/auth/presentation/sign_out_action.dart:57-63`

## Work

### 1. `session_termination.dart`

- `enum SessionTerminationReason { userInitiated, refreshFailed }`
- `SessionTerminationNotifier` exposing a broadcast
  `Stream<SessionTerminationReason>` and an `emit(reason)`. Keep it a plain
  Dart class with no Firebase/Dio dependency.
- Register once in `service_locator.dart` as a lazy singleton.

### 2. Publishers

- `CupidAuthInterceptor`: emit `refreshFailed` **before** invoking the
  existing `_onSessionExpired()`. Keep the interceptor's current contract
  intact — it must still never throw and must still forward the original 401
  unchanged. Inject the notifier rather than reaching into `getIt` from
  inside the interceptor.
- `SignOutCubit`: emit `userInitiated` **after** teardown succeeds, i.e. on
  the `SignOutSuccess` path. AC5 fixes this ordering — teardown first, then
  the signal, then navigation. Do not invert it.

### 3. Consumer

`SessionTerminationListener` — mounted exactly once at the app root, inside
`PairGateShell` alongside the existing `ReminderOverlayHost` mount. On event:

- `userInitiated` → `OnboardingRouter.resetTo(context, OnboardingNode.welcome)`
- `refreshFailed` → `OnboardingRouter.resetTo(context, OnboardingNode.login)`

Remove the inline `pushAndRemoveUntil` to `WelcomeScreen` from
`sign_out_action.dart:57-63`. Routing now lives in one place, so sign-out
behaves identically from every present and future call site — that widget's
own doc comment already notes no destination was wired into the app.

Keep `sign_out_action.dart`'s `SignOutFailed` snackbar behaviour unchanged.

## Tests

- Notifier emission ordering: teardown completes before `userInitiated` is
  emitted.
- Interceptor emits `refreshFailed` on a failed refresh, still forwards the
  original 401, and still never throws. Reuse the existing interceptor test
  setup rather than building a new Dio harness.
- Widget: `userInitiated` lands on `welcome`; `refreshFailed` lands on
  `login`. Assert both directions — an inverted pair is a
  verification-contract blocker (`master-plan.md` §6.4).
- Widget: the listener is mounted exactly once (no duplicate navigation on a
  single event).

## Completion

- Sign-out and refresh failure route to different destinations, driven from
  one root listener.
- `flutter analyze` clean, `flutter test` green.

## Stop Rule

If mounting the listener in `PairGateShell` cannot see a `Navigator` (because
the shell sits above `MaterialApp`'s navigator), do **not** work around it by
adding a second `MaterialApp` or a global navigator key inside a screen.
Report the placement problem — the correct fix is a single `navigatorKey` on
the existing `MaterialApp` in `mobile/lib/app/cupid_app.dart`, which is a
one-line composition-root change and should be confirmed before proceeding.

Not triggered: `CupidApp` builds `MaterialApp(home: SplashScreen(...))`, so
`PairGateShell` is reached *through* that navigator and the listener's context
resolves it. No second `MaterialApp` and no global navigator key were added.

## Verification Evidence (2026-08-14, mobile-dev)

Commands run in
`.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-002/mobile`:

- `flutter analyze lib test` — 78 issues, all `info`, zero `error`, zero
  `warning`, and zero issues in any file this phase created or modified. Every
  remaining info is a pre-existing `prefer_initializing_formals` /
  `deprecated_member_use` / `use_null_aware_elements` in an untouched file.
- `flutter test test/core/auth test/core/navigation` — 48/48 passed.
- `flutter test test/core/navigation/session_termination_listener_test.dart` —
  6/6 passed.
- `flutter test test/features/auth/presentation/sign_out_action_test.dart` —
  2/2 passed.
- `flutter test` (full suite) — `+1172 ~2 -6`.

The 6 full-suite failures are pre-existing and owned by other stories; none
references any file this phase touched:

- `test/design_system/no_fork_guard_test.dart` — raw colour literals in
  chat/account/reminders screens.
- `test/features/auth/presentation/screens/login_screen_test.dart`,
  `test/features/pairing/.../joincode_screen_design_test.dart`,
  `test/features/pairing/.../waiting_screen_design_fidelity_test.dart` — one
  shared caption-token regression (`Expected: <13> Actual: <11.5>`).
- `test/features/pet/presentation/pet_design_fidelity_test.dart`,
  `test/features/reminders/reminder_copy_guard_test.dart` — design/copy guards.

Out-of-declared-write-scope change made deliberately:
`mobile/test/features/auth/presentation/sign_out_action_test.dart` asserted
`find.byType(WelcomeScreen)` after a confirmed sign-out, which this phase's
mandated removal of the inline `pushAndRemoveUntil` makes unreachable. The test
now asserts the published `userInitiated` reason instead. The file sits in P3's
declared write scope; P3 had not started when this edit was made.
