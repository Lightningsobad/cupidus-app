# 004_realtime_coordinator_spike-solution.md

## 0. Metadata

- User Story ID: STORY-004 (Spike — RealtimeCoordinator)
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-004_realtime_coordinator_spike/story_master.md`
- Complexity: M / Story-Class `standard`
- Referenced Inputs: `story_master.md`, `story_brief.md`, `req_master.md` (D0-D5, R2/R7, breakdown note 2), STORY-003 `architecture/solution.md` §2 + ADR-011a, system memory §7 (ADR-002/006/007/008/009) + §8, backend `chat.gateway.ts`, `chat.constants.ts`, `alarms.gateway.ts`, `alarms.service.ts`, `messages.controller.ts`, `messages.service.ts`, `message.entity.ts`, `alarm.entity.ts`
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md`
- Solution Number: 004
- Version: v1.0
- Date: 2026-07-30
- Status: Final
- UX-Spec: WAIVED -- no operator-facing UI surface, technical spike only

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: Scan Architecture (realtime boundary was unverified; ADR-008 existed as intent only)
- Architecture Drivers: AC1-4, R2 (top risk), R8 (socket auth gap), A1 (backend frozen), D1/ADR-002 (reminders not real alarms), D2 (Bloc), ADR-006 (codegen is REST-only; realtime stays hand-written), ADR-007 (Drift = server-authoritative read-through, no offline write queue), ADR-008 (`RealtimeCoordinator` intent), STORY-003 §2 (`idToken`/`idTokenStream`).
- Invariants: one socket connection process-wide; features consume one merged stream and never learn the transport; zero backend change.
- Non-goals: any backend gateway/auth/FCM-dispatch change (R8 out of scope per `story_master.md`), feature realtime UI (epic-2/epic-3), Drift-backed queue (F5 not built).
- Direction: `RealtimeCoordinator` owns one Socket.IO connection plus the FCM handlers, and exposes one deduped `Stream<RealtimeEvent>` with an explicit `RealtimeStatus`. Never two live sources at once: the socket is authoritative while foreground, FCM only while not foreground, with a persisted pending queue and a REST resync on resume.
- Why this fits: it converts ADR-008 from intent into an implementable contract against the *actual* frozen backend, and localizes every A1/R8 workaround in one `core/realtime/` module instead of spreading it across epic-2 and epic-3.

## 2. Downstream Contract Summary

Authoritative for STORY-007, STORY-008, STORY-009 and every later realtime story.

- Public surface (barrel `package:cupid_mobile/core/realtime/cupid_realtime.dart`; feature code must not import `socket_io_client` or `firebase_messaging` directly):

```dart
enum RealtimeStatus { offline, connecting, live, degraded } // degraded = socket down, FCM path still viable
enum RealtimeTransport { socket, fcmForeground, fcmBackgroundReplay } // diagnostics only
sealed class RealtimeEvent {           // name == exact CHAT_EVENTS / ALARM_EVENTS string
  String get name; String? get id;     // id = server uuid; null for ephemeral events
  Map<String, dynamic> get data; RealtimeTransport get transport; DateTime get receivedAt;
}
abstract interface class RealtimeCoordinator {
  Stream<RealtimeEvent> events({Set<String>? names});  // merged + deduped; broadcast
  Stream<RealtimeStatus> get status;
  Future<void> start();                                // idempotent
  Future<void> stop();
  Future<void> emit(String name, Object? payload);     // socket-only; throws RealtimeNotLiveFailure
  Future<void> resync();                               // manual gap-fill
}
```

- Feature-layer rule (AC1): filter by `names`, switch on `name`, **never** branch on `transport`.
- Backend contract: consumed unchanged. Event names are the frozen `CHAT_EVENTS` / `ALARM_EVENTS` values; no new event, route, or DTO is requested.
- Auth contract consumed from STORY-003 §2: `CupidSession.idToken()` populates `handshake.auth.token`; `CupidSession.idTokenStream` drives re-handshake (ADR-012c). No auth logic is re-derived here.
- **Required new input not supplied by STORY-003**: Socket.IO rooms are keyed by the **backend `User.id`**, not the Firebase uid (`messages.controller.ts:20,33` resolves `findByFirebaseUid(req.user.uid).id`; fanout is `server.to(message.receiverId)`). `CupidSession` exposes uid/email only. The coordinator therefore takes an injected `Future<String?> Function() backendUserId` resolver, cached after sign-in from the `POST /auth/login` response that STORY-003's `AuthRepository` already calls. Epic-2 must not pass the Firebase uid — doing so joins a room nobody emits to and produces a silent zero-event socket.
- Lifecycle contract: the coordinator implements STORY-003's `SessionScopedStore.clearOnSignOut()` — disconnect, clear the seen-id LRU and the pending queue. Without this a second user on the same device inherits the first user's queued events.
- DevOps / environment contract: `firebase_messaging` requires an APNs auth key uploaded to Firebase, iOS `UIBackgroundModes: remote-notification`, and an Android default notification channel. No new `--dart-define` key.
- Requirement configuration guide impact: **REQUIRED** (update the file STORY-003 already made required; add the FCM/APNs section).
- Data model / migration contract: none.
- Test and verification expectations: unit-testable via fake socket/FCM transports; no Playwright, no e2e.
- New dependencies: `socket_io_client`, `firebase_messaging`, `shared_preferences`. No codegen deps (holds ADR-010f/ADR-011).

## 3. Scope And Assumptions

- In Scope: the coordinator abstraction, single-socket ownership, `joinRoom` subscription handshake, `handshake.auth.token` wiring plus rotation policy, two-tier de-duplication, foreground/background transition machine, persisted background queue, REST resync, and the FCM payload contract the backend must later satisfy.
- Out Of Scope: backend gateway auth (R8), backend FCM dispatch (R9, below), feature realtime UI, Drift-backed queue.
- Assumptions: (a) STORY-003 has landed `CupidSession` with `idToken`/`idTokenStream` — verified present at `mobile/lib/core/auth/cupid_session.dart`; (b) the FCM leg is exercised by injecting messages through the **FCM HTTP v1 API** with the existing `backend/service-account.json` credentials, since no backend dispatch exists (ADR-012e) — this is a zero-backend-change validation path and is A1-safe; (c) `backendUserId` is resolvable from the existing `POST /auth/login` response — if it is not, that is a Scrum Master escalation, not grounds to key rooms by Firebase uid.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/core/realtime/` — the only place allowed to import `socket_io_client` or `firebase_messaging`.
- `core/auth/` and `core/network/` are untouched; this story consumes STORY-003 §2 and STORY-002's client as-is.
- Contract owner: Tech Lead for every §2 name. Mobile Developer may not rename them without a new architecture pass.
- Registered as a `get_it` lazy singleton (ADR-011g pattern) and as a `SessionScopedStore`.

### Affected Components And Layers

- Mobile: `core/realtime/cupid_realtime.dart` (barrel), `realtime_coordinator.dart`, `realtime_event.dart`, `socket_transport.dart`, `fcm_transport.dart`, `pending_event_store.dart`, `realtime_failure.dart`; edits to `core/di/service_locator.dart`, `mobile/pubspec.yaml`.
- Infrastructure: iOS `Info.plist` background mode, APNs key in Firebase, Android notification channel.
- Backend / Data: none.

### ADR-012 — RealtimeCoordinator (implements and refines system ADR-008)

#### ADR-012a — One socket for both gateways

`ChatGateway` and `AlarmsGateway` are both declared `@WebSocketGateway({cors:{origin:'*'}})` with **no namespace**, so both bind the default `/` namespace and share one `socket.io` server and one userId-keyed room registry. Exactly one client connection therefore serves chat *and* reminders. The coordinator owns it process-wide. Rejected: a socket per feature — it would double-deliver every event and double server connections for zero benefit.

#### ADR-012b — `joinRoom` is the subscription; `connect` alone delivers nothing

Fanout is `server.to(<User.id>)` and the only room join in the codebase is `ChatGateway.handleJoinRoom` → `client.join(userId)` (`chat.gateway.ts:51-60`). Connect sequence is therefore mandatory two-step: connect → `emit('joinRoom', backendUserId)` → await `joinedRoom` ack → only then `RealtimeStatus.live`. Because the namespace is shared (ADR-012a), this single chat-owned `joinRoom` is also what enables **alarm** delivery. That cross-gateway coupling is load-bearing and must not be "tidied up" into the chat feature. Re-emit `joinRoom` on every reconnect: rooms are per-connection and do not survive a drop.

#### ADR-012c — `handshake.auth.token`, applied at handshake, rotated lazily (AC3)

Build the socket with `OptionBuilder().setTransports(['websocket']).disableAutoConnect().setAuth({'token': await session.idToken()})`. Socket.IO evaluates `handshake.auth` **once per connection** (STORY-003 §2). Policy on `idTokenStream` emit: store the new token for the *next* handshake; do **not** force a reconnect. Rationale: the backend ignores the token today (ADR-012e/R8), so an hourly forced reconnect would drop events and pay resync cost for nothing; and once the gap is fixed the policy is still correct, because auth is checked at handshake and an already-accepted long-lived socket stays accepted. Forward-compat safety net: on `connect_error`, force-refresh via `idToken(forceRefresh: true)`, replace the auth map, and reconnect with capped exponential backoff — so the client behaves correctly the day the backend starts enforcing. The token is never logged (reuse ADR-011d redaction).

#### ADR-012d — Two-tier de-duplication (refines ADR-008)

ADR-008 requires "de-duplication by server-assigned id". Verified against the frozen backend, that is **not universally implementable**: only durable payloads carry a server uuid (`Message.id`, `Alarm.id`, both `@PrimaryGeneratedColumn('uuid')`). Ephemeral payloads carry no id at all — `ghostTyping`/`ghostStopTyping` `{content,senderId}`, `messageSeen` `{seenBy,readAt}`, `messageDelivered` `{deliveredTo,deliveredAt}`, `emojiStormReceived` `{senderId,penalty}`. Resolution — classify at the coordinator boundary:

- **durable** (id present): deduped through a bounded LRU seen-id set (512 entries). These are the only events FCM may ever re-deliver, so this is precisely where double-delivery can occur.
- **ephemeral** (no id): meaningless once backgrounded, so never FCM-delivered and dropped while not foreground. No dedup needed and none possible.

This keeps ADR-008 satisfiable with zero backend change. It is the spike's primary finding and is recorded back into system memory.

#### ADR-012e — Background delivery has no server dispatch in v1 (new risk R9)

Verified: `firebase-admin` is imported only for `verifyIdToken` (`main.ts`, `firebase-auth.strategy.ts`); `admin.messaging()` is never called anywhere. Every push is a stub — `alarms.service.ts:151-157` (`triggerPushNotification` = `console.log`, `getDeviceTokens` commented out), `vibes.service.ts:35`, `ghost-config.service.ts:48` — and there is **no device-token registration endpoint and no device-token column** in `backend/src`. The spike is still valid because its deliverable is the *client* abstraction, and the FCM leg is driven directly through the FCM HTTP v1 API with a payload shaped exactly like the future server payload. But background delivery is **not production-ready**, which blocks D1's "reminder strong enough to be noticed" whenever the app is backgrounded — the entire point of a reminder. Escalate as **R9** alongside R8; needs token-registration endpoint, token storage, and `admin.messaging()` dispatch at the three stub sites.

#### ADR-012f — FCM payload contract the backend must later satisfy

```
data: { cupid_event: '<exact CHAT_EVENTS/ALARM_EVENTS name>',
        cupid_event_id: '<server uuid, == the id the socket would have sent>',
        cupid_payload: '<json-encoded socket payload>' }
notification: { title, body }   // only for user-visible events (D1 reminders)
```

`data` must always be present, so the coordinator can inject into the merged stream even for silent events. Reusing the socket event names means one parser serves both transports. `cupid_event_id` must equal the entity uuid or ADR-012d dedup fails. Android needs `priority: high`; iOS needs `content-available: 1` with `apns-priority: 5`. No Critical Alerts (ADR-002/D1).

#### ADR-012g — Transition machine: never two live sources (AC1, AC2)

One authoritative lifecycle state machine (`AppLifecycleListener`):

| App state | Socket | FCM | Merged-stream source |
|---|---|---|---|
| resumed | connected + joined | `onMessage` → **discarded** | socket (authoritative) |
| inactive/paused/hidden | held for a ~30s grace, then disconnected | `onBackgroundMessage` → persisted to pending queue | none (no listeners) |
| detached / killed | none | background isolate → persisted | none |
| back to resumed | reconnect + re-`joinRoom` | queue drained | queue (deduped), then REST resync |

1. Discarding foreground FCM makes AC2's no-duplicates property **structural**, not luck-dependent; the ADR-012d LRU covers only the grace-window overlap.
2. The ~30s grace exists because iOS fires `inactive`/`paused` for the notification shade, app switcher, and incoming calls; disconnecting on the first signal causes reconnect storms.
3. On resume: drain the queue through the same dedup gate, then run a bounded REST resync. This is the only "no dropped events" guarantee available — the socket has **no replay or `since` cursor**, and `GET /messages` is **page-based, not cursor-based** (`messages.controller.ts:25-35`: `partnerId`, `page`, `limit`), so gap-fill is a page-1 refetch reconciled by `id`, not a delta query. This matches ADR-007 (server-authoritative read-through cache).
4. The background isolate cannot touch `get_it` or in-memory state, and must survive process death. Drift is not built yet (F5/ADR-007), so the spike uses a bounded `SharedPreferences` append-only JSON list; migrate the queue to Drift when F5 lands.

#### ADR-012h — Chat writes stay on the socket despite the auth asymmetry (escalation)

`POST /messages` is Firebase-authenticated and forces `senderId` to the authenticated user (`messages.controller.ts:17-23`), but `MessagesService.create` **emits nothing** (`messages.service.ts:13-16`) — only `ChatGateway.handleMessage` fans out. So "route writes over authenticated REST to sidestep R8" would silently stop the partner from receiving anything in realtime, and cannot be adopted without a backend change A1 forbids. v1 sends chat writes over the socket; `POST /messages` stays the documented offline/fallback path **with the no-fanout caveat recorded**. Escalate with R8.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Merged-stream dedup (AC1, AC2) | ADR-012d | `events()` yields each durable id once | Unit: same `Message.id` injected via both fake transports → exactly 1 event | none (fakes) |
| Foreground/background transition (AC2) | ADR-012g | no duplicate, no drop, order preserved | Manual: background → FCM HTTP v1 inject → foreground → exactly 1 event | R9: no backend dispatch, so injection is manual |
| Socket subscription (AC1) | ADR-012b | `joinedRoom` ack before `live` | Local backend: connect → assert ack + `RealtimeStatus.live` | Backend not runnable → escalate |
| Token in handshake (AC3) | ADR-012c + STORY-003 §2 | `handshake.auth.token` = current id token | Unit: auth map carries `idToken()`; diagnostics never contain it | none |
| Room key correctness | §2 `backendUserId` | backend `User.id`, never Firebase uid | Local backend: partner-sent message arrives | `POST /auth/login` lacks the id → escalate |

### Mobile Lane Handoff

- Responsibilities: all of `core/realtime/`, DI registration, pubspec deps, the prototype harness proving AC1-3.
- Authoritative inputs: this §2 and ADR-012a-h; STORY-003 §2 for auth only.
- Guardrails: no backend edits; no direct `socket_io_client`/`firebase_messaging` import outside `core/realtime/`; do not key rooms by Firebase uid; do not force reconnect on token rotation; do not emit ephemeral events while backgrounded.

### DevOps Lane Handoff

- Responsibilities: APNs auth key in Firebase, iOS `UIBackgroundModes: remote-notification`, Android default notification channel, and the FCM/APNs section of `deployment/configuration-guide.md`.
- Requirement configuration guide update: REQUIRED.
- Guardrails: no Critical Alerts entitlement (ADR-002/D1).

## 5. Non-Functional Impact

- Security / privacy: R8 unchanged — sockets remain impersonable; this story only makes the client ready. `clearOnSignOut()` prevents cross-user leakage of the queued events. Tokens never logged or persisted.
- Reliability: capped exponential backoff on reconnect; the 30s grace prevents churn; bounded LRU and bounded queue prevent unbounded growth.
- Observability: log connection state transitions and dropped-duplicate counts (never payload contents).
- Rollout: additive module; no migration.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Two live sources + dedup only | Simplest to write | Rejected | Makes AC2 depend on dedup completeness, which ADR-012d proves is impossible for ephemeral events |
| Socket per feature | Feature isolation | Rejected | ADR-012a: shared namespace ⇒ duplicate delivery, doubled connections |
| Force reconnect on every token rotation | Strictest freshness | Rejected | Hourly event loss + resync cost; auth is handshake-time only, so it buys nothing (ADR-012c) |
| Writes over authenticated REST | Sidesteps R8 | Rejected | ADR-012h: REST does not fan out; partner would receive nothing |
| Drift-backed background queue | Survives process death cleanly | Deferred | F5/Drift not built; `SharedPreferences` now, migrate later (ADR-012g) |

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| R2 socket/FCM reconciliation | High | This ADR; validated by the prototype gates above |
| R8 socket auth gap (unchanged) | High | Client sends the token now (ADR-012c); backend fix escalated, still blocks epic-2 production |
| **R9 (new)** no backend FCM dispatch, no device-token storage | High | ADR-012e; spike validated via FCM HTTP v1 injection; escalate — background reminders (D1) cannot ship without it |
| Room keyed by wrong id (uid vs `User.id`) | High | §2 `backendUserId` contract + verification gate; silent zero-event failure otherwise |
| Cross-user queue leakage on device sharing | Medium | `SessionScopedStore.clearOnSignOut()` |
| Ephemeral events cannot be deduped | Medium | ADR-012d: never FCM-delivered, dropped when not foreground |

## 8. Handoff Notes

- Implementation guardrails: ADR-012a-h are binding; the §2 API surface is the frozen contract for STORY-007/008/009.
- Shared contract-first work required: `realtime_event.dart` + the barrel must land before any feature consumes the stream.
- Shared coding plan required: YES (Story-Class `standard`), but effectively **one mobile lane** plus one small DevOps configuration phase — there is no second parallel implementation lane, since the backend is frozen and there is no UI surface.
- Memory updates required: YES — ADR-008 refined by ADR-012d/012g, and R9 added to §8.
- Open questions / blockers: R9 escalation (backend FCM dispatch + device-token registration) and confirmation that `POST /auth/login` returns the backend `User.id`.
