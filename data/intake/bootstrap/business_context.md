# Business Context

Normalized from S1-S3 (see `source_register.md`).

## Problem / Value

Build the Cupid mobile app (couple-only, 1:1 pairing) in **Flutter** for iOS
and Android, consuming the already-complete NestJS backend (~59 REST
endpoints, 2 Socket.IO gateways, Firebase Auth) and implementing the design
already finalized at `cupid-mobile-design/` (~31 screens, iOS/Material
variants, dark + light, VI + EN). This replaces a prior decision to build a
native iOS-only client (SUPERSEDED, see `conflicts_open_questions.md`).

## Actors

- Two paired users (couple, 1:1). No multi-partner or group scope.
- Backend already models auth (Firebase), profiles, pairing/invitations,
  chat, daily engagement, intimacy/memories, finance (shared expenses), and
  admin/privacy.

## In Scope (v1)

- ~31 mobile screens across 6 backend epics:
  - epic-1 core connection (pairing/invitation)
  - epic-2 communication (chat incl. typing-ghost two-way)
  - epic-3 daily engagement (renamed "nhắc nhở đồng bộ" / synced reminders —
    see wording rule below)
  - epic-4 intimacy/memories
  - epic-5 finance
  - epic-6 admin/privacy — mobile-visible portion only
- Client foundation: design system + design tokens (platform × theme), i18n
  (default `vi`, plus `en`), API client generated from OpenAPI (`/api-docs`),
  Firebase auth + refresh-token flow, Socket.IO realtime layer.
- Realtime channels: chat (two-way typing-ghost), anti-ghosting, synced
  reminders (not real alarms — see D1 in `technical_context.md`).

## Out Of Scope (v1)

- `admin` and `data-export` backend modules — no mobile screens designed for
  these (web admin / API-only).
- System-level alarms / Critical Alerts entitlement (deferred past v1, D1).
- Any backend contract change — backend is frozen for this client effort (A1).

## Mandatory Wording Rule

Product Owner must rename epic-3 "báo thức đồng bộ" (synced alarm) to
"**nhắc nhở đồng bộ**" (synced reminder) in every story/AC — a direct
consequence of D1 so the product does not over-promise real alarm behavior.

## Business Priority

Single requirement, HIGH priority: REQ-001 (already seeded, see
`requirement_candidates.md`). No competing/parallel initiatives identified in
current sources.

## Non-Goals / Constraints Carried From Decisions

- No new backend endpoints for the client to ship v1 (A1).
- No melos monorepo / no Pigeon codegen unless proven necessary later (D4).
- Keep one Flutter package (pragmatic feature-first) rather than premature
  multi-package split (D4).
