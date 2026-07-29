# Review Report: STORY-002 api_client

Reviewer: Iris-QC
Story-Class: standard (ADR-010e)
Diff base: `1ffb33bfb051f404e33d99eed763252d1140dba3` -> worktree HEAD
`3bd7dd3e011af88fc56e62ab627d2d7ac839094f`
Worktree: `story-REQ-001_cupid_flutter_mobile_app-STORY-002`

## Verdict: CLEAN

## Scope Reviewed

21 non-generated files changed (hand-written `lib/`, `test/`, tool scripts,
config, docs) plus the machine-generated `mobile/openapi/cupid_api/**`
package (120 generated files). The one commit after the recorded P4
verification commit (`3c27c04` -> `3bd7dd3`) only added `test-results.md`,
`configuration-guide.md` content, and a `master-plan.md` status-column edit —
no source change.

## AC-by-AC

- **AC1 (spec generated, not hand-written)** — PASS. `mobile/openapi/cupid-api.json`
  is a vendored export (`openapi: 3.0.0`, `info.version: 1.0`, 46 paths). The
  two-step pipeline (`fetch_openapi_spec.sh` deliberate/live,
  `generate_api_client.sh` offline/deterministic) matches ADR-010c. No hand
  edits found in the generated tree.
- **AC2 (typed models/methods for in-scope modules)** — PASS. Generated
  `cupid_api/lib/src/api/` contains one API class per epic (`epic1_auth_api`,
  `epic1_users_api`, `epic2_communication_messages_api`,
  `epic3_daily_vibe_check_api`, `epic3_synced_alarms_api`,
  `epic4_love_pet_api`, `epic4_love_timeline_api`,
  `epic4_private_gallery_api`, `epic5_dream_jar_api`, `epic5_expenses_api`,
  `epic23_ghost_config_anti_ghosting_api`, `uploads_api`, `app_api`), plus
  `admin`/`data-export` per ADR-010d's deliberate no-tag-filtering decision
  (exclusion enforced at feature-story level, not codegen level, as
  documented). Smoke test
  (`mobile/test/openapi/cupid_api_smoke_test.dart`) imports and constructs a
  generated API class and model. Confirmed passing directly (see Independent
  Verification).
- **AC3 (deterministic regeneration)** — PASS, independently re-verified.
  I re-ran `bash mobile/tool/generate_api_client.sh` myself in the worktree;
  `git status --porcelain mobile/openapi/cupid_api` was empty afterward, and
  full `git status --short` for the worktree was empty — genuinely
  idempotent, not just self-reported.
- **AC4 (backend untouched)** — PASS, independently re-verified.
  `git status --porcelain backend/` was empty both before and after my
  regeneration run.

## Independent Verification (not just re-reading test-results.md)

Ran directly in the story worktree with the registry-resolved Flutter SDK
(`$HOME/flutter/bin/flutter`):

- `flutter analyze`: 17 issues, all `unused_import` warnings confined to
  generated `mobile/openapi/cupid_api/lib/src/api/*.dart` (generator template
  artifact) — matches `test-results.md` Gate 4 exactly, no errors and no
  warnings in hand-written code.
- `flutter test`: `All tests passed!`, 51 tests — matches `test-results.md`
  Gate 5 exactly.
- `bash mobile/tool/generate_api_client.sh` (second run): idempotent, empty
  diff — matches Gate 2/AC3.
- `git status --porcelain backend/`: empty — matches Gate 3/AC4.

Did not re-run `flutter build apk --debug` (long-running, already evidenced
in `test-results.md` with a plausible, code-unrelated failure/retry
narrative: host disk exhaustion, resolved by freeing disk, not a source
change).

## Code Quality

- Contract boundaries from `architecture/solution.md` §2/§4 are honored:
  single public import surface `core/network/cupid_api.dart`; `Dio` is
  constructed only in `cupid_api_client.dart`; `CupidApi(..., interceptors:
  const [])` correctly suppresses the generated client's own default
  OAuth/Basic/Bearer/API-key interceptors so the four named slots are the
  sole auth plug point — a subtle, easy-to-miss double-interceptor bug that
  was avoided.
- Interceptor slot order (`requestContext, auth, diagnostics, errorMapping`)
  matches the Interceptor Pipeline Contract and is asserted by
  `cupid_interceptor_slots_test.dart`, including that an `auth` override
  replaces exactly one slot and leaves the others untouched.
- `CupidErrorInterceptor.onError` calls `handler.next(...)`, never
  `handler.resolve(...)` — errors are rethrown, not swallowed, and mapped to
  `CupidApiFailure` on `DioException.error`, matching §2's contract that
  feature code never switches on raw `DioExceptionType`. Test coverage hits
  timeout, connection error, 401, and 500 (message + statusCode asserted).
  A `_CapturingErrorHandler extends ErrorInterceptorHandler` overriding
  `next()` is used instead of the package's `@protected` `future` getter — a
  reasonable way to keep `flutter analyze` clean while still asserting the
  mapped error.
- `RequestContextInterceptor` uses `dart:io Platform.operatingSystem` rather
  than `defaultTargetPlatform`, correctly avoiding the STORY-001
  `no_fork_guard_test.dart` literal-substring guard under `lib/core/` — a
  deliberate, documented deviation, not an oversight.
- No `get_it`, `injectable`, or `freezed` introduced (ADR-010f respected).
  `CupidApiFailure` is a plain Dart 3 `sealed class`, no codegen needed.
- `mobile/tool/generate_api_client.sh`'s SDK-floor normalization step is
  idempotent, fails loudly (non-zero exit with a clear message) if the
  expected `sdk:` line is missing from either `pubspec.yaml`, and patches
  only the generated `pubspec.yaml` (never a `.dart` file) — consistent with
  ADR-010b's whole-directory-replace/no-hand-edit invariant. This was the
  right fix for the documented `FormatterException` blocker: the generated
  package's SDK floor was genuinely under-declared relative to the
  `json_serializable` output it was resolving, not a `json_serializable` or
  `dart-dio` incompatibility, so patching the declaration rather than
  swapping `serializationLibrary` avoided an unnecessary §2 contract-shape
  change.
- `mobile/pubspec.yaml` only added `dio` and the `cupid_api` path dependency
  — minimal, in-scope diff.
- Test coverage is scoped and non-redundant: slot-order/override behavior,
  error-mapping per exception type, and one AC2 smoke import — no
  over-testing of generated code bodies, consistent with solution §5
  ("reviewers check the spec diff and the hand-written composition layer,
  not generated bodies").

## Residual Risks / Notes (non-blocking)

- `deployment/configuration-guide.md` correctly documents the SDK-floor
  normalization rationale, preconditions (Node/JDK), pinned generator
  version, and `CUPID_API_BASE_URL` including the Android-emulator
  `10.0.2.2` case — matches the P4 "Done when" checklist in
  `coding-plan/master-plan.md` §6.
- The generated-package `flutter analyze` warnings (17 `unused_import`) are
  cosmetic generator-template noise inside a machine-owned directory per
  ADR-010b; not a code-quality concern for hand-written code and out of this
  story's control (regenerating does not remove them, confirmed by my own
  re-run).
- Gate 6 (`flutter build apk --debug`) evidence rests on the story's own
  `test-results.md` narrative (disk-exhaustion retry); I did not re-run it
  given its cost, but nothing in the diff suggests a build-breaking change,
  and the AC1-AC4 evidence together with independently-reproduced
  analyze/test gates gives high confidence.

## Outcome

Outcome: CLEAN

REVIEW_COMPLETE: YES
