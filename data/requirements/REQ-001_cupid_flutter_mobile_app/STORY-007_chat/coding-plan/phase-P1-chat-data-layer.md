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
  - `Future<void> send(String text)` — `coordinator.emit('sendMessage', {'content': text, 'type': 'text', 'senderId': myId, 'receiverId': partnerId})`, then upsert the **awaited ack return value** into Drift. The gateway emits `newMessage` to `receiverId` only (`chat.gateway.ts:35`), so the sender's own row must come from the ack, never from the event stream. Let `RealtimeNotLiveFailure` propagate unchanged — **no catch, no retry, no queue**.
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

- Status: NOT_STARTED
- Last updated: 2026-07-30
