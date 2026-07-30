# Phase P1 – Chat Data Layer (repository, partner store, resync wiring)

## 1. Objective

Build the chat data layer over the P0 Drift seam and the frozen
`RealtimeCoordinator`: partner-id resolution, the `CHAT_EVENTS` client mirror,
the socket send path, the Drift read-through, the page-1 REST reconcile, and
the `ResyncFetcher` wiring. No UI in this phase.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-chat-data-layer.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chat/data/**`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/chat/data/**`
  - `mobile/lib/core/realtime/cupid_realtime.dart` (ADR-013g extension, §7A)
  - `mobile/lib/core/realtime/realtime_coordinator.dart` (ADR-013g extension, §7A)
  - `mobile/test/core/realtime/realtime_coordinator_test.dart` (ADR-013g extension, §7A)
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ChatRepository`
  - `ChatPartnerStore`
  - `chat_events.dart` (`CHAT_EVENTS` client mirror)
  - `ResyncFetcher` wiring in `service_locator.dart`
- Shared Interfaces Consumed:
  - `MessageDao` (P0)
  - `RealtimeCoordinator` barrel `package:cupid_mobile/core/realtime/cupid_realtime.dart` (STORY-004, frozen)
  - `CupidApi.dio` (STORY-002/003)
- Risk Surfaces:
  - Realtime send/receive
  - Read-receipt correctness
  - Local persistence (ADR-007)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §2 Downstream Contract Summary
  - consumer contract: `ChatRepository` as listed in `master-plan.md` §3
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2, §4 "Contracts And Integrations", §4 ADR-013d, ADR-013f
  - OQ constraints: `../architecture/solution.md` §3 (OQ4/ADR-007)
  - upstream phase outputs: P0 `MessageDao`
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: chat data access only
  - Source/Test File Count: 4 source (`chat_events.dart`, `chat_partner_store.dart`, `chat_message_mapper.dart`, `chat_repository.dart`) + 1 edit (`service_locator.dart`) + 2 tests
  - Split Required: NO
  - Split Rationale: one cohesive data slice, within one specialist lifecycle

## 2. Required Reads

- `../architecture/solution.md` §2, §3, §4 (Contracts And Integrations, ADR-013d, ADR-013f)
- P0 output `mobile/lib/core/database/daos/message_dao.dart`
- `mobile/lib/core/realtime/cupid_realtime.dart` (frozen public surface)
- `mobile/lib/core/di/service_locator.dart`
- `mobile/lib/features/auth/data/auth_repository.dart` lines 95-109 only, as the precedent for raw `CupidApi.dio` use

## 3. Tasks

- Create `mobile/lib/features/chat/data/chat_events.dart` mirroring the literal event-name strings from `backend/src/modules/messages/chat.constants.ts`. Mirror only the names this story uses: `sendMessage`, `newMessage`, `typing`, `stopTyping`, `ghostTyping`, `ghostStopTyping`, `markSeen`, `messageSeen`. Do not mirror `markDelivered`, `messageDelivered`, `emojiStorm`, or `emojiStormReceived` — the first two are forbidden by ADR-013d and the last two are STORY-008 scope.
- Create `mobile/lib/features/chat/data/chat_partner_store.dart` implementing `SessionScopedStore` (mirror `core/realtime/backend_user_id_store.dart` in shape). It caches `partnerId`, partner `displayName`, and own `isGhostModeEnabled`, populated by `refreshFromServer()` which calls `GET /users/me` through raw `CupidApi.dio` (the generated `epic1_users_api` returns `Response<void>` and cannot expose the body — same limitation `auth_repository.dart:95-109` already works around). `clearOnSignOut()` nulls all three.
- Create `mobile/lib/features/chat/data/chat_message_mapper.dart` converting a raw `Map<String, dynamic>` message payload (identical shape from both `newMessage` socket events and `GET /messages` rows) into the P0 Drift row type. Tolerate a missing `readAt`. Set `cachedAt` to now.
- Create `mobile/lib/features/chat/data/chat_repository.dart` exposing:
  - `Stream<List<Message>> watchThread()` — Drift-backed, ascending, bounded page size (use 30).
  - `Future<void> send(String text)` — `coordinator.emit('sendMessage', {'content': text, 'type': 'text', 'senderId': myId, 'receiverId': partnerId})`, then upsert the **awaited ack return value** into Drift. The gateway emits `newMessage` to `receiverId` only (`chat.gateway.ts:35`), so the sender's own row must come from the ack, never from the event stream. On a `null` ack (timeout) follow the ADR-013g rule in §7A: no fabricated row, no rethrow, one `resyncPageOne()`. Let `RealtimeNotLiveFailure` propagate unchanged — **no catch, no retry, no queue**.
  - `Future<void> loadOlder()` — next page via `GET /messages?partnerId&page&limit` through raw `CupidApi.dio`, reverse the newest-first response to ascending, upsert. Never clear the cache on failure.
  - `Future<List<RealtimeEvent>> resyncPageOne()` — bounded page-1 refetch reconciled by id (ADR-012g.3). Upsert into Drift and return the fetched rows as `GenericRealtimeEvent`s so the coordinator's LRU dedupe sees them. Return `const []` when `partnerId` is null.
  - `Future<void> markSeen()` — `emit('markSeen', {'senderId': partnerId, 'receiverId': myId})` plus `markSeenLocally`. **Never emit `markDelivered`** (ADR-013d: the backend's `WHERE status = 'sent'` filter would then permanently block `markAsSeen` from persisting).
  - A subscription to `coordinator.events(names: {newMessage, messageSeen})` that upserts inbound rows and applies seen state.
- Edit `mobile/lib/core/di/service_locator.dart`: register `CupidDatabase`, `MessageDao`, `ChatPartnerStore`, and `ChatRepository` as lazy singletons; enroll `ChatPartnerStore` and the database in `CupidSession.registerScopedStore` for sign-out teardown; and pass `resyncFetcher: () => getIt<ChatRepository>().resyncPageOne()` into the existing `RealtimeCoordinatorImpl` construction. The closure body must resolve through `getIt` at call time — direct injection would be circular because `ChatRepository` depends on `RealtimeCoordinator` (ADR-013f).
- Write `mobile/test/features/chat/data/chat_message_mapper_test.dart` and `mobile/test/features/chat/data/chat_repository_test.dart` with a fake coordinator and an in-memory database.

## 4. Acceptance Criteria

- `send` on a live coordinator upserts exactly the ack payload; `send` on a non-live coordinator throws `RealtimeNotLiveFailure` and writes nothing anywhere (no Drift row, no prefs key).
- A test asserts the string `markDelivered` appears nowhere in `features/chat/` and that the fake coordinator records no `markDelivered` emit for any repository operation.
- `loadOlder` reverses a newest-first response to ascending before upsert; a failing REST call leaves previously cached rows intact.
- `resyncPageOne` upserts and returns events, and returns `const []` when `partnerId` is null.
- `ChatPartnerStore.clearOnSignOut()` clears `partnerId`, `displayName`, and the ghost flag.
- `flutter analyze` reports no new issues.

## 5. Planned Outputs

- Code: `mobile/lib/features/chat/data/{chat_events,chat_partner_store,chat_message_mapper,chat_repository}.dart`, edited `mobile/lib/core/di/service_locator.dart`
- Contracts: `ChatRepository`, `ChatPartnerStore`, `chat_events.dart` mirror, `ResyncFetcher` wiring
- Requirement configuration guide updates: none
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, data layer (no UI)
- Required levels:
  - unit: mapper, repository read-through, send live/offline, resync dedupe, `markSeen`-only assertion, partner-store teardown
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: no `socket_io_client` or `firebase_messaging` import appears anywhere under `features/chat/`
- Mobile discoverability / navigation integration: N/A — no user-visible surface in this phase; discoverability is P4's gate
- Minimum gates by risk surface:
  - Realtime send/receive: send-live upserts the ack; send-offline throws and persists nothing
  - Read-receipt correctness: no `markDelivered` emit, asserted
  - Local persistence: failed REST reconcile does not clear cached rows
- Required regression or contract coverage: existing `test/core/realtime/` suite must still pass unchanged after the `service_locator.dart` edit
- Evidence format: concise rows recorded by P5 in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/chat/data/ test/core/realtime/`
  - Build/type-check/lint command: `flutter analyze`
  - Required assertion evidence: thrown-failure type on offline send; recorded emit list from the fake coordinator; row ordering after `loadOlder`

## 7. Status

- Status: READY (ack-path blocker resolved by Tech Lead, 2026-07-30 — see §7A)
- Last updated: 2026-07-30

## 7A. Resolved Blocker — Send Ack Path (ADR-013g)

The mobile-dev diagnosis in §7B is confirmed correct. Decision: **Option (a)** —
widen the frozen `RealtimeCoordinator.emit` return type, with a mandatory
bounded ack wait. Full rationale in `../architecture/solution.md` ADR-013g.

### New frozen contract (`core/realtime/cupid_realtime.dart`)

```dart
/// Bounded wait for a socket acknowledgement (ADR-013g). Only
/// `sendMessage` acks; every other client-emitted event resolves to `null`
/// after this duration.
const Duration realtimeAckTimeout = Duration(seconds: 5);
```

```dart
/// Socket-only write path (ADR-012h). Returns the server's acknowledgement
/// payload, or `null` when no ack arrives within [realtimeAckTimeout]
/// (ADR-013g — most `ChatGateway` handlers never ack). An ack timeout is
/// **not** a send failure and must not be retried. Throws
/// [RealtimeNotLiveFailure] when [status] is not [RealtimeStatus.live].
Future<Object?> emit(String name, Object? payload);
```

`RealtimeCoordinatorImpl.emit` keeps its existing not-live guard, then returns
`await _socket.emit(name, payload).timeout(_ackTimeout)` and maps
`TimeoutException` to `null` (logged, not rethrown). `_ackTimeout` is a
constructor seam defaulting to `realtimeAckTimeout` so tests do not wait on a
real 5 s timer. `SocketTransport` is **not** changed — its `emit` already
returns `Future<dynamic>` carrying the ack.

### Why widening is safe for every other in-flight story

- Dart's Left-Top subtype rule makes `void <: Object?`, so `Future<void>` is a
  valid override of `Future<Object?>`. Any test fake on another branch that
  implements `RealtimeCoordinator` with the old signature still compiles.
- Widening a return type never breaks a caller that discards the value, so
  `await coordinator.emit(...)` call sites on other branches are unaffected.
- The rejected alternative — adding a new `emitWithAck` member — would break
  **every** existing implementer, because `abstract interface class` requires
  all members. Widening is strictly the lower-blast-radius change, which is why
  this decision does not depend on inspecting STORY-006/008/009/010/011/014/015
  worktrees.
- Grep of `mobile/lib` and `mobile/test` in this worktree: the only implementer
  is `RealtimeCoordinatorImpl`, and there are zero `RealtimeCoordinator.emit`
  call sites outside `core/realtime/`. STORY-007 is the first consumer.

### The timeout is mandatory, not defensive

`emitWithAckAsync` completes only when the server invokes the ack callback.
`ChatGateway.handleMessage` returns the persisted `message`, so `sendMessage`
acks. `handleTyping`, `handleStopTyping`, `handleMarkSeen`, `handleMarkDelivered`,
and `handleEmojiStorm` return `undefined` on every path, and a Nest handler
result of `undefined` produces no ack. Without the timeout, `await emit('typing',
…)` never completes; `GhostCubit` emits at up to ~8/s, so the current
unbounded `await _socket.emit(...)` would leak never-completing futures and
deadlock the ghost path on the first keystroke. This also bounds the case where
`messagesService.create` throws (Nest emits an `exception` event, no ack).

### P1 consumption rules

- `send(text)` is the only operation that awaits the ack.
  - ack non-null -> map through `ChatMessageMapper` and upsert; the sender's
    bubble comes from this row.
  - ack null -> **do not** fabricate a local row (that is the OQ4/ADR-007
    forbidden pending representation) and **do not** rethrow. Call
    `resyncPageOne()` once so the server-authoritative row is pulled in. This
    is a bounded read (already sanctioned by ADR-012g.3), never a re-emit of
    `sendMessage`.
  - `RealtimeNotLiveFailure` still propagates unchanged (AC4).
- `typing`, `stopTyping`, and `markSeen` must **ignore** the return value and
  must not block on it. Wrap them in a helper that swallows
  `RealtimeNotLiveFailure` — a keystroke or seen-marker emitted while offline is
  a silent no-op, not a user-visible error. Do not use bare `unawaited(...)`:
  `emit` is `async`, so the not-live throw would surface as an unhandled async
  error.

### WriteScope extension granted to P1

- `mobile/lib/core/realtime/cupid_realtime.dart`
- `mobile/lib/core/realtime/realtime_coordinator.dart`
- `mobile/test/core/realtime/realtime_coordinator_test.dart`

Nothing else under `core/realtime/` may be edited. Do not touch
`socket_transport.dart`, `pending_event_store.dart`, or `fcm_transport.dart`.

### Added P1 acceptance criteria

- `emit` returns the ack payload when the fake socket acks.
- `emit` resolves to `null` — does not throw and does not hang — when the fake
  socket never acks, driven by an injected short `ackTimeout`.
- `emit` still throws `RealtimeNotLiveFailure` when status is not `live`, and
  does not reach the socket.
- `send` with a null ack writes no Drift row directly and triggers exactly one
  `resyncPageOne()`; no second `sendMessage` emit ever occurs.
- The existing `test/core/realtime/` suite passes unchanged.

## 7B. Original Blocker Report (mobile-dev, retained for traceability)

- Blocker: `RealtimeCoordinator.emit(String name, Object? payload)`
  (`mobile/lib/core/realtime/realtime_coordinator.dart`, frozen since
  STORY-004 P4 commit `7e71f81`, unchanged on every branch in this repo)
  returns `Future<void>` and discards the socket ack.
  `RealtimeCoordinatorImpl.emit` awaits `SocketTransport.emit` (which does
  return the ack via `emitWithAckAsync`) and throws the value away before
  returning `void`. `../architecture/solution.md` §2/§4/§7 and this phase's
  §3 task text both require `ChatRepository.send()` to "upsert the awaited
  ack return value" because the backend's `newMessage` event fans out only
  to `receiverId`'s room (`chat.gateway.ts:35`), so the frozen contract gives
  the sender no path — event stream or ack — to learn their own sent
  message. Without a fix, a sender's own message never appears in their own
  Drift-backed thread until the next lifecycle-triggered `resync()`, not a
  minor test gap.
  - `core/realtime/**` is outside this phase's declared WriteScope, and the
    interface is explicitly Tech-Lead-owned ("do not rename any member
    without a new architecture pass"), so P1 cannot fix this unilaterally.
  - No in-scope workaround respects existing invariants: bypassing
    `cupid_realtime.dart` to reach `SocketTransport` directly is forbidden;
    a locally-fabricated optimistic Drift row would recreate the
    OQ4/ADR-007-forbidden pending/outbox pattern.
  - Recommended fix (Tech Lead call): widen `RealtimeCoordinator.emit`'s
    return type to `Future<dynamic>` (or add a distinct
    `emitWithAck`/`sendAndAck` member) forwarding
    `SocketTransport.emit`'s already-available ack value, then grant P1 a
    WriteScope extension over `core/realtime/{cupid_realtime.dart,
    realtime_coordinator.dart}` (and their tests) to consume it. No other
    branch has touched this file since STORY-004, so this is a narrow,
    low-risk addition, not a redesign.
  - Everything else in this phase (`chat_events.dart` mirror,
    `ChatPartnerStore`, `ChatMessageMapper`, and the non-`send` parts of
    `ChatRepository` — `loadOlder`, `resyncPageOne`, `markSeen`, the
    `newMessage`/`messageSeen` subscription) has no dependency on this gap
    and remains buildable once this is resolved; none of it has been
    written yet so the phase is reported BLOCKED rather than partially
    committed.
