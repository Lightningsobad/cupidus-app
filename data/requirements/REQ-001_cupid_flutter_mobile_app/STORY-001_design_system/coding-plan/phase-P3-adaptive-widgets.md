# Phase P3 – The Four Named Adaptive Widgets

## 1. Objective

Build the only four widgets in the codebase allowed to branch on platform, so
all 31 later screens stay on one widget tree (D3 / AC 4).

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-adaptive-widgets.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/design_system/adaptive/cupid_tab_bar.dart`
  - `mobile/lib/design_system/adaptive/cupid_header.dart`
  - `mobile/lib/design_system/adaptive/cupid_primary_button.dart`
  - `mobile/lib/design_system/adaptive/cupid_add_action.dart`
  - `mobile/lib/design_system/design_system.dart` (add adaptive exports only)
  - `mobile/test/design_system/adaptive_widgets_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE (story-level smoke runs in P6)
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `runCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `CupidTabBar`, `CupidHeader`, `CupidPrimaryButton`, `CupidAddAction`
- Shared Interfaces Consumed:
  - P1 theme accessors and tokens; P2 `CupidIcon`
- Risk Surfaces:
  - No-fork discipline (AC 4)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` section 6 behavior table
  - consumer contract: screen stories compose these widgets and never branch on platform themselves
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC 4
  - architecture: `../architecture/solution.md` section 4 (`design_system/adaptive/` is the only platform-branching location)
  - OQ constraints: none
  - upstream phase outputs: P1 theme, P2 icons
  - UX constraints: `../ux/uiux-spec.md` section 6 (iOS vs Material behavior per category)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: four adaptive widgets, no screens
  - Source/Test File Count: 4 source + 1 export edit + 1 test
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` section 6
- `../architecture/solution.md` section 4 Affected Components
- P1 and P2 outputs

## 3. Tasks

- `CupidTabBar`: iOS — translucent background, 26pt icon with 10pt label; Material — pill-shaped active indicator.
- `CupidHeader`: iOS — large title, back affordance is chevron plus text label; Material — top app bar, back affordance is arrow icon only.
- `CupidPrimaryButton`: iOS — full-width pill using `radiusButton`; Material — filled button at 20dp corner radius with ripple feedback on press.
- `CupidAddAction`: iOS — `+` button in the nav bar; Material — FAB anchored bottom-right.
- Read the platform from `context.cupidPlatform` (which honors `CupidPlatformOverride`), never from `Platform.is*` or `defaultTargetPlatform` directly, so tests and QA can force either platform.
- Take all colors, radii, spacing, and text styles from tokens; no literals.
- Honor `tapTarget` (44pt iOS / 48dp Material) as the minimum hit target on every interactive element.
- Build no screens and add no navigation.

## 4. Acceptance Criteria

- Each widget renders both platform variants correctly under `CupidPlatformOverride`.
- Behavior matches UX section 6 for all four categories.
- No color, radius, or spacing literal appears in `adaptive/`.
- Minimum hit target is satisfied on every interactive element.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the paths in Write Scope
- Contracts or schemas: the four widget APIs
- Requirement configuration guide updates: none
- Notes or evidence: recorded by P6 in `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, adaptive widget layer
- Required levels:
  - unit: none beyond the widget tests below
  - integration: widget tests pumping each of the four widgets under both `CupidPlatformOverride` values inside `buildCupidTheme`
  - mobile build/type-check/static-analysis: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` clean
- Required checks: platform-distinguishing assertion per widget (for example FAB present on Material and absent on iOS for `CupidAddAction`); hit-target size assertion
- Mobile discoverability / navigation integration: N/A — this story builds no screens and mounts no routes; discoverability is owned by the screen stories that consume these widgets
- Minimum gates by risk surface: no-fork discipline (AC 4) -> both-platform widget tests here; repo-wide source-scan guard in P6
- Evidence format: concise rows in `coding-plan/test-results.md`, written by P6
- Verification strategy:
  - Targeted tests/regression/contract checks: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test test/design_system/adaptive_widgets_test.dart`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: per-widget, per-platform assertions in one test run

## 7. Status

- Status: DONE
- Last updated: 2026-07-29
- Evidence: `flutter analyze` clean (`mobile/`). `flutter test
  test/design_system/adaptive_widgets_test.dart` 8/8 passed, covering both
  `CupidPlatformOverride` values for all four widgets (`CupidTabBar`,
  `CupidHeader`, `CupidPrimaryButton`, `CupidAddAction`) with a
  platform-distinguishing assertion and a hit-target-size assertion each.
- Platform read mechanism: structural branching uses `CupidPlatform.of
  (context)` (the override-aware enum resolver in
  `theme/cupid_platform.dart`, documented as honoring
  `CupidPlatformOverride`); `context.cupidPlatform` (the P1
  `CupidPlatformTokens` accessor) is used only for token values (radii,
  `tapTarget`, safe-area insets), consistent with `master-plan.md` section 3
  ("`CupidPlatformTokens` ... `ThemeExtension` resolved via
  `Theme.of(context)`") and `architecture/solution.md` section 2's "Token
  access only via `BuildContext` extensions" framing. Neither call reads
  `Platform.is*` or `defaultTargetPlatform` directly.
- Sanctioned literals (verbatim from `ux/uiux-spec.md` section 6, no
  corresponding token field exists): iOS tab icon size 26 / label size 10
  (`cupid_tab_bar.dart`); Material primary-CTA corner radius 20dp
  (`cupid_primary_button.dart`, distinct from the pill `radiusButton` token
  that both platforms otherwise share at 999). Each is a private const with
  a dartdoc citing its source, not a bare literal.
