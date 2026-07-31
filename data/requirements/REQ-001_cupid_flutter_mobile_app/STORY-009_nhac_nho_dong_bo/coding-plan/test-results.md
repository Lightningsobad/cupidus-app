# STORY-009 Nhắc Nhở Đồng Bộ — P5 Verification Test Results

- Phase: P5 (Verification)
- Owner: Mobile Developer
- Date: 2026-07-31
- BaseHead / worktree HEAD: `f5cb2c03d56f0ad86be0146aa8093a36cac6e52c` (clean tree)

## 1. Plan-Integrity Checks

- `master-plan.md` §5 Phases Overview table uses the required schema (Phase |
  Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs |
  Planned Outputs | Test Scope | Status). PASS.
- Every phase id (P0–P5) maps to exactly one canonical `phase-Px-*.md` file on
  disk, no duplicates: `phase-P0-reminder-contract-and-data.md`,
  `phase-P1-reminder-schedule-state.md`, `phase-P2-reminder-schedule-screen.md`,
  `phase-P3-reminder-firing-overlay.md`,
  `phase-P4-entry-point-and-copy-guard.md`, `phase-P5-verification.md`. PASS.

## 2. Build/Analyze/Test Commands

| Command | Result |
|---|---|
| `flutter analyze` | PASS — 0 errors on tracked source. All reported errors are pre-existing noise from the untracked, gitignored `mobile/build/ios/SourcePackages/checkouts/flutterfire` artifact (confirmed via `git check-ignore -v`, `git ls-files mobile/build` empty). Outside that path: only pre-existing info/warning-level lints, no regressions. |
| `flutter test` (whole `mobile` package) | PASS — 184/184 tests passed, 0 failed. Verified with default concurrency and re-confirmed with `--concurrency=1` (identical 184/184 total, every one of the 9 `test/features/reminders/*.dart` files visibly executed in the log) to rule out a compact-reporter display artifact. Covers auth, realtime, home readiness, and reminders regressions together. |
| `flutter build apk --debug` (registry build command) | PASS — `✓ Built build/app/outputs/flutter-apk/app-debug.apk`. Only a non-blocking pre-existing `sign_in_with_apple` KGP plugin warning, unrelated to this story. |

## 3. Acceptance Criteria Evidence

### AC1 — realtime write reaches the partner-facing state; overlay opens for the receiving viewer

- `reminder_repository_test.dart`: `outbound emit setTime emits setAlarm with an
  ISO-8601 time and backend userId`, `outbound emit confirm emits confirmAlarm
  with alarmId and backend userId`, `outbound emit dismiss emits stopAlarm with
  alarmId and backend userId`, `.events filters the merged stream to the five
  inbound wire events`. PASS.
- `reminder_schedule_bloc_test.dart`: `realtime refresh (§4 D5) an inbound wire
  event re-hydrates from GET /alarms`. PASS.
- `reminder_firing_cubit_test.dart`: `open (D5) opens on triggerAlarm and
  re-derives partner-dismissed from GET /alarms stopperIds`. PASS — this is the
  direct evidence that an inbound `triggerAlarm` reaches the partner-facing
  state and opens the cubit.
- `reminder_firing_overlay_test.dart`: `ReminderOverlayHost mounts the overlay
  above the child once the cubit is open`. PASS — this is the direct evidence
  that the overlay opens for the receiving viewer once the cubit is open.
- Together these confirm both the `setAlarm` emit path (repository -> socket)
  and the inbound `triggerAlarm` -> cubit-open -> overlay-mount path required
  by AC1. All named tests pass.

### AC2 — no forbidden alarm/DND copy in user-facing strings

- `reminder_copy_guard_test.dart`: `mobile/lib string literals never say "báo
  thức"/"Synced Alarm"/"Do Not Disturb" (AC2/AC3, ADR-002)`. PASS.
- Negative-injection check from P4 was performed (not re-run in P5, already
  recorded in `phase-P4-entry-point-and-copy-guard.md` §7 Status/Evidence):
  `"Synced Alarm"` was temporarily injected into `home_screen.dart`'s AppBar
  title, the guard test failed and reported the exact offending file/line/
  token, then the injection was reverted. This proves the guard is a real gate,
  not a vacuously-passing test.

### AC3 — no Do-Not-Disturb claim; Notifications settings screen intentionally not built

- Guard test (above) statically scans `mobile/lib/**` string literals for
  `do not disturb` (case-insensitive) and passes.
- Direct source check: `grep -ril "do.not.disturb\|dnd\b" mobile/lib` matches
  only `reminder_strings.dart`, and the only occurrence is a doc-comment
  (`/// DND-override clause deleted outright, not softened (§4 resolution).`)
  documenting that the DND-override wording was removed — not a live
  user-facing claim. No DND claim exists in any string literal.
- No Notifications settings screen exists under `mobile/lib`
  (`find lib -iname "*notification*setting*"` → no matches). This is
  intentional for this story: `reminder_strings.dart` documents
  (`reminderNotificationsRowTitle`/`reminderNotificationsRowSubtitle`/
  `reminderNotificationsBanner`) that this row's copy is transcribed for a
  future notifications story to reuse, per `architecture/solution.md` §3 Out
  Of Scope / D9, and `phase-P4` §3 explicitly directs "Do not create a
  Notifications settings screen."

### AC4 — no native-alarm/local-notification dependency, no platform channel

- `mobile/pubspec.yaml` dependency list inspected directly: `flutter`,
  `flutter_localizations`, `intl`, `cupertino_icons`, `dio`, `cupid_api`
  (path dep), `firebase_core`, `firebase_auth`, `get_it`, `google_sign_in`,
  `sign_in_with_apple`, `flutter_facebook_auth`, `flutter_bloc`,
  `socket_io_client`, `firebase_messaging`, `shared_preferences`. None of
  `android_alarm_manager`, `flutter_local_notifications`, `alarm`,
  `awesome_notifications` are present. PASS.
- `reminder_copy_guard_test.dart`: `pubspec.yaml declares no native-alarm/
  local-notification dependency (AC4)`. PASS.
- No platform channel (`MethodChannel`/`EventChannel`) was added anywhere in
  `lib/features/reminders/**`; the feature is REST hydration (`dio.get`) plus
  socket transport (`RealtimeCoordinator`) only, matching D1/D2 in
  `architecture/solution.md` §4.

## 4. Risk-Surface Gates (`architecture/solution.md` §4)

| Risk Surface | Gate | Result |
|---|---|---|
| Realtime reminder events | unit tests over a fake `RealtimeCoordinator` for all 5 inbound + 3 outbound events | PASS — `reminder_repository_test.dart` (3 outbound emits + inbound events filter), `reminder_firing_cubit_test.dart` (`triggerAlarm`, `alarmStoppedByPartner`-derived stopperIds refresh, `alarmFullyStopped`, ignores unrelated `newAlarmRequest`/`alarmScheduled`), `reminder_schedule_bloc_test.dart` (inbound event re-hydration) |
| Copy compliance (AC2/AC3) | `reminder_copy_guard_test.dart` static scan | PASS |
| Native-alarm non-goal (AC4) | dependency assertion inside the same guard test | PASS |
| Client-side 5-minute timeout | cubit test with an injected clock/timer seam, asserting no outbound emit | PASS — `reminder_firing_cubit_test.dart`: `D4 client-side timeout ... timeout expiry clears the overlay with zero outbound emits and sets the pending notice` |
| Overlay mount + a11y | widget test: announcement on open, non-gesture dismiss button, safe-area padding | PASS — `reminder_firing_overlay_test.dart` accessibility group (alert-level announcement + focus, non-gesture dismiss button, swipe-equivalent) and rendering group (safe-area insets) |
| Entry-point discoverability | widget test: tap from home reaches the schedule screen; `Key('home_screen_ready_signal')` still pumps | PASS — `reminder_entry_point_test.dart`: `home affordance navigates from AppShell to ReminderScheduleScreen (P4 AC)`; readiness key confirmed unchanged in `phase-P4` evidence and re-confirmed green in this phase's whole-package `flutter test` run |

No risk surface is `BLOCKED` or `NOT_REQUIRED`; all six gates ran and passed.

## 5. A1 Backend Freeze

- `git diff f5cb2c03d56f0ad86be0146aa8093a36cac6e52c --stat -- backend/`
  returns empty. No change under `backend/` since BaseHead. PASS.

## 6. Recorded Assumptions (verbatim, carried from `story_master.md` / `architecture/solution.md` §3)

- **ASSUMPTION-1**: No server-side recurrence exists (`alarm.constants.ts` has
  no repeat/cron field), so the schedule screen's "every morning" framing is
  UI-only convenience copy; the implementation sends a single absolute
  occurrence and does not auto-repeat.
- **ASSUMPTION-2 / R9**: There is no server-side FCM dispatch for alarm events
  in the current backend (`AlarmsGateway` emits only over the live socket
  namespace), so there is no background/killed-app delivery for synced
  reminders in this story's v1 scope; delivery requires the app to be
  foregrounded or backgrounded-but-connected.

## 7. Story-Level Runtime Startup Smoke

- NOT_APPLICABLE per `phase-P5-verification.md` §4A. Mobile-app readiness is
  covered by the `Key('home_screen_ready_signal')` widget signal, confirmed
  green in the whole-package `flutter test` run (§2 above).

## 8. Overall Result

All build/analyze/test gates pass. All four acceptance criteria (AC1–AC4) have
named, passing evidence. All six risk-surface gates pass. No backend changes.
No blockers. STORY-009 P5 verification is COMPLETE.
