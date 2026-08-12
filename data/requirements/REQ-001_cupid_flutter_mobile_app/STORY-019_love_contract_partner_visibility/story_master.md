# Story Master: STORY-019 Hardening - Love Contract Partner Visibility (Retro-Audit RED-PATCH)

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-001
Retro-Type: RED-PATCH
Fixes: STORY-006 AC2 ("The partner can view and acknowledge/accept it per the
backend's supported flow.") and AC3 ("Both partners can view the list/detail
of active love contracts.")
Source: `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`
§ Open Question Triage / Approved Scope Change, entry "2. STORY-006 OQ-006A —
dual-signature contract ritual reduced to creator-only capability"
(`retro-audit/audit-report.md`, Audit Date 2026-08-12, ruling recorded
2026-08-12).

## Depends On
- NONE. STORY-017 and STORY-018 are both DONE; this ruling explicitly states
  no further PO decision is required before this story starts.

## User Story
As a paired partner who did not create the love contract, I want to view it
and acknowledge/accept it exactly as the creating partner can, so the
dual-signature commitment ritual works for both people in the pair, not just
the one who tapped "create."

## Background / Confirmed Defect
The ruling in `req_master.md` entry #2 is final: STORY-006 AC2/AC3 were
already correct as written; the shipped creator-only capability
(`architecture/solution.md` ADR-006c) is a **build defect**, not an approved
scope cut. AC2/AC3 text is unchanged and must be implemented exactly as
originally written.

Verified against current code (`backend/src/modules/love-contracts/`,
`backend/src/modules/users/entities/user.entity.ts`,
`mobile/lib/features/love_contracts/`):

1. **View defect (confirmed, matches original diagnosis).**
   `LoveContractsService.create()` never sets `partnerId` on the created
   `LoveContract` row. `getMyContract()` looks up
   `{requesterId: userId} OR {partnerId: userId}`, so the partner's branch can
   never match — the partner cannot see the contract at all.
   `User.partnerId` (`backend/src/modules/users/entities/user.entity.ts`) is
   already a persisted pairing field, populated at pairing time and already
   read by other modules (e.g. `dream-jar.service.ts`'s
   `getCoupleIdForUser()`, `common/utils/couple.util.ts`). `LoveContract`
   already has a nullable `partnerId` column
   (`entities/love-contract.entity.ts`). **No schema change is required** —
   the fix is to read the requester's paired `User.partnerId` at contract
   create time and write it onto the `LoveContract` row.

2. **Acknowledge/accept defect (found during this story's verification —
   broader than the view-only defect the diagnosis summary described).**
   Even after (1) is fixed, `LoveContractsService.sign()` is hardcoded to the
   requester: it queries `{requesterId: userId, status: CREATED}` and always
   writes `ContractStatus.SIGNED_REQUESTER` + `signedAtRequester`. If the
   partner calls `PATCH /love-contracts/sign`, the query can never match
   (the row's `requesterId` is the creator, not the partner), so the partner
   gets the same 404 the mobile client already special-cases as
   `SignUnavailableFailure` (`love_contract_repository.dart` line 6-13,
   explicitly commented as "ADR-006c creator-only capability"). The
   `ContractStatus.SIGNED_PARTNER` enum value and `signedAtPartner` column
   already exist on the entity but are never written by any code path today.
   AC2's "acknowledge/accept" clause cannot be satisfied by the view fix
   alone; `sign()` (or an equivalent partner-facing action) must also branch
   on whether the caller is the requester or the partner and transition to
   `SIGNED_PARTNER`/`signedAtPartner` accordingly.

3. **Mobile status interpretation is viewer-agnostic.**
   `LoveContract.fromJson` (`mobile/lib/features/love_contracts/data/love_contract.dart`)
   maps the raw `status` string to `ContractSignStatus` (`signedByMe` /
   `awaitingPartner`) the same way regardless of which partner is viewing.
   Once the partner can legitimately call sign/acknowledge, this mapping is
   wrong from the partner's point of view (e.g. `signed_requester` should read
   as "your partner already signed, your turn" when the partner is viewing,
   not `signedByMe`). This is in scope only insofar as it blocks a correct
   partner acknowledge/accept experience — it is an implementation detail for
   Tech Lead/Mobile Developer to solve, not a new PO scope decision.

## In Scope
1. Backend: populate `LoveContract.partnerId` from the requester's paired
   `User.partnerId` at contract create time, so `getMyContract()`'s
   `{partnerId: userId}` branch matches for the partner (restores AC3 view
   parity and is a precondition for AC2).
2. Backend: allow the partner (not just the requester) to acknowledge/accept
   the contract via the backend's supported flow, transitioning the contract
   to reflect the partner's acknowledgement (`SIGNED_PARTNER` /
   `signedAtPartner`) distinctly from the requester's own sign action. Exact
   endpoint shape (branch existing `PATCH /love-contracts/sign` on caller
   identity vs. a new partner-facing route) is a Tech Lead implementation
   decision, not a PO scope item.
3. Mobile: both partners can view the list/detail of the active love
   contract, and the sign/acknowledge status shown to each partner is correct
   for that partner's own role in the contract (not silently mislabeled as in
   item 3 of Background above).
4. Both partners can invoke acknowledge/accept from their own device once the
   contract exists and they are paired to it.

## Out of Scope
- STORY-006 AC1 (create/propose flow) — already confirmed working, not
  touched.
- STORY-006 AC4 (unpaired users cannot access this feature) — already
  confirmed working, not touched.
- Any love-contracts endpoint contract change beyond what is strictly needed
  to let the partner acknowledge/accept (no new clause types, no new contract
  statuses beyond the already-defined `SIGNED_PARTNER`, no renegotiation/
  editing flow for the partner).
- The chat-screen "ghost state" mount work (separate story).
- The privacy/notifications capability work (separate story, STORY-016 scope).

## Acceptance Criteria
1. `partnerId` is populated on the love contract at create/pairing time from
   the requester's existing paired `User.partnerId`, with no new persisted
   field or schema change, so the partner's own `GET /love-contracts/my-pending`
   fetch returns the contract.
2. The partner can view and acknowledge/accept the love contract per the
   backend's supported flow (STORY-006 AC2, carried forward unchanged): the
   partner's acknowledge/accept action transitions the contract to a
   partner-signed state (`SIGNED_PARTNER`, `signedAtPartner` set) distinct
   from the requester's own signed state, and this is reachable from the
   partner's own device/session — not creator-only.
3. Both partners can view the list/detail of active love contracts (STORY-006
   AC3, carried forward unchanged), and each partner's view of sign status
   correctly reflects their own role (i.e., a partner who has not yet signed
   is never shown as having already signed, and vice versa).
4. Unpaired users still cannot access this feature (STORY-006 AC4 regression
   guard — this story must not weaken that gate while fixing partner
   visibility).

## Open Items For Downstream Roles
- [Tech Lead] Decide the exact endpoint/branching shape for partner-side
  acknowledge/accept (reuse `PATCH /love-contracts/sign` with
  requester/partner branching on the authenticated caller vs. a new route),
  and how `LoveContract.partnerId` is populated at create time (denormalized
  read of `User.partnerId` at write time vs. computed at query time) — both
  are implementation decisions within this story's approved AC2/AC3 scope,
  not further PO scope items.
- [Tech Lead / Mobile Developer] Decide how `ContractSignStatus` (or its
  mobile model) becomes viewer-aware so each partner sees accurate sign state
  for their own role, per AC3 above.

## Role Completion
- [x] Product Owner — AC1-4 fixed directly from the ruling in
  `req_master.md` § Open Question Triage / Approved Scope Change, entry 2; no
  separate Product Owner delegation required, per this story's own "Depends
  On" note.
- [x] UI/UX Designer — `ux/uiux-spec.md` (per-viewer sign-state table §2 and
  the new partner-already-signed/both-signed states §3).
- [x] Architecture (Tech Lead) — `architecture/solution.md` (ADR-019a-f) +
  `architecture/contract-summary.md` (frozen cross-lane response contract) +
  `coding-plan/master-plan.md` (3-phase shared plan, P1 backend / P2+P3
  mobile).
- [x] Implementation (Development) — P1 backend by `Abert-BE`, P2+P3 mobile
  by `Alex-Mobile-Dev`, all `DONE` in `coding-plan/master-plan.md` § Phases
  Overview. The P1 resolver-precedence test-scope gap found by the Slice A
  review was closed (`findContractForUser` split into two sequential ordered
  queries) and independently re-verified against the diff during final
  synthesis.
- [x] Review (Reviewer) — `Outcome: DEFERRED_ONLY`, 0 blocking findings, all
  4 ACs PASS across all 3 lanes. One non-blocking deferred finding (missing
  "Phase P2" section in `coding-plan/test-results.md`; the underlying P2 code
  was independently confirmed passing by fresh test/analyze reruns) carried
  forward, not required to close this story. Tier 3 scoped-slice + final
  synthesis across `review/slice-P1-backend-review-report.md`,
  `review/slice-P2-mobile-data-state.md`,
  `review/slice-P3-mobile-ui-visual-fidelity.md`, and
  `review/review-report.md`, by `Iris-QC`, 2026-08-12.
