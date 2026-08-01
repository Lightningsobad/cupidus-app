# Bug Master: BUG-20260801-004_app_shell_test_stale_inkwell_tab_count

Status: DONE — fix `b07a632` by Justin-BugFixer-2. Reviewer Iris-QC-2
`Outcome: CLEAN` (`review/review-report.md`), independently confirmed by
Scrum Master via direct read: diff scope (1 test file, 4 insertions/2
deletions, no production code), fix direction independently verified
against `app_shell.dart`'s actual tab composition, 5/5 tests + Runtime
Startup Gate + Build Gate all pass.
Linked Requirement: REQ-001_cupid_flutter_mobile_app (blocks its Integration
Build & Runtime evidence gate; does NOT block the readiness gate test itself
— `widget_test.dart` passes independently of this bug).
Discovered by: Scrum Master, independently re-running
`flutter test test/core/navigation/app_shell_test.dart` in the integration
worktree after `BUG-20260801-002`'s fix landed (commit `d667861`), to verify
that fix's claims. Corroborated by Justin-BugFixer-2's own report (finding
1) while fixing `BUG-20260801-002`.

## Scope

- Branch: `codex/REQ-001_cupid_flutter_mobile_app-integration`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`
- Worktree HEAD at discovery: `d667861` (after `BUG-20260801-002`'s fix)
- Same branch-topology caveat as the other REQ-001 bugs: `main` does not
  carry this code. Fix must land on the integration branch/worktree above,
  not `main`.

## Reproduction

```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app/mobile
$HOME/flutter/bin/flutter test test/core/navigation/app_shell_test.dart
```

## Failure anchor (both independently reproduced by Scrum Master)

- "paired: Home renders with the readiness key, Chat is reachable, and the
  ghostset action opens GhostSettingsScreen from Chat" (line ~199):
  `Expected: exactly 2 matching candidates / Actual: Found 3 widgets with
  type "InkWell" descending from widgets with type "CupidTabBar"`.
- "unpaired: Chat is hidden, Home still renders with the readiness key, no
  pet/money/me destinations exist" (line ~242): `Expected: exactly one
  matching candidate / Actual: Found 2 widgets with type "InkWell"
  descending from widgets with type "CupidTabBar"`.

Neither failure contains a GetIt or `AppL10n.of` error — `BUG-20260801-002`'s
fix is confirmed NOT implicated; this is a distinct root-cause family.

## Working hypothesis (NOT a diagnosis — context only)

Per Justin-BugFixer-2's report: the test's expected `InkWell` tab count
under `CupidTabBar` was never updated for STORY-013's unconditional Gallery
tab addition — actual live counts are 3 (paired) / 2 (unpaired), the test
still expects 2 (paired) / 1 (unpaired). This reads as a stale test
assertion (test-only), not a production defect, but bug-fixer must confirm
via its own query-first reading, not assume.

## Constraints for the fix

- Fix must land on `codex/REQ-001_cupid_flutter_mobile_app-integration` in
  the worktree above, not `main`.
- Do not touch production `app_shell.dart` tab composition unless the fix
  confirms the actual tab count is a production defect rather than a stale
  test expectation — re-verify against STORY-013's intended tab set before
  concluding this is test-only.
- Do not "fix" the pre-existing, already-triaged, out-of-scope items:
  `pair_gate_cubit_test.dart` constructor mismatch,
  `reminder_copy_guard_test.dart`, ~76 `prefer_initializing_formals` lints,
  or the other REQ-001 bugs (`BUG-20260801-002`, `-003`, `-005`).
- This bug blocks the REQ-001 Integration Build & Runtime evidence gate. It
  must not be waived.

## Fix Evidence

(bug-fixer fills in `fix-evidence.md`)

## Review

(Reviewer fills in `review/review-report.md`)

BUG_FIX_COMPLETE: YES
