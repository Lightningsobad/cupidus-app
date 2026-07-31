# Story Master: STORY-006 Epic-1 — Love Contracts / Nghi Thức Cam Kết

Status: IN_PROGRESS (P0-P3 DONE+committed on the story branch —
`8ab8be5` P2 clause-UI status sync, `20c9355d18ec640da176365a84ee3b1e09507e13`
P3 hold-to-sign button; P4 entry-point-gate dispatched this wave to
Alex-Mobile-Dev-76, BaseHead `20c9355d...`; see scrum-master-checkpoint.md)
Complexity: M
Epic: epic-1 (core connection)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/love-contracts/`
Design reference: `cupid-mobile-design/` — commitment/ritual screen group
(exact screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003. Soft dependency on STORY-005 (pairing
  must exist before a contract between the pair can be created).

## User Story
As a paired couple, we want to create and view shared "love contracts"
(commitment rituals) so we have an explicit, mutually agreed record of
promises we've made to each other in the app.

## In Scope
- Creating/proposing a love contract between the paired users.
- Both partners accepting/acknowledging it (per whatever the backend
  contract's flow requires).
- Viewing existing love contracts.

## Out of Scope
- Any love-contracts endpoint change (A1 frozen).
- Full state-management architecture decisions (D2 flags this module as
  needing full Bloc, not Cubit, for its ritual/ceremony flows — that's a
  Tech Lead implementation concern, not a PO scope item).

## Acceptance Criteria
1. A paired user can create/propose a love contract.
2. The partner can view and acknowledge/accept it per the backend's supported
   flow.
3. Both partners can view the list/detail of active love contracts.
4. Unpaired users cannot access this feature.

## Open Items For Downstream Roles
- Tech Lead: D2 calls out this module as needing full Bloc (not Cubit) for
  its ceremony/ritual flow — confirm in coding-plan.
