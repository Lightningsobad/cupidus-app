# Phase P1 – Camera Dependency And Permission Foundation

## 1. Objective

Give the app a camera it is allowed to open: resolve the scanner and permission
packages, declare camera usage on both platforms, and land the injectable
`CameraPermissionGate` seam every later phase depends on. This app has never
requested a runtime permission before, so this phase establishes the convention.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-camera-permission-foundation.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/pubspec.yaml`
  - `mobile/android/app/src/main/AndroidManifest.xml`
  - `mobile/ios/Runner/Info.plist`
  - `mobile/lib/features/pairing/presentation/camera_permission_gate.dart`
  - `mobile/test/features/pairing/presentation/camera_permission_gate_test.dart`
  - `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/deployment/configuration-guide.md`
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
  - `CameraPermissionGate` — `status()` returning granted / denied /
    permanentlyDenied / unavailable, plus `openSettings()`
  - A test fake of the same interface, importable by P2/P3/P4 tests
- Risk Surfaces:
  - Permission dead-end (AC1/AC3)
  - Platform permission declarations missing
  - `pubspec.yaml` collision with STORY-002
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md`
    sections 3 (assumption A1) and 4 (`Boundaries And Ownership`)
  - consumer contract: `ScanCodeCubit` in P2
- Primary Inputs Summary:
  - requirements: AC1, AC3
  - architecture: `../architecture/solution.md` sections 3, 4
  - OQ constraints: OQ1 — permission is requested at scan tap, never earlier
  - upstream phase outputs: none
  - UX constraints, if truly required: `../ux/ux-spec.md` States 5-7 only, for
    the granted / denied / permanentlyDenied / unavailable distinction
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES (file does not exist yet; create it)
  - Sections To Update: mobile third-party dependencies; Android/iOS camera
    permission declarations and the user-facing purpose string
- Phase Sizing:
  - Behavior Slice: dependency + platform declaration + permission seam
  - Source/Test File Count: 6
  - Split Required: NO
  - Split Rationale: one behavior cluster; the manifest edits are meaningless
    without the package and vice versa

## 2. Required Reads

- `../requirements/` (AC1, AC3 and the `## Open Question Impact` section)
- `../architecture/` sections 3 and 4

## 3. Tasks

- Close assumption A1 FIRST, before writing any other code in this phase: run
  `flutter pub add mobile_scanner permission_handler` in `mobile/`, then
  `flutter pub get` and `flutter analyze`. Record the resolved versions in
  `test-results.md`. If either package fails to resolve, is discontinued, or
  demands an SDK constraint beyond the declared `sdk: ^3.12.1`, STOP and
  escalate — do not substitute another package.
- Append the two dependencies to the existing `dependencies:` block in
  `mobile/pubspec.yaml`. Do not reorder or reformat the block (STORY-002 edits
  the same file on a sibling branch).
- Declare `android.permission.CAMERA` in `AndroidManifest.xml` and
  `NSCameraUsageDescription` in `ios/Runner/Info.plist`, with a purpose string
  that states scanning a partner's pairing QR code.
- If the resolved `mobile_scanner` forces an Android `minSdk` floor above the
  Flutter default, set it explicitly in `android/app/build.gradle.kts` (it
  currently inherits `flutter.minSdkVersion` at line 25) and note it in
  `test-results.md`.
- Implement `CameraPermissionGate` as an interface plus a `permission_handler`
  implementation, and a fake implementation usable by widget tests. Map the
  platform statuses onto exactly the four values named above — do not leak
  `permission_handler` types past this seam.
- Create `../../deployment/configuration-guide.md` with the dependency and
  permission sections listed in `Requirement Configuration Guide` above.

## 4. Acceptance Criteria

- `flutter pub get` and `flutter analyze` are clean with both packages resolved,
  and the resolved versions are recorded.
- Both platform declarations are present and carry a purpose string.
- `CameraPermissionGate` exposes exactly the four statuses plus
  `openSettings()`, with no `permission_handler` type in its public signature.
- The fake gate can drive all four statuses from a test with no platform channel.
- `../../deployment/configuration-guide.md` exists and documents both the
  packages and the permission declarations.

## 5. Planned Outputs

- Code directories or files: the six paths in `Write Scope`
- Contracts or schemas: `CameraPermissionGate` + its test fake
- Requirement configuration guide updates: created, two sections
- Notes or evidence: resolved package versions and any `minSdk` change in
  `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/`
- Required levels:
  - unit: `CameraPermissionGate` status mapping and the fake's four states
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: both platform declaration files contain the camera entry
- Minimum gates by risk surface: Permission dead-end (AC1/AC3) — the fake gate
  returns all four statuses; Platform permission declarations missing — assert
  by reading both files
- Evidence format: command output and resolved versions in
  `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/pairing/presentation/camera_permission_gate_test.dart`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: resolved `mobile_scanner` and
    `permission_handler` versions, quoted from `pubspec.lock`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
