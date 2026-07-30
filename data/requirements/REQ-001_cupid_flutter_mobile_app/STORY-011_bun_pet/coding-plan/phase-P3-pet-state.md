# Phase P3 – Pet And Adopt Cubits

## 1. Objective

Implement the two cubits that own screen state: `PetCubit` (pairing gate, status
load, interact + 5s cooldown) and `AdoptCubit` (form validation, adopt submit,
typed error states).

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-pet-state.md`
- Owner: Mobile Developer
- Lane: Mobile / State

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pet/presentation/pet_cubit.dart`
  - `mobile/lib/features/pet/presentation/pet_state.dart`
  - `mobile/lib/features/pet/presentation/adopt_cubit.dart`
  - `mobile/lib/features/pet/presentation/adopt_state.dart`
  - `mobile/test/features/pet/presentation/pet_cubit_test.dart`
  - `mobile/test/features/pet/presentation/adopt_cubit_test.dart`
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
  - `PetState`: `PetLoading`, `PetLocked`, `PetNoPet`, `PetReady(status,
    cooldownRemaining)`, `PetFailure(failure)`
  - `PetCubit.load()`, `PetCubit.interact()`
  - `AdoptState`: `AdoptEditing(species, name, isValid)`, `AdoptSubmitting`,
    `AdoptSucceeded`, `AdoptRejectedNotYet`, `AdoptConflict(existingName)`,
    `AdoptFailed(failure)`
  - `AdoptCubit.selectSpecies()`, `nameChanged()`, `submit()`
- Shared Interfaces Consumed:
  - P1 models, P2 `PetRepository`
- Risk Surfaces:
  - Pairing hard gate (AC3)
  - 5s interaction cooldown
  - Adopt input validation
- Source Of Truth:
  - authoritative artifact: `pets.service.ts` (`interact` cooldown, adopt
    preconditions), `dto/adopt-pet.dto.ts` (1-30 char name, species enum)
  - consumer contract: `../architecture/solution.md` D2-D4
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` D2, D3, D4, §4 error contract
  - UX constraints: `../ux/uiux-spec.md` §2.2 submit states, §2.3 unpaired
    guard, §5 Open Items 1 and 5
  - upstream phase outputs: P1 models, P2 repository
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: state machines only; no widgets
  - Source/Test File Count: 4 source + 2 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` D2-D4, §4 error contract
- `../ux/uiux-spec.md` §2.2, §2.3, §5 Open Items 1 and 5
- P1 and P2 outputs
- `mobile/lib/features/auth/presentation/sign_in_cubit.dart` (cubit convention)

## 3. Tasks

- `PetCubit.load()` sequence: `readPairing()` → if not paired emit `PetLocked`
  and stop (no status call). If paired, `readStatus()` → `null` emits `PetNoPet`,
  otherwise `PetReady`.
- Derive the initial `cooldownRemaining` on every load from
  `status.pet.lastInteraction`: `5s - (now - lastInteraction)`, clamped to zero.
  This keeps the cooldown honest across app restarts and backgrounding.
- `PetCubit.interact()`: ignore taps while `cooldownRemaining > 0` or while a
  request is in flight; on success emit `PetReady` with a fresh 5s cooldown and
  tick it down to zero; on `HttpStatusFailure(400)` re-arm the cooldown from the
  server truth instead of showing an error banner.
- Inject the clock and the ticker (`DateTime Function() now` and a
  `Duration`-driven periodic callback) so tests control time; do not call
  `DateTime.now()` or `Timer` directly inside the cubit body.
- Map non-cooldown failures to `PetFailure(failure)` carrying the
  `CupidApiFailure` so presentation can pick copy without re-inspecting HTTP.
- `AdoptCubit`: validate name length 1-30 (trimmed) and require a selected
  species before `isValid`; `submit()` maps `HttpStatusFailure(400)` →
  `AdoptRejectedNotYet` (architecture D3), `HttpStatusFailure(409)` →
  `AdoptConflict` (parse the existing pet name from the message when present,
  otherwise leave it null), other failures → `AdoptFailed`.
- Cubit unit tests as described in Test Scope.

## 4. Acceptance Criteria

- When `readPairing()` reports unpaired, `PetCubit` emits `PetLocked` and never
  calls `readStatus()`, `interact()`, or `adopt()`.
- A second `interact()` inside the cooldown window performs no network call.
- After a load whose `lastInteraction` is 2 seconds old, `cooldownRemaining` is
  ~3s, not zero.
- `HttpStatusFailure(400)` from `interact()` never produces `PetFailure`.
- `AdoptCubit` reports `isValid == false` for empty, whitespace-only, and
  31-character names, and `true` for 1- and 30-character names.
- No cubit contains mood thresholds, decay math, level math, or milestone lists.

## 5. Planned Outputs

- Code files: the four source files in Write Scope.
- Contracts: `PetState` / `AdoptState` unions and both cubit APIs.
- Requirement configuration guide updates: none.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), state layer
- Required levels:
  - unit: `pet_cubit_test.dart` (locked path with a fake repository asserting no
    status call, no-pet path, ready path, cooldown derivation from
    `lastInteraction`, double-tap suppression, `400` re-arm) and
    `adopt_cubit_test.dart` (validation boundaries 0/1/30/31, species required,
    `400`/`409`/other mapping)
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `cd mobile && flutter test test/features/pet/presentation` and
  `cd mobile && flutter analyze`
- Minimum gates by risk surface:
  - Pairing gate: locked-path test asserting zero further repository calls
  - Cooldown: injected-clock tests for tap suppression and load-time derivation
  - Adopt validation: boundary-length tests
- Required regression or contract coverage: none beyond the above.
- Evidence format: concise rows in `coding-plan/test-results.md` at P9.
- Verification strategy:
  - Targeted tests: the two cubit test files
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: emitted state sequences and fake-repository
    call counts

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
