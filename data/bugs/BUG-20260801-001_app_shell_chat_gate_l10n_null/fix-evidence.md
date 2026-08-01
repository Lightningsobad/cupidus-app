# Fix Evidence: BUG-20260801-001_app_shell_chat_gate_l10n_null

See diagnosis.md for full root-cause analysis and the correction to
bug_master.md's "all 10 failures share one signature" hypothesis.

## Patch

File changed (worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`,
branch `codex/REQ-001_cupid_flutter_mobile_app-integration`):

- `mobile/test/core/navigation/app_shell_test.dart`
  - Added `import 'package:cupid_mobile/l10n/generated/app_l10n.dart';`
  - Added `localizationsDelegates: AppL10n.localizationsDelegates,` and
    `supportedLocales: AppL10n.supportedLocales,` to the `_harness()`
    helper's `MaterialApp`, matching the real composition root
    (`mobile/lib/app/cupid_app.dart`).

No production code (`app_shell.dart`, `chat_entry_gate.dart`,
`app_l10n.dart`) was changed — the defect was entirely in the test harness,
not the app.

## Verification

- `flutter analyze test/core/navigation/app_shell_test.dart` → "No issues
  found!" (1.9s).
- `flutter build apk --debug` → exit 0 (Build Gate: PASS).
- `flutter test test/core/navigation/app_shell_test.dart` (before fix):
  both tests fail with `_TypeError`, `Null check operator used on a null
  value`, stack `AppL10n.of` -> `_AppShellState.build` -> `ChatEntryGate.build`
  (matching bug_master.md's failure anchor exactly).
- `flutter test test/core/navigation/app_shell_test.dart` (after fix): the
  `AppL10n.of` crash is gone from both tests (confirmed zero occurrences of
  `AppL10n.of` / "Null check operator" in the full-suite rerun's output for
  this file). Both tests now fail for a **different, unrelated** reason —
  `Bad state: GetIt: ... CouplePairingStore is not registered inside
  GetIt` building `_TimelineEntryPointGate` inside `HomeScreen` (paired
  test), and a pre-existing unrelated `InkWell` duplicate-tab-icon
  assertion mismatch (unpaired test) — both are separate, previously-masked
  defects, not part of this bug's scope. See Blocker below.
- Full-suite `flutter test` before fix: `872 passed, 10 failed`. Full-suite
  `flutter test` after fix: `872 passed, 10 failed` (same totals — the two
  `app_shell_test.dart` tests still fail, but now for the newly-unmasked,
  out-of-scope `CouplePairingStore` GetIt gap instead of the diagnosed
  `AppL10n` crash). No `AppL10n.of`/localization null-check crash remains
  anywhere in `app_shell_test.dart`'s tests; the two other `AppL10n.of`
  crashes still present in the suite (`vibe_screen_test.dart`,
  `pet_entry_point_test.dart`, via `_AntiGhostEntryCardChrome`, an
  unrelated production widget) are explicitly out of this bug's declared
  scope (`app_shell.dart` / `chat_entry_gate.dart` only) and were left
  untouched per the "do not touch unrelated files" constraint.

## Blocker for the Runtime Startup Gate as literally stated in the handoff

The handoff's Runtime Startup Gate requires "all 10 previously-failing
tests now passing... as satisfying this gate." That cannot be achieved by
this bug alone: only 2 of the 10 originally-failing tests were actually
this bug's `AppL10n`/`ChatEntryGate` defect (both now fixed and verified
clean of that crash). The other 8 have distinct, unrelated root causes
discovered during this session (see diagnosis.md):

1. `Bad state: GetIt: ... CouplePairingStore is not registered inside
   GetIt` (`_TimelineEntryPointGate`, `home_screen.dart:133`) — affects
   `widget_test.dart` (the readiness gate itself),
   `feature_flags_test.dart`, and now-unmasked in
   `app_shell_test.dart`'s "paired" test.
2. `Bad state: GetIt: ... ChatPartnerStore is not registered inside GetIt`
   (`AppShell.build`, `app_shell.dart:76`) — affects
   `gallery_cubit_test.dart` and `reminder_entry_point_test.dart`.
3. The same `AppL10n.of` null-check defect pattern as this bug, but via a
   different production widget (`_AntiGhostEntryCardChrome`) — affects
   `vibe_screen_test.dart` and `pet_entry_point_test.dart`.
4. `pair_gate_cubit_test.dart` / `reminder_copy_guard_test.dart` — the two
   already-triaged, explicitly out-of-scope items named in bug_master.md's
   Constraints section (left untouched, as instructed).

Recommend Scrum Master file separate bug record(s) for items 1-3 above
before REQ-001's Integration Build & Runtime evidence gate can go fully
green. This bug (BUG-20260801-001) is complete for its own declared scope
(`app_shell.dart` `chat_entry_gate.dart` `AppL10n.of` null crash) but the
registry readiness test will remain red until item 1 (and, transitively,
item 3 if folded into the same fix wave) is also resolved.

BUG_FIX_COMPLETE: NO
