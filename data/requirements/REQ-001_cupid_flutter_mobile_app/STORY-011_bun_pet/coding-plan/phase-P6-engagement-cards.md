# Phase P6 – Engagement Cards And Interact Action Row

## 1. Objective

Add the XP card, the two-tile stats row, the Feed/Play action row with its 5s
cooldown affordance, and the "How Bun reacts" reference card to `PetScreen`.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-engagement-cards.md`
- Owner: Mobile Developer
- Lane: Mobile / UI

## 1B. Phase Metadata

- Depends On: P5
- Parallelizable: YES (independent of P7)
- Write Scope:
  - `mobile/lib/features/pet/presentation/widgets/pet_xp_card.dart`
  - `mobile/lib/features/pet/presentation/widgets/pet_stats_row.dart`
  - `mobile/lib/features/pet/presentation/widgets/pet_action_row.dart`
  - `mobile/lib/features/pet/presentation/widgets/pet_reactions_card.dart`
  - `mobile/lib/features/pet/presentation/pet_screen.dart` (mount the four
    widgets in the `PetReady` branch only)
  - `mobile/test/features/pet/presentation/widgets/pet_engagement_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `PetXpCard`, `PetStatsRow`, `PetActionRow`, `PetReactionsCard`
- Shared Interfaces Consumed:
  - P1 models and `PetLocaleText`, P3 `PetCubit` cooldown state, P4 `BunSprite`
    and `CupidIcons`, P5 `PetScreen` layout slot
- Risk Surfaces:
  - 5s interaction cooldown
  - Mood → sprite mapping (reference card)
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §2.1 items 2-5, §5 Open Items
    1-2, §7
  - consumer contract: P3 `PetReady(status, cooldownRemaining)`
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §3 assumptions 1, 2, 6
  - UX constraints: `../ux/uiux-spec.md` §2.1 items 2-5, §5 Open Items 1-2, §6
    fixed 2-up action row, §7 cooldown and tap-target accessibility, §8 button
    gradients
  - upstream phase outputs: P3 cooldown state, P5 screen slot
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: four presentational cards plus one screen mount edit
  - Source/Test File Count: 5 source (4 new, 1 additive edit) + 1 test
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §2.1 items 2-5, §5 Open Items 1-2, §6, §7, §8
- `../architecture/solution.md` §3 assumptions
- P3 and P5 outputs

## 3. Tasks

- `PetXpCard`: progress bar bound to `status.levelProgress`
  (`totalInteractions % 50 / 50`). Do not invent a `petXpPct` field and do not
  recompute level.
- `PetStatsRow`: exactly two tiles — `totalInteractions` and `nextMilestone`,
  with a `{totalInteractions}/{nextMilestone}` caption. No streak tile, no badge
  tile. Render a localized caption; never print the backend's English
  `milestone` string.
- `PetActionRow`: two buttons — Feed (`CupidIcons.restaurant`, `gradientHot`
  primary) and Play (`CupidIcons.sportsEsports`, `colorSurfaceAlt` secondary) —
  both calling the single `context.read<PetCubit>().interact()`. Fixed 2-up
  `flex: 1` row at every width; never stacked.
- Cooldown affordance: both buttons disabled while `cooldownRemaining > 0`, with
  a visible countdown or "cooldown" micro-state. Expose it via
  `Semantics(enabled: false)` plus one live-region announcement rather than a
  silent no-op tap.
- Accessibility labels must distinguish `Feed Bun` from `Play with Bun` even
  though both trigger the same backend action; tap targets satisfy
  `CupidPlatformTokens.tapTarget`.
- `PetReactionsCard`: three reference sprites at size 46 — a positive state plus
  `sulk` and `sick` — captioned "Bơ một chút" / "Bơ lâu ghê". Do not print hour
  or day thresholds.
- Mount the four widgets in the `PetReady` branch of `pet_screen.dart` only; do
  not touch the guard-state branches.
- Widget tests as described in Test Scope.

## 4. Acceptance Criteria

- The action row renders exactly two buttons and both invoke the same cubit
  method; asserted in tests.
- While `cooldownRemaining > 0`, both buttons are disabled and a tap performs no
  cubit call.
- The stats row renders exactly two tiles and contains no "streak" or "badge"
  text in either locale.
- The XP bar value equals `(totalInteractions % 50) / 50` for a payload with
  `totalInteractions: 63` (expect 0.26).
- The reactions card shows no hour/day threshold text and no `sleep` state.
- No widget in this phase calls `PetRepository` directly.

## 5. Planned Outputs

- Code files: the five source files in Write Scope.
- Contracts: the four card widget APIs.
- Requirement configuration guide updates: none.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), widget layer
- Required levels:
  - widget: `pet_engagement_test.dart` — XP value for `totalInteractions: 63`;
    stats row tile count and absence of streak/badge copy; action row invoking
    the same cubit method from both buttons; cooldown state disabling both
    buttons and suppressing the call; reactions card rendering three sprites
  - accessibility: distinct semantics labels for Feed and Play, disabled
    semantics during cooldown, tap-target size assertion
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `cd mobile && flutter test test/features/pet/presentation`
  and `cd mobile && flutter analyze`
- Mobile discoverability / navigation integration: N/A for this phase (P8 owns it)
- Minimum gates by risk surface:
  - Cooldown: disabled-state widget test plus suppressed-call assertion
  - Mood reference rendering: three-sprite render assertion
- Required regression or contract coverage: re-run
  `pet_screen_test.dart` after the `pet_screen.dart` mount edit.
- Evidence format: concise rows in `coding-plan/test-results.md` at P9.
- Verification strategy:
  - Targeted tests: `pet_engagement_test.dart` plus the P5 screen test
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: rendered values, semantics flags, and cubit
    call counts

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
