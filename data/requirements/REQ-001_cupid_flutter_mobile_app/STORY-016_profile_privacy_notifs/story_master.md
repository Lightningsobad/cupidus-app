# Story Master: STORY-016 Epic-6 — Hồ Sơ / Quyền Riêng Tư / Thông Báo (Mobile-Only)

Status: PENDING
Complexity: M
Epic: epic-6 (admin/privacy — mobile screens only; `admin` module itself is
out of scope per req_master)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/users/` (profile/privacy/notification
settings — exact endpoint mapping to be confirmed by Tech Lead; req_master
flags "me, privacy, notifs" screens as needing endpoint verification)
Design reference: `cupid-mobile-design/` — profile/settings screen group
("me", "privacy", "notifs"; exact screen ids to be confirmed by UI/UX
Designer).

## Depends On
- STORY-001, STORY-002, STORY-003.

## User Story
As a user, I want to view/edit my profile and control my privacy and
notification settings so I can manage my own presence in the app.

## In Scope
- Profile view/edit (the "me" screens).
- Privacy settings screens.
- Notification settings screens (distinct from STORY-009's reminder
  copy/behavior — this is the settings surface, not the reminder feature
  itself).

## Out of Scope
- `admin` module entirely (no mobile screens exist for it per req_master).
- `data-export` module entirely (no mobile screens exist for it per
  req_master).
- Any `users` endpoint change (A1 frozen).
- The Critical Alerts/DND-override copy conflict — that lives in STORY-009's
  scope (Notifications feature copy), not here, even though both touch
  "notification" surfaces. This story is settings/preferences only.

## Acceptance Criteria
1. A user can view and edit their own profile.
2. A user can view and change privacy settings exposed by the backend
   contract.
3. A user can view and change notification settings exposed by the backend
   contract.
4. No admin- or data-export-specific screen/action exists in this story's
   scope.

## Open Items For Downstream Roles
- Tech Lead: confirm exact endpoint mapping for "me", "privacy", "notifs"
  screens against the `users` module (req_master flags this as unverified);
  escalate to Scrum Master if any screen implies an endpoint the contract
  doesn't have.
