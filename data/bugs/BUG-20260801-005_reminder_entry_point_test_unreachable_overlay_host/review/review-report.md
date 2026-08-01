# Review Report: BUG-20260801-005_reminder_entry_point_test_unreachable_overlay_host

Reviewer: Iris-QC
Mode: bugfix-review

## Verification performed

1. **Diff matches claim.** `git show 2efa148` on
   `codex/REQ-001_cupid_flutter_mobile_app-integration`
   (worktree `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`)
   touches only `mobile/test/features/reminders/reminder_entry_point_test.dart`
   (5 insertions, 1 deletion). The change is exactly: `_harness()`'s
   `MaterialApp.home` changed from `const AppShell()` to `const
   ReminderOverlayHost(child: AppShell())`, plus an explanatory comment. No
   other file, and no production code, appears in the diff.
2. **No production code touched.** `git status --porcelain` on the worktree
   shows no staged/unstaged/uncommitted source changes — only the same
   pre-existing untracked `integration-review/` artifact directory seen in
   prior reviews of this branch.
3. **Fix direction independently confirmed correct, not trusted from
   fix-evidence.md.** Read the real composition root directly:
   - `mobile/lib/app/cupid_app.dart`: `CupidApp`'s `MaterialApp.home` is
     `PairGateShell(createPairGateCubit: createPairGateCubit)` — production
     never mounts a bare `AppShell()` directly.
   - `mobile/lib/core/navigation/pair_gate_shell.dart`:
     `PairGateShell.build` returns `ReminderOverlayHost(child:
     BlocProvider<PairGateCubit>(..., child: _AppShellView(...)))`, and
     `_AppShellView`'s `PairGatePaired()` branch renders `AppShell(...)`.
     Confirms `AppShell` is always a descendant of exactly one
     `ReminderOverlayHost` in production (matching the class's own doc
     comment: "`ReminderOverlayHost` is mounted exactly once here").
   This confirms the test harness's original bare `AppShell()` mount was
   the structural gap (Direction 1, not a production defect), and wrapping
   it in `ReminderOverlayHost` is the correct fix.
4. **`ReminderOverlayHost` degrades gracefully — no new GetIt regression
   risk.** Read `mobile/lib/features/reminders/presentation/reminder_overlay_host.dart`
   directly: `build()` resolves a `factory` from `_createCubit ??
   (getIt.isRegistered<ReminderFiringCubit>() ? () =>
   getIt<ReminderFiringCubit>() : null)`, and immediately `if (factory ==
   null) return child;` before ever touching `BlocProvider`. Since this
   test harness never registers `ReminderFiringCubit` in `getIt`, wrapping
   `AppShell()` in `ReminderOverlayHost` is a structural no-op at runtime
   (renders `child` bare) and introduces no new dependency or crash risk.
5. **Target test and Runtime Startup Gate pass.** Independently ran
   `flutter test test/features/reminders/reminder_entry_point_test.dart
   test/widget_test.dart` → `2/2 passed, All tests passed!`, exit 0. Both
   the previously-failing "home affordance navigates from AppShell to
   ReminderScheduleScreen (P4 AC)" test (including its
   `find.byType(ReminderOverlayHost)` assertion) and the registry readiness
   test now pass.
6. **Build Gate.** Independently ran `flutter build apk --debug` in the
   worktree's `mobile/` dir → exit 0 (`✓ Built
   build/app/outputs/flutter-apk/app-debug.apk`).

## Scope discipline

The 2 remaining full-suite failures named in fix-evidence.md
(`pair_gate_cubit_test.dart`'s pre-existing constructor mismatch and
`reminder_copy_guard_test.dart`) are pre-existing, already-triaged, and
explicitly out of this bug's scope per the handoff. They are not judged as
part of this bug's outcome.

## Assessment

The fix is correct, minimal, and safe: it corrects a structurally-invalid
test assertion by mirroring production's actual widget nesting
(`PairGateShell` -> `ReminderOverlayHost` -> paired-state `AppShell`),
verified directly against the real composition root rather than taken on
claim. `ReminderOverlayHost`'s graceful GetIt-absent fallback means this
introduces no new dependency risk. No production code was touched. The
target test, the Runtime Startup Gate, and the Build Gate all pass
independently. This closes the last of the 5 REQ-001 integration bugs.

Outcome: CLEAN

REVIEW_COMPLETE: YES
