# Slice Review: STORY-019 — P2 Mobile Data/State (Slice B)

Reviewer: Iris-QC
Scope: `Flow: story`, `Mode: scoped-slice`, `Slice: P2-mobile-data-state`
BaseHead: `7f2e8ccc8fb8361d9c105fdd0d2f6469d31c20c4`
Diff command used: `git diff 7f2e8ccc8fb8361d9c105fdd0d2f6469d31c20c4 -- mobile/lib/features/love_contracts/data mobile/lib/features/love_contracts/presentation/love_contract_bloc.dart mobile/lib/features/love_contracts/presentation/love_contract_state.dart mobile/test/features/love_contracts/data mobile/test/features/love_contracts/presentation/love_contract_bloc_test.dart`

Files reviewed (6, matches handoff list exactly):
- `mobile/lib/features/love_contracts/data/love_contract.dart`
- `mobile/lib/features/love_contracts/data/love_contract_repository.dart`
- `mobile/lib/features/love_contracts/presentation/love_contract_bloc.dart`
- `mobile/lib/features/love_contracts/presentation/love_contract_state.dart`
- `mobile/test/features/love_contracts/data/love_contract_repository_test.dart`
- `mobile/test/features/love_contracts/presentation/love_contract_bloc_test.dart`

## AC2 (partner sign-only branch, no clause save) — mobile data/state half

**PASS.**

- `love_contract_bloc.dart:_onSignHoldCompleted` calls `_repository.saveClauses(...)` only when `state.viewerRole == ContractViewerRole.requester`; the partner path calls `_repository.sign()` directly with no save call. Matches ADR-019e and closes the split-contract-row hazard in `architecture/solution.md` §1.
- `_onClauseToggled` / `_onCustomClauseAdded` both early-return when `!state.canEditClauses`, so a partner-viewer's `ClauseToggled`/`CustomClauseAdded` events are no-ops.
- `love_contract_state.dart`: `canEditClauses => viewerRole == ContractViewerRole.requester`; `canSign` extended to also require `signStatus == unsigned || signStatus == partnerAlreadySigned` (blocks re-sign after the viewer's own side is already signed).
- `viewerRole` is threaded end-to-end: default `requester` for the empty/no-contract state (`_load`), carried from the fetched contract into `_readyFromContract`, and re-synced from the `sign()` response (`signed.viewerRole`) after a successful sign.
- Test coverage in `love_contract_bloc_test.dart` (new group `viewer-aware sign flow (ADR-019e)`, 4 cases) exactly matches the phase's required test scope: partner viewer → `sign()` only, never `saveClauses()`; requester viewer → unchanged `saveClauses()` then `sign()`; partner `ClauseToggled`/`CustomClauseAdded` no-ops; already-signed viewer cannot re-sign (`canSign` false, no network call).
- Verified `selectedClauseIds` is populated from `contract.clauses` in `_readyFromContract` regardless of viewer role, so a partner viewing an existing (non-empty, backend-enforced `ArrayMinSize(1)`) contract satisfies `canSign`'s `selectedCount > 0` requirement without ever calling `ClauseToggled` — no dead-end where the partner could never sign.

## AC3 (viewer-aware `ContractSignStatus` derivation) — mobile data/state half

**PASS.**

- `love_contract.dart`: `ContractViewerRole { requester, partner }` added; `ContractSignStatus` replaced with `{ unsigned, signedByMe, partnerAlreadySigned, bothSigned }` — `awaitingPartner` deleted, not kept, per the phase spec.
- `status` getter derivation logic is a byte-for-byte match of `architecture/contract-summary.md` § Client Derivation Rule (viewerSigned/otherSigned relative to `viewerRole`; both null → unsigned; viewerSigned only → signedByMe; otherSigned only → partnerAlreadySigned; both set → bothSigned).
- `_viewerRoleFromJson` falls back to `requester` for null/unknown input; `fromJson` never throws for a null body, missing `clauses`, or missing timestamps (defensive defaults preserved).
- Doc comment at the top of `love_contract.dart` correctly drops the ADR-006b/ADR-006c "frozen backend / creator-only" framing and now cites ADR-019c/ADR-019d.
- `love_contract_repository_test.dart` group `LoveContract.status derivation (ADR-019c)` covers the full required 4×2 matrix (8 cases), including the regression case explicitly named in the phase spec — `signed_requester` viewed by the partner must resolve to `partnerAlreadySigned`, never `signedByMe` — which is asserted and passes.
- `love_contract_repository.dart` doc comments (`SignUnavailableFailure`, `sign()`) are correctly retargeted: the 404 case is now documented as "no contract exists for either party," and the stale ADR-006c "creator-only capability" framing is removed from the source.

## AC4 regression guard (not weakened)

**PASS.** Confirmed via `git diff --name-only` that neither `love_contract_gate_repository.dart` nor any file under `mobile/openapi/` appears in the diff — the AC4 pairing gate and the generated API client are untouched, consistent with `architecture/solution.md` §5 and the phase's "Do Not" list.

## Bounded compile-fix switch arm in `love_contract_screen.dart` (spot-check, not in the 6-file write scope)

This file is not part of the P2 slice's file list, and it is not covered by the bounded diff command given in this handoff. It was spot-checked only for the specific switch-arm mapping named in `phase-P2-mobile-viewer-aware-model.md` §3.

- The switch-arm control-flow mapping matches the P2 plan exactly: `partnerAlreadySigned → _SignPromptSection`, `bothSigned → _SignedConfirmationCard`.
- Caveat: because P2 and P3 landed as uncommitted working-tree changes on the same base (no intermediate commit separates them — `git log 7f2e8cc..HEAD` is empty), the current diff for this file also carries P3's copy/l10n/affordance additions (`acknowledgmentLine`, `statusLine`, new l10n keys) layered on the same switch arm. That is expected accumulation, not a P2 boundary violation — the switch-arm *structure* P2 owns is correct — but full verification of the copy/CTA content is P3 scope and is explicitly out of this slice's review.

## Test evidence

Independently reran both gate commands from `phase-P2-mobile-viewer-aware-model.md` §6 rather than relying solely on documentary evidence (see Issue below):

- `cd mobile && flutter test test/features/love_contracts/data test/features/love_contracts/presentation/love_contract_bloc_test.dart` → **44/44 passed**, including all 8 derivation-matrix cases and all 4 viewer-aware sign-flow cases.
- `cd mobile && flutter analyze` scoped to the 6 slice files → **No issues found! (ran in 1.7s)**

## Issue (non-blocking, evidence/process gap)

**`coding-plan/test-results.md` has no dedicated "Phase P2" section.** The file contains only "Phase P1 (backend-dev)" and "Phase P3 (mobile-dev)" headings. `phase-P2-mobile-viewer-aware-model.md` §6 requires "Record evidence in `coding-plan/test-results.md` before `MOBILE_COMPLETE: YES`" for the P2-scoped `flutter test`/`flutter analyze` gate, and the Phase P3 section's own `flutter analyze` note ("confirmed in P2, reconfirmed here") implies a P2 confirmation happened but was never captured as its own record in this artifact.

This is not a functional defect — I independently reran both P2 gate commands above and both pass cleanly, so the code itself satisfies the gate. But the required artifact trail is incomplete. Recommend adding an explicit "Phase P2" section to `test-results.md` (targeted `flutter test` output + scoped `flutter analyze` result) before this story is marked `DONE`, so the story's evidence trail doesn't rely on a reviewer's out-of-band rerun.

## Verdict

AC2 and AC3 (mobile data/state half): **PASS**, with fresh independent test/analyze evidence. One non-blocking documentation gap noted above (missing Phase P2 section in `test-results.md`) — does not change the PASS verdict for this slice's code, but should be closed before final story closure.

REVIEW_SLICE_COMPLETE: YES
