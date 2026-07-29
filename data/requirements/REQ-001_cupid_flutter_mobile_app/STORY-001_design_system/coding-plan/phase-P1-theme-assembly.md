# Phase P1 – Theme Assembly, Fonts, And Import Surface

## 1. Objective

Compose the P0 tokens into `ThemeData` for all four platform x theme
combinations, bundle the required fonts, and expose the single import surface
that all later stories use.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-theme-assembly.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/design_system/theme/cupid_theme.dart`
  - `mobile/lib/design_system/theme/cupid_theme_context.dart`
  - `mobile/lib/design_system/design_system.dart`
  - `mobile/pubspec.yaml` (fonts + assets declarations only)
  - `mobile/assets/fonts/`
  - `mobile/test/design_system/theme_matrix_test.dart`
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
  - `buildCupidTheme({required CupidPlatform platform, required Brightness brightness})`
  - `context.cupidColors`, `context.cupidPlatform`, `context.cupidType`
  - `package:cupid_mobile/design_system/design_system.dart` barrel
- Shared Interfaces Consumed:
  - P0 token classes and `CupidPlatform`
- Risk Surfaces:
  - 4-combination completeness (AC 1)
  - Font/icon asset bundling (ADR-004d)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` section 4 Affected Components
  - consumer contract: barrel exports are the only public import path for feature code
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC 1, AC 4
  - architecture: `../architecture/solution.md` section 4, ADR-004d
  - OQ constraints: OQ5 — all four combinations must build
  - upstream phase outputs: P0 token classes
  - UX constraints: `../ux/uiux-spec.md` sections 4 (font families) and 5 (combination matrix)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (P5 owns the single write; report any tree-shake finding to P5)
- Phase Sizing:
  - Behavior Slice: theme composition and import surface only; no widgets, no flags, no l10n
  - Source/Test File Count: 3 source + 1 manifest edit + 1 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` section 4 (Affected Components), ADR-004d
- `../ux/uiux-spec.md` sections 4 and 5
- P0 outputs

## 3. Tasks

- Implement `buildCupidTheme({required CupidPlatform platform, required Brightness brightness})` returning `ThemeData` with all three P0 extensions registered.
- Derive `ThemeData.colorScheme` from `CupidColorTokens` so stock Material widgets inherit brand color from the same source of truth rather than a second palette.
- Implement the `BuildContext` accessors in `cupid_theme_context.dart`; each asserts the extension is present and returns non-null.
- Create the `design_system.dart` barrel exporting tokens, theme, and context accessors. Feature code must never need a deeper import.
- Add the font assets under `mobile/assets/fonts/` and declare them in `pubspec.yaml`: Nunito (400/600/700/800/900), Roboto (400/500/700), Roboto Mono (400/500), Material Symbols Rounded (variable). Bundle Roboto explicitly so Material-style typography is reproducible on iOS devices; iOS-style uses the platform default font family (SF Pro cannot be bundled).
- Do not add any dependency beyond what P4 needs; no `google_fonts`, no runtime font fetching.
- Write the 4-combination matrix test.

## 4. Acceptance Criteria

- `buildCupidTheme` produces a valid `ThemeData` for all four combinations without throwing.
- All three extensions resolve non-null from every produced `ThemeData`.
- `colorScheme` values trace back to `CupidColorTokens` fields, not to hardcoded literals.
- Fonts resolve from bundled assets with no network access.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the paths in Write Scope
- Contracts or schemas: `buildCupidTheme`, context accessors, barrel export list
- Requirement configuration guide updates: none directly; report any `--no-tree-shake-icons` need to P5
- Notes or evidence: recorded by P6 in `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, theme layer
- Required levels:
  - unit: 4-combination matrix test — for each of `{ios, material} x {dark, light}` build the theme and assert `CupidPlatformTokens`, `CupidColorTokens`, and `CupidTypographyTokens` all resolve, that platform tokens differ between `ios` and `material`, and that color tokens differ between `dark` and `light`
  - mobile build/type-check/static-analysis: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` clean
- Required checks: `body` text style picks up the platform `uiFontFamily`; declared font assets exist on disk
- Minimum gates by risk surface: 4-combination completeness (AC 1) -> matrix test
- Evidence format: concise rows in `coding-plan/test-results.md`, written by P6
- Verification strategy:
  - Targeted tests/regression/contract checks: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test test/design_system/theme_matrix_test.dart`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: all four combinations asserted in one test run

## 7. Status

- Status: DONE
- Last updated: 2026-07-29
- Evidence: `flutter analyze` clean; `flutter test
  test/design_system/theme_matrix_test.dart` 9/9 passed, including all 4
  combinations in "4-combination matrix (AC 1)". Fonts bundled from
  `google/fonts` (Nunito, Roboto, Roboto Mono — single variable-axis TTF per
  family, no discrete static weight files published upstream any more) and
  `google/material-design-icons` (Material Symbols Rounded variable font);
  Flutter resolves `TextStyle.fontWeight` from each font's own weight axis.
  Finding for P5: Material Symbols Rounded variable TTF is ~15MB on disk (vs.
  the ~1-2MB estimate in `architecture/solution.md` section 5) — raises the
  likelihood `--no-tree-shake-icons` will be needed at build time; P5 owns
  the configuration-guide note, not written here.
