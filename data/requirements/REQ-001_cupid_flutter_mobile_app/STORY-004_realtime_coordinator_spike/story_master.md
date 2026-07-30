# Story Master: STORY-004 Spike — RealtimeCoordinator (Socket.IO + FCM)

Status: DONE
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
