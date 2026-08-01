# Bug Master: BUG-20260801-002_test_harness_getit_registration_gaps

Status: PENDING
Linked Requirement: REQ-001_cupid_flutter_mobile_app — **this bug directly
blocks the registry-defined mobile readiness gate**
(`mobile/test/widget_test.dart`, `runtimes.mobile-app.readiness` in
`data/devops/system/runtime-command-registry.json`), so it must be fixed
before REQ-001's Integration Build & Runtime evidence gate can pass.
Discovered by: Justin-BugFixer, as a masked/out-of-scope finding while
fixing `BUG-20260801-001_app_shell_chat_gate_l10n_null` (see that bug's
`diagnosis.md` items 1-2 for the original discovery notes; this record is
the authoritative scope for the fix, do not re-read that diagnosis.md).

## Scope

- Branch: `codex/REQ-001_cupid_flutter_mobile_app-integration`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`
- Worktree HEAD at discovery: `3c3e9f0` (after BUG-20260801-001's fix)
- Same branch-topology caveat as BUG-20260801-001: `main` does not carry
  this code (`mobile/lib/features/home/presentation/home_screen.dart` and
  the affected test files are integration-branch-only). Fix must land on
  the integration branch/worktree above, not `main`.

## Reproduction

```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app/mobile
$HOME/flutter/bin/flutter test
```

## Failure anchor

Two distinct `GetIt` "not registered" `Bad state` errors, both under the
same defect family (a widget/test builds and resolves a dependency from
`GetIt.instance` that the active test's setup never registered — the
requirement integration review already confirmed the *production*
`service_locator.dart` registers both types correctly, so this is a
test-harness/test-setup gap, not a production DI gap; bug-fixer must verify
this, not assume it):

1. `Bad state: GetIt: ... CouplePairingStore is not registered inside GetIt.`
   — thrown building `_TimelineEntryPointGate`
   (`mobile/lib/features/home/presentation/home_screen.dart:133`, via
   `_defaultResolvePairingStatus` at line 72). Affects:
   - `mobile/test/widget_test.dart` — **"App boots to the home screen ready
     signal" — this is the readiness gate test itself.**
   - `mobile/test/app/feature_flags_test.dart`
   - `mobile/test/core/navigation/app_shell_test.dart` ("paired" case —
     newly unmasked now that BUG-20260801-001's AppL10n crash no longer
     fires first in this same test)
2. `Bad state: GetIt: ... ChatPartnerStore is not registered inside GetIt.`
   — thrown building `AppShell` itself (`mobile/lib/core/navigation/app_shell.dart:76`).
   Affects:
   - `mobile/test/features/gallery/gallery_cubit_test.dart`
   - `mobile/test/features/reminders/reminder_entry_point_test.dart`
     (file name as reported by Justin-BugFixer; confirm exact path when
     reproducing)

Git history note from Justin-BugFixer: `app_shell_test.dart` predates
STORY-012's Timeline entry point, so the `CouplePairingStore` gap likely
predates STORY-015 entirely and was only masked until now by
BUG-20260801-001's AppL10n crash throwing earlier in the same widget build.

## Constraints for the fix

- Fix must land on `codex/REQ-001_cupid_flutter_mobile_app-integration` in
  the worktree above, not `main`.
- Do not touch production `service_locator.dart` registrations unless the
  fix confirms they are genuinely missing there too (the integration review
  already read that file in full and found `CouplePairingStore` correctly
  registered — re-verify `ChatPartnerStore` registration there as well
  before concluding this is test-only).
- Do not "fix" the pre-existing, already-triaged, out-of-scope items:
  `pair_gate_cubit_test.dart` constructor mismatch,
  `reminder_copy_guard_test.dart`, ~76 `prefer_initializing_formals` lints,
  or `BUG-20260801-003_anti_ghost_entry_card_l10n_null` (separate bug).
- This bug blocks the REQ-001 Integration Build & Runtime evidence gate. It
  must not be waived, especially item 1 (the readiness gate test itself).

## Fix Evidence

(bug-fixer fills in `fix-evidence.md`)

## Review

(Reviewer fills in `review/review-report.md`)

BUG_FIX_COMPLETE: NO
