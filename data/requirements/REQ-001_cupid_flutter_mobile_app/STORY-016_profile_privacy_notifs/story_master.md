# Story Master: STORY-016 Epic-6 — Hồ Sơ / Quyền Riêng Tư / Thông Báo (Mobile-Only)

Status: PENDING
Complexity: M
Epic: epic-6 (admin/privacy — mobile screens only; `admin` module itself is
out of scope per req_master)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/users/` for profile view/edit and
privacy view (`GET /users/me`, `PATCH /users/me`). Notification settings
(AC3) are device-local only in v1 — no backend module or endpoint (PO
decision, see `requirements/requirements.md`).
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
2. A user can view their privacy settings (the three-tier data-sharing
   explainer) as static, read-only content. This story does not add or own
   any editable privacy control; the Typing Ghost / ghost-mode toggle remains
   solely owned by STORY-008 and must not be duplicated here.
3. A user can view and change notification preferences, persisted
   device-local only (no backend endpoint, no cross-device sync in v1).
   These preferences gate client-side notification presentation only.
4. No admin- or data-export-specific screen/action exists in this story's
   scope.

## Role Completion

- [x] Architecture (Tech Lead) — `architecture/solution.md` +
  `coding-plan/master-plan.md` phases P0-P6/P-DEVOPS, 2026-07-30.
- [x] Implementation (Development) — Mobile Developer. P0, P1, P2, P4, P5, P6
  all DONE/COMPLETE per `coding-plan/master-plan.md` §6.1 Phase Overview
  (`flutter analyze` clean, `flutter test` green, AC4 grep gate, per P6
  verification). P3 (avatar upload) and P-DEVOPS (`HOST` config) are
  NOT_STARTED and intentionally deferred per architecture DEC-1: avatar
  upload stays behind `CupidFeatureFlags.enableAvatarUpload` (default
  `false`), so AC1 is satisfied by display name/DOB/zodiac without it. This
  is a recorded known limitation for the review gate, not a blocker. 2026-07-31.
- [ ] Review (Reviewer) — IN PROGRESS. `review/slice-a.md`: PASS, no blocking
  findings (AccountRepository endpoint scoping, NotificationPreferencesStore
  device-local persistence, ARB key-set parity, no dead code). `review/slice-b.md`:
  PATCH_REQUIRED — Finding F-1: `me_screen.dart`'s `_MenuRow` has no `onTap` for
  the Privacy/Notifications rows (Typing Ghost/Love Contract correctly remain
  inert, owned by other stories). Finding F-1 patch applied by Mobile Developer,
  2026-07-31: `_MenuRow` now takes an optional `onTap`; the Privacy row pushes
  `PrivacyScreen()` and the Notifications row pushes
  `NotificationSettingsScreen(store: getIt<NotificationPreferencesStore>())`,
  mirroring `app_shell.dart`'s existing `getIt<...>()` pattern. Typing Ghost and
  Love Contract rows were left untouched (still inert). `me_screen_test.dart`
  extended with coverage for both new navigations and for the two rows
  remaining non-interactive; `flutter analyze` clean and
  `flutter test test/features/account/presentation/screens/me_screen_test.dart`
  6/6 passing. Awaiting a fresh Reviewer re-check of Finding F-1 before this
  story can close the review gate.

## Open Items For Downstream Roles

Resolved by Tech Lead solution doc
(`architecture/solution.md`) and Product Owner decision
(`requirements/requirements.md`):
- Endpoint mapping for "me"/"profile" and "privacy" (view) screens: `GET
  /users/me` and `PATCH /users/me` on the `users` module. No endpoint exists
  or is added for notification settings; AC3 is device-local only (PO
  decision, BLOCKER-1 Option A).
- AC2 is view-only; the only editable privacy field (`isGhostModeEnabled`)
  stays owned by STORY-008 (PO decision, BLOCKER-2 Option A).

Still open, not Product Owner scope (Scrum Master routing required):
- GAP-1: no owner exists yet for the 5-tab app shell this story's screens
  are meant to live inside; do not build the shell in this story.
- RISK-1: verify `PATCH /users/me` `photoUrl` (`@IsUrl()`) accepts the
  bare-`localhost` upload URL returned by `POST /uploads` in a default local
  environment before building the avatar flow; if it doesn't, this is a
  DevOps config issue, not a client workaround.
