# 002_api_client-solution.md

## 0. Metadata

- User Story ID: REQ-001 / STORY-002_api_client
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-002_api_client/story_master.md`
- Complexity: M (Story-Class `standard` — confirmed in ADR-010e)
- Referenced Inputs: `story_master.md`; `story_brief.md`; `req_master.md` (D5 row, foundation order, A1); `requirements/requirements.md` (`## Cross-Story Notes`); `system_architecture_memory.md` (ADR-005, ADR-006, ADR-009, §4 contract versioning note, §8 risk rows); `STORY-001/architecture/solution.md` §2 Downstream Contract Summary + §4 Boundaries; `backend/src/main.ts` (Swagger bootstrap only); `mobile/pubspec.yaml`; `mobile/analysis_options.yaml`; `mobile/openapi/README.md`; `data/devops/system/runtime-command-registry.json` (`mobile-app` entry)
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md`
- Solution Number: 002
- Version: v1.0
- Date: 2026-07-29
- Status: Final

## 1. Decision Summary

- Mode: Greenfield (no network layer exists in `mobile/`; `mobile/openapi/` holds only a placeholder README)
- Branch Action: Research Architecture (the generator tool was left open by D5/ADR-006)
- Architecture Drivers: D5/ADR-006 (REST client is generated, never hand-written), A1 (backend contract frozen), system memory §4 (spec must be vendored; codegen must not need a live backend, which requires `backend/service-account.json` to boot), AC3 (deterministic regeneration), STORY-003 needs a plug point for a refresh-token interceptor.
- Invariants: (a) every file under `mobile/openapi/cupid_api/` is machine output and is never hand-edited; (b) feature code reaches REST only through `package:cupid_mobile/core/network/cupid_api.dart`; (c) codegen input is the vendored spec file, never a live URL; (d) STORY-002 contains no auth logic — it only reserves the slot.
- Non-goals: token acquisition/refresh/storage (STORY-003), sockets and FCM (ADR-006 scopes generation to REST only; STORY-004), Drift caching (ADR-007), `get_it`/`injectable` registration, repository classes, any feature UI.
- Technical direction: pinned `openapi-generator-cli` (`dart-dio` generator, `json_serializable` serialization) run offline against `mobile/openapi/cupid-api.json`, emitting a committed local package `cupid_api` consumed by the app via a `path` dependency, plus a small hand-written Dio composition layer with four named interceptor slots.
- Fit: honors ADR-006 (REST only), ADR-009 (spec path), and adds one runtime dependency (`dio`) to the app package.

## 2. Downstream Contract Summary

- Backend contract: consumed as-is, frozen (A1). Spec source is `GET /api-docs-json` (NestJS serves the JSON document at `<swagger-path>-json`; `SwaggerModule.setup('api-docs', ...)` at `backend/src/main.ts:38`). No endpoint may be added, changed, or removed for this story; a generation failure caused by the spec is a Scrum Master escalation, not a backend edit.
- Mobile contract (authoritative for STORY-003 and every later REQ-001 feature story):
  - Single import surface: `package:cupid_mobile/core/network/cupid_api.dart`. Feature code must not import `package:cupid_api/...` directly and must not construct `Dio` itself.
  - `CupidApiClient.create({Map<CupidInterceptorSlot, Interceptor> slotOverrides = const {}})` returns the configured `CupidApi` (generated entry point) backed by one shared `Dio`.
  - `enum CupidInterceptorSlot { requestContext, auth, diagnostics, errorMapping }` — the ordered, stable interceptor pipeline. Slot occupants are replaced by override, never appended ad hoc.
  - `CupidInterceptorSlot.auth` is occupied by `PassthroughInterceptor` in this story. STORY-003 replaces exactly that slot and adds no other.
  - `abstract interface class CupidAuthTokenProvider { Future<String?> readAccessToken(); Future<String?> refreshAccessToken(); }` with `UnauthenticatedTokenProvider` as the STORY-002 default. STORY-003 supplies the real implementation.
  - Errors reach callers as `sealed class CupidApiFailure` (`NetworkUnavailableFailure`, `TimeoutFailure`, `UnauthorizedFailure`, `HttpStatusFailure`, `UnexpectedFailure`) carried on `DioException.error`. Feature code must not switch on raw `DioExceptionType`.
- DevOps / environment contract: one new `--dart-define` key `CUPID_API_BASE_URL` (default `http://localhost:3000`; Android emulator uses `http://10.0.2.2:3000`). No new secret. Codegen toolchain preconditions: Node (already required by `backend/`) and a JDK (already required by `flutter build apk`).
- Requirement configuration guide impact: REQUIRED — `CUPID_API_BASE_URL`, the pinned generator version, and the two-step fetch/generate commands must land in `deployment/configuration-guide.md` (owned by phase P4).
- Data model / migration contract: none.
- Test and verification expectations: `flutter analyze` clean; `flutter test` green; regeneration produces an empty `git status --porcelain mobile/openapi/cupid_api`; `flutter build apk --debug` succeeds.
- OQ constraints downstream must preserve: none open for this story. ADR-007 (Drift) is deliberately untouched — the generated client is stateless and cache-unaware.

## 3. Scope And Assumptions

- In Scope: spec vendoring pipeline, pinned generator toolchain, generated `cupid_api` package, path-dependency wiring, hand-written Dio composition with named slots, error mapping, determinism gate.
- Out Of Scope: auth (STORY-003), realtime (STORY-004), repositories/Blocs, DI container, retries/backoff policy, offline cache.
- Assumptions: (a) a `backend/service-account.json` can be obtained once to boot the backend and export the spec — if not, this is a blocker to escalate, not a reason to hand-write the spec; (b) Node and a JDK are available on the build machine; (c) the pinned `dart-dio` generator supports `serializationLibrary: json_serializable` — if generation is broken on the pinned version, fall back to `built_value` and record the change (see §7).

## 4. Architecture Delta

### Boundaries And Ownership

- Generated boundary: `mobile/openapi/cupid_api/` is a *build artifact package*, owned by the generator. Whole-directory replace on every regeneration. No hand edits, no `// ignore:` patches, no local fixes.
- Composition boundary: `mobile/lib/core/network/` is hand-written and is the only place allowed to import `package:cupid_api/...` or construct `Dio`.
- Config boundary: `mobile/lib/core/config/cupid_api_config.dart` sits beside STORY-001's `core/config/cupid_feature_flags.dart` and follows the same const `String.fromEnvironment` pattern.
- Leaf rule preserved: `design_system/` must not import `core/network/` (STORY-001 §4 already forbids the reverse direction too).
- Contract owner: Tech Lead for §2 names. Mobile Developer implements and may not rename §2 symbols without a new architecture pass.

### Affected Components And Layers

- `mobile/openapi/cupid-api.json` — vendored OpenAPI document (ADR-009 path). Committed. Replaces the placeholder README's promise.
- `mobile/openapi/openapi-generator-config.yaml` — generator config (`generatorName: dart-dio`, `pubName: cupid_api`, `serializationLibrary: json_serializable`, `dateLibrary: core`, `outputDir: mobile/openapi/cupid_api`).
- `mobile/openapitools.json` — pins `generator-cli.version` to an exact patch version (no `^`).
- `mobile/tool/fetch_openapi_spec.sh` — run deliberately, requires a booted backend, writes `mobile/openapi/cupid-api.json`.
- `mobile/tool/generate_api_client.sh` — offline, deterministic: deletes `mobile/openapi/cupid_api/`, regenerates, then runs `dart run build_runner build --delete-conflicting-outputs` inside the generated package.
- `mobile/openapi/cupid_api/**` — generated package (its own `pubspec.yaml`, `lib/src/api/*.dart`, `lib/src/model/*.dart`, `.g.dart` outputs). Committed.
- `mobile/pubspec.yaml` — adds `dio` and `cupid_api: {path: openapi/cupid_api}`.
- `mobile/lib/core/config/cupid_api_config.dart` — base URL + timeouts.
- `mobile/lib/core/network/cupid_interceptor_slots.dart` — slot enum, ordered assembly, `PassthroughInterceptor`.
- `mobile/lib/core/network/cupid_auth_token_provider.dart` — provider interface + `UnauthenticatedTokenProvider`.
- `mobile/lib/core/network/cupid_api_failure.dart` — sealed failure hierarchy.
- `mobile/lib/core/network/cupid_error_interceptor.dart` — `DioException` -> `CupidApiFailure`.
- `mobile/lib/core/network/cupid_api_client.dart` — the `Dio` + `CupidApi` factory.
- `mobile/lib/core/network/cupid_api.dart` — barrel; the only public surface.

### ADR-010 — Generated REST client toolchain (implements D5 / ADR-006)

#### ADR-010a — Generator: `openapi-generator-cli`, `dart-dio`, `json_serializable`

Chosen over `swagger_dart_code_generator` and over any hand-written `retrofit`/`dio` layer. `dart-dio` emits Dio-based API classes, which is what the refresh-token interceptor in STORY-003 needs; `swagger_dart_code_generator` emits Chopper services, whose interceptor model is a worse fit and whose OAS3 coverage is weaker. `json_serializable` output is plain Dart classes; the `built_value` default would leak `BuiltList`/`rebuild()` into Bloc state and fight `freezed` (D2). Cost accepted: the JAR needs a JDK, which the Android build already requires.

#### ADR-010b — Generated code is a committed local package, not app-tree source

Output goes to `mobile/openapi/cupid_api/` and is consumed via a `path` dependency. This keeps generated code out of `flutter analyze`'s scope for the app package (no lint noise, no per-file ignores) while `flutter test`/`flutter build` still compile it, and it makes "regenerate" a safe whole-directory replace. This does **not** reopen ADR-005: ADR-005 forbids splitting hand-written app code into multiple packages/melos; a machine-generated artifact package is not hand-written app code. Melos and Pigeon stay deferred. Generated output is committed so that CI, other developers, and story worktrees never need Java or a live backend to build.

#### ADR-010c — Two-step pipeline: fetch is deliberate, generate is offline

`fetch_openapi_spec.sh` (needs a booted backend + `service-account.json`) is run only when the backend contract changes. `generate_api_client.sh` reads only the vendored file. This satisfies AC1 (the spec originates from the live `/api-docs` document) while honoring system memory §4 (codegen must never depend on a live server). Determinism (AC3) comes from three pins: exact generator version, vendored spec, whole-directory regeneration — verified by an empty `git status --porcelain mobile/openapi/cupid_api` after a second run.

#### ADR-010d — Generate the whole spec; do not filter by tag

No `globalProperty: apis=...` filtering to exclude `admin`/`data-export`. Tag filtering risks dropping transitively referenced models and makes output sensitive to spec ordering, which threatens AC3. The mobile scope exclusion for `admin`/`data-export` is enforced at feature-story level (no screens, no repositories), not at codegen level. Unused generated classes are tree-shaken by the release build. This also satisfies AC2 as a superset.

#### ADR-010e — Story-Class stays `standard`

STORY-005..STORY-016 depend on this story's *merged output* (a normal DONE-dependency), not on concurrently editing its files. They import `core/network/cupid_api.dart` and the generated package read-only; nothing schedules them to write `mobile/openapi/**` or `mobile/lib/core/network/**`. `shared-foundation` is therefore not warranted. Two scheduling notes for Scrum Master: (1) STORY-003 must declare `Depends-On: STORY-002` because it edits the `auth` slot in `core/network/`; (2) `mobile/pubspec.yaml` is a shared file every mobile story may touch — that is a merge-contention surface for the parallel lock scope, not a Story-Class signal.

#### ADR-010f — No DI container in this story

`get_it`/`injectable` (D2) are not yet in `pubspec.yaml`. Introducing them here would widen a narrow story. `CupidApiClient.create()` is a plain factory; the story that introduces the DI container registers it then. Mobile Developer must not add `get_it`, `injectable`, or `freezed` in this story — `CupidApiFailure` uses a Dart 3 `sealed class`, which needs no codegen.

### Interceptor Pipeline Contract

Fixed order, applied in this sequence on request and unwound in reverse on response:

| # | Slot | STORY-002 occupant | Owner after this story |
|---|------|--------------------|------------------------|
| 0 | `requestContext` | `RequestContextInterceptor` (Accept, Content-Type, client/platform header) | STORY-002 |
| 1 | `auth` | `PassthroughInterceptor` | STORY-003 (bearer + 401 refresh-and-retry) |
| 2 | `diagnostics` | `LogInterceptor` in debug builds only, no-op in release | STORY-002 |
| 3 | `errorMapping` | `CupidErrorInterceptor` | STORY-002 |

`auth` sits before `diagnostics`/`errorMapping` so that STORY-003's refresh-and-retry can resolve a 401 before it is logged or mapped to `UnauthorizedFailure`. Slot order is part of the contract; STORY-003 may replace the occupant but must not reorder slots.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Minimum Gate | Blocker If Gate Cannot Run |
|---|---|---|---|
| Spec acquisition | live `GET /api-docs-json` | vendored JSON parses and reports the expected `openapi`/`info.version` fields | Backend cannot boot without `service-account.json` -> escalate to Scrum Master/DevOps; never hand-write the spec |
| Regeneration determinism (AC3) | `mobile/openapi/cupid-api.json` + pinned generator version | second `generate_api_client.sh` run leaves `git status --porcelain mobile/openapi/cupid_api` empty | Generator emits a timestamp/ordering diff -> pin `hideGenerationTimestamp` if supported, else record the exact unstable file and escalate |
| Generated package compiles | generated `cupid_api` package | `flutter test` compiles a smoke test that imports one generated API class and one model | build_runner failure inside the generated package -> see §7 fallback |
| Interceptor slot contract | §2 + Interceptor Pipeline Contract | unit test asserting slot order and that overriding `auth` replaces exactly one interceptor | none |
| Error mapping | `cupid_api_failure.dart` | unit test mapping each `DioExceptionType` and a 401/500 response to the expected failure | none |
| App build | `mobile-app` runtime registry id | `flutter build apk --debug` | Flutter is not on PATH on this machine — resolve via `$FLUTTER_SDK_PATH/bin/flutter` (default `$HOME/flutter`) per the registry `sdk.resolutionOrder` |

### Mobile Lane Handoff

- Owns every item in Affected Components, the two tool scripts, and the tests above.
- Must not: hand-edit generated files, add an endpoint request to backend, add DI/freezed deps, implement any token logic.

### DevOps Lane Handoff

- None required. `mobile-app` already exists in `data/devops/system/runtime-command-registry.json` with `installCommand`, `buildCommand`, and `testCommand` that cover this story unchanged. Codegen is a developer tool, not a runtime service, so no registry entry is added.

### Backend Lane Handoff

- None. `backend/` is read-only for this story (A1). The only backend interaction is booting it once to export `/api-docs-json`.

## 5. Non-Functional Impact

- Build time: one extra JVM invocation on regeneration only; normal `flutter build` is unaffected because output is committed.
- Binary size: unused generated APIs (`admin`, `data-export`) are tree-shaken in release builds.
- Security: no credential handling in this story; `LogInterceptor` is debug-only so tokens added by STORY-003 never reach release logs.
- Reviewability: generated diffs are large but machine-produced; reviewers check the spec diff and the hand-written composition layer, not generated bodies.

## 6. Option Evaluation

| Option | Verdict | Reason |
|---|---|---|
| `openapi-generator-cli` `dart-dio` + `json_serializable` | CHOSEN | Dio-native (fits STORY-003), plain-Dart models, mature OAS3 support |
| `openapi-generator-cli` `dart-dio` + `built_value` | FALLBACK | Better-trodden generator path, but `BuiltList`/`rebuild()` leaks into Bloc state |
| `swagger_dart_code_generator` (pure Dart, no JDK) | REJECTED | Emits Chopper; interceptor model fits STORY-003 poorly; weaker OAS3 coverage |
| `openapi_generator` Dart annotation package | REJECTED | Wraps the same JAR but hides version pinning behind build_runner, weakening AC3 |
| Hand-written `dio`/`retrofit` data layer | REJECTED | Violates D5/ADR-006 and AC1 |
| Generate into `mobile/lib/api/generated/` | REJECTED | Generated code enters `flutter analyze`; needs blanket analyzer excludes and per-file ignores |

## 7. Risks And Mitigations

| Risk | Mitigation |
|---|---|
| `service-account.json` unavailable, backend will not boot, spec cannot be exported | Hard blocker. Escalate to Scrum Master/DevOps. Do not hand-write or hand-patch the spec (A1) |
| `dart-dio` + `json_serializable` generation broken on the pinned version | Switch `serializationLibrary` to `built_value`, record the change and the resulting model ergonomics in the story evidence, and notify Scrum Master — it changes the §2 mobile contract shape |
| Non-deterministic generator output (timestamps, map ordering) | Verify with a double-run diff gate before the story is considered done; if unstable, name the exact file and escalate rather than adding a scrub script that hides drift |
| Spec exposes an endpoint gap a later story needs | A1 escalation to Scrum Master, per `requirements.md` cross-story note |
| Large generated diff hides a real contract change | Review the `cupid-api.json` diff as the contract diff; generated output is a function of it |

## 8. Handoff Notes

- Coding plan: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-002_api_client/coding-plan/master-plan.md`
- Single lane: `mobile`. No backend, frontend, or DevOps lane work.
- STORY-003 reads §2 and the Interceptor Pipeline Contract only; it does not need the rest of this file.
