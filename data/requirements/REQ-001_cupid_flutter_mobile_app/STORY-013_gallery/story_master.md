# Story Master: STORY-013 Epic-4 — Gallery Ảnh Chung

Status: IN_PROGRESS (Open Item #1 resolved, Tech Lead coding-plan P0-P5
written; P0-P4 DONE+committed on the story branch — `526ea65f` P3 upload
sheet, `fc7c58a1` P4; P5 verification dispatched this wave to
Alex-Mobile-Dev-75, BaseHead `526ea65f`; open BLOCKER-1 — AC2 `GET /gallery`
user-scoped not couple-scoped — needs a Scrum Master routing decision before
Reviewer; see scrum-master-checkpoint.md)
Complexity: M
Epic: epic-4 (intimacy/memories)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/gallery/`, `backend/src/modules/uploads/`
Design reference: `cupid-mobile-design/` — gallery screen group (exact
screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003.

## User Story
As a paired couple, we want a shared photo gallery so we can keep and
revisit photos that matter to our relationship in one place.

## In Scope
- Uploading photos to the shared gallery (via `uploads` + `gallery`
  contract).
- Viewing the shared gallery.

## Out of Scope
- Any `gallery`/`uploads` endpoint change (A1 frozen).

## Acceptance Criteria
1. A paired user can upload a photo to the shared gallery.
2. Both partners can view the shared gallery contents.
3. Unpaired users cannot access this feature.

## Non-Functional / Risk Notes
- R3 (libsodium FFI) — if gallery content requires local encryption, flag
  for Tech Lead spike before implementation (per req_master's risk table).
- R4 (Android low-end perf) — gallery is an image-heavy screen; Tech Lead
  should include it in the low-end Android performance pass.

## Open Items For Downstream Roles
- Tech Lead: confirm encryption requirement (R3) and perf budget (R4) for
  this story before coding-plan.
