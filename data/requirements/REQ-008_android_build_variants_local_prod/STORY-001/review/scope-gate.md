# Scope Gate — REQ-008 / STORY-001 Android Studio Build Variants For Local/Prod Backend

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: compact-story-review
- Review report path: `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/review/review-report.md`
- Date: 2026-08-24
- Complexity: standard | Implementation Lane: shared | Story-Class: standard
- Diff baseline: `f52ec488801b6c5c68558d8f71ce5f38df2be7d9` (Worktree `/Users/alantravala/workspace/snapsofts/cupid-apps`, Branch `main`)

Note: the handoff and skill rule 5a specify an inline `Scope Gate` section for
`compact-story-review` and no separate file. `validate-reviewer-two-phase.sh`
requires this file regardless, so it is written to satisfy the guard and mirrors
the inline section in `review-report.md` exactly.

## Source/Test Files In Scope

- `mobile/android/app/build.gradle.kts`
- `mobile/pubspec.yaml`
- `mobile/lib/core/config/cupid_api_config.dart`
- `mobile/test/core/config/cupid_api_config_test.dart`
- `data/requirements/REQ-008_android_build_variants_local_prod/deployment/configuration-guide.md`
- `mobile/lib/main.dart` (read-only, to verify the `assertValidConfig()` call site)

## Evidence Files In Scope

- `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/story_master.md`
- `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/requirements/requirements.md` (AC1-6, Business Rules, Edge Cases, `## Open Question Impact`)
- `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/architecture/solution.md` (§1 Key Discovery, §3, §4, §6)
- `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/coding-plan/master-plan.md` (§1, §4, §6)
- `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/coding-plan/test-results.md` (runs 1-13, §6, §7, §8)

## Out Of Scope (verified unrelated to this story)

- `mobile/ios/Runner.xcodeproj/project.pbxproj`, `mobile/ios/Runner/Base.lproj/Main.storyboard` — pre-existing uncommitted working-tree changes; iOS is explicitly out of story scope
- `data/devops/system/runtime-command-registry.json` — +1 line, a `web-frontend` `dependsOnRationale` annotation
- `data/requirements/master_requirements_list.md` — +1 REQ-008 registry row

## Touched Risk Surfaces And Critical Gates To Verify

| Risk Surface | Source Of Truth | Critical Gate |
|---|---|---|
| Runtime/configuration — Android build variant registration (AC1) | `mobile/android/app/build.gradle.kts` | Plain-Gradle variant task listing + both flavored assembles |
| Runtime/configuration — build-time base-URL resolution (AC2-AC4, AC6) | `mobile/lib/core/config/cupid_api_config.dart` | Per-flavor unit tests + scoped static analysis |
| Operational command — existing local build path (AC5) | `mobile/pubspec.yaml` | Unmodified registry `mobile-app.buildCommand` still produces an artifact |
| Security/auth — Google Sign-In package match | `mobile/android/app/google-services.json` | `applicationId` identical across variants |
| App lifecycle — startup config guard on a flavored binary | `mobile/lib/main.dart` | Story runtime startup smoke (rule 12g) |

UI gates (12e1 entry point, 12e2/12e3 visual fidelity) are NOT REQUIRED:
`story_master.md` records `UX-Spec: WAIVED` and `requirements.md` `## Out of Scope`
excludes any end-user-facing UI. Mobile e2e, emulator install/uninstall cycles,
signing, and store upload are not required.

## Focused Query Keys For Phase 2

- AC1, AC2, AC3, AC4, AC5, AC6
- `flavorDimensions`, `productFlavors`, `applicationIdSuffix`, `versionNameSuffix`
- `appFlavor`, `FLUTTER_APP_FLAVOR`, `default-flavor`
- `validationError`, `requiredEnvironmentForFlavor`, `assertValidConfig`, `_isProductionFlavor`
- `productionBaseUrl`, `localBaseUrl`, `CUPID_ENV`, `CUPID_API_BASE_URL`
- "and vice versa" (architecture §4 symmetric-check request vs. implemented asymmetric rule set)
- `Runtime-Smoke`, `Startup Smoke`, `## Story Runtime Startup Smoke`
- `## Open Question Impact`, req_master.md inline OQ on Gradle flavor structure

## Tooling Constraint Recorded

The `Grep` tool returned `No such tool available: Grep. Grep is not available in
this session` when called. Shell `grep` over `mobile/**` is blocked by
`guard-query-first-bash-read.sh` (`SHELL_GREP_SOURCE`). Source inspection
therefore used the Git boundary diff (`git -C <Worktree> diff <BaseHead>`) plus
ranged `Read`, which was sufficient for all six in-scope files.

## Gate Decision

Phase 2 focused verification MAY PROCEED. All governing artifacts are present
and under roughly 20 KB (largest: `test-results.md` at 10.8 KB), the six in-scope
files are within the `compact-story-review` budget of 8, and no large governing
artifact is consumed. No BLOCKED condition at scope-gate time.
