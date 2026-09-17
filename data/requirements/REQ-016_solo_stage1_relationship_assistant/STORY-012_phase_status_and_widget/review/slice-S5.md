# Review Slice S5: phase-P6 evening check-in + cross-requirement guard narrowing

Phase: SCOPED_SLICE
REVIEW_SLICE_COMPLETE: YES
Slice: S5
Story: STORY-012_phase_status_and_widget
Requirement: REQ-016_solo_stage1_relationship_assistant
Mode: scoped-slice
Diff baseline: `b58afbe073eff4e1ebb9151735221532a9cf5a82`
File budget used: 10 of 10 (`full-story-review` budget per `review/scope-gate.md`
S5 bullet), plus `story_master.md` (7.4 KB) and `review/scope-gate.md` as
governing inputs.

## Files Reviewed (all relative to the story worktree root)

- `mobile/lib/features/phase_status/data/local_notification_scheduler.dart`
- `mobile/lib/features/phase_status/domain/evening_check_in_scheduler.dart`
- `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart`
- `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart`
- `mobile/pubspec.yaml`
- `mobile/pubspec.lock`
- `mobile/test/features/phase_status/evening_check_in_scheduler_test.dart`
- `mobile/test/features/phase_status/evening_check_in_sheet_test.dart`
- `mobile/test/features/account/presentation/screens/notification_settings_screen_test.dart`
- `mobile/test/features/reminders/reminder_copy_guard_test.dart`

Not read: any file belonging to slices S1-S4, S6a, S6b (including
`phase_status_cubit.dart`, which is S2). See O-1 below for the one question that
lands on the other side of that boundary.

## AC-4 Verdict

`AC-4` (SB-85: "Given hôm nay là ngày hẹn của một thẻ, when tới khoảng 23h,
then app gửi một nhắc nhẹ 'về tới nhà chưa?' dẫn tới cất ảnh / viết một câu vào
nhật ký, và nếu bỏ qua thì không nhắc lại"): **PASS**, with two scope-boundary
observations recorded below that do not by themselves fail the criterion.

Clause-by-clause evidence:

1. *"khi tới khoảng 23h"* — PASS.
   `evening_check_in_scheduler.dart:8` `const int eveningCheckInHour = 23`;
   `_eveningOf` (`:116-119`) builds a local `DateTime(y, m, d, 23)` from the
   card's `scheduledOn`. Asserted by
   `evening_check_in_scheduler_test.dart:170-177` ("lands in the evening of the
   card date, in local time"), which pins both the hour constant and
   `at.isUtc == false`.
2. *"ngày hẹn của một thẻ"* — PASS. `_sync` (`:66-80`) returns early for every
   phase other than `SoloPhase.dateDay` and for a resolution missing `cardId`
   or `scheduledOn`. Asserted by the "phases that must stay silent" group
   (`:202-235`).
3. *"nhắc nhẹ"*, not an alarm — PASS.
   `local_notification_scheduler.dart:19-20` pins
   `AndroidScheduleMode.inexactAllowWhileIdle`, and `_gentleDetails`
   (`:203-218`) sets `playSound: false`, `enableVibration: false`,
   `channelShowBadge: false`, `presentBadge: false`, `presentSound: false`.
   The source-scan group (`evening_check_in_scheduler_test.dart:338-365`)
   additionally proves no `exactAllowWhileIdle`/`AndroidScheduleMode.exact` is
   reachable and that the manifest declares neither `SCHEDULE_EXACT_ALARM` nor
   `USE_EXACT_ALARM`. This matches story In Scope item 8 ("nhắc nhẹ (D-1) — đủ
   mạnh để thấy, không phải báo thức thật").
4. *"dẫn tới cất ảnh / viết một câu vào nhật ký"* — PASS. The queued
   notification carries the card id as its payload
   (`evening_check_in_scheduler.dart:92-98`); the tap path
   (`evening_check_in_sheet.dart:257-284`) resolves it back to the
   `evening_check_in` nudge item and opens `EveningCheckInSheet`, whose save
   hands the sentence and photo paths to `openJournalComposer` with an opaque
   `originRef` (`:291-305`). Both the attach step and the sentence step are
   optional and independent (`evening_check_in_sheet_test.dart:195-206`,
   `:239-291`). Cold-launch taps are drained via
   `getNotificationAppLaunchDetails` (`local_notification_scheduler.dart:82-86`),
   so a tap that starts the app from dead does not lose its destination.
5. *"nếu bỏ qua thì không nhắc lại"* — PASS, and stronger than the wording
   requires. `_sync` writes `prefs.markReminded(cardId, scheduledOn)`
   (`:100`) on the success branch **and** on the permission-refused branch, and
   any card with a `remindedOn` value is refused at `:78-80`. There is no
   escalation, no second attempt and no catch-up. Covered by the
   `REMIND-REPEAT` group (`evening_check_in_scheduler_test.dart:116-156`: five
   opens queue one; a fresh scheduler over the same store queues nothing; a
   different card is a distinct id) and by `permission refused (AC-31)`
   (`:251-269`). Skipping the sheet itself writes nothing and re-queues nothing
   (`evening_check_in_sheet_test.dart:294-303`).

Related criteria touched in passing, both consistent: `AC-7` (a user who turns
the reminder off gets nothing queued and the pending one cancelled —
`evening_check_in_scheduler.dart:107-112`, verified by
`notification_settings_screen_test.dart:222-236`) and `AC-8` (the sheet carries
no badge, rating, score or "still owed" marker —
`evening_check_in_sheet_test.dart:305-319`).

## Dependency Scope Check

`git diff b58afbe0 -- mobile/pubspec.yaml mobile/pubspec.lock` adds exactly
three direct dependencies and no others:

- `flutter_local_notifications: ^22.3.1` — the plugin named in the handoff, and
  the only notification plugin added. CONFIRMED.
- `timezone: ^0.11.1` — required companion: `zonedSchedule` takes a
  `tz.TZDateTime` (`local_notification_scheduler.dart:148-159`, which uses
  `tz.UTC` rather than pulling in a second device-timezone plugin). In scope.
- `home_widget: ^0.9.4` — belongs to the P4/P5 widget phases (slices S3/S4),
  not to P6. In scope for the story, out of scope for this slice; flagged to
  S7 only so the final synthesis knows it was already accounted for here.

Transitive additions (`dbus`, `petitparser`, `xml`, and the four
`flutter_local_notifications_*` platform packages) are all pulled in by
`flutter_local_notifications` itself. No reminder-adjacent package crept in:
`android_alarm_manager`, `alarm` and `awesome_notifications` remain absent and
remain banned by `reminder_copy_guard_test.dart:82-100`.

## Cross-Requirement Guard (`_remindersForbiddenImport`)

The narrowing at `reminder_copy_guard_test.dart:34-40` /`:102-134` is the one
the 2026-09-17 user decision authorised, and it is recorded in the file itself
with the decision date and a pointer to `phase-P6-evening-check-in.md` §8. The
policy decision itself was not re-opened, per the handoff.

- `_remindersForbiddenImport = 'flutter_local_notifications'` and the boundary
  test walks `Directory('lib/features/reminders')` recursively, failing on any
  `import`/`export` line naming that plugin (`:102-134`).
- Still substantive after the narrowing: `find mobile/lib/features/reminders
  -name "*.dart"` returns 17 Dart files across 5 directories, so the
  `listSync` walk has real input and a violation would be caught. (Confirmed
  only that the prior full-story review's non-vacuity finding still holds; not
  re-derived.)
- The guard's other two tests are unchanged and still pass: the string-literal
  ban (`báo thức` / `synced alarm` / `do not disturb` / `không làm phiền`) and
  the three-package pubspec ban.
- PASS: the guard still passes with the narrowed scope.

## Test Evidence

Command run from the story worktree's `mobile/` directory, Flutter 3.44.1 /
Dart 3.12.1:

```
flutter test test/features/phase_status/evening_check_in_scheduler_test.dart \
  test/features/phase_status/evening_check_in_sheet_test.dart \
  test/features/account/presentation/screens/notification_settings_screen_test.dart \
  test/features/reminders/reminder_copy_guard_test.dart
```

Result: `+46 ~1: All tests passed!`. The one skipped test is
`capture: evening-check-in sheet`, gated behind
`--dart-define=CAPTURE_VISUALS=true` by design
(`evening_check_in_sheet_test.dart:332-338`).

The guard file was additionally re-run alone with `--reporter expanded` to name
its three tests explicitly; all three passed.

`git status --porcelain` in the worktree is clean after both runs: the test runs
dirtied no tracked file, and `pubspec.lock` was not rewritten by `pub get`.

## Observations (non-blocking, for the S7 final synthesis)

- **O-1 (boundary, needs S2/S7 to close)**: `sync` only ever queues from a
  resolution already at `SoloPhase.dateDay`, so the 23h nudge exists only if
  the app is opened at some point during the date day itself. `AC-4`'s "Given
  hôm nay là ngày hẹn của một thẻ" does not state an app-open precondition. The
  caller (`phase_status_cubit.dart`) is slice S2, so this slice cannot confirm
  whether an earlier-phase pass ever pre-schedules. Severity: low-to-medium;
  the final synthesis should reconcile S2's call sites with this clause before
  calling AC-4 closed story-wide.
- **O-2 (minor)**: a first app open after 23:00 on the date day makes
  `_eveningOf` produce a past instant, which `zonedSchedule` will not deliver,
  while `markReminded` is still written — so that card silently gets no nudge
  at all rather than a late one. This is the quiet-degradation direction BR-14
  prefers over nagging, so it is recorded rather than raised.
- **O-3 (latent)**: `EveningCheckInScheduler.setEnabled(false)` calls
  `notifications.cancelAll()` (`:107-112`), which drops every pending local
  notification the app has, not only this feature's. `cancel(int id)` exists on
  the port and is unused. Harmless today — this is the app's only
  local-notification producer — but it becomes a cross-feature bug the moment a
  second one is added.
- **O-4 (cosmetic)**: the guard test named "pubspec.yaml declares no
  native-alarm/local-notification dependency (AC4)"
  (`reminder_copy_guard_test.dart:82-84`) no longer describes its own body
  after the narrowing: `flutter_local_notifications` *is* now declared in
  `pubspec.yaml`, and the test checks only the three still-banned packages. The
  name should say "no native-alarm dependency". Doc-level only; the assertions
  are correct.

## Slice Result

- AC-4: PASS
- Dependency scope (no creep beyond `flutter_local_notifications` + its
  required `timezone` companion): PASS
- Narrowed cross-requirement guard still passes and still substantive: PASS
- Nothing UNVERIFIED inside this slice's 10 files. The one open question (O-1)
  is a cross-slice reconciliation for S7, not a gap in the files reviewed here.
