# 003_scan_code_screen_qr_scanning_capability-solution.md

## 0. Metadata

- Complexity: complex
- Date: 2026-08-25

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC2 requires a scanned code to produce a byte-identical
  pairing outcome to a typed code; AC3/AC4 require every camera failure to end
  on the existing manual-entry surface; AC5 requires the new states to be
  renderable for design comparison on a machine with no camera.
- Architectural invariants / non-goals:
  - One and only one submit path to the backend: `JoincodeCubit.submit(code)`.
    The scan overlay must not own a second pairing call, a second failure map,
    or a second success navigation.
  - The scan overlay never mutates join-code screen state (`_codeController`,
    focus, scroll). Dismissing it must leave the screen exactly as found
    (UX "Fallback Guarantee").
  - No new design tokens, no new pairing outcome states, no backend change.
- Proposed technical direction: add a `mobile_scanner`-backed full-screen scan
  route in `features/pairing/presentation/`, presented with an opaque fade
  `PageRouteBuilder`, sharing the caller's existing `JoincodeCubit` instance via
  `BlocProvider.value`. Camera permission is read through a small injectable
  `CameraPermissionGate` seam so widget tests and the preview harness can drive
  all seven UX states without a camera.
- Why this fits the current system: the pairing feature already separates
  `PairingRepository` (transport + failure mapping) from `JoincodeCubit`
  (state) from `JoincodeScreen` (paint), and `main_preview.dart` already drives
  join-code states through `String.fromEnvironment` injection. The overlay
  plugs into all three seams instead of adding a parallel stack.

### Key Discovery

Three facts contradict the story/UX premise and change scope:

1. **The "Quét QR" affordance does not exist in the app.** The story and
   `ux/ux-spec.md` ("Entry Point (unchanged)") both assume the button is already
   on screen. It is not:
   `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart:523-526`
   states the design pairs the paste pill with a `Quét QR` pill but
   "QR scanning needs a camera package and platform permissions this app does
   not carry, so REQ-002/STORY-047 triage item 3d left it deferred and this pill
   takes the whole row." This story therefore also has to **build** the pill and
   split the action row into two pills to match the design source. Treat this as
   in-scope: without it AC1 has no trigger and AC5 cannot match the design.
2. **The shipped code length is 6, not 8.** `_codeLength = 6`
   (`joincode_screen.dart:29`) drives the slot row, the length limiter, and the
   paste truncation. The story text says "6/8-character" and the design canvas
   shows an 8-char `CPD-8…` form. The scan parser must target the **shipped**
   6-char form; it must not introduce an 8-char path.
3. **There is no camera or runtime-permission precedent in this app.** No
   `permission_handler`/`camera` dependency in `mobile/pubspec.yaml`, no
   `NSCameraUsageDescription` in `ios/Runner/Info.plist`, no
   `android.permission.CAMERA` in the manifest, and
   `features/onboarding/.../permissions_screen.dart` is a presentational toggle
   screen that requests nothing. `system_architecture_memory.md` has no camera or
   permission ADR. This story establishes that convention.

Fourth, smaller: "expired" is only knowable from the backend.
`PairingRepository._mapAcceptFailure` (`pairing_repository.dart:63-84`) maps
404/400 to `InvalidOrExpiredCodeFailure`. UX State 4 ("invalid **or expired**",
camera still running) therefore cannot be decided locally — the overlay must
stay mounted across the `/invitations/accept` round trip. That is the reason
for the shared-cubit design below rather than a "return the code and let the
screen submit" design.

## 2. Downstream Contract Pointer

- Cross-lane contract: none. Single-lane (mobile) story with no consumer in
  another lane, repository, or later story; `contract-summary.md` is
  intentionally omitted.

## 3. Scope And Assumptions

- In Scope: the `Quét QR` pill, the scan route and its 7-state controller, the
  QR payload parser, the camera-permission seam, `pubspec.yaml` + Android/iOS
  platform declarations, and the preview-harness entry for AC5.
- Out Of Scope: `PairingRepository`, `JoincodeCubit`, `pairingFailureMessage`,
  the slot row, the paste pill, the switch link, and post-pairing navigation —
  all reused unchanged.
- Assumptions affecting design:
  - A1 (**UNVERIFIED — blocks nothing, must be closed in the coding plan**):
    package selection. `WebSearch` and `WebFetch` are disabled in this session
    (verbatim: `No such tool available: WebSearch. WebSearch is disabled for
    this session, in subagents as well as here.`), so current version, current
    maintenance status, and the exact permission API of `mobile_scanner` and
    `permission_handler` could not be confirmed against pub.dev. Exact check the
    mobile lane must run and record in `coding-plan/test-results.md`:
    `flutter pub add mobile_scanner permission_handler` in `mobile/`, then
    record the resolved versions, confirm `flutter analyze` is clean, and
    confirm the resolved `mobile_scanner` still requires only the Flutter SDK
    constraint already declared (`sdk: ^3.12.1`). If either package fails to
    resolve or is discontinued, stop and re-open this decision — do not
    substitute a package silently.
  - A2: `minSdk`/`targetSdk` are inherited from the Flutter SDK
    (`android/app/build.gradle.kts:25-26`). MLKit-backed scanning may force an
    explicit `minSdk` floor; the first Android build is the check.
  - A3: STORY-002 owns QR *generation*, so the encoded payload shape is not
    fixed by this story. The parser below is deliberately tolerant of both a
    bare code and a URL/deep-link whose trailing segment is the code.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/pairing/presentation/`.
- New or changed boundaries:
  - `ScanCodeRoute` (full-screen, opaque, ~150ms fade `PageRouteBuilder`) —
    **decision, deviating from the UX wording**: the UX spec asks for an
    "overlay (not a full navigation/route change)", and its stated reason is
    that underlying screen state (typed characters, scroll) must survive and be
    instantly resumable. A pushed opaque route already guarantees that —
    `_JoincodeViewState` stays mounted below the route — while giving free focus
    trapping and a back-gesture dismiss that a `showGeneralDialog` overlay would
    have to re-implement. The rendered result (full-screen, dark, fade-in) is
    what the UX describes. No visual deviation; if the designer disagrees on the
    transition, that is a UX review item, not a re-architecture.
  - `ScanCodeCubit` — owns the 7 UX states, the permission read, and decode
    debounce. It does **not** own pairing; it calls the injected
    `JoincodeCubit`.
  - `CameraPermissionGate` (interface + `permission_handler` implementation) —
    `status()` returns granted / denied / permanentlyDenied / unavailable, and
    `openSettings()` for State 6. This seam exists because widget tests and
    `main_preview.dart` cannot answer a real platform channel.
  - `parsePairingCode(String raw) -> String?` — pure function, unit-testable,
    no Flutter import.
- Shared patterns reused: `BlocProvider.value` for cross-route cubit sharing,
  `context.viEn(...)` for inline vi/en copy, `context.cupidColors` /
  `cupidType` / `cupidPlatform` token access (never literal colors — the
  no-fork guard test scans for forbidden color literals), and the
  `String.fromEnvironment` preview-injection pattern already used at
  `main_preview.dart:1130-1138`.

### Affected Modules

- Mobile: `features/pairing/presentation` (+ its `screens/`), `main_preview.dart`
  preview registry, `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`,
  `ios/Runner/Info.plist`.

### Contracts And Integrations

- **Pairing hand-off (AC2).** `JoincodeScreen` pushes `ScanCodeRoute` with
  `BlocProvider.value(value: context.read<JoincodeCubit>())`. On an accepted
  decode the overlay calls `submit(code)` on **that same instance**. Identical
  outcome to manual entry is structural, not asserted: same cubit, same
  `acceptInvitation`, same failure map, same `JoincodeSuccess` listener at
  `joincode_screen.dart:176-182`.
- **Parse contract (AC4, local branch).** Normalize `raw`: trim, take the
  trailing token after the last `/` or `:` when present, strip non-alphanumerics,
  uppercase. Accept only if the result is exactly `_codeLength` (6) alphanumeric
  characters; otherwise it is malformed → State 4 with **no network call**.
  Do not reuse `_pasteCode`'s "truncate to first 6 chars" rule
  (`joincode_screen.dart:145-147`): on a URL payload it yields `HTTPS:` and
  would turn a malformed scan into a bogus backend call.
- **State routing after submit.**
  - `JoincodeInProgress` → overlay holds State 3 (recognized flash, camera
    paused, no new "processing" UI invented).
  - `JoincodeFailed(InvalidOrExpiredCodeFailure)` → State 4, camera resumes,
    `Thử lại` re-arms detection. This is the only failure the overlay renders.
  - Any other `JoincodeFailed` (`AlreadyPairedFailure`, `SelfInviteFailure`,
    `InviterAlreadyPairedFailure`, `UnmappedPairingFailure`) → pop the overlay
    immediately; the join-code screen's existing inline `errorText` renders it
    exactly as it does for manual entry.
  - `JoincodeSuccess` → pop the overlay in the overlay's own listener. The
    screen's `_handlePairedOnce` runs in a post-frame callback and is
    `_pairedHandled`-guarded, so the pop lands before `resetTo`.
- **Idempotency.** `mobile_scanner` emits a detection stream; the cubit must
  ignore every detection after the first accepted one until State 4 or State 2
  explicitly re-arms. Double submit would return 409 `AlreadyPairedFailure` and
  read to the user as a broken scan.
- **Trust boundary.** A QR payload is untrusted input. It is only ever parsed to
  a 6-char alphanumeric code and sent as `{'code': ...}`; it is never rendered
  as markup, opened as a URL, or used for navigation.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Scanned vs typed outcome divergence (AC2) | `joincode_cubit.dart:37-53` | Shared `JoincodeCubit` instance; overlay owns no pairing call | Widget test: scan path and manual path both reach one stubbed `acceptInvitation` with the same code | `SCAN_PAIRING_PARITY_UNVERIFIED` |
| Malformed/URL payload sent to backend (AC4) | `pairing_repository.dart:52-61` | `parsePairingCode` rejects locally before any call | Unit tests over bare code, URL tail, lowercase, padded, wrong length, empty | `SCAN_PARSER_UNVERIFIED` |
| Permission dead-end (AC1/AC3) | `ux/ux-spec.md` States 5-7 | `CameraPermissionGate` seam + manual-entry exit in every state | Widget tests driving denied / permanentlyDenied / unavailable, each asserting a reachable manual-entry exit | `PERMISSION_STATES_UNVERIFIED` |
| Join-code screen mutated by a dismissed scan | `ux/ux-spec.md` "Fallback Guarantee" | Overlay never touches `_codeController`/focus | Widget test: type 3 chars, open overlay, dismiss, assert the 3 chars and slot painting survive | `FALLBACK_STATE_UNVERIFIED` |
| Design fidelity of new pill + states (AC5) | `Cupid Screens.dc.html:1617-1637` | Preview entries render every state without a camera | Preview harness renders `joincode` (two-pill row) and each scan state for design comparison | `SCAN_PREVIEW_UNRENDERABLE` |
| Platform permission declarations missing | `AndroidManifest.xml`, `Info.plist` | Declare camera usage with vi/en-appropriate purpose string | Real device/emulator runtime smoke: tap `Quét QR`, OS prompt appears | `CAMERA_RUNTIME_UNVERIFIED` |
| `pubspec.yaml` collision with STORY-002 | `mobile/pubspec.yaml` | Append-only dependency edit; never reorder or reformat the block | Post-merge `flutter pub get` on the integration branch | `DEPENDENCY_MERGE_UNRESOLVED` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: all of section 4, including the platform manifest entries
  and the preview-harness registry entry.
- Authoritative inputs: this file, `story_master.md`, `ux/ux-spec.md`,
  `joincode_screen.dart`, `joincode_cubit.dart`, `pairing_repository.dart`.
- Guardrails:
  - Do not modify `PairingRepository`, `JoincodeCubit`, `pairingFailureMessage`,
    or the backend. If a scan case seems to need a new failure type, stop — it
    means AC2's parity invariant is being broken.
  - Do not raise `_codeLength` to 8 or add an 8-char code path.
  - Do not prefill or clear `_codeController` from the overlay.
  - Do not request camera permission anywhere except on `Quét QR` tap.
  - Do not add a literal color, font size, or radius — token accessors only.
  - Do not gate the preview harness behind a real camera; every state must be
    renderable headless.

## 5. Non-Functional Impact

- The camera controller must be disposed on every exit path (pop, back gesture,
  permission failure, app backgrounding). A retained camera session is the
  standard defect of this feature class and is user-visible as a stuck
  indicator light.
- Adding an MLKit-backed scanner increases Android binary size; acceptable, but
  record the delta if the first release build is measured.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Shared `JoincodeCubit`, overlay submits and stays mounted | AC2 parity by construction; keeps the overlay alive across the accept round trip so UX State 4 can show "expired" with the camera still running | ACCEPTED | Requires the failure-routing table in section 4 |
| Overlay returns `String?`, join-code screen submits | Simpler seam, no cross-route cubit sharing | REJECTED | Expired is only knowable from the backend response; the overlay would already be gone, so UX State 4's "camera keeps running, Thử lại" is unreachable and every expired scan would force a full re-open |
