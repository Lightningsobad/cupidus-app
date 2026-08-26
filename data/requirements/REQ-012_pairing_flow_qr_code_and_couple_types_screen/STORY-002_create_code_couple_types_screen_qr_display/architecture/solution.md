# STORY-002 Create-Code (Couple Types) Screen QR Display — Solution

## 0. Metadata

- Complexity: standard
- Date: 2026-08-25

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: the pairing code already exists on-screen as
  `PairingInvitation.code`; the QR is a second *rendering* of that one value,
  so no new state, no new fetch, and no new backend surface is introduced.
- Architectural invariants / non-goals:
  - INV-1 (inherited, REQ-009): Fingerprint Vow is never the successor of
    `invite`. Already guarded by
    `mobile/test/core/navigation/post_code_navigation_guard_test.dart`.
  - INV-2: exactly one code value. The QR payload is
    `InviteReady.invitation.code` read from the same state object the text
    code renders — never a second generation call, never a reformat.
  - INV-3: no raw color literal inside `lib/features`. Enforced by
    `mobile/test/design_system/no_fork_guard_test.dart`, which substring-scans
    `lib/features`, `lib/app`, `lib/core` for `Color(0x` and `Colors.`.
  - Non-goal: no QR *scanning* (STORY-003), no camera permission, no expiry
    or regeneration mechanics.
- Proposed technical direction: add one Flutter QR-encoding dependency, add a
  `qr_palette.dart` design-system palette for the QR's fixed light-on-dark
  paper/module colors, build a self-contained `InviteQrFrame` widget, mount it
  at the top of the existing `_InviteCodeCard`, and wire the existing Continue
  CTA to `WaitingScreen` using the push already present in this file.
- Why this fits the current system: `mobile/lib/design_system/tokens/` already
  carries feature-scoped palettes (`vow_palette.dart`, `splash_palette.dart`,
  `on_accent_palette.dart`); a `qr_palette.dart` is the same pattern and keeps
  the guarded `lib/features` tree literal-free.

### Key Discovery

Three facts from the source contradict the story/UX framing and change the plan:

1. **The Continue CTA does not navigate today.** `_submitCoupleType`
   (`mobile/lib/features/pairing/presentation/screens/invite_screen.dart:222`)
   persists the couple type and stops, with an in-source comment reading
   "STORY-002 owns where Continue goes next." AC4 is therefore *new wiring*,
   not a preservation check. The destination push already exists verbatim in
   `_copyAndAdvance` (same file, lines 207-216) and is reused as-is.
2. **The "Simulate: partner joined" dashed link does not exist in the app.**
   A grep for `Simulate` / `Giả lập` / `kDebugMode` across
   `mobile/lib/features/pairing` returns nothing. It is a design-prototype
   affordance that was never implemented, so there is no production gating
   question to answer — the correct action is to keep not implementing it.
   The UX spec's §6 flag is resolved by absence.
3. **The card renders a 6-character code, not 8.** The caption at
   `invite_screen.dart:413` reads "Mã 6 ký tự" / "6-character code", and there
   is no in-card waiting-for-partner pill (waiting is a separate
   `WaitingScreen`). Implementation must encode whatever `invitation.code`
   holds and must not hardcode a length or a `CPD-` prefix.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (QR payload format,
  consumed by STORY-003's scanner).

## 3. Scope And Assumptions

- In Scope: `mobile/pubspec.yaml` + `pubspec.lock`, one new design-system
  palette, one new pairing presentation widget, `invite_screen.dart`, and the
  matching widget tests.
- Out Of Scope: backend, `cupid_api`, any web/design-system HTML source, the
  couple-type picker's content and position, expiry logic, scanning.
- Assumptions affecting design:
  - `story_master.md` declares `Implementation Lane: shared`, but no backend or
    web code changes; treat this as a mobile-only lane.
  - `flutter pub get` can reach pub.dev to resolve a new dependency. If the
    environment is offline this story cannot proceed — see the risk table.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/pairing/presentation` (screen + widget),
  `mobile/lib/design_system/tokens` (palette).
- New or changed boundaries: one new third-party dependency boundary
  (QR encoder). No new network, storage, or platform-channel boundary.
- Shared patterns reused: the `tokens/<name>_palette.dart` palette pattern and
  its `design_system.dart` export; the `Navigator.push(MaterialPageRoute →
  WaitingScreen(expiresAt, code, router, createWaitingCubit))` pattern already
  in `_copyAndAdvance`.

### Affected Modules

- Mobile: `features/pairing/presentation`, `design_system/tokens`.

### Contracts And Integrations

- Empty/error-state contract: the QR frame renders only inside the
  `InviteReady` branch of the existing `switch (state)`. `InviteLoading` and
  `InviteFailed` are unchanged — no QR placeholder, no skeleton.
- The QR widget must be pure: given a code string it renders; it never calls
  the cubit, the repository, or `refresh()`.
- Compatibility posture: additive. Removing the QR restores current behavior.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| QR library availability/API | `mobile/pubspec.yaml`, pub.dev resolution | Pick `qr_flutter`; treat the version/API as UNVERIFIED and let the resolver + analyzer prove it (section 6) | `cd mobile && flutter pub get && flutter analyze` resolves clean with the new dependency | `QR_DEPENDENCY_UNRESOLVABLE` — report the verbatim resolver error; do not hand-roll an encoder without escalating |
| Payload identity (AC2) | `InviteReady.invitation.code` | QR widget takes the code as a required `String` param sourced from the same state object the text `Text(invitation.code)` uses | Widget test asserts the `InviteQrFrame`'s `data` equals the code rendered by the sibling text node, for a non-default fixture code | `PAYLOAD_IDENTITY_UNVERIFIABLE` |
| Badge occlusion vs scannability | UX spec §1 QR frame | Error correction level **H**; badge+ring capped at 50px on a 154px module area | Widget test asserts the configured error-correction level is H **and** the badge box is <= 50 logical px inside a 154px QR box | `EC_LEVEL_UNASSERTABLE` — if the package exposes no readable level, assert the constructor argument instead |
| No-fork color guard (INV-3) | `mobile/test/design_system/no_fork_guard_test.dart` | All QR colors come from `qr_palette.dart`; never pass `Colors.black`/`Colors.white` to the QR widget's module, eye, or background arguments | `flutter test test/design_system/no_fork_guard_test.dart` passes | `NO_FORK_GUARD_RED` |
| CTA destination (AC4, INV-1) | `mobile/test/core/navigation/post_code_navigation_guard_test.dart` | Reuse the existing `WaitingScreen` push from `_copyAndAdvance`; add no `vow` import | That guard test plus a new widget test asserting Continue lands on `WaitingScreen` after a successful save | `CTA_DESTINATION_UNVERIFIED` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: dependency, palette, `InviteQrFrame`, screen mount, CTA
  wiring, widget tests.
- Authoritative inputs: this file, `../ux/ux-spec.md` §1 (QR frame metrics)
  and §3 (CTA), `contract-summary.md`.
- Guardrails:
  - Do NOT write `Color(0x` or `Colors.` anywhere under `lib/features`.
  - Do NOT add the "Simulate: partner joined" link (Key Discovery 2).
  - Do NOT add an in-card waiting pill or change the "Mã 6 ký tự" caption.
  - Do NOT change the couple-type picker's position or the share/copy actions.
  - Do NOT import anything from `features/vow/` into `invite_screen.dart`.
  - Do NOT hardcode a code length, prefix, or sample code in the widget.
  - Do NOT change the QR payload to the `https://cupid.app/pair?code=` URL.

## 5. Non-Functional Impact

- The scan-line and ambient-glow animations run continuously while the invite
  screen is mounted; both must use a single `AnimationController` disposed with
  the widget's `State`, not a rebuild-on-timer loop, so the card's existing
  1-second countdown rebuild does not compound them.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| `qr_flutter` (`QrImageView`, `errorCorrectionLevel: QrErrorCorrectLevel.H`), badge + scan-line composited as sibling widgets in a `Stack` | The established Flutter QR-render package; a `Stack` overlay lets the gradient heart badge and the animated scan-line be ordinary widgets, so no `ImageProvider`-based embedded-image path and no `CustomPainter` are needed | ACCEPTED (version/API **UNVERIFIED** — see below) | Exact check the implementer must run first: `cd mobile && flutter pub add qr_flutter && flutter analyze`. The resolver proves compatibility with `sdk: ^3.12.1`; the analyzer proves the `QrImageView` / `QrErrorCorrectLevel.H` / `dataModuleStyle` / `eyeStyle` symbol names. If either fails, stop with `QR_DEPENDENCY_UNRESOLVABLE` and report the verbatim error |
| Pure-Dart `qr` package + a hand-written `CustomPainter` | Full control over module geometry | REJECTED | Adds an encoder-to-pixels layer this story does not need; the badge and scan-line are already achievable as `Stack` siblings, which is the only reason control would have been wanted |

> Research note: `WebSearch` and `WebFetch` were both attempted and both
> returned `No such tool available: WebSearch. WebSearch is disabled for this
> session, in subagents as well as here.` (same text for `WebFetch`);
> `ToolSearch` returned the same disabled error. The package's current version
> and API names could not be confirmed against pub.dev in this run, which is
> why the ACCEPTED row is marked UNVERIFIED with a local resolver/analyzer
> check instead of a cited version constraint.
