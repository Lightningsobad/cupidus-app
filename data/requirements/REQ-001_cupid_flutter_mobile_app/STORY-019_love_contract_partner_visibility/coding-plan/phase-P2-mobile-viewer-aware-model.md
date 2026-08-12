# P2 — Mobile: viewer-aware contract model and sign flow

Status: DONE

Owner: mobile-dev | Lane: mobile | Depends On: P1 (contract only) | Runtime id: `mobile-app`
Contract: `../architecture/contract-summary.md` (authoritative — may start
before P1 lands; do not invent fields beyond it)

## 1. Goal

Make sign state a function of *who is viewing*, and stop the partner from ever
writing clauses. AC2 and AC3 (mobile data/state half).

## 2. Write Scope

- `mobile/lib/features/love_contracts/data/love_contract.dart`
- `mobile/lib/features/love_contracts/data/love_contract_repository.dart`
- `mobile/lib/features/love_contracts/presentation/love_contract_bloc.dart`
- `mobile/lib/features/love_contracts/presentation/love_contract_state.dart`
- `mobile/test/features/love_contracts/data/love_contract_repository_test.dart`
- `mobile/test/features/love_contracts/presentation/love_contract_bloc_test.dart`
- `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`
  — **compile-keeping switch arms only** (see §3); P3 owns this file's copy,
  CTA, and affordance work.

## 3. Implementation

**`love_contract.dart`.** Add `enum ContractViewerRole { requester, partner }`.
Replace the enum values `ContractSignStatus { unsigned, signedByMe,
awaitingPartner }` with `{ unsigned, signedByMe, partnerAlreadySigned,
bothSigned }` — `awaitingPartner` is deleted, not kept: it was the
viewer-agnostic mislabel in `story_master.md` finding 3, and its real meaning
("I signed, waiting for them") is already `signedByMe`'s status line.

Parse `viewerRole`, `signedAtRequester`, and `signedAtPartner`; derive
`status` with the rule in `contract-summary.md` §Client Derivation Rule. Stop
reading the raw `status` string entirely (ADR-019c). `fromJson` must still
never throw: unknown/missing `viewerRole` falls back to `requester`, missing
timestamps to null, and the update the doc comment at the top of the file to
drop the ADR-006b/ADR-006c "frozen backend / creator-only" framing.

**`love_contract_repository.dart`.** Keep the `SignUnavailableFailure`
extension but retarget it: a 404 from `PATCH /love-contracts/sign` now means
"no contract exists for either party", not "creator-only capability". Rewrite
the extension's and `sign()`'s doc comments accordingly — the ADR-006c
rationale is now false and must not survive in the source.

**`love_contract_state.dart`.** Add `final ContractViewerRole viewerRole` to
`LoveContractReady` (default `requester` for the no-contract/empty state), and
include it in `copyWith`, `==`, and `hashCode`. Add
`bool get canEditClauses => viewerRole == ContractViewerRole.requester`.
`canSign` additionally requires that the viewer has not already signed:
`signStatus == unsigned || signStatus == partnerAlreadySigned`. Delete the
"never exposes a partner-side signing affordance (ADR-006c)" comment.

**`love_contract_bloc.dart` (ADR-019e — the critical branch).** In
`_onSignHoldCompleted`, call `_repository.saveClauses(...)` **only** when
`state.viewerRole == requester`. The partner path calls `_repository.sign()`
directly. This is the fix for the split-state hazard in `solution.md` §1:
`POST /love-contracts` upserts by `requesterId`, so a partner-side save would
create a second contract row. Also reject `ClauseToggled` and
`CustomClauseAdded` when `!state.canEditClauses`. Carry `viewerRole` from the
fetched contract into `_readyFromContract`.

**`love_contract_screen.dart` — bounded compile fix.** The screen switches
exhaustively on `ContractSignStatus`, so removing `awaitingPartner` breaks the
build. Update only that switch: `partnerAlreadySigned` → `_SignPromptSection`,
`bothSigned` → `_SignedConfirmationCard`. No copy, l10n, layout, or affordance
changes here — those are P3's, and touching them from this phase will collide.

## 4. Do Not

- Do not read the raw `status` string to pick a UI state.
- Do not touch `love_contract_gate_repository.dart` or the AC4 gate.
- Do not add a partner clause-editing path of any kind.
- Do not regenerate `mobile/openapi` — no endpoint shape changed.

## 5. Interfaces Published

`ContractViewerRole`, the four `ContractSignStatus` values, and
`LoveContractReady.viewerRole`/`canEditClauses`. P3 consumes these.

## 6. Test Scope

`love_contract_repository_test.dart`:
- The full derivation matrix — 4 timestamp combinations x 2 viewer roles = 8
  cases — asserting the exact `ContractSignStatus` from
  `contract-summary.md`. The `signed_requester`-viewed-by-partner case is the
  regression this story exists for: it must be `partnerAlreadySigned`, never
  `signedByMe`.
- `fromJson` defensive defaults: null body fields, unknown `viewerRole`,
  missing timestamps, missing `clauses`.

`love_contract_bloc_test.dart`:
- Partner viewer + completed hold → `sign()` called, `saveClauses()` **never**
  called.
- Requester viewer + completed hold → `saveClauses()` then `sign()`, unchanged.
- Partner viewer → `ClauseToggled` / `CustomClauseAdded` are no-ops.
- A viewer who already signed cannot re-sign (`canSign` false).

Gate: `cd mobile && flutter test test/features/love_contracts/data
test/features/love_contracts/presentation/love_contract_bloc_test.dart` green
and `flutter analyze` clean (the §3 compile fix is what keeps it clean). The
existing screen tests must also still pass unchanged — if one needs new copy to
pass, that is P3's work, not a reason to edit the screen further here. Record
evidence in `coding-plan/test-results.md` before `MOBILE_COMPLETE: YES`.
