# Fix Evidence: BUG-20260817-001 Chat FAB Occludes Send Button

Bug: `BUG-20260817-001_chat_fab_occludes_send_button`
Role: bug-fixer (Justin-BugFixer)
Date: 2026-08-23
Repo state: branch `main`, HEAD `a11959d`
Diagnosis: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/diagnosis.md`

## Summary

The reported occlusion is already absent from current source: commit `3d74a75`
(STORY-061, 2026-08-20) deleted the account-hub `FloatingActionButton` from
`mobile/lib/core/navigation/app_shell.dart` when it replaced the provisional
3-tab shell with the design's 5 destinations. The bug was filed 2026-08-17,
before that commit.

No production source change was needed. The change made here is the missing
regression guard, in one test file.

## Changed Files

- `mobile/test/core/navigation/app_shell_test.dart` — added regression test
  `chat tab: the composer send button is hit-testable, not occluded by shell
  chrome (BUG-20260817-001)`, plus `package:flutter/gestures.dart` and
  `chat_composer.dart` imports.

Total: 1 file. `mobile/lib/core/navigation/app_shell.dart` and
`mobile/lib/features/chat/presentation/widgets/chat_composer.dart` are
unmodified (`git diff` on both is empty).

## Regression Coverage

The new test pumps `AppShell` paired, selects the `Chat` destination, enters a
non-empty draft so the send button is enabled, then asserts the send button's
`RenderBox` appears in the hit-test path for a pointer at its own centre. This
asserts the property the bug was about (the primary action receives the
pointer), not merely the absence of one widget class, so it also catches a
non-FAB occluder.

### Mutation check — the guard actually catches the original defect

The guard was verified by temporarily re-adding an `endFloat`
`FloatingActionButton` to `AppShell`'s `Scaffold`, exactly as it existed before
`3d74a75`, and rerunning only the new test.

Command:
`flutter test test/core/navigation/app_shell_test.dart --plain-name 'chat tab: the composer send button is hit-testable, not occluded by shell chrome (BUG-20260817-001)'`

Result with the FAB reintroduced: **FAIL**

```
Expected: true
  Actual: <false>
a pointer at the send button centre never reached it; something in the shell is
painted above the chat composer
00:01 +0 -1: Some tests failed.
```

The mutation was then fully reverted; `git diff -- mobile/lib/core/navigation/app_shell.dart`
is empty.

## Regression Test Gate

Command:
`cd mobile && /Users/alantravala/flutter/bin/flutter test test/core/navigation/app_shell_test.dart`

Result: PASS — `00:01 +10: All tests passed!` (all 10 tests in the shell suite,
including the new BUG-20260817-001 guard, which the run lists as `+5`).

Static analysis of the touched file:
`cd mobile && /Users/alantravala/flutter/bin/flutter analyze test/core/navigation/app_shell_test.dart`
→ `No issues found! (ran in 1.5s)`

## Build Gate

Runtime id: `mobile-app` (`data/devops/system/runtime-command-registry.json`,
`runtimes.mobile-app.buildCommand`).

Command:
`cd mobile && /Users/alantravala/flutter/bin/flutter build apk --debug`

Result: PASS

```
Running Gradle task 'assembleDebug'...                              5.4s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

(Flutter SDK resolved at `/Users/alantravala/flutter/bin/flutter` per the
registry's `runtimes.mobile-app.sdk` note — it is not on this machine's PATH.)

## Runtime Startup Gate

Runtime Id: `mobile-app` (registry `runtimes.mobile-app.readiness`, platform
`android`).

Preconditions satisfied: device `HT7AH1A02116` booted and visible to `adb`;
`MOBILE_DEVICE_SERIAL=HT7AH1A02116`; the debug APK from the build gate installed
onto it with `adb -s HT7AH1A02116 install -r -d build/app/outputs/flutter-apk/app-debug.apk`
(`Success`).

Command (registry `readiness.command`, verbatim):
`adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity >/dev/null && for _ in $(seq 1 30); do adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" && exit 0; sleep 2; done; exit 1`

Ready Check: OS reports `com.snapsofts.cupid/...MainActivity` as `ResumedActivity`
(registry `expectExitCode: 0`).

Result: PASS — probe returned exit code 0 (`READINESS_EXIT_0`).

Shutdown command (registry `readiness.shutdownCommand`):
`adb -s "$MOBILE_DEVICE_SERIAL" shell am force-stop com.snapsofts.cupid`

Shutdown: PASS — exit 0 (`SHUTDOWN_EXIT_0`); a follow-up
`dumpsys activity activities` count of `ResumedActivity.*com.snapsofts.cupid`
returned `0`.

## Original Failure Recheck Gate

Same modality as original: YES — rendered on-device capture of the shell-wrapped
`chat` screen, plus a real pointer tap on the send button. Not unit-test-only,
not build-only.

Environment: device `HT7AH1A02116` (Pixel 2, Android), dark theme, `vi` locale,
Material platform axis, `chat` route opened shell-wrapped through the app's own
preview harness (`mobile/lib/main_preview.dart`, `chat` entry is
`wrapInShell: true`, i.e. `AppShell` + `ChatScreen` in one tree).

Proof paths:
- `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/evidence/recheck-chat-shell-empty-draft.png`
- `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/evidence/recheck-chat-shell-enabled-send.png`
- `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/evidence/recheck-chat-shell-after-send-tap.png`

Reproduction steps re-run, matching `bug_master.md` §Report steps 1-3:

1. Launched the app to the shell-wrapped `chat` tab.
   Expected: the account-hub FAB covers the bottom-right corner of the composer.
   Actual: 5-tab bar (`Nhà / Trò chuyện / Pet / Ví chung / Tôi`), no FAB
   anywhere, send button fully visible.
   (`recheck-chat-shell-empty-draft.png`)

2. Typed a non-empty draft (`adb shell input text`) so the send button reaches
   its enabled state.
   Expected: enabled send button hidden behind the FAB.
   Actual: enabled send button (pink gradient, `arrow_upward` glyph) rendered
   clear of any overlay at the composer's trailing edge.
   (`recheck-chat-shell-enabled-send.png`)

3. Tapped the send button at its rendered centre
   (`adb -s HT7AH1A02116 shell input tap 985 875`).
   Expected (bug): the tap lands on the FAB, the send button cannot be reached.
   Actual: the send button received the tap — the draft was consumed and the
   composer returned to its hint state (`Đối phương thấy từng chữ…`) with the
   send button back in its disabled style.
   (`recheck-chat-shell-after-send-tap.png`)

Result: PASS

## Residual Notes For Reviewer

- `bug_master.md` cites `mobile/lib/core/navigation/app_shell.dart:199-206` as
  the FAB location. Those line numbers no longer point at a FAB on current HEAD;
  lines 189-201 are now the `Scaffold` with `body` and `bottomNavigationBar`
  only. This is expected given `3d74a75`, not a mis-filed anchor.
- The report's supplementary capture
  `implemented-chat-composer-draft-emulator-5560.png` was taken with
  `wrapInShell: false` and therefore never showed the FAB; the shelled
  `implemented-chat-emulator-5560.png` is the one that evidences the original
  defect.
- No `STORY-016` DEC-4 decision was reopened. DEC-4's 3-tab-plus-FAB chrome had
  already been superseded by STORY-061's shipped 5-tab shell before this bug was
  picked up.
