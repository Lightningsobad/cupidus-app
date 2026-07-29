# STORY-002 api_client — P4 Verification Results

Full gate per `coding-plan/master-plan.md` §6 `### P4`. Worktree HEAD for this
gate run: `3c27c04b32372c18967dc7c5f9ec139f8c4f33d2` (unchanged since P0-P3).

## Gate 1 — `flutter pub get`

Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter pub get` (run from
`mobile/`). Resolves cleanly, including the `cupid_api` path dependency.

Result: PASS.

## Gate 2 — AC3 determinism (double-run diff)

Command: `bash mobile/tool/generate_api_client.sh` run a second time against
the already-generated tree, then `git status --porcelain mobile/openapi/cupid_api`.

Result: PASS — `git status --porcelain mobile/openapi/cupid_api` output was
empty. Regeneration is idempotent; the SDK-floor normalization step in
`generate_api_client.sh` (§6 P1 step 0) reapplies the same `sdk: ^3.12.1`
value on every run with no drift.

## Gate 3 — AC4 backend untouched

Command: `git status --porcelain backend/`.

Result: PASS — empty output. No file under `backend/` was modified by the
mobile client generation or build steps.

## Gate 4 — `flutter analyze`

Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` (run from
`mobile/`).

Result: PASS (baselined) — clean except 17 pre-existing `unused_import`
warnings in generated `mobile/openapi/cupid_api/**` sources (generator
template artifact, not hand-edited, not introduced by this story's own
`lib/`/`test/` code). No errors, no warnings outside the generated package.

## Gate 5 — `flutter test`

Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test` (run from
`mobile/`).

Result: PASS — 51/51 tests passed, covering: AC2 smoke import
(`test/openapi/cupid_api_smoke_test.dart`), interceptor slot order and
auth-override replacement (`test/core/network/cupid_interceptor_slots_test.dart`),
and error-mapping (`test/core/network/cupid_error_interceptor_test.dart`:
timeout, connection error, 401, 500).

## Gate 6 — `flutter build apk --debug`

Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter build apk --debug`
(run from `mobile/`).

Result: PASS — `✓ Built build/app/outputs/flutter-apk/app-debug.apk`
(148.3M). A prior attempt on 2026-07-29 failed with `No space left on device`
at Gradle's `:app:mergeDebugNativeLibs` task due to host disk exhaustion
(unrelated to source code); after the user freed host disk space
(confirmed `df -h /` before this run: 9.2Gi+ available), the identical build
command completed successfully with no code changes.

## Per-AC Evidence Summary

- AC1 (spec provenance): vendored `mobile/openapi/cupid-api.json` fetched
  from the live backend `/api-docs-json` endpoint (P0); generator-cli pinned
  to exact version `7.24.0` in `mobile/openapitools.json`.
- AC2 (generated client wired and importable): `mobile/test/openapi/cupid_api_smoke_test.dart`
  imports a generated API class and model and asserts construction (Gate 5).
- AC3 (deterministic regeneration): Gate 2 double-run diff, empty.
- AC4 (backend untouched): Gate 3, empty `git status --porcelain backend/`.

## Toolchain Versions Observed

- Flutter 3.44.1 (stable), Dart 3.12.1
- Node v20.20.2
- OpenJDK 17.0.17

All 6 gates: PASS.
