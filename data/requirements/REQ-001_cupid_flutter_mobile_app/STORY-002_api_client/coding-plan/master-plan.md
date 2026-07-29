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
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/openapi/cupid_api/**`, `mobile/pubspec.yaml`, `mobile/.gitignore` | P0 outputs, solution §4 ADR-010b | generated `cupid_api` package committed and wired as a `path` dependency | `flutter pub get`; `flutter test` with one smoke test importing a generated API class + model | NOT_STARTED |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/core/config/cupid_api_config.dart`, `mobile/lib/core/network/cupid_interceptor_slots.dart`, `mobile/lib/core/network/cupid_auth_token_provider.dart`, `mobile/lib/core/network/cupid_api_client.dart`, `mobile/test/core/network/cupid_interceptor_slots_test.dart` | solution §2, §4 Interceptor Pipeline Contract, ADR-010f | Dio composition + four named slots + auth plug point | `flutter analyze`; `flutter test` (slot order + auth-override replacement) | NOT_STARTED |
| P3 | Mobile Developer | Mobile | P2 | NO | `mobile/lib/core/network/cupid_api_failure.dart`, `mobile/lib/core/network/cupid_error_interceptor.dart`, `mobile/lib/core/network/cupid_api.dart`, `mobile/test/core/network/cupid_error_interceptor_test.dart` | solution §2 error contract | sealed failure hierarchy + mapping interceptor + public barrel | `flutter analyze`; `flutter test` (timeout, connection error, 401, 500) | NOT_STARTED |
| P4 | Mobile Developer | Mobile | P3 | NO | `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`, `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-002_api_client/coding-plan/test-results.md`, this file (status column) | all prior phase outputs, `data/devops/system/runtime-command-registry.json` -> `mobile-app` | determinism evidence, AC1-AC4 evidence, configuration guide entry | full gate: regeneration double-run diff, `flutter analyze`, `flutter test`, `flutter build apk --debug`, `git status --porcelain backend/` | NOT_STARTED |

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

1. Run `mobile/tool/generate_api_client.sh`.
2. Commit the full generated tree including `.g.dart` outputs (ADR-010b). Ensure `mobile/.gitignore` does not exclude it.
3. Add to `mobile/pubspec.yaml`: `dio` and `cupid_api: {path: openapi/cupid_api}`.
4. Add one smoke test that imports a generated API class and a generated model and asserts they construct — proof of AC2 without enumerating 59 endpoints.

Done when: `flutter pub get` and `flutter test` pass with the generated package on the dependency graph. No file under `mobile/openapi/cupid_api/` was hand-edited.

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
