# Diagnosis: BUG-20260817-001 Chat FAB Occludes Send Button

Bug: `BUG-20260817-001_chat_fab_occludes_send_button`
Role: bug-fixer (Justin-BugFixer)
Date: 2026-08-23
Bug master: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/bug_master.md`
Fix evidence: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/fix-evidence.md`

## Pre-Fix Reproduction Gate

Attempted before reading any owner source file or patching.

Modality: rendered on-device capture of the shell-wrapped `chat` screen — the
same modality as the original report.

Environment used:
- Device: `HT7AH1A02116` (Pixel 2, Android, already attached to `adb`)
- Axis: dark theme, `vi` locale, Material platform — same axis the report names
  (the report's own `emulator-5560` was not running; the attached device
  reproduces the same shell/composer render axis)
- Route opened via the app's own preview harness, `mobile/lib/main_preview.dart`,
  whose `chat` entry is registered with `wrapInShell: true`, i.e. `AppShell` and
  `ChatScreen` in one render tree — exactly the combination the report says no
  existing test covers.

Steps actually run:
1. `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=chat --dart-define=PREVIEW_CHAT_GHOST=on --dart-define=PREVIEW_BRIGHTNESS=dark --dart-define=PREVIEW_PLATFORM=material`
2. `adb -s HT7AH1A02116 install -r -d build/app/outputs/flutter-apk/app-debug.apk`
3. `adb -s HT7AH1A02116 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
4. `adb -s HT7AH1A02116 exec-out screencap -p` on the rendered `chat` tab.

Expected (per bug report): the account-hub `FloatingActionButton` sits at the
default `endFloat` location and covers the composer's send button 100%.

Actual on current `main` (`a11959d`): **NOT REPRODUCIBLE.** The render shows the
design's 5-tab bar (`Nhà / Trò chuyện / Pet / Ví chung / Tôi`), **no
`FloatingActionButton` anywhere**, and the composer's send button fully visible
and unobstructed at the bottom-right of the composer row.

Result: NOT_REPRODUCIBLE_ON_HEAD — the reported defect is already absent from
the current source. Capture:
`data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/evidence/recheck-chat-shell-empty-draft.png`

Historical pre-fix render confirming the bug was real when filed:
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-040_chat_typing_ghost_design_fidelity_hardening/visual-fidelity/implemented-chat-emulator-5560.png`
— that capture does show the 3-tab bar plus a pink circular person-icon FAB
occupying the send button's slot, matching the report's measurements exactly.

## Root Cause

The occluding widget no longer exists.

At intake time `mobile/lib/core/navigation/app_shell.dart` built its `Scaffold`
with `floatingActionButton: FloatingActionButton(heroTag: 'account-hub-entry',
...)` and no `floatingActionButtonLocation` override, so Material's default
`endFloat` pinned it to the bottom-right of every tab body — including the chat
tab, where the composer's send button occupies that same corner. Because the
`Scaffold`'s FAB paints above `body`, the send button was both hidden and
excluded from the hit-test path.

That FAB was deleted in commit `3d74a75`
(`feat(REQ-002_screen_flow_and_design_fidelity_audit/STORY-061_dream_jar_list_design_fidelity_hardening)`,
2026-08-20), which replaced STORY-016 DEC-4's provisional "3-tab shell plus
account-hub FAB" chrome with the design's five destinations and moved the
account hub (`MeScreen`) into the `Tôi` tab. The bug was filed 2026-08-17, three
days before that commit landed, so it was fixed incidentally by a later story
rather than by this bug entry.

Current state of the anchor: `mobile/lib/core/navigation/app_shell.dart` contains
no `FloatingActionButton`, no `floatingActionButton:` argument and no
`floatingActionButtonLocation` at all. `mobile/lib/features/chat/presentation/widgets/chat_composer.dart`
is unchanged and correct — its `_SendButton` was never the defect.

This does not re-litigate STORY-016 DEC-4: DEC-4 was already superseded by
STORY-061's shipped 5-tab shell before this bug was picked up. No shell/IA
decision is taken here.

## Fix Scope

No production source change is required or made — patching `app_shell.dart`
would mean re-adding and re-removing a widget that is already gone.

What *is* missing is the regression guard. The bug report's own failure-anchor
section records that no test pumps `AppShell` and `ChatScreen` in one tree, and
the guard STORY-061 did add
(`test/core/navigation/app_shell_test.dart`, "no account FAB remains on any
shell destination") only asserts `find.byType(FloatingActionButton), findsNothing`.
That rules out one *shape* of occluder, not the property the bug is about: any
future bottom-right shell chrome that is not a `FloatingActionButton` (a
`Positioned` overlay, a `Stack` child, a bottom sheet, a banner) would re-break
the send button and still pass every existing test.

Fix applied: one regression test in the shell suite that pumps the shell-wrapped
chat tab, enters a non-empty draft so the send button reaches its enabled state,
and asserts a pointer at the send button's centre actually reaches the send
button's `RenderBox` in the hit-test path.

Files touched: 1
- `mobile/test/core/navigation/app_shell_test.dart` (regression test + two imports)

## Risk Surfaces

- Navigation/shell chrome (`AppShell`): **read only**, not modified. `git diff`
  on `mobile/lib/core/navigation/app_shell.dart` is empty.
- Chat composer: not modified.
- Test-only change; no runtime behaviour, no API, no schema, no dependency, no
  configuration change. No product scope added.
