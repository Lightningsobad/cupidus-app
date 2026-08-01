# Bug Master: BUG-20260801-002_test_harness_getit_registration_gaps

Status: DONE — fix committed `d667861` by Justin-BugFixer-2, independently
re-verified twice by Scrum Master (diff scope, readiness gate rerun) and by
Reviewer Iris-QC-2 (`Outcome: CLEAN` in `review/review-report.md`: diff
scope, `service_locator.dart` untouched/correct, Build Gate exit 0, Runtime
Startup Gate exit 0, zero remaining GetIt errors across all 7 files).
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

See `fix-evidence.md` and `diagnosis.md` (written by Justin-BugFixer-2).
Summary: two fix patterns, no production code touched — `HomeScreen`-mounting
tests pass a `resolvePairingStatus` override (existing STORY-012 precedent);
`AppShell`-mounting tests register real `CouplePairingStore`/`ChatPartnerStore`
backed by a fake non-throwing `Dio` adapter directly into `getIt` in
`setUp`/`tearDown`. Verified: zero `"is not registered inside GetIt"`
occurrences across 3 consecutive full `flutter test` runs (was 8 at
baseline); `flutter build apk --debug` exit 0; final full suite 874
passed / 8 failed, all 8 pre-existing/newly-unmasked and unrelated to GetIt.

Newly-discovered findings from this fix, triaged separately (not folded into
this bug's closure):
- Stale `InkWell` tab-count assertions in `app_shell_test.dart` (paired +
  unpaired) — filed as `BUG-20260801-004`, independently reproduced by
  Scrum Master.
- 2 additional `AppL10n.of` null-check crash sites (`app_shell.dart:203`'s
  FAB tooltip in `gallery_cubit_test.dart`; `DreamJarEntryCard` in
  `pet_entry_point_test.dart`) — folded into `BUG-20260801-003`'s existing
  scope (same root-cause family, not yet dispatched).
- `reminder_entry_point_test.dart` asserts a structurally unreachable widget
  (`ReminderOverlayHost`, only mounted by `PairGateShell`, never composed by
  this test's harness) — filed as `BUG-20260801-005`.

## Review

(Reviewer fills in `review/review-report.md`)

BUG_FIX_COMPLETE: YES
