# REQ-001 Requirement-Level Requirements & OQ Triage

Source: `req_master.md` (D0-D5, risk table), `data/intake/bootstrap/conflicts_open_questions.md`.

## Story Breakdown Summary

Foundation (sequential, per req_master proposed order):
STORY-001 design_system (shared-foundation) -> STORY-002 api_client ->
STORY-003 auth -> STORY-004 RealtimeCoordinator spike.

Feature stories (epic-1..epic-6, admin/data-export excluded):
STORY-005..STORY-016. Full list and paths: `req_master.md` -> `## User
Stories`.

## OQ Triage

### OQ4 — Offline storage strategy
Status: RESOLVED before this breakdown (ADR-007,
`data/architecture/system/system_architecture_memory.md`). Drift for
chat/timeline/expenses (read-through, server-authoritative cache, no
offline write/outbox queue in v1 — backend has no idempotency key);
`hydrated_bloc` for ephemeral state only. No PO action needed; cited as-is
in STORY-007 (chat), STORY-012 (timeline), STORY-015 (expenses).

### OQ5 — Light theme & EN locale in v1?
Status: RESOLVED by Product Owner in this breakdown, in STORY-001
(design_system) AC. Decision: build all 4 combinations now (iOS/Material x
dark/light x vi/en token + ARB infra), but only **enable** dark + `vi` at v1
launch. Light theme and `en` locale stay built but switched off (flag/config,
not deleted code) until a future requirement explicitly turns them on. This
matches the working assumption in `req_master.md` and
`conflicts_open_questions.md`; no escalation needed.

### D1 / Critical-Alerts copy conflict (raised by UI/UX system-foundation pass)
Status: RESOLVED by Product Owner in this breakdown, in STORY-009 (nhắc nhở
đồng bộ) scope. The raw design copy "Chỉ Synced Alarm được phép phá Do Not
Disturb" implies a Critical Alerts-class entitlement, which conflicts with D1
(no Critical Alerts in v1). Default/safe direction taken: STORY-009 scopes
this DND-override claim OUT of v1 copy — UI/UX Designer must rewrite the
Notifications screen copy to remove the "phá Do Not Disturb" claim rather
than request the entitlement. Not escalated to the user; no evidence v1
actually needs OS-level DND override. Escalate later only if a stakeholder
explicitly asks for guaranteed DND-breaking delivery.

## Cross-Story Notes For Downstream Roles

- Backend contract frozen (A1): no story below may request a new/changed
  backend endpoint. If a story's AC seems to need one, flag as an open
  question back to Scrum Master instead of assuming a change.
- Epic-3 wording: every story/AC referencing the old "báo thức" (alarm)
  concept must say "nhắc nhở đồng bộ" (D1, mandatory note #3). Backend
  module/gateway name `alarms`/`TRIGGER_ALARM` stays as transport naming only
  (ADR-002) — do not rename backend identifiers.
- R8 (Socket.IO auth gap, `chat.gateway.ts:39-57`): client-side forward
  compatibility (sending Firebase token in `handshake.auth.token`) is a
  Tech Lead ADR concern, cited in STORY-004. Production-readiness of chat
  (STORY-007) depends on this being resolved or accepted as risk before
  production ship — not a v1 build blocker.
- R3 (libsodium FFI, local encryption): flagged as an open item on epic-4
  stories (STORY-012, STORY-013, STORY-014) for Tech Lead to spike on both
  platforms before epic-4 implementation starts. Not broken out as its own
  story in this breakdown since req_master's mandated foundation order does
  not list it as a separate story.
