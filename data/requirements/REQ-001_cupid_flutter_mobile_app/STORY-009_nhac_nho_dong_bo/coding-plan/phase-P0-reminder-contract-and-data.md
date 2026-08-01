# Phase P0 – Reminder Contract And Data Layer

## 1. Objective

Fix the frozen `alarms` wire contract in one Dart file, model the server-owned
reminder plus its client-derived viewer stage, and expose a single repository
that writes over the socket and hydrates over REST.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-reminder-contract-and-data.md`
- Owner: Mobile Developer
- Lane: Contract

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/reminders/data/reminder_wire_events.dart`
  - `mobile/lib/features/reminders/domain/synced_reminder.dart`
  - `mobile/lib/features/reminders/domain/reminder_stage.dart`
  - `mobile/lib/features/reminders/data/reminder_repository.dart`
  - `mobile/test/features/reminders/synced_reminder_test.dart`
  - `mobile/test/features/reminders/reminder_repository_test.dart`
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
  - `ReminderWireEvents` (exact frozen event strings)
  - `SyncedReminder`, `ReminderStage`
  - `ReminderRepository`
- Shared Interfaces Consumed:
  - `mobile/lib/core/realtime/cupid_realtime.dart` (`RealtimeCoordinator`,
    `RealtimeEvent`, `RealtimeNotLiveFailure`)
  - `mobile/lib/core/network/cupid_api.dart` (`CupidApi.dio`)
  - `mobile/lib/core/realtime/backend_user_id_store.dart`
- Risk Surfaces:
  - Realtime reminder events
- Source Of Truth:
  - authoritative artifact: `backend/src/modules/alarms/alarm.constants.ts`,
    `backend/src/modules/alarms/entities/alarm.entity.ts` (read-only, frozen)
  - consumer contract: `../architecture/solution.md` §4 D1, D2, D3, D5
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2, §4 (D1, D2, D3, D5)
  - OQ constraints: A1 backend freeze — no `backend/` file may be edited
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: contract + data access only, no UI and no state machine
  - Source/Test File Count: 4 source + 2 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2 and §4 (D1, D2, D3, D5)
- `mobile/lib/core/realtime/cupid_realtime.dart`
- `mobile/lib/features/auth/data/auth_repository.dart` lines 88-112 only, for the
  raw-body REST precedent
- `backend/src/modules/alarms/alarm.constants.ts` and
  `backend/src/modules/alarms/entities/alarm.entity.ts` (read-only)

## 3. Tasks

- Mirror the eight frozen event strings in `ReminderWireEvents` as `static const
  String` members (`setAlarm`, `confirmAlarm`, `stopAlarm`, `newAlarmRequest`,
  `alarmScheduled`, `triggerAlarm`, `alarmStoppedByPartner`,
  `alarmFullyStopped`), plus an `inbound` set for
  `RealtimeCoordinator.events(names: ...)`. Add a one-line comment that these are
  backend transport names frozen by A1/ADR-002 and must never reach the UI.
- Model `SyncedReminder` as an immutable class over the frozen `Alarm` row
  (`id`, `time`, `isActive`, `status`, `requesterId`, `partnerId`, `stopperIds`)
  with a `fromJson` that tolerates a `null` body and a missing/empty
  `stopperIds`.
- Implement `ReminderStage` and a `stageFor(String viewerUserId)` derivation
  exactly per `../architecture/solution.md` §4 D3. Also expose
  `hasDismissed(String userId)` from `stopperIds` for the per-partner firing
  labels.
- Implement `ReminderRepository` with: `Future<SyncedReminder?> load()` using
  `CupidApi.dio.get<Object?>('/alarms')` (comment the D2 rationale);
  `Stream<RealtimeEvent> events()` filtered by `ReminderWireEvents.inbound`;
  and `setTime`, `confirm`, `dismiss` that call
  `RealtimeCoordinator.emit(<wire event>, payload)` with `userId` taken from
  `BackendUserIdStore.backendUserId`.
- Let `RealtimeNotLiveFailure` and `CupidApiFailure` propagate unchanged; do not
  swallow them and do not add a retry queue (ADR-007b).

## 4. Acceptance Criteria

- No file under `backend/` is modified.
- The feature imports only `core/realtime/cupid_realtime.dart` and
  `core/network/cupid_api.dart`; it does not import `socket_io_client`,
  `firebase_messaging`, `package:cupid_api/...`, or construct `Dio`.
- `stageFor` returns `needsMyConfirmation` when `status ==
  'pending_confirmation'` and the viewer is `partnerId`, `awaitingPartner` when
  the viewer is `requesterId`, `bothConfirmed` for `'scheduled'`, `firing` for
  `'ringing'`, `cleared` for `'stopped'`.
- `setTime` sends `time` as an ISO-8601 string and `userId` as the backend
  `User.id`, never the Firebase uid.
- `load()` returns `null` (not an error) when the body is `null`.
- No user-facing string exists in any file produced by this phase.

## 5. Planned Outputs

- Code: the four `mobile/lib/features/reminders/**` files listed in Write Scope
- Contracts: `ReminderWireEvents`, `SyncedReminder`, `ReminderStage`,
  `ReminderRepository`
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile-app`), Dart unit tests
- Required levels:
  - unit: `stageFor` for all five statuses from both viewer perspectives;
    `fromJson` null/empty-`stopperIds` cases; each of the three emit helpers
    asserting the exact wire name and payload against a fake
    `RealtimeCoordinator`; inbound stream filtering over all five inbound events
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: no `backend/` diff; no forbidden imports
- Mobile discoverability / navigation integration: N/A for this phase
- Minimum gates by risk surface:
  - Realtime reminder events: unit tests over the fake coordinator (BLOCKED if
    they cannot run; do not substitute live-backend checks)
- Required regression or contract coverage: existing
  `mobile/test/**` suite must stay green
- Evidence format: concise rows appended by P5 to `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/reminders/`
  - Static analysis: `flutter analyze`

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Evidence:
  - `flutter test test/features/reminders/`: 17/17 passed
    (`synced_reminder_test.dart` 10, `reminder_repository_test.dart` 7)
  - `flutter test` (full suite): 136/136 passed, no regressions
  - `flutter analyze lib/features/reminders test/features/reminders`: No
    issues found
  - `git status --porcelain -- backend/`: empty (no `backend/` diff)
  - Imports confirmed limited to `core/realtime/cupid_realtime.dart` and
    `core/network/cupid_api.dart`; no `socket_io_client`,
    `firebase_messaging`, `package:cupid_api/...`, or raw `Dio` construction
    in production code
  - No user-facing strings in any P0 file
