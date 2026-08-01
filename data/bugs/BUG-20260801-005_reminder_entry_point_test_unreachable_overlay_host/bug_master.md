# Bug Master: BUG-20260801-005_reminder_entry_point_test_unreachable_overlay_host

Status: DONE — fix `2efa148` by Justin-BugFixer-2. Reviewer Iris-QC-2
`Outcome: CLEAN` (`review/review-report.md`), independently confirmed by
Scrum Master via direct read: diff scope (1 test file, 5 insertions/1
deletion, no production code), fix direction independently re-verified
against the real `CupidApp -> PairGateShell -> ReminderOverlayHost ->
AppShell` composition root, 2/2 target tests + Runtime Startup Gate +
Build Gate all pass. This is the last of the 5 REQ-001 bugs; the earlier
full unfiltered suite rerun (880 pass / 2 pre-existing fail) serves as the
Integration Build & Runtime evidence gate's test baseline.
Linked Requirement: REQ-001_cupid_flutter_mobile_app (blocks its Integration
Build & Runtime evidence gate; does NOT block the readiness gate test
itself).
Discovered by: Justin-BugFixer-2, as a masked/out-of-scope finding (item 3)
while fixing `BUG-20260801-002_test_harness_getit_registration_gaps`;
independently reproduced by Scrum Master as noted above.

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
$HOME/flutter/bin/flutter test test/features/reminders/reminder_entry_point_test.dart
```

## Failure anchor

Per Justin-BugFixer-2's report: the test asserts `find.byType(ReminderOverlayHost)`,
but that widget is only mounted by `PairGateShell` — a widget this test's
harness never composes (it pumps a bare `AppShell()` directly). The
assertion is therefore structurally unreachable regardless of GetIt
registration state; `BUG-20260801-002`'s fix (registering
`CouplePairingStore`/`ChatPartnerStore` for `AppShell`-mounting tests) does
not and cannot resolve this.

## Working hypothesis (NOT a diagnosis — context only)

Two plausible directions, unverified — bug-fixer must confirm via its own
query-first reading before choosing:
1. The test's harness is wrong: it should pump `PairGateShell` (or whatever
   composition root actually mounts `ReminderOverlayHost` in production),
   not bare `AppShell()`.
2. The assertion itself is testing the wrong widget/location and should
   target something `AppShell` actually mounts.
Confirm which by reading the real composition root
(`mobile/lib/app/cupid_app.dart` and/or wherever `PairGateShell` is
instantiated in production) before deciding.

## Constraints for the fix

- Fix must land on `codex/REQ-001_cupid_flutter_mobile_app-integration` in
  the worktree above, not `main`.
- Do not touch `service_locator.dart`, `app_shell.dart`, or `home_screen.dart`
  production DI wiring (already verified correct by `BUG-20260801-002`'s
  fix) unless this bug's own investigation finds a genuine, separately
  confirmed production gap.
- Do not "fix" the pre-existing, already-triaged, out-of-scope items:
  `pair_gate_cubit_test.dart` constructor mismatch,
  `reminder_copy_guard_test.dart`, ~76 `prefer_initializing_formals` lints,
  or the other REQ-001 bugs (`BUG-20260801-002`, `-003`, `-004`).
- This bug blocks the REQ-001 Integration Build & Runtime evidence gate. It
  must not be waived.

## Fix Evidence

(bug-fixer fills in `fix-evidence.md`)

## Review

(Reviewer fills in `review/review-report.md`)

BUG_FIX_COMPLETE: YES
