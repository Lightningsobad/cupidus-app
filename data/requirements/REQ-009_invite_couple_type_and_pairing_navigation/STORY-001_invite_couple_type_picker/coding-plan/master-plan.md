# Master Coding Plan – Invite Couple-Type Picker

## 1. Planning Metadata

- Story ID: STORY-001_invite_couple_type_picker
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  third-party integration, or runtime dependency changes.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (`couple_type.dart` wire-value enum
  and the Continue submit seam, both specified in
  `../architecture/contract-summary.md`).
- Contract-first phase required: NO — the same Mobile Developer implements the
  enum and both of its in-story consumers (`InviteCubit`, `InviteScreen`) back
  to back in one lane, so the contract folds into the single consumer phase.
- Parallel execution possible: NO — single lane, single phase.
- Critical path: P1.
- Parallelism notes: none.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| Couple-type wire values + Continue submit seam | Mobile Developer | P1 | STORY-002 (out of this story) | `../architecture/contract-summary.md` sections 2-3 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Couple-type wire enum fidelity | P1 |
| Countdown re-emit dropping selection | P1 |
| Pre-fill on return (AC5) | P1 |
| Continue gating and single-select (AC2/AC3) | P1 |
| Icon codepoint fidelity | P1 (must be resolved before the `IconData` constants are written) |
| Preview/build compatibility | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app` (`testCommand: flutter test`,
    `buildCommand: flutter build apk --debug`; the Flutter SDK is not on PATH
    on this machine — resolve it via `FLUTTER_SDK_PATH`, default `$HOME/flutter`,
    per the registry's `sdk` block). No new DI registration, env var, port, or
    startup path is introduced, so the change is fully covered by the build and
    test gates.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-couple-type-picker.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- P1 writes 5 source/test files plus one optional preview fixture, which fits
  one specialist lifecycle (roughly six source/test files max); no split needed.
- No standalone contract phase exists: the enum's only consumers share P1's
  owner and lane in sequence.
- No trailing verification/testing phase exists; P1 owns its own targeted tests
  and build/static-analysis gate.

## 6. Notes

- The icon codepoint lookup (`location_city`, `auto_awesome`, `all_inclusive`)
  is an ordered prerequisite *inside* P1, not a separate phase: the Tech Lead
  run had no shell available to execute `fontTools`, and the repository's own
  convention (`mobile/lib/design_system/icons/cupid_icons.dart:7-11`) forbids
  writing a codepoint from memory. P1 must run the lookup and record its output
  before writing the constants.
