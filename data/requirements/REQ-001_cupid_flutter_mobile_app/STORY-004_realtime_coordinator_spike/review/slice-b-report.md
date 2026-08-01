# STORY-004 Review — Slice B (P1 + P3)

Scope: `mobile/android/app/src/main/AndroidManifest.xml`,
`mobile/ios/Runner/Info.plist`, `mobile/lib/core/realtime/fcm_transport.dart`,
`mobile/lib/core/realtime/pending_event_store.dart`,
`mobile/lib/core/realtime/backend_user_id_store.dart`, their three test files,
and `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`
(the handoff-listed path was one directory level too deep — the actual P1
write-scope path is at REQ level per `phase-P1-fcm-apns-config.md` §1B; it is
present and was reviewed).

Base: `00938d8276c8a8a15671fcd1e671db55d2aa32dc`.

## Findings Table

| # | Check | Result |
|---|---|---|
| 1 | iOS `Info.plist` declares `UIBackgroundModes: remote-notification`; no Critical Alerts entitlement | PASS |
| 2 | Android `AndroidManifest.xml` declares `com.google.firebase.messaging.default_notification_channel_id` = `cupid_realtime_default` | PASS |
| 3 | Configuration guide FCM/APNs section: APNs key upload procedure, channel id, FCM HTTP v1 injection procedure with ADR-012f-shaped sample payload, explicit "no new env/`--dart-define`" statement, explicit R9-temporary-injection-path caveat | PASS — thorough, self-contained, matches P1 §3/§4 exactly |
| 4 | Channel id identical in manifest and guide (`cupid_realtime_default`) | PASS |
| 5 | `fcm_transport.dart`: single parser (`parseFcmDataMap`) reused for both foreground and background paths, `cupid_event_id` → `RealtimeEvent.id`, missing id → ephemeral | PASS |
| 6 | Message missing `cupid_event` rejected without throwing, nothing persisted, rejection logged without payload content | PASS (background handler returns early on `null`; foreground never emits it; `_logRejection` message contains no payload data) |
| 7 | Background handler is top-level, `@pragma('vm:entry-point')`, touches no `get_it`/in-memory state — only side effect is `PendingEventStore().append(...)` | PASS |
| 8 | Ephemeral events never persisted (background handler checks `event.isEphemeral`) | PASS |
| 9 | `pending_event_store.dart`: bounded append-only JSON list in `SharedPreferences`, oldest-first eviction, entry shape `{name,id,payload,receivedAt}` | PASS |
| 10 | Persisted queue survives re-instantiation (round-trip) | PASS — covered by test |
| 11 | `clearOnSignOut()` empties the queue; `SessionScopedStore` implemented | PASS |
| 12 | `firebase_messaging` imported only under `core/realtime/` | PASS — verified via repo-wide grep; only `cupid_realtime.dart`, `fcm_transport.dart`, and their tests import it |
| 13 | `backend_user_id_store.dart` half of AC6: sources/caches the real backend `User.id` from a login/register response body, with no Firebase-uid fallback | PASS — `updateFromLoginResponse` reads only `body['id']`; any other shape (e.g. `{'uid': ...}`) throws `RealtimeRoomKeyUnavailableFailure` rather than falling back. `clearOnSignOut()` clears the cached id. |
| 14 | Test coverage in the three listed test files exercises the claimed ACs | PASS — parser (valid/missing-event/missing-id), foreground stream gating, background-handler registration and persistence/ephemeral-skip, queue bound/eviction/round-trip/clear, and store id-cache/no-fallback/clear cases are all present |

## Non-blocking observations (not scored against a stated AC)

- `parseFcmDataMap` calls `jsonDecode` directly on `cupid_payload` when
  present; a message with `cupid_event` present but a malformed
  (non-JSON) `cupid_payload` string would throw a `FormatException` into the
  background isolate instead of being rejected gracefully. The stated AC only
  covers a payload *missing* `cupid_event`, so this is not a scope violation,
  but it is a real gap for a background isolate handler and worth a follow-up
  hardening note (not blocking this slice).

## Out-of-scope, not verified in this slice

- AC6's derivation half (how/where `updateFromLoginResponse` is actually
  wired to the real `POST /auth/login`/`register` response body) and AC7 (the
  existing 404→register fallback in `auth_repository.dart`) — both live in
  files outside this slice, per the handoff note, and belong to slice C.

## Slice Result

All checks in this slice's scope: PASS. No blocking findings identified for
P1, P3, `backend_user_id_store.dart`, or the configuration guide within this
slice's file set.
