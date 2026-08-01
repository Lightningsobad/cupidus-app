# Fix Evidence: BUG-20260801-006_pair_gate_cubit_test_stale_app_shell_seam

Fixed by: Justin-BugFixer (`Mode: fix-bug`)
Branch: `main`, control checkout
`/Users/alantravala/workspace/snapsofts/cupid-apps`
HEAD at fix: `c984e5a`
Root cause and hypothesis resolution: see `diagnosis.md`.

## Files changed

- `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart`
  (test-only)

**No production file was modified.** The pair gate had been extracted from
`AppShell` into `PairGateShell`
(`mobile/lib/core/navigation/pair_gate_shell.dart`), which preserves all three
injection seams (`createPairGateCubit` / `createInviteCubit` /
`createJoincodeCubit`) with identical names and signatures — so there is no
production testability gap, only a test pointed at the wrong widget.

## Change summary

1. `_harness` now constructs `PairGateShell` instead of `AppShell`; the three
   `create*Cubit` arguments carry over unchanged.
2. Paired-branch setup, which is newly required because that branch now really
   does mount `AppShell` (previously `AppShell` *was* the gate):
   - inject a fake-`Dio`-backed `ChatPartnerStore` (eagerly resolved by
     `AppShell`'s `ChatEntryGate` wrap);
   - register `CouplePairingStore` in `getIt` in `setUp`, with
     `tearDown(() => getIt.reset())` — `HomeScreen`'s `_TimelineEntryPointGate`
     resolves it unconditionally on build and has no override reachable from
     `AppShell`'s `const HomeScreen()`;
   - add `AppL10n.localizationsDelegates` / `supportedLocales` and an explicit
     `locale: const Locale('en')`, required by `AppShell`'s account-hub FAB
     tooltip and keeping the pre-existing English text assertions
     deterministic.
   All three mirror the already-passing `test/core/navigation/app_shell_test.dart`
   harness rather than introducing a new pattern.
3. `paired routes into the main tab shell` now uses `pumpAndSettle()` instead of
   a single `pump()`: the newly-mounted `AppShell` starts two store fetches on
   build, and a single pump left them as pending timers (test-framework
   `'!timersPending'` assertion). Same reason `app_shell_test.dart` settles.
4. Group label `AppShell gate (AC4)` renamed to `PairGateShell gate (AC4)` to
   match the widget actually under test.

No assertion was weakened or deleted — all 9 tests and every original
expectation are intact.

Out-of-scope files confirmed untouched: `reminder_copy_guard_test.dart`
(BUG-20260801-007), all ARB files, and all `AppShell` production wiring.

## Target test — PASS

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter test test/features/pairing/presentation/pair_gate_cubit_test.dart
```

Before: `Failed to load ... Error: No named parameter with the name
'createPairGateCubit'` (whole file failed to compile, 0 tests ran).

After:

```
00:00 +4: PairGateShell gate (AC4) unpaired routes into the pairing stack with no tab bar and a reachable "Pair with your partner" entry action
00:00 +5: PairGateShell gate (AC4) "I already have a code" navigates directly to JoincodeScreen
00:00 +6: PairGateShell gate (AC4) accepting a code via "I already have a code" navigates through to PairedScreen (onPaired production wiring)
00:00 +7: PairGateShell gate (AC4) paired routes into the main tab shell
00:00 +8: PairGateShell gate (AC4) a failed check falls back to the pairing stack, never exposing the tab shell while unresolved
00:00 +9: All tests passed!
```

## Static analysis — PASS

```
$HOME/flutter/bin/flutter analyze test/features/pairing/presentation/pair_gate_cubit_test.dart
No issues found! (ran in 1.7s)
```

Note: repo-wide `flutter analyze` from `mobile/` is unusable on this machine
for a pre-existing environmental reason unrelated to this bug — it sweeps
vendored sources under `mobile/build/ios/SourcePackages/checkouts/flutterfire/`
and reports hundreds of `cloud_firestore` errors. Scoped `flutter analyze lib
test` reports 77 issues, all `info`-level lints, all pre-existing in `lib/`,
none in the changed test file.

## Build Gate — PASS

Command from `data/devops/system/runtime-command-registry.json`
(`runtimes.mobile-app.buildCommand`):

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter build apk --debug
```

Exit code 0:

```
Running Gradle task 'assembleDebug'...                              7.2s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

(The `sign_in_with_apple` KGP warning is pre-existing and unrelated.)

## Runtime Startup Gate — PASS (scoped to `mobile-app`)

Per `runtimes.mobile-app.readiness` in the registry, mobile readiness is **not**
an HTTP probe: it is the pump of `Key('home_screen_ready_signal')` exercised via
`flutter test`. `flutter run` requires a connected device/emulator and is
interactive, so the registry's own `notes` field states the root scripts do not
launch it headlessly. Scope kept to `mobile` only — the fix touches no shared or
backend code, so no backend/Postgres/Redis stack was started.

Readiness signal verified green in the full-suite run below:

- `test/widget_test.dart: App boots to the home screen ready signal` — pass
- `test/core/navigation/app_shell_test.dart` paired + unpaired
  `home_screen_ready_signal` assertions — pass
- this bug's own new `paired routes into the main tab shell`, which mounts
  `AppShell` through `PairGateShell` and finds `HomeScreen` — pass

## Full mobile suite — no regressions

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter test
```

Result: `+889 -1`.

The single remaining failure is the **separate, already-queued** sibling bug,
not a regression from this fix:

```
Failing tests:
  mobile/test/features/reminders/reminder_copy_guard_test.dart: mobile/lib string literals never say "báo thức"/"Synced Alarm"/"Do Not Disturb" (AC2/AC3, ADR-002)
```

That is `BUG-20260801-007`, explicitly out of this bug's scope per
`bug_master.md` § Constraints for the fix. Before this fix the suite failed on
**two** files (this one at compile/load time plus `-007`); it now fails on
`-007` only.

## Impact on the REQ-001 `development-local` readiness gate

This bug is cleared, but the gate is **not yet fully green**: `start-dev.sh`
hard-gates on the whole `flutter test` run, so it will keep failing until
`BUG-20260801-007` (`reminder_copy_guard_test.dart`) is also fixed. Flagged for
Scrum Master routing; no action taken on `-007` here.

BUG_FIX_COMPLETE: YES
