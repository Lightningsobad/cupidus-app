# Phase P2 – Payload Parser And Scan State Machine

## 1. Objective

Land the headless half of scanning: the pure payload parser and the
`ScanCodeCubit` that owns the seven UX states, the permission read, detection
debounce, and the routing of `JoincodeCubit` outcomes. No widgets, no camera
plugin surface — all of it must be testable without a device.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-scan-decode-logic.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pairing/presentation/pairing_code_parser.dart`
  - `mobile/lib/features/pairing/presentation/scan_code_cubit.dart`
  - `mobile/test/features/pairing/presentation/pairing_code_parser_test.dart`
  - `mobile/test/features/pairing/presentation/scan_code_cubit_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE (story-level smoke runs after P4)
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `devCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `parsePairingCode(String raw) -> String?`
  - `ScanCodeCubit` + its seven states, consumed by P3
- Shared Interfaces Consumed:
  - `CameraPermissionGate` (P1)
  - existing `JoincodeCubit.submit(String)` and the `PairingFailure` subtypes
- Risk Surfaces:
  - Malformed/URL payload sent to backend (AC4)
  - Scanned vs typed outcome divergence (AC2)
  - Permission dead-end (AC1/AC3)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` section
    4 (`Contracts And Integrations`) — parse contract, state routing after
    submit, idempotency
  - consumer contract: `ScanCodeScreen` in P3
- Primary Inputs Summary:
  - requirements: AC2, AC4
  - architecture: `../architecture/solution.md` section 4
  - OQ constraints: none beyond OQ1's tap-time permission timing
  - upstream phase outputs: `CameraPermissionGate` from P1
  - UX constraints, if truly required: `../ux/ux-spec.md` state names only, so
    the cubit's states map 1:1 onto States 1-7

## 2. Required Reads

- `../requirements/` (AC2, AC4)
- `../architecture/` section 4
- P1 output: `camera_permission_gate.dart`

## 3. Tasks

- Implement `parsePairingCode`: trim, take the trailing token after the last
  `/` or `:` when present, strip non-alphanumerics, uppercase, and accept only
  an exactly-6-character alphanumeric result; otherwise return `null`. Keep the
  file free of Flutter imports. Do NOT copy `_pasteCode`'s truncate-to-first-6
  rule (`joincode_screen.dart:145-147`) — on a URL payload it yields `HTTPS:`.
- Implement `ScanCodeCubit` with states matching `../ux/ux-spec.md` States 1-7.
  It reads `CameraPermissionGate` on start (State 1) and resolves to live
  scanning, denied, permanently denied, or unavailable.
- On detection: parse. `null` → invalid state with no network call. Valid →
  recognized flash, then call `submit(code)` on the **injected existing
  `JoincodeCubit` instance**. The cubit must not call `PairingRepository`, build
  its own failure map, or navigate.
- Route `JoincodeCubit` outcomes exactly as `../architecture/solution.md`
  section 4 specifies: `InvalidOrExpiredCodeFailure` → invalid state with camera
  resumed; every other `PairingFailure` → a close-overlay signal; `JoincodeSuccess`
  → a close-overlay signal.
- Debounce: after an accepted detection, ignore every further detection until
  the invalid state re-arms or the user taps `Thử lại`. A double submit returns
  409 `AlreadyPairedFailure` and reads to the user as a broken scan.

## 4. Acceptance Criteria

- Parser accepts a bare code, a URL tail, lowercase, and surrounding whitespace;
  rejects wrong length, empty, and non-alphanumeric-only payloads.
- A malformed payload produces the invalid state with zero calls to the injected
  `acceptInvitation`.
- A valid payload produces exactly one `submit` call with the normalized code.
- Each of the four permission statuses lands on its matching state.
- Repeated detections while a submit is in flight produce exactly one `submit`.

## 5. Planned Outputs

- Code directories or files: the four paths in `Write Scope`
- Contracts or schemas: `parsePairingCode`, `ScanCodeCubit` states
- Requirement configuration guide updates: none
- Notes or evidence: test output in `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/`
- Required levels:
  - unit: parser table cases; cubit state transitions with a fake permission
    gate and a stubbed `acceptInvitation`
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: zero-network assertion on malformed payloads; single-submit
  assertion on repeated detections
- Minimum gates by risk surface: Malformed/URL payload sent to backend (AC4) —
  parser rejection tests; Scanned vs typed outcome divergence (AC2) — the
  stubbed `acceptInvitation` receives the same normalized code the manual path
  would send; Permission dead-end (AC1/AC3) — one test per status
- Required regression or contract coverage: existing
  `test/features/pairing/presentation/joincode_cubit_test.dart` must still pass
  unchanged — this phase must not modify `JoincodeCubit`
- Evidence format: command output in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/pairing/presentation/`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: the submit-call count and the exact code string
    passed to the stub

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
