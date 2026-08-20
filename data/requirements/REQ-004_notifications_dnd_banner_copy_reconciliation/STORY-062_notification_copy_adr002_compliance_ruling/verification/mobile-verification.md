# STORY-062 Mobile Verification

Role: mobile-dev (Alex-Mobile-Dev)
Date: 2026-08-20
Branch: `codex/REQ-004_notifications_dnd_banner_copy_reconciliation-STORY-062_notification_copy_adr002_compliance_ruling`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-004_notifications_dnd_banner_copy_reconciliation-STORY-062_notification_copy_adr002_compliance_ruling`
BaseHead: `9742fe8c14fc4059c3c5c827e1d2b6ff09fbdd56`

## Code change (the only one in scope)

`mobile/test/features/reminders/reminder_copy_guard_test.dart` — added
`'không làm phiền'` to `_forbiddenTokens`, and extended the test description to
name the new token. No other file changed.

```diff
 const List<String> _forbiddenTokens = [
   'báo thức',
   'synced alarm',
   'do not disturb',
+  // Vietnamese rendering of "Do Not Disturb": the English-only ban let a
+  // translated form of the same unhonourable capability claim through
+  // (REQ-002 review finding E-2, STORY-062 AC1).
+  'không làm phiền',
 ];
```

```diff
-    'mobile/lib string literals never say '
-    '"báo thức"/"Synced Alarm"/"Do Not Disturb" (AC2/AC3, ADR-002)',
+    'mobile/lib string literals never say '
+    '"báo thức"/"Synced Alarm"/"Do Not Disturb"/"không làm phiền" '
+    '(AC2/AC3, ADR-002)',
```

No production copy was modified: `notification_settings_screen.dart` and
`permissions_screen.dart` are untouched on this branch.

## Environment note

`flutter` is not on the default session `PATH`; the SDK at
`/Users/alantravala/flutter/bin` was prepended for every command below. The
worktree is fresh, so `lib/l10n/generated/` (gitignored build output, see
`mobile/.gitignore:41`) did not exist and had to be produced with
`flutter gen-l10n` before widget tests could compile. That is a build-artifact
step, not a source change — nothing under `lib/l10n/generated/` is tracked or
committed.

## Commands run and results

### 1. Guard test — AC1

```
cd mobile && flutter test test/features/reminders/reminder_copy_guard_test.dart
```

```
00:00 +0: mobile/lib string literals never say "báo thức"/"Synced Alarm"/"Do Not Disturb"/"không làm phiền" (AC2/AC3, ADR-002)
00:00 +1: pubspec.yaml declares no native-alarm/local-notification dependency (AC4)
00:00 +2: All tests passed!
```

PASS (2/2). The hardened token list is green against the current `lib/` tree,
confirming no shipped Dart string literal contains the Vietnamese DND phrase.

Pre-edit scan corroborating that result:
`git grep -in -e "làm phiền" -- mobile/lib mobile/l10n` returned zero matches,
so adding the token could not have been satisfied by a copy change — the guard
was already clean and is now mechanically stricter.

Negative-proof note for Reviewer: the new token is consumed by the exact same
`lowered.contains(token)` loop that already fails the build on
`'do not disturb'` and `'synced alarm'`. No injected-offense run was performed,
because forcing a failure would require writing a violating literal into
`mobile/lib/**`, which is outside this story's declared `WriteScope`. The
failure path is shared code, not new code.

### 2. Regression — AC2 + AC3

```
cd mobile && flutter test \
  test/features/account/presentation/screens/notification_settings_screen_test.dart \
  test/features/onboarding/permissions_screen_test.dart \
  test/features/reminders/reminder_copy_guard_test.dart
```

```
00:00 +12: All tests passed!
```

PASS (12/12), all three files unmodified except the guard's token list.

- **AC2** — `notification_settings_screen_test.dart` (actual path
  `mobile/test/features/account/presentation/screens/notification_settings_screen_test.dart`,
  not `test/features/notifications/`) passes unmodified:
  "NotificationSettingsScreen renders 7 rows across the 3 groups". The
  `notifs_cap_banner` numeric-cap-only sentence still ships in both locales; no
  DND clause reintroduced.
- **AC3** — `mobile/test/features/onboarding/permissions_screen_test.dart`
  passes unmodified, all 6 cases including "renders the design source copy for
  the vi locale" and "en locale renders the design source English copy". The
  `Nhắc nhở đồng bộ` / `Synced Reminder` phrasing is intact; no "Synced Alarm"
  label in either language.

### 3. Static analysis

```
cd mobile && flutter analyze test/features/reminders/reminder_copy_guard_test.dart
```

```
Analyzing reminder_copy_guard_test.dart...
No issues found! (ran in 1.0s)
```

PASS.

## AC status

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 guard hardened with "không làm phiền" | PASS | Command 1, diff above |
| AC2 `notifs` banner copy unchanged | PASS | Command 2, no diff to `notification_settings_screen.dart` |
| AC3 `permissions` row copy unchanged | PASS | Command 2, no diff to `permissions_screen.dart` |
| AC4 ruling citation trail | N/A to mobile lane | Recorded in `requirements/requirements.md` AC4 by Product Owner |

MOBILE_COMPLETE
