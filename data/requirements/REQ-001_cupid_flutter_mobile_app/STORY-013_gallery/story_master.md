# Story Master: STORY-013 Epic-4 — Gallery Ảnh Chung

Status: BLOCKED — implementation (P0-P5) and Reviewer are both complete
(`Outcome: DEFERRED_ONLY`, `story_status_recommendation: DONE`, story branch
HEAD `0f30230a404bd71346202d2d8d05a31319274cf9`). The ONLY remaining step is
merging into `codex/REQ-001_cupid_flutter_mobile_app-integration`, which is
stuck: the integration worktree is mid-merge with all 4 conflicts
hand-resolved and 46 files staged, but no sanctioned tool path can complete
the merge commit (`GUARD_FEEDBACK_INSUFFICIENT` — see
scrum-master-checkpoint.md "Merge Blocker"). Do NOT re-run any phase or
Reviewer for this story. Do NOT touch the integration worktree further
(work is staged, not lost). Needs a user/tooling decision.
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
