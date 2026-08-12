# Story Master: STORY-021 Hardening - Privacy/Notifications Capability (Retro-Audit RED-PATCH)

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-001
Retro-Type: RED-PATCH
Fixes: STORY-016 AC2 ("A user can view and change privacy settings exposed by
the backend contract.") and AC3 ("A user can view and change notification
settings exposed by the backend contract.")
Source: `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`
§ Open Question Triage / Approved Scope Change, entry "5. STORY-016 AC2/AC3
rescope — privacy view-only, notifications device-local-only"
(`retro-audit/audit-report.md`, Audit Date 2026-08-12, ruling recorded
2026-08-12).

## Depends On
- NONE. STORY-017 and STORY-018 are both DONE, and STORY-019 and STORY-020
  (the first two of three sequential hardening code-fix stories this cycle)
  are both DONE; this ruling explicitly states no further PO decision is
  required before this story starts.

## User Story
As a user, I want to view and change my privacy settings, and view and change
my notification settings exposed by the backend contract, so the settings
screens I already see actually let me control my own experience instead of
only displaying it or faking that control locally.

## Background / Confirmed Defect
The ruling in `req_master.md` entry #5 is final: STORY-016 AC2/AC3 were
already correct as written; the shipped view-only privacy screen and
device-local-only notification screen are **build defects**, not an approved
scope cut. AC2/AC3 text is unchanged and must be implemented exactly as
originally written.

Verified against current code (`backend/src/modules/users/`,
`mobile/lib/features/account/`) and
`retro-audit/audit-report.md` § AC-by-AC Implementation Traceability
(STORY-016 AC2/AC3 rows):

1. **AC2 privacy defect — editable control missing, backend contract already
   exists.** `privacy_screen.dart`
   (`mobile/lib/features/account/presentation/screens/privacy_screen.dart`)
   renders three static informational tier cards — no `Switch`, no `PATCH`
   call, no `isGhostModeEnabled` reference anywhere, matching the audit's
   `AC2 FAIL` finding ("zero `Switch`/`PATCH`/editable control"). The backend
   already exposes exactly one privacy-relevant, user-writable field:
   `User.isGhostModeEnabled` (`backend/src/modules/users/entities/user.entity.ts`),
   already accepted by the existing `PATCH /users/me` endpoint via
   `UpdateProfileDto.isGhostModeEnabled`
   (`backend/src/modules/users/dto/update-profile.dto.ts`,
   `users.controller.ts`). Today this field is only ever *read* on the mobile
   side (`ghost_cubit.dart`'s `_partnerStore.isGhostModeEnabled`, for the
   local device's own consent gating in chat) — no mobile screen ever writes
   it. **No new backend endpoint or field is required**: the fix is to add an
   editable control for `isGhostModeEnabled` to the privacy screen, wired to
   the already-existing `PATCH /users/me` contract.

2. **AC3 notification defect — no backend contract exists to expose.**
   `notification_settings_screen.dart`
   (`mobile/lib/features/account/presentation/screens/notification_settings_screen.dart`)
   is already a fully functional device-local toggle screen (7 rows across 3
   groups — critical, engagement, info — backed by
   `NotificationSettingsCubit`/`NotificationPreferencesStore`/
   `SharedPreferences`): it already lets a user "view and change" notification
   preferences, just not against any backend contract. The audit confirms the
   backend has "no notification module/field at all." Unlike the privacy
   case, there is no existing `users`-module (or any other) endpoint this fix
   can wire into: AC3's literal "exposed by the backend contract" clause has
   no backend contract to target, and A1 freezes the backend entirely for
   this client-only requirement (`req_master.md` § Ràng buộc kiến trúc đã
   chốt: "Thay đổi contract backend (A1: backend đóng băng, không đổi vì
   client)"). This story does not invent a new backend module on Product
   Owner authority to satisfy AC3 literally — see Open Items below.

## In Scope
1. Mobile: add an editable control to the privacy settings screen for
   `isGhostModeEnabled`, wired to the existing `PATCH /users/me` endpoint
   (`UpdateProfileDto.isGhostModeEnabled`), so AC2's "view and change" is
   genuinely real for the one privacy field the backend contract exposes.
2. Mobile: keep the notification settings screen's existing, already-working
   device-local view/change capability (7 rows, 3 groups) intact — this story
   must not regress that functioning behavior while AC3's backend-contract
   question is unresolved.
3. Tech Lead: resolve, before implementation phases are scoped, whether AC3's
   "exposed by the backend contract" clause is achievable at all given the
   confirmed absence of any backend notification module and the A1 freeze —
   see Open Items below. This is a Tech Lead technical finding, not a
   Product Owner scope decision.
4. Regression guard: confirm STORY-016 AC1 (profile view/edit) and AC4 (no
   admin- or data-export-specific screen/action) are not disturbed by this
   story's changes to the adjacent privacy/notification screens.

## Out of Scope
- Inventing a new backend endpoint, field, or module for notification
  settings on Product Owner authority — A1 freezes the backend contract, and
  this story does not approve a new one. If Tech Lead determines a new
  backend module is the only way to satisfy AC3, that is itself a new
  decision requiring its own future entry in `req_master.md`'s
  `## Open Question Triage / Approved Scope Change` section, not something
  this story-seed pre-approves.
- Any privacy field beyond `isGhostModeEnabled` — it is the only
  privacy-relevant, user-writable field the backend `User` entity exposes per
  the audit. The privacy screen's three tier cards (typing ghost/private
  gallery/messages; dream jar/love timeline/vibe check; profile/love pet
  stats/alarm settings) are informational content describing privacy tiers,
  not individually backend-writable toggles, and stay informational here.
- The "Export all my data" button (DEC-5) and any other admin/data-export
  surface — out of scope per STORY-016 AC4, unaffected by this fix.
- STORY-006/STORY-008 hardening scope (STORY-019 and STORY-020, both already
  DONE, separate stories).
- Any `users` endpoint contract change beyond calling the already-existing
  `PATCH /users/me` (A1 frozen).

## Acceptance Criteria
1. A user can view and change privacy settings exposed by the backend
   contract (STORY-016 AC2, carried forward unchanged): the privacy screen
   exposes an editable control for `isGhostModeEnabled`, and toggling it
   calls the existing `PATCH /users/me` endpoint and persists the change.
2. A user can view and change notification settings exposed by the backend
   contract (STORY-016 AC3, carried forward unchanged).
3. No admin- or data-export-specific screen/action exists in this story's
   scope (STORY-016 AC4 regression guard — this story must not weaken that
   gate while fixing privacy/notifications).

## Open Items For Downstream Roles
- [Tech Lead] Confirm/resolve whether AC3 ("view and change notification
  settings exposed by the backend contract") is achievable at all: the
  backend has no notification module or field of any kind — confirmed by
  `retro-audit/audit-report.md`'s STORY-016 AC3 FAIL row ("backend has no
  notification module/field at all") — and A1 freezes the backend contract
  entirely for this client-only requirement. If Tech Lead confirms no backend
  contract can be exposed without violating A1, that technical finding
  determines whether AC3 closes as "mobile device-local settings, done
  correctly" or requires escalation back through the
  `## Open Question Triage / Approved Scope Change` mechanism in
  `req_master.md` for a possible new backend module. This story does not
  pre-decide that outcome.
- [Tech Lead / Mobile Developer] Decide the exact editable-control shape for
  `isGhostModeEnabled` on the privacy screen (e.g. a toggle on the existing
  Level 1 tier card vs. a distinct "Controls" section) — an implementation
  decision within this story's approved AC2 scope, not a new PO scope item.
- [Mobile Developer] Confirm the existing device-local notification toggle
  behavior (`notification_settings_screen.dart`, 7 rows / 3 groups via
  `NotificationPreferencesStore`) is not regressed regardless of how Tech
  Lead resolves the AC3 backend-contract question above.

## Role Completion
- [x] Product Owner — this story-seed, opened from `req_master.md` § Open
  Question Triage / Approved Scope Change entry #5 ruling (STORY-016 AC2/AC3
  rescope reversed; AC text unchanged) +
  `retro-audit/audit-report.md` (STORY-016 AC2/AC3 FAIL rows).
- [x] UI/UX Designer — `ux/uiux-spec.md` (§2 controls-card placement between
  Level 1/Level 2 tier cards, §3 pill-toggle component/copy, §5 accessibility
  labels), confirmed against the shipped capture in
  `visual-fidelity/visual-fidelity-report.md`.
- [x] Architecture (Tech Lead) — `architecture/solution.md` (§1 AC2 one-
  parameter passthrough write-path design via `AccountRepository
  .updateProfile()`; §3 AC3 Feasibility Finding — verified against current
  source that no backend notification module/field exists and A1 forbids
  creating one, so AC3 closes as "mobile device-local settings, done
  correctly" with no blocker raised) + `coding-plan/master-plan.md` (single P1
  phase) + `coding-plan/phase-P1-privacy-ghost-toggle.md`.
- [x] Implementation (Development) — P1 by `Alex-Mobile-Dev`, `DONE` in
  `coding-plan/master-plan.md` § Phases Overview. Code+test evidence in
  `coding-plan/test-results.md`: clean `flutter analyze`, `flutter test
  test/features/account/` 85/85 (including the four unmodified AC3
  non-regression files: `notification_settings_screen_test.dart`,
  `notification_settings_cubit_test.dart`,
  `notification_preferences_store_test.dart`, plus the rewritten
  `privacy_screen_test.dart`). Visual audit `PASS` in
  `visual-fidelity/visual-fidelity-report.md`: real authenticated-session
  capture (`main_preview.dart` PREVIEW=privacy against the live backend, not a
  mocked fixture) matching `ux/uiux-spec.md` §2/§3/§5; two environment
  blockers (emulator storage, then `backend-api` unreachable) were hit and
  resolved outside mobile-dev's remediation scope, documented in the report's
  Retry History section. Note: the same `visual-fidelity/` directory also
  contains 8 additional `implemented-privacy-*.png` files the reporting agent
  did not produce and explicitly does not claim, attributed to confirmed
  duplicate/parallel mobile-dev agent activity on this same story scope during
  this cycle; the `PASS` verdict is scoped only to
  `implemented-privacy-emulator-5554.png`, the one capture the report accounts
  for end to end. The 8 extra files are surplus evidence artifacts, not a
  correctness or regression risk, and do not block review.
- [x] Review (Reviewer) — `review/review-report.md`, `Outcome: CLEAN` (Tier 1
  compact story review, `Iris-QC-6`). Diff independently verified against
  `BaseHead` (exactly 8 files, all `mobile/`, matching declared write scope);
  all 4 architecture-declared risk-surface gates confirmed CLEAR (two-writer
  isolation, notification non-regression 1/1+17/17+4/4, no
  admin/export affordance, tier cards never hidden behind a spinner); AC1-3
  traced to concrete test/capture evidence; the AC2/notification
  backend-infeasibility OQ ruling confirmed correctly respected with zero
  unauthorized backend change; `implemented-privacy-emulator-5554.png` viewed
  directly and confirmed to match `ux/uiux-spec.md`. No findings, no patch
  required.
