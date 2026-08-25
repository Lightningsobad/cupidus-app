# Test Results — STORY-005 Home Header Notifications Entry Point

Lane: mobile
Story-Class: trivial (single-lane, no shared coding plan required)
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-005`
Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-005`

## Changed Files

- `mobile/lib/features/home/presentation/home_screen.dart` — header row becomes
  `space-between` and gains `_NotificationsAction` (glyph, tap target, unread
  dot, push to the existing Notifications screen).
- `mobile/lib/features/account/data/notification_preferences_store.dart` —
  adds `hasStoredPreferences()`, the AC3 "unconfigured" signal. `load()`'s
  silent defaults fallback cannot distinguish "reviewed and kept the defaults"
  from "never opened the screen"; this reads the already-persisted device-local
  key rather than inventing any new tracking system.
- `mobile/test/features/home/presentation/home_header_notifications_test.dart`
  — new widget tests covering all three ACs.

## Static Analysis

Command:

```
flutter analyze lib/features/home/presentation/home_screen.dart \
  lib/features/account/data/notification_preferences_store.dart \
  test/features/home/presentation/home_header_notifications_test.dart
```

Output: `No issues found! (ran in 2.5s)`

Result: PASS

## Automated Tests

Command:

```
flutter test test/features/home test/features/account --reporter=failures-only
```

Output: `+110: All tests passed!`

Result: PASS

New cases in `home_header_notifications_test.dart` (5), rendered in the enabled
dark theme with `locale: Locale('vi')` so they exercise the AC1 combination:

1. AC1 — the header renders the notifications action.
2. AC3 — no indicator dot when a preference choice has already been persisted.
3. AC3 — the indicator dot renders while the user is unconfigured.
4. AC2 — tapping the action lands on the existing
   `NotificationSettingsScreen`; no new screen is introduced.
5. The dot clears after visiting the Notifications screen and saving a value,
   proving the entry point re-resolves its state on return.

A production defect was found and fixed by case 5 before this run:
`setState(() => _unconfigured = widget.resolveUnconfigured())` returned a
`Future` from the `setState` callback and threw at runtime. The assignment is
now hoisted out of the callback.

## Build

Command:

```
flutter build apk --debug --flavor local --target=lib/main_preview.dart \
  --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true
```

Output: `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk`

Result: PASS

## Visual Fidelity

- Screen captured: `home` (`Design-Screen: home`)
- Device: `emulator-5554` (Android)
- Implemented screenshot:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-005_home_header_notifications_entry_point/visual-fidelity/implemented-home-android.png`
- Design reference:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-005_home_header_notifications_entry_point/visual-fidelity/design-reference-home-android.png`
- VISUAL_FIDELITY: PASS
- Report:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-005_home_header_notifications_entry_point/visual-fidelity/visual-fidelity-report.md`

State was faked from the preview entrypoint (`PREVIEW=home`,
`PREVIEW_HOME_FIXTURE=true`), not driven through the live app.

## Runtime Startup Smoke

The debug APK was installed and launched on `emulator-5554` inside the capture's
device-lease window. The Home screen reached its loaded state and rendered the
new header action; `adb logcat -d -s flutter:* FlutterError:* AndroidRuntime:E`
showed no Flutter framework errors. The only logged failure is a pre-existing
`DioException [connection error]` for `GET /users/me`, caused by the emulator
having no backend reachable, and is unrelated to this story.

Result: PASS

## Entry Point Reachability

The new action lives in the Home dashboard header, which is the default tab of
the app shell — reachable by every signed-in user without a deep link. Its
destination, `NotificationSettingsScreen`, was already shipped by REQ-002
STORY-031; this story adds a second route to it and builds no new screen.
