# 007_chat-solution.md

## 0. Metadata

- User Story ID: STORY-007
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-007_chat/story_master.md`
- Complexity: L (Story-Class `standard`)
- Referenced Inputs: `story_master.md`; `ux/uiux-spec.md` §1-§10; `req_master.md` (STORY-007 row, OQ4); `data/architecture/system/system_architecture_memory.md` §3-§10 (ADR-006/007, R8/R9); STORY-004 `architecture/solution.md` §2 Downstream Contract Summary + ADR-012d/g/h; frozen backend `backend/src/modules/messages/*`, `backend/src/modules/uploads/*`, `backend/src/modules/users/entities/user.entity.ts`, `backend/src/app.module.ts:45-47`; `mobile/lib/core/realtime/*`, `mobile/lib/core/di/service_locator.dart`, `mobile/lib/features/auth/data/auth_repository.dart:95-109`, `mobile/openapi/cupid_api/lib/src/api/{epic2_communication_messages_api,uploads_api}.dart`, `mobile/pubspec.yaml`
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md`
- Solution Number: 007
- Version: v1.1 (v1.1 adds ADR-013g resolving the P1 send-ack blocker)
- Date: 2026-07-30
- Status: Final

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: Scan Architecture (frozen `messages`/`uploads` contract had to be verified endpoint-by-endpoint before attachment and read-receipt scope could be set)
- Architecture Drivers: AC1-AC5; ADR-007 (Drift read-through cache, no offline write queue); ADR-012d/g/h (STORY-004 realtime contract); A1 (backend frozen); R4 (low-end Android benchmark); R8 (socket auth gap, deferred).
- Architectural invariants:
  1. Chat sends go over the socket only (`SEND_MESSAGE`); `POST /messages` is never used to send, because it fans out nothing (ADR-012h).
  2. Drift is a server-authoritative read-through cache. No table column, field, or code path may represent a pending/queued/unsent message (AC4 is enforced by schema absence, not by convention).
  3. Typing-ghost content never touches Drift or `shared_preferences`. It lives only in Cubit memory for the lifetime of the screen.
  4. Feature code reaches realtime only through `package:cupid_mobile/core/realtime/cupid_realtime.dart` and switches on `RealtimeEvent.name`, never on `transport`.
  5. Zero backend change. Every contract gap below is routed around on the client and escalated, not patched server-side.
- Non-goals: attachments (see §3, decided OUT); `markDelivered` emission (see ADR-013d); anti-ghosting seen-row / Emoji Storm (STORY-008); migrating `PendingEventStore` from `shared_preferences` to Drift (STORY-004 deferral, left as-is to bound blast radius); any dependency on STORY-005 pairing source files.
- Proposed technical direction: a `features/chat/` feature-first slice (Cubit + repository) over two new core seams — `core/database/` (Drift, chat table slice only) and the already-shipped `core/realtime/` coordinator. Message history is a Drift-first read-through with a bounded page-1 REST reconcile wired into the coordinator's `ResyncFetcher`. Typing ghost is a pure in-memory 2-way stream with client-owned throttle, idle, and stale-expiry timers because the backend supplies none.
- Why this fits: it lands ADR-007's F5 persistence seam (`system_architecture_memory.md` §9) as the narrowest possible chat-only slice, consumes STORY-004's frozen `RealtimeCoordinator` surface without reopening it, and localizes all five A1 contract gaps found in §4 in one feature module.

## 2. Downstream Contract Summary

Authoritative for the STORY-007 mobile lane. Downstream lanes read this section, not the whole file.

- Backend contract: **no change**. Consumed as-is:
  - Socket write: `emit('sendMessage', {content, type: 'text', senderId, receiverId})` -> server persists, emits `newMessage` to the `receiverId` room, and **returns the persisted `message` as the socket ack** (`chat.gateway.ts:34-37`). The sender does **not** receive its own `newMessage` (line 35 targets `receiverId` only) — the sender's bubble comes from `emit()`'s awaited ack return value, not from the event stream. `sendMessage` is the **only** client-emitted event that acks; see ADR-013g.
  - Socket write: `emit('typing', {content, senderId, receiverId})` -> partner receives `ghostTyping {content, senderId}`. `emit('stopTyping', {senderId, receiverId})` -> partner receives `ghostStopTyping {senderId}`.
  - Socket write: `emit('markSeen', {senderId, receiverId})` -> original sender receives `messageSeen {seenBy, readAt}`.
  - REST read: `GET /messages?partnerId&page&limit` -> `Message[]`, **newest-first** (`messages.service.ts:25`), page-based, no cursor.
  - REST read: `GET /users/me` -> user row incl. `partnerId`, `displayName`, `isGhostModeEnabled`.
  - REST write: `PATCH /users/me {isGhostModeEnabled}`.
- Frontend contract: N/A (no web surface in this story).
- Mobile contract:
  - New public seam `core/database/cupid_database.dart` exposing `CupidDatabase` (schemaVersion 1) and `MessageDao`. Contract owner: Tech Lead. Later long-history domains (timeline, expenses) add tables here, not in their feature directories — Drift's single-database annotation forces one owner, and `core/` must not import `features/`.
  - `features/chat/data/ChatRepository` is the only chat data entry point. It owns partner-id resolution, Drift reads/writes, the socket write path, and the resync fetcher.
  - `service_locator.dart` supplies `RealtimeCoordinatorImpl(resyncFetcher: ...)` with a `getIt`-deferred closure (§4 ADR-013f).
  - **Amended 2026-07-30 (ADR-013g):** `RealtimeCoordinator.emit` changes from `Future<void>` to `Future<Object?>` and gains a bounded `realtimeAckTimeout`. This is the one sanctioned reopening of the STORY-004 frozen surface; it is additive and source-compatible for all other in-flight stories.
- DevOps / environment contract: none. No env var, secret, port, or third-party credential changes. Runtime registry id `mobile-app` is unchanged.
- Requirement configuration guide impact: **NOT_APPLICABLE**.
- Data model / migration contract: new local-only Drift table `messages`, schemaVersion 1, no migration step (first schema). Columns: `id TEXT PK` (server uuid), `senderId`, `receiverId`, `content`, `type`, `status`, `readAt NULLABLE`, `createdAt`, `cachedAt`. **No** `localId`, `pending`, `queued`, `outbox`, `retryCount`, or `sendState` column — their absence is the AC4 gate.
- API / event / worker queue contract: `CHAT_EVENTS` names are consumed as literal strings mirrored into one client constants file (`system_architecture_memory.md` §8 mitigation). No worker/queue.
- Test and verification expectations: unit tests for the DAO paging read and the mapper; `bloc_test` for `ChatCubit` (send-while-offline, history reconcile, seen transition) and `GhostCubit` (throttle interval, deletion flush, idle emit, stale expiry); widget test for the chat screen thread + composer disabled state and for the `AppShell` entry/gate; `flutter analyze` + `flutter test` + `flutter build apk --debug`. No mobile e2e, no emulator lifecycle, no signing.
- Risk surfaces and verification contract: see §4 Risk Surfaces table.
- OQ constraints downstream lanes must preserve: OQ4/ADR-007 — Drift is read-through and server-authoritative; **no offline write queue may be introduced**, not even a "retry once on reconnect" helper. Fail fast and leave the draft in the composer.

## 3. Scope And Assumptions

- In Scope: text send/receive over the socket (AC1); 2-way typing ghost with the client-owned timing contract in ADR-013b (AC2); Drift-backed read-through message history with page-1 reconcile (AC3); no-outbox fail-fast send (AC4); `partnerId`-driven chat gate plus the discoverable entry point (AC5); the `ghostset` settings screen and the ghost consent model (ADR-013e).
- Out Of Scope:
  - **Attachments — decided OUT (ADR-013a).** Per `ux/uiux-spec.md` §3e second outcome, the composer's `image` icon must be **removed**, not shipped disabled.
  - `markDelivered` emission and any third read-receipt visual (ADR-013d).
  - Partner presence / online dot / last-seen (ADR-013c) — the header chip renders name + avatar only.
  - Partner-unpaired-while-chatting defensive navigation (`ux/uiux-spec.md` §7 / §10.5): the frozen `CHAT_EVENTS` set contains no unpair event and `User` has no unpair signal, so this event can never fire. Dropped as UX §7 itself permits, not implemented speculatively.
  - Any backend change, incl. R8 socket auth and R9 FCM dispatch.
- Assumptions affecting design:
  - STORY-004's `RealtimeCoordinator` is merged and its §2 surface is frozen (verified against `mobile/lib/core/realtime/cupid_realtime.dart`).
  - STORY-005 pairing may not be merged when this story runs. STORY-007 therefore derives paired state from `GET /users/me`.`partnerId` and reads **no** STORY-005 source file.
  - Ephemeral events are dropped while the app is not foreground (ADR-012d/g) — so a `ghostStopTyping` can be lost, which is why the receiver-side stale expiry in ADR-013b is mandatory rather than defensive polish.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| OQ4 | RESOLVED (ADR-007) | Offline write/outbox queue; local send retry; optimistic bubble that survives app restart | Drift read-through cache, server-authoritative; in-session optimistic bubble only | Schema and code contain no pending/queued representation; `emit()` failure surfaces `NetworkUnavailableFailure` copy and leaves the draft in the composer |
| R8 | OPEN, deferred to backend | Production-wide release of chat | Build and ship to non-production/private beta | Client already sends `handshake.auth.token` via STORY-004; this story adds no new auth surface and is not blocked |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning modules: `mobile/lib/features/chat/` (new), `mobile/lib/core/database/` (new), `mobile/lib/core/navigation/app_shell.dart` (edited), `mobile/lib/core/di/service_locator.dart` (edited), `mobile/pubspec.yaml` (edited).
- New boundaries: `core/database/` becomes the single Drift owner for the whole app. Dependency direction is `features/ -> core/`; `core/` never imports `features/`.
- Shared patterns reused: `get_it` composition root (ADR-011g), Cubit-per-surface (D2/ADR-003), `SessionScopedStore` sign-out teardown, adaptive widgets `CupidHeader`/`CupidTabBar` (ADR-004), raw `CupidApi.dio` for endpoints the generated client cannot type (STORY-003 precedent, `auth_repository.dart:95-109`).

### Affected Components And Layers

- Backend: none.
- Frontend: none.
- Mobile: new `features/chat/{data,presentation}`, new `core/database/`, edits to `core/navigation/app_shell.dart`, `core/di/service_locator.dart`, `pubspec.yaml`.
- Data: local-only Drift `messages` table (schemaVersion 1). No server schema change.
- Infrastructure: none.

### Contracts And Integrations

- Contract owner: Tech Lead for `CupidDatabase`/`MessageDao` and the ADR-013b timing constants; backend team for `messages`/`uploads` (frozen, A1).
- Connection pattern: `ChatCubit -> ChatRepository -> {MessageDao (Drift), RealtimeCoordinator (socket), CupidApi.dio (REST)}`. One direction only; no widget touches the coordinator or Dio directly.
- Example payloads:
  - send: `coordinator.emit('sendMessage', {'content': text, 'type': 'text', 'senderId': myId, 'receiverId': partnerId})`
  - receive: `coordinator.events(names: {'newMessage', 'ghostTyping', 'ghostStopTyping', 'messageSeen'})`
  - history: `GET /messages?partnerId=<uuid>&page=1&limit=30` -> newest-first `Message[]`; the repository reverses to ascending before Drift upsert.
- Error / retry / timeout / idempotency / empty-state contract:
  - `emit()` throws `RealtimeNotLiveFailure` when `status != live` (ADR-012h). Mapped to the STORY-003 `NetworkUnavailableFailure` copy per `ux/uiux-spec.md` §5. **No retry, no queue.**
  - REST failures never clear or invalidate the Drift cache — a failed reconcile leaves the cached thread rendered, matching `ux/uiux-spec.md` §3c ("no spinner, no empty-state flash").
  - Idempotency: none exists server-side. All client-side dedupe is by server `Message.id` — Drift `insertOnConflictUpdate` on the `id` primary key, plus the coordinator's own 512-entry LRU (ADR-012d).
  - Empty state: `partnerId != null` and zero cached rows and a completed page-1 fetch returning empty -> first-open empty state (`ux/uiux-spec.md` §3c, copy pending PO per §10.6).

#### ADR-013a — Attachments are OUT of STORY-007 (resolves `story_master.md` open item and UX §10.1)

The frozen contract cannot carry a chat attachment safely. Four independent blockers, any one of which is sufficient:

1. **No attachment field exists.** `Message` (`entities/message.entity.ts`) has only `content: string`. `type` carries the inline comment `'text', 'image', 'video', 'ghost'` but there is no url, mime, size, width/height, or thumbnail column. Shipping images would mean overloading `content` with a URL — an undocumented convention invented by the client, not a contract the frozen backend exposes. A1 forbids adding the field.
2. **Uploaded files are served publicly and unauthenticated.** `app.module.ts:45-47` mounts `ServeStaticModule` at `serveRoot: '/uploads'` over `process.cwd()/uploads` with no guard. Any uploaded image is retrievable by anyone who has the URL. The chat screen carries a standing Level-1 privacy chip — "chỉ nằm trên máy hai người" / "on your devices only" (`ux/uiux-spec.md` §3b, system UX memory §5/§8). Shipping image messages would make that chip a false statement for exactly the most sensitive content in a couples' app. This is a privacy regression, not a missing feature.
3. **The returned URL is unusable off-localhost and is plaintext.** `uploads.service.ts:8-15` builds `http://${HOST}:${PORT}/uploads/<file>` from config, hardcoding the `http` scheme.
4. **The generated client cannot upload.** `uploadsControllerUploadFile` (`uploads_api.dart:32-62`) declares no file, body, or `FormData` parameter — `@UploadedFile()` produces no OpenAPI schema — so it POSTs an empty request. A hand-rolled raw-Dio multipart call would be new untyped surface outside ADR-006.

Decision: attachment scope is OUT. Per `ux/uiux-spec.md` §3e the composer `image` icon is **removed** so no dead affordance ships. Escalate to Scrum Master as an A1 backend gap (attachment field + authenticated media serving + HTTPS URL + OpenAPI file schema) before any later story plans chat or Private Gallery media.

#### ADR-013b — AC2 typing-ghost timing contract (resolves the `story_master.md` / UX §10.2 threshold)

The `ghostTyping` payload is `{content, senderId}` — no server timestamp — so true one-way latency is **not measurable client-side** without a backend change A1 forbids. Additionally `chat.gateway.ts:69` runs `usersService.findOne(senderId)` — an uncached DB read — on **every keystroke event**. A sub-200ms network SLA is therefore neither measurable nor promisable. AC2 is consequently specified as a set of client-owned, unit-testable timing constants plus a target budget, not as a network SLA:

| Constant | Value | Rationale |
|---|---|---|
| Outbound throttle (trailing edge) | 120 ms | Caps a fast typist at ~8 emits/s instead of 10-15, protecting the R4 low-end-Android socket budget while staying well inside the p95 target |
| Outbound immediate flush | on any `content` length **decrease** | Non-negotiable. The receiver derives struck-through deleted runs by diffing successive `content` values; coalescing a short type-then-delete burst inside one throttle window would silently destroy the differentiating mechanic (`ux/uiux-spec.md` §3d) |
| Sender idle -> `stopTyping` | 1200 ms after last keystroke | The backend has no idle timer; without this the partner's ghost bubble never clears |
| Receiver stale-ghost expiry | 6000 ms since last `ghostTyping` | Mandatory, not defensive: ephemeral events are dropped while the app is not foreground (ADR-012d/g), so `ghostStopTyping` **can** be lost |
| Indicator appear target | <= 300 ms from partner's first keystroke | Perceptual budget |
| Keystroke-to-partner-render target | p95 <= 400 ms, p99 <= 800 ms | Target, verified by manual observation only; not an automated gate, for the two reasons above |

Deleted-run derivation is entirely receiver-side: the backend carries no deletion information. The receiver keeps the previous `content`, and on each `ghostTyping` renders the removed tail struck-through in `--ghost` with the 1.3 s `ghostFade`. Escalate to PO: the `ghostset` "under 200ms" copy (`ux/uiux-spec.md` §3d/§4) is unverifiable and should be softened.

#### ADR-013c — Partner presence is not derivable; the header chip omits status

`CHAT_EVENTS` contains no presence/online/offline event and `User` has no `lastSeenAt`. `RealtimeStatus` is the **device's own** connection state. Deriving "partner online" from it would display "partner online" whenever *you* are online — wrong in every case. Decision: the header renders partner avatar + display name with no dot and no status line, which `ux/uiux-spec.md` §6 explicitly permits. Own connection state is surfaced instead as a subtle non-blocking degraded indicator when `status != live`, which also serves AC4. Escalate as a backend gap.

#### ADR-013d — Do not emit `markDelivered`; keep the 2-state receipt visual, persist 3 states

`messages.service.ts` `markAsSeen` and `markAsDelivered` both filter `WHERE status = 'sent'`. So once a row is `'delivered'`, `markAsSeen` matches **nothing** and the row stays `'delivered'` forever — while `messageSeen` is still emitted to the sender. The sender's tick would show double-check live, then regress to single-check after the next history reload. Decision: the client **never emits `markDelivered`**. It emits `markSeen` only, and only while the thread is visible. The 2-state visual (`done` = sent/delivered, `done_all` = seen) from `ux/uiux-spec.md` §3b is kept as final (resolves UX §10.3). Drift still stores all three `status` values so a later third visual needs no migration. Escalate the `WHERE status = 'sent'` defect as an A1 backend gap.

#### ADR-013e — Ghost consent: two authoritative states plus one derived; local opt-in gate

`User.isGhostModeEnabled` is readable only for **self** (`GET /users/me`); there is no endpoint returning the partner's flag. UX §4's per-partner consent readout therefore cannot be made fully truthful. One signal is derivable: `chat.gateway.ts:69-73` silently drops `typing` when the **sender's** flag is false, so receiving any `ghostTyping` proves the partner's flag is true. Absence is ambiguous. State model:

- `off` — my flag false (authoritative).
- `pending` — my flag true, no `ghostTyping` received from the partner this session. Renders UX §4's "waiting for both to agree"; the partner column reads waiting/unknown, never a definite "off".
- `on` — my flag true and at least one `ghostTyping` received this session.

Additionally: the frozen entity defaults `isGhostModeEnabled` to **`true`** (`user.entity.ts:41-42`), so a brand-new user's keystrokes would broadcast without ever seeing a consent surface. Informed consent for keystroke streaming cannot come from a server default the user never saw. The client therefore treats ghost as `off` in the composer until an explicit local opt-in is recorded once per device in `shared_preferences`; opting in then `PATCH`es the flag true. Escalate the default to PO/backend.

#### ADR-013f — `ResyncFetcher` is wired with a `getIt`-deferred closure

`resync()` takes no parameters and the coordinator has no partner scope (`realtime_coordinator.dart:70-79`, default fetcher is a no-op), so chat must supply the page-1 refetch. `ChatRepository` depends on `RealtimeCoordinator`, which would make direct injection circular. `service_locator.dart` passes `resyncFetcher: () => getIt<ChatRepository>().resyncPageOne()`; the closure body resolves lazily at call time, after both singletons exist. It returns `const []` when `partnerId` is null so an unpaired session never throws.

#### ADR-013g — `emit` returns the ack, with a mandatory bounded ack wait (resolves the P1 blocker)

v1.0 §2 assumed the sender's bubble comes from "`emit()`'s awaited ack return
value", but the frozen `RealtimeCoordinator.emit` returns `Future<void>` and
`RealtimeCoordinatorImpl` awaits `SocketTransport.emit` — which does carry the
ack — and discards it. The sender therefore has no path to its own message:
`newMessage` fans out to `receiverId` only. Decision, in two parts.

**1. Widen the return type.** `Future<void> emit(...)` becomes
`Future<Object?> emit(...)`, forwarding the value `SocketTransport.emit`
already returns. `Object?` rather than `dynamic` so call sites must check or
cast instead of silently losing static checking. `SocketTransport` is unchanged.

Widening is chosen over adding an `emitWithAck` member because it is the only
option that is source-compatible in both directions:

- Dart's Left-Top subtype rule gives `void <: Object?`, so an existing
  `Future<void> emit(...)` override on another branch remains valid.
- Callers that discard the result are never broken by a widened return type.
- Adding a member to an `abstract interface class` would break **every**
  existing implementer, including test fakes on branches this story cannot
  inspect.

This is why the decision needs no cross-worktree audit of
STORY-006/008/009/010/011/014/015. Within this worktree, `RealtimeCoordinatorImpl`
is the only implementer and there are no `emit` call sites outside
`core/realtime/`.

**2. Bound the wait — the ack usually never arrives.** `emitWithAckAsync`
completes only when the server invokes the ack callback, and a Nest handler
result of `undefined` produces no ack. Of the events this client emits, only
`handleMessage` returns a value:

| Client emit | Gateway handler returns | Acks? |
|---|---|---|
| `sendMessage` | persisted `message` | **yes** |
| `typing` | `undefined` (incl. the ghost-disabled early return) | no |
| `stopTyping` | `undefined` | no |
| `markSeen` | `undefined` | no |
| `markDelivered` | `undefined` | no (forbidden anyway, ADR-013d) |
| `joinRoom` | `{event, data}` `WsResponse` shape | **unverified — see §7 risk** |

So `emit` returns the ack payload when one arrives within
`realtimeAckTimeout` (5 s, a constructor seam for tests) and resolves to `null`
otherwise. It never throws on timeout: a missing ack is not evidence the write
failed, and throwing would push chat toward the retry/outbox behaviour
OQ4/ADR-007 forbids. The existing unbounded `await _socket.emit(...)` is a
latent defect that only STORY-007 exposes — `GhostCubit` emits `typing` at up
to ~8/s, so without the timeout the first keystroke would deadlock the ghost
path and leak never-completing futures.

Consumer rules: only `ChatRepository.send()` awaits the ack. A `null` ack
produces no fabricated Drift row (that is the forbidden pending representation)
and no rethrow — it triggers exactly one `resyncPageOne()`, a bounded
server-authoritative read already sanctioned by ADR-012g.3, never a re-emit.
`typing`/`stopTyping`/`markSeen` ignore the return value and swallow
`RealtimeNotLiveFailure` — an ephemeral write while offline is a silent no-op.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Realtime send/receive | STORY-004 §2 + `cupid_realtime.dart` | `events(names:)` / `emit()` | `bloc_test` on `ChatCubit` with a fake coordinator: send-while-live, send-while-offline throws and draft is retained, `newMessage` appends | Chat cannot be verified; stop and escalate |
| Local persistence (ADR-007) | `core/database/cupid_database.dart` | `MessageDao` paged read + `insertOnConflictUpdate` | Unit test: newest-first REST page reversed then upserted twice yields no duplicate rows; paged read returns ascending; **schema grep proves no pending/queued column** | AC3/AC4 unverified; stop |
| Typing-ghost timing (AC2) | ADR-013b table | `GhostCubit` timing constants | Unit test with a fake clock: 120 ms throttle, immediate flush on length decrease, 1200 ms idle emit, 6000 ms receiver expiry | AC2 unverified; stop |
| Read-receipt correctness | ADR-013d | `markSeen` only | Unit test asserting no `markDelivered` emit ever occurs | Receipt regression risk; stop |
| Pairing gate (AC5) | `GET /users/me`.`partnerId` | `ChatEntryGate` | Widget test: `partnerId == null` -> chat destination absent and route not reachable | AC5 unverified; stop |
| Discoverability | `core/navigation/app_shell.dart` | `CupidTabBar` destination + `ghostset` header action | Widget test: chat reachable from the shell; `ghostset` reachable from the chat header; `Key('home_screen_ready_signal')` still pumps | Orphaned feature; stop |

### Mobile Lane Handoff

- Mobile responsibilities: all five phases plus verification. Single lane.
- Authoritative inputs: this §2 and §4; `ux/uiux-spec.md` §3a-§3e, §4, §5, §6, §7, §8; ADR-013a-f.
- UX dependencies: reuse STORY-001 tokens and the adaptive header/tab-bar verbatim; introduce no new tokens.
- Guardrails: never import `socket_io_client`/`firebase_messaging` in feature code; never call `POST /messages` to send; never add a queue/outbox/retry; never write ghost content to Drift or prefs; do not read STORY-005 source files; do not touch `pending_event_store.dart`.
- ADR-013g write-scope extension (P1 only): `core/realtime/cupid_realtime.dart`, `core/realtime/realtime_coordinator.dart`, and `test/core/realtime/realtime_coordinator_test.dart` are writable solely to land the `emit` return type and ack timeout. `socket_transport.dart`, `fcm_transport.dart`, and `pending_event_store.dart` stay frozen.

### Backend / DevOps Lane Handoff

- Backend: not required. Four escalations only (ADR-013a, ADR-013c, ADR-013d, ADR-013e default).
- DevOps: not required. Requirement configuration guide update: **NOT_APPLICABLE**.

## 5. Non-Functional Impact

- Security / privacy: attachments excluded specifically to keep the Level-1 privacy claim true (ADR-013a). Ghost content is memory-only. The local opt-in gate (ADR-013e) prevents consent-by-server-default. The Drift file is unencrypted device storage and holds message text — acceptable under system memory §5 (device is untrusted; no tokens in Drift), but tokens must never be written there.
- Reliability / performance: R4 low-end Android is the benchmark. Long threads are paged from Drift, never held whole in Cubit state (system memory §5). The 120 ms throttle bounds socket write volume. Per-keystroke server DB read is a **server-side** cost this client cannot fix — escalated.
- Observability: reuse the coordinator's existing `developer.log` channel. Log ghost timer transitions at debug level only; never log ghost `content`.
- Migration / rollout: Drift schemaVersion 1, no migration. New deps require `flutter pub get` + `build_runner` codegen. Chat ships to non-production/private beta only while R8 is open.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Ship image attachments over `content`-as-URL | UX drew an `image` icon | Rejected | ADR-013a: no contract field, and `/uploads` is served unauthenticated, breaking the Level-1 privacy claim |
| Send via `POST /messages` to sidestep R8 | Endpoint is authenticated | Rejected | ADR-012h: REST does not fan out; the partner receives nothing |
| Emit `markDelivered` for a richer receipt | Backend has the event | Rejected | ADR-013d: backend `WHERE status='sent'` makes a later `markSeen` a no-op, regressing the tick on history reload |
| Derive partner presence from own `RealtimeStatus` | Chip is drawn "online" | Rejected | ADR-013c: shows "partner online" whenever *you* are online |
| Ghost delta protocol instead of full-content resend | Smaller payloads | Rejected | Payload shape is frozen (`content`); receiver-side diffing achieves the same visual |
| `hydrated_bloc` for history instead of Drift | Fewer deps | Rejected | ADR-007: chat is one of the three long-history domains needing real paged queries |
| Migrate `PendingEventStore` to Drift now | STORY-004 deferred it to F5 | Deferred | Out of scope; keeps blast radius on already-verified realtime code at zero |

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Sender never receives its own `newMessage` (gateway targets `receiverId` only) | High — messages appear only on the partner's device if assumed otherwise | Sender's bubble comes from the awaited `emit()` ack return value (ADR-013g widens the return type to carry it); asserted in `ChatCubit` tests |
| Awaiting an ack that never arrives (only `sendMessage` acks) | High — a single awaited `typing` emit would hang forever and deadlock the ghost path | ADR-013g bounded `realtimeAckTimeout` resolving to `null`; unit test asserts a never-acking socket resolves rather than hangs |
| `joinRoom` may never ack: `handleJoinRoom` returns a `WsResponse`-shaped `{event, data}`, which Nest routes to `client.emit('joinedRoom', …)` rather than to the ack callback | **High** — `SocketTransport._handleConnect` awaits `emitWithAckAsync(joinRoom)` before setting `live`, so if this is right the socket never reaches `live` against the real server and all of chat is dead, while every unit test still passes (the STORY-004 fake acks it by hand). ADR-013g's timeout does **not** cover this path | Not fixable inside STORY-007 P1. Must be verified against a running backend during P5 manual verification; escalated to Scrum Master as a STORY-004 follow-up |
| Lost `ghostStopTyping` leaves a stuck ghost bubble | Medium | Mandatory 6 s receiver stale expiry (ADR-013b) |
| Type-then-delete burst swallowed by the throttle | Medium — destroys the differentiating mechanic | Immediate flush on any content-length decrease (ADR-013b) |
| Per-keystroke server DB read (`findOne` on every `typing`) | Medium — server-side latency/load | Client-side 120 ms throttle reduces volume; escalate as a backend gap |
| R8 socket auth gap | High | Unchanged from STORY-004; beta-only release; not a blocker for this story |
| STORY-005 not merged when this story runs | Medium | AC5 gate derives from `GET /users/me`.`partnerId`; zero STORY-005 file reads |
| Drift codegen (`build_runner`) drift/staleness | Medium | Generated `*.g.dart` is committed; `flutter analyze` in the verification phase catches staleness |

## 8. Handoff Notes

- Implementation guardrails: §4 Mobile Lane Handoff.
- OQ-driven constraints to preserve: OQ4/ADR-007 — no offline write queue anywhere, enforced by schema absence.
- Shared contract-first work required: YES — P0 (`core/database/`) produces the `MessageDao` seam every later phase consumes.
- Shared coding plan required: YES — `coding-plan/master-plan.md`, phases P0-P5.
- Memory updates required: recommended but out of this story's write scope. After review, fold into `data/architecture/system/system_architecture_memory.md`: ADR-013a (attachment/media gap + unauthenticated `/uploads`), ADR-013b (ghost timing contract), ADR-013d (`markSeen`-only rule and the `WHERE status='sent'` defect), and the `core/database/` single-Drift-owner rule for timeline/expenses.
- Escalations for Scrum Master (A1 backend gaps unless noted, none blocking this story): (1) no chat attachment field + `/uploads` served unauthenticated over `http`; (2) `markAsSeen`/`markAsDelivered` `WHERE status='sent'` defect; (3) no partner presence signal and no partner-flag read endpoint; (4) `isGhostModeEnabled` defaults to `true`; (5) per-keystroke `usersService.findOne` in `handleTyping`; (6) **not A1 — client-side, STORY-004 follow-up:** `SocketTransport._handleConnect` awaits an ack from `joinRoom`, whose handler returns a `WsResponse`-shaped `{event, data}` that Nest delivers as a `joinedRoom` **event**, not an ack. If confirmed, the socket never reaches `live` against a real backend. Needs a live-backend check and, if confirmed, a dedicated fix story or bug (ADR-013g §7 risk row).
- Open questions / blockers: none blocking. ADR-013g resolves the P1 ack-path blocker. PO follow-ups: `ghostset` "under 200ms" copy (ADR-013b), first-open empty-state copy (UX §10.6), and the ghost server-side default (ADR-013e).
