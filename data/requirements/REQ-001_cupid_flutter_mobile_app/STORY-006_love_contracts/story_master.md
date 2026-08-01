# Story Master: STORY-006 Epic-1 — Love Contracts / Nghi Thức Cam Kết

Status: DONE — fully reviewed and merged. P0-P5 implementation DONE,
story-scoped Reviewer returned `Outcome: CLEAN` (story branch HEAD
`cdbb75f0835efc02add70f6d77ce01594cd21e70`). AC1-AC4 verified at the
ADR-006c capability (OQ-006A recorded open/non-blocking). Merged into
`codex/REQ-001_cupid_flutter_mobile_app-integration` at merge commit
`23ca3b5ea767b1b6616028ed26f358f6867c6fdd` (additive conflicts in
`service_locator.dart`, `home_screen.dart`, `app_en.arb`, `app_vi.arb`
resolved inline as a union of both sides). See scrum-master-checkpoint.md.
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

## Role Completion

- [x] Architecture (Tech Lead) — `architecture/solution.md` v1.0 (ADR-006a..c)
  and `coding-plan/` (master-plan + P0-P5 + coding-agent-guide), 2026-07-30.
- [x] Mobile (Mobile Developer) — all phases DONE: P0 (contract/data layer),
  P1 (ceremony bloc), P2 (`LoveContractScreen`/`ClauseToggleRow`/
  `AddClauseSheet` + ARB), P3 (hold-to-sign gesture + fork-guard-fix), P4
  (entry point/pairing gate on `HomeScreen`), P5 (consolidated AC1-AC4
  verification: `flutter test` 170/170 PASS, `flutter analyze` clean). See
  `coding-plan/master-plan.md` §7 Result Log and `coding-plan/test-results.md`
  for full evidence.
- [x] Review (Reviewer) — `review/review-report.md`, `Outcome: CLEAN`,
  2026-07-31.

## Open Items For Downstream Roles
- [DONE — Tech Lead] Architecture (Tech Lead): `architecture/solution.md`
  (v1.0, ADR-006a..c) plus the coding-plan bundle (`coding-plan/master-plan.md`,
  `coding-agent-guide.md`, `phase-P0`..`phase-P5`). D2 confirmed: full `Bloc`
  (not Cubit) for the ceremony flow (ADR-006a), with the hold-progress animation
  kept widget-local. Bodies are read from the shared `Dio` because the generated
  client types these endpoints `Response<void>` (ADR-006b). Single mobile lane,
  strictly sequential `P0 → P5`; no backend, frontend, or devops phase; no new
  pub dependency.
- [NEW — Product Owner / user] OQ-006A: the frozen backend cannot support the
  dual-signature ritual (`partnerId` is never assigned on create, `sign()`
  matches the requester only, `SIGNED_PARTNER` is never produced), so AC2/AC3
  ship at creator-only capability per ADR-006c. Confirm that v1 wording, or
  authorise a narrow A1 exception for the partner half. Non-blocking for
  implementation.
- [Tech Lead note] UX §3's `Me`-screen entry point is superseded: no `Me` screen
  exists yet, so the discoverable entry tile mounts on `HomeScreen` (solution
  §3 A-2). UX §9-2 answered: the partner's `displayName` is not resolvable from
  the backend, so v1 renders a neutral localized partner label behind an
  injectable provider.
