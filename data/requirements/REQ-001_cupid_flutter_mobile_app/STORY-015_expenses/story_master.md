# Story Master: STORY-015 Epic-5 — Chi Tiêu Chung (Expenses)

Status: DONE — Implementation (Development) DONE, all phases P1-P6 DONE and
committed on `codex/REQ-001_cupid_flutter_mobile_app-STORY-015` through
`51ae8f1` (P6 verification: `flutter analyze`/`flutter test` 81/81,
`flutter build apk --debug` green, AC1-AC4 traceability PASS, R-015.1
confirmed one canonical Drift class, ADR-007 bounds verified). Reviewer gate:
`review/review-report.md` Tier-3 final synthesis, 5/5 slices CLEAN,
`Outcome: CLEAN`. Merged into `codex/REQ-001_cupid_flutter_mobile_app-integration`
at merge commit `727677d93c2b0d00695653e4a88691735ac770ed` (hand-resolved
7-file merge conflict; `git-story-boundary.sh complete` confirmed
`MERGE_COMPLETE: true`).
Complexity: M
Epic: epic-5 (finance)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/expenses/`
Design reference: `cupid-mobile-design/` — finance/expenses screen group
(exact screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003.

## User Story
As a paired couple, we want to track shared expenses in the app so we have a
clear, agreed record of what we've spent together.

## In Scope
- Adding an expense entry (per `expenses` backend contract).
- Viewing shared expense history, backed by Drift per ADR-007 (OQ4 — one of
  the three domains explicitly named for Drift caching).

## Out of Scope
- Any `expenses` endpoint change (A1 frozen).
- Offline write/outbox queue for new expense entries — excluded by ADR-007.
- Any settlement/payment-processing logic beyond what the `expenses` contract
  itself provides (no new financial capability may be invented client-side).

## Acceptance Criteria
1. A paired user can add an expense entry.
2. Both partners can view shared expense history.
3. Expense history is readable offline via the Drift cache after at least
   one successful sync; new entries still require connectivity to write.
4. Unpaired users cannot access this feature.

## Open Items For Downstream Roles
- ~~Tech Lead: confirm exact `expenses` contract fields (currency, splitting
  logic if any) before coding-plan, so UI doesn't imply capabilities the
  backend doesn't have.~~ **RESOLVED** in `architecture/solution.md` §2 and
  ADR-015.2 / ADR-015.4 / ADR-015.4a: there is **no** `currency` field (VND is a
  fixed display unit) and **no** splitting/settlement/balance field of any kind.
  Additionally, "paid by" is **not** a client-settable field — the server derives
  `userId` from the JWT — so the UX spec's partner toggle is not implementable and
  ships as a display-only row.

## Tech Lead Outputs
- `architecture/solution.md` (v1.0, Final) — contract confirmation, ADR-015.1-015.7
- `coding-plan/master-plan.md` — phases P1-P6, single mobile lane
- R-015.1 (resolved) — two competing Drift owner classes were briefly in flight
  in this wave (STORY-007 `cupid_database.dart`, STORY-012 `app_database.dart`);
  canonicalized as `CupidDatabase` per ADR-010 before this story's merge, with
  `AppDatabase` folded in. See `system_architecture_memory.md` ADR-010.
