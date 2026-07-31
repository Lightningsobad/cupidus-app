# Master Coding Plan – STORY-011 Bun Pet Đồng Hành

## 1. Planning Metadata

- Story ID: STORY-011
- Complexity: M (`Story-Class: standard`)
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md`
- Source UX: `../ux/uiux-spec.md` §1-§9
- Source Architecture: `../architecture/solution.md`
- OQ Constraints Source: none attached; `../ux/uiux-spec.md` §5 Open Items 1-5
  are resolved and carried in `../architecture/solution.md` §3
- Review Input: none yet
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` — NOT_APPLICABLE for this story

## 2. Planning Goal

- Shared contract owner: Mobile Developer (P1 models + mood mapping, P2 repository)
- Contract-first phase required: YES (P1, then P2)
- Parallel execution possible: YES (limited — single mobile lane; P4 is
  independent of P2/P3, and P6/P7 are independent of each other)
- Critical path: P1 → P2 → P3 → P5 → P8 → P9
- Parallelism notes: P4 (`BunSprite`) only needs P1's `BunSpriteState` enum, so
  it can run alongside P2/P3. P6 (engagement cards) and P7 (adopt flow) both
  need P3 + P5 and can run in either order. Every phase is mobile-owned, so
  concurrency is only realized when more than one mobile agent is available.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|---|---|---|---|---|---|
| `PetStatus` / `Pet` / `PetMood` models | Mobile (P1) | in-process Dart types | P1 | P2, P3, P5, P6 | `PetStatus(pet, mood, decayedHappiness, milestone, nextMilestone)` |
| `BunSpriteState` mood mapping | Mobile (P1) | pure function `BunSpriteState.fromMood` | P1 | P4, P5 | `ecstatic → inlove`, `sad → sulk`, unknown → `neutral` |
| `PetRepository` | Mobile (P2) | shared `Dio` via `get_it` singleton | P2 | P3 | `readPairing()`, `readStatus()`, `interact()`, `adopt(species, name)` |
| `PetCubit` / `PetState` | Mobile (P3) | `flutter_bloc` | P3 | P5, P6, P8 | `PetLocked`, `PetNoPet`, `PetReady(status, cooldownRemaining)`, `PetFailure` |
| `AdoptCubit` / `AdoptState` | Mobile (P3) | `flutter_bloc` | P3 | P7 | `AdoptEditing(species, name, valid)`, `AdoptRejectedNotYet`, `AdoptConflict(name)` |
| `PetPreviewCard` entry point | Mobile (P8) | widget mounted in `HomeScreen` | P8 | P9 | tap → `PetScreen` route |
| `CupidIcons` glyphs (`restaurant`, `sportsEsports`, `lock`, `pets`, `celebration`) | Mobile (P4) | `design_system` barrel | P4 | P5, P6, P7, P8 | cmap-verified `IconData` constants |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|---|---|---|---|---|---|
| Untyped `pets` REST parsing | `backend/src/modules/pets/` | `PetRepository` | unit tests over a stubbed `Dio` adapter: path/verb/body + parse of full, empty, and unknown-mood payloads | P1 models | BLOCKED: contract parsing unverified |
| Mood → sprite mapping | `pets.service.ts` `computeMood`, UX §3 | `BunSpriteState` | unit test over all 5 moods + unknown fallback | none | BLOCKED: AC1 mood fidelity unverified |
| Pairing hard gate (AC3) | `GET /users/me.partnerId` | `PetCubit` → `PetLocked` | widget test: locked state, no adopt CTA, no interact buttons | P2, P3 | BLOCKED: AC3 unverified |
| 5s interaction cooldown | `pets.service.ts` `interact` | `PetCubit` cooldown state | cubit unit test with injected clock: disabled ~5s after tap and re-derived from `lastInteraction` on load | P3 | BLOCKED: raw 400 leaks to the user |
| Adopt input validation | `AdoptPetDto` | adopt sheet form | widget test: CTA gating at name length 1/30/31 + species required | P3 | BLOCKED: AC2 adopt path unverified |
| New icon codepoints | bundled `MaterialSymbolsRounded-Variable.ttf` cmap | `CupidIcons` | codepoints read from the font cmap, never guessed; render smoke test | none | BLOCKED: tofu/wrong glyph shipped |
| Entry-point reachability | UX §2.1 preview card | `HomeScreen` → `PetScreen` | widget test navigating from the preview card; `Key('home_screen_ready_signal')` still pumps | P5 | BLOCKED: orphaned feature + broken runtime readiness signal |

## 4. Lane Summary

- Backend required: NO (A1 frozen)
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer
- Final verification owner: Mobile Developer (P9)
- Shared contract owner: Mobile Developer (P1, P2)
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (registry readiness
    is a `flutter test` widget signal, not an HTTP probe), commands from
    `data/devops/system/runtime-command-registry.json` → `mobile-app`
    (`testCommand: flutter test`, `buildCommand: flutter build apk --debug`)

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P1 | Mobile Developer | Mobile / Contract | None | NO | `mobile/lib/features/pet/data/pet_models.dart`, `mobile/lib/features/pet/data/pet_mood.dart`, `mobile/lib/features/pet/presentation/pet_strings.dart`, `mobile/test/features/pet/data/` | `../architecture/solution.md` §2, §4 Contracts; UX §1, §3, §4 | pet/status/species models with JSON parsing, `PetMood`, `BunSpriteState.fromMood`, `viEn` locale extension, unit tests | unit (`flutter test`), static analysis (`flutter analyze`) | DONE |
| P2 | Mobile Developer | Mobile / Data | P1 | NO | `mobile/lib/features/pet/data/pet_repository.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/pet/data/pet_repository_test.dart` | `../architecture/solution.md` D1-D4, §4 Contracts table | `PetRepository` over shared `Dio`, `get_it` registration, repository unit tests | unit (stubbed `Dio` adapter), static analysis | DONE |
| P3 | Mobile Developer | Mobile / State | P2 | NO | `mobile/lib/features/pet/presentation/pet_cubit.dart`, `pet_state.dart`, `adopt_cubit.dart`, `adopt_state.dart`, `mobile/test/features/pet/presentation/` | `../architecture/solution.md` D2-D4; UX §2.2, §2.3, §5 Open Items 1 and 5 | `PetCubit` load/interact/cooldown, `AdoptCubit` validation + error mapping, cubit unit tests | unit (injected clock), static analysis | DONE |
| P4 | Mobile Developer | Mobile / UI | P1 | YES (with P2, P3) | `mobile/lib/features/pet/presentation/widgets/bun_sprite.dart`, `mobile/lib/design_system/icons/cupid_icons.dart`, `mobile/test/features/pet/presentation/widgets/bun_sprite_test.dart`, `mobile/lib/design_system/tokens/bun_sprite_palette.dart` (additive, added to satisfy the no-fork guard) | UX §3, §6 sprite sizes, §8 animation vocabulary | 5-state pure-Flutter `BunSprite` with idle bob, 5 cmap-verified `CupidIcons` glyphs, widget tests | widget, visual inspection, static analysis | DONE |
| P5 | Mobile Developer | Mobile / UI | P3, P4 | NO | `mobile/lib/features/pet/presentation/pet_screen.dart`, `widgets/pet_hero_card.dart`, `widgets/pet_guard_states.dart`, `mobile/test/features/pet/presentation/pet_screen_test.dart` | UX §2.1 items 1, §2.3, §7; `../architecture/solution.md` §4 Mobile Lane Handoff | `PetScreen` with hero card (sprite + `Lv.` pill + name + status line), locked/waiting/no-pet guard states, widget tests | widget, static analysis | DONE |
| P6 | Mobile Developer | Mobile / UI | P5 | YES (with P7) | `mobile/lib/features/pet/presentation/widgets/pet_xp_card.dart`, `widgets/pet_stats_row.dart`, `widgets/pet_action_row.dart`, `widgets/pet_reactions_card.dart`, `mobile/test/features/pet/presentation/widgets/pet_engagement_test.dart` | UX §2.1 items 2-5, §5 Open Items 1-2, §7 cooldown a11y | XP progress card, 2-tile stats row, Feed/Play action row with cooldown + semantics, "How Bun reacts" card, widget tests | widget, accessibility, static analysis | DONE |
| P7 | Mobile Developer | Mobile / UI | P5 | YES (with P6) | `mobile/lib/features/pet/presentation/widgets/adopt_sheet.dart`, `widgets/species_picker.dart`, `mobile/test/features/pet/presentation/widgets/adopt_sheet_test.dart` | UX §2.2, §5 Open Items 3-5, §7 modal a11y, §8 sheet chrome | adopt bottom sheet with species radio-group + name field, success/400/409 states, widget tests | widget, accessibility, static analysis | NOT_STARTED |
| P8 | Mobile Developer | Mobile / Entry Point | P5 | NO | `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`, `mobile/lib/features/pet/presentation/pet_route.dart`, `mobile/lib/features/home/presentation/home_screen.dart`, `mobile/test/features/pet/presentation/pet_entry_point_test.dart` | UX §2.1 dashboard preview card; `../architecture/solution.md` §4 reachability risk surface | `PetPreviewCard` mounted in `HomeScreen`, navigation into `PetScreen`, readiness-key regression test | widget, navigation integration, static analysis | NOT_STARTED |
| P9 | Mobile Developer | Mobile Verification | P6, P7, P8 | NO | `mobile/test/features/pet/**`, `coding-plan/test-results.md` | all P1-P8 outputs; implementation phase `## 6. Test Scope` sections | consolidated `flutter analyze` + `flutter test` evidence, AC1-AC3 verification rows | unit, widget, accessibility, mobile static analysis/type-check | NOT_STARTED |

The final phase must be a verification phase for `standard` and `complex`
stories. Tech Lead work is incomplete until that phase file exists.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-pet-contracts.md` |
| P2 | `phase-P2-pet-data-layer.md` |
| P3 | `phase-P3-pet-state.md` |
| P4 | `phase-P4-bun-sprite.md` |
| P5 | `phase-P5-pet-screen.md` |
| P6 | `phase-P6-engagement-cards.md` |
| P7 | `phase-P7-adopt-flow.md` |
| P8 | `phase-P8-entry-point.md` |
| P9 | `phase-P9-verification.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Mobile implementation phases must fit one specialist lifecycle (roughly six
  source/test files max) or be split. Every phase above is 3-5 files.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, mobile e2e, emulator/simulator lifecycle commands,
  signing, store upload, traces, scenario reruns, repository-root local script
  gates, or runtime startup smoke.

## 6. Risks And Notes

- Risks: untyped JSON parsing drift, guessed icon codepoints, shared-file
  conflicts on `service_locator.dart` / `cupid_icons.dart` / `home_screen.dart`
  in a parallel wave, and hand-built sprite drift from the design source. Full
  table in `../architecture/solution.md` §7.
- OQ-driven constraints: none attached to the story. Do not implement anything
  in `../ux/uiux-spec.md` §9 (no `sleep` state, no streaks, no badges, no
  per-species art, no `pets` endpoint change).
- Migration / rollout notes: additive client-only feature; rollback is a revert
  of the `HomeScreen` preview-card mount.
- Notes:
  - `HomeScreen` must keep `Key('home_screen_ready_signal')` — the `mobile-app`
    runtime registry readiness probe depends on it.
  - Do not add a pub dependency or an `assets:` section; the sprite is
    pure-Flutter vector work.
  - Requirement-level mobile visual audit is deferred to requirement
    integration, not gated per phase.
