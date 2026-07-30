# Phase P2 – Socket Transport, joinRoom Handshake, Room Key

## 1. Objective

Own exactly one Socket.IO connection: connect with the Firebase token in `handshake.auth.token` (AC3), complete the mandatory `joinRoom` subscription before reporting `live` (AC1), and resolve the room key from the backend `User.id`.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-socket-transport.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO (single mobile writer inside `core/realtime/`)
- Write Scope:
  - `mobile/lib/core/realtime/socket_transport.dart`
  - `mobile/lib/core/realtime/backend_user_id_store.dart`
  - `mobile/lib/features/auth/data/auth_repository.dart`
  - `mobile/test/core/realtime/socket_transport_test.dart`
  - `mobile/test/core/realtime/backend_user_id_store_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - internal socket transport with an injectable socket factory (so P5 can drive a fake)
  - `BackendUserIdStore` behind the injected `Future<String?> Function() backendUserId` resolver from `../architecture/solution.md` §2
- Shared Interfaces Consumed:
  - P0 barrel: `RealtimeEvent`, `RealtimeStatus`, typed failures
  - STORY-003 `CupidSession.idToken()` / `idTokenStream` (`mobile/lib/core/auth/cupid_session.dart:63,70`) — auth only, do not re-derive auth logic
- Risk Surfaces:
  - Socket subscription (AC1)
  - Token in handshake (AC3)
  - Room key correctness
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` ADR-012a, ADR-012b, ADR-012c, §2 `backendUserId`
  - consumer contract: the coordinator (P4) sees `live` only after the `joinedRoom` ack
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC3
  - architecture: `../architecture/solution.md` ADR-012a/b/c, §2 auth + room-key contracts
  - OQ constraints: R8 — the backend ignores the token today; send it anyway, change nothing on the backend
  - upstream phase outputs: P0 public surface
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: one authoritative socket connection plus its subscription key
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` ADR-012a, ADR-012b, ADR-012c, §2
- `master-plan.md` §3, §3A, §6
- `mobile/lib/core/auth/cupid_session.dart` (token surface only)
- `mobile/lib/features/auth/data/auth_repository.dart`

## 3. Tasks

- Build the socket exactly per ADR-012c: `OptionBuilder().setTransports(['websocket']).disableAutoConnect().setAuth({'token': await session.idToken()})`. Accept an injectable socket factory so tests never open a real connection.
- Implement the mandatory two-step connect sequence (ADR-012b): connect -> `emit('joinRoom', backendUserId)` -> await the `joinedRoom` ack -> only then report `RealtimeStatus.live`. Re-emit `joinRoom` on every reconnect; rooms are per-connection and do not survive a drop.
- One connection serves both gateways (ADR-012a). Do not create a second socket and do not move the `joinRoom` call into a feature: the chat-owned join is also what enables alarm delivery, and that coupling is load-bearing.
- Token rotation policy (ADR-012c): on `idTokenStream` emit, store the new token for the *next* handshake only. Do **not** force a reconnect. On `connect_error`, force-refresh via `idToken(forceRefresh: true)`, replace the auth map, and reconnect with capped exponential backoff. Never log the token (reuse the ADR-011d redaction convention).
- Create `BackendUserIdStore` in `core/realtime/`, implementing `SessionScopedStore` (`mobile/lib/core/auth/cupid_session.dart:10`), holding the cached backend `User.id`. Keep `core/auth/` untouched: realtime owns the room key, and `features/auth` writes into it.
- Populate it from `AuthRepository._syncBackendProfile()`. `POST /auth/login` returns the user entity, but the generated client types the response `Response<void>` (`mobile/openapi/cupid_api/lib/src/api/epic1_auth_api.dart:32`), so read the body from the shared `Dio` instance that already carries the interceptor pipeline rather than the typed call. Preserve the existing behavior exactly: `HttpStatusFailure` 404 still falls back to `POST /auth/register`, and callers still only ever see `CupidApiFailure` / `CupidAuthFailure`. Do not regenerate the client, do not change the OpenAPI spec, do not touch the backend.
- If the id is absent from the body, raise the typed room-key failure from P0. Never fall back to the Firebase uid — that joins a room nobody emits to and produces a silent zero-event socket.

## 4. Acceptance Criteria

- The built option map carries the current `idToken()` under `auth.token`, and no test output or log line contains the token value.
- A fake socket observes strictly `connect` -> `joinRoom(<backend User.id>)` -> ack -> `live`; no event is surfaced before the ack.
- A simulated reconnect re-emits `joinRoom`.
- An `idTokenStream` emit does not trigger a reconnect, but the next handshake uses the new token.
- `connect_error` triggers a force-refreshed token and a backoff reconnect whose delay is capped.
- The room key resolves to the backend `User.id`; a missing id raises the typed failure and never yields the Firebase uid.
- The existing 404 -> register fallback in `AuthRepository` still passes its tests.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/core/realtime/{socket_transport,backend_user_id_store}.dart`, edited `mobile/lib/features/auth/data/auth_repository.dart`
- Contracts or schemas: `backendUserId` resolver contract
- Requirement configuration guide updates: none
- Notes or evidence: none beyond unit tests

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/lib/core/realtime/` and `mobile/lib/features/auth/data/`
- Required levels:
  - unit: handshake auth map, joinRoom ordering and ack gating, reconnect re-join, token-rotation policy, capped backoff, room-key resolution and failure path
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: no real socket opened in tests; no token in any log/diagnostic string; `socket_io_client` imported only under `core/realtime/`
- Minimum gates by risk surface:
  - Socket subscription (AC1): ack observed before `live`
  - Token in handshake (AC3): token present in the auth map, absent from logs
  - Room key correctness: backend `User.id` only
- Required regression or contract coverage: existing `AuthRepository` login/register-fallback tests still pass
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/core/realtime/ test/features/auth/`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: recorded emit order and the resolved room-key value

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
