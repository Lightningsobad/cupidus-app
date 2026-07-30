# Phase P4 – Verification

## 1. Objective

Verify the mobile lane output and story-level readiness for the review handoff.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P0, P1, P2, P3
- Parallelizable: NO
- Write Scope:
  - `mobile/test/features/vibes/**` (lane-owned test files)
  - `coding-plan/test-results.md`

## 2. Required Reads

- `../story_master.md` (AC1-AC3)
- `../architecture/solution.md` §2, §6, AC3 subsection
- owned implementation outputs under `mobile/lib/features/vibes/`
- `../ux/uiux-spec.md` §4, §8 (only the states this lane verifies)
- the `## 6. Test Scope` sections of P0, P1, P2, and P3

## 3. Verification Tasks

- confirm `master-plan.md` uses the required Phase Overview table schema
- confirm every listed phase has exactly one canonical `phase-Px-*.md` file
- confirm no duplicate phase files exist for the same phase id
- run the lane-relevant automated tests:
  `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test`
- run mobile static analysis / type-check:
  `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" analyze`
- do not plan or run mobile e2e, emulator/simulator lifecycle commands,
  signing, store upload, traces, or scenario reruns
- run the phase-specific regression checks: `mobile/test/design_system/**`,
  `mobile/test/core/network/**`, `mobile/test/features/auth/**`,
  `mobile/test/widget_test.dart`
- verify AC1 (set/share a vibe) and AC2 (partner view + 7-day strip) against the
  P0-P3 tests
- record AC3 as **deferred to requirement integration** with risk R-010-1: the
  paired route gate that AC3 depends on is absent at this story's BaseHead, and
  UX §7 forbids a screen-level guard as the primary control. Verify only this
  story's owned part: empty partner data renders the waiting/`none` state with no
  error
- verify every critical gate selected for the touched risk surfaces
  (`MOOD_CONTRACT_UNVERIFIED`, `VIBES_REPO_UNVERIFIED`, `BUCKETING_UNVERIFIED`,
  `SUBMIT_UNVERIFIED`, `A11Y_UNVERIFIED`, `ENTRYPOINT_UNVERIFIED`)
- confirm no `vibes` backend, DTO, or Swagger file changed (A1)
- confirm `mobile/lib/l10n/**` was not modified (D-010-6) and that
  `service_locator.dart` / `cupid_icons.dart` changes are additive only
- document results concisely in `coding-plan/test-results.md`

## 4. Acceptance Criteria

- required automated checks pass (`flutter test`, `flutter analyze`)
- critical regressions are resolved
- AC1 and AC2 are verified by this lane; AC3 is recorded as deferred with
  R-010-1 rather than silently claimed
- contract-sensitive behavior owned by this lane is verified (mood wire mapping,
  failure typing, local-date bucketing)
- critical gates for touched risk surfaces are recorded as pass, not required, or
  blocked with a typed blocker
- requirement-level mobile visual audit is deferred to the requirement level
  after all stories are otherwise complete
- next owner (Reviewer) can resume without guessing

## 4A. Verification Test Scope

- Source implementation phases: P0, P1, P2, P3
- Platform / Surface: Flutter mobile, `mobile/` package
- Required levels:
  - unit: `VibeMood`, `VibeEntry`, `VibesRepository`, bucketing, `VibeCubit`
  - integration: `VibeScreen` widget composition + entry-point navigation
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - visual inspection: requirement-level audit only
  - accessibility: mood cell accessible name, selected semantics, `--tap` size,
    revert announcement
  - mobile build/type-check/static-analysis: `REQUIRED` — `flutter analyze`
  - build gate: `DEVOPS only for root scripts; mobile-dev uses package-native flutter analyze/test`
  - local dev startup gate: `STORY-RUNTIME-SMOKE only; implementation lanes do not run scripts/start-dev.sh`
- Required runtime signals:
  - route/navigation entrypoint: `HomeScreen` entry card → `VibeScreen`
  - screenshot artifacts: `requirement visual audit only`
- Evidence format:
  - concise `coding-plan/test-results.md` rows only
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: YES (deferred to the
    requirement level, after all stories are otherwise complete)
  - Affected screens/routes: `vibe` screen, `home` entry card
  - Required entry surfaces: `HomeScreen` vibe entry card
  - Provided runtime/artifact/screenshot command: provided by the requirement
    visual audit owner; this phase does not launch a simulator
  - Screenshot budget: optimized small device/artifact screenshots
  - Required visual evidence: screenshot paths plus broken/misaligned mobile UI
    findings
- Risk-surface gates:
  - touched risk surfaces: mood wire mapping, REST read path, local-date
    bucketing, optimistic submit/revert, accessibility semantics, entry-point
    discoverability
  - source-of-truth artifacts: `../architecture/solution.md` §2/§4,
    `../ux/uiux-spec.md` §3-§8, `backend/src/modules/vibes/`
  - critical gates: the six typed gates listed in `master-plan.md` §3A
  - blocked gates: AC3 end-to-end verification (R-010-1, requires the paired
    route gate)
- Story-level runtime startup smoke:
  - NOT_APPLICABLE — the `mobile-app` readiness contract is the
    `home_screen_ready_signal` widget test, already covered by `flutter test`

## 5. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
