# Review Scope Gate: BUG-20260907-002 iOS Missing Per-Flavor Xcode Build Configurations

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `bugfix-review`
- Review report path: `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/review/review-report.md`
- Scope gate path: `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/review/scope-gate.md`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: 4 changed source/config
  files (1 generated pbxproj, 2 new schemes, 1 new Dart guard test), well inside
  the bugfix budget. The only large file (`project.pbxproj`) is query-first /
  ranged only, per the handoff `Do Not Re-read` instruction. Single root-cause
  cluster (iOS flavor dimension), single runtime (`mobile-app`).
- Current story or bug status: `bug_master.md` `Status: IN_PROGRESS`;
  `fix-evidence.md` `BUG_FIX_COMPLETE: YES`. No story worktree; fix committed on
  `main` as `62f451733d191b666b718b595ead4621676e3e1c` (HEAD).

## Governing Inputs

- Primary artifacts:
  - `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/bug_master.md`
  - `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/diagnosis.md`
  - `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/fix-evidence.md`
- Existing review findings: `N/A` (first review pass)
- Test evidence: `fix-evidence.md` sections `## Original Failure Recheck Gate`,
  `### A/B control`, `## Regression Coverage`, `## Build Gate`,
  `## Runtime Startup Gate`
- Extra artifacts required beyond the default minimum: none. Story artifacts for
  REQ-016/STORY-003 are NOT in scope — the bug is explicitly pre-existing and
  not story-linked for expected behavior.

## Source/Test Files In Scope

- `mobile/ios/Runner.xcodeproj/project.pbxproj` (ranged/query-first only)
- `mobile/ios/Runner.xcodeproj/xcshareddata/xcschemes/local.xcscheme`
- `mobile/ios/Runner.xcodeproj/xcshareddata/xcschemes/prod.xcscheme`
- `mobile/test/tooling/ios_android_flavor_parity_test.dart`
- `mobile/android/app/build.gradle.kts` (flavor declaration only, lines ~36-53,
  as the parity source of truth)

## Evidence Files In Scope

- `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/evidence/ios-runtime-startup-local-flavor.png`
- `git show --stat 62f4517` / `git show --numstat` for insertion-vs-deletion
  proof on `project.pbxproj`

## Risk Surfaces And Critical Gates

- Touched risk surfaces: runtime/configuration (Xcode build configuration and
  shared scheme wiring), operational command (`flutter build ios` for the
  `mobile-app` runtime), app lifecycle (simulator launch to first frame).
  No Dart product code, no persistence/schema, no external integration, no
  security/auth surface touched.
- Source-of-truth artifacts or contracts:
  `mobile/android/app/build.gradle.kts` `productFlavors` (the parity contract),
  `data/devops/system/runtime-command-registry.json` `mobile-app`
  `readiness.iosCommand` (already consulted by Bug Fixer; not re-read).
- Critical gates to verify:
  1. `diagnosis.md` has `## Pre-Fix Reproduction Gate` with `Result: REPRODUCED`
  2. `## Original Failure Recheck Gate` with `Same modality as original: YES`,
     exercising both reported error strings via the same CLI modality
  3. Build Gate PASS (pbxproj structural validity + real iOS builds)
  4. Regression guard exists, is parity-driven, and is proven not a no-op
  5. Runtime Startup Gate PASS for runtime `mobile-app` with readiness + shutdown
  6. No pre-existing pbxproj object mutated (additions only)
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` (bugfix, no frontend
  participation)
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary
  continue` (the simulator run here is the bugfix runtime startup gate, which is
  required for a bugfix, not a story-level mobile e2e requirement)
- Requirement mobile visual audit evidence: `NOT_APPLICABLE` (bugfix scope, not
  a requirement closure; no UI behavior changed)
- Missing gate evidence or blocker: `N/A`

## Query Keys

- pbxproj: `Debug-local`, `Debug-prod`, `Release-local`, `Release-prod`,
  `Profile-local`, `Profile-prod`, `buildConfigurations`,
  `defaultConfigurationName`, `baseConfigurationReference`,
  `97C146E91CF9000F007C117D`, `97C147051CF9000F007C117D`,
  `331C8087294A63A400263BE5`
- schemes: `buildConfiguration = "Debug-local"`, `Profile-local`,
  `Release-local`, `PreActions`, `Runner.app`, `RunnerTests.xctest`
- parity test: `flavorDimensions`, `productFlavors`, `xcscheme`, `expect(`
- gradle: `productFlavors`, `create("local")`, `create("prod")`
- evidence: `Same modality as original: YES`, `Result: PASS`,
  `READINESS_EXIT=0`, `PATCH_RESTORED_AND_VERIFIED`

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: N/A
- If `NO`, exact blocker or re-scope instruction: N/A
