# Phase P0 – Design Tokens

## 1. Objective

Create the three `ThemeExtension` token classes, the const spacing class, and
the platform-axis resolver that every other REQ-001 story consumes.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-tokens.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/design_system/tokens/cupid_platform_tokens.dart`
  - `mobile/lib/design_system/tokens/cupid_color_tokens.dart`
  - `mobile/lib/design_system/tokens/cupid_typography_tokens.dart`
  - `mobile/lib/design_system/tokens/cupid_spacing.dart`
  - `mobile/lib/design_system/theme/cupid_platform.dart`
  - `mobile/test/design_system/contrast_test.dart`
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
  - `CupidPlatformTokens`, `CupidColorTokens`, `CupidTypographyTokens`
  - `CupidSpacing`, `CupidPlatform`, `CupidPlatformOverride`
- Shared Interfaces Consumed:
  - None
- Risk Surfaces:
  - Light-accent contrast (ADR-004b)
  - 4-combination completeness (AC 1) — partial; completed in P1
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` sections 2–4 for exact token names and values
  - consumer contract: `../architecture/solution.md` section 2 public names (may not be renamed)
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC 1
  - architecture: `../architecture/solution.md` section 4 Affected Components, ADR-004b, ADR-004c
  - OQ constraints: OQ5 — both themes must be constructible
  - upstream phase outputs: none
  - UX constraints: `../ux/uiux-spec.md` sections 2, 3, 4 (token tables)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: token layer only, no theme assembly and no widgets
  - Source/Test File Count: 5 source + 1 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` section 4 (Affected Components), ADR-004b, ADR-004c
- `../ux/uiux-spec.md` sections 2, 3, 4
- `../story_master.md` AC 1

## 3. Tasks

- Implement `CupidPlatformTokens extends ThemeExtension<CupidPlatformTokens>` with `radiusCard`, `radiusButton`, `radiusSheet`, `radiusSmall`, `safeTop`, `safeBottom`, `tapTarget`, `uiFontFamily`, `elevationShadow`; provide `const CupidPlatformTokens.ios()` and `.material()` using the exact values in UX section 2.
- Implement `CupidColorTokens extends ThemeExtension<CupidColorTokens>` with one field per UX section 3 row (`colorBackground` … `gradientHot`); provide `.dark()` and `.light()`.
- Apply ADR-004c: `colorAccentPurpleDark` in `.light()` uses `#8E5FD6` (the dark value) with a dartdoc marking it a design-source gap restricted to non-text usage.
- Apply ADR-004b: dartdoc on `colorAccentPink`, `colorAccentPinkDark`, `colorAccentPurple`, `colorAccentPurpleDark` in `.light()` stating they are large-text/icon/border/gradient only, never body or caption text on surface/background.
- Implement `CupidTypographyTokens extends ThemeExtension<CupidTypographyTokens>` with roles `display`, `cardTitle`, `body`, `caption`, `labelMono` per UX section 4, constructed via `CupidTypographyTokens.forPlatform(CupidPlatform)` so `body` inherits `uiFontFamily`. Text styles carry no color.
- Implement `abstract final class CupidSpacing` with const `xs`, `sm`, `md`, `lg`, `xl`, `xxl` per UX section 4.
- Implement `enum CupidPlatform { ios, material }`, a resolver from `defaultTargetPlatform` (iOS/macOS -> `ios`, else `material`), and a `CupidPlatformOverride` inherited widget so tests and QA can force either platform on one device.
- Implement `copyWith` and `lerp` on all three extensions (required by `ThemeExtension`).
- Write the contrast tripwire test asserting the four documented ratios.

## 4. Acceptance Criteria

- Every token name and value in UX sections 2–4 has exactly one corresponding field; no invented values other than ADR-004c.
- All three extensions implement `copyWith` and `lerp`.
- `CupidPlatformOverride` lets a test render either platform regardless of the host device.
- Contrast tripwire test passes and fails if a light accent value is changed to something that silently claims AA compliance.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the six paths in Write Scope
- Contracts or schemas: `CupidPlatformTokens`, `CupidColorTokens`, `CupidTypographyTokens`, `CupidSpacing`, `CupidPlatform`
- Requirement configuration guide updates: none
- Notes or evidence: recorded by P6 in `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, token layer (no widget tree yet)
- Required levels:
  - unit: contrast tripwire test asserting light `colorAccentPink` on `colorSurface` is `>= 3.0` and `< 4.5`; dark `colorAccentPink` on `colorSurface` is `>= 4.5`; dark and light `colorText` on `colorBackground` are both `>= 4.5`
  - mobile build/type-check/static-analysis: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` clean
- Required checks: every field of `.dark()`, `.light()`, `.ios()`, `.material()` is non-null; `lerp` at `t=0` and `t=1` returns the endpoints
- Minimum gates by risk surface: light-accent contrast (ADR-004b) -> contrast tripwire test
- Evidence format: concise rows in `coding-plan/test-results.md`, written by P6
- Verification strategy:
  - Targeted tests/regression/contract checks: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test test/design_system/contrast_test.dart`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: computed contrast ratios printed or asserted against the ADR-004b thresholds

## 7. Status

- Status: DONE
- Last updated: 2026-07-29
