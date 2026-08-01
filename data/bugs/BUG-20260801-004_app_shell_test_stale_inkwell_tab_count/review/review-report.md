# Review Report: BUG-20260801-004_app_shell_test_stale_inkwell_tab_count

Reviewer: Iris-QC
Mode: bugfix-review

## Verification performed

1. **Diff matches claim.** `git show b07a632` on
   `codex/REQ-001_cupid_flutter_mobile_app-integration`
   (worktree `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`)
   touches only `mobile/test/core/navigation/app_shell_test.dart` (4
   insertions, 2 deletions). The diff changes exactly two `findsNWidgets`
   assertions: `findsNWidgets(2)` -> `findsNWidgets(3)` (paired case) and
   `findsNWidgets(1)` -> `findsNWidgets(2)` (unpaired case), each with an
   added explanatory comment. No other file, and no production code,
   appears in the diff.
2. **No production code touched.** `git status --porcelain` on the worktree
   shows no staged/unstaged/uncommitted source changes — only the same
   pre-existing untracked `integration-review/` artifact directory seen in
   prior reviews of this branch.
3. **Correct direction of fix, independently verified against production
   code.** Read `mobile/lib/core/navigation/app_shell.dart`'s
   `_AppShellState.build` (lines 118-133) directly: the tab item list
   always includes Home, conditionally includes Chat only `if (isUnlocked)`,
   and always includes Gallery — exactly matching the fix's new expected
   counts (paired = Home+Chat+Gallery = 3; unpaired = Home+Gallery = 2).
   This confirms the fix corrected the *test's* stale expectation to match
   already-correct, unmodified production behavior, not the reverse.
4. **Both target cases and the Runtime Startup Gate pass.** Independently
   ran `flutter test test/core/navigation/app_shell_test.dart
   test/widget_test.dart` → `5/5 passed, All tests passed!`, exit 0. This
   covers both previously-failing "paired"/"unpaired" tests, the two
   untouched STORY-005 pairing-source isolation guard tests in the same
   file, and the registry readiness test.
5. **Build Gate.** Independently ran `flutter build apk --debug` in the
   worktree's `mobile/` dir → exit 0 (`✓ Built
   build/app/outputs/flutter-apk/app-debug.apk`).

## Scope discipline

The remaining out-of-scope failures named in fix-evidence.md's full-suite
regression check — `reminder_entry_point_test.dart`'s
`ReminderOverlayHost` assertion (BUG-20260801-005, already independently
reproduced and in progress per Scrum Master's checkpoint) and the two
pre-existing `pair_gate_cubit_test.dart` / `reminder_copy_guard_test.dart`
failures — are correctly not judged as part of this bug's outcome, per the
handoff.

## Assessment

The fix is correct, minimal, and safe: it updates two stale test
assertions to match already-correct production tab composition
(confirmed by direct reading of `app_shell.dart`), touching no production
code. Both target test cases now pass, the two adjacent untouched
STORY-005 guard tests in the same file are unaffected, the Runtime Startup
Gate passes, and the Build Gate passes.

Outcome: CLEAN

REVIEW_COMPLETE: YES
