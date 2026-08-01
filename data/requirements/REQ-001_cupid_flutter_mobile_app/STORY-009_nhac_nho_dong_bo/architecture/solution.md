# 001_synced-reminder-solution.md

## 0. Metadata

- User Story ID: STORY-009
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-009_nhac_nho_dong_bo/story_master.md`
- Complexity: M (standard)
- Referenced Inputs: `story_master.md`; `ux/uiux-spec.md` §1–§8; `req_master.md`
  STORY-009 row; system memory §3/§4/§5/§7 (ADR-002, ADR-006, ADR-007, ADR-008 +
  STORY-004 ADR-012, ADR-009), §8 R8/R9; frozen backend
  `backend/src/modules/alarms/` (gateway, service, entity, controller,
  `alarm.constants.ts`); `mobile/lib/core/realtime/cupid_realtime.dart`;
  `mobile/lib/core/network/cupid_api.dart`; `mobile/pubspec.yaml`
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md`
- Solution Number: 001
- Version: v1.0
- Date: 2026-07-30
- Status: Final

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: None (system baseline current as of 2026-07-30; STORY-004
  ADR-012 is the authoritative realtime contract)
- Architecture Drivers: AC1 both partners receive one reminder; AC2/AC3 copy
  compliance (D1/ADR-002); AC4 no native alarm; A1 backend freeze.
- Architectural invariants / non-goals:
  - Backend is frozen. No endpoint, gateway, event-name, entity, or DTO change.
  - Transport identifiers stay `alarms` / `setAlarm` / `triggerAlarm` etc.
    Internal Dart naming for this feature is `reminders`; **no** transport or
    backend name may appear in any user-facing string.
  - No native/system alarm API, no Critical Alerts entitlement, no
    Do-Not-Disturb override, no OS-level alarm scheduling, and no locally
    scheduled notification plugin. Foreground in-app reminder only.
  - No new pub dependency. The lane uses `flutter_bloc`, `socket_io_client` (via
    `RealtimeCoordinator` only), `dio` (via `CupidApi` only), and
    `shared_preferences`, all already in `mobile/pubspec.yaml`.
- Proposed technical direction: one new mobile feature slice
  `mobile/lib/features/reminders/` (`data` / `domain` / `presentation`) that
  writes over the existing `RealtimeCoordinator.emit` socket path, hydrates over
  `GET /alarms`, derives every per-partner UI state client-side, and renders an
  app-level foreground overlay when `triggerAlarm` arrives.
- Why this fits the current system: it is a pure consumer of the already-DONE
  STORY-004 realtime boundary (ADR-008/ADR-012) and the generated REST client
  boundary (ADR-006), adds no new shared boundary, and stays inside ADR-009's
  feature-first layout and ADR-003's Bloc-for-rituals rule.

## 2. Downstream Contract Summary

- Backend contract: **no change**. Consumed as-is: socket `setAlarm`
  `{time: ISO8601 String, userId: <backend User.id>}`, `confirmAlarm`
  `{alarmId, userId}`, `stopAlarm` `{alarmId, userId}`; inbound
  `newAlarmRequest` / `alarmScheduled` / `triggerAlarm` / `alarmFullyStopped`
  carry the full `Alarm` row, `alarmStoppedByPartner` carries only
  `{stopperId}`. REST `GET /alarms` returns the same `Alarm` row.
- Frontend contract: NOT_APPLICABLE (no web surface in this story).
- Mobile contract: new feature slice `mobile/lib/features/reminders/`; the only
  outward-facing additions are `ReminderRepository`, `ReminderScheduleBloc`,
  `ReminderFiringCubit`, `ReminderOverlayHost`, and `ReminderStrings`. All
  registered in `mobile/lib/core/di/service_locator.dart`.
- DevOps / environment contract: no change. Runtime registry id `mobile-app`.
- Requirement configuration guide impact: NOT_APPLICABLE (no env var, secret, or
  third-party integration change).
- Data model / migration contract: no change. `Alarm` is server-owned; the client
  keeps only view state plus two `shared_preferences` keys (see §4 Data).
- API / event / worker queue contract: see the write/read split in §4.
- Test and verification expectations: `flutter analyze`, `flutter test`,
  `flutter build apk --debug` (registry `mobile-app`). No mobile e2e, no
  emulator/simulator lifecycle, no signing, no store gates.
- Risk surfaces and verification contract: see §4 Risk Surfaces table.
- OQ constraints downstream lanes must preserve: D1/ADR-002 wording and
  no-Critical-Alerts rule; A1 backend freeze.

## 3. Scope And Assumptions

- In Scope: mobile schedule screen, mobile foreground firing overlay, canonical
  vi/en copy for this feature, discoverable entry point, client-side 5-minute
  timeout, static copy/dependency compliance guard.
- Out Of Scope: any backend change; Notifications settings screen construction
  (that screen does not exist in `mobile/lib` yet — see D9); native alarm; DND
  override; background push delivery; ARB migration; onboarding Permissions
  screen copy (UX spec §10 flags it as a separate scope).
- Assumptions affecting design:
  - **ASSUMPTION-1 (needs PO/UX confirmation, does not block implementation):**
    the frozen `Alarm` entity has a single `time: timestamp` and **no weekday or
    repeat column**, so a recurring "mỗi sáng / every morning" schedule is not
    persistable under A1. The weekday chip row is therefore a client-local
    selection that computes the next matching absolute occurrence and sends that
    one timestamp. v1 does not auto-repeat. The UX eyebrow copy "Nhắc nhở đồng
    bộ mỗi sáng / Shared morning reminder" implies recurrence it cannot deliver;
    flagged to Scrum Master for a PO/UX copy ruling. Implementation must not
    claim automatic daily repetition in any string it writes.
  - **ASSUMPTION-2:** R9 (no server-side FCM dispatch; `triggerPushNotification`
    is a `console.log` stub) means a backgrounded device receives nothing. UX
    spec §5 step 5's "system push" is not deliverable in v1 and must not be
    implemented client-side by adding a local-notification scheduler (that is
    the excluded native-alarm path). Backgrounded devices recover on next
    foreground via `GET /alarms`.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| D1 / ADR-002 | RESOLVED | native/system alarm, Critical Alerts entitlement, DND-override claim, "báo thức"/"Synced Alarm" user-facing wording | strong in-app foreground reminder; "nhắc nhở đồng bộ" wording | D8 + D9: single canonical strings file plus a static guard test that fails the build on forbidden tokens |
| A1 | RESOLVED | any `backend/` edit, endpoint/event rename | consuming the frozen `alarms` contract unchanged | D1–D5 derive all missing behavior client-side |
| R8 (socket mock auth) | ACCEPTED RISK | client-side fix | send `handshake.auth.token` (already done by `RealtimeCoordinator`) and pass the backend `User.id` in payloads | no new mitigation in this story |
| R9 (no backend FCM dispatch) | ACCEPTED RISK | background reminder delivery | foreground overlay + foreground rehydration | ASSUMPTION-2 |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/reminders/` (new). Contract owner for the
  reminder feature: Tech Lead; consumer: Mobile Developer.
- New or changed boundaries: none. `RealtimeCoordinator` (ADR-008/ADR-012) and
  `CupidApi` (ADR-006) remain the only realtime and REST surfaces. The feature
  must not import `package:socket_io_client/...`,
  `package:firebase_messaging/...`, `package:cupid_api/...`, or construct `Dio`.
- Shared patterns reused: ADR-003 Bloc for the realtime ritual + Cubit for the
  overlay; ADR-004 adaptive widgets and `ThemeExtension` tokens; STORY-003's
  `context.viEn(vi, en)` locale-resolution extension; STORY-003's
  "read the raw body through `CupidApi.dio` when the OpenAPI response schema is
  absent" precedent; `SessionScopedStore` for sign-out clearing.

### Affected Components And Layers

- Backend: none.
- Frontend: none.
- Mobile: new `features/reminders/{data,domain,presentation}`; edits to
  `core/di/service_locator.dart`, `core/navigation/app_shell.dart`,
  `features/home/presentation/home_screen.dart`, and additive glyph constants in
  `design_system/icons/cupid_icons.dart`.
- Data: server-owned `Alarm` unchanged. Client adds two `shared_preferences`
  keys, `reminder.weekdays` (local selection) and
  `reminder.pending_timeout_notice` (unacknowledged-timeout flag for the toast
  in UX §7), both cleared through `SessionScopedStore.clearOnSignOut()`.
- Infrastructure: none.

### Contracts And Integrations

- Contract owner: backend (frozen). Dependency direction: mobile -> backend only.
- **D1 — writes go over the socket, never over REST.** The REST controller calls
  `AlarmsService` directly and performs **no gateway fanout**, so a REST
  `POST /alarms` / `PATCH /alarms/:id/confirm` / `PATCH /alarms/:id/stop` never
  reaches the partner device. AC1 is only satisfiable through
  `RealtimeCoordinator.emit('setAlarm'|'confirmAlarm'|'stopAlarm', payload)`.
  `emit` throws `RealtimeNotLiveFailure` when status is not `live`, which is the
  ADR-007(b) fail-fast-with-retry-affordance contract; surface it as an inline
  retry, never a silent drop.
- **D2 — hydration reads go over REST raw body.** Generated
  `Epic3SyncedAlarmsApi.alarmsControllerFindOne` is typed `Future<Response<void>>`
  because the backend Swagger declares no response schema, so the `Alarm` is
  unreachable through it. Use `getIt<CupidApi>().dio.get<Object?>('/alarms')`
  and parse the map, mirroring STORY-003 `auth_repository.dart:99-112`. Record
  the same rationale in a one-line comment.
- **D3 — per-partner state is derived client-side.** `Alarm` has no
  per-user confirmation column and `confirmAlarm` sets `status` straight to
  `scheduled`. Derive the viewer stage from `status` + `requesterId` vs
  `BackendUserIdStore.backendUserId`:
  `pending_confirmation` + viewer is `partnerId` -> `needsMyConfirmation`;
  `pending_confirmation` + viewer is `requesterId` -> `awaitingPartner`;
  `scheduled` -> `bothConfirmed`; `ringing` -> `firing`; `stopped` -> `cleared`.
  Per-partner firing labels derive from `stopperIds.contains(<partner id>)`.
- **D4 — the 5-minute timeout is client-side only.** The backend scheduler has
  no timeout: `stopAlarm` only reaches `stopped` when `stopperIds.length >= 2`.
  `ReminderFiringCubit` starts a 5-minute timer when the overlay opens, clears
  the overlay locally on expiry, and sets `reminder.pending_timeout_notice`.
  It must **not** emit `stopAlarm` on expiry — that event means "this user
  swiped" and would falsely record the user as a stopper. The server row may
  stay `ringing`; the next `setAlarm` resets `status` and `stopperIds`, and the
  15-second scheduler only picks up `scheduled` rows, so it cannot re-fire.
- **D5 — `alarmStoppedByPartner` is an ephemeral event.** Its payload is
  `{stopperId}` with no server uuid, so `RealtimeEvent.isDurable` is false: per
  ADR-012d it is never FCM-delivered and is dropped while not foreground.
  Partner-dismissed state must therefore be re-derived from `GET /alarms`
  `stopperIds` on every foreground rehydration, not only from the live event.
- Event/payload contract consumed (exact wire strings from
  `backend/src/modules/alarms/alarm.constants.ts`, mirrored once in
  `features/reminders/data/reminder_wire_events.dart`):
  outbound `setAlarm`, `confirmAlarm`, `stopAlarm`; inbound `newAlarmRequest`,
  `alarmScheduled`, `triggerAlarm`, `alarmStoppedByPartner`,
  `alarmFullyStopped`. Filter with `RealtimeCoordinator.events(names: {...})`
  and switch on `RealtimeEvent.name`; never branch on `transport`.
- Error / empty-state contract: `GET /alarms` may return `null` (no reminder
  yet) -> empty schedule state, not an error. `RealtimeNotLiveFailure` and
  `CupidApiFailure` render an inline retry affordance. No offline write queue
  (ADR-007b).
- Compatibility posture: additive. No shared contract is renamed.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Realtime reminder events | `alarm.constants.ts` + `cupid_realtime.dart` | `ReminderRepository` event stream + `emit` payloads | unit tests over a fake `RealtimeCoordinator` for all 5 inbound + 3 outbound events | mark BLOCKED; do not hand-verify against a live backend |
| Copy compliance (AC2/AC3) | `ux/uiux-spec.md` §2–§4 + ADR-002 | `ReminderStrings` is the only source of this feature's user-facing text | `reminder_copy_guard_test.dart` static scan of `mobile/lib/**` | BLOCKED: story cannot pass review without this gate |
| Native-alarm non-goal (AC4) | `story_master.md` Out of Scope + ADR-002 | no alarm/local-notification plugin in `mobile/pubspec.yaml` | dependency assertion inside the same guard test | BLOCKED |
| Client-side 5-minute timeout | D4 above | `ReminderFiringCubit` timer, no `stopAlarm` emit | cubit test with an injected clock/timer seam, asserting no outbound emit | BLOCKED |
| Overlay mount + a11y | `ux/uiux-spec.md` §3, §7 | `ReminderOverlayHost` mounted once above the shell | widget test: announcement on open, non-gesture dismiss button, safe-area padding | mark BLOCKED |
| Entry-point discoverability | ADR-009 + `app_shell.dart` | home surface exposes a reminder action | widget test: tap from home reaches the schedule screen; `Key('home_screen_ready_signal')` still pumps | BLOCKED (runtime registry readiness depends on that key) |

### Mobile Lane Handoff

- Mobile responsibilities: everything in this story. Single-lane.
- Authoritative inputs: this solution §2/§4; `ux/uiux-spec.md` §2–§8 for copy,
  layout, responsive and a11y rules; `cupid_realtime.dart` for the realtime API.
- Mobile constraints derived from UX: exact vi/en strings from §2/§3/§4 (with
  the DND clause deleted, not softened); `notifications_active` glyph identity,
  never an alarm-clock glyph; `shake` keyframe kept; safe-area insets on the
  overlay; text label always paired with colour for partner state; a
  non-gesture dismiss equivalent alongside swipe-to-dismiss; timeout toast on
  next open.
- Mobile guardrails: no backend edits, no new pub dependency, no direct socket /
  FCM / generated-client / `Dio` import from the feature, no `AppL10n` ARB
  migration, no construction of the Notifications settings screen.

### Backend / Frontend / DevOps Lane Handoff

- Not participating. No backend, frontend, or DevOps phase exists in this story.

## 5. Non-Functional Impact

- Security / privacy: unchanged; R8 socket mock auth remains an accepted,
  escalated backend risk. Payload `userId` must be the backend `User.id` from
  `BackendUserIdStore`, never the Firebase uid (ADR-012c room-key rule).
- Reliability: foreground-only delivery is the honest v1 behaviour (R9). Missed
  reminders are recovered by `GET /alarms` rehydration, not by a fake push.
- Performance: one bounded overlay widget and one bloc; no list paging concerns.
- Observability: reuse `RealtimeCoordinator` status for the connection banner;
  do not add a new logging channel.
- Migration / rollback: none. Reverting the feature slice plus the four edited
  files fully removes the capability.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| REST write path via generated client | typed, matches ADR-006 | REJECTED | REST performs no partner fanout, so AC1 fails |
| Local scheduled notification to cover background | would satisfy UX §5 step 5 | REJECTED | needs a new plugin and re-creates a client-side alarm scheduler, excluded by D1/AC4 |
| ARB (`AppL10n`) for this feature's copy | project has an ARB pipeline | REJECTED for v1 | one `ReminderStrings` file makes AC2/AC3 auditable by a single static guard; follows STORY-003 precedent |
| Emit `stopAlarm` on 5-minute expiry | keeps server state tidy | REJECTED | falsely records the user as a stopper and can flip the row to `stopped` |

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Recurrence expectation vs single-timestamp backend (ASSUMPTION-1) | user-visible promise mismatch | flag to PO/UX now; implementation writes no auto-repeat claim |
| Background reminder silently missed (R9) | AC1 partially degraded | foreground rehydration + timeout notice toast; recorded as an accepted v1 limitation, not hidden |
| Server row stuck at `ringing` after client timeout (D4) | stale server state | tolerated: scheduler only fires `scheduled` rows; next `setAlarm` resets it |
| Backend naming leaking into copy | AC2/AC3 failure | wire strings confined to `reminder_wire_events.dart`; static guard test |
| Material Symbols codepoints guessed wrong | blank glyph boxes | resolve codepoints against the bundled `MaterialSymbolsRounded-Variable.ttf` and assert rendering in the widget test |

## 8. Handoff Notes

- Implementation guardrails: §4 D1–D5 are binding contracts, not suggestions.
- OQ-driven constraints to preserve: ADR-002 wording, no DND claim, no native
  alarm, A1 backend freeze.
- Shared contract-first work required: YES — phase P0 fixes the wire-event
  constants and the `SyncedReminder` / stage model before any UI work.
- Shared coding plan required: YES — `coding-plan/master-plan.md`, phases P0–P5.
- Memory updates required: NO for this run. If PO rules on ASSUMPTION-1, the
  outcome belongs in system memory §7 as an ADR-002 addendum.
- Open questions / blockers: ASSUMPTION-1 needs a PO/UX copy ruling on the
  "mỗi sáng / morning" recurrence wording. Non-blocking for implementation.
