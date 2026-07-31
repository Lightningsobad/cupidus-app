# Story Master: STORY-011 Epic-3 — Bun Pet Đồng Hành

Status: DONE
Complexity: M
Epic: epic-3 (daily engagement)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/pets/`
Design reference: `cupid-mobile-design/` — "Bun Pet Art"/"Bun Sprite" design
files and daily engagement screen group (exact screen ids to be confirmed by
UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003.

## User Story
As a paired couple, we want a shared virtual pet ("Bun") that reflects our
daily engagement with each other, so the app rewards showing up for each
other in a playful way.

## In Scope
- Displaying the shared pet's state per the `pets` backend contract.
- Any pet interactions the backend contract exposes (feeding, care actions,
  etc. — whatever `pets` module actually supports).

## Out of Scope
- Any `pets` endpoint change (A1 frozen).
- Inventing pet mechanics not backed by the `pets` contract — if the design
  implies an interaction with no backend support, flag it rather than fake
  it client-side.

## Acceptance Criteria
1. Paired users can view the shared pet's current state.
2. Any pet interaction shown in the UI maps to an actual `pets` backend
   capability.
3. Unpaired users cannot access this feature.

## Role Completion

- [x] Architecture (Tech Lead) — `architecture/solution.md` v1.0 (D1-D4) and
  `coding-plan/master-plan.md` phases P1-P9, 2026-07-30.
- [x] Implementation (Development) — Mobile Developer, P1-P9 all DONE per
  `coding-plan/master-plan.md` §5 Phases Overview and
  `coding-plan/phase-P9-verification.md` (Status: DONE), 2026-07-31.
  `flutter analyze` 0 new issues, `flutter test` 214/214, AC1-AC3 PASS.
- [x] Review (Reviewer) — `review/review-report.md`, Outcome: CLEAN,
  final-synthesis from slice-a (pet-data-di) + slice-b (P3-P9), 2026-07-31.

## Merge State (Scrum Master)
Merged into `codex/REQ-001_cupid_flutter_mobile_app-integration` at
`34bb6aae9c0e97d5751fc02182266ef1538d3298` (story tip
`c2aebfa43d04dd1cde7567abc9d19dddc8c09015`). Had a real, additive-only 3-file
merge conflict (`service_locator.dart` DI registration, `cupid_icons.dart`
glyph constants, `home_screen.dart` entry-point widget) against the
STORY-006/007/008/009/010/014 content already on the integration branch;
resolved inline by keeping both sides per `architecture/solution.md` §4
Boundaries And Ownership, committed directly (no raw `git merge`/`commit`
porcelain — resolved via `git-story-boundary.sh merge` retry after staging
the hand-resolved files), then sealed via `git-story-boundary.sh complete`.
`MERGE_COMPLETE: true`. Full architecture/coding-plan/review/ux artifacts live
on the story branch and the integration branch/worktree; this control-checkout
copy carries only the Status/completion summary until the integration branch
merges to `main` at requirement-DONE.

## Open Items For Downstream Roles
- [DONE — Tech Lead] Architecture (Tech Lead): `architecture/solution.md` v1.0
  (D1-D4) plus the shared coding plan `coding-plan/master-plan.md` (P1-P9,
  mobile-only lane). Backend untouched (A1). Configuration guide impact:
  NOT_APPLICABLE.
- [DONE — Tech Lead/UI-UX] Reconciled `cupid-mobile-design/`'s pet art assets
  against the actual `pets` module contract: `PATCH /pets/interact` is the
  only interaction endpoint (Feed/Play share one action with a client-surfaced
  5s cooldown); 5 of 6 `Bun Sprite` mood states map to backend `mood` values
  (`sleep` not implemented); day-streak/badge tiles dropped (no backing
  field); `BunSprite` renders for all species (only bunny art exists).
  Escalations to Product Owner (not story blockers): real streak/badge
  system, per-species sprite art, `pairedAt` field for a countdown adopt gate.
