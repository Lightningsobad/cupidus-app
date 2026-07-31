# Phase P5 – Fork Guard Fix

## 1. Objective

Fix a pre-existing out-of-scope defect flagged (not fixed) by the P4 mobile-dev
dispatch: `test/design_system/no_fork_guard_test.dart` failed because of a raw
`Colors.white` literal at
`mobile/lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart:144`,
violating STORY-001 AC4 / ADR-004 (design-system token discipline).

## 1A. Ownership

- Phase ID: P5 (fork-guard-fix sub-dispatch)
- Canonical Phase File: `phase-P5-fork-guard-fix.md`
- Owner: Mobile Developer
- Lane: Mobile Implementation (defect fix)

## 2. Change

`HoldToSignButton`'s dwell-progress fill (`FractionallySizedBox` ->
`Container` at the `_HoldToSignButtonState.build` `AnimatedBuilder`) used a
raw `Colors.white.withValues(alpha: 0.32)` literal instead of a design-system
token.

Replaced with `colors.colorText.withValues(alpha: 0.32)`, where
`colors = context.cupidColors` (`CupidColorTokens`) is already resolved at the
top of `build`.

`colorText` was chosen (not a new token, not `colorSurface`) because it is the
token this same widget already uses for every other element painted on top of
the button's `gradientHot`/`colorGhost` background: the label `Text` color
(`colors.colorText`), the `CircularProgressIndicator.valueColor`
(`colors.colorText`), and its `backgroundColor`
(`colors.colorText.withValues(alpha: 0.24)`). The progress-fill overlay is the
same category of on-gradient overlay element, so it follows the same
established in-file pattern rather than introducing a different token.

## 3. Verification

- `flutter test test/design_system/no_fork_guard_test.dart` — 1 passed (was
  failing before this fix).
- `flutter test test/features/love_contracts/presentation/hold_to_sign_button_test.dart`
  — 7 passed (no regression from the token swap).
- `flutter analyze lib/features/love_contracts/presentation/widgets/hold_to_sign_button.dart`
  — No issues found.

## 4. Status

- Status: DONE
- Last updated: 2026-07-31
