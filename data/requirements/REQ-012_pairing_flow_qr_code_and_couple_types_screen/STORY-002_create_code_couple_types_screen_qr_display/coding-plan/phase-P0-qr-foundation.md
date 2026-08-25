# Phase P0 – QR Foundation: Dependency, Palette, `InviteQrFrame`

## 1. Objective

Land a self-contained, token-driven `InviteQrFrame` widget that renders a
scannable QR for an arbitrary code string at error-correction level H, with the
center heart badge and the animated scan-line, plus the dependency and palette
it needs. The widget is not mounted anywhere in this phase.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-qr-foundation.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/pubspec.yaml`
  - `mobile/pubspec.lock`
  - `mobile/lib/design_system/tokens/qr_palette.dart`
  - `mobile/lib/design_system/design_system.dart`
  - `mobile/lib/features/pairing/presentation/widgets/invite_qr_frame.dart`
  - `mobile/test/features/pairing/presentation/widgets/invite_qr_frame_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `InviteQrFrame({required String code, ...})` — payload contract per
    `../architecture/contract-summary.md` sections 1 and 3
- Risk Surfaces:
  - QR library availability/API
  - Payload identity (AC2)
  - Badge occlusion vs scannability
  - No-fork color guard (INV-3)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` sections 1, 4, 6
  - consumer contract: `../architecture/contract-summary.md`
- Primary Inputs Summary:
  - requirements: `../requirements/` AC1, AC2, AC5
  - architecture: `../architecture/solution.md` sections 1, 4, 6;
    `../architecture/contract-summary.md`
  - UX constraints (required — this phase reproduces exact metrics):
    `../ux/ux-spec.md` §1 "QR frame" and the ambient-glow paragraph above it
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: dependency + palette + one presentation widget + its test
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/`
- `../architecture/solution.md`
- `../architecture/contract-summary.md`
- `../ux/ux-spec.md` §1 (QR frame metrics only)

## 3. Tasks

1. Run `cd mobile && flutter pub add qr_flutter` then `flutter analyze`. If
   resolution or analysis fails, STOP and report `QR_DEPENDENCY_UNRESOLVABLE`
   with the verbatim error — do not swap in a different package on your own.
   Confirm the analyzer accepts `QrImageView`, `QrErrorCorrectLevel.H`, and the
   module/eye color arguments before writing widget code; if the real API names
   differ from those, use the real ones and note the difference in
   `test-results.md`.
2. Add `mobile/lib/design_system/tokens/qr_palette.dart` following the existing
   `tokens/vow_palette.dart` / `tokens/splash_palette.dart` pattern. It carries
   the QR's theme-independent colors: paper `#FFFDFE`, dark QR modules, the
   badge ring color, and the scan-line gradient/edge colors from
   `../ux/ux-spec.md` §1. Export it from `design_system.dart` in alphabetical
   position among the other `tokens/` exports.
3. Add `mobile/lib/features/pairing/presentation/widgets/invite_qr_frame.dart`
   with a `StatefulWidget` taking `required String code`. Compose, in a `Stack`:
   the ambient glow blob, the 186x186 white frame (16px padding, 28px radius,
   pink drop shadow), the 154x154 QR at error-correction level **H**, the
   animated scan-line band, and the 40x40 gradient heart badge with its 5px ring.
4. Drive the `breathe` (4.5s) and `qrScan` (3.4s) loops from a single
   `AnimationController` created in `initState` and disposed in `dispose`.
5. Wrap the QR in `Semantics(label: ...)` producing
   "Mã QR chứa mã ghép đôi {code}" / "QR code containing pairing code {code}"
   via the existing `context.viEn(...)` helper.
6. Write `invite_qr_frame_test.dart` covering the acceptance criteria below.

## 4. Acceptance Criteria

- `InviteQrFrame(code: 'ZZ9QX1')` renders a QR whose configured data is exactly
  `'ZZ9QX1'` — not uppercased, not prefixed, not wrapped in a URL.
- The configured error-correction level is H.
- The badge box (badge + ring) is at most 50 logical px wide inside the 154px
  QR box.
- No `Color(0x` or `Colors.` substring exists in the new
  `lib/features/.../invite_qr_frame.dart`; every color resolves through
  `qr_palette.dart` or `context.cupidColors`.
- The widget builds and disposes without leaking its `AnimationController`
  (`tester.pumpWidget(SizedBox())` after mounting produces no exception).
- The widget makes no cubit or repository call.

## 5. Planned Outputs

- Code files: the six paths in `1B. Write Scope`.
- Contracts: `InviteQrFrame` public constructor honoring
  `../architecture/contract-summary.md`.
- Notes or evidence: record the resolved `qr_flutter` version and the confirmed
  API symbol names in `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile widget layer
- Required levels:
  - unit: N/A
  - mobile build/type-check/static-analysis: `flutter analyze` clean for the
    touched files
  - visual inspection: implementer confirms the rendered frame against
    `../ux/ux-spec.md` §1 metrics
- Required checks:
  - `cd mobile && flutter test test/features/pairing/presentation/widgets/invite_qr_frame_test.dart`
  - `cd mobile && flutter test test/design_system/no_fork_guard_test.dart`
  - `cd mobile && flutter analyze`
- Mobile discoverability / navigation integration: not in this phase — P1 owns
  the mount.
- Minimum gates by risk surface:
  - QR library availability/API: `flutter pub get` + `flutter analyze` clean
  - Payload identity: the `data`-equals-`code` assertion above
  - Badge occlusion: the EC-level-H and 50px badge-cap assertions above
  - No-fork color guard: `no_fork_guard_test.dart` green
- Required regression coverage: `no_fork_guard_test.dart` must stay green;
  adding a dependency must not change any other test's result.
- Evidence format: command + exit status + assertion names in
  `coding-plan/test-results.md`.
- Verification strategy:
  - Targeted tests: the two `flutter test` invocations above.
  - Build/type-check command: `flutter analyze`.
  - Required assertion evidence: named test cases proving payload identity and
    EC level H.

> Real-world scannability (pointing a phone camera at the rendered frame) is a
> requirement-level mobile visual audit item, not an implementation gate — do
> not attempt an emulator/device lifecycle in this phase.

## 7. Status

- Status: IMPLEMENTED
- Last updated: 2026-08-25
- Resolved dependency: `qr_flutter 4.1.0` (+ transitive `qr 3.0.2`). API surface
  read from the pub cache before use, not assumed.
- Own checks green: `invite_qr_frame_test.dart` 6/6, targeted `flutter analyze`
  clean on all three P0 files.
- Inherited red, outside this phase's write scope:
  `test/design_system/no_fork_guard_test.dart` fails on
  `lib/features/pet/presentation/widgets/pet_preview_card.dart:229-230`, a file
  byte-identical to BaseHead `94600f32`. Deferred by Scrum Master ruling to
  `BUG-20260825-002` in the bug queue — not a STORY-002 regression, not a
  blocker on this phase.
- Evidence: `coding-plan/test-results.md`
