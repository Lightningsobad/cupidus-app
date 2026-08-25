# Phase P4 – Quét QR Entry Point, Wiring, And Preview Coverage

## 1. Objective

Make the capability reachable and provable: build the `Quét QR` pill that the
design has and the app does not, wire it to `ScanCodeRoute` with the caller's
existing `JoincodeCubit`, and register the preview-harness entries that let AC5
be compared against the design canvas.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-scan-entry-point-and-preview.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`
  - `mobile/lib/main_preview.dart`
  - `mobile/test/features/pairing/presentation/joincode_screen_test.dart`
  - `mobile/test/features/pairing/presentation/screens/joincode_screen_design_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: REQUIRED — story-level gate run by Scrum Master after this
    phase, not inside it
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `devCommand`
  - Readiness Check: launcher activity resumed, per the registry entry
  - Port Contract: N/A
- Shared Interfaces Consumed:
  - `ScanCodeRoute` (P3)
  - existing `JoincodeCubit` instance held by `_JoincodeView`
- Risk Surfaces:
  - Scanned vs typed outcome divergence (AC2)
  - Join-code screen mutated by a dismissed scan
  - Design fidelity of new pill + states (AC5)
- Source Of Truth:
  - authoritative artifact or convention:
    `cupid-app-design-system/Cupid Screens.dc.html` lines 1617-1637 for the
    two-pill row; `../architecture/solution.md` section 4 for the hand-off
  - consumer contract: none downstream
- Primary Inputs Summary:
  - requirements: AC2, AC3, AC5
  - architecture: `../architecture/solution.md` sections 1 (`Key Discovery`)
    and 4 (`Contracts And Integrations`)
  - OQ constraints: OQ1 — permission requested only on this tap
  - upstream phase outputs: `ScanCodeRoute` from P3
  - UX constraints, if truly required: `../ux/ux-spec.md` `Entry Point` and
    `Fallback Guarantee`

## 2. Required Reads

- `../requirements/` (AC2, AC3, AC5)
- `../architecture/` sections 1 and 4
- `../ux/ux-spec.md` `Entry Point`, `Fallback Guarantee`
- P3 output: `scan_code_route.dart`

## 3. Tasks

- Build the `Quét QR` / `Scan QR` pill next to the existing paste pill and split
  the action row between them, matching the design source. The pill does not
  exist today: `joincode_screen.dart:523-526` records that REQ-002/STORY-047
  deferred it and that the paste pill takes the whole row. Remove that stale
  comment as part of this change.
- On tap, push `ScanCodeRoute` wrapped in
  `BlocProvider.value(value: context.read<JoincodeCubit>())` so the overlay
  submits on the same instance. Do not create a second cubit and do not call
  `PairingRepository` from the screen.
- Do not prefill, clear, or otherwise touch `_codeController` or its focus node
  from the scan path — the UX `Fallback Guarantee` requires the screen to come
  back exactly as it was.
- Leave `_codeLength = 6`, the slot row, the paste pill behavior, the pair-up
  CTA, and the `Tôi mới là người tạo mã →` link untouched (AC5's "preserve
  existing manual UI unchanged"). Do not add an 8-character path.
- Register preview entries in `main_preview.dart` following the existing
  `String.fromEnvironment` pattern at lines 1130-1138: extend the registry map
  with a scan entry whose state is selected by an environment variable
  (live / invalid / denied / blocked / unavailable), injecting the fake
  permission gate and the placeholder preview builder from P1/P3. The existing
  `joincode` entry must now render the two-pill row.

## 4. Acceptance Criteria

- The `Quét QR` pill renders beside the paste pill and opens the scan route.
- A widget test proves the scan path and the manual path reach one stubbed
  `acceptInvitation` with the same code (AC2 parity).
- A widget test types three characters, opens the overlay, dismisses it, and
  asserts the three characters and the slot painting survive.
- Every scan state renders headless from the preview harness with no camera.
- The existing join-code tests pass with only the additions this phase makes.

## 5. Planned Outputs

- Code directories or files: the four paths in `Write Scope`
- Contracts or schemas: none
- Requirement configuration guide updates: none (P1 owns it)
- Notes or evidence: test output plus the preview invocations used, in
  `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/`
- Required levels:
  - unit: pill presence, tap-to-route, parity, state preservation
  - mobile build/type-check/static-analysis: `flutter analyze` and
    `flutter build apk --debug`
  - visual inspection: preview-harness render of the two-pill row and each scan
    state
- Required checks: the design test for the join-code row still passes with the
  row now split between two pills
- Mobile discoverability / navigation integration: the `Quét QR` pill is the
  discoverable entry point on an already-reachable screen; assert it is present
  and tappable, not reachable by direct route only
- Minimum gates by risk surface: Scanned vs typed outcome divergence (AC2) —
  the shared-stub parity test; Join-code screen mutated by a dismissed scan —
  the type/open/dismiss test; Design fidelity (AC5) — preview render of the
  two-pill row plus each state
- Required regression or contract coverage: the full existing
  `test/features/pairing/` suite
- Evidence format: command output and the exact preview invocations in
  `coding-plan/test-results.md`
- Requirement mobile visual audit: YES — the two-pill row and the scan states
  are compared against `Cupid Screens.dc.html` lines 1617-1637 and
  `../ux/ux-spec.md`
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/pairing/`
  - Build/type-check/lint command when required: `flutter analyze`,
    `flutter build apk --debug`
  - Required assertion evidence: the single stubbed `acceptInvitation` call from
    both paths, and the preserved controller text after dismiss

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
