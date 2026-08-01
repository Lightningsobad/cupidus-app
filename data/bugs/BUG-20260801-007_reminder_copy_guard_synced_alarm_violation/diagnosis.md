# Diagnosis: BUG-20260801-007_reminder_copy_guard_synced_alarm_violation

Author: bug-fixer (Justin-BugFixer)
Date: 2026-08-01
Branch/worktree: `main` @ `c71875f`, control checkout
`/Users/alantravala/workspace/snapsofts/cupid-apps`

## 1. Reproduction (confirmed)

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter test test/features/reminders/reminder_copy_guard_test.dart
```

Observed failure (test 1 of 2 in the file; test 2 passes):

```
Expected: empty
  Actual: [
            'lib/l10n/generated/app_l10n_vi.dart:429: forbidden token "synced alarm"',
            'lib/l10n/generated/app_l10n_en.dart:431: forbidden token "synced alarm"'
          ]
```

## 2. What the guard actually enforces

`mobile/test/features/reminders/reminder_copy_guard_test.dart` walks every
`*.dart` file under `mobile/lib` (recursively, generated output included),
extracts the *contents* of Dart string literals on non-comment lines, and
fails if any literal contains `báo thức`, `synced alarm`, or
`do not disturb` (case-insensitive). It deliberately does not scan
`mobile/openapi/`, which carries the frozen backend tag `Epic 3 - Synced
Alarms`.

## 3. Governing decision (ADR-002)

`data/architecture/system/system_architecture_memory.md` §7:

> **ADR-002 (D1)** No system-level alarms and no Critical Alerts entitlement.
> v1 ships strong notifications only; epic-3 wording is "nhắc nhở đồng bộ".
> The backend `alarms` module and its gateway are still the transport — the
> naming mismatch is backend-internal and must not leak into UI copy.

So the ban is a copy-consistency rule, not a policy that is stale. Internal
identifiers (backend `alarms` module, the generated OpenAPI client, ARB key
names, the `syncedAlarm` SharedPreferences key, `Icons.alarm`) are explicitly
allowed to keep alarm naming; only **user-facing copy** must not.

The approved terminology is already materialized in the repository's canonical
copy source, `mobile/lib/features/reminders/presentation/reminder_strings.dart`.
Its doc comment states every string uses `"nhắc nhở đồng bộ"` / `"synced
reminder"` and never `"báo thức"`, `"Synced Alarm"`, or `"reo"/"ring"` bell
language. Critically, that file **already contains this exact notification
settings row** (`ux/uiux-spec.md` §4), transcribed ahead of time for "the
future notifications story":

- `reminderNotificationsRowTitle` -> vi `Nhắc nhở đồng bộ`, en `Synced Reminder`
- `reminderNotificationsRowSubtitle` -> vi `Nhắc trên cả hai máy`,
  en `Prompts on both phones`

## 4. Root cause

STORY-016 built `NotificationSettingsScreen`
(`mobile/lib/features/account/presentation/screens/notification_settings_screen.dart:106-112`)
and re-authored the CRITICAL row's copy directly into the ARB pipeline instead
of adopting the canonical §4 values that STORY-009 had already approved. It
transcribed the wording verbatim from the stale HTML design source
(`cupid-mobile-design/Cupid Screens.dc.html`) — the ARB metadata literally says
`"locale-invariant per design source"` — which predates ADR-002's renaming.

Two ARB entries carry the violation, in `mobile/lib/l10n/arb/` (not
`mobile/lib/l10n/` as recorded in `bug_master.md` §Failure anchor; `l10n.yaml`
sets `arb-dir: lib/l10n/arb`, `template-arb-file: app_vi.arb`):

- `app_en.arb:127` `"notifs_row_synced_alarm_title": "Synced Alarm"`
- `app_vi.arb:565` `"notifs_row_synced_alarm_title": "Synced Alarm"` — the
  Vietnamese template also held the untranslated English phrase, so the
  Vietnamese build shipped banned English copy as well.

`flutter gen-l10n` emits those values as Dart string literals into
`lib/l10n/generated/app_l10n_en.dart:431` and `app_l10n_vi.dart:429`, which is
what the guard scans. The generated files are the symptom; the ARB files are
the cause.

Additionally the same row's subtitle uses the bell language the canonical
source bans (`Rings on both phones` / `Reo trên cả hai máy`). The token list
does not catch it, but it is the same ADR-002 AC2 violation on the same two
lines, so it is corrected together rather than left to trip a future guard
tightening.

## 5. Decision: fix the copy, not the guard

Direction 1 from `bug_master.md` is correct; direction 2 does not apply. ADR-002
is current and is corroborated by an in-repo canonical copy source that already
holds the approved wording for this precise row. No guard loosening, no ADR
change, no escalation needed.

Chosen fix (smallest safe patch):

1. `mobile/lib/l10n/arb/app_en.arb` — title -> `Synced Reminder`,
   sub -> `Prompts on both phones`.
2. `mobile/lib/l10n/arb/app_vi.arb` — title -> `Nhắc nhở đồng bộ`,
   sub -> `Nhắc trên cả hai máy`; drop the now-false "locale-invariant per
   design source" note on the title, since the row is no longer locale-invariant.
3. Regenerate l10n so `app_l10n_en.dart` / `app_l10n_vi.dart` carry the new
   literals.
4. `mobile/test/features/account/presentation/screens/notification_settings_screen_test.dart:36`
   asserts `find.text('Synced Alarm')`; update it to the approved title. That
   assertion encodes the violating copy, so it must move with the fix.

Explicitly **not** changed (internal naming ADR-002 permits):

- ARB key id `notifs_row_synced_alarm_title` / `_sub`
- `prefKey: 'syncedAlarm'` — a persisted SharedPreferences key; renaming it
  would silently reset users' stored toggle
- `Icons.alarm`
- the generated OpenAPI client under `mobile/openapi/`
- the forbidden-token list in `reminder_copy_guard_test.dart`

## 6. Blast radius

One notification settings row's visible title/subtitle in both locales. No
state, contract, persistence, or behavior change.
