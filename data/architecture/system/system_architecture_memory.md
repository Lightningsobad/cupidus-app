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
- **ADR-009 — Flutter project root.** Target is `mobile/` at repository root,
  Dart package `cupid_mobile`, feature-first layout
  (`lib/core/`, `lib/design_system/`, `lib/features/<feature>/{data,domain,presentation}/`,
  `mobile/openapi/cupid-api.json`). This is the unambiguous scaffold target for
  Mobile Developer; **no scaffold is created in this mode.**
- **ADR-010 — Single canonical Drift database class.** STORY-007 (chat, P0)
  and STORY-012 (timeline, P1) independently built two competing Drift
  database classes under `mobile/lib/core/database/`: `CupidDatabase`
  (`cupid_database.dart`) and `AppDatabase` (`app_database.dart`). Per
  STORY-015 Tech Lead escalation R-015.1 and its ADR-015.6 tie-break (repo-wide
  `Cupid*` naming convention), **`CupidDatabase` is the single canonical Drift
  owner for the whole app.** `AppDatabase`/`app_database.dart` (STORY-012) must
  be folded into `CupidDatabase` (its `timeline_entries` /
  `timeline_sync_state` tables added as additional tables/DAOs on
  `CupidDatabase`, `service_locator.dart` updated to register only
  `CupidDatabase`) before STORY-012 and STORY-007 merge to the requirement
  integration branch `codex/REQ-001_cupid_flutter_mobile_app-integration`, and
  before STORY-015 P2 (Drift cache, additive) is scheduled. No story may create
  a third database class. Scrum Master owns sequencing this consolidation
  (recorded in STORY-012 and STORY-015 checkpoints); it is a pre-merge/
  pre-integration gate, not a blocker on STORY-007/012/015 P1 work already
  landed.

## 8. Constraints And Transitional Areas

| Area | Constraint / Debt | Impact | Recommendation |
|---|---|---|---|
| Backend contract (A1) | Frozen; client must adapt | High | Escalate to Scrum Master rather than silently working around |
| Socket auth (R8, new) | Gateways unauthenticated/impersonable | High | Escalate before epic-2 reaches production; client sends token now |
| Realtime contract | Not in OpenAPI; drifts silently | Medium | Mirror `chat.constants.ts` into a single client constants file |
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
| 2026-07-30 | Escalation Resolution | ADR-010: canonicalized single Drift database class (`CupidDatabase`) after STORY-007/STORY-012 built competing classes; STORY-012's `AppDatabase` must be folded in before integration merge | STORY-015 Tech Lead escalation R-015.1 (Scrum Master, parallel wave) |
