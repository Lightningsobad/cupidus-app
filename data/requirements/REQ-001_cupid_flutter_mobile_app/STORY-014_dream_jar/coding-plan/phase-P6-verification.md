# Phase P6 – Mobile Verification

## 1. Objective

Verify the Dream Jar mobile lane end to end and record AC1-AC3 evidence so the
review gate can resume without re-deriving anything.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P1, P2, P3, P4, P5
- Parallelizable: NO
- Write Scope:
  - `mobile/test/features/dream_jar/**` (gap-filling tests only)
  - `coding-plan/test-results.md`

## 2. Required Reads

- `../story_master.md` AC1-AC3
- `../architecture/solution.md` §2, §4 `Risk Surfaces And Source Of Truth`
- `master-plan.md` §3A
- the `## 6. Test Scope` sections of P1-P5
- the P1-P5 implementation outputs

## 3. Verification Tasks

- confirm `master-plan.md` uses the required Phase Overview table schema
- confirm every listed phase has exactly one canonical `phase-Px-*.md` file and no duplicates exist for a phase id
- run `flutter analyze` and record it clean
- run `flutter test` (full suite, not only the Dream Jar subset) and record the result
- run `flutter build apk --debug` from the runtime registry `mobile-app` `buildCommand` and record success
- verify each §3A risk-surface gate: decimal-as-string decoding, AC3 unpaired mapping, entry-point discoverability, progress bounds, double-submission guard, ARB key parity, design-system guards
- verify AC1 by the create-jar and preset-contribution tests, AC2 by the list/detail/history tests, AC3 by the unpaired-failure mapping plus notice rendering tests
- confirm no backend, `mobile/openapi/**`, or `pubspec.yaml` file changed in the story diff
- confirm no Dream Jar surface renders an "end-to-end encrypted" claim, lock, or shield affordance (ADR-014a)
- confirm no deferred item shipped: no edit/archive/delete affordance, no custom-amount tile or `note` input, no currency selector, no archived toggle
- add only the minimum missing tests needed to close a gate; do not redesign phases
- document results concisely in `coding-plan/test-results.md`

## 4. Acceptance Criteria

- required automated checks pass (`flutter analyze`, `flutter test`, `flutter build apk --debug`)
- critical regressions are resolved
- AC1-AC3 are each verified with a named test or explicit evidence row
- every §3A risk-surface gate is recorded as pass or blocked with a typed blocker
- deferred-scope and A1-freeze checks are recorded as pass
- next owner (Reviewer) can resume without guessing

## 4A. Verification Test Scope

- Source implementation phases: P1, P2, P3, P4, P5
- Platform / Surface: Flutter mobile (`mobile-app`)
- Required levels:
  - unit: all Dream Jar cubit, model, repository, and formatter tests
  - integration: widget tests covering detail, list, create sheet, history, and the Home entry point
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - visual inspection: none at story level; requirement-level mobile visual audit only
  - accessibility: verify the §3-driven semantics/tap-target expectations already asserted by the phase widget tests
  - mobile build/type-check/static-analysis: REQUIRED (`flutter analyze` + `flutter build apk --debug`)
- Required runtime signals:
  - backend response/log/assertion evidence: fake-repository assertions only; no live backend needed
  - screenshot artifacts: `requirement visual audit only`
- Evidence format:
  - concise `coding-plan/test-results.md` rows only
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: YES (requirement level, after all REQ-001 stories are otherwise complete — not this story's gate)
  - Affected screens/routes: Home Dream Jar card, jar list, jar empty state, jar detail, create sheet, contribution history
  - Required entry surfaces: Home Money Dream Jar card
  - Provided runtime/artifact/screenshot command: to be provided by the requirement-level audit owner
- Risk-surface gates:
  - touched risk surfaces: decimal-as-string decoding, unpaired access (AC3), entry-point discoverability, progress bounds, double submission, ARB key parity, design-system compliance
  - source-of-truth artifacts: `../architecture/solution.md` §4, `master-plan.md` §3A
  - critical gates: `flutter analyze`, `flutter test`, `flutter build apk --debug`, plus the per-surface tests named in P1-P5
- Story-level runtime startup smoke: NOT_APPLICABLE — the runtime registry records that `flutter run` needs a connected interactive device, and readiness is the `flutter test` widget-test signal
- Local runtime/port safety gate: not required (no Docker, Compose, script, or registry change)
- Backend e2e gate: do not add

## 5. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
