# Story Master: STORY-014 Epic-4 — Dream Jar / Hũ Ước Mơ Chung

Status: PENDING
Complexity: S
Epic: epic-4 (intimacy/memories)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/dream-jar/`
Design reference: `cupid-mobile-design/` — dream jar screen group (exact
screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003.

## User Story
As a paired couple, we want a shared "dream jar" where we can each drop in
wishes/dreams for our relationship, so we build a collection of shared
aspirations over time.

## In Scope
- Adding a dream/wish entry to the shared jar.
- Viewing the shared jar's contents.

## Out of Scope
- Any `dream-jar` endpoint change (A1 frozen).

## Acceptance Criteria
1. A paired user can add a dream/wish entry to the shared jar.
2. Both partners can view the jar's contents.
3. Unpaired users cannot access this feature.

## Non-Functional / Risk Notes
- R3 (libsodium FFI) — if dream jar entries require local encryption, flag
  for Tech Lead spike before implementation (per req_master's risk table).

## Open Items For Downstream Roles
- Tech Lead: confirm encryption requirement (R3) for this story before
  coding-plan.
