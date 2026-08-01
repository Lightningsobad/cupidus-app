# System Architecture Memory

## 1. Metadata

- Status: Bootstrap
- Update Type: Research Architecture (Greenfield client against frozen brownfield backend)
- Last Updated: 2026-07-29
- Updated By: tech-lead (Mode: foundation, Flow: bootstrap)
- Related Inputs Reviewed: `data/intake/bootstrap/{bootstrap_master,source_register,business_context,technical_context,conflicts_open_questions}.md`,
  `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`,
  `backend/src/main.ts`, `backend/src/modules/` (listing), `chat.gateway.ts`, `alarms.gateway.ts` (query-first)

## 2. System Baseline

- Posture: two-tier system — a **new Flutter client** (greenfield) consuming an
  **existing NestJS backend** (brownfield, frozen contract A1). No new server tier.
- Runtime environments: iOS + Android app; NestJS API on `PORT` (default `3000`),
  no global route prefix; Swagger UI `/api-docs`, spec JSON `/api-docs-json`.
- Shared principles:
  - The client adapts to the backend. No story may require a backend contract
    change without explicit escalation (A1).
  - The server is the source of truth. Client persistence is cache, never a
    second write-authority.
  - One widget tree, no per-platform screen forks.

## 3. Shared Boundaries

| Module / Service | Responsibility | Notes |
|---|---|---|
| `backend/` (NestJS) | All business logic, persistence, auth verification | Frozen (A1). 16 modules; `admin` + `data-export` out of mobile scope |
| Flutter app (`mobile/`) | All 6 epics' UI, client state, cache, realtime session | Target root confirmed in ADR-009; does not exist yet |
| Generated API client | Typed REST access only | Generated from OpenAPI; never hand-edited |
| `RealtimeCoordinator` | Single owner of Socket.IO session + FCM routing | Hand-written; **not** covered by OpenAPI |
| Local store (Drift) | Read cache for chat/timeline/expenses | Read-through only; see ADR-007 |
| `cupid-mobile-design/` | UX source of truth | Read-only, never edited |

## 4. Shared Data And Contracts

- Data ownership: backend owns all durable data. The client owns only session,
  cache, and view state.
- REST contract: OpenAPI at `/api-docs-json`, title `Cupid App Backend
  Integration API` v1.0, ~59 endpoints. Bearer scheme id `firebase-jwt` (JWT).
- **Realtime contract is NOT in OpenAPI.** Two Socket.IO gateways, default
  namespace, `cors.origin: '*'`, rooms keyed by **user id**:
  - Chat (`messages`): `JOIN_ROOM`, `SEND_MESSAGE` -> `NEW_MESSAGE`, `TYPING` ->
    `GHOST_TYPING`, `STOP_TYPING`, `MARK_SEEN` -> `MESSAGE_SEEN`,
    `MARK_DELIVERED` -> `MESSAGE_DELIVERED`, `EMOJI_STORM` -> `EMOJI_STORM_RECEIVED`.
    Event name constants live in `backend/src/modules/messages/chat.constants.ts`.
  - Alarms/reminders: `SET_ALARM`, `CONFIRM_ALARM`, `STOP_ALARM` ->
    `NEW_ALARM_REQUEST`, `ALARM_SCHEDULED`, `TRIGGER_ALARM`,
    `ALARM_FULLY_STOPPED`, `ALARM_STOPPED_BY_PARTNER`.
- **Chat send is socket-only** (`SEND_MESSAGE`), not REST. Epic-2 is therefore
  hard-blocked on `RealtimeCoordinator`, not merely enhanced by it.
- No idempotency key, client message id, or dedupe field exists anywhere in the
  backend (verified by search). This directly constrains ADR-007.
- Contract versioning: vendor the fetched spec into the repo
  (`mobile/openapi/cupid-api.json`) and regenerate deliberately. Codegen must not
  depend on a live backend, which needs `service-account.json` to boot.

## 5. Shared Security And Operations

- Authentication: Firebase Auth. REST sends `Authorization: Bearer <Firebase ID
  token>`; a refresh interceptor renews on 401 and retries once.
- **Socket auth gap (accepted risk, escalation required):** both gateways use
  mock auth. `handleConnection` verifies nothing and `JOIN_ROOM` joins any
  supplied `userId`, so any client can impersonate any user over the socket. The
  client cannot fix this. Clients must still send the Firebase token in
  `handshake.auth.token` so the app is already compatible when the backend adds
  verification. See R8.
- Secrets: no API keys in the Flutter bundle beyond Firebase client config.
  Tokens in platform secure storage, never in `hydrated_bloc`/Drift.
- Trust zones: device is untrusted; all authorization decisions stay server-side.
- Observability / reliability: client crash + error reporting; realtime layer
  must expose an explicit connection state to the UI rather than failing silently.
- Performance posture: low-end Android is the benchmark target (R4). Long lists
  must be paged from Drift, not held whole in bloc state.

## 6. Approved Shared Patterns

| Pattern | Why Approved | Source |
|---|---|---|
| Bloc for rituals/realtime, Cubit for CRUD screens | Matches interaction complexity without over-modelling | D2 / ADR-003 |
| `freezed` states + `get_it`/`injectable` DI | Immutable state, testable seams, `bloc_test` | D2 / ADR-003 |
| `ThemeExtension` (platform x theme) + 4 named adaptive widgets | Single widget tree, no screen forking across 31 screens | D3 / ADR-004 |
| Pragmatic feature-first, single package | Avoids premature melos/Pigeon split | D4 / ADR-005 |
| Generated OpenAPI client for REST | Removes hand-written REST layer, locks contract | D5 / ADR-006 |
| Drift read-through cache; `hydrated_bloc` for ephemeral state | Long-history domains need real queries + paging | ADR-007 |
| Golden tests for atoms + ~6 representative screens | Cheapest guard against UI drift (R5) | R5 |

## 7. Architecture Decisions (ADR)

- **ADR-001 (D0)** Client is Flutter for iOS + Android. The native SwiftUI client
  in `_bmad-output/planning-artifacts/architecture.md` is SUPERSEDED; cite D0, do
  not reconcile the two documents.
- **ADR-002 (D1)** No system-level alarms and no Critical Alerts entitlement. v1
  ships strong notifications only; epic-3 wording is "nhắc nhở đồng bộ". The
  backend `alarms` module and its gateway are still the transport — the naming
  mismatch is backend-internal and must not leak into UI copy.
- **ADR-003 (D2)** Bloc/Cubit as above, with lint-enforced conventions (R6): one
  bloc per feature surface, no cross-bloc reads, side effects in repositories.
- **ADR-004 (D3)** Adaptive UI via `ThemeExtension` over platform x theme; four
  named adaptive widgets; no per-screen platform branching.
- **ADR-005 (D4)** Single Flutter package, feature-first. Defer melos and Pigeon.
- **ADR-006 (D5) — scoped.** Generated client covers **REST only**. It does not
  remove the realtime data layer, which stays hand-written and untyped by
  codegen. Confirmed with this scope limit; the "removes most hand-written data
  layer" consequence in `technical_context.md` holds for REST and not for sockets.
- **ADR-007 (OQ4 — RESOLVED, confirms the working assumption with a bound).**
  Adopt **Drift** for `chat`, `timeline`, and `expenses`; `hydrated_bloc` for
  small ephemeral state only. Two bounds: (a) Drift is a **read-through cache**,
  server-authoritative, and (b) **no offline write/outbox queue in v1** — the
  backend exposes no idempotency or client-message-id field, so a replay queue
  cannot be made duplicate-safe without a backend change that A1 forbids. Offline
  writes fail fast with an explicit retry affordance. Rationale for not choosing
  `hydrated_bloc`-only: it serializes whole state on every emit, which regresses
  long chat/timeline/expense histories on low-end Android (R4) and cannot support
  paging or expense aggregation.
- **ADR-008** `RealtimeCoordinator` is the single owner of the Socket.IO
  connection and FCM foreground/background delivery, exposing one merged event
  stream plus an explicit connection state. Features never touch a socket
  directly. It must handle the double-delivery case (socket + FCM for the same
  event) with de-duplication by server-assigned id.
  - **Refined by STORY-004 ADR-012** (`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-004_realtime_coordinator_spike/architecture/solution.md`),
    which is the authoritative contract for STORY-007/008/009. Three
    corrections found by verifying this intent against the frozen backend:
    (a) blanket "de-duplication by server-assigned id" is **not** implementable
    — only durable payloads carry a uuid (`Message.id`, `Alarm.id`); ephemeral
    events (`ghostTyping`, `messageSeen`, `messageDelivered`,
    `emojiStormReceived`) carry none, so dedup is two-tier and ephemeral events
    are never FCM-delivered; (b) duplicates are prevented **structurally** by
    never having two live sources — the socket is authoritative while
    foreground and foreground FCM is discarded — not by dedup alone;
    (c) `ChatGateway` and `AlarmsGateway` share the default namespace and
    userId-keyed rooms, so one connection plus one `joinRoom` (keyed by the
    backend `User.id`, **not** the Firebase uid) serves both chat and reminders.
  - **Amended 2026-07-30 by STORY-007 ADR-013g** — the shared
    `RealtimeCoordinator.emit` contract is now
    `Future<Object?> emit(String name, Object? payload)`: it returns the socket
    ack payload, or `null` after `realtimeAckTimeout` (5 s). Reason: only
    `ChatGateway.handleMessage` returns a value, so only `sendMessage` acks;
    `typing`, `stopTyping`, `markSeen`, `markDelivered`, and `emojiStorm`
    return `undefined` and never ack, and an unbounded `await` on those would
    hang forever. The ack is the sender's **only** path to its own message
    because `newMessage` fans out to `receiverId` only. A `null` ack is not a
    send failure and must never be retried or queued (OQ4/ADR-007) — recover
    with a bounded server-authoritative refetch instead. Widening rather than
    adding an `emitWithAck` member is deliberate: `void <: Object?` keeps every
    existing override and call site source-compatible, whereas a new interface
    member breaks all implementers.
- **ADR-009 — Flutter project root.** Target is `mobile/` at repository root,
  Dart package `cupid_mobile`, feature-first layout
  (`lib/core/`, `lib/design_system/`, `lib/features/<feature>/{data,domain,presentation}/`,
  `mobile/openapi/cupid-api.json`). This is the unambiguous scaffold target for
  Mobile Developer; **no scaffold is created in this mode.**
- **ADR-010 — canonical mobile Drift owner (resolves STORY-015 R-015.1).** The
  Flutter app has exactly **one** Drift database class:
  **`CupidDatabase`** in `mobile/lib/core/database/cupid_database.dart`, backing
  file `cupid.sqlite`. STORY-012's `AppDatabase`
  (`mobile/lib/core/database/app_database.dart`, `cupid_app_database.sqlite`) is
  **SUPERSEDED** and must be folded into `CupidDatabase`.
  - Rationale (structure first, naming last): (a) `CupidDatabase` already uses
    the multi-domain layout ADR-007 F5 requires for three domains —
    `@DriftDatabase(tables: [...], daos: [...])` with `tables/` and `daos/`
    sub-directories — whereas `AppDatabase` declares its tables inline in the
    database file and hangs query methods directly on the database class, which
    does not scale past one domain and would need rewriting the moment chat,
    timeline, and expenses coexist; (b) `CupidDatabase` is the one that already
    declares single-owner status and anticipates timeline/expenses registration;
    (c) the repo-wide `Cupid*` convention only confirms the same answer.
  - **Mandatory carry-over — the fold is not a delete.** `AppDatabase`
    implements `SessionScopedStore` (`mobile/lib/core/auth/cupid_session.dart`)
    with `clearOnSignOut()`, which is STORY-012 AC4 / D-012-5: a second user on
    the same device must never read the previous couple's cached content. That
    is a cross-cutting privacy contract, not a timeline detail. The canonical
    class **must** implement `SessionScopedStore` and clear **every** cached
    domain table (messages, timeline, expenses, and any later domain). A fold
    that drops it is a privacy regression and must fail review.
  - Fold steps, owned by STORY-012 at merge time: (1) move `TimelineEntries` and
    `TimelineSyncState` into `mobile/lib/core/database/tables/timeline_tables.dart`;
    (2) move `watchFirstPage`, `replaceFirstPage`, and `lastSyncedAt` into
    `mobile/lib/core/database/daos/timeline_dao.dart` as a `@DriftAccessor` DAO
    matching `daos/message_dao.dart`; (3) register the tables and DAO in the
    `CupidDatabase` annotation and bump `schemaVersion`; (4) move
    `clearOnSignOut()` onto `CupidDatabase` and extend it to all cached tables;
    (5) repoint DI and every `AppDatabase` reference and test to
    `CupidDatabase`, delete `app_database.dart` / `app_database.g.dart`, rerun
    codegen.
  - Migration: **none required.** Both classes are `schemaVersion 1`, nothing is
    released, and ADR-007 makes the database a disposable read-through cache, so
    destructive recreate is acceptable and the orphaned
    `cupid_app_database.sqlite` file can simply be abandoned.
  - Standing rule: every new long-history domain registers **additively** into
    `CupidDatabase`. A second `@DriftDatabase` class anywhere in `mobile/lib/` is
    a review blocker.

## 8. Constraints And Transitional Areas

| Area | Constraint / Debt | Impact | Recommendation |
|---|---|---|---|
| Backend contract (A1) | Frozen; client must adapt | High | Escalate to Scrum Master rather than silently working around |
| Socket auth (R8, new) | Gateways unauthenticated/impersonable | High | Escalate before epic-2 reaches production; client sends token now |
| FCM dispatch (R9, new) | No server-side FCM send and no device-token storage anywhere; every push is a `console.log` stub (`alarms.service.ts` `triggerPushNotification`, `vibes.service.ts`, `ghost-config.service.ts`). `firebase-admin` is used for `verifyIdToken` only | High | Background delivery is not production-ready; epic-3 reminders (D1) cannot fire while backgrounded. Needs token-registration endpoint + storage + `admin.messaging()` at the three stub sites. Escalate with R8 |
| Chat write fanout asymmetry | `POST /messages` is authenticated but emits nothing; only `ChatGateway.handleMessage` fans out | High | Do not "fix" R8 by moving writes to REST — the partner would receive nothing (STORY-004 ADR-012h) |
| Realtime contract | Not in OpenAPI; drifts silently | Medium | Mirror `chat.constants.ts` into a single client constants file |
| Socket ack availability | Only `sendMessage` acks; handlers returning `undefined` produce no ack (STORY-007 ADR-013g) | High | Never `await` a socket emit without a bounded timeout. `RealtimeCoordinator.emit` enforces this centrally |
| `joinRoom` ack assumption (unverified) | `handleJoinRoom` returns a `WsResponse`-shaped `{event, data}`, which Nest delivers as a `joinedRoom` **event**, not an ack — but `SocketTransport._handleConnect` awaits `emitWithAckAsync(joinRoom)` before reporting `live` | High | If confirmed, the socket never reaches `live` against a real backend while all unit tests pass (the STORY-004 fake acks by hand). Verify against a running backend before any epic-2/epic-3 realtime story ships |
| Runnable foundation | No Flutter project, no root scripts, no runtime registry, zero git commits | High | DevOps + Mobile Developer bootstrap steps; ADR-009 gives the target |
| Runtime registry ids | `data/devops/system/runtime-command-registry.json` absent | Medium | DevOps to create `backend-api` and `mobile-app` ids |
| Backend boot dependency | `service-account.json` required to start | Medium | Vendor OpenAPI spec so codegen never needs a live backend |
| libsodium FFI (R3) | Dual-platform build unproven | Medium | Spike before epic-4 |

## 9. Confirmed Foundation Build Order

Confirmed from `technical_context.md` with two adjustments (F0 and F5 added).

0. **F0 Runnable foundation** — repo initial commit, `mobile/` Flutter scaffold
   (ADR-009), root scripts, runtime registry, backend wiring. Prerequisite for
   all story worktrees (`git-story-boundary.sh` needs a `BaseHead`).
1. **F1 `design_system`** — tokens (platform x theme) + i18n ARB. First
   shared-foundation story, before any feature (R7). OQ5 scope is Product Owner's.
2. **F2 `api_client`** — generate from `/api-docs-json`, vendor the spec (D5).
3. **F3 auth** — Firebase + refresh interceptor + secure token storage.
4. **F4 `RealtimeCoordinator` spike** — R2, highest risk. Keep in the foundation
   block; do not defer, since chat send is socket-only.
5. **F5 local persistence** — Drift schema for chat/timeline/expenses (ADR-007),
   before epic-2.
6. **F6 feature epics 1 -> 6**, excluding `admin` and `data-export`.

## 10. Story Guidance

- Defaults: feature-first placement, Cubit unless the surface is a ritual or
  realtime flow, generated client for REST, `RealtimeCoordinator` for sockets,
  Drift for the three long-history domains only.
- Verification contract per surface — minimum gate / blocker:
  - Design system: golden tests for atoms + ~6 representative screens / visual drift.
  - API client: regeneration is reproducible from the vendored spec / spec drift.
  - Auth: unit tests for refresh-on-401 and single retry / token leak into cache.
  - Realtime: connection-state and de-duplication tests / duplicate or lost events.
  - Persistence: paged-read tests / any offline write path appearing in v1.
- Unstable/transitional: realtime layer and socket auth. Re-check this memory
  before any epic-2 or epic-3 story.
- Update this memory when: a backend contract change is approved (A1 escalation),
  socket auth changes, OQ4/ADR-007 bounds are revisited, or ADR-009 layout moves.

## 11. Update History

| Date | Update Type | Change | Source Story / Initiative |
|---|---|---|---|
| 2026-07-29 | Research Architecture | Created baseline: ADR-001..009, OQ4 resolved, socket auth gap R8 raised, foundation order confirmed | Bootstrap synthesize-foundation (REQ-001) |
| 2026-07-30 | Scan Architecture | ADR-008 refined by ADR-012 (two-tier dedup, no-two-live-sources, shared namespace + `User.id` room key); R9 (no backend FCM dispatch) and chat write fanout asymmetry added to §8 | REQ-001 / STORY-004 RealtimeCoordinator spike |
| 2026-07-30 | Coding Plan (blocker resolution) | ADR-013g: shared `RealtimeCoordinator.emit` widened to `Future<Object?>` returning the socket ack, with a mandatory 5 s `realtimeAckTimeout`; socket-ack-availability and unverified `joinRoom` ack rows added to §8 | REQ-001 / STORY-007 chat P1 |
| 2026-07-30 | Decision | ADR-010 added: `CupidDatabase` (`mobile/lib/core/database/cupid_database.dart`) is the single canonical Drift owner; STORY-012's `AppDatabase` is SUPERSEDED with a mandatory `SessionScopedStore`/`clearOnSignOut` carry-over and explicit fold steps | REQ-001 / STORY-015 R-015.1 |
