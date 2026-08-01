# Diagnosis: BUG-20260801-006_pair_gate_cubit_test_stale_app_shell_seam

## Reproduced failure (verified on `main`, HEAD `c984e5a`)

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter test test/features/pairing/presentation/pair_gate_cubit_test.dart
```

```
test/features/pairing/presentation/pair_gate_cubit_test.dart:26:7: Error: No named parameter with the name 'createPairGateCubit'.
      createPairGateCubit: () => PairGateCubit(getPartnerLink: getPartnerLink),
      ^^^^^^^^^^^^^^^^^^^
lib/core/navigation/app_shell.dart:49:9: Context: Found this candidate, but the arguments don't match.
```

Compile failure at test-load time, matching the reported anchor exactly.

## Root cause

The pair gate was **extracted out of `AppShell` into a new widget**,
`mobile/lib/core/navigation/pair_gate_shell.dart` (`PairGateShell`), and the
test file was never repointed at the new widget.

Current ownership on `main`:

- `PairGateShell` (`pair_gate_shell.dart:42`) owns the `PairGateCubit`
  `BlocProvider`, the `PairGateChecking` / `PairGateUnpaired` /
  `PairGatePaired` switch (`:122`), and the `_PairingStack` widget that carries
  `Key('pairing_stack')` (`:203`) plus the "Pair with your partner" /
  "I already have a code" entry actions (`:219`, `:226`).
- `AppShell` (`app_shell.dart:48`) is now **only** the paired-side tab shell
  (Home / Chat-gated / Gallery). It is what `PairGateShell` renders in its
  `PairGatePaired()` branch (`pair_gate_shell.dart:129`).

So every symbol the test exercises still exists in production; it simply lives
one widget higher than it did when the test was written.

## Hypothesis resolution

Working hypothesis 1 (rewrite the test against the current shape) is correct,
with the correction that the target widget is `PairGateShell`, not `AppShell`.

Hypothesis 2 (a real production testability gap) is **ruled out**:
`PairGateShell` preserves all three injection seams the test needs with
identical names and signatures —

```dart
const PairGateShell({
  PairGateCubit Function()? createPairGateCubit,
  InviteCubit Function()? createInviteCubit,
  JoincodeCubit Function()? createJoincodeCubit,
  ...
})
```

No production change is required. Corroborating evidence that these seams are
live and intended: `lib/app/cupid_app.dart:44` forwards `createPairGateCubit`
into `PairGateShell`, and `test/app/feature_flags_test.dart:72` and
`test/widget_test.dart:63` both already drive the gate through `CupidApp`'s
forwarded seam and compile cleanly today.

## Why the whole file failed, not just the widget group

The four pure `PairGateCubit` unit tests in the file are correct and untouched
by the refactor, but Dart compiles the test file as a unit — one stale
constructor call in `_harness` fails the entire file, including those unit
tests.

## Fix shape (smallest safe patch)

Test-only change to
`mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart`:

1. Point `_harness` at `PairGateShell` instead of `AppShell`; the three
   `create*Cubit` arguments carry over unchanged.
2. Satisfy the paired branch, which now really does mount `AppShell`
   (it did not before, when `AppShell` was itself the gate):
   - inject a fake-`Dio`-backed `ChatPartnerStore` (consumed eagerly by
     `AppShell`'s `ChatEntryGate` wrap, `app_shell.dart:116`);
   - register a `CouplePairingStore` in `getIt`, resolved unconditionally on
     build by `HomeScreen`'s `_TimelineEntryPointGate`
     (`home_screen.dart:72`), which has no constructor override reachable
     from `AppShell`'s `const HomeScreen()`;
   - add `AppL10n.localizationsDelegates` / `supportedLocales`, required by
     `AppShell`'s account-hub FAB tooltip (`app_shell.dart:203`).

   All three mirror the already-passing
   `test/core/navigation/app_shell_test.dart` harness rather than inventing a
   new pattern.

`ReminderOverlayHost` (wrapped around the tree by `PairGateShell`) needs no
setup: it renders its child bare when `ReminderFiringCubit` is unregistered
(`reminder_overlay_host.dart:40`).

No production file is modified. `BUG-20260801-007`'s
`reminder_copy_guard_test.dart` and all ARB files are untouched.
