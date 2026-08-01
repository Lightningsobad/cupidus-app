# Diagnosis: BUG-20260801-004_app_shell_test_stale_inkwell_tab_count

## Root cause

Stale test assertion, not a production defect. Confirmed by reading
`mobile/lib/core/navigation/app_shell.dart` in full: the class doc comment
(lines 36-41) and the `_AppShellState.build` tab-item list (lines 119-133)
both explicitly state and implement that the Gallery destination
(STORY-013 epic-4) is always present alongside Home, independent of
pairing status, while Chat is gated by `isUnlocked` (paired). This gives:

- Paired (`isUnlocked: true`): Home + Chat + Gallery = 3 tab items → 3
  `InkWell`s under `CupidTabBar`.
- Unpaired (`isUnlocked: false`): Home + Gallery = 2 tab items → 2
  `InkWell`s under `CupidTabBar`.

`mobile/test/core/navigation/app_shell_test.dart` still asserted the
pre-STORY-013 expectations (`findsNWidgets(2)` paired, `findsNWidgets(1)`
unpaired — i.e. Home + Chat only, no Gallery), never updated when the
Gallery tab was added. The actual failure counts reported (`Found 3` /
`Found 2`) match the current, intended production tab composition exactly,
confirming this is a stale test expectation and not a production
regression. Production `app_shell.dart` tab composition was not modified.

## Fix

Updated the two `findsNWidgets` expectations in
`mobile/test/core/navigation/app_shell_test.dart` to match the current,
intended production tab count:
- "paired: ..." test: `findsNWidgets(2)` -> `findsNWidgets(3)`.
- "unpaired: ..." test: `findsNWidgets(1)` -> `findsNWidgets(2)`.

See `fix-evidence.md` for verification.

## Out-of-scope items observed, not touched

- `pair_gate_cubit_test.dart` constructor mismatch — pre-existing,
  unrelated.
- `reminder_copy_guard_test.dart` — pre-existing, unrelated.
- `reminder_entry_point_test.dart`'s structurally-unreachable
  `ReminderOverlayHost` assertion — `BUG-20260801-005`, not touched.
- ~76 `prefer_initializing_formals` lints — pre-existing, unrelated.
