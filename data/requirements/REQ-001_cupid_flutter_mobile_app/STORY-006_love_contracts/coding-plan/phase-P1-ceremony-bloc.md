# Phase P1 – Ceremony Bloc

## 1. Objective

Implement the ritual state machine as a full `Bloc` (ADR-006a, confirming D2): ordered hold
lifecycle events, clause-selection rules within the backend's 1..20 bounds, guarded re-entrancy,
and the ADR-006c creator-only sign semantics.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-ceremony-bloc.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/love_contracts/presentation/love_contract_event.dart`
  - `mobile/lib/features/love_contracts/presentation/love_contract_state.dart`
  - `mobile/lib/features/love_contracts/presentation/love_contract_bloc.dart`
  - `mobile/test/features/love_contracts/presentation/love_contract_bloc_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` — not run in this phase
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `LoveContractEvent` (`LoveContractOpened`, `ContractRetryRequested`, `ClauseToggled`,
    `CustomClauseAdded`, `SignHoldStarted`, `SignHoldCancelled`, `SignHoldCompleted`)
  - `LoveContractState` (`LoveContractLoading`, `LoveContractReady`, `LoveContractLoadFailed`)
  - `LoveContractBloc`
- Shared Interfaces Consumed:
  - P0's `LoveContractRepository`, `LoveContract`, `ContractSignStatus`, `PartnerDisplayName`
- Risk Surfaces:
  - Ceremony state machine (ADR-006a)
  - Clause constraints 1..20
  - Creator-only backend capability (ADR-006c)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` ADR-006a and ADR-006c
  - consumer contract: `LoveContractState` as consumed by P2, P3, P4 widgets
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` ADR-006a, ADR-006c
  - upstream phase outputs: P0's `love_contract.dart` and `love_contract_repository.dart`
  - style reference: `mobile/lib/features/auth/presentation/sign_out_cubit.dart`
    (sealed state classes, hand-written, no `freezed`/`equatable`)
  - OQ constraints: `../architecture/solution.md` §3 (no persistence per OQ4)
  - UX constraints: `../ux/uiux-spec.md` §4 (1..20 enforcement and "at least one clause before
    signing") — the only UX-derived rule this phase needs
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: the full ritual state machine, independently testable without widgets
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` ADR-006a, ADR-006c
- P0 outputs in `mobile/lib/features/love_contracts/data/`
- `mobile/lib/features/auth/presentation/sign_out_cubit.dart`
- `../ux/uiux-spec.md` §4 (clause bounds and sign-enablement rule only)

## 3. Tasks

- Define the sealed `LoveContractEvent` hierarchy listed above.
- Define the sealed `LoveContractState` hierarchy with hand-written `==`/`hashCode`:
  - `LoveContractLoading`
  - `LoveContractReady { presetClauses, customClauses, selectedClauseIds, signStatus,
    partnerDisplayName, inFlight, actionFailure }`
  - `LoveContractLoadFailed { failure }`
- Implement `LoveContractBloc`:
  - `LoveContractOpened` / `ContractRetryRequested` → emit `LoveContractLoading`, call
    `fetchCurrent()`; `null` → ready-empty (all presets deselected, sign disabled);
    a contract → ready with its clauses selected and the mapped `signStatus`; failure →
    `LoveContractLoadFailed`.
  - `ClauseToggled` → pure state update; never calls the network.
  - `CustomClauseAdded` → append after trimming; reject empty/whitespace-only strings; reject when
    total selected clauses already equal 20 (`ArrayMaxSize(20)`).
  - `SignHoldStarted` → no-op unless at least one clause is selected and `inFlight` is false
    (this is what disables the ritual, per UX §4/§5).
  - `SignHoldCancelled` → clear any pending sign intent with no network call and no partial state.
  - `SignHoldCompleted` → guard on `inFlight`; set `inFlight: true`; `saveClauses(selected)` then
    `sign()` in that order (the backend upsert resets a signed row to `created`, so clauses must be
    saved before signing); on success emit `signStatus: signedByMe` with the awaiting-partner
    informational flag; on failure emit ready with `actionFailure` set and `inFlight: false`.
  - Never emit a state that offers a partner-side signing action (ADR-006c).
- Read `partnerDisplayName` from the injected `PartnerDisplayName` provider once when loading;
  a `null` result leaves the field null so P2/P3 can render the neutral localized label.
- Do not persist any state; do not add a `bloc_concurrency` transformer; use the `inFlight` guard.
- Write `love_contract_bloc_test.dart` with plain `flutter_test` (no `bloc_test` dependency):
  drive `bloc.add(...)` sequences and assert emitted states via `expectLater(bloc.stream, ...)`.

## 4. Acceptance Criteria

- `LoveContractBloc extends Bloc<LoveContractEvent, LoveContractState>`; it is not a `Cubit`.
- No per-frame hold progress value exists in any state class.
- Signing is unreachable with zero selected clauses.
- A 21st clause is rejected and a whitespace-only custom clause is rejected.
- `SignHoldCompleted` arriving twice in a row produces exactly one save+sign pair.
- `SignHoldCancelled` after `SignHoldStarted` produces no network call.
- `saveClauses` is always called before `sign` in the completed-hold path.
- No state exposes a partner-sign affordance flag.
- No new pub dependency is added.

## 5. Planned Outputs

- Code files: the three `presentation/` files in Write Scope
- Contracts: `LoveContractEvent`, `LoveContractState`, `LoveContractBloc`
- Requirement configuration guide updates: none
- Notes or evidence: concise rows in `test-results.md` (P5 consolidates)

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile` package), Bloc unit level — no widget tree
- Required levels:
  - unit: load success / empty / failure; retry after failure; clause toggle purity; custom clause
    trim and reject rules; clause counts at 0, 1, 20, 21; hold started → cancelled (no call);
    hold started → completed (save then sign, ordered); double-completed re-entrancy guard;
    sign failure keeps the ready state with `actionFailure` and `inFlight: false`
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks:
  - `flutter test test/features/love_contracts/presentation/love_contract_bloc_test.dart`
  - `flutter analyze`
- Mobile discoverability / navigation integration: N/A for this phase (owned by P4)
- Minimum gates by risk surface:
  - ceremony state machine → the ordered hold-event tests and the re-entrancy test
  - clause constraints → the 0/1/20/21 boundary tests
  - creator-only capability → assert no emitted state carries a partner-sign action
- Required regression or contract coverage: P0's data tests must stay green
- Evidence format: concise rows in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: the new bloc test file plus P0's data tests
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: the emitted state sequence and the recorded repository call order

## 7. Status

- Status: DONE
- Last updated: 2026-07-30

## 8. Implementation Evidence

- `mobile/lib/features/love_contracts/presentation/love_contract_event.dart`:
  sealed `LoveContractEvent` with the seven events named in §1B — no state,
  no logic.
- `mobile/lib/features/love_contracts/presentation/love_contract_state.dart`:
  sealed `LoveContractState` (`LoveContractLoading`, `LoveContractReady`,
  `LoveContractLoadFailed`) with hand-written `==`/`hashCode` (using
  `package:flutter/foundation.dart`'s `listEquals`/`setEquals`, not
  `equatable`), plus the `LoveContractClause { id, text }` value type.
  `LoveContractReady` carries `presetClauses`, `customClauses`,
  `selectedClauseIds`, `signStatus` (P0's `ContractSignStatus`),
  `partnerDisplayName`, `inFlight`, `actionFailure`
  (`CupidApiFailure?`). No field offers a partner-sign affordance
  (ADR-006c).
- `mobile/lib/features/love_contracts/presentation/love_contract_bloc.dart`:
  `LoveContractBloc extends Bloc<LoveContractEvent, LoveContractState>`
  (not a `Cubit`). `LoveContractOpened`/`ContractRetryRequested` fetch via
  P0's `LoveContractRepository.fetchCurrent()` and reconcile the returned
  raw `clauses: string[]` against a fixed 4-item preset catalog (matching
  ids) vs. synthesized custom-clause ids. `ClauseToggled` and
  `CustomClauseAdded` are pure/local, both enforcing the 20-clause cap
  (`CreateContractDto`'s `ArrayMaxSize(20)`); `CustomClauseAdded` also
  rejects empty/whitespace-only text after trimming. The hold ritual is
  guarded by a private `_holdAcknowledged` flag set only by a legal
  `SignHoldStarted` (>=1 clause selected, not `inFlight`) and consumed by
  the next `SignHoldCompleted` — this blocks the "complete a hold that was
  never started" illegal transition named in ADR-006a.
  `SignHoldCompleted` calls `saveClauses(selected)` then `sign()` in that
  order, setting `inFlight: true` synchronously before the first `await` so
  a second `SignHoldCompleted` arriving immediately after sees either
  `_holdAcknowledged == false` or `inFlight == true` and is a no-op — one
  save+sign pair per legal hold. `SignHoldCancelled` clears the
  acknowledgement with no network call and no state emission. The injected
  `String? Function() partnerDisplayName` provider parameter is
  structurally compatible with `service_locator.dart`'s `PartnerDisplayName`
  typedef without importing that file (avoids pulling the DI composition
  root into feature/bloc code).
- `mobile/test/features/love_contracts/presentation/love_contract_bloc_test.dart`:
  14 tests using a scripted `HttpClientAdapter` double (same pattern as
  P0's repository test, no mocking package) wired through the real
  `LoveContractRepository`/`CupidErrorInterceptor`, with a call-order log
  for save-then-sign assertions. Covers: load success/empty/failure and
  retry-after-failure; clause toggle purity (asserted via the adapter's
  call log staying at one `GET`); custom-clause trim/empty rejection;
  clause counts at 20 (accepted) and a 21st (rejected); hold
  started->cancelled (no network call); hold started->completed (ordered
  `POST` then `PATCH`); a `SignHoldCompleted` with no preceding
  `SignHoldStarted` (no-op); a second immediate `SignHoldCompleted`
  producing exactly one save+sign pair; and a sign failure (404) leaving
  `actionFailure` set with `inFlight: false` and `signStatus` unchanged.

## 9. Test Evidence

- `flutter test test/features/love_contracts/presentation/love_contract_bloc_test.dart`
  — 14/14 passed.
- `flutter test test/features/love_contracts/` (P0 regression + P1) —
  32/32 passed.
- `flutter analyze` on the four touched files (three P1 source files plus
  the new test file) — No issues found.
