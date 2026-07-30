# Phase P3 – Signing Ritual UI And Error States

## 1. Objective

Fill the signing slot with the hold-to-sign control (widget-local progress, ~1.5s dwell), render
the signed / awaiting-partner states per ADR-006c, and add the inline mapped-error banner with
retry.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-signing-ritual-ui.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`
  - `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/love_contracts/presentation/hold_to_sign_button_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` — not run in this phase
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `HoldToSignButton`
  - the completed signing UI on `LoveContractScreen`
- Shared Interfaces Consumed:
  - P1's `SignHoldStarted` / `SignHoldCancelled` / `SignHoldCompleted` events and
    `LoveContractReady.signStatus` / `actionFailure`
  - P2's screen shell and ARB keys
  - P0's sign-unavailable failure type
- Risk Surfaces:
  - Custom-gesture accessibility (UX §8)
  - Creator-only backend capability (ADR-006c)
  - Mapped-error presentation (UX §6)
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §5 and §6; `../architecture/solution.md` ADR-006a
    (progress stays widget-local) and ADR-006c (no partner-sign affordance)
  - consumer contract: the events this control dispatches into `LoveContractBloc`
- Primary Inputs Summary:
  - UX constraints: `../ux/uiux-spec.md` §5 (unsigned / signed-by-me / both-signed states, hold
    copy, footer lock note), §6 (error banner + retry, sign-unavailable copy), §8 (accessible
    alternative to the raw hold gesture)
  - architecture: `../architecture/solution.md` ADR-006a, ADR-006c
  - upstream phase outputs: P1's bloc/state, P2's screen shell, P0's failure types
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: the signing ritual and its result/error presentation
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §5, §6, §8
- `../architecture/solution.md` ADR-006a, ADR-006c
- P0 failure types, P1 events/state, P2 screen shell

## 3. Tasks

- Build `HoldToSignButton` with a widget-local `AnimationController` driving the circular progress
  ring and the inverse overlay over ~1.5s (UX §5). It dispatches `SignHoldStarted` on press,
  `SignHoldCancelled` on early release or gesture cancel, and `SignHoldCompleted` exactly once when
  the dwell completes. No progress value crosses the Bloc boundary (ADR-006a).
- Provide an accessible activation path alongside the raw hold: expose a semantic action (or an
  equivalent confirm affordance reachable via the platform accessibility activation gesture) that
  produces the same started→completed pair (UX §8). Do not ship a gesture-only control.
- Render the three result states on the screen:
  - unsigned → full-width gradient pill with the hold copy from ARB, disabled when no clause is
    selected;
  - signed-by-me → the green-tinted card with "{me} đã ký" plus the awaiting-partner status line;
  - both-signed → the confirmation state with a Done/back affordance in the revisit path.
    Per ADR-006c the app never renders a partner-facing sign affordance, and per UX §9-3 the
    prototype's "Ghép đôi"/"Pair up" CTA must not be ported.
- Keep the footer lock note ("Bản hợp đồng lưu ở Level 2 …") as ARB copy.
- Render `actionFailure` as an inline banner above the card with a retry action; the card chrome
  stays visible (UX §6). Map the sign-unavailable failure from P0 to its own localized message and
  never display a raw status code, server string, or `CupidApiFailure` type name.
- Add every new string to both `app_vi.arb` and `app_en.arb` in the same commit.

## 4. Acceptance Criteria

- Releasing the hold before the dwell completes dispatches `SignHoldCancelled` and triggers no
  network call.
- A completed hold dispatches exactly one `SignHoldCompleted`.
- No hold-progress value appears in any Bloc state or event payload.
- An accessible activation alternative to the raw hold exists and is covered by a test.
- The signing control is disabled when no clause is selected.
- No partner-facing sign affordance is rendered in any state.
- Error text is localized ARB copy; no raw failure type, status code, or server message is shown.
- New strings exist in both ARB files; `arb_parity_test.dart` stays green.

## 5. Planned Outputs

- Code files: `hold_to_sign_button.dart` plus the signing/error sections of `love_contract_screen.dart`
- Contracts: `HoldToSignButton`; the signing-related ARB keys
- Requirement configuration guide updates: none
- Notes or evidence: concise rows in `test-results.md` (P5 consolidates)

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter widget tests (`mobile` package), `HoldToSignButton` and the screen's
  signing/error regions
- Required levels:
  - integration: widget-level screen + Bloc with a fake repository for the sign paths
  - mobile build/type-check/static-analysis: `flutter analyze` clean
  - visual inspection: N/A in this phase (requirement-level mobile visual audit only)
- Required checks:
  - `flutter test test/features/love_contracts/presentation/`
  - `flutter test test/l10n/arb_parity_test.dart`
  - `flutter analyze`
- Mobile discoverability / navigation integration: N/A for this phase (owned by P4)
- Minimum gates by risk surface:
  - accessibility → assert the semantic activation alternative produces the same event pair
  - creator-only capability → assert no partner-sign affordance is findable in any rendered state,
    and that the sign-unavailable failure renders its localized message
  - mapped-error presentation → assert the banner text is ARB copy and the card stays visible
- Required regression or contract coverage: P2's screen widget test and P1's bloc test stay green
- Evidence format: concise rows in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: the new hold-control test plus the P2/P1 tests as regression
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: dispatched event sequence per gesture outcome and the rendered
    text for each failure case

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
