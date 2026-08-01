# Fix Evidence: BUG-20260801-007_reminder_copy_guard_synced_alarm_violation

Author: bug-fixer (Justin-BugFixer)
Date: 2026-08-01
Branch: `main`, control checkout
`/Users/alantravala/workspace/snapsofts/cupid-apps` (HEAD at fix time: `c71875f`)
Diagnosis: `data/bugs/BUG-20260801-007_reminder_copy_guard_synced_alarm_violation/diagnosis.md`

## 1. Change set (3 files, +6 / -6)

### `mobile/lib/l10n/arb/app_en.arb`

```
-  "notifs_row_synced_alarm_title": "Synced Alarm",
-  "notifs_row_synced_alarm_sub": "Rings on both phones",
+  "notifs_row_synced_alarm_title": "Synced Reminder",
+  "notifs_row_synced_alarm_sub": "Prompts on both phones",
```

### `mobile/lib/l10n/arb/app_vi.arb`

```
-  "notifs_row_synced_alarm_title": "Synced Alarm",
+  "notifs_row_synced_alarm_title": "Nhắc nhở đồng bộ",
   "@notifs_row_synced_alarm_title": {
-    "description": "CRITICAL row title, locale-invariant per design source."
+    "description": "CRITICAL row title. Wording fixed by ADR-002; the design source's \"Synced Alarm\" is superseded and this row is not locale-invariant."
   },
-  "notifs_row_synced_alarm_sub": "Reo trên cả hai máy",
+  "notifs_row_synced_alarm_sub": "Nhắc trên cả hai máy",
```

### `mobile/test/features/account/presentation/screens/notification_settings_screen_test.dart`

```
-      expect(find.text('Synced Alarm'), findsOneWidget);
+      expect(find.text('Synced Reminder'), findsOneWidget);
```

The replacement values are not newly invented copy: they are the already-approved
STORY-009 canonical values for this exact `ux/uiux-spec.md` §4 row, taken verbatim
from `mobile/lib/features/reminders/presentation/reminder_strings.dart:122-126`
(`reminderNotificationsRowTitle`, `reminderNotificationsRowSubtitle`).

Regeneration step: `flutter gen-l10n` (per `mobile/l10n.yaml`, `arb-dir:
lib/l10n/arb`, `output-dir: lib/l10n/generated`). The generated
`lib/l10n/generated/app_l10n_*.dart` files are gitignored, so they do not appear
in `git status`; verified in place afterwards:

- `lib/l10n/generated/app_l10n_en.dart:431` -> `'Synced Reminder'`
- `lib/l10n/generated/app_l10n_vi.dart:429` -> `'Nhắc nhở đồng bộ'`

### Deliberately unchanged

The forbidden-token list in `reminder_copy_guard_test.dart` was **not** touched;
ADR-002 was **not** amended. Internal (non-user-facing) alarm naming ADR-002
explicitly permits was left alone: ARB key ids `notifs_row_synced_alarm_*`, the
persisted `prefKey: 'syncedAlarm'` (renaming it would silently reset users'
stored toggle), `Icons.alarm`, and the generated OpenAPI client under
`mobile/openapi/`.

## 2. Target test — PASS

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter test test/features/reminders/reminder_copy_guard_test.dart
```

Before:

```
00:00 +0 -1: mobile/lib string literals never say "báo thức"/"Synced Alarm"/"Do Not Disturb" (AC2/AC3, ADR-002) [E]
  Expected: empty
    Actual: [
              'lib/l10n/generated/app_l10n_vi.dart:429: forbidden token "synced alarm"',
              'lib/l10n/generated/app_l10n_en.dart:431: forbidden token "synced alarm"'
            ]
```

After:

```
00:00 +2: All tests passed!
```

## 3. Full suite regression — PASS (890/890)

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter test
```

Result: `00:16 +890: All tests passed!` — matches the expected `+890 -0`
from the checkpoint. No test regressed; the only test touched
(`notification_settings_screen_test.dart` "renders 7 rows across the 3 groups")
passes with the corrected assertion.

## 4. Build Gate — PASS

Registry `runtimes.mobile-app.buildCommand` = `flutter build apk --debug`.

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter build apk --debug
```

Result:

```
Running Gradle task 'assembleDebug'...                              7.8s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

Only pre-existing noise emitted: the `sign_in_with_apple` Kotlin Gradle Plugin
deprecation warning, unrelated to this change.

## 5. Runtime Startup Gate — PASS

Registry `runtimes.mobile-app.readiness` is `type: widget-test`, not an HTTP
probe: the pump of `Key('home_screen_ready_signal')`
(`mobile/lib/features/home/presentation/home_screen.dart`) exercised via
`flutter test`. Observed green in the full-suite run above:

```
00:16 +881: .../mobile/test/widget_test.dart: App boots to the home screen ready signal
```

## 6. Residual risk

None identified. The change is two visible strings in one notification settings
row across both locales, plus the test assertion that pinned the old value. No
state, contract, persistence, navigation, or behavior change; no dependency
change.

BUG_FIX_COMPLETE: YES
