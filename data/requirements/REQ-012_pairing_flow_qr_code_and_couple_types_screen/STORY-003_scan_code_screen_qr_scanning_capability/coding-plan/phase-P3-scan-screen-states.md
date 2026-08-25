# Phase P3 – Scan Screen And Its Seven States

## 1. Objective

Paint the full-screen scan surface: the camera preview, the viewfinder, and the
five non-live states, plus the opaque fade route that presents it. Every state
must be renderable without a camera so P4 can capture it for AC5.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-scan-screen-states.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pairing/presentation/screens/scan_code_screen.dart`
  - `mobile/lib/features/pairing/presentation/scan_code_route.dart`
  - `mobile/test/features/pairing/presentation/screens/scan_code_screen_test.dart`
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
  - `ScanCodeRoute` — opaque `PageRouteBuilder` with a ~150ms fade, consumed by P4
  - an injectable camera-preview builder so the harness can substitute a
    placeholder for the live preview
- Shared Interfaces Consumed:
  - `ScanCodeCubit` and its states (P2)
  - `CameraPermissionGate` (P1)
- Risk Surfaces:
  - Permission dead-end (AC1/AC3)
  - Design fidelity of new pill + states (AC5)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/ux-spec.md` States 1-7,
    `Reused vs. New Visual Tokens`, and `Accessibility`
  - consumer contract: `JoincodeScreen` in P4
- Primary Inputs Summary:
  - requirements: AC1, AC3, AC4, AC5
  - architecture: `../architecture/solution.md` section 4
    (`Boundaries And Ownership`, Mobile lane guardrails)
  - OQ constraints: OQ1 — full-screen mechanism, tap-time permission
  - upstream phase outputs: `ScanCodeCubit` from P2
  - UX constraints, if truly required: yes — `../ux/ux-spec.md` is the
    authoritative input for this phase

## 2. Required Reads

- `../requirements/` (AC1, AC3, AC4, AC5)
- `../architecture/` section 4
- `../ux/ux-spec.md` States 1-7, token list, accessibility
- P2 output: `scan_code_cubit.dart`

## 3. Tasks

- Build `ScanCodeScreen` rendering all seven states from `ScanCodeCubit`:
  opening, live scanning with the pink viewfinder, recognized mint flash,
  invalid/expired card over a running preview with `Thử lại` + manual-entry
  link and its ~3s auto-dismiss, denied, permanently denied with
  `Mở Cài đặt` wired to `CameraPermissionGate.openSettings()`, and unavailable.
- Present the camera preview through an injectable builder that defaults to the
  `mobile_scanner` widget, so tests and the preview harness pass a placeholder.
  Without this seam AC5 is unverifiable on a build machine.
- Implement `ScanCodeRoute` as an opaque `PageRouteBuilder` with a ~150ms fade.
  Do not use `showGeneralDialog` — see `../architecture/solution.md` section 4
  for why a pushed opaque route is the chosen mechanism.
- Dispose the camera controller on every exit path: pop, system back gesture,
  permission failure, and app backgrounding. A retained session is user-visible
  as a stuck camera indicator.
- Use only token accessors (`context.cupidColors` / `cupidType` /
  `cupidPlatform`) and `context.viEn(...)` for copy. A literal color, font size,
  or radius trips the repo's no-fork guard test.
- Give the close control a >=44x44 hit target and an accessible label, per the
  UX accessibility section.

## 4. Acceptance Criteria

- Each of the seven states renders its specified content, and every state except
  live scanning exposes a manual-entry exit; live scanning exposes the close
  control.
- `Mở Cài đặt` calls `openSettings()` exactly once.
- The invalid card auto-returns to live scanning after its timeout, and
  `Thử lại` returns immediately.
- No literal color/size/radius appears in the new files.
- The whole screen renders in a widget test with a fake gate and a placeholder
  preview, with no platform channel.

## 5. Planned Outputs

- Code directories or files: the three paths in `Write Scope`
- Contracts or schemas: `ScanCodeRoute`, the preview-builder seam
- Requirement configuration guide updates: none
- Notes or evidence: widget-test output in `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/`
- Required levels:
  - unit: state-to-widget mapping for all seven states
  - mobile build/type-check/static-analysis: `flutter analyze`
  - visual inspection: deferred to P4, which owns the preview-harness entries
- Required checks: no-fork guard test still passes; controller disposal asserted
  on pop
- Mobile discoverability / navigation integration: not this phase — P4 owns the
  entry point
- Minimum gates by risk surface: Permission dead-end (AC1/AC3) — a widget test
  per denied / permanently denied / unavailable state asserting a reachable
  manual-entry exit; Design fidelity (AC5) — token-only assertion here, pixel
  comparison in P4
- Required regression or contract coverage: existing
  `test/design_system/` guard tests must still pass
- Evidence format: command output in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/pairing/ test/design_system/`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: per-state widget finders and the
    `openSettings()` call count

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
