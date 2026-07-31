# Phase P9 – Verification

## 1. Objective

Verify the mobile lane output and story-level readiness for the review gate:
consolidated static analysis, the full targeted test suite, and explicit AC1-AC3
evidence.

## 1A. Ownership

- Phase ID: P9
- Canonical Phase File: `phase-P9-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P6, P7, P8
- Parallelizable: NO
- Write Scope:
  - `mobile/test/features/pet/**`
  - `coding-plan/test-results.md`

## 2. Required Reads

- `../story_master.md` (AC1-AC3)
- `../architecture/solution.md` §4 Risk Surfaces And Source Of Truth
- owned implementation outputs from P1-P8
- `../ux/uiux-spec.md` §2.3, §5, §9 (guard, resolved open items, out of scope)
- the `## 6. Test Scope` section of every phase P1-P8

## 3. Verification Tasks

- confirm `master-plan.md` uses the required Phase Overview table schema
- confirm every listed phase has exactly one canonical `phase-Px-*.md` file
- confirm no duplicate phase files exist for the same phase id
- run `cd mobile && flutter analyze` and record the result
- run `cd mobile && flutter test` (full suite) and record pass/fail counts
- verify AC1: a paired couple with a pet sees the current state — payload name,
  level, mood label, status line, XP, and stats all sourced from
  `GET /pets/status`
- verify AC2: every interactive affordance maps to a real `pets` capability —
  Feed and Play both hit `PATCH /pets/interact`, adopt hits `POST /pets/adopt`,
  and no other pet mutation exists in the feature
- verify AC3: unpaired users reach neither the pet content nor the adopt sheet,
  from both `PetScreen` and the `HomeScreen` preview card
- verify the out-of-scope list in `../ux/uiux-spec.md` §9 by search: no `sleep`
  state, no streak, no badge, no per-species sprite art, no `pets` endpoint or
  DTO change anywhere in the diff
- verify `backend/` is untouched in the story diff (A1 freeze)
- verify `mobile/pubspec.yaml` has no new dependency and no `assets:` section
- verify `Key('home_screen_ready_signal')` still pumps
- verify the new `CupidIcons` constants document cmap-verified codepoints
- document results in concise form in `coding-plan/test-results.md`

## 4. Acceptance Criteria

- `flutter analyze` reports no new issues
- `flutter test` passes with no skipped pet tests
- AC1, AC2, and AC3 each have a recorded evidence row
- every risk surface in `../architecture/solution.md` §4 is recorded as pass, not
  required, or blocked with a typed blocker
- the A1 freeze and the §9 out-of-scope list are confirmed by search evidence
- the next owner (Reviewer) can resume without re-deriving context

## 4A. Verification Test Scope

- Source implementation phases: P1, P2, P3, P4, P5, P6, P7, P8
- Platform / Surface: Flutter (`mobile`), runtime registry id `mobile-app`
- Required levels:
  - unit: `test/features/pet/data`, `test/features/pet/presentation` cubit tests
  - integration: widget-level screen + navigation tests (P5, P6, P7, P8)
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - visual inspection: five sprite states compared against
    `Bun Sprite.dc.html`, recorded as one line
  - accessibility: Feed/Play distinct labels, cooldown disabled semantics,
    adopt-sheet radio-group and focus return, guard-state page titles
  - mobile build/type-check/static-analysis: `flutter analyze` REQUIRED;
    `flutter build apk --debug` OPTIONAL (run only if a toolchain is already
    available; not a gate)
  - build gate: `DEVOPS only for root scripts; mobile-dev uses package-native
    mobile build/type-check/static-analysis`
  - local dev startup gate: `STORY-RUNTIME-SMOKE only; implementation lanes do
    not run scripts/start-dev.sh`
- Required runtime signals:
  - route/navigation entrypoint: `HomeScreen` → `PetPreviewCard` → `PetScreen`
  - assertion evidence: emitted cubit states, stubbed-adapter request
    verb/path/body, rendered text and semantics
  - screenshot artifacts: `requirement visual audit only`
- Evidence format:
  - concise `coding-plan/test-results.md` rows only
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: YES
  - Affected screens/routes: `PetScreen`, `HomeScreen` preview card, adopt sheet
  - Required entry surfaces: `HomeScreen` preview card
  - Provided runtime/artifact/screenshot command: deferred to requirement
    integration; not a STORY-011 gate
  - Screenshot budget: optimized small device/artifact screenshots
  - Required visual evidence: screenshot paths plus broken/misaligned mobile UI
    findings
- Risk-surface gates:
  - touched risk surfaces: untyped `pets` REST parsing, mood → sprite mapping,
    pairing hard gate (AC3), 5s interaction cooldown, adopt input validation, new
    icon codepoints, entry-point reachability
  - source-of-truth artifacts: `backend/src/modules/pets/`,
    `backend/src/modules/users/users.controller.ts`, `../ux/uiux-spec.md` §3/§4,
    bundled `MaterialSymbolsRounded-Variable.ttf`, `mobile-app` registry entry
  - critical gates: as listed per phase in `master-plan.md` §3A
  - blocked gates: record with a typed blocker if any cannot run
- Story-level runtime startup smoke: NOT_APPLICABLE — the `mobile-app` registry
  readiness signal is a `flutter test` widget key, already covered by the P8
  regression assertion, and `flutter run` requires an interactive device.
- Backend e2e gate: do not add for ordinary continue

## 5. Status

- Status: DONE
- Evidence: `coding-plan/test-results.md` — `flutter analyze` 0 new issues,
  `flutter test` 212/213 (1 pre-existing P6 no-fork-guard failure, outside
  P8/P9 WriteScope, recorded as a typed BLOCKER for the review gate), AC1-AC3
  PASS, all risk surfaces PASS or already gated, A1 freeze and §9 out-of-scope
  list confirmed by search evidence.
- Last updated: 2026-07-31
