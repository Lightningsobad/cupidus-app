# Phase P1 – Mount The QR On The Invite Card And Wire The Continue CTA

## 1. Objective

Make the QR reachable to a real user: mount `InviteQrFrame` at the top of the
existing `_InviteCodeCard`, feeding it the same `invitation.code` the text node
renders, and wire the Continue CTA to the REQ-009-locked `WaitingScreen`
destination it currently does not navigate to.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-invite-screen-mount-and-cta.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
  - `mobile/test/features/pairing/presentation/invite_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Consumed:
  - `InviteQrFrame` from P0
  - existing `WaitingScreen(expiresAt, code, router, createWaitingCubit)` push
- Risk Surfaces:
  - Payload identity (AC2)
  - CTA destination (AC4, INV-1)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` sections 1
    (Key Discovery), 4 (Mobile Lane guardrails)
  - consumer contract: `../architecture/contract-summary.md`
- Primary Inputs Summary:
  - requirements: `../requirements/` AC1, AC2, AC3, AC4, AC5
  - architecture: `../architecture/solution.md` sections 1, 4
  - upstream phase outputs: `InviteQrFrame` from P0
  - UX constraints: `../ux/ux-spec.md` "Screen Structure" ordering and §3
    (Continue CTA copy)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: screen mount + navigation wiring + their tests
  - Source/Test File Count: 2
  - Split Required: NO

## 2. Required Reads

- `../requirements/`
- `../architecture/solution.md` (Key Discovery and Mobile Lane guardrails)
- `../architecture/contract-summary.md`
- `../ux/ux-spec.md` "Screen Structure" and §3
- P0's `invite_qr_frame.dart` public constructor

## 3. Tasks

1. In `_InviteCodeCard.build`, insert `InviteQrFrame(code: invitation.code)`
   as the first child of the card `Column`, above the existing "Mã ghép đôi của
   bạn" label, followed by the spacing the UX spec's card padding implies. Pass
   the code from the same `invitation` object the `Text(invitation.code)` node
   below already uses — do not thread a second value in.
2. Wire the CTA. Change `_submitCoupleType` so that on a successful save it
   performs the same `Navigator.of(context).push(MaterialPageRoute(builder: (_)
   => WaitingScreen(expiresAt: invitation.expiresAt, code: invitation.code,
   router: router, createWaitingCubit: _createWaitingCubit)))` that
   `_copyAndAdvance` already performs. A failed save keeps the current
   snackbar-and-stay behavior unchanged. `_submitCoupleType` needs the
   `invitation` in scope — pass it from the `InviteReady` branch rather than
   reading it back out of the cubit.
3. Delete the now-stale in-source comment above `_submitCoupleType` that reads
   "Persists the selection and stops there — STORY-002 owns where Continue goes
   next", and replace it with nothing (the code is self-describing once it
   pushes).
4. Leave the CTA label as the existing `context.viEn('Tiếp tục', 'Continue')` —
   it already matches `../ux/ux-spec.md` §3. Do not add a destination suffix.
5. Do not touch `_CoupleTypeSection`, `_CoupleTypeGrid`, `_ShareInviteButton`,
   `_CopyCodeButton`, the "Mã 6 ký tự" caption, or the countdown.
6. Extend `invite_screen_test.dart` with the acceptance criteria below, reusing
   its existing `_harness(...)` helper.

## 4. Acceptance Criteria

- AC1: the invite card renders exactly one `InviteQrFrame`, and it sits above
  the gradient text code in the card's child order.
- AC2: with a fixture invitation whose code is a distinctive value, the mounted
  `InviteQrFrame.code` equals the string rendered by the card's code `Text`
  node — asserted by reading both from the widget tree in one test, not by
  comparing two literals.
- AC3: the couple-type grid still sits between the code card and the CTA — the
  existing "AC1: the picker sits between the code card and the CTA" test still
  passes unmodified.
- AC4: tapping Continue after selecting a card and a successful save pushes
  `WaitingScreen`; a failed save pushes nothing and shows the retry snackbar.
- AC4/INV-1: `post_code_navigation_guard_test.dart` stays green — no `VowScreen`,
  `OnboardingNode.vow`, or `features/vow/` reference enters `invite_screen.dart`.
- AC5: no new raw color or literal-styled node is introduced into
  `invite_screen.dart`; `no_fork_guard_test.dart` stays green.
- `InviteLoading` and `InviteFailed` render no QR.

## 5. Planned Outputs

- Code files: the two paths in `1B. Write Scope`.
- Notes or evidence: command output and the new test names in
  `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile widget layer
- Required levels:
  - mobile build/type-check/static-analysis: `flutter analyze` clean
  - visual inspection: implementer confirms the card's top-to-bottom order
    against `../ux/ux-spec.md` "Screen Structure"
- Required checks:
  - `cd mobile && flutter test test/features/pairing/presentation/invite_screen_test.dart`
  - `cd mobile && flutter test test/core/navigation/post_code_navigation_guard_test.dart`
  - `cd mobile && flutter test test/design_system/no_fork_guard_test.dart`
  - `cd mobile && flutter analyze`
- Mobile discoverability / navigation integration: this phase IS the
  integration point — the QR becomes visible on the already-reachable invite
  screen, and the Continue CTA gains its destination. No new route is added and
  none is needed; the screen is reached from the existing pairing-choice screen.
- Minimum gates by risk surface:
  - Payload identity: the AC2 tree-read assertion above
  - CTA destination: the AC4 push assertion plus the existing navigation guard
- Required regression or contract coverage: every pre-existing test in
  `invite_screen_test.dart` must still pass unmodified, in particular
  "the code card matches the design source treatment", "AC1: the picker sits
  between the code card and the CTA", and "AC4: Continue persists the chosen
  card as its wire value".
- Evidence format: command + exit status + assertion names in
  `coding-plan/test-results.md`.
- Verification strategy:
  - Targeted tests: the three `flutter test` invocations above.
  - Build/type-check command: `flutter analyze`.
  - Required assertion evidence: named test cases proving the QR/text payload
    identity and the `WaitingScreen` destination.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
