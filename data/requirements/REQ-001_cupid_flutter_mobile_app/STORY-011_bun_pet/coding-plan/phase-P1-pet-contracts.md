# Phase P1 – Pet Domain Contracts

## 1. Objective

Land the pure-Dart contract layer every other phase consumes: pet/status/species
models with JSON parsing, the backend `mood` → `BunSpriteState` mapping, and the
feature-local vi/en copy source.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-pet-contracts.md`
- Owner: Mobile Developer
- Lane: Mobile / Contract

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pet/data/pet_models.dart`
  - `mobile/lib/features/pet/data/pet_mood.dart`
  - `mobile/lib/features/pet/presentation/pet_strings.dart`
  - `mobile/test/features/pet/data/pet_models_test.dart`
  - `mobile/test/features/pet/data/pet_mood_test.dart`
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
  - `Pet`, `PetStatus`, `PetPairing`, `PetSpecies`
  - `PetMood`, `BunSpriteState`, `BunSpriteState.fromMood`
  - `PetLocaleText.viEn(vi, en)` extension
- Shared Interfaces Consumed:
  - none
- Risk Surfaces:
  - Mood → sprite mapping
  - Untyped `pets` REST parsing (model half)
- Source Of Truth:
  - authoritative artifact: `backend/src/modules/pets/entities/pet.entity.ts`,
    `pets.service.ts` (`getStatus`, `computeMood`), `dto/adopt-pet.dto.ts`
  - consumer contract: `../architecture/solution.md` §2 Downstream Contract
    Summary and §4 Contracts And Integrations
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2, §4 Contracts And Integrations
  - UX constraints: `../ux/uiux-spec.md` §1 (contract table), §3 (mood→sprite
    table), §4 (status-line copy table)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: parsing + mapping contract, no I/O, no widgets
  - Source/Test File Count: 3 source + 2 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2, §4
- `../ux/uiux-spec.md` §1, §3, §4
- `mobile/lib/features/auth/presentation/auth_strings.dart` (the `viEn`
  extension pattern to mirror)

## 3. Tasks

- Define `PetSpecies` (`cat`, `dog`, `bunny`) with `fromJson`/`wireValue`
  matching the backend enum strings exactly.
- Define `Pet.fromJson` for `{ id, coupleId, species, name, happiness, level,
  totalInteractions, lastInteraction }`. `lastInteraction` is nullable ISO-8601.
- Define `PetStatus.fromJson` for `{ pet, mood, decayedHappiness, milestone,
  nextMilestone }`. Keep `milestone` as a nullable raw string but mark it
  display-forbidden (English-only; see AC below).
- Add derived getters used by presentation: `levelProgress` =
  `(pet.totalInteractions % 50) / 50`, and `interactionsTowardNextMilestone`
  exposing `pet.totalInteractions` and `nextMilestone` as a pair. Do not
  reimplement level or milestone-list math.
- Define `PetPairing` with `isPaired` parsed from `GET /users/me.partnerId`
  (non-null and non-empty).
- Define `PetMood` (`ecstatic`, `happy`, `content`, `sad`, `sick`) with
  `PetMood.fromWire(String?)` falling back to `content` for unknown/missing.
- Define `BunSpriteState` (`inlove`, `happy`, `neutral`, `sulk`, `sick`) and
  `BunSpriteState.fromMood` per `../ux/uiux-spec.md` §3. Do not declare a
  `sleep` state.
- Add `PetLocaleText` extension on `BuildContext` exposing `viEn(vi, en)` plus
  named getters for the §4 status lines, the §3 mood labels, and the §2 headline
  and CTA copy. Mirror `auth_strings.dart`; do not touch
  `mobile/lib/l10n/arb/**`.
- Unit tests as described in Test Scope.

## 4. Acceptance Criteria

- `PetStatus.fromJson` parses the §4 example payload in
  `../architecture/solution.md` with every field populated.
- A payload with an unrecognised `mood` string parses successfully and maps to
  `PetMood.content` / `BunSpriteState.neutral` without throwing.
- A payload with `lastInteraction: null` and `milestone: null` parses.
- All five backend moods map to the five sprite states in the §3 table; there is
  no code path that can produce a `sleep` state.
- No model file imports `flutter_bloc`, `dio`, or `cupid_api`.
- `milestone` is never rendered directly by any later phase; the models expose
  the numeric pair needed for localized captions instead.

## 5. Planned Outputs

- Code files: the three source files in Write Scope.
- Contracts: `Pet`, `PetStatus`, `PetPairing`, `PetSpecies`, `PetMood`,
  `BunSpriteState`, `PetLocaleText`.
- Requirement configuration guide updates: none.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), pure Dart
- Required levels:
  - unit: `pet_models_test.dart` (full payload, null-field payload, empty body
    handling contract, species round-trip), `pet_mood_test.dart` (5 moods +
    unknown fallback + no `sleep` state)
  - mobile build/type-check/static-analysis: `flutter analyze` clean for the
    touched files
- Required checks: `cd mobile && flutter test test/features/pet/data` and
  `cd mobile && flutter analyze`
- Minimum gates by risk surface:
  - Mood → sprite mapping: 5-mood + unknown-fallback unit test
  - Untyped REST parsing (model half): payload parsing unit tests
- Required regression or contract coverage: field names asserted literally
  against `pet.entity.ts` / `getStatus` return shape.
- Evidence format: concise rows in `coding-plan/test-results.md` at P9.
- Verification strategy:
  - Targeted tests: the two unit test files above
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: parsed field values and mapping results

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Evidence:
  - `cd mobile && flutter test test/features/pet/data`: 11/11 tests passed
    (`pet_models_test.dart` 7, `pet_mood_test.dart` 4).
  - `cd mobile && flutter analyze`: 58 pre-existing issues, none in the 5
    touched files (`lib/features/pet/data/pet_models.dart`,
    `lib/features/pet/data/pet_mood.dart`,
    `lib/features/pet/presentation/pet_strings.dart`,
    `test/features/pet/data/pet_models_test.dart`,
    `test/features/pet/data/pet_mood_test.dart`); all issues are unrelated
    missing-generated-`AppL10n`/OpenAPI-client warnings (gitignored
    `lib/l10n/generated/`, produced by `flutter gen-l10n`).
  - All 6 acceptance criteria verified by the above tests.
