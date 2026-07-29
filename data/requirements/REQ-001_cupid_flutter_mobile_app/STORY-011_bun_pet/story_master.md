# Story Master: STORY-011 Epic-3 — Bun Pet Đồng Hành

Status: PENDING
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

## Open Items For Downstream Roles
- Tech Lead/UI-UX: reconcile `cupid-mobile-design/`'s pet art assets against
  the actual `pets` module contract to confirm which interactions are real
  vs. purely cosmetic/local.
