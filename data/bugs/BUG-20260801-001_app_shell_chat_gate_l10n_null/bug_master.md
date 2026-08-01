# Bug Master: BUG-20260801-001_app_shell_chat_gate_l10n_null

Status: FIX_APPLIED — committed `3c3e9f0` on
`codex/REQ-001_cupid_flutter_mobile_app-integration`, awaiting Reviewer gate.
Root cause per Justin-BugFixer's diagnosis.md: `app_shell_test.dart`'s
`_harness()` pumped `AppShell` in a bare `MaterialApp` with no
`localizationsDelegates`/`supportedLocales`, unlike the real `cupid_app.dart`
boot path — a test-fixture gap, not a production defect. Fix: added
`AppL10n.localizationsDelegates`/`AppL10n.supportedLocales` to the harness.
No production code changed. `flutter analyze` clean, `flutter build apk
--debug` exit 0.
Correction to the original hypothesis: not all 10 `flutter test` failures
shared this root cause. Only `app_shell_test.dart`'s 2 tests were this bug;
diagnosis surfaced 3 further, previously-masked, genuinely separate defects
now filed as `BUG-20260801-002_test_harness_getit_registration_gaps` and
`BUG-20260801-003_anti_ghost_entry_card_l10n_null`.
Linked Requirement: REQ-001_cupid_flutter_mobile_app (discovered during the
mandatory Integration Build & Runtime evidence gate, after requirement
integration review already recorded `Outcome: CLEAN`)
Discovered by: Scrum Master, running `flutter test` directly on the
integration branch as the registry-defined readiness gate (see
`data/devops/system/runtime-command-registry.json` `runtimes.mobile-app`:
readiness = `home_screen_ready_signal` widget key exercised via
`flutter test`).

## Scope

- Branch: `codex/REQ-001_cupid_flutter_mobile_app-integration`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`
- Worktree HEAD at discovery: `727677d93c2b0d00695653e4a88691735ac770ed`
  (the STORY-015 merge commit — this is the current tip of the integration
  branch; all 16 stories are merged here)
- This bug does NOT exist on `main` — `main`'s `mobile/lib/core/navigation/app_shell.dart`
  and `mobile/lib/features/chat/presentation/chat_entry_gate.dart` are far
  behind the integration branch (`git diff --stat main
  codex/REQ-001_cupid_flutter_mobile_app-integration -- mobile/lib/core/navigation/app_shell.dart
  mobile/lib/features/chat/presentation/chat_entry_gate.dart` = 255
  insertions / 5 deletions across those two files; `chat_entry_gate.dart`
  does not exist on `main` at all). The fix must be applied and verified
  directly on the integration branch/worktree above, not on `main`.

## Reproduction

```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app/mobile
$HOME/flutter/bin/flutter pub get
$HOME/flutter/bin/flutter test
```

Result: `00:23 +872 -10: Some tests failed.` (872 passed, 10 failed). Full
run log archived at
`data/runtime/integration-flutter-test.log` (control checkout, not the
worktree) for reference; do not re-read it in full — it is a raw command
capture, not a maintained artifact.

## Failure anchor — primary exception

Every observed failure shares the same crash signature: building
`ChatEntryGate` (mounted inside `AppShell`) throws
`Null check operator used on a null value` from `AppL10n.of`. First full
capture, from `mobile/test/core/navigation/app_shell_test.dart` ("paired:
Home renders with the readiness key, Chat is reachable, and the ghostset
action opens GhostSettingsScreen from Chat"):

```
The following _TypeError was thrown building ChatEntryGate(dirty, dependencies:
[_LocalizationsScope-[GlobalKey#aa7ed]], state: _ChatEntryGateState#63f67):
Null check operator used on a null value

The relevant error-causing widget was:
  ChatEntryGate
  ChatEntryGate:file:///.../mobile/lib/core/navigation/app_shell.dart:116:12

When the exception was thrown, this was the stack:
#0  AppL10n.of (package:cupid_mobile/l10n/generated/app_l10n.dart:71:55)
#1  _AppShellState.build.<anonymous closure> (package:cupid_mobile/core/navigation/app_shell.dart:203:30)
#2  _ChatEntryGateState.build (package:cupid_mobile/features/chat/presentation/chat_entry_gate.dart:52:55)
#3  StatefulElement.build (package:flutter/src/widgets/framework.dart:5931:27)
...
```

The ROOT boot smoke test itself fails from the same symptom class:

```
00:23 +872 -10: /Users/.../mobile/test/widget_test.dart: App boots to the home screen ready signal [E]
  Test failed. See exception logs above.
```

## Named failing tests (4 of 10 named individually by the runner; the other
6 are collapsed under "... and 6 more" in the reporter's final summary —
all failures observed during this run share the same `ChatEntryGate` /
`AppL10n.of` null-check crash signature)

- `mobile/test/widget_test.dart`: "App boots to the home screen ready
  signal" — **this is the registry-designated readiness gate itself.**
- `mobile/test/app/feature_flags_test.dart`: "CupidApp resolves dark theme
  mode and vi locale with flags off, and the runtime readiness key still
  resolves"
- `mobile/test/core/navigation/app_shell_test.dart`: "paired: Home renders
  with the readiness key, Chat is reachable, and the ghostset action opens
  GhostSettingsScreen from Chat"
- `mobile/test/core/navigation/app_shell_test.dart`: "unpaired: Chat is
  hidden, Home still renders with the readiness key, no pet/money/me
  destinations exist"
- `mobile/test/features/gallery/gallery_cubit_test.dart`: "AppShell gallery
  destination exposes a labelled gallery destination reachable by tap,
  opening GalleryScreen"
- ... and 6 more (bug-fixer should re-run `flutter test` in the worktree
  above to get the full current list; do not assume this list is exhaustive)

## Working hypothesis (NOT a diagnosis — Scrum Master does not diagnose
implementation root cause; this is context only for the assigned specialist)

`app_shell.dart:203` calls `AppL10n.of(context)` inside a closure passed to
`ChatEntryGate` (mounted at `app_shell.dart:116`), and `AppL10n.of` performs
a null-check (`!`) internally (`app_l10n.dart:71`) that is failing. This
smells like a localization delegate/provider not being present on the
widget tree at the point `ChatEntryGate` builds — possibly introduced or
exposed by the STORY-015 hand-resolved 7-file merge conflict (the only
manually resolved merge in this integration branch's history), since
`app_shell.dart` and `chat_entry_gate.dart` are both shared/cross-story
files per the requirement integration review's own scope gate. This is
unverified — bug-fixer must confirm actual root cause via its own
query-first reading, not assume this hypothesis.

## Constraints for the fix

- Fix must land on `codex/REQ-001_cupid_flutter_mobile_app-integration` in
  the worktree listed under Scope above (not `main` — `main` does not have
  this code).
- Do not touch unrelated files. `flutter analyze` and `flutter test` must be
  clean (or reach the same pre-existing-failure baseline documented in
  `data/requirements/REQ-001_cupid_flutter_mobile_app/scrum-master-checkpoint.md`
  "Known pre-existing, out-of-scope issues": `pair_gate_cubit_test.dart`
  constructor mismatch, `reminder_copy_guard_test.dart`, ~76
  `prefer_initializing_formals` info-lints — those three are NOT part of
  this bug and must not be conflated with it or "fixed" as a side effect
  without a separate bug record).
- This bug blocks the REQ-001 Integration Build & Runtime evidence gate and
  therefore blocks marking REQ-001 `DONE`. It must not be waived.

## Fix Evidence

(bug-fixer fills in `fix-evidence.md` with root cause, patch, and
`flutter test`/`flutter analyze` results)

## Review

(Reviewer fills in `review/review-report.md` with `Outcome:
CLEAN|DEFERRED_ONLY|PATCH_REQUIRED|BLOCKED`)

BUG_FIX_COMPLETE: NO
