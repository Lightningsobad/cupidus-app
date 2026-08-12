---
story_status_recommendation: "IN_PROGRESS"
implementation_status_recommendation: "UNCHECK"
reviewed_at: 2026-08-12
reviewed_by: Reviewer
---

# Review Report: STORY-019 P1-Backend Slice — Love Contract Partner Visibility

Outcome: PATCH_REQUIRED

## Reviewed Inputs

- Review gate: `scoped-slice`
- Scope Gate: `inline` — slice boundary defined by team-lead handoff: backend
  half of AC1, AC2, AC3, AC4 only, scoped to the 5 files under
  `backend/src/modules/love-contracts/`
- Requirements: `story_master.md` Acceptance Criteria section (lines 112-129)
- Bug Report: `N/A`
- Diagnosis: `N/A`
- Fix Evidence: `N/A`
- UX: `N/A` (backend-only slice)
- Architecture: `architecture/solution.md` ADR-019a, ADR-019b, ADR-019e,
  ADR-019f, §5, §6; `architecture/contract-summary.md`
- Coding Plan: `coding-plan/phase-P1-backend-partner-signing.md`
- Test Results: `coding-plan/test-results.md` Phase P1 section
- Previous review findings: `N/A` (first pass)

## Reviewed Scope

- Story complexity: `standard`
- Bug status: `N/A`
- Code scope reviewed: `backend/src/modules/love-contracts/love-contracts.service.ts`,
  `love-contracts.controller.ts`, `love-contracts.module.ts`,
  `dto/love-contract-response.dto.ts` (new), `love-contracts.service.spec.ts`
  — P1-backend slice only, via
  `git -C <repo> diff 7f2e8ccc8fb8361d9c105fdd0d2f6469d31c20c4 -- backend/src/modules/love-contracts`
  (the new DTO file is untracked and does not appear in that diff; read
  directly)
- Evidence reviewed: `coding-plan/test-results.md` Phase P1 section
  (`npm test -- love-contracts`, `npm run build`)
- Risk surfaces reviewed: typed contract (response DTO shape), persistence
  lookup precedence (`findContractForUser`), state-transition/authorization
  guard (409 create guard, sign role branch, idempotency)
- Critical gates reviewed: backend targeted verification gates, resolver-
  precedence risk-surface test named in `architecture/solution.md` §6
- Backend targeted verification gates: `PATCH_REQUIRED`
- Story runtime startup smoke: `NOT_APPLICABLE` — `test-results.md` and the
  phase gate explicitly scope this phase to `npm test`/`npm run build` only
- Frontend targeted verification gates: `NOT_APPLICABLE` (backend-only slice)
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE`
- Mobile targeted verification gates: `NOT_APPLICABLE` (backend-only slice)
- Mobile discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement mobile visual audit: `NOT_APPLICABLE`
- Story artifacts reviewed: `story_master.md` (AC section only),
  `architecture/solution.md` (ADR-019a/b/e/f, §5, §6),
  `architecture/contract-summary.md`,
  `coding-plan/phase-P1-backend-partner-signing.md`,
  `coding-plan/test-results.md` (P1 section)
- Bug artifacts reviewed: `N/A`
- OQ context reviewed: `N/A` — not referenced by the handoff or this slice's
  scope

## AC Verification (backend half only)

| AC | Result | Evidence |
|---|---|---|
| AC1 — `partnerId` populated from paired `User.partnerId`, no schema change | PASS | `create()` sets `partnerId: user?.partnerId ?? undefined` on new rows; `findContractForUser` step 2 backfills once (ADR-019a). Tests: "writes partnerId from the paired User.partnerId...", "leaves partnerId null... unpaired requester", "resolves via the step-2 fallback and backfills partnerId..." |
| AC2 (backend half) — partner can acknowledge/accept via sign, transitions to `SIGNED_PARTNER` | PASS | `sign()` branches on `contract.requesterId === userId`; partner branch sets `signedAtPartner`/`SIGNED_PARTNER`, per-party idempotent, never clears the other party's timestamp (ADR-019b). Tests: "sets signedAtPartner and SIGNED_PARTNER when the partner signs, preserving signedAtRequester", "is idempotent when the caller has already signed" |
| AC3 (backend `viewerRole` half) | PASS | `LoveContractResponseDto.from()` computes `viewerRole` correctly; DTO field set/order matches `contract-summary.md` exactly; `getMyPending` returns `null` (not `DTO.from(null)`) when no contract exists. Test: "sets viewerRole to requester for the creator and partner for the other side" |
| AC4 (backend unpaired-caller guard regression) | PASS | `sign()` throws `NotFoundException` when `findContractForUser` resolves nothing; unreachable for an unpaired caller since step 2 requires non-null `User.partnerId`. Test: "throws NotFoundException for an unpaired caller with no contract (AC4 regression guard)" |

## Outcome Summary

- Review outcome: PATCH_REQUIRED
- Rationale: All four backend-half ACs are correctly implemented with passing
  test/build evidence, and ADR-019a/b/e/f are each matched by the diff. The
  blocker is narrower: `architecture/solution.md` §6's Risk Surface Gate table
  names a specific unit test as the minimum gate for the resolver-precedence
  risk and states explicitly "Blocker condition: either test absent or
  failing." `coding-plan/phase-P1-backend-partner-signing.md` §6 Test Scope
  item 5 requires the same test. The implemented test with a matching name
  does not construct the required scenario, so this named critical gate
  (SKILL.md rule 12c) is not satisfied as specified.
- Blocking findings: 1
- Deferred findings: 0
- Dismissed observations: 0

## Traceability Summary

- Requirements: `story_master.md` AC1-AC4 (lines 112-129) — backend half only
- Bug report: `N/A`
- Diagnosis: `N/A`
- Open Questions: `N/A`
- UX: `N/A`
- Architecture: ADR-019a/b/e/f verified against implementation; §6 Risk
  Surface row 2 not fully satisfied
- Testing evidence: `coding-plan/test-results.md` P1 section — 13/13 tests
  passed, `npm run build` clean; one required test from the phase's own Test
  Scope is missing

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|---|---|---|---|---|
| Duplicate contract row via partner `POST` | solution.md §6 row 1 | P1 409-guard unit test | PASS | `create()` throws `ConflictException` when caller is partner of an existing contract; test present and passing, `save` confirmed not called |
| Resolver precedence picks the partner's row | solution.md §6 row 2 | P1 unit test: caller who owns a contract AND is partner on another resolves to their own | FAIL | Named test not implemented as specified — see Blocking Findings |
| Signature survives a clause edit (ADR-019f) | solution.md §6 row 4 | P1 unit test asserting both timestamps null after edit | PASS | Test present and passing |
| AC4 weakened | solution.md §6 row 5 | P1 unpaired-caller test | PASS | Test present and passing |

## Blocking Findings

1. **[backend-dev] `backend/src/modules/love-contracts/love-contracts.service.spec.ts`**
   — Missing the required unit test for resolver precedence in the ambiguous
   two-row case: a caller who is `requesterId` on one contract row AND
   `partnerId` on a different contract row must resolve to their own
   (requester) row. This exact scenario is required by
   `coding-plan/phase-P1-backend-partner-signing.md` §6 Test Scope item 5 and
   named as a critical gate with an explicit blocker condition in
   `architecture/solution.md` §6 Risk Surface table, row 2. The existing test
   at `love-contracts.service.spec.ts:146`
   ("resolver precedence: a caller who owns a row resolves to it without the
   partner fallback") only mocks a single row and never constructs the
   two-row scenario. The underlying resolver
   (`findContractForUser` in `love-contracts.service.ts`) issues one query —
   `findOne({ where: [{ requesterId: userId }, { partnerId: userId }], order: { createdAt: 'DESC' } })`
   — ordered globally by `createdAt DESC` across both OR branches, with no
   logic that prioritizes an owned row over a partnered row. If the ambiguous
   case is reachable, the current implementation is not proven to satisfy
   ADR-019a's stated guarantee ("a caller who owns a contract must always
   resolve to their own row").

## Implementation Action Items

- `[backend-dev] backend/src/modules/love-contracts/love-contracts.service.spec.ts`:
  add the unit test named in the coding plan — mock a caller who is
  `requesterId` on one contract row and `partnerId` on a second, separate
  contract row, and assert `getMyContract`/`findContractForUser` resolves to
  the caller's own (requester) row. If that test reveals the resolver query
  needs to change to satisfy the precedence guarantee (e.g. checking the
  owned-row condition ahead of the partnered-row condition instead of one
  OR'd query ordered only by recency), update `findContractForUser`
  accordingly and re-run `cd backend && npm test -- love-contracts && npm run build`.
- Alternative: if tech-lead/team-lead determines the two-row scenario is
  genuinely unreachable under the current 1:1 `User.partnerId` pairing model,
  record that determination explicitly (e.g. an approved scope note in
  `architecture/solution.md` or `coding-plan/phase-P1-backend-partner-signing.md`)
  so this named critical gate is formally waived rather than silently unmet.

## Workflow State Recommendation

- Story status: `IN_PROGRESS` for this slice's scope; full story disposition
  depends on the other parallel slice reviews
- Bug status: `N/A`
- `Implementation (Development)`: `UNCHECK`
- `Review (Reviewer)`: `LEAVE_UNCHECKED`
- Next step: route the missing unit test (or an explicit tech-lead/team-lead
  waiver) back to backend-dev before this slice is folded into a full-story
  or final-synthesis review.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
