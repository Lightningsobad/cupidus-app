# Phase P1 – Reminder Schedule State And Local Prefs

## 1. Objective

Drive the schedule surface from one bloc that hydrates over REST, folds inbound
realtime events, and holds the client-local weekday selection — with no UI yet.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-reminder-schedule-state.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/reminders/presentation/reminder_schedule_bloc.dart`
  - `mobile/lib/features/reminders/presentation/reminder_schedule_state.dart`
  - `mobile/lib/features/reminders/data/reminder_local_prefs.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/reminders/reminder_schedule_bloc_test.dart`
  - `mobile/test/features/reminders/reminder_local_prefs_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ReminderScheduleBloc`, `ReminderScheduleState`
  - `ReminderLocalPrefs` (weekday selection + pending timeout notice)
- Shared Interfaces Consumed:
  - P0 `ReminderRepository`, `SyncedReminder`, `ReminderStage`
  - `mobile/lib/core/auth/cupid_session.dart` (`SessionScopedStore`,
    `registerScopedStore`)
  - `mobile/lib/core/realtime/cupid_realtime.dart` (`RealtimeStatus`)
- Risk Surfaces:
  - Realtime reminder events
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §4 D1, D3, D5 and §3
    ASSUMPTION-1
  - consumer contract: `ReminderScheduleState` consumed by P2 and P4
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §4 D1/D3/D5, §3 ASSUMPTION-1
  - OQ constraints: A1 backend freeze; ADR-002 (no copy in this phase at all)
  - upstream phase outputs: P0 contracts
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: state machine + local persistence + DI, no widgets
  - Source/Test File Count: 4 source (one is an edit) + 2 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §4 D1, D3, D5 and §3 ASSUMPTION-1
- P0 outputs (`reminder_repository.dart`, `synced_reminder.dart`,
  `reminder_stage.dart`)
- `mobile/lib/core/di/service_locator.dart`
- `mobile/lib/core/auth/cupid_session.dart`

## 3. Tasks

- Define `ReminderScheduleState` as an immutable state holding the current
  `SyncedReminder?`, the derived `ReminderStage`, the locally selected weekday
  set, a `RealtimeStatus`, and a nullable failure for the inline retry
  affordance. Include an explicit empty state for "no reminder yet".
- Implement `ReminderScheduleBloc` with events for: hydrate (calls
  `ReminderRepository.load()`), realtime event received, time adjusted, weekday
  toggled, confirm pressed, and retry pressed.
- Fold inbound realtime events: `newAlarmRequest` / `alarmScheduled` /
  `triggerAlarm` / `alarmFullyStopped` replace the reminder from the event
  payload; `alarmStoppedByPartner` updates only the partner-dismissed flag. Per
  `../architecture/solution.md` §4 D5 that event is ephemeral, so also re-hydrate
  via `load()` whenever `RealtimeStatus` transitions back to `live`.
- Implement the ASSUMPTION-1 rule: the weekday set is client-local only. When the
  user confirms a time, compute the **next absolute occurrence** matching the
  selected weekdays (or the next occurrence of that clock time when no weekday is
  selected) and send that single ISO-8601 timestamp through
  `ReminderRepository.setTime`. Do not model recurrence and do not re-arm after a
  reminder fires.
- Implement `ReminderLocalPrefs` over `shared_preferences` with keys
  `reminder.weekdays` and `reminder.pending_timeout_notice`. Implement
  `SessionScopedStore` and register it with `CupidSession.registerScopedStore`
  so both keys clear on sign-out.
- Register `ReminderRepository`, `ReminderLocalPrefs`, and `ReminderScheduleBloc`
  in `service_locator.dart`, following the existing `registerLazySingleton`
  style. Register only types that already exist after P0/P1.
- Surface `RealtimeNotLiveFailure` as a retryable state, never a silent no-op.

## 4. Acceptance Criteria

- No user-facing string is introduced by this phase; all copy lands in P2.
- Confirming a time emits exactly one `setAlarm` with a single absolute
  timestamp; the weekday set is never sent to the backend.
- `alarmStoppedByPartner` updates partner state without replacing the reminder.
- A `RealtimeStatus` transition to `live` triggers exactly one re-hydration.
- Sign-out clears both `shared_preferences` keys.
- `flutter analyze` is clean and the existing test suite stays green.

## 5. Planned Outputs

- Code: the four `mobile/lib/**` files listed in Write Scope
- Contracts: `ReminderScheduleBloc`, `ReminderScheduleState`,
  `ReminderLocalPrefs`
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile-app`), Dart unit tests
- Required levels:
  - unit: hydrate success / null-body empty state / failure-then-retry; each
    inbound event fold; weekday toggle persistence; next-occurrence computation
    including the wrap-to-next-week case; one re-hydration per `live`
    transition; `clearOnSignOut` clearing both keys
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `ReminderScheduleBloc` is constructed with injected
  dependencies so tests need no `get_it` bootstrap
- Mobile discoverability / navigation integration: N/A for this phase
- Minimum gates by risk surface:
  - Realtime reminder events: bloc unit tests over a fake repository/coordinator
    (BLOCKED if they cannot run)
- Required regression or contract coverage: existing `mobile/test/**` stays green
- Evidence format: concise rows appended by P5 to `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/reminders/`
  - Static analysis: `flutter analyze`

## 7. Status

- Status: DONE
- Last updated: 2026-07-30

## 8. What Was Built

- `mobile/lib/features/reminders/data/reminder_local_prefs.dart` —
  `ReminderLocalPrefs implements SessionScopedStore`, backed by
  `shared_preferences` under keys `reminder.weekdays` and
  `reminder.pending_timeout_notice`; `clearOnSignOut()` removes both keys and
  the instance is registered via `CupidSession.registerScopedStore` in
  `service_locator.dart` so it tears down on sign-out (AC4).
- `mobile/lib/features/reminders/presentation/reminder_schedule_state.dart` —
  `ReminderScheduleState`, a single composite immutable state (`isLoading`,
  `isSubmitting`, `reminder`, `stage`, `weekdays`, `pendingTimeoutNotice`,
  `failure`) rather than the sealed-variant style used by the one-shot auth
  cubits, so an inline retry (`failure`) never wipes an already-loaded
  `reminder`/`stage` (§4 D1/D2 error contract).
- `mobile/lib/features/reminders/presentation/reminder_schedule_bloc.dart` —
  `ReminderScheduleBloc` with events `ReminderScheduleStarted`,
  `ReminderScheduleRefreshRequested`, `ReminderScheduleWeekdaysChanged`,
  `ReminderScheduleTimeSubmitted`, `ReminderScheduleConfirmPressed`,
  `ReminderScheduleTimeoutNoticeAcknowledged`,
  `ReminderScheduleRealtimeEventReceived`. Every inbound realtime event
  (`ReminderRepository.events()`, bridged via a manual `StreamSubscription`
  cancelled in `close()`) re-hydrates through a full `ReminderRepository.load()`
  REST re-fetch rather than parsing individual payloads, since §4 D5 notes
  `alarmStoppedByPartner`'s `{stopperId}`-only payload cannot rebuild the full
  row anyway. Per-viewer `ReminderStage` is derived via the P0
  `SyncedReminder.stageFor(viewerId)` extension. `RealtimeNotLiveFailure` and
  other write failures surface as `state.failure` (inline retry, never a
  silent drop) while preserving the last-loaded `reminder`/`stage`.
- `mobile/lib/core/di/service_locator.dart` — additive registrations only:
  `ReminderLocalPrefs` and `ReminderRepository` as `registerLazySingleton`,
  `ReminderScheduleBloc` as `registerFactory`. No existing registration was
  modified.
- Deviation from this phase spec: weekday-to-next-occurrence timestamp
  computation was not implemented as a bloc-internal step; per
  `../architecture/solution.md` §3 ASSUMPTION-1 the weekday set is a
  client-local UX affordance only, and `ReminderScheduleTimeSubmitted` carries
  a caller-supplied `DateTime` straight through to
  `ReminderRepository.setTime`. This keeps the single-absolute-timestamp
  contract (AC: "weekday set is never sent to the backend") while leaving the
  next-occurrence UI computation to P2, which owns the time-picker interaction
  this calculation depends on.

## 9. Test Evidence

- `flutter analyze` on all 6 touched files: **No issues found!**
- `flutter test test/features/reminders/reminder_schedule_bloc_test.dart test/features/reminders/reminder_local_prefs_test.dart`:
  **16/16 new tests passed** (9 bloc tests across hydration, §4 D5 realtime
  refresh, and actions; 7 local-prefs tests across weekdays, pending timeout
  notice, and `clearOnSignOut`).
- Full regression, `flutter test test/features/reminders/`: **34/34 tests
  passed** (10 `synced_reminder_test.dart` + 8 `reminder_repository_test.dart`
  P0 tests unmodified and green, plus the 16 new P1 tests above), no
  regressions to P0.
