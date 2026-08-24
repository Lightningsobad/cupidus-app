# Review Report — REQ-008 / STORY-001 Android Studio Build Variants For Local/Prod Backend

- Review type: compact-story-review
- Date: 2026-08-24
- Complexity: standard | Implementation Lane: shared | Story-Class: standard
- Diff baseline: `f52ec488801b6c5c68558d8f71ce5f38df2be7d9` (Worktree `/Users/alantravala/workspace/snapsofts/cupid-apps`, Branch `main`)
- Revision: pass 2 (`completion/resume`, 2026-08-24) — F-001 re-verified only. AC1-6, the §4 deviation, OQ triage, and the configuration guide passed in pass 1 and were confirmed untouched: `git diff --stat <BaseHead> -- mobile/` still reports the identical `+16 / +57 / +5 / +132` implementation counts, so mobile-dev added evidence only.

Outcome: DEFERRED_ONLY

## Scope Gate

- Review type: `compact-story-review`. No separate `scope-gate.md` (skill rule 5a).
- Source/test/config files in scope (6):
  - `mobile/android/app/build.gradle.kts`
  - `mobile/pubspec.yaml`
  - `mobile/lib/core/config/cupid_api_config.dart`
  - `mobile/test/core/config/cupid_api_config_test.dart`
  - `data/requirements/REQ-008_android_build_variants_local_prod/deployment/configuration-guide.md`
  - `mobile/lib/main.dart` (read-only, to verify the `assertValidConfig()` call site)
- Evidence files in scope: `coding-plan/test-results.md` (all 13 runs, §6, §7, §8),
  `coding-plan/master-plan.md` §4/§6, `architecture/solution.md` §4,
  `requirements/requirements.md` AC1-6 + `## Open Question Impact`, `story_master.md`.
- Query keys: AC1-AC6, `appFlavor`, `default-flavor`, `validationError`,
  `requiredEnvironmentForFlavor`, `assertValidConfig`, `flavorDimensions`,
  "and vice versa", `Runtime-Smoke`, `Startup Smoke`.
- Out of scope (verified unrelated to this story): `mobile/ios/**` (pre-existing
  uncommitted working-tree changes), `data/devops/system/runtime-command-registry.json`
  (+1 line, a `web-frontend` `dependsOnRationale` annotation),
  `data/requirements/master_requirements_list.md` (+1 REQ-008 registry row).
- Tool note: the `Grep` tool returned `No such tool available` in this session;
  shell `grep` over `mobile/**` is blocked by `guard-query-first-bash-read.sh`.
  Source inspection therefore used the Git boundary diff plus ranged `Read`.

## Acceptance Criteria

| AC | Verdict | Basis |
|----|---------|-------|
| AC1 | PASS | `build.gradle.kts` declares dimension `backend` + flavors `local`/`prod`; runs 12/13 enumerate all 10 flavor×buildType variant tasks; runs 8/9 build both |
| AC2 | PASS | `_isProductionFlavor` feeds `defaultValue` of both keys; runs 2/3 assert `local` → `http://localhost:3000` with no dart-define |
| AC3 | PASS | Run 4 (`--flavor prod`, no dart-define) asserts `production` / `https://api.cupidus.app`; the recorded intermediate failure proves the flavor alone moved it |
| AC4 | PASS | Under AC4's stated condition (no CLI dart-define), flavor fully determines the pair; contradictions throw at startup via `main.dart:20` |
| AC5 | PASS | `flutter: default-flavor: local` at `pubspec.yaml:83` under the `flutter:` key (verified placement, not `dev_dependencies`); run 6 bare `flutter build apk --debug` still produces an installable APK |
| AC6 | PASS | Flavor supplies only the `defaultValue` of REQ-007's two existing `String.fromEnvironment` keys; source-guard tests still pin one `https://api.cupidus.app` literal in `lib/` and no runtime channel |

## Requested Deviation Verdict — architecture §4 symmetric check

CLEAN — deviation justified. `solution.md` §4 asks to reject "a `prod` flavor
resolving to a non-production origin (and vice versa)" while the same section
promises REQ-007's define-only production build "keeps its exact prior
behaviour". Once `default-flavor: local` exists (required by AC5), that command
carries `appFlavor == 'local'`, so a literal symmetric rule would build fine and
then `StateError` at launch — shipping a production build that crashes on start.

The implemented asymmetric rule set was checked against every mismatch
combination, not just the documented ones:

| Invocation | Resolved | Implemented rule | Correct? |
|---|---|---|---|
| `--flavor prod`, no define | production / prod origin | none fires | yes |
| `--flavor prod --dart-define=CUPID_ENV=local` | local / localhost | rule 1 (flavor constraint) | yes |
| `--flavor prod --dart-define=CUPID_API_BASE_URL=localhost` | production / localhost | rule 3 (REQ-007, unchanged) | yes |
| `--flavor local --dart-define=CUPID_API_BASE_URL=prod origin` | local / prod origin | rule 2 (flavor-independent) | yes — this is the "vice versa" direction |
| REQ-007 define-only production build (carries `local` flavor) | production / prod origin | none fires | yes — required by AC5/§4 compatibility |

- Does not violate AC4: AC4 is scoped to "without separately passing a CLI
  `--dart-define` flag"; every case that reaches the asymmetry involves an
  explicit define.
- Does not violate AC6: no new key, value, or config channel.
- Does not reintroduce the REQ-007 mismatch risk: rule 3 is preserved verbatim
  and rule 2 is strictly *additional* coverage that REQ-007 did not have.
- Covered by tests: `prod flavor silently resolving to local fails loudly (AC4)`,
  `a local-declared build pointed at production fails loudly` (loops `null` and
  `local`), and `REQ-007's define-only production build still validates`.

## Touched Risk Surfaces And Critical Gates

| Risk Surface | Source Of Truth | Critical Gate | Status |
|---|---|---|---|
| Runtime/configuration — Android build variant registration (AC1) | `mobile/android/app/build.gradle.kts` | Plain-Gradle variant task listing + both flavored assembles | PASS (runs 8, 9, 12, 13) |
| Runtime/configuration — build-time base-URL resolution (AC2-AC4, AC6) | `mobile/lib/core/config/cupid_api_config.dart` | Per-flavor unit tests + static analysis | PASS (runs 1-5, 21/21 × 3 flavor resolutions) |
| Operational command — existing local build path (AC5) | `mobile/pubspec.yaml` | Unmodified registry `mobile-app.buildCommand` still produces an artifact | PASS (run 6) |
| Security/auth — Google Sign-In package match | `mobile/android/app/google-services.json` | `applicationId` identical across variants | PASS (runs 10, 11 — `com.snapsofts.cupid` both) |
| App lifecycle — startup config guard on a flavored binary | `mobile/lib/main.dart:20` | Story runtime startup smoke (app launches, reaches first screen) | PASS (runs 14, 15 — see F-001 resolved) |

- UI/UX gates (12e1 entry point, 12e2/12e3 visual fidelity): NOT REQUIRED.
  `story_master.md` records `UX-Spec: WAIVED`, requirements `## Out of Scope`
  excludes any end-user-facing UI, and the only surface is Android Studio's own
  Build Variants panel.
- Mobile e2e, emulator install/uninstall cycles, signing, store upload: not
  required and not requested.

## OQ Discipline

`requirements.md` `## Open Question Impact` triages the single `req_master.md`
inline OQ (Gradle flavor structure / flavor→dart-define mechanism) as NOT
BLOCKED for all of AC1-6, to be confirmed by Tech Lead. `solution.md` §6 records
that confirmation explicitly: dimension `backend`, flavors `local`/`prod`, no
`applicationIdSuffix`/`versionNameSuffix`. Implementation matches. No scope was
omitted or over-blocked. PASS.

## Configuration Guide

`data/requirements/REQ-008_android_build_variants_local_prod/deployment/configuration-guide.md`
exists and matches the delivered surface: the `backend` dimension and both
flavor→(env, baseUrl) rows are accurate, the precedence contract matches the
implemented `defaultValue` mechanism, the `default-flavor` section states the
correct `pubspec.yaml` placement and why removing it breaks the local path, and
the "Startup Guard Failures" section documents all four `validationError` rules
including the deliberate asymmetry. It also correctly records the
`applicationIdSuffix` limitation. Required per `master-plan.md` §1. PASS.

## Blocking Findings

None. F-001 from pass 1 is resolved; see below.

## Resolved Findings

### F-001 — Missing story runtime startup smoke — RESOLVED (pass 2)

`coding-plan/test-results.md` now carries a `## Story Runtime Startup Smoke`
section satisfying rule 12g. Both flavors were launched on real hardware (Pixel
2, `HT7AH1A02116`, Android 11 / API 30, physical device over USB):

| # | Flavor | Command | Outcome |
|---|--------|---------|---------|
| 14 | `prod` | `flutter run --flavor prod -d HT7AH1A02116` | PASS — `assembleProdDebug`, installed, login screen rendered, no Dart exception, exit 0 |
| 15 | `local` | `flutter run --flavor local -d HT7AH1A02116` | PASS — `assembleLocalDebug`, installed, same login screen, no Dart exception, exit 0 |

This is the evidence F-001 asked for, and it proves the specific thing the build
gates could not: `assertValidConfig()` at `main.dart:20` does not throw on either
flavor's derived defaults, so the AC2/AC3 pairings validate at runtime and not
only as pure-function unit tests. The recorded focused window
(`com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` on both runs) also
re-confirms at runtime what runs 10-11 showed statically: neither flavor suffixes
`applicationId`, so the BUG-20260823-001 Google Sign-In package match survives.

§7 was corrected and no longer self-contradicts: the bullet now reads
"superseded", states that the original `Startup Smoke: NOT_APPLICABLE` call was
wrong because `assertValidConfig()` is flavor-dependent at startup, and points to
the new section. No stale `NOT_APPLICABLE` claim remains in the file.
`story_master.md:12` records the resolution against the `Implementation
(Development)` artifact line. No `Runtime-Smoke: WAIVED` line is needed, since
the gate ran rather than being waived.

### Expired-session snackbar on run 15 — CONFIRMED BENIGN (not a gate failure)

Mobile-dev flagged this for adjudication rather than deciding it silently, which
was the right call. Confirming their judgment, on three independent grounds:

1. It is not an error screen. Rule 12g's mobile bar is "reaches its first screen
   without a crash or an error screen". A snackbar is rendered *by* the login
   screen, which means that screen composed and painted successfully — the
   opposite of the red-screen failure mode the rule exists to catch. No Dart
   exception appeared in the run output and the process exited 0.
2. It is not flavor-derived. The `prod` run reached the identical screen without
   it, so the message tracks stored auth state left on the device, not anything
   REQ-008 changed. `assertValidConfig()` throws a `StateError` that would abort
   `main()` before `runApp`; it cannot surface as a localized snackbar.
3. Even under the most suspicious reading — that a token refresh against
   `http://localhost:3000` failed because a *physical* device resolves that to
   its own loopback rather than the host's — that is REQ-007's frozen local
   default behaving exactly as AC2 requires, identical to pre-REQ-008 behaviour,
   and the documented override path exists (`configuration-guide.md`, "Explicit
   `--dart-define` override"). Nothing was introduced or made worse by this
   story, so it would be out of scope at most, never blocking.

## Deferred Findings

### D-001 — `architecture/solution.md` §4 still specifies the superseded symmetric check

§4 "Contracts And Integrations" still reads "reject a `prod` flavor resolving to
a non-production origin (and vice versa)", and `test-results.md` §8 says the
deviation "is flagged for Tech Lead confirmation" — that confirmation is not
recorded in any artifact. The behaviour is correct and the operator-facing
`configuration-guide.md` documents the asymmetry accurately, so this is
documentation drift only, and this review supplies the independent verification.
Suggest Tech Lead amend §4's one clause to the implemented three-rule set at the
next touch of this requirement. Non-blocking.

### D-002 — Config guide's local-from-device override covers only the emulator (new in pass 2)

`configuration-guide.md` introduces the `--dart-define` escape hatch as "running
against the local backend from a device", but the only command it shows is the
emulator form (`10.0.2.2`, annotated as "the emulator alias for the host
loopback"). Run 15 established that this project also runs on a physical Pixel 2,
where `10.0.2.2` is meaningless and `http://localhost:3000` resolves to the
device's own loopback — so a developer following that section on hardware has no
working form to copy. Suggest adding the host-LAN-IP variant alongside it.
Documentation only; the mechanism itself is correct and in scope for REQ-007's
value contract, not this story. Non-blocking.

## Traceability

- Requirements: `requirements/requirements.md` AC1-6, `## Business Rules / Guardrails`, `## Edge Cases / Failure Modes`, `## Open Question Impact`
- UX: none — `UX-Spec: WAIVED` in `story_master.md`, no user-facing surface
- Architecture: `architecture/solution.md` §1 Key Discovery, §3, §4 (boundaries, contracts, risk table, mobile lane guardrails), §6 option evaluation — all five §4 guardrails verified honoured in the diff (no id/version suffix, no `dart-defines` property read, no `startParameter.taskNames` branch, no `FLUTTER_APP_FLAVOR` dart-define, one prod-origin literal, `const` config preserved)
- Plan: `coding-plan/master-plan.md` §1 (config-guide REQUIRED), §6 (Gradle block + `default-flavor` must land together — both are in the same uncommitted change, satisfied)
- Evidence: `coding-plan/test-results.md` runs 1-13, §6 AC coverage, §7 exclusions (corrected in pass 2), §8 deviation rationale, `## Story Runtime Startup Smoke` runs 14-15
- Configuration: `deployment/configuration-guide.md`

## State Recommendation

- Keep `Implementation (Development)` checked in `story_master.md`
- Check `Review (Reviewer)`
- Story status: `DONE`
- D-001 and D-002 are recorded documentation follow-ups for Tech Lead and do not
  gate closure. No rework is outstanding in any implementation lane.
