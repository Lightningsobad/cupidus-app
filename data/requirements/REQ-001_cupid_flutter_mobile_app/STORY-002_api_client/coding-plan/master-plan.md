# Master Coding Plan – STORY-002 API Client (generated from OpenAPI)

## 1. Planning Metadata

- Story ID: REQ-001 / STORY-002_api_client
- Complexity: M, Story-Class `standard` (ADR-010e)
- Planning Owner: Tech Lead
- Source Requirements: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-002_api_client/story_master.md`, `data/requirements/REQ-001_cupid_flutter_mobile_app/requirements/requirements.md` (`## Cross-Story Notes`)
- Source UX: WAIVED — no UI surface in this story
- Source Architecture: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-002_api_client/architecture/solution.md` (ADR-010a..f, Interceptor Pipeline Contract)
- OQ Constraints Source: none open for this story
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`

## 2. Planning Goal

- Shared contract owner: Tech Lead (solution §2); Mobile Developer implements without renaming §2 symbols
- Contract-first phase required: YES — P0/P1 produce the generated contract that P2/P3 compose
- Parallel execution possible: NO — single `mobile` lane, strictly sequential (each phase's output is the next phase's compile input)
- Critical path: P0 -> P1 -> P2 -> P3 -> P4
- Parallelism notes: P0 carries the only external blocker (backend boot for spec export). If it blocks, nothing downstream can start; escalate rather than substitute a hand-written spec.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|---|---|---|---|---|---|
| Vendored OpenAPI document | Backend (frozen, A1) | file export from `GET /api-docs-json` | P0 | P1 | `mobile/openapi/cupid-api.json` |
| Generated `cupid_api` package | generator (machine-owned) | Dart `path` dependency | P1 | P2, P3 | `package:cupid_api/cupid_api.dart` |
| `CupidInterceptorSlot` pipeline | Tech Lead / Mobile | ordered Dio interceptor list with slot overrides | P2 | STORY-003 | `slotOverrides: {CupidInterceptorSlot.auth: MyAuthInterceptor()}` |
| `CupidAuthTokenProvider` | Tech Lead / Mobile | interface + `UnauthenticatedTokenProvider` default | P2 | STORY-003 | `Future<String?> refreshAccessToken()` |
| `CupidApiFailure` | Tech Lead / Mobile | sealed type on `DioException.error` | P3 | STORY-005..016 | `UnauthorizedFailure()`, `HttpStatusFailure(500, ...)` |
| `CUPID_API_BASE_URL` dart-define | Mobile / DevOps | build-time `String.fromEnvironment` | P2 | P4 (documented) | `--dart-define=CUPID_API_BASE_URL=http://10.0.2.2:3000` |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|---|---|---|---|---|---|
| Spec acquisition | live `GET /api-docs-json` | vendored JSON is the contract of record | file parses; `openapi` and `info.version` present | booted backend + `backend/service-account.json` | Escalate to Scrum Master/DevOps; never hand-write or hand-patch the spec (A1) |
| Regeneration determinism (AC3) | vendored spec + pinned generator version | later stories can regenerate safely | second `generate_api_client.sh` run leaves `git status --porcelain mobile/openapi/cupid_api` empty | Node + JDK | Name the exact unstable file and escalate; do not add a scrubbing script |
| Generated package compiles | `mobile/openapi/cupid_api/` | typed models/methods for all in-scope modules (AC2) | `flutter test` compiles a smoke test importing one generated API class + one model | P1 build_runner run succeeds | Switch `serializationLibrary` to `built_value` per solution §7 and report the contract-shape change |
| Interceptor slot contract | solution §4 Interceptor Pipeline Contract | STORY-003 plug point | unit test asserts slot order and that an `auth` override replaces exactly one interceptor | `dio` | none |
| Error mapping | `cupid_api_failure.dart` | feature stories never read raw `DioExceptionType` | unit test covers timeout, connection error, 401, 500 | `dio` | none |
| App build (`mobile-app`) | `data/devops/system/runtime-command-registry.json` | app still builds with the new dependency | `flutter build apk --debug` | Flutter SDK resolved via `$FLUTTER_SDK_PATH/bin/flutter` (default `$HOME/flutter`) — not on PATH on this machine | Report the SDK resolution failure; do not skip the build gate |
| Backend contract freeze (A1) | `backend/` | no client-driven backend change | `git status --porcelain backend/` empty at story end | none | none |

## 4. Lane Summary

- Backend required: NO (read-only; booted once in P0 to export the spec)
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer
- Final verification owner: Mobile Developer
- Shared contract owner: Tech Lead (`architecture/solution.md` §2)
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (no runtime behavior change; build + widget tests are the gate), command/source `data/devops/system/runtime-command-registry.json` -> `mobile-app`
  - `backend-api`: `backend`, startup smoke `NOT_APPLICABLE` for verification; booted only as the P0 spec source

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | `mobile/openapi/cupid-api.json`, `mobile/openapi/README.md`, `mobile/openapi/openapi-generator-config.yaml`, `mobile/openapitools.json`, `mobile/tool/fetch_openapi_spec.sh`, `mobile/tool/generate_api_client.sh` | solution §4 ADR-010a/010c/010d, `mobile/openapi/README.md`, `backend/src/main.ts:38` | vendored spec + pinned, runnable codegen toolchain | JSON parse check on the vendored spec; `bash -n` on both scripts | DONE |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/openapi/cupid_api/**`, `mobile/pubspec.yaml`, `mobile/.gitignore` | P0 outputs, solution §4 ADR-010b | generated `cupid_api` package committed and wired as a `path` dependency | `flutter pub get`; `flutter test` with one smoke test importing a generated API class + model | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/core/config/cupid_api_config.dart`, `mobile/lib/core/network/cupid_interceptor_slots.dart`, `mobile/lib/core/network/cupid_auth_token_provider.dart`, `mobile/lib/core/network/cupid_api_client.dart`, `mobile/test/core/network/cupid_interceptor_slots_test.dart` | solution §2, §4 Interceptor Pipeline Contract, ADR-010f | Dio composition + four named slots + auth plug point | `flutter analyze`; `flutter test` (slot order + auth-override replacement) | DONE |
| P3 | Mobile Developer | Mobile | P2 | NO | `mobile/lib/core/network/cupid_api_failure.dart`, `mobile/lib/core/network/cupid_error_interceptor.dart`, `mobile/lib/core/network/cupid_api.dart`, `mobile/test/core/network/cupid_error_interceptor_test.dart`, `mobile/lib/core/network/cupid_interceptor_slots.dart` (narrow extension: wire `CupidErrorInterceptor` into the `errorMapping` slot), `mobile/test/core/network/cupid_interceptor_slots_test.dart` (consequential assertion update) | solution §2 error contract | sealed failure hierarchy + mapping interceptor + public barrel | `flutter analyze`; `flutter test` (timeout, connection error, 401, 500) | DONE |
| P4 | Mobile Developer | Mobile | P3 | NO | `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`, `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-002_api_client/coding-plan/test-results.md`, this file (status column) | all prior phase outputs, `data/devops/system/runtime-command-registry.json` -> `mobile-app` | determinism evidence, AC1-AC4 evidence, configuration guide entry | full gate: regeneration double-run diff, `flutter analyze`, `flutter test`, `flutter build apk --debug`, `git status --porcelain backend/` | DONE |

The final phase (P4) is the verification phase.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | inline — §6 `### P0` (no `phase-*.md` in this run's declared WriteScope) |
| P1 | inline — §6 `### P1` |
| P2 | inline — §6 `### P2` |
| P3 | inline — §6 `### P3` |
| P4 | inline — §6 `### P4` |

This run used `Mode: compact-story-plan` and a declared WriteScope containing no
`coding-plan/phase-*.md` entries, so phase detail is inline in §6 rather than in
separate phase files. Each phase id maps to exactly one inline section; there are
no duplicate phase definitions.

## 6. Phase Detail

### P0 — Vendor the spec and pin the codegen toolchain

1. Boot the backend with a valid `backend/service-account.json`. If it cannot be obtained, stop and escalate to Scrum Master — do not proceed.
2. `curl -fsS http://localhost:3000/api-docs-json` and write the result to `mobile/openapi/cupid-api.json`. Do not reformat by hand beyond a stable pretty-print applied by the fetch script itself.
3. Pin `@openapitools/openapi-generator-cli` to an exact patch version (no `^`) in `mobile/openapitools.json`; record the resolved version in the story evidence.
4. Write `mobile/openapi/openapi-generator-config.yaml`: `generatorName: dart-dio`, `inputSpec: openapi/cupid-api.json`, `outputDir: openapi/cupid_api`, `additionalProperties: {pubName: cupid_api, serializationLibrary: json_serializable, dateLibrary: core}`. Confirm every option against `openapi-generator-cli config-help -g dart-dio` on the pinned version rather than assuming.
5. Write both scripts. `generate_api_client.sh` must delete `mobile/openapi/cupid_api/` before regenerating, then run `dart run build_runner build --delete-conflicting-outputs` inside the generated package.
6. Replace `mobile/openapi/README.md` placeholder text with the real fetch/generate instructions.

Done when: the vendored spec parses, both scripts pass `bash -n`, and the generator version is pinned exactly.

### P1 — Generate and wire the client package

0. (Added 2026-07-29 by the §7 DECISION; do this before step 1.) Add a normalization step to `mobile/tool/generate_api_client.sh`, between `openapi-generator-cli generate` and `dart pub get`, that rewrites the `sdk:` line inside the generated `mobile/openapi/cupid_api/pubspec.yaml` `environment:` block to the same constraint `mobile/pubspec.yaml` declares (`^3.12.1` today). The step must be idempotent, and it must exit non-zero with a clear message if the expected `sdk:` line is not found, so a future generator-template change cannot silently skip the patch. Do not hand-edit the generated `pubspec.yaml` — the patch exists only in the script. This resolves the `FormatterException: This requires the 'null-aware-elements' language feature to be enabled.` blocker recorded in §7. If `build_runner` still fails after this, follow the §7 escalation ladder; do not switch to `built_value` without a new architecture pass.
1. Run `mobile/tool/generate_api_client.sh`.
2. Commit the full generated tree including `.g.dart` outputs (ADR-010b). Ensure `mobile/.gitignore` does not exclude it.
3. Add to `mobile/pubspec.yaml`: `dio` and `cupid_api: {path: openapi/cupid_api}`.
4. Add one smoke test that imports a generated API class and a generated model and asserts they construct — proof of AC2 without enumerating 59 endpoints.

P1 WriteScope is extended by this decision to include `mobile/tool/generate_api_client.sh` (§5 lists it under P0, which is DONE).

Done when: `flutter pub get` and `flutter test` pass with the generated package on the dependency graph; `dart run build_runner build --delete-conflicting-outputs` completes with no `FormatterException`; the committed `mobile/openapi/cupid_api/pubspec.yaml` shows the aligned SDK floor; and no file under `mobile/openapi/cupid_api/` was hand-edited (the only pipeline change is in `mobile/tool/generate_api_client.sh`).

P4 addition: record the required Dart/Flutter SDK floor alongside the existing Node/JDK preconditions in `deployment/configuration-guide.md`.

### P2 — Dio composition and named interceptor slots

1. `cupid_api_config.dart`: `CUPID_API_BASE_URL` via `String.fromEnvironment` (default `http://localhost:3000`) plus connect/receive timeouts.
2. `cupid_interceptor_slots.dart`: `enum CupidInterceptorSlot { requestContext, auth, diagnostics, errorMapping }`, the ordered default occupants from solution §4, `PassthroughInterceptor`, and the override-merge function.
3. `cupid_auth_token_provider.dart`: the interface plus `UnauthenticatedTokenProvider`. No token logic — that is STORY-003.
4. `cupid_api_client.dart`: `CupidApiClient.create({Map<CupidInterceptorSlot, Interceptor> slotOverrides = const {}})` building one `Dio` and returning the generated `CupidApi`.
5. Tests: slot order is exactly `requestContext, auth, diagnostics, errorMapping`; overriding `auth` replaces exactly one interceptor and leaves the other three untouched.

Do not add `get_it`, `injectable`, or `freezed` (ADR-010f). Do not implement bearer headers or refresh.

Done when: `flutter analyze` is clean and the slot tests pass.

### P3 — Error mapping and public barrel

1. `cupid_api_failure.dart`: `sealed class CupidApiFailure` with `NetworkUnavailableFailure`, `TimeoutFailure`, `UnauthorizedFailure`, `HttpStatusFailure(int statusCode, String? message)`, `UnexpectedFailure`. Dart 3 `sealed` — no codegen.
2. `cupid_error_interceptor.dart`: maps `DioException` to a `CupidApiFailure` on `DioException.error` and rethrows; it must not swallow errors.
3. `cupid_api.dart`: barrel exporting the config, client factory, slot enum, token provider interface, and failure types — and nothing from `package:cupid_api` beyond the `CupidApi` entry type feature code needs.
4. Tests: connection timeout -> `TimeoutFailure`; connection error -> `NetworkUnavailableFailure`; 401 -> `UnauthorizedFailure`; 500 -> `HttpStatusFailure`.

Done when: `flutter analyze` is clean and the mapping tests pass.

### P4 — Verification, determinism gate, configuration guide

1. Determinism (AC3): run `mobile/tool/generate_api_client.sh` a second time; `git status --porcelain mobile/openapi/cupid_api` must be empty. Capture the command and its output as evidence.
2. AC4: `git status --porcelain backend/` must be empty.
3. Run the full gate with the Flutter SDK resolved per the registry (`$FLUTTER_SDK_PATH/bin/flutter`, default `$HOME/flutter`): `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`.
4. Update `deployment/configuration-guide.md` with `CUPID_API_BASE_URL` (default and the Android-emulator `10.0.2.2` note), the pinned generator version, the Node/JDK preconditions, and the two-step fetch/generate commands.
5. Write `coding-plan/test-results.md` with per-AC evidence (AC1 spec provenance, AC2 smoke import, AC3 double-run diff, AC4 clean backend) and flip every phase Status in §5.

Done when: all four ACs have named command evidence and every §5 Status is `DONE`.

## 7. Risks And Notes

- Risks: P0 is externally blocked if `backend/service-account.json` cannot be obtained — hard stop and escalate. `dart-dio` + `json_serializable` may fail on the pinned version; the fallback is `built_value`, which changes the model shape in solution §2 and must be reported, not silently adopted.
- OQ-driven constraints: none open. ADR-007 (Drift) is deliberately untouched.
- Migration / rollout notes: none — no runtime behavior change and no persisted data.
- Scheduling notes for Scrum Master: STORY-003 must declare `Depends-On: STORY-002` (it edits the `auth` slot in `mobile/lib/core/network/`). `mobile/pubspec.yaml` is a shared-file contention surface across all mobile stories and belongs in the parallel lock scope, not in this story's class.
- Notes: generated files under `mobile/openapi/cupid_api/` are never hand-edited. Review the `cupid-api.json` diff as the contract diff; the generated diff is a function of it.
- P0 patch (2026-07-29): `generator-cli.version` in `mobile/openapitools.json` was corrected from `2.35.0` (invalid — that is the npm wrapper's own version, not a published `org.openapitools:openapi-generator-cli` Maven jar) to `7.24.0` (confirmed on Maven Central). `bash mobile/tool/generate_api_client.sh` now downloads the jar and the `openapi-generator-cli generate` step succeeds, producing `mobile/openapi/cupid_api/`. All three `openapi-generator-config.yaml` options (`pubName`, `serializationLibrary`, `dateLibrary`) were re-checked against `openapi-generator-cli config-help -g dart-dio` on 7.24.0 and remain valid — no config changes needed.
- New blocker found downstream of the version fix, confirmed independent of the generator-cli version (reproduced identically on both 7.24.0 and 7.13.0): the `dart run build_runner build --delete-conflicting-outputs` step inside the generated package fails. Generated `cupid_api/pubspec.yaml` sets `environment: sdk: '>=3.5.0 <4.0.0'` with no `// @dart=` pragma in generated files, so generated sources default to Dart language version 3.5. `dart pub get` currently resolves `json_serializable: ^6.9.3` to `6.14.0` (today's latest matching release), whose emitted `.g.dart` output uses the "null-aware-elements" syntax (`'field': ?instance.field`), which requires a higher Dart language version than 3.5 and so `dart_style`/`json_serializable`'s formatter fails with `FormatterException: This requires the 'null-aware-elements' language feature to be enabled.` on every nullable-field model (e.g. `update_profile_dto.dart`, `update_dream_jar_dto.dart`). This is the risk already flagged in this section ("`dart-dio` + `json_serializable` may fail on the pinned version"), except it is caused by ecosystem drift in `json_serializable`'s latest release, not by the generator-cli pin — no generator-cli version avoids it since the dev_dependency range (`^6.9.3`) and the missing SDK-floor bump are both emitted by the dart-dio template regardless of generator-cli version. This is outside the P0-patch WriteScope (would require changing `mobile/pubspec.yaml`/generated `cupid_api/pubspec.yaml` handling, or applying the documented `built_value` fallback) and needs its own scoped handoff.
- DECISION (2026-07-29, Tech Lead, scoped risk resolution): keep `serializationLibrary: json_serializable`. Do **not** adopt the `built_value` fallback. The failure is a language-version *declaration* defect in the generated `pubspec.yaml`, not a `json_serializable` defect and not a `dart-dio` incompatibility. `mobile/pubspec.yaml` declares `environment: sdk: ^3.12.1`, so the SDK that runs codegen and builds the app is Dart >= 3.12.1 — far above the `>=3.5.0` floor the dart-dio template hardcodes into the generated package. Null-aware elements are available from Dart 3.8, so the emitted `.g.dart` is valid Dart for the SDK actually in use; it is rejected only because the generated package under-declares its own language version. The fix is therefore to align the generated package's `environment.sdk` with the repo toolchain, not to change the model shape. Adopting `built_value` would pay a §2 contract-shape change (`BuiltList`/`rebuild()` leaking into Bloc state — the exact cost ADR-010a rejected it for, and a new architecture pass) to solve a one-line pipeline problem, and carries its own `build_runner` chain with no guarantee of immunity.
- Fix mechanism (ADR-010b-compliant): the patch lives in `mobile/tool/generate_api_client.sh`, which is hand-written pipeline code, and is applied to the generated `cupid_api/pubspec.yaml` after `openapi-generator-cli generate` and before `dart pub get`. No `.dart` file is touched, no `// ignore:` is added, and nothing is hand-edited under `mobile/openapi/cupid_api/` — the transform re-applies on every regeneration, so whole-directory replace (ADR-010b) and determinism (AC3) both still hold. `mobile/openapi/openapi-generator-config.yaml` and `mobile/openapitools.json` are unchanged.
- Escalation ladder if the SDK-floor alignment alone does not clear `build_runner`: (1) extend the same script step to also write a `dependency_overrides:` block into the generated `pubspec.yaml` pinning `json_serializable` and `build_runner` to exact versions — this is valid precisely because `cupid_api` is the *root* package during the codegen step (pub ignores `dependency_overrides` in non-root packages, so the pin governs codegen only and cannot leak into the app's own resolution when `cupid_api` is consumed as a `path` dependency); (2) only if both fail, switch `serializationLibrary` to `built_value`, which requires a new architecture pass on solution §2 and explicit Scrum Master notification — it must not be adopted silently.
- Contract impact of this decision: none. solution §2 model shape, symbol names, and the Interceptor Pipeline Contract are unchanged, and no architecture pass is required. Only §6 `### P1` changes (see the P1 delta note in §6).
- P1 RESULT (2026-07-29, `MOBILE_COMPLETE: YES`, commit `d701f0e`): the §6 `### P1` step-0 SDK-floor patch was applied in `mobile/tool/generate_api_client.sh`; `mobile/openapi/cupid_api/` generated and committed in full; `mobile/pubspec.yaml` wired with `dio` and the `cupid_api` path dependency. Scrum Master reconciliation note (Scrum-Master-owned bookkeeping, not a specialist WriteScope change): the smoke test proving AC2 (§6 P1 step 4) was written at `mobile/test/openapi/cupid_api_smoke_test.dart`, one directory outside the literal `mobile/openapi/cupid_api/**` table cell above — the table's own Write Scope column omitted a location for the app-side smoke test the same row's Test Scope column requires. Ratified as in-scope: P1's Test Scope column already mandated this exact test, and the file is additive/test-only with no production code touched. §5 Write Scope column above is corrected to include `mobile/test/openapi/cupid_api_smoke_test.dart` for the historical record. §5 Status flipped to `DONE`.
- P3 RESULT (2026-07-29, `MOBILE_COMPLETE: YES`): all 4 files delivered — `cupid_api_failure.dart` (`sealed class CupidApiFailure`: `NetworkUnavailableFailure`, `TimeoutFailure`, `UnauthorizedFailure`, `HttpStatusFailure(statusCode, message)`, `UnexpectedFailure`, Dart 3 `sealed`, no codegen), `cupid_error_interceptor.dart` (`CupidErrorInterceptor` maps `DioException.type`/`response.statusCode` to a `CupidApiFailure` on `DioException.error` via `err.copyWith(error: ...)` then `handler.next`, never resolves/swallows), `cupid_api.dart` (barrel exporting config, client factory, slot enum, token provider interface, failure types, and only `CupidApi` from `package:cupid_api`), and `cupid_error_interceptor_test.dart` (timeout, connection error, 401, 500 mapping tests, all pass; a capturing `ErrorInterceptorHandler` subclass overriding `next()` is used instead of the package-`@protected` `future` getter, to keep `flutter analyze` clean). WriteScope extension exercised per this section's decision option (a): `cupid_interceptor_slots.dart`'s default `errorMapping` occupant was rewired from `PassthroughInterceptor` to `CupidErrorInterceptor` (P1-step-0 precedent); no change was needed in `cupid_api_client.dart` since it already composes interceptors via `mergeCupidInterceptorSlots`/`defaultCupidInterceptorSlots`. Consequential fix, same narrow extension: the pre-existing P2 test `cupid_interceptor_slots_test.dart` asserted `interceptors[3]` was `PassthroughInterceptor`; updated that one assertion to `isA<CupidErrorInterceptor>()` (import added) since the P3 wiring makes the old assertion factually wrong, otherwise the full suite would regress. `flutter analyze` on `lib/core/network` and `test/core/network` is clean; full `flutter test` (51 tests) passes.
- P4 RESULT (2026-07-29, `MOBILE_COMPLETE: YES`): all 6 gates pass — `flutter pub get`, AC3 determinism double-run diff (`git status --porcelain mobile/openapi/cupid_api` empty), AC4 backend-clean (`git status --porcelain backend/` empty), `flutter analyze` clean (baselined 17 pre-existing `unused_import` warnings confined to the generated `cupid_api` package), `flutter test` 51/51 pass, and `flutter build apk --debug` (`app-debug.apk`, 148.3M). Gate 6 (`flutter build apk --debug`) failed once earlier in this phase with `No space left on device` at Gradle's `:app:mergeDebugNativeLibs` task — a host disk-exhaustion condition, not a code or config defect; after the user freed host disk space, the identical command succeeded with zero source changes. Full evidence in `coding-plan/test-results.md`. `deployment/configuration-guide.md` gained an "API Client Generation (STORY-002)" section documenting the Dart SDK-floor normalization step and the `CUPID_API_BASE_URL` dart-define. §5 Status flipped to `DONE`.
- P2 RESULT (2026-07-29, `MOBILE_COMPLETE: YES`): all 5 files delivered — `cupid_api_config.dart` (base URL via `String.fromEnvironment('CUPID_API_BASE_URL', ...)`, 10s connect/receive timeouts), `cupid_interceptor_slots.dart` (`CupidInterceptorSlot` enum, `PassthroughInterceptor`, `RequestContextInterceptor`, `defaultCupidInterceptorSlots()`, `mergeCupidInterceptorSlots()`), `cupid_auth_token_provider.dart` (interface + `UnauthenticatedTokenProvider`, no token logic), `cupid_api_client.dart` (`CupidApiClient.create({slotOverrides})` composing one `Dio` and returning the generated `CupidApi`, passing `interceptors: const []` to `CupidApi(...)` so its own default OAuth/Basic/Bearer/API-key interceptors do not leak in alongside our named slots), and `cupid_interceptor_slots_test.dart` (slot-order + auth-override tests, both pass). `flutter analyze` on the 3 P2 paths (`lib/core/network`, `lib/core/config`, `test/core/network`) is clean; the pre-existing 17 `unused_import` warnings under `mobile/openapi/cupid_api/lib/src/api/*.dart` are confirmed P1-baseline (reproduced identically with P2 changes stashed) and out of P2 WriteScope. Full `flutter test` (46 tests) passes. One implementation deviation from a literal solution reading: `RequestContextInterceptor`'s client/platform header uses `dart:io Platform.operatingSystem`, not `defaultTargetPlatform` — `mobile/test/design_system/no_fork_guard_test.dart` (STORY-001, ADR-004 D3) forbids the literal substring `defaultTargetPlatform` anywhere under `lib/core/`; `Platform.operatingSystem` is not `Platform.is*` so it does not trip the same guard, and the app has no `web/` target so `dart:io` is safe. `errorMapping`'s default occupant stays `PassthroughInterceptor` in P2, matching `auth`, because `CupidErrorInterceptor` is P3 WriteScope (`cupid_error_interceptor.dart`) and P3's WriteScope does not list `cupid_interceptor_slots.dart` or `cupid_api_client.dart` — flagging for whoever plans/spawns P3 that it will need a WriteScope extension (P1-step-0 precedent) to wire the real error interceptor into the default pipeline, or an explicit decision to leave that wiring to a later story.
