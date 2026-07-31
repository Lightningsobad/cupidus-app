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

## Role Completion

- [x] Architecture (Tech Lead) — `architecture/solution.md` v1.0 and
  `coding-plan/master-plan.md` phases P0-P5, 2026-07-30.
- [x] Implementation (Development) — Mobile Developer, all phases DONE
  2026-07-31 per `coding-plan/master-plan.md` §5 Phases Overview (P0-P5 all
  `DONE`). P0 contract/data layer, P1 schedule bloc/state, P2 schedule
  screen/widgets, P3 firing cubit/overlay, P4 entry point + AC2/AC3/AC4 static
  copy guard, P5 verification (184/184 `flutter test` passed, `flutter
  analyze` clean, `flutter build apk --debug` PASS). Evidence:
  `coding-plan/test-results.md`.
- [ ] Review (Reviewer)

## Open Items For Downstream Roles
- UI/UX Designer: rewrite the raw Notifications screen copy to remove the
  DND-override claim per the resolved D1/Critical-Alerts conflict.
  (Resolved in `ux/uiux-spec.md` §4/§9.)
- [DONE — Tech Lead] Architecture (Tech Lead): `architecture/solution.md` v1.0 +
  `coding-plan/master-plan.md` phases P0–P5 (mobile-only lane). Five binding
  contracts: D1 writes go over the socket because the REST controller performs no
  partner fanout, so REST cannot satisfy AC1; D2 hydrate via
  `CupidApi.dio.get('/alarms')` because the generated
  `alarmsControllerFindOne` is typed `Response<void>` (no OpenAPI response
  schema); D3 per-partner stage derived client-side from `status` +
  `requesterId` vs backend `User.id`; D4 the 5-minute timeout is client-side
  only and must not emit `stopAlarm`; D5 `alarmStoppedByPartner` is ephemeral
  (no server uuid) so partner dismissal is re-derived from `GET /alarms`
  `stopperIds` on foreground. AC2/AC3/AC4 are enforced by a static guard test
  scanning `mobile/lib/**` plus a `pubspec.yaml` dependency assertion; the
  Notifications settings screen is deliberately not built (it does not exist in
  `mobile/lib` yet). No backend change, no new pub dependency.
- Product Owner / UI-UX Designer (ASSUMPTION-1, non-blocking): the frozen `Alarm`
  entity has one `time` column and no weekday/repeat field, so under A1 a
  recurring schedule is not persistable. Weekday chips are client-local and only
  the next absolute occurrence is sent; v1 does not auto-repeat. The UX eyebrow
  copy "Nhắc nhở đồng bộ mỗi sáng / Shared morning reminder" implies recurrence
  it cannot deliver — needs a copy ruling.
- Product Owner (ASSUMPTION-2 / R9, non-blocking): backend push is a
  `console.log` stub, so a backgrounded device receives nothing in v1. UX spec §5
  step 5's "system push" is not deliverable; backgrounded devices recover on next
  foreground via `GET /alarms`. Faking it with a local-notification plugin is
  excluded by AC4.
