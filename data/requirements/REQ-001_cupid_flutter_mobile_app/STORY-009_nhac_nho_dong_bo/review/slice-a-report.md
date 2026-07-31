# STORY-009 Review — Scoped Slice A (P0 contract/data layer + P1 schedule bloc/state)

- Reviewer: Iris-QC (reviewer)
- Scope: AC1 foundation contracts D1/D2/D3/D5 only (`architecture/solution.md` §4)
- Diff base: `0a467d03babf1ed4102c3fab09c61b2dec941a0b` (verified ancestor of worktree HEAD `386310249f35e8d84a12b763ec2923935de7b160`)
- Files reviewed (12): `reminder_wire_events.dart`, `synced_reminder.dart`, `reminder_stage.dart`, `reminder_repository.dart`, `synced_reminder_test.dart`, `reminder_repository_test.dart`, `reminder_schedule_bloc.dart`, `reminder_schedule_state.dart`, `reminder_local_prefs.dart`, `service_locator.dart`, `reminder_schedule_bloc_test.dart`, `reminder_local_prefs_test.dart`

## Contract verification

| Contract | Requirement | Evidence | Result |
|---|---|---|---|
| D1 | Writes (`setTime`/`confirm`/`dismiss`) must go over the socket via `RealtimeCoordinator.emit`, never REST | `reminder_repository.dart` `setTime`/`confirm`/`dismiss` call `_realtime.emit('setAlarm'\|'confirmAlarm'\|'stopAlarm', ...)` exclusively; no REST POST/PATCH call exists anywhere in the reviewed files | PASS |
| D2 | Hydration reads must use `getIt<CupidApi>().dio.get('/alarms')` raw-body parse, not the generated typed client | `reminder_repository.dart` `load()`: `_api.dio.get<Object?>('/alarms')` then `SyncedReminder.fromJson(response.data)`; doc comment cites the `Response<void>` rationale matching D2 and mirrors `auth_repository.dart` precedent | PASS |
| D3 | Per-partner stage derived client-side from `status` + `requesterId` vs backend `User.id`, with exact mapping | `reminder_stage.dart` `stageFor()` implements the exact mapping: `pending_confirmation`+viewer==partnerId -> `needsMyConfirmation`; `pending_confirmation`+viewer==requesterId -> `awaitingPartner`; `scheduled` -> `bothConfirmed`; `ringing` -> `firing`; `stopped`/default -> `cleared`. Matches architecture §4 D3 verbatim. | PASS |
| D5 | `alarmStoppedByPartner` is ephemeral; partner-dismissed state re-derived from `GET /alarms` `stopperIds`, not parsed ad hoc from the live event payload | `ReminderWireEvents.inbound` includes `alarmStoppedByPartner` alongside the other 4 inbound events; `reminder_schedule_bloc.dart` `_onRealtimeEventReceived` ignores the event payload entirely and calls `_hydrate()` (-> `repository.load()` -> `GET /alarms`) for every inbound event, uniformly re-deriving state from the REST row rather than the socket payload. `SyncedReminderStage.hasDismissed()` reads `stopperIds` off the hydrated `SyncedReminder`. | PASS |

## Named test evidence (from `coding-plan/test-results.md` §2–§3, AC1 subsection)

- `reminder_repository_test.dart`:
  - `outbound emit setTime emits setAlarm with an ISO-8601 time and backend userId` — present, asserts `realtime.emitted` contains `setAlarm` with `time.toIso8601String()` + `userId: 'user-1'` (backend id, not Firebase uid). PASS.
  - `outbound emit confirm emits confirmAlarm with alarmId and backend userId` — present, asserts `confirmAlarm` payload. PASS.
  - `outbound emit dismiss emits stopAlarm with alarmId and backend userId` — present, asserts `stopAlarm` payload. PASS.
  - `.events filters the merged stream to the five inbound wire events` — present as `ReminderRepository.events / filters the merged stream to the five inbound wire events`; fires `triggerAlarm`, an unrelated `rejectAlarm`, and `alarmFullyStopped`, asserts only the two named ones pass the filter. Confirms `ReminderWireEvents.inbound` (5 events) is the actual filter set. PASS.
- `reminder_schedule_bloc_test.dart`:
  - `realtime refresh (§4 D5) an inbound wire event re-hydrates from GET /alarms` — present. Seeds two REST bodies (`pending_confirmation` then `scheduled`), fires an inbound `alarmScheduled` event, and asserts the bloc state transitions from `needsMyConfirmation` to `bothConfirmed` purely from the second REST fetch, not from the event payload (the fake event carries no data). This is representative evidence for D5's re-hydration mechanism generically — the bloc's `_onRealtimeEventReceived` handler does not branch on which of the 5 inbound event names fired, so the same rehydrate path applies uniformly to `alarmStoppedByPartner`. PASS.

Both named test files were inspected directly (not just test-results.md's description) and their assertions match the claimed behavior; no vacuous or mismatched test bodies found.

## Additional checks

- Import boundaries respected: `reminder_repository.dart` and `reminder_schedule_bloc.dart` import only `core/network/cupid_api.dart`, `core/realtime/cupid_realtime.dart`, `core/realtime/backend_user_id_store.dart` — no direct `package:socket_io_client`, `package:firebase_messaging`, `package:cupid_api` (generated client), or `Dio()` construction anywhere in the 12 files. Matches §4 Boundaries And Ownership.
- `userId` payloads use `BackendUserIdStore.backendUserId` (backend `User.id`), never a Firebase uid, matching §5 Non-Functional Impact (ADR-012c room-key rule).
- `RealtimeNotLiveFailure`/`CupidApiFailure` propagate to `state.failure` without wiping already-loaded `reminder`/`stage` (`reminder_schedule_state.dart` `copyWith` keeps `reminder`/`stage` untouched on failure) — matches the D1/D2 inline-retry, never-silent-drop error contract.
- `ReminderLocalPrefs` implements `SessionScopedStore.clearOnSignOut()` clearing both `reminder.weekdays` and `reminder.pending_timeout_notice` keys — consistent with §4 Data.
- `service_locator.dart` registers `ReminderLocalPrefs`/`ReminderRepository`/`ReminderScheduleBloc` (and `ReminderFiringCubit`, out of this slice's scope but present in the same diff hunk) with correct dependency wiring; no issues observed.
- Diff-base sanity: `test-results.md`'s recorded BaseHead (`f5cb2c03d56f0ad86be0146aa8093a36cac6e52c`) is a later commit than this review's assigned `BaseHead` (`0a467d03...`); confirmed both are ancestors of worktree HEAD (`0a467d03` = pre-implementation architecture baseline, `f5cb2c03` = P5 all-phases-done checkpoint). No inconsistency.

## Findings

No defects found in scoped slice A. All four AC1 foundation contracts (D1/D2/D3/D5) are correctly implemented and covered by the named passing tests.

## Result

- D1: PASS
- D2: PASS
- D3: PASS
- D5: PASS
- Named AC1-foundation tests: PASS (verified by direct inspection)

REVIEW_SLICE_COMPLETE: YES
