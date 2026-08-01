# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
`../architecture/solution.md` §4 D1–D5 are binding contracts; read them before
touching the data or state layer.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane (all phases here are Mobile Developer).
3. Update phase status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand phase scope into migration, rollout, or contract areas not
   assigned to your phase.
6. Stop and escalate if the work requires an unresolved decision the phase does
   not already resolve.

## 4. Story-Specific Hard Rules

These apply to every phase and override convenience:

1. **No backend change.** A1 freeze. Nothing under `backend/` may be edited, and
   no endpoint, event name, entity, or DTO may be added.
2. **Copy rule (AC2/AC3, ADR-002/D1).** Every user-facing string says
   "nhắc nhở đồng bộ" / "synced reminder". Never "báo thức", never
   "Synced Alarm", never a Do-Not-Disturb-override claim, never "reo"/"ring"
   bell language. Backend transport names (`alarms`, `setAlarm`, `triggerAlarm`,
   …) are confined to `features/reminders/data/reminder_wire_events.dart`.
3. **No native alarm (AC4).** No OS alarm API, no platform channel, no
   local-notification or alarm plugin, no new `pubspec.yaml` dependency. The
   reminder is a foreground in-app overlay only.
4. **No recurrence claim.** The frozen `Alarm` row has one `time` column and no
   weekday/repeat field, so weekday chips are client-local and only the next
   absolute occurrence is sent. Do not write copy implying automatic daily
   repetition (`../architecture/solution.md` §3 ASSUMPTION-1).
5. **No background-delivery claim.** The backend push is a `console.log` stub
   (R9), so a backgrounded device receives nothing in v1. Recover by
   re-hydrating from `GET /alarms`; do not fake a push.
6. **Writes over the socket, reads over REST.** The REST controller performs no
   partner fanout, so REST writes cannot satisfy AC1
   (`../architecture/solution.md` §4 D1, D2).
7. **Boundary imports only.** Import `core/realtime/cupid_realtime.dart` and
   `core/network/cupid_api.dart`. Never `socket_io_client`,
   `firebase_messaging`, `package:cupid_api/...`, and never construct `Dio`.
8. **Preserve `Key('home_screen_ready_signal')`** on the home screen; it is the
   `mobile-app` runtime registry readiness signal.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the plan during implementation.
- Escalate if the plan is materially wrong.
