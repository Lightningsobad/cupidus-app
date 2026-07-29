# Story Master: STORY-013 Epic-4 — Gallery Ảnh Chung

Status: PENDING
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
