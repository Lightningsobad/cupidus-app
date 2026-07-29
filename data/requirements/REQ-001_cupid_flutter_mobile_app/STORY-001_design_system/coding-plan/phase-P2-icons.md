# Phase P2 – Icon Family And Variant Tokens

## 1. Objective

Expose Material Symbols Rounded as the single icon family for both platforms
with the three design-source fill variants mapped to font variation axes.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-icons.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/design_system/icons/cupid_icons.dart`
  - `mobile/lib/design_system/icons/cupid_icon.dart`
  - `mobile/lib/design_system/design_system.dart` (add icon exports only)
  - `mobile/test/design_system/icon_variant_test.dart`
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
  - `CupidIcons` façade, `enum CupidIconVariant { filled, line, soft }`, `CupidIcon` widget
- Shared Interfaces Consumed:
  - P1 theme accessors and the bundled Material Symbols Rounded variable font
- Risk Surfaces:
  - Font/icon asset bundling (ADR-004d)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` section 2 icon fill-state table
  - consumer contract: screen stories use `CupidIcon` / `CupidIcons`, never a second icon package
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC 4
  - architecture: `../architecture/solution.md` ADR-004d
  - OQ constraints: none
  - upstream phase outputs: P1 theme + bundled font
  - UX constraints: `../ux/uiux-spec.md` section 2 (FILL/wght/GRAD/opsz per variant)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (report any `--no-tree-shake-icons` requirement to P5, which owns the write)
- Phase Sizing:
  - Behavior Slice: icon façade and variant mapping only
  - Source/Test File Count: 2 source + 1 export edit + 1 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` ADR-004d
- `../ux/uiux-spec.md` section 2 (icon family and fill-state table)
- P1 outputs

## 3. Tasks

- Implement `CupidIcons` as a façade over Material Symbols Rounded, preferring `const IconData` entries so Flutter icon tree-shaking keeps working.
- Implement `enum CupidIconVariant { filled, line, soft }` mapped to `fontVariations`: `filled` = FILL 1 / wght 400 / GRAD 0 / opsz 24; `line` = FILL 0 / wght 350 / GRAD 0 / opsz 24; `soft` = FILL 1 / wght 300 / GRAD -25 / opsz 24.
- Implement `CupidIcon`, a widget taking an icon, a variant, and an optional color that defaults to `context.cupidColors`-derived color rather than a literal.
- Do not add a second icon set and do not branch on platform anywhere in this phase — icon choice is platform-invariant per ADR-004d.
- If the debug build fails on icon tree-shaking, record that `--no-tree-shake-icons` is required and hand that finding to P5 for the configuration guide.

## 4. Acceptance Criteria

- All three variants map to the exact axis values in UX section 2.
- No platform branching exists in `icons/`.
- No color literal appears in `icons/`; colors come from the theme.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the paths in Write Scope
- Contracts or schemas: `CupidIcons`, `CupidIconVariant`, `CupidIcon`
- Requirement configuration guide updates: none written here; findings handed to P5
- Notes or evidence: recorded by P6 in `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, icon layer
- Required levels:
  - unit: variant-to-`fontVariations` mapping asserted for all three variants
  - mobile build/type-check/static-analysis: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` clean
- Required checks: `CupidIcon` renders inside a `buildCupidTheme` wrapper without a missing-extension assertion
- Minimum gates by risk surface: font/icon asset bundling (ADR-004d) -> variant mapping test now; full build gate deferred to P6
- Evidence format: concise rows in `coding-plan/test-results.md`, written by P6
- Verification strategy:
  - Targeted tests/regression/contract checks: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test test/design_system/icon_variant_test.dart`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: asserted axis values per variant

## 7. Status

- Status: DONE
- Last updated: 2026-07-29
- Evidence: `flutter analyze` clean; `flutter test
  test/design_system/icon_variant_test.dart` 5/5 passed, including all 3
  variant-to-axis assertions and the `CupidIcon` render + theme-color-default
  required checks. No `--no-tree-shake-icons` build was run in this phase
  (deferred to the P6 registry build gate); no tree-shaking failure observed
  in `flutter analyze`/`flutter test`. `CupidIcons` intentionally declares no
  named icon constants yet — this story has no screen-level icon inventory to
  source concrete glyph codepoints from without inventing values; screen
  stories add named `static const IconData` entries as they consume specific
  glyphs.
