# solution.md — STORY-006 Love Contracts (client-only)

## 0. Metadata

- User Story ID: STORY-006
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-006_love_contracts/story_master.md`
- Complexity: M (Story-Class `standard`)
- Referenced Inputs: `story_master.md`; `ux/uiux-spec.md` §1-§9; `req_master.md`
  (STORY-006 row, A1 line 50, D2 line 58, OQ4/OQ5); `backend/src/modules/love-contracts/*`;
  `backend/src/modules/users/users.controller.ts` + `entities/user.entity.ts`;
  `mobile/lib/core/network/cupid_api.dart`; `mobile/lib/features/auth/data/auth_repository.dart`;
  `mobile/lib/core/di/service_locator.dart`; `mobile/lib/core/navigation/app_shell.dart`;
  `mobile/l10n.yaml`; `mobile/pubspec.yaml`; `data/devops/system/runtime-command-registry.json` (`mobile-app`)
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md` (not updated by this story)
- Solution Number: 006
- Version: v1.0
- Date: 2026-07-30
- Status: Final

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: None (Flutter client baseline from STORY-001/002/003/004 is reliable)
- Architecture Drivers: A1 frozen backend; D2 Bloc-for-ritual; D3 one adaptive widget tree;
  UX §9-1 partner-side capability gap; no `Me`/profile screen exists yet.
- Architectural invariants:
  - No file under `backend/` is touched by this story.
  - Feature code reaches REST only through `mobile/lib/core/network/cupid_api.dart`; never
    imports `package:cupid_api/...` directly and never constructs `Dio`.
  - No new pub dependency (`flutter_bloc` 9.1.1 and `get_it` 9.2.1 already present); no
    `freezed`, `bloc_test`, `bloc_concurrency`, `equatable`, or `build_runner` introduction.
  - `Key('home_screen_ready_signal')` in `home_screen.dart` must survive every edit — it is the
    `mobile-app` runtime readiness signal in the runtime command registry.
- Proposed technical direction: a self-contained `mobile/lib/features/love_contracts/` feature
  (data + presentation) driven by one full `Bloc` (ADR-006a), reading and writing the three
  frozen `love-contracts` endpoints through the shared `Dio` (ADR-006b), with a v1 contract
  model that is honest about the backend's creator-only capability (ADR-006c).
- Why this fits: identical layering to `features/auth` (sealed state classes, repository over
  `_api.dio`, `get_it` registration), so no new pattern enters the codebase.

## 2. Downstream Contract Summary

- Backend contract: **unchanged and unchangeable (A1).** Consumed exactly as-is:
  - `POST /love-contracts` body `{ "clauses": string[] }`, 1..20 items (`CreateContractDto`).
    Service upserts the caller's existing `created`/`signed_requester` row; re-saving after a
    signature resets `status` to `created` and clears `signedAtRequester`.
  - `PATCH /love-contracts/sign` (no body). Matches `{ requesterId: caller, status: created }`
    only; returns the already-signed row when `status = signed_requester`; otherwise 404
    `No pending contract found to sign`.
  - `GET /love-contracts/my-pending` returns the caller's single latest row or `null`.
  - `GET /users/me` returns the caller's `User` row including `displayName` and `partnerId`.
  - All four are declared with **no response schema**, so the generated client types them
    `Future<Response<void>>` and the body is unreachable through it.
- Frontend contract: not applicable (no web surface in this story).
- Mobile contract: `LoveContractRepository` + `LoveContractGateRepository` are the only
  love-contracts network owners; `LoveContractBloc` is the only state owner; the screen is
  reached from exactly one discoverable entry surface (§4 Entry Point).
- DevOps / environment contract: none. No env var, secret, port, or registry change.
- Requirement configuration guide impact: NOT_APPLICABLE.
- Data model / migration contract: none (no client persistence — see OQ4 row).
- API / event / worker queue contract: no realtime events. The partner's signature is not
  observable client-side in v1 (ADR-006c), so no `RealtimeCoordinator` subscription is added.
- Test and verification expectations: Dart unit tests for JSON mapping and error mapping, Bloc
  unit tests for the ceremony state machine and clause constraints, widget tests for the
  gate/entry-point/hold-control semantics, plus `flutter analyze` and `flutter test`
  (registry id `mobile-app`). No mobile e2e, no emulator lifecycle, no signing.
- Risk surfaces and verification contract: see §4 table.
- OQ constraints downstream lanes must preserve: OQ4 stays open (no Drift, no `hydrated_bloc`
  in this feature); OQ5 stays open (add both `app_vi.arb` and `app_en.arb` keys for parity, but
  do not add any locale/theme switch affordance).

## 3. Scope And Assumptions

- In Scope: `mobile/lib/features/love_contracts/**`, the two new ARB key sets, the
  `service_locator.dart` registrations, and one discoverable entry point mount.
- Out Of Scope: every `backend/` change; the `vow` screen (UX §1); a real `Me`/profile screen;
  partner-side signing and partner-visible contracts (ADR-006c); offline cache; realtime.
- Assumptions affecting design:
  - A-1: The partner's `displayName` is **not** resolvable from the backend (no `GET /users/:id`).
    STORY-005 is in flight on a sibling branch, so this story must not depend on its output.
    v1 therefore renders a localized neutral partner label and takes an optional
    `PartnerDisplayName` provider (a `String? Function()` registered in `service_locator.dart`
    returning `null` by default) so a later story can supply the real name without touching
    this feature's widgets. (UX §9-2 answered.)
  - A-2: No `Me`/profile screen exists (`app_shell.dart` boots `HomeScreen` directly), so the
    UX §3 "row on the `Me` screen" cannot be built as specified. v1 mounts the same
    list-item-style entry on `HomeScreen` instead; when the `Me` screen lands, the tile widget
    moves without change. Deviation recorded here rather than shipping an unreachable screen.
  - A-3: `GET /users/me` is not yet fetched anywhere in the app, so this story owns a narrow
    fetch of it for the AC4 gate. STORY-005 may add an overlapping current-user reader on its
    own branch; overlap is acceptable and reconciled at merge, and a consolidation note is left
    in §8 rather than blocking either story.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| OQ4 (offline: Drift vs `hydrated_bloc`) | OPEN | Any local persistence of love contracts | In-memory Bloc state, re-fetched on entry | Add no persistence layer; this feature is a single small object and does not force the OQ4 decision |
| OQ5 (light theme + EN in v1) | OPEN | Any locale or theme switch affordance | ARB keys in both `app_vi.arb` and `app_en.arb` | `app_vi.arb` stays the template locale (ADR-004e); parity test must stay green; nothing is user-switchable |
| OQ-006A (new, raised here) | OPEN — PO/user decision | Nothing (v1 ships under ADR-006c) | Creator-only create/sign/view per ADR-006c | See ADR-006c: AC2/AC3 are implemented at the capability the frozen backend actually has; the intended dual-signature ritual needs an A1 exception that this story does not take |

## 4. Architecture Delta

### ADR-006a — Full `Bloc`, not `Cubit`, for the ceremony flow (confirms D2)

`LoveContractBloc extends Bloc<LoveContractEvent, LoveContractState>`. Rationale: the signing
ritual is an ordered, guarded event sequence (`SignHoldStarted` → `SignHoldCompleted` |
`SignHoldCancelled`) whose legality depends on prior events, not just on current state; expressing
each ritual step as a first-class event makes the illegal transitions (sign with zero clauses,
double-submit while a request is in flight, complete a hold that was never started) testable as
event sequences and traceable via `onTransition`. Cubit's plain-method surface cannot express the
hold lifecycle as data. Every other CRUD-shaped screen in this app stays on `Cubit` per D2.

Concurrency without a new dependency: the Bloc guards re-entrancy with an explicit
`inFlight` flag on the ready state instead of `bloc_concurrency` transformers.

**Hold progress stays out of the Bloc.** The circular fill (`holdPct`/`holdInvPct`, ~1.5s dwell,
UX §5) is driven by a widget-local `AnimationController` in `HoldToSignButton`. Only the three
discrete lifecycle events cross the Bloc boundary. Streaming per-frame progress through Bloc
state is forbidden.

Events: `LoveContractOpened`, `ContractRetryRequested`, `ClauseToggled`, `CustomClauseAdded`,
`SignHoldStarted`, `SignHoldCancelled`, `SignHoldCompleted`.
States (sealed, hand-written `==`/`hashCode`, matching `SignOutState`'s style — no `freezed`,
no `equatable`): `LoveContractLoading`, `LoveContractReady`, `LoveContractLoadFailed`.
`LoveContractReady` carries `clauses`, `selectedClauseIds`, `signState`
(`unsigned | signedByMe | awaitingPartner`), `inFlight`, and `actionFailure`.

### ADR-006b — Read bodies from the shared `Dio`, not the generated client

`Epic1LoveContractsApi` and `Epic1UsersApi` return `Response<void>`, so response bodies are
unreachable through them. Follow the precedent already set in
`mobile/lib/features/auth/data/auth_repository.dart:94-112`: call
`_api.dio.get<Object?>('/love-contracts/my-pending')`,
`_api.dio.post<Object?>('/love-contracts', data: {...})`, and
`_api.dio.patch<Object?>('/love-contracts/sign')`, then map the raw JSON in a hand-written
`LoveContract.fromJson`. Rules: the repository catches `DioException` and rethrows
`e.error as CupidApiFailure` (set by `CupidErrorInterceptor`) — never a raw `DioException`; it
never leaks `Map<String, dynamic>` past its own boundary; unknown `status` strings and missing
fields map to defensive defaults rather than throwing.

### ADR-006c — v1 contract semantics: creator-only, honestly rendered

The frozen backend cannot support the dual-signature ritual: `LoveContract.partnerId` is never
assigned in `LoveContractsService.create()` (no such DTO field), `sign()` matches only
`{ requesterId: caller }`, `ContractStatus.SIGNED_PARTNER` is never produced, and
`getMyContract()`'s `partnerId` branch is therefore dead. A1 (`req_master.md` line 50) and the
story's own Out Of Scope both forbid changing it, and this handoff is client-only, so the only
A1-compliant reading is: **build the capability the backend has, and never render an affordance
that is guaranteed to 404.**

Client-observable model:

- AC1 — the caller creates/updates their own contract's clauses (`POST`). Satisfied fully.
- AC2 — the caller signs their own contract (`PATCH`). After a successful sign, the screen shows
  `signedByMe` plus an `awaitingPartner` informational line. It must **not** render a
  partner-facing sign affordance in this app version, because a partner tapping it would always
  receive 404. UX §6's "partner-sign-call error" copy is therefore a defensive fallback for the
  404 path, not a designed flow.
- AC3 — "list/detail of active contracts" resolves to the single current contract returned by
  `my-pending` (the endpoint returns one row, not an array). The partner cannot fetch the
  creator's contract; the partner entering the screen sees the empty/propose state.
- AC4 — satisfied client-side (§ Pairing Gate below); no backend guard exists.

Escalation OQ-006A: full AC2/AC3 dual-signature parity requires a narrowly scoped backend change
(populate `partnerId` from the pairing relationship on create; add a partner-aware branch to
`sign()`), which is an explicit A1 exception and a Product Owner / user decision. This story
ships option (b) — creator-only — and keeps the repository as the single seam so option (a)
later becomes a repository-and-state change with no widget rework.

### Boundaries And Ownership

- Owning module: `mobile/lib/features/love_contracts/`
  - `data/love_contract.dart` — client model, `ContractSignStatus`, `fromJson`
  - `data/love_contract_repository.dart` — the three love-contracts calls
  - `data/love_contract_gate_repository.dart` — `GET /users/me` → `{ displayName, partnerId }`
  - `presentation/love_contract_event.dart`, `love_contract_state.dart`, `love_contract_bloc.dart`
  - `presentation/screens/love_contract_screen.dart`
  - `presentation/widgets/clause_toggle_row.dart`, `hold_to_sign_button.dart`,
    `add_clause_sheet.dart`, `love_contract_entry_tile.dart`
- Shared files touched (narrow edits only): `mobile/lib/core/di/service_locator.dart`,
  `mobile/lib/features/home/presentation/home_screen.dart`,
  `mobile/lib/l10n/arb/app_vi.arb`, `mobile/lib/l10n/arb/app_en.arb`
- Shared patterns reused: `design_system` tokens/`ThemeExtension` and the four named adaptive
  widgets (`CupidHeader`, `CupidPrimaryButton`, `CupidAddAction`, `CupidTabBar`) — one widget
  tree, no per-platform screen fork (D3). No new token and no new adaptive widget.

### Entry Point (discoverability)

`LoveContractEntryTile` is a `--surf` card row with the `draw` icon and a chevron, mounted in
`HomeScreen`. It renders only when `partnerId != null` (hide-not-disable, UX §7). Tapping it
pushes `LoveContractScreen` with standard chrome and a back affordance. The screen is never
reachable by direct route only. `HomeScreen`'s existing `home_screen_ready_signal` key and
centred text stay in place.

### Pairing Gate (AC4)

`LoveContractGateRepository.fetch()` reads `GET /users/me` once when `HomeScreen` mounts the
tile. `partnerId == null` → tile absent. A failed gate fetch is treated as "not paired" (tile
absent) rather than surfacing an error on the home surface — a hidden optional entry point is
strictly safer than a broken one. The screen itself re-asserts the gate on open so a stale
navigation cannot reach a contract UI for an unpaired user.

### Contracts And Integrations

- Contract owner: backend (frozen). The client is a pure consumer.
- Connection pattern: `LoveContractScreen` → `LoveContractBloc` → `LoveContractRepository` →
  shared `Dio` (auth + error interceptors already installed). Dependency direction is one-way;
  no widget touches `Dio`.
- Example payload: `POST /love-contracts` `{"clauses":["Luôn nói thật","Không ngủ khi đang giận"]}`
  → `200` `{"id":"<uuid>","requesterId":"<uuid>","partnerId":null,"clauses":[...],
  "status":"created","signedAtRequester":null,"signedAtPartner":null,"createdAt":"...","updatedAt":"..."}`
- Error / retry / empty-state contract:
  - `my-pending` → `null` body ⇒ empty state (all preset clauses off, sign control disabled).
  - `sign` → 404 ⇒ mapped to the localized "can't sign right now" message (UX §6), never the raw
    server string, and never a `CupidApiFailure` type name.
  - `NetworkUnavailableFailure` / `TimeoutFailure` ⇒ inline retry banner above the card; the card
    chrome stays visible (UX §6). No full-screen error state.
  - `UnauthorizedFailure` ⇒ bubble to the existing session gate; this feature does not handle it.
  - No client retries and no idempotency token: `POST` is a per-requester upsert and `PATCH` is
    idempotent for an already-signed row, so re-submits are safe by the server's own semantics.
- Compatibility posture: additive client-only change; nothing else in the app depends on it.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Untyped response bodies | `backend/src/modules/love-contracts/entities/love-contract.entity.ts` | `LoveContract.fromJson` | Unit tests over recorded JSON incl. `null` body, unknown `status`, missing timestamps | Report `MOBILE_BLOCKED`; do not guess field names |
| Frozen creator-only capability | `love-contracts.service.ts` | ADR-006c state model | Bloc unit tests assert no partner-sign path is reachable; repository test asserts 404 maps to the localized sign-unavailable message | Escalate OQ-006A; do not add a backend change |
| Ceremony state machine | ADR-006a | `LoveContractBloc` transitions | Bloc unit tests for ordered hold events, zero-clause guard, `inFlight` re-entrancy | Report `MOBILE_BLOCKED` |
| Clause constraints 1..20 | `create-contract.dto.ts` | Bloc validation before submit | Bloc unit tests at 0, 1, 20, 21 clauses | Report `MOBILE_BLOCKED` |
| AC4 pairing gate | `user.entity.ts:33` (`partnerId`) | `LoveContractGateRepository` | Widget test: tile absent when `partnerId` null, present when set | Report `MOBILE_BLOCKED` |
| Custom-gesture accessibility | UX §8 | `HoldToSignButton` semantics | Widget test asserts a semantic activation action exists besides the raw hold, and toggle rows expose on/off state non-colour-only | Report `MOBILE_BLOCKED` |
| l10n parity | `mobile/l10n.yaml` (`app_vi.arb` template) | new ARB keys | Existing `mobile/test/l10n/arb_parity_test.dart` | Fix keys; never suppress the test |
| Runtime readiness regression | `data/devops/system/runtime-command-registry.json` (`mobile-app`) | `Key('home_screen_ready_signal')` | Existing `mobile/test/widget_test.dart` | Restore the key before completing the phase |

### Mobile Lane Handoff

- Responsibilities: the entire story. Mobile Developer is the only implementation lane.
- Authoritative inputs: this solution, the phase files, and the four backend source files named
  in §2. The backend source is read-only reference.
- UX dependencies: UX §4 (clause list + add-clause sheet + 1..20 enforcement), §5 (hold-to-sign
  states and copy), §6 (loading/empty/error), §7 (gate), §8 (accessibility). UX §3's `Me`-screen
  placement is superseded by A-2; UX §9-3's raw prototype labels/handlers must not be ported.
- Guardrails: no `backend/` edit; no new pub dependency; no direct `package:cupid_api` import; no
  new design token or adaptive widget; preserve `home_screen_ready_signal`.

### Backend / Frontend / DevOps Lane Handoff

- Backend: not participating (A1).
- Frontend: not participating (no web surface).
- DevOps: not participating. Requirement configuration guide update: NOT_APPLICABLE.

## 5. Non-Functional Impact

- Security / privacy: contract clauses are Level-2 data (UX §5 footer). They are never written to
  disk, never logged, and never included in error messages. Auth stays entirely with the existing
  Firebase interceptor.
- Reliability / performance: one `GET` on screen open, one `GET /users/me` on home mount; no
  polling and no realtime subscription. Per-frame hold animation stays widget-local (ADR-006a) so
  no state churn.
- Observability: no new logging surface; Bloc `onTransition` is sufficient for local diagnosis.
- Migration / rollout / rollback: none. Removing the entry tile fully hides the feature.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Request an A1 exception for a partner-aware `sign()` + `partnerId` on create | Only way to satisfy AC2/AC3 as literally worded (UX §9-1) | Rejected for this story | Backend is frozen, this handoff is client-only, and the change is a PO/user call — raised as OQ-006A |
| Cubit instead of Bloc | Matches every other screen so far | Rejected | D2 names the ritual flow as the Bloc case; ADR-006a explains why the hold lifecycle needs events |
| Generated `Epic1LoveContractsApi` for the calls | Preferred layering | Rejected | Returns `Response<void>`; response bodies unreachable (ADR-006b) |
| Stream hold progress through Bloc state | Single source of truth for the ritual | Rejected | ~60 emissions/second of state churn for a purely visual value |
| Mount the entry point on a new `Me` screen per UX §3 | Matches the UX spec literally | Deferred | No `Me` screen exists; building one is a separate story's scope (A-2) |

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| A reviewer reads AC2/AC3 literally and fails the story | Story rework | ADR-006c + OQ-006A state the capability limit and the decision explicitly, before implementation |
| `home_screen.dart` edited in parallel by STORY-005 | Merge conflict | Keep this story's edit to a single tile mount; overlap is reconciled at merge per the parallel policy |
| Duplicate current-user reader vs STORY-005 | Small duplication | Keep the gate repository inside this feature and record the consolidation note in §8 |
| Hold gesture inaccessible to switch/screen-reader users | A11y defect | UX §8 gate is a named risk surface with a widget-test minimum |
| Backend response shape drifts | Runtime mapping errors | Defensive `fromJson` with defaults plus unit tests over the recorded shape |

## 8. Handoff Notes

- Implementation guardrails: see Mobile Lane Handoff. Phases are in
  `../coding-plan/master-plan.md`; execute them in `P0 → P5` order.
- OQ-driven constraints to preserve: no persistence (OQ4); ARB parity with no user-facing
  locale/theme switch (OQ5); no backend change (A1); OQ-006A stays open and is not resolved by
  the implementation lane.
- Shared contract-first work required: none across lanes (single lane). Within the lane, `P0`
  produces the model/repository contract that `P1`-`P4` consume.
- SHARED_FOUNDATION_REQUIRED: NO

  Confirmation: stories are independent; no shared-foundation story is required for this wave.

- Consolidation follow-up (not this story): when STORY-005 has merged, fold
  `LoveContractGateRepository` and any pairing reader it introduces into one current-user/pairing
  source, and supply the real partner `displayName` through the `PartnerDisplayName` provider.
- Memory updates required: none. This story introduces no system-wide baseline change; ADR-006a
  through ADR-006c are story-local and stay in this file.
- Open questions / blockers: OQ-006A (Product Owner / user) — confirm the creator-only v1 wording
  of AC2/AC3, or authorise an A1 exception for the partner half. Non-blocking for implementation.
