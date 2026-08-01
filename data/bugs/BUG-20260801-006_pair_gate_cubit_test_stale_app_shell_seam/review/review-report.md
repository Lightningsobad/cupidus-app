# Bugfix Review: BUG-20260801-006_pair_gate_cubit_test_stale_app_shell_seam

Reviewer: Iris-QC (`Mode: bugfix-review`)
Flow: bugfix
Scope: BUG-20260801-006_pair_gate_cubit_test_stale_app_shell_seam
Branch: `main`, control checkout
`/Users/alantravala/workspace/snapsofts/cupid-apps`
HEAD at review: `c984e5a` (fix is uncommitted in the working tree)
Scope gate: `review/scope-gate.md` (Phase 1, `SCOPE_GATE_COMPLETE: YES`)

Verdict summary: CLEAN (see the verdict section at the end of this report).

## What was verified (independently re-run, not taken from fix-evidence)

### 1. Fix is genuinely test-only — CONFIRMED

`git status --porcelain` at review time:

```
 M data/bugs/BUG-20260801-006_.../bug_master.md
 M mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart
?? data/bugs/BUG-20260801-006_.../diagnosis.md
?? data/bugs/BUG-20260801-006_.../fix-evidence.md
?? data/bugs/BUG-20260801-006_.../scrum-master-checkpoint.md
```

`git diff --stat HEAD` shows exactly two changed tracked files: this bug's
`bug_master.md` and the single test file (`+68 -5`).

`git status --porcelain -- mobile/lib mobile/test/features/reminders
'mobile/**/*.arb'` returns empty. So:

- No production file under `mobile/lib/` was touched.
- `mobile/test/features/reminders/reminder_copy_guard_test.dart` is untouched
  (`BUG-20260801-007` scope preserved).
- No ARB file was touched.

The bug-fixer's "no production change required" claim holds.

### 2. `PairGateShell` really preserves the three cubit-factory seams — CONFIRMED

Read `mobile/lib/core/navigation/pair_gate_shell.dart` directly. The
constructor (`pair_gate_shell.dart:43`) declares, with names and signatures
identical to the ones the original test used against `AppShell`:

```dart
const PairGateShell({
  super.key,
  PairGateCubit Function()? createPairGateCubit,
  InviteCubit Function()? createInviteCubit,
  JoincodeCubit Function()? createJoincodeCubit,
  ChatPartnerStore? partnerStore,
  ChatRepository? chatRepository,
  RealtimeCoordinator? coordinator,
  BackendUserIdStore? backendUserIdStore,
  GhostConsentStore? consentStore,
});
```

`createPairGateCubit` feeds the `BlocProvider<PairGateCubit>` create callback;
`createInviteCubit`/`createJoincodeCubit` are threaded to `_AppShellView` ->
`_PairingStack`. The `PairGateChecking` / `PairGateUnpaired` / `PairGatePaired`
switch lives in `_AppShellView.build`, with `PairGatePaired()` rendering
`AppShell`. This matches the diagnosis exactly: the gate moved one widget up,
the seams did not change, and hypothesis 2 (production testability gap) is
correctly ruled out.

### 3. Rewritten harness is faithful, not weakened — CONFIRMED

Assertion-level comparison against `HEAD:` version of the same file:

- `expect(` count: 19 before, 19 after — no assertion deleted or merged.
- Test count and names: 9 tests before, the same 9 after (4 pure `PairGateCubit`
  unit tests plus 5 widget tests); no test renamed except the group label
  `AppShell gate (AC4)` -> `PairGateShell gate (AC4)`, which is a
  correctness improvement (names the widget actually under test).
- Removed lines, in full: one doc-comment line, the group label, and one
  `await tester.pump()`. Nothing else was deleted.

The behavioural assertions remain non-tautological and still bind real
navigation outcomes, e.g. the unpaired test still asserts `pairing_stack`
present, `HomeScreen` absent, `BottomNavigationBar` absent, both entry-action
labels present, and then actually taps "Pair with your partner" and requires
`InviteScreen` to be pushed and `pairing_stack` to be gone. The fail-safe test
still requires the throwing check to land on `pairing_stack` with `HomeScreen`
absent.

The three additions to the harness are justified by the widget move, not by
assertion pressure:

- `ChatPartnerStore(dio: ...)` with a fake `HttpClientAdapter` — required
  because the paired branch now really mounts `AppShell`, whose `ChatEntryGate`
  wrap resolves the store eagerly on build.
- `getIt.registerSingleton<CouplePairingStore>(...)` in `setUp` with
  `tearDown(() => getIt.reset())` — `HomeScreen`'s `_TimelineEntryPointGate`
  resolves it unconditionally and has no override reachable through
  `AppShell`'s `const HomeScreen()`. The `tearDown` reset makes this
  non-leaking.
- `AppL10n.localizationsDelegates` / `supportedLocales` / `locale: Locale('en')`
  — required by `AppShell`'s account-hub FAB tooltip, and pinning `en` keeps
  the pre-existing English `find.text` assertions deterministic rather than
  locale-dependent. This strengthens, not weakens, the assertions.

The `pump()` -> `pumpAndSettle()` change is confined to the single
`paired routes into the main tab shell` test and is the correct fix for the
`'!timersPending'` framework assertion caused by the newly-mounted `AppShell`
kicking off store fetches on build. It is not a way to hide a failure: the
assertions after it (`HomeScreen` present, `pairing_stack` absent) are
unchanged and still discriminating.

### 4. Target test — PASS (9/9), re-run by reviewer

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter test test/features/pairing/presentation/pair_gate_cubit_test.dart
```

```
00:00 +9: All tests passed!
```

All four `PairGateCubit` unit tests plus all five `PairGateShell gate (AC4)`
widget tests pass. Matches the claimed evidence exactly.

### 5. Build Gate — PASS, re-run by reviewer

Registry command (`runtimes.mobile-app.buildCommand` in
`data/devops/system/runtime-command-registry.json`):

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter build apk --debug
```

```
Running Gradle task 'assembleDebug'...                           1,767ms
✓ Built build/app/outputs/flutter-apk/app-debug.apk
BUILD_EXIT=0
```

The `sign_in_with_apple` KGP warning is pre-existing and unrelated, as claimed.

### 6. Runtime Startup Gate — PASS, re-verified by reviewer

`runtimes.mobile-app.readiness` in the registry is `type: widget-test`, not an
HTTP probe: readiness is the pump of `Key('home_screen_ready_signal')`
exercised via `flutter test`, and the registry's own `notes` confirm the root
scripts do not launch `flutter run` headlessly. The bug-fixer's scoping of this
gate to a widget-test signal is correct per the registry, not an evasion.

Re-verified green in the reviewer's own full-suite run:

- `test/widget_test.dart: App boots to the home screen ready signal` — pass
- this bug's own `paired routes into the main tab shell`, which mounts
  `AppShell` through `PairGateShell` and finds `HomeScreen` — pass

Scoping to `mobile-app` only is correct: the change touches no backend or
shared code.

### 7. No new regression — CONFIRMED

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter test --reporter compact
```

Reviewer result: `00:18 +889 -1: Some tests failed.` — exactly the claimed
`+889 -1`.

The single failure is:

```
test/features/reminders/reminder_copy_guard_test.dart:
  mobile/lib string literals never say "báo thức"/"Synced Alarm"/"Do Not Disturb" (AC2/AC3, ADR-002)
  Expected: empty
    Actual: [
      'lib/l10n/generated/app_l10n_vi.dart:429: forbidden token "synced alarm"',
      'lib/l10n/generated/app_l10n_en.dart:431: forbidden token "synced alarm"'
    ]
```

That is the separately queued `BUG-20260801-007`, in generated l10n files this
fix never touched, and it is explicitly out of this bug's scope per
`bug_master.md` § Constraints. Not a regression from this change. Full
re-verification of `-007` is out of scope for this review.

## Deferred / follow-up items

None blocking. Two observations recorded for Scrum Master, neither requiring a
patch here:

1. The REQ-001 `development-local` readiness gate stays red until
   `BUG-20260801-007` is fixed, because `scripts/start-dev.sh` hard-gates on
   the whole `flutter test` run. The bug-fixer already flagged this; it is
   accurate and belongs to `-007`, not to this bug.
2. The fix is currently uncommitted in the control checkout. Committing it is
   Scrum Master's Git control-plane responsibility, not the Reviewer's.

## Verdict

Outcome: CLEAN

The diagnosis is independently confirmed, the fix is minimal and test-only, no
assertion was weakened, and all four gates (target test, build, runtime
startup, full-suite regression) were re-run by the Reviewer and match the
claimed evidence exactly.
