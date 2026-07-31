# Story Master: STORY-012 Epic-4 — Timeline Kỷ Niệm

Status: IN_PROGRESS — fully reviewed, merge-eligible. P1-P8 implementation
DONE, full sliced review DEFERRED_ONLY at commit `8b898c4`. An ADR-010
canonical-Drift-owner fold was applied afterward (story branch HEAD
`73785306d990ec9df47a6258b535524727fafc13`, folding
`TimelineEntries`/`TimelineSyncState` into the shared `CupidDatabase`,
removing the standalone `AppDatabase`) and has now passed a scoped fold-only
Reviewer run: Outcome CLEAN. Only remaining step is merging into the
integration branch, currently blocked requirement-wide by STORY-013's stuck
integration worktree. See scrum-master-checkpoint.md.
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
- [DONE — Tech Lead] R3 spike not required: no timeline content needs local
  encryption; ADR-007 (read-through Drift cache, server-authoritative, no
  offline write queue) covers the story's persistence needs.

## Role Completion

- [x] Architecture (Tech Lead) — `architecture/solution.md` and
  `coding-plan/master-plan.md` phases P1-P8, ADR-007 read-through cache.
- [x] Implementation (Development) — Mobile Developer, P1-P8 all DONE per
  `coding-plan/master-plan.md` §5 Phases Overview and
  `coding-plan/test-results.md` (P8 verification), 2026-07-31. P8 closed a
  real gap found during verification: `TimelineScreen`'s two "Add a memory"
  call sites were still wired to `onAddMemory: () {}` (stale P6-scope
  comment) even though P6 had already built `CreateEntryCubit`/
  `CreateMemorySheet`, making AC1 unreachable from the real screen; P8 wired
  both call sites to `CreateMemorySheet.show`. `flutter analyze` (scoped):
  no issues. `flutter test`: 196/199 groups pass; the 3 failures are
  pre-existing/unrelated (confirmed via `git stash` to prior HEAD, same 3
  tests fail identically on a `GetIt` test-harness gap, not this story's
  change). `flutter build apk --debug`: PASS. AC1-AC4 PASS per evidence
  table. No outstanding blockers. Ready for Reviewer (Tier 3 — 33 touched
  files since merge-base `0a467d0`, needs scoped-slice review).
