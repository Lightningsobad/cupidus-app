# Phase P6 – Verification

## 1. Objective

Verify the mobile lane output and story-level readiness for the review gate,
and author the AC 4 source-scan guard that protects all 31 later screens.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P0, P1, P2, P3, P4, P5
- Parallelizable: NO
- Write Scope:
  - `mobile/test/design_system/no_fork_guard_test.dart`
  - `coding-plan/test-results.md`

## 2. Required Reads

- `../architecture/solution.md` Risk Surfaces And Source Of Truth table
- `../story_master.md` AC 1–4
- the `## 6. Test Scope` sections of P0–P5
- owned implementation outputs

## 3. Verification Tasks

- Confirm `master-plan.md` uses the required Phase Overview table schema.
- Confirm every listed phase has exactly one canonical `phase-Px-*.md` file and no duplicates exist for any phase id.
- Author the AC 4 source-scan guard test: fail if `Color(0x`, `Colors.`, `Platform.is`, or `defaultTargetPlatform` appears anywhere under `mobile/lib/features/`, `mobile/lib/app/`, or `mobile/lib/core/` (allowed only under `mobile/lib/design_system/`). This passes vacuously today; the guard itself is the deliverable that keeps the 31 later screens on one widget tree.
- Run the full mobile test suite: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test`.
- Run static analysis: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze`.
- Run the registry build gate: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter build apk --debug` (registry `mobile-app` `buildCommand`). This is the only gate that proves the bundled variable font and icon tree-shaking behavior from ADR-004d; if it requires `--no-tree-shake-icons`, confirm P5 recorded that in the configuration guide.
- Verify each of the five risk-surface gates from `../architecture/solution.md` is recorded as pass or as a typed blocker: 4-combination build (P1), contrast tripwire (P0), ARB key-parity plus resolution (P4), flag behavior (P5), AC 4 source-scan (this phase).
- Verify AC 1–4 are each traceable to a passing gate.
- Do not plan or run mobile e2e, emulator/simulator lifecycle commands, signing, store upload, traces, scenario reruns, or `scripts/start-dev.sh`.
- Document results concisely in `coding-plan/test-results.md`.

## 4. Acceptance Criteria

- Required automated checks pass.
- Critical regressions are resolved.
- AC 1–4 are verified and each maps to a named passing gate.
- Critical gates for every touched risk surface are recorded as pass, not required, or blocked with a typed blocker.
- The AC 4 source-scan guard exists and runs as part of `flutter test`.
- The next owner (Reviewer) can resume without guessing.

## 4A. Verification Test Scope

- Source implementation phases: P0, P1, P2, P3, P4, P5
- Platform / Surface: Flutter mobile (`mobile/`), design-system and app-composition layers
- Required levels:
  - unit: contrast tripwire, 4-combination matrix, icon variant mapping, ARB key parity, flag defaults
  - integration: adaptive widget tests on both platforms, both-locale resolution, `CupidApp` flag-behavior widget test
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - desktop/electron e2e: `DO NOT PLAN for ordinary continue`
  - accessibility: contrast tripwire test (ADR-004b) plus `tapTarget` minimum hit-target assertions from P3
  - mobile build/type-check/static-analysis: REQUIRED — `flutter analyze` plus registry `flutter build apk --debug`
  - build gate: package-native only; mobile-dev does not run repository-root scripts
  - local dev startup gate: `STORY-RUNTIME-SMOKE only; implementation lanes do not run scripts/start-dev.sh`
- Required runtime signals:
  - backend response/log/assertion evidence: N/A — no backend surface in this story
  - screenshot artifacts: `requirement visual audit only`
- Evidence format:
  - concise `coding-plan/test-results.md` rows only
- Requirement frontend visual audit:
  - Required when requirement has frontend participation: NO — REQ-001 has no web frontend lane
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: YES, but deferred to the requirement level after all REQ-001 stories are otherwise complete. STORY-001 renders no screen of its own, so there is nothing story-local to audit.
  - Affected screens/routes: deferred to the requirement-level audit
  - Provided runtime/artifact/screenshot command: deferred to the requirement-level audit
  - Screenshot budget: optimized small device/artifact screenshots
- Risk-surface gates:
  - touched risk surfaces: 4-combination completeness, light-accent contrast, locale parity, no-fork discipline, flag behavior, font/icon asset bundling
  - source-of-truth artifacts: `../architecture/solution.md` Risk Surfaces table; `../ux/uiux-spec.md` sections 2–7
  - critical gates: the five listed in Verification Tasks plus the registry build gate
  - blocked gates: none expected; record a typed blocker if the Flutter SDK cannot be resolved
- Story-level runtime startup smoke:
  - REQUIRED. Registry `mobile-app` readiness is a widget-test signal, not an HTTP probe: `flutter pub get` then `flutter test` must resolve `Key('home_screen_ready_signal')`. No device, emulator, or `flutter run` is involved.
- Local runtime/port safety gate:
  - Not required — this story changes no Docker, Compose, port, or runtime registry entry.
- Backend e2e gate:
  - Do not add for ordinary continue

## 5. Status

- Status: DONE
- Last updated: 2026-07-29
- Evidence:
  - `flutter test` (full suite): 42/42 passed.
  - `flutter analyze`: "No issues found!"
  - `flutter build apk --debug` (registry `mobile-app` `buildCommand`): built `build/app/outputs/flutter-apk/app-debug.apk`; `--no-tree-shake-icons` not required for a debug build.
  - `mobile/test/design_system/no_fork_guard_test.dart` (new): scans `lib/features/`, `lib/app/`, `lib/core/` for `Color(0x`, `Colors.`, `Platform.is`, `defaultTargetPlatform`; 1/1 passed, vacuously (zero violations today).
  - `master-plan.md` Phase Overview schema confirmed; 7 canonical `phase-Px-*.md` files on disk, one-to-one with the Phase file mapping table, no duplicates.
  - All 5 risk-surface gates and all 4 story ACs recorded pass with named gates in `coding-plan/test-results.md` (full detail, this phase's other Write Scope file).
  - `Key('home_screen_ready_signal')` confirmed resolving under the full suite.
  - No mobile e2e, emulator/simulator lifecycle, signing, store upload, or `scripts/start-dev.sh` run, per instruction.
