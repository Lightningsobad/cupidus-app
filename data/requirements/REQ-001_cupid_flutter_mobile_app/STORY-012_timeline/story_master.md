# Story Master: STORY-012 Epic-4 — Timeline Kỷ Niệm

Status: PENDING
Complexity: M
Epic: epic-4 (intimacy/memories)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/timeline/`
Design reference: `cupid-mobile-design/` — memories/timeline screen group
(exact screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003.

## User Story
As a paired couple, we want a shared timeline of our relationship's
memories/milestones so we can look back on our history together.

## In Scope
- Creating timeline entries (per `timeline` backend contract).
- Viewing the shared timeline, backed by Drift per ADR-007 (OQ4 — read-through
  cache, server-authoritative, no offline write queue).

## Out of Scope
- Any `timeline` endpoint change (A1 frozen).
- Offline write/outbox queue for new entries — excluded by ADR-007.

## Acceptance Criteria
1. A paired user can create a timeline entry.
2. Both partners can view the shared timeline.
3. Timeline is readable offline via the Drift cache after at least one
   successful sync; new entries still require connectivity to write.
4. Unpaired users cannot access this feature.

## Non-Functional / Risk Notes
- R3 (libsodium FFI) — if any timeline content requires local encryption,
  flag for Tech Lead spike before implementation starts (per req_master's
  risk table: spike libsodium build on both platforms before epic-4).

## Open Items For Downstream Roles
- Tech Lead: confirm whether timeline entries require local encryption
  (triggers R3 spike) before coding-plan for this story is finalized.
