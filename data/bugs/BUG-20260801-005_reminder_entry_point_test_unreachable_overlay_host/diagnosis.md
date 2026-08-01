# Diagnosis: BUG-20260801-005_reminder_entry_point_test_unreachable_overlay_host

## Root cause

Test-harness composition gap, not a production defect. Confirmed by
reading the real production composition root:

- `mobile/lib/app/cupid_app.dart`: `CupidApp`'s `MaterialApp.home` is
  `PairGateShell(createPairGateCubit: createPairGateCubit)` — production
  never mounts a bare `AppShell()` directly under `MaterialApp`.
- `mobile/lib/core/navigation/pair_gate_shell.dart`: `PairGateShell.build`
  returns `ReminderOverlayHost(child: BlocProvider<PairGateCubit>(...,
  child: _AppShellView(...)))`. `_AppShellView` switches on `PairGateState`
  and only renders `AppShell(...)` for the `PairGatePaired` branch. So in
  production, `AppShell` is always a descendant of exactly one
  `ReminderOverlayHost` (mounted once by `PairGateShell`, per its own doc
  comment: "STORY-009 P4: `ReminderOverlayHost` is mounted exactly once
  here, wrapping the entire gated tree below").

`mobile/test/features/reminders/reminder_entry_point_test.dart`'s
`_harness()` pumped `const AppShell()` directly as `MaterialApp.home`,
skipping `PairGateShell`/`ReminderOverlayHost` entirely — matching this
test suite's established convention (also used by `app_shell_test.dart`,
`gallery_cubit_test.dart`) of pumping `AppShell` directly for paired-flow
tests to avoid wiring the full `PairGateCubit` state machine. This left
`find.byType(ReminderOverlayHost)` structurally unreachable: the widget the
test asserted on was never mounted in this harness's tree, independent of
GetIt registration state. `BUG-20260801-002`'s fix (registering
`CouplePairingStore`/`ChatPartnerStore`) could not and did not resolve
this, since the missing ancestor is a compositional gap, not a DI gap.

Confirmed `ReminderOverlayHost`
(`mobile/lib/features/reminders/presentation/reminder_overlay_host.dart`)
gracefully degrades to rendering `child` bare when `ReminderFiringCubit` is
not registered in GetIt (it checks `getIt.isRegistered<ReminderFiringCubit>()`
and falls back to `null`, short-circuiting to `return child;` before ever
touching `BlocProvider`) — so wrapping the test's `AppShell()` in
`ReminderOverlayHost` introduces no new GetIt dependency and cannot
regress or crash the harness.

## Fix

Direction 1 confirmed (per the handoff's two candidate directions): the
test harness was wrong, not the assertion's target widget. Updated
`_harness()` in `reminder_entry_point_test.dart` to wrap `const
AppShell()` in `const ReminderOverlayHost(child: ...)`, mirroring
production's actual nesting (`PairGateShell` -> `ReminderOverlayHost` ->
paired-state `AppShell`) without pulling in the full `PairGateCubit` state
machine, consistent with this suite's existing "pump `AppShell` directly
for paired-flow tests" convention. No production code touched
(`service_locator.dart`, `app_shell.dart`, `home_screen.dart`,
`pair_gate_shell.dart` unmodified).

See `fix-evidence.md` for verification.

## Out-of-scope items observed, not touched

- `pair_gate_cubit_test.dart` constructor mismatch — pre-existing,
  unrelated.
- `reminder_copy_guard_test.dart` — pre-existing, unrelated.
- ~76 `prefer_initializing_formals` lints — pre-existing, unrelated.
- `BUG-20260801-001` through `-004` — all already `DONE`, not touched.
