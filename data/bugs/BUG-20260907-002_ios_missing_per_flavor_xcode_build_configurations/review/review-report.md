---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-09-07
reviewed_by: Reviewer
---

# Review Report: BUG-20260907-002 iOS Missing Per-Flavor Xcode Build Configurations

Outcome: DEFERRED_ONLY

## Reviewed Inputs

- Review gate: `bugfix-review`
- Scope Gate: `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/review/scope-gate.md`
- Requirements: `N/A` (pre-existing repo-wide iOS build-tooling defect, not story-linked for expected behavior)
- Bug Report: `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/diagnosis.md`
- Fix Evidence: `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/fix-evidence.md`
- UX: `N/A`
- Architecture: `N/A`
- Coding Plan: `N/A`
- Test Results: `fix-evidence.md` sections `## Original Failure Recheck Gate`, `### A/B control`, `## Regression Coverage`, `## Build Gate`, `## Runtime Startup Gate`
- Previous review findings: `N/A` (first review pass)

## Reviewed Scope

- Story complexity: `N/A`
- Bug status: `IN_PROGRESS` in `bug_master.md`; `BUG_FIX_COMPLETE: YES` in `fix-evidence.md`
- Code scope reviewed: commit `62f451733d191b666b718b595ead4621676e3e1c` (HEAD of `main`, control checkout, no story worktree)
  - `mobile/ios/Runner.xcodeproj/project.pbxproj` (diff-only / ranged reads, per handoff)
  - `mobile/ios/Runner.xcodeproj/xcshareddata/xcschemes/local.xcscheme`
  - `mobile/ios/Runner.xcodeproj/xcshareddata/xcschemes/prod.xcscheme`
  - `mobile/test/tooling/ios_android_flavor_parity_test.dart`
  - `mobile/android/app/build.gradle.kts:36-45` (parity source of truth)
  - `mobile/lib/core/config/cupid_api_config.dart` (flavor consumer, read to check parity semantics)
  - `mobile/pubspec.yaml:87` (`default-flavor: local`)
- Evidence reviewed: `evidence/ios-runtime-startup-local-flavor.png` (opened and inspected, not counted), `git show --numstat 62f4517`
- Risk surfaces reviewed: runtime/configuration (Xcode build configuration + shared scheme wiring), operational command (`flutter build ios` for runtime `mobile-app`), app lifecycle (simulator launch to first frame)
- Critical gates reviewed: pre-fix reproduction, original-failure recheck (same modality), build gate, regression guard with negative control, runtime startup smoke, non-mutation of pre-existing pbxproj objects
- Backend targeted verification gates: `NOT_APPLICABLE`
- Story runtime startup smoke: `PASS` (bugfix runtime startup gate, runtime `mobile-app`)
- Frontend targeted verification gates: `NOT_APPLICABLE`
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE`
- Mobile targeted verification gates: `PASS`
- Mobile discoverability/navigation integration: `NOT_APPLICABLE` (build-configuration fix; no navigation or user-facing surface changed)
- Requirement mobile visual audit: `NOT_APPLICABLE` (bugfix scope, not requirement closure; no UI behavior changed)
- Story artifacts reviewed: none (bug is explicitly not story-linked for expected behavior)
- Bug artifacts reviewed: `bug_master.md`, `diagnosis.md`, `fix-evidence.md`, `evidence/ios-runtime-startup-local-flavor.png`
- OQ context reviewed: `N/A`

## Outcome Summary

- Review outcome: DEFERRED_ONLY
- Rationale: The fix resolves the reported root cause at the right layer and the
  evidence is independently verifiable. Every claim in `fix-evidence.md` that
  could be checked from the committed diff was checked and held:
  `git show --numstat` reports `572 insertions, 0 deletions` on
  `project.pbxproj`, so no pre-existing object was mutated or removed; exactly
  18 new `XCBuildConfiguration` objects exist; all 18 are registered in the
  three `XCConfigurationList` `buildConfigurations` arrays
  (`97C1470{3,4}`/`249021D3` project list, `97C1470{6,7}`/`249021D4` Runner
  list, `331C808{8,9,A}` RunnerTests list) with `defaultConfigurationName`
  left at `Release`; clone fidelity was spot-verified byte-for-byte for the
  project-level `Profile` -> `Profile-local` pair (identical apart from `name`);
  the six Runner-target configurations carry the correct
  `baseConfigurationReference` (`Debug.xcconfig` for both `Debug-*`,
  `Release.xcconfig` for `Release-*` and `Profile-*`); and Debug-only settings
  (`ENABLE_TESTABILITY`, `GCC_OPTIMIZATION_LEVEL = 0`, `ONLY_ACTIVE_ARCH`,
  `SWIFT_OPTIMIZATION_LEVEL = "-Onone"`, `SWIFT_ACTIVE_COMPILATION_CONDITIONS =
  DEBUG`) appear only in `Debug-*` objects while `SWIFT_COMPILATION_MODE =
  wholemodule` / `-O` / `VALIDATE_PRODUCT` appear only in `Release-*`/`Profile-*`,
  so no configuration was cloned from the wrong base. Both new schemes diff
  against `Runner.xcscheme` as clones whose only changes are the five
  `buildConfiguration` attributes, with the Flutter PreAction, blueprint
  references and `customLLDBInitFile` intact; `Runner.xcscheme` is untouched.
  The regression guard is genuinely parity-driven (it parses `productFlavors`
  out of `build.gradle.kts` rather than hardcoding `local`/`prod`) and its
  assertion string `name = "$mode-$flavor";` matches the exact pbxproj format,
  with a documented negative control. The runtime screenshot is a real device
  frame showing this app's onboarding screen with the DEBUG banner, not a
  splash, blank or error frame, which independently confirms the `Debug-local`
  configuration produced an actual debug build that reached first frame. The
  A/B control (revert -> original failure reproduces -> restore -> passes)
  establishes causality rather than correlation. Deferred items are
  documentation-accuracy and future-robustness notes; none of them affects the
  reported behavior or the correctness of the committed change.
- Blocking findings: 0
- Deferred findings: 4
- Dismissed observations: 1

## Traceability Summary

- Requirements: `N/A` — `bug_master.md` "Expected behavior" is the governing
  contract. It allowed either per-flavor configurations OR removing the iOS
  `--flavor` requirement; the fix delivers both conditions (flavored builds pass
  and the unflavored invocation also passes), which satisfies the OR.
- Bug report: both quoted failure strings ("You must specify a --flavor option
  to select one of the available schemes." and "Flutter expects a build
  configuration named Debug-Runner or similar.") are absent from all three
  post-fix runs.
- Diagnosis: `## Pre-Fix Reproduction Gate` present, same modality as the
  report, `Result: REPRODUCED`. Root cause (`reportFlavorNotFoundAndExit` at
  `xcodeproj.dart:721` reached because SPM package schemes make the project
  scheme-customised) is consistent with the fix applied.
- Open Questions: `N/A`
- UX: `N/A`
- Architecture: `N/A`
- Testing evidence: `## Original Failure Recheck Gate` `Same modality as
  original: YES`, `Result: PASS` (3 CLI builds, exit 0); `## Build Gate`
  `Result: PASS` (`plutil -lint` OK, `xcodebuild -list` shows the 6 flavored
  configurations and the `local`/`prod` schemes, simulator build exit 0, guard
  test 3/3); `## Runtime Startup Gate` `Result: PASS` (registry runtime
  `mobile-app`, `readiness.iosCommand` run verbatim, `READINESS_EXIT=0`,
  screenshot, terminate + shutdown exit 0).

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Runtime/configuration (Xcode build configs) | `mobile/android/app/build.gradle.kts` `productFlavors` | pbxproj structural validity + additive-only change | PASS | `plutil -lint` OK; 572 insertions / 0 deletions; 18 new objects registered in all 3 config lists |
| Operational command (`flutter build ios`) | `bug_master.md` reported commands | Original-failure recheck, same modality | PASS | unflavored 90.5s, `--flavor local` 17.7s, `--flavor prod` 39.4s, all exit 0; A/B revert reproduces original failure |
| App lifecycle (iOS launch) | `data/devops/system/runtime-command-registry.json` `mobile-app` | Runtime startup smoke with readiness + shutdown | PASS | iPhone 17 simulator; `readiness.iosCommand` verbatim, `READINESS_EXIT=0`; screenshot shows real onboarding frame with DEBUG banner; clean terminate/shutdown |
| Regression re-entry | This bug's root cause | Parity guard test, proven non-no-op | PASS | `mobile/test/tooling/ios_android_flavor_parity_test.dart` derives flavors from Gradle; negative control fails as expected |
| Scheme wiring | `Runner.xcscheme` | Action-to-configuration mapping | PASS | Run/Test/Analyze -> `Debug-*`, Profile -> `Profile-*`, Archive -> `Release-*`; PreAction and blueprint refs preserved |
| Release/archive signing | `Release.xcconfig` | Archive build with signing | NOT_EXERCISED | Deferred D3; out of the reported scope, `--no-codesign` matched the reported command |

## Deferred Findings

- D1 (documentation accuracy, `diagnosis.md` "Cluster Boundary" and
  `fix-evidence.md` "Residual Risks"): both state Android's `local` and `prod`
  flavors are "value-identical today". That is true at the Gradle level, but not
  behaviorally — `mobile/lib/core/config/cupid_api_config.dart:39` computes
  `_isProductionFlavor = appFlavor == 'prod'`, so the flavor already selects
  `productionBaseUrl` vs `localBaseUrl` in Dart. This does not change the
  verdict: `appFlavor` is fed by the Flutter tool's platform-agnostic
  `FLUTTER_APP_FLAVOR` dart-define, so cloned iOS configurations are the correct
  shape and no iOS-side value differentiation is owed. Only the prose
  understates what the flavors already do.
- D2 (unverified downstream behavior): no iOS `--flavor prod` binary was
  launched, so `appFlavor == 'prod'` resolving to `https://api.cupidus.app` was
  not empirically confirmed on iOS. The `--flavor prod` build exits 0, which is
  the full extent of this bug's contract; Dart-side backend resolution is
  REQ-008 scope. Worth a one-line confirmation whenever an iOS prod build is
  next produced.
- D3 (already recorded by Bug Fixer): `Release-*` and `Profile-*` configurations
  are structurally verified but never built — `--no-codesign` and `--debug` were
  used throughout, matching the reported command. Archive/signing behavior with
  the new configurations remains unexercised. They inherit `Release.xcconfig`
  unchanged, so no signing behavior was altered.
- D4 (guard robustness, `ios_android_flavor_parity_test.dart:20-24`): the test
  takes `gradle.substring(start)` from the `productFlavors` index to end of file
  and regex-matches every `create("...")` in that remainder. Today
  `build.gradle.kts` contains exactly the two flavor `create(` calls, so the
  guard is correct. A future `signingConfigs { create("release") }` placed after
  the flavors block would make it demand a `Debug-release` configuration. The
  failure mode is a loud false positive, never a silent pass, so this is a
  robustness note rather than a defect.

## Dismissed Observations

- The evidence does not explain why the *unflavored* build began passing, which
  initially looked like a possible environment artifact. It is not: `mobile/pubspec.yaml:87`
  declares `default-flavor: local`, so an unflavored invocation resolves to the
  `local` scheme and `Debug-local` configuration — both of which this fix
  created. Pre-fix the `local` scheme did not exist, so resolution returned null
  and dead-ended in `reportFlavorNotFoundAndExit`. The causality is sound and the
  A/B control confirms it empirically. Recorded here rather than as a finding so
  the "unflavored also works now" claim is not later read as unconditional:
  it depends on `default-flavor: local` remaining in `pubspec.yaml`.

## Workflow State Recommendation

- Story status: `N/A`
- Bug status: `DONE`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: Scrum Master marks BUG-20260907-002 `DONE` in `bug_master.md` and
  `data/bugs/master_bugs_list.md`, then unblocks the REQ-016/STORY-003 iOS build
  verification path that this bug was gating. The fix is already committed on
  `main` as `62f451733d191b666b718b595ead4621676e3e1c`; no merge action is
  outstanding. D1-D4 need no rework routing.
- State update owner: `scrum-master` only. Reviewer does not edit story or requirement status files.
