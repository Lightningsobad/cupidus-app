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
- R3 (libsodium FFI) — **RESOLVED for STORY-012: no local encryption, no spike
  required.** The frozen backend persists and returns `title`, `description`,
  `photoUrl`, and `icon` as plaintext, so encrypting the on-device read-through
  mirror adds no confidentiality against any actor the current design protects
  against. Device-level confidentiality is met instead by wiping the Drift cache
  on sign-out. Rationale in `architecture/solution.md` §1. STORY-013 and
  STORY-014 must still resolve R3 on their own content sensitivity.

## Role Progress
- [x] UX Spec (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`
- [x] Coding Plan (Tech Lead) — `coding-plan/master-plan.md`, phases P1–P8
- [ ] Implementation (Mobile Developer)
- [ ] Review gate

## Open Items For Downstream Roles
- Tech Lead: RESOLVED — see the R3 note above and `architecture/solution.md` §1.
- Product Owner / Scrum Master: `architecture/solution.md` §8 defers three items
  the UX spec left open — photo attachment on create (D-012-7), pagination past
  the first 50 entries (D-012-8), and the milestone/progress banner (D-012-9).
  None is required by AC1–AC4; confirm or re-scope if that is not acceptable.
- Scrum Master: server-generated `type: milestone` entries already arrive in the
  same `GET /timeline` feed, so the UX "auto-added" pill is in scope as
  read-only rendering (answers UX spec §5.2).
- Scrum Master: STORY-005 (pairing) may later define a shared unpaired-gate
  pattern; this story ships a deliberately minimal `CouplePairingStore` that
  should be reconciled with it (UX spec §5.5).
