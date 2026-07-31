# Story Master: STORY-015 Epic-5 — Chi Tiêu Chung (Expenses)

Status: IN_PROGRESS (UX spec + architecture + Tech Lead coding-plan P1-P6
DONE; P1 expense contract/models/repository DONE+committed `a1839dc`
(master-plan.md P1 synced DONE); P2-P6 NOT_STARTED. P2's canonical Drift
owner dependency (`CupidDatabase`, ADR-010, produced externally by STORY-007)
is now satisfied — STORY-007 merged to the integration branch — so P2 is
ready to dispatch.)
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
- Escalation for Scrum Master: **R-015.1** — two competing Drift owner classes are
  in flight in this wave (STORY-007 `cupid_database.dart`, STORY-012
  `app_database.dart`). The wave must canonicalize one before STORY-015 P2 merges.
