# Story Master: STORY-009 Epic-3 — Nhắc Nhở Đồng Bộ

Status: PENDING
Complexity: M
Epic: epic-3 (daily engagement)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/alarms/` (backend module/gateway name
`alarms`/`TRIGGER_ALARM` stays as transport naming per ADR-002 — only
user-facing copy is renamed)
Design reference: `cupid-mobile-design/` — notifications/reminders screen
group (exact screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003, STORY-004 (delivery via FCM/socket dual
  path per RealtimeCoordinator).

## User Story
As a paired user, I want synced reminders ("nhắc nhở đồng bộ") that both
partners receive together, so we stay coordinated on shared moments —
without the app promising system-level alarm/Do-Not-Disturb-breaking
behavior it can't deliver in v1.

## In Scope
- Creating and receiving "nhắc nhở đồng bộ" (synced reminders) between the
  paired users, delivered via the `alarms` backend module.
- Copy and UI must say "nhắc nhở đồng bộ" everywhere — never "báo thức"
  (D1, mandatory rewording, applies to every AC/screen in this story).

## Out of Scope
- Any `alarms` endpoint/gateway change (A1 frozen) — transport names stay as
  `alarms`/`TRIGGER_ALARM`, only user-facing copy changes.
- System-level Critical Alerts / Do-Not-Disturb override. The raw design
  copy "Chỉ Synced Alarm được phép phá Do Not Disturb" is explicitly OUT of
  v1 — this conflicted with D1 (no Critical Alerts entitlement in v1). UI/UX
  Designer must remove/rewrite that DND-override claim from the
  Notifications screen; do not implement or request the entitlement. See
  `requirements.md` D1/Critical-Alerts triage.
- Real device alarm/native alarm module — explicitly excluded by D1 (v1
  needs a sufficiently strong notification, not a real alarm).

## Acceptance Criteria
1. A paired user can create/trigger a synced reminder that both partners
   receive.
2. All in-app copy and any localized strings for this feature use "nhắc nhở
   đồng bộ", never "báo thức".
3. Notifications screen copy contains no claim that this feature overrides
   system Do Not Disturb.
4. No native/system alarm integration exists in this story's implementation.

## Open Items For Downstream Roles
- UI/UX Designer: rewrite the raw Notifications screen copy to remove the
  DND-override claim per the resolved D1/Critical-Alerts conflict.
