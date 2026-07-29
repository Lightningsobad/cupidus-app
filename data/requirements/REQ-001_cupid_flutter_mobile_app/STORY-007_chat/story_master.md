# Story Master: STORY-007 Epic-2 — Chat (2-way typing-ghost, realtime)

Status: PENDING
Complexity: L
Epic: epic-2 (communication)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/messages/`, `backend/src/modules/uploads/`
(attachments)
Design reference: `cupid-mobile-design/` — chat screen group (exact screen
ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003, STORY-004 (RealtimeCoordinator — chat is
  the primary consumer of the socket/FCM reconciliation this spike proves
  out). Soft dependency on STORY-005 (pairing).

## User Story
As a paired user, I want to chat with my partner in real time, including
seeing when they're typing, so our conversation feels immediate and present.

## In Scope
- Sending/receiving text messages between the paired users.
- 2-way typing-ghost indicator (both directions).
- Message history view, backed by Drift per ADR-007 (OQ4 resolution — see
  `requirements.md`).
- Attachments if the backend `messages`/`uploads` contract supports them in
  chat (confirm with Tech Lead; do not assume beyond what the frozen contract
  exposes).

## Out of Scope
- Any messages/uploads endpoint change (A1 frozen).
- Offline write/outbox queue — explicitly excluded by ADR-007 (no
  idempotency key/dedupe on backend, so queued sends can't be made
  duplicate-safe).
- Fixing the backend Socket.IO auth gap (R8) — client sends the Firebase
  token per STORY-004's forward-compat work, but the actual gap is a
  separate backend decision. Chat may ship to a private-beta/limited-user v1
  per the open decision in `conflicts_open_questions.md`; production-wide
  release needs that decision resolved first.

## Acceptance Criteria
1. Paired users can send and receive text messages in real time.
2. Typing-ghost indicator appears/disappears correctly in both directions
   within a reasonable latency window (Tech Lead to set exact threshold).
3. Message history is available on reopening the app (Drift-backed
   read-through cache, server-authoritative).
4. No local queued/offline message send exists — sends require connectivity,
   consistent with the OQ4 resolution.
5. Chat is inaccessible to unpaired users.

## Open Items For Downstream Roles
- Scrum Master/User: R8 production-readiness decision (private-beta accept
  risk vs. escalate to backend team) still open — this story can build and
  ship to non-production/beta regardless.
- Tech Lead: confirm attachment support scope from the actual `messages`/
  `uploads` contract before UI/UX designs an attachment picker.
