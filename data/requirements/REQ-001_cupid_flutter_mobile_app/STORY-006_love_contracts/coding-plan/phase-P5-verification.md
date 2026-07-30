# Phase P5 – Mobile Verification

## 1. Objective

Verify the mobile lane output and story-level readiness for the review handoff: AC1-AC4 against the
ADR-006c capability limit, every named risk-surface gate, and the full `mobile` test suite.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P0, P1, P2, P3, P4
- Parallelizable: NO
- Write Scope:
  - `mobile/test/features/love_contracts/**` (test fixes only)
  - `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-006_love_contracts/coding-plan/test-results.md`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE — this story adds no runtime surface, no port, and no env var;
    the registry's readiness signal is the `home_screen_ready_signal` widget test, covered below
  - Build Command Source: runtime registry `buildCommand` (`flutter build apk --debug`) — OPTIONAL,
    required only if a native or dependency change appeared during implementation (none is planned)
  - Readiness Check: `Key('home_screen_ready_signal')` via `mobile/test/widget_test.dart`
  - Port Contract: N/A

## 2. Required Reads

- `../story_master.md` (AC1-AC4)
- `../architecture/solution.md` §4 Risk Surfaces And Source Of Truth, ADR-006c
- the `## 6. Test Scope` sections of `phase-P0` through `phase-P4`
- the implementation outputs under `mobile/lib/features/love_contracts/`

## 3. Verification Tasks

- confirm `master-plan.md` uses the required Phase Overview table schema
- confirm every listed phase has exactly one canonical `phase-Px-*.md` file and no duplicates exist
- run `flutter test` for the whole `mobile` package (Flutter SDK resolves via `FLUTTER_SDK_PATH`,
  default `$HOME/flutter`; it is not on `PATH`)
- run `flutter analyze` and record it clean
- run each phase-specific check listed in P0-P4 `## 6. Test Scope`
- verify AC1: a paired user can propose/save clauses (`POST /love-contracts`) — bloc + screen tests
- verify AC2 at the ADR-006c capability: the creator can sign; the app renders the
  awaiting-partner state and never a partner-facing sign affordance; the sign-404 path shows the
  localized sign-unavailable copy
- verify AC3 at the ADR-006c capability: the current contract is viewable via the revisit entry
  point, rendered as a single current contract (the endpoint returns one row, not an array)
- verify AC4: the entry tile is hidden for unpaired users and on gate failure
- verify every risk-surface gate in `../architecture/solution.md` §4 is recorded as pass, not
  required, or blocked with a typed blocker
- confirm no file under `backend/` changed and no new entry appeared in `mobile/pubspec.yaml`
  dependencies or dev_dependencies
- confirm no `package:cupid_api/...` import exists in `mobile/lib/features/love_contracts/`
- record OQ-006A as an open, non-blocking escalation in `test-results.md` so the review gate sees
  the AC2/AC3 capability limit explicitly instead of reading it as a defect
- document results concisely in `test-results.md`

## 4. Acceptance Criteria

- `flutter test` and `flutter analyze` both pass for the `mobile` package
- AC1-AC4 are each recorded as verified at the ADR-006c capability, with the limit stated
- every risk-surface gate is recorded as pass, not required, or blocked with a typed blocker
- `home_screen_ready_signal` readiness regression is recorded as pass
- ARB parity is recorded as pass
- `backend/` is untouched and no new pub dependency exists
- OQ-006A is recorded as open and non-blocking
- the next owner (Reviewer) can resume without guessing

## 4A. Verification Test Scope

- Source implementation phases: P0, P1, P2, P3, P4
- Platform / Surface: Flutter `mobile` package (unit + widget)
- Required levels:
  - unit: P0 data mapping/failure tests; P1 bloc state-machine tests
  - integration: P2/P3/P4 widget-level screen + Bloc + fake repository tests
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - desktop/electron e2e: `DO NOT PLAN for ordinary continue`
  - accessibility: semantics assertions from P2 (toggle state, sheet focus) and P3 (hold
    activation alternative)
  - mobile build/type-check/static-analysis: `flutter analyze` REQUIRED; `flutter build apk --debug`
    OPTIONAL (only if a native or dependency change appeared)
  - local setup gate: `DEVOPS only`
  - build gate: `DEVOPS only for root scripts; mobile-dev uses package-native flutter analyze/test`
  - local dev startup gate: `STORY-RUNTIME-SMOKE only; implementation lanes do not run scripts/start-dev.sh`
- Required runtime signals:
  - screenshot artifacts: `requirement visual audit only`
- Evidence format:
  - concise `coding-plan/test-results.md` rows only
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: YES — but scheduled at requirement level
    after all REQ-001 stories are otherwise complete, not inside this story
  - Affected screens/routes: `HomeScreen` entry tile, `LoveContractScreen` (empty, clause-populated,
    signed-by-me, awaiting-partner, error states)
  - Required entry surfaces: the `HomeScreen` "Love Contract" tile
  - Provided runtime/artifact/screenshot command: to be provided by the requirement-level audit
    owner; do not launch an emulator in this phase
  - Screenshot budget: optimized small device/artifact screenshots
  - Required visual evidence: screenshot paths plus broken/misaligned mobile UI findings
- Risk-surface gates:
  - touched risk surfaces: untyped response bodies; creator-only capability; ceremony state
    machine; clause constraints 1..20; AC4 pairing gate; custom-gesture accessibility; l10n parity;
    runtime readiness regression
  - source-of-truth artifacts: `../architecture/solution.md` §4 table
  - critical gates: the per-surface minimum gates recorded in that table
  - blocked gates: none expected; report a typed blocker if any cannot run
- Story-level runtime startup smoke:
  - NOT_APPLICABLE — no runtime surface, port, or env var changes; readiness is covered by the
    `home_screen_ready_signal` widget test
- Backend e2e gate:
  - Do not add for ordinary continue

## 5. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
