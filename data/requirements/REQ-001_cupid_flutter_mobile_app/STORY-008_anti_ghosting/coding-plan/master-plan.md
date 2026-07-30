# Master Coding Plan – Anti-Ghosting Configuration (STORY-008)

## 1. Planning Metadata

- Story ID: STORY-008
- Complexity: S (Story-Class `standard`)
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md`
- Source UX: `../ux/uiux-spec.md` §0-§5
- Source Architecture: `../architecture/solution.md` (§2 contract summary, §4
  risk surfaces, §6 ADR-1..ADR-6)
- OQ Constraints Source: none — no OQ ids in scope
- Review Input: none yet
- Requirement Configuration Guide: NOT_APPLICABLE (no env, secret, port, or
  registry change)

## 2. Planning Goal

- Shared contract owner: P0 `GhostConfigRepository` + `ghost_config_models.dart`
- Contract-first phase required: YES (P0)
- Parallel execution possible: YES (P3 runs alongside P1/P2 once P0 is DONE)
- Critical path: P0 -> P1 -> P2 -> P4
- Parallelism notes: P3 depends only on P0, so it may run concurrently with P1
  and P2 by a second mobile lane if Scrum Master chooses to split them. Its
  write scope is disjoint from P1/P2 except for the two ARB files, which are
  append-only; if a single lane executes everything, run P0 -> P1 -> P2 -> P3 -> P4.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|----------------------|-------|--------------------|----------------|----------------|----------------------------|
| `ghost-config` REST contract (frozen) | backend `ghost-config` module | mobile -> backend REST over shared `Dio` | none (pre-existing) | P0 | `POST /ghost-config` `{"timeoutMinutes":10,"penalty":"emoji_storm"}` |
| `GhostConfigRepository` + `GhostConfig`/`StormStatus` models | P0 | Dart interface via `get_it` | P0 | P1, P2, P3 | `Future<GhostConfig?> fetchActive()` |
| `AntiGhostCubit` lifecycle states A/B/C/D | P1 | `flutter_bloc` state | P1 | P2 | `AntiGhostState.pendingFromPartner(config)` |
| `AntiGhostScreen` route target | P1 | widget constructor | P1 | P2 | `AntiGhostScreen()` pushed from the entry card |
| `GhostStormCubit` + `GhostStateRow` chat mount seam (ADR-3) | P3 | exported widget consumed by STORY-007's chat screen | P3 | STORY-007 / requirement integration | `GhostStateRow(partnerId: partnerId)` |
| `anti_ghosting.dart` feature barrel | P2 | Dart export surface | P2 | P3, STORY-007 | `export 'presentation/widgets/ghost_state_row.dart';` |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|--------------|-----------------|-------------------|--------------|---------------------|----------------------------|
| Frozen wire contract | `backend/src/modules/ghost-config/` | exact paths, body keys, enum wire strings | P0 repository unit test asserting each path/method/body/enum | none | BLOCKER |
| Pairing gate (AC3) | UX §1 + backend `BadRequestException` | unpaired -> guard state, zero mutating calls | P1 cubit + screen test | P0 | BLOCKER |
| Approval-role derivation | `proposedBy` + `BackendUserIdStore` | State B vs State C | P1 cubit test (mine / partner's / unknown id) | P0 | BLOCKER |
| Design-system no-fork guard | `mobile/test/design_system/no_fork_guard_test.dart` | tokens + adaptive widgets only | that test stays green | P1, P2, P3 | BLOCKER |
| Runtime readiness key | registry `mobile-app.readiness.widgetKey` | `Key('home_screen_ready_signal')` preserved | `mobile/test/widget_test.dart` stays green | P2 | BLOCKER |
| l10n parity | `mobile/test/l10n/arb_parity_test.dart` | every new key in both ARB files | that test stays green | P1, P3 | BLOCKER |
| Storm polling lifecycle | `../architecture/solution.md` ADR-2 | timer only while visible + foregrounded | P3 cubit test asserting cancellation on `close()` and background | P0 | BLOCKER |
| AC2 end-to-end mount | ADR-3 | STORY-007 chat mounts `GhostStateRow` | P3 widget test in-branch; end-to-end deferred to the mount | P3 | Non-blocking; escalate to Scrum Master |

## 4. Lane Summary

- Backend required: NO
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer (P0)
- Final verification owner: Mobile Developer (P4)
- Shared contract owner: Mobile Developer (P0)
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (Flutter app; the
    registry readiness signal is a widget test, not an HTTP probe), command/source
    runtime registry `mobile-app.testCommand` (`flutter test`) and
    `mobile-app.buildCommand` (`flutter build apk --debug`). The Flutter SDK is
    not on PATH on this machine; resolve it as
    `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter` per the registry `sdk` block.

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Mobile Developer | Contract | None | NO | `mobile/lib/features/anti_ghosting/data/ghost_config_models.dart`, `mobile/lib/features/anti_ghosting/data/ghost_config_repository.dart`, `mobile/lib/core/di/service_locator.dart` (additive), `mobile/test/features/anti_ghosting/data/ghost_config_repository_test.dart` | `../architecture/solution.md` §2, §4 Contracts, ADR-1/ADR-4; `backend/src/modules/ghost-config/` | typed models + repository over the frozen contract, registered in `get_it` | unit + mobile static analysis | DONE |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/features/anti_ghosting/presentation/anti_ghost_cubit.dart`, `mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart`, `mobile/lib/design_system/icons/cupid_icons.dart` (additive), `mobile/lib/l10n/arb/app_en.arb` (additive), `mobile/lib/l10n/arb/app_vi.arb` (additive), `mobile/test/features/anti_ghosting/presentation/anti_ghost_cubit_test.dart`, `mobile/test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart` | `../architecture/solution.md` §4 Mobile Lane Handoff, ADR-4/ADR-5/ADR-6; `../ux/uiux-spec.md` §1, §2.3, §3, §4, §5; P0 outputs | AC1 + AC3: settings screen with states A/B/C/D and pairing guard | unit + widget + mobile static analysis | NOT_STARTED |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart`, `mobile/lib/features/anti_ghosting/anti_ghosting.dart`, `mobile/lib/features/home/presentation/home_screen.dart` (additive), `mobile/test/features/anti_ghosting/presentation/anti_ghost_entry_card_test.dart` | `../architecture/solution.md` §3 Assumption 2, §7; `../ux/uiux-spec.md` §2.1; P1 outputs | discoverable entry point: home card -> `AntiGhostScreen`, readiness key preserved | widget + regression on `widget_test.dart` + mobile static analysis | NOT_STARTED |
| P3 | Mobile Developer | Mobile | P0 | YES (with P1, P2) | `mobile/lib/features/anti_ghosting/presentation/ghost_storm_cubit.dart`, `mobile/lib/features/anti_ghosting/presentation/widgets/ghost_state_row.dart`, `mobile/test/features/anti_ghosting/presentation/ghost_storm_cubit_test.dart`, `mobile/test/features/anti_ghosting/presentation/ghost_state_row_test.dart`, `mobile/lib/l10n/arb/app_en.arb` (additive), `mobile/lib/l10n/arb/app_vi.arb` (additive) | `../architecture/solution.md` ADR-2/ADR-3; `../ux/uiux-spec.md` §2.4, §4; P0 outputs | AC2 surfacing widget + storm-status polling, exported as the chat mount seam | unit + widget + mobile static analysis | NOT_STARTED |
| P4 | Mobile Developer | Mobile Verification | P0, P1, P2, P3 | NO | lane-owned test files, `coding-plan/test-results.md` | this plan; P0-P3 outputs; `../architecture/solution.md` §4 risk table | full `flutter test` + `flutter analyze` + registry `buildCommand`, results recorded | targeted regression + mobile build/type-check/static-analysis | NOT_STARTED |

The final phase must be a verification phase for `standard` and `complex`
stories. Tech Lead work is incomplete until that phase file exists.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-data-contract-layer.md` |
| P1 | `phase-P1-lifecycle-and-settings-screen.md` |
| P2 | `phase-P2-home-entry-card.md` |
| P3 | `phase-P3-chat-ghost-state-row.md` |
| P4 | `phase-P4-verification.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Backend/frontend/mobile implementation phases must fit one specialist lifecycle
  (roughly six source/test files max) or be split.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, traces, or scenario reruns.

## 6. Risks And Notes

- Risks: AC2 cannot be shown end-to-end in this branch until STORY-007's chat
  screen mounts `GhostStateRow` (ADR-3) — Scrum Master owns that scheduling.
  Four shared files (`service_locator.dart`, `cupid_icons.dart`,
  `home_screen.dart`, both ARB files) are also touched by sibling parallel
  stories; every edit must be strictly append-only.
- OQ-driven constraints: none. UX §6 items 1-3 are resolved by ADR-5 and ADR-2.
- Migration / rollout notes: none. No schema, env, or registry change.
- Notes: no new pubspec dependency is permitted. `mocktail` and `bloc_test` are
  not in `dev_dependencies`; use hand-written fakes, matching
  `mobile/test/features/auth/data/auth_repository_test.dart`. Do not touch
  `mobile/openapi/**` or any file under `mobile/lib/features/chat/`.
