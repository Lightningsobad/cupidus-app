# Master Coding Plan – STORY-006 Love Contracts

## 1. Planning Metadata

- Story ID: STORY-006
- Complexity: M (Story-Class `standard`)
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md`
- Source UX: `../ux/uiux-spec.md` §4, §5, §6, §7, §8
- Source Architecture: `../architecture/solution.md`
- OQ Constraints Source: `../architecture/solution.md` §3 Open Question Constraints (OQ4, OQ5, OQ-006A)
- Review Input: none yet
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` — NOT_APPLICABLE for this story

## 2. Planning Goal

- Shared contract owner: backend (frozen, A1). Within the mobile lane, `P0` owns the client-side
  model and repository contract that all later phases consume.
- Contract-first phase required: YES (`P0`)
- Parallel execution possible: NO (single lane, strictly sequential `P0 → P5`)
- Critical path: `P0 → P1 → P2 → P3 → P4 → P5`
- Parallelism notes: every phase writes into the same feature package and depends on the previous
  phase's exported types, so no two phases have disjoint write scope. Do not fan out.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|---|---|---|---|---|---|
| `POST /love-contracts`, `PATCH /love-contracts/sign`, `GET /love-contracts/my-pending` | Backend (frozen, A1) | shared `Dio` via `mobile/lib/core/network/cupid_api.dart` | none (pre-existing) | P0 | `../architecture/solution.md` §2 + §4 "Example payload" |
| `GET /users/me` → `{ displayName, partnerId }` | Backend (frozen, A1) | shared `Dio` | none (pre-existing) | P0 | `backend/src/modules/users/entities/user.entity.ts:15,33` |
| `LoveContract` model + `ContractSignStatus` | Mobile | Dart types | P0 | P1, P2, P3 | `mobile/lib/features/love_contracts/data/love_contract.dart` |
| `LoveContractRepository` / `LoveContractGateRepository` | Mobile | `get_it` lazy singletons | P0 | P1, P4 | `mobile/lib/core/di/service_locator.dart` |
| `LoveContractEvent` / `LoveContractState` | Mobile | `flutter_bloc` | P1 | P2, P3, P4 | `mobile/lib/features/love_contracts/presentation/love_contract_state.dart` |
| ARB message keys (`loveContract*`) | Mobile | `AppL10n` generated from `app_vi.arb` | P2 (create), P3/P4 (extend) | P2, P3, P4 | `mobile/lib/l10n/arb/app_vi.arb` + `app_en.arb` |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|---|---|---|---|---|---|
| Untyped response bodies (`Response<void>`) | `backend/src/modules/love-contracts/entities/love-contract.entity.ts` | `LoveContract.fromJson` | unit tests over recorded JSON, `null` body, unknown `status` | none | `MOBILE_BLOCKED`; do not guess field names |
| Creator-only backend capability (ADR-006c) | `backend/src/modules/love-contracts/love-contracts.service.ts` | ADR-006c state model | repository test: sign 404 → localized sign-unavailable failure; bloc test: no partner-sign path | P0 | escalate OQ-006A; never add a backend change |
| Ceremony state machine (ADR-006a) | `../architecture/solution.md` ADR-006a | `LoveContractBloc` transitions | bloc unit tests for hold order, zero-clause guard, `inFlight` re-entrancy | P0 | `MOBILE_BLOCKED` |
| Clause constraints 1..20 | `backend/src/modules/love-contracts/dto/create-contract.dto.ts` | bloc validation before submit | bloc unit tests at 0, 1, 20, 21 clauses | P0 | `MOBILE_BLOCKED` |
| AC4 pairing gate | `backend/src/modules/users/entities/user.entity.ts:33` | `LoveContractGateRepository` | widget test: entry tile absent when `partnerId` null | P0 | `MOBILE_BLOCKED` |
| Custom-gesture accessibility | `../ux/uiux-spec.md` §8 | `HoldToSignButton` semantics | widget test: semantic activation action exists besides raw hold; toggle state not colour-only | P1 | `MOBILE_BLOCKED` |
| l10n parity | `mobile/l10n.yaml` (`app_vi.arb` is the template) | new `loveContract*` keys | existing `mobile/test/l10n/arb_parity_test.dart` | P2 | fix keys; never suppress the test |
| Runtime readiness regression | `data/devops/system/runtime-command-registry.json` (`mobile-app`) | `Key('home_screen_ready_signal')` | existing `mobile/test/widget_test.dart` | P4 | restore the key before completing P4 |

## 4. Lane Summary

- Backend required: NO (A1 frozen — no `backend/` file is touched)
- Frontend required: NO (no web surface)
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer (P0)
- Final verification owner: Mobile Developer (P5)
- Shared contract owner: backend (frozen); mobile-internal contract owner is P0
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source runtime registry
    `mobile-app.testCommand` = `flutter test`, `installCommand` = `flutter pub get`
    (Flutter SDK resolved via `FLUTTER_SDK_PATH`, default `$HOME/flutter` — it is not on `PATH`)

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | `mobile/lib/features/love_contracts/data/love_contract.dart`, `mobile/lib/features/love_contracts/data/love_contract_repository.dart`, `mobile/lib/features/love_contracts/data/love_contract_gate_repository.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/love_contracts/data/love_contract_repository_test.dart`, `mobile/test/features/love_contracts/data/love_contract_gate_repository_test.dart` | `../architecture/solution.md` §2, ADR-006b, ADR-006c; `backend/src/modules/love-contracts/entities/love-contract.entity.ts`; `backend/src/modules/love-contracts/dto/create-contract.dto.ts`; `backend/src/modules/love-contracts/love-contracts.service.ts`; `backend/src/modules/users/entities/user.entity.ts`; `mobile/lib/features/auth/data/auth_repository.dart` | client model + two repositories + `get_it` registrations, with mapped-failure behavior | unit: JSON mapping, null body, unknown status, failure mapping incl. sign-404; `flutter analyze` | DONE |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/features/love_contracts/presentation/love_contract_event.dart`, `mobile/lib/features/love_contracts/presentation/love_contract_state.dart`, `mobile/lib/features/love_contracts/presentation/love_contract_bloc.dart`, `mobile/test/features/love_contracts/presentation/love_contract_bloc_test.dart` | `../architecture/solution.md` ADR-006a, ADR-006c; P0 outputs; `mobile/lib/features/auth/presentation/sign_out_cubit.dart` (sealed-state style) | full `Bloc` ceremony state machine with clause and re-entrancy guards | unit: event-sequence transitions, clause bounds 0/1/20/21, hold order, `inFlight` guard; `flutter analyze` | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`, `mobile/lib/features/love_contracts/presentation/widgets/clause_toggle_row.dart`, `mobile/lib/features/love_contracts/presentation/widgets/add_clause_sheet.dart`, `mobile/lib/l10n/arb/app_vi.arb`, `mobile/lib/l10n/arb/app_en.arb`, `mobile/test/features/love_contracts/presentation/love_contract_screen_test.dart` | `../ux/uiux-spec.md` §4, §6, §8; `../architecture/solution.md` §4 Boundaries; P1 outputs; `mobile/lib/design_system/design_system.dart` | contract screen shell, clause toggle rows, add-clause sheet, loading/empty states, ARB keys | widget: clause toggle semantics not colour-only, add-clause focus trap/return, 20-clause cap disables add, empty + loading states; `flutter analyze` | DONE |
| P3 | Mobile Developer | Mobile | P2 | NO | `mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`, `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`, `mobile/lib/l10n/arb/app_vi.arb`, `mobile/lib/l10n/arb/app_en.arb`, `mobile/test/features/love_contracts/presentation/hold_to_sign_button_test.dart` | `../ux/uiux-spec.md` §5, §6, §8; `../architecture/solution.md` ADR-006a, ADR-006c; P1 + P2 outputs | hold-to-sign control with widget-local progress, signed/awaiting-partner states, inline error banner + retry | widget: early release cancels with no sign call, completed hold emits exactly one event, semantic activation alternative, mapped error banner shows no raw failure type; `flutter analyze` | DONE |
| P4 | Mobile Developer | Mobile | P3 | NO | `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart`, `mobile/lib/features/home/presentation/home_screen.dart`, `mobile/lib/l10n/arb/app_vi.arb`, `mobile/lib/l10n/arb/app_en.arb`, `mobile/test/features/love_contracts/presentation/love_contract_entry_tile_test.dart` | `../ux/uiux-spec.md` §3, §7; `../architecture/solution.md` §3 A-2, §4 Entry Point + Pairing Gate; P0 + P3 outputs | discoverable entry tile mounted on `HomeScreen`, AC4 hide-not-disable gate, navigation to the screen | widget: tile hidden when `partnerId` null and on gate failure, tile visible + navigates when paired, `home_screen_ready_signal` still pumps; `flutter analyze` | DONE |
| P5 | Mobile Developer | Mobile Verification | P0, P1, P2, P3, P4 | NO | `mobile/test/features/love_contracts/**`, `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-006_love_contracts/coding-plan/test-results.md` | `../story_master.md` AC1-AC4; `../architecture/solution.md` §4 risk-surface table; the `## 6. Test Scope` sections of P0-P4 | consolidated AC1-AC4 verification plus `test-results.md` | full `flutter test`, `flutter analyze`, existing `arb_parity_test.dart` + `widget_test.dart` regression | DONE |

The final phase must be a verification phase for `standard` and `complex`
stories. Tech Lead work is incomplete until that phase file exists.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-contract-data-layer.md` |
| P1 | `phase-P1-ceremony-bloc.md` |
| P2 | `phase-P2-clause-ui.md` |
| P3 | `phase-P3-signing-ritual-ui.md` |
| P4 | `phase-P4-entry-point-gate.md` |
| P5 | `phase-P5-verification.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Backend/frontend/mobile implementation phases must fit one specialist lifecycle
  (roughly six source/test files max) or be split.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, traces, or scenario reruns.

## 6. Risks And Notes

- Risks: AC2/AC3 cannot be satisfied as literally worded against the frozen backend — the plan
  implements ADR-006c (creator-only) and leaves OQ-006A open for Product Owner / user decision.
  See `../architecture/solution.md` §7 for the full risk table.
- OQ-driven constraints: no local persistence (OQ4); add both `app_vi.arb` and `app_en.arb` keys
  but no locale/theme switch affordance (OQ5); no `backend/` change (A1).
- Migration / rollout notes: none. Removing the P4 entry tile fully hides the feature.
- Notes:
  - No new pub dependency in any phase. `flutter_bloc` 9.1.1 and `get_it` 9.2.1 are already in
    `mobile/pubspec.yaml`; do not add `freezed`, `bloc_test`, `bloc_concurrency`, or `equatable`.
  - Never import `package:cupid_api/...` from feature code and never construct `Dio`.
  - `Key('home_screen_ready_signal')` in `home_screen.dart` is the `mobile-app` runtime readiness
    signal — it must survive the P4 edit.
  - Do not port the raw prototype button labels/handlers flagged in `../ux/uiux-spec.md` §9-3.

## 7. Result Log

- 2026-07-31 — P3 (Mobile Developer): implemented `HoldToSignButton`
  (`mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`)
  with a widget-local `AnimationController`-driven dwell fill, a `Semantics`
  activation alternative (`onTap` fires the same started/completed pair
  instantly, satisfying ADR-006a + §8 without streaming per-frame progress
  through the `Bloc`), and wired it additively into
  `love_contract_screen.dart`'s `_SignPromptSection` (no other screen edits).
  Added `loveContractSignUnavailable` mapped-error-banner coverage reusing
  the existing `_SignActionErrorBanner`/retry wiring from P2; no new ARB keys
  were required since P2 already added the sign-flow strings this phase
  needed (`loveContractHoldButtonLabel`, `loveContractSignUnavailable`, and
  the signed/awaiting-partner strings), so `app_vi.arb`/`app_en.arb` are
  unchanged in this phase.
  - Touched files: `mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`,
    `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`,
    `mobile/test/features/love_contracts/presentation/hold_to_sign_button_test.dart`.
  - Test command: `flutter test test/features/love_contracts/presentation/hold_to_sign_button_test.dart`
    — 7/7 passed (4 `HoldToSignButton widget` cases: early release cancels,
    full dwell dispatches exactly one completed event, semantic activation
    parity, disabled ignores input; 3 `Love contract screen signing
    integration` cases: completed hold saves+signs, mapped sign-unavailable
    banner never leaks a raw failure type/server string, retry recovers to
    signed).
  - Regression command: `flutter test test/features/love_contracts/` — 45/45
    passed (P0 repository/gate-repository tests, P1 bloc tests, P2 screen
    tests, P3 button tests all green).
  - `flutter analyze` on the three touched files: no issues found.
  - Note: the screen-integration tests drive the signed state through the
    button's `Semantics` activation action rather than a real-time hold
    gesture, because the `HoldToSignButton` sits under the ready body's
    `SingleChildScrollView` and a widget test's coarse-grained
    `tester.pump(duration)` jumps do not reliably deliver ticks to an
    `AnimationController` under a scrollable ancestor with real overflow
    (confirmed as a test-harness-only artifact via isolated repro; a real
    device delivers a continuous frame stream). The raw hold-dwell gesture
    itself is covered directly and repeatedly by the isolated
    `HoldToSignButton widget` group, which has no scrollable ancestor.

- 2026-07-31 — P4 (Mobile Developer, run
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-006-mobile-dev-p4`): mounted
  `LoveContractEntryTile` on `HomeScreen`, commit
  `7858b2b8eb19a67bc7f2f7fb7db8a6441a082ecd`. `MOBILE_COMPLETE: YES`.
  Flagged (not fixed, out of P4 write scope) a pre-existing P3 defect:
  `test/design_system/no_fork_guard_test.dart` failing on
  `hold_to_sign_button.dart:144` (raw `Colors.white` literal).
- 2026-07-31 — fork-guard-fix patch (Mobile Developer, run
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-006-mobile-dev-p5fix`,
  `coding-plan/phase-P5-fork-guard-fix.md`): fixed the raw-color literal in
  `hold_to_sign_button.dart` flagged by P4. Commit
  `1391b689c3ca7bd376345ab4f4e38bdab19638da` — this is the current story
  branch HEAD. Despite the run id, this was NOT the master-plan P5
  verification phase; P5 (consolidated AC1-4 verification) is still
  NOT_STARTED and is the only remaining phase.

- 2026-07-31 — P5 (Mobile Developer, run
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-006-mobile-dev-p5`): consolidated
  AC1-AC4 verification per `phase-P5-verification.md`, at story branch HEAD
  `ac04e71bc876b9b97988719d870ed6a431e3a1af`. `flutter test` whole `mobile`
  package: 170/170 passed. `flutter analyze` scoped to
  `lib/features/love_contracts`, `lib/features/home/presentation/home_screen.dart`,
  `test/features/love_contracts`: no issues found; `flutter analyze lib test`
  (whole first-party source): 17 pre-existing `info`-level
  `prefer_initializing_formals` lints outside `love_contracts`/`home_screen.dart`,
  none touched by this story. Whole-package no-path-args `flutter analyze` also
  walks a local, gitignored `mobile/build/ios/SourcePackages/checkouts/flutterfire/`
  CocoaPods vendoring artifact (FlutterFire's own integration-test fixtures) that
  is not part of this repository's source; scoped invocations above avoid it,
  consistent with how P0-P4 scoped their own analyze runs. AC1-AC4 each verified
  at the ADR-006c capability (OQ-006A recorded as open, non-blocking); all 8
  `../architecture/solution.md` §4 risk-surface gates pass; `arb_parity_test.dart`
  and `test/widget_test.dart` (`home_screen_ready_signal`) both pass; `backend/`
  untouched and no new pub dependency across the full story range; no
  `package:cupid_api/...` import under `mobile/lib/features/love_contracts/`.
  Full detail in `coding-plan/test-results.md` "P5 verification" section.
  `MOBILE_COMPLETE: YES`.
