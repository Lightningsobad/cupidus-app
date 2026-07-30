# Story Master: STORY-004 Spike — RealtimeCoordinator (Socket.IO + FCM)

Status: PENDING
Complexity: M (spike/technical validation, not a user-facing feature)
Epic: Foundation
Story-Class: standard
Requirement: REQ-001

## Depends On
- STORY-003 (needs the Firebase token to send in `handshake.auth.token` for
  forward-compat, per R8).

## User Story
As the Flutter codebase, it needs one coordinated realtime layer that
reconciles Socket.IO (foreground) and FCM (background) delivery paths so
every realtime feature (chat, anti-ghosting, reminders) builds on a single
proven mechanism instead of each inventing its own.

## In Scope
- Spike/prototype validating a `RealtimeCoordinator` abstraction that
  unifies the foreground (Socket.IO connected) and background (FCM push)
  delivery paths for the same logical event stream.
- Forward-compatible auth: send the Firebase token via
  `handshake.auth.token` on connect (client-side mitigation for R8 — backend
  gateway itself has no auth check yet, see `requirements.md` cross-story
  notes; this does not fix the backend gap, only makes the client ready for
  when it is fixed).
- Validation criteria for reconnect/foreground-background transition
  behavior (app backgrounded mid-socket-session, event still arrives via
  FCM; app foregrounded, socket resumes without duplicate/missed events).

## Out of Scope
- Any backend gateway/auth fix (R8) — that is a backend-team decision per
  `conflicts_open_questions.md`, not this spike's deliverable.
- Feature-specific realtime UI (chat typing-ghost, anti-ghosting, reminders)
  — those are epic-2/epic-3 stories that consume this coordinator.

## Acceptance Criteria
1. A working prototype demonstrates a single event reaching the app whether
   delivered via active Socket.IO connection or FCM push, without the
   feature layer needing to know which path was used.
2. Foreground-to-background and background-to-foreground transitions do not
   duplicate or drop events in the prototype's test scenarios.
3. Socket connection sends the Firebase token in `handshake.auth.token`.
4. Findings and the resulting API surface (from the Flutter feature layer's
   point of view) are documented for Tech Lead's ADR — this spike's output
   feeds the coding-plan for epic-2/epic-3, it does not ship as end-user
   functionality itself.

## Open Items For Downstream Roles
- Tech Lead: this is risk R2 (impact high) — the ADR should record the
  chosen reconciliation strategy so epic-2 (STORY-007, STORY-008) and
  epic-3 (STORY-009) can build directly on it.
- Escalation reminder: backend Socket.IO auth gap (R8,
  `chat.gateway.ts:39-57`) is not fixed by this spike; production readiness
  of chat still needs a separate decision before epic-2 ships to production.

## Architecture Pass (2026-07-30)

- Architecture solution: `architecture/solution.md` (ADR-012a-h, refines system ADR-008). AC1-4 all have a named contract and verification gate.
- UX-Spec: WAIVED — no operator-facing UI surface, technical spike only.
- Implementation shape: shared coding plan required (Story-Class `standard`),
  but effectively **one mobile lane** plus one small DevOps configuration
  phase; backend is frozen and untouched, and there is no UI surface.
- Configuration guide: REQUIRED (FCM/APNs section — APNs auth key, iOS
  `UIBackgroundModes: remote-notification`, Android notification channel).
- New escalations raised for Scrum Master (neither blocks this spike):
  - **R9** — backend has **no** server-side FCM dispatch and no device-token
    storage; every push is a `console.log` stub and `firebase-admin` is used
    for `verifyIdToken` only. The spike is still validatable by injecting FCM
    messages through the FCM HTTP v1 API (zero backend change, A1-safe), but
    background reminders (D1, epic-3) cannot ship until the backend adds
    token registration, storage, and `admin.messaging()` dispatch.
  - `POST /messages` is authenticated but emits nothing to the socket, so R8
    cannot be worked around by routing writes over REST (ADR-012h).
- Contract gap for epic-2: Socket.IO rooms are keyed by the backend `User.id`,
  not the Firebase uid. `CupidSession` does not expose it; the coordinator
  takes an injected `backendUserId` resolver. Confirm `POST /auth/login`
  returns that id.

## Coding Plan Pass (2026-07-30)

- Shared coding plan: `coding-plan/master-plan.md` (+ `coding-agent-guide.md`).
- Shape: 6 phases — P0 contract (Mobile), P1 FCM/APNs config (DevOps), P2 socket
  transport + room key (Mobile), P3 FCM transport + pending queue (Mobile),
  P4 coordinator lifecycle/dedup/DI (Mobile), P5 verification + spike findings
  (Mobile). Matches the architecture's single-mobile-lane-plus-one-DevOps-phase
  shape: the mobile phases are strictly sequential (one writer inside
  `mobile/lib/core/realtime/`); only P1 may run concurrently.
- Implementation Lane: shared (mobile-dev + devops), not parallel multi-writer.
- Entry point: no UI surface (UX WAIVED). The reachability wiring for this
  non-UI capability is the `get_it` lazy-singleton registration plus
  `SessionScopedStore` enrollment in P4.
- Runtime registry id: `mobile-app`. Story-level runtime startup smoke NOT
  required (no runtime command, port, or app entry point change).
- Configuration guide: P1 owns the new FCM/APNs section.
- Resolved during planning: `POST /auth/login` **does** return the backend user
  entity (`backend/src/modules/auth/auth.controller.ts:15-21`), so the `User.id`
  is available at runtime. But the OpenAPI spec declares no response schema, so
  the generated client types it `Response<void>`
  (`mobile/openapi/cupid_api/lib/src/api/epic1_auth_api.dart:32`) and the id is
  not reachable through the typed call. P2 reads it from the shared `Dio`
  instance that already carries the interceptor pipeline; no client
  regeneration and no backend change.
- Still open (non-blocking, carried to epic-2/epic-3, not gates on any phase
  here): R8 socket auth gap, R9 missing backend FCM dispatch + device-token
  storage, ADR-012h `POST /messages` no-fanout. The real-device background push
  confirmation is recorded in P5 as a deferred manual operator procedure caused
  by R9, not as a phase test gate.
