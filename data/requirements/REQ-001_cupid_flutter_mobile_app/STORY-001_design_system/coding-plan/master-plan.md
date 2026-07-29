# Master Coding Plan – STORY-001 Design System (platform x theme tokens + i18n ARB infra)

## 1. Planning Metadata

- Story ID: REQ-001 / STORY-001_design_system
- Complexity: L (shared-foundation)
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md` (AC 1–4), `../requirements/requirements.md` (OQ5)
- Source UX: `../ux/uiux-spec.md` sections 2–7 (exact token names/values)
- Source Architecture: `../architecture/solution.md` (ADR-004a…e + Risk Surfaces table)
- OQ Constraints Source: `../architecture/solution.md` section 3 "Open Question Constraints"
- Review Input: none (first pass)
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` (absent today — created in P5)

## 2. Planning Goal

- Shared contract owner: Mobile Developer, bound by the public names in `../architecture/solution.md` section 2
- Contract-first phase required: YES — P0 (token classes) and P1 (theme assembly) are the contract every later REQ-001 story consumes
- Parallel execution possible: NO (single lane: mobile-dev). P4 is genuinely independent of the token chain but is not scheduled in parallel because there is only one owner.
- Critical path: P0 -> P1 -> P2 -> P3 -> P5 -> P6 (P4 may be pulled forward at the implementer's convenience)
- Parallelism notes: no backend, frontend, or DevOps lane participates in this story; artificial cross-lane parallelism is deliberately not introduced.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|---|---|---|---|---|---|
| `CupidPlatformTokens` / `CupidColorTokens` / `CupidTypographyTokens` | Mobile Developer | `ThemeExtension` resolved via `Theme.of(context)` | P0 | P1, P3, all later REQ-001 stories | `context.cupidColors.colorSurface` |
| `CupidSpacing` | Mobile Developer | const class, no theme lookup | P0 | P3, all later stories | `CupidSpacing.md` |
| `buildCupidTheme({platform, brightness})` | Mobile Developer | factory returning `ThemeData` | P1 | P5, tests | 4 combinations from 2 args |
| `design_system.dart` barrel | Mobile Developer | single import surface | P1 (created), P2/P3 (extended) | all later stories | `import 'package:cupid_mobile/design_system/design_system.dart';` |
| `CupidTabBar` / `CupidHeader` / `CupidPrimaryButton` / `CupidAddAction` | Mobile Developer | widgets; only platform-branching point | P3 | all later screen stories | per `../ux/uiux-spec.md` section 6 |
| `AppL10n` + ARB key convention | Mobile Developer | `gen-l10n` codegen | P4 | all later screen stories | `AppL10n.of(context).home_header_title` |
| `CupidFeatureFlags` | Mobile Developer | `static const bool.fromEnvironment` | P5 | future settings story | `CUPID_ENABLE_LIGHT_THEME` |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|---|---|---|---|---|---|
| 4-combination completeness (AC 1) | `../ux/uiux-spec.md` s2–s5 | `buildCupidTheme` | Unit test builds all 4 `ThemeData`, asserts all 3 extensions resolve non-null | P0, P1 | AC 1 unproven — BLOCKED |
| Light-accent contrast (ADR-004b) | `../architecture/solution.md` ADR-004b | `CupidColorTokens.light()` | Contrast tripwire unit test on the 4 documented pairs | P0 | Contrast rule unenforced — BLOCKED |
| Locale parity (AC 2) | `app_vi.arb` (template locale) | `AppL10n` | ARB key-parity test + both-locale resolution test + empty `l10n-untranslated.json` | P4 | AC 2 unproven — BLOCKED |
| No-fork discipline (AC 4) | D3 / ADR-004 | `design_system/adaptive/` | Source-scan guard test over `mobile/lib/features/` and `mobile/lib/app/` | P3, P6 | AC 4 unenforceable across 31 screens — BLOCKED |
| Flag behavior (AC 3) | ADR-004a | `CupidFeatureFlags`, `CupidApp` | Widget test: defaults false, app pins dark + `vi`; light theme and `en` still constructible | P5 | AC 3 unproven — BLOCKED |
| Font/icon asset bundling (ADR-004d) | ADR-004d | `CupidIcons`, `pubspec.yaml` | `flutter build apk --debug` via registry `mobile-app` buildCommand | P1, P2 | Variable-font/tree-shake regression ships undetected — BLOCKED |

## 4. Lane Summary

- Backend required: NO
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO (registry id `mobile-app` already exists; `../architecture/solution.md` noted it as absent based on stale system memory section 8 — no DevOps phase is needed)
- Initial implementation owner: Mobile Developer
- Final verification owner: Mobile Developer
- Shared contract owner: Mobile Developer
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `REQUIRED` at story level only (P6), command/source runtime registry `data/devops/system/runtime-command-registry.json` (`installCommand: flutter pub get`, `buildCommand: flutter build apk --debug`, `testCommand: flutter test`; readiness is the `Key('home_screen_ready_signal')` widget-test signal, not an HTTP probe). Flutter is not on PATH on this machine — resolve via `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | `mobile/lib/design_system/tokens/`, `mobile/lib/design_system/theme/cupid_platform.dart`, `mobile/test/design_system/contrast_test.dart` | `../ux/uiux-spec.md` s2–s4; `../architecture/solution.md` s4 Affected Components + ADR-004b/004c | 3 `ThemeExtension` classes, `CupidSpacing`, `CupidPlatform` + override, contrast tripwire test | unit (contrast tripwire), `flutter analyze` | DONE |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/design_system/theme/cupid_theme.dart`, `.../cupid_theme_context.dart`, `mobile/lib/design_system/design_system.dart`, `mobile/pubspec.yaml`, `mobile/assets/fonts/`, `mobile/test/design_system/theme_matrix_test.dart` | P0 outputs; `../ux/uiux-spec.md` s4–s5; ADR-004d | `buildCupidTheme`, context accessors, barrel, bundled fonts, 4-combination test | unit (4-combination matrix), `flutter analyze` | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/design_system/icons/`, `mobile/test/design_system/icon_variant_test.dart` | P1 outputs; `../ux/uiux-spec.md` s2 icon variant table; ADR-004d | `CupidIcons` façade, `CupidIconVariant` -> `fontVariations` mapping | unit (variant mapping), `flutter analyze` | DONE |
| P3 | Mobile Developer | Mobile | P1, P2 | NO | `mobile/lib/design_system/adaptive/`, `mobile/test/design_system/adaptive_widgets_test.dart` | P1/P2 outputs; `../ux/uiux-spec.md` s6; ADR-004 (D3) | `CupidTabBar`, `CupidHeader`, `CupidPrimaryButton`, `CupidAddAction` | widget tests both platforms, `flutter analyze` | DONE |
| P4 | Mobile Developer | Mobile | None | YES (independent of the token chain; not scheduled in parallel — single lane) | `mobile/l10n.yaml`, `mobile/lib/l10n/arb/`, `mobile/pubspec.yaml` (l10n keys only), `mobile/.gitignore`, `mobile/test/l10n/` | `../architecture/solution.md` ADR-004e; `../story_master.md` AC 2 | `l10n.yaml`, `app_vi.arb` + `app_en.arb` smoke keys, generated `AppL10n` | unit (ARB key parity + both-locale resolution), `flutter analyze` | DONE |
| P5 | Mobile Developer | Mobile | P1, P4 | NO | `mobile/lib/core/config/cupid_feature_flags.dart`, `mobile/lib/app/cupid_app.dart`, `mobile/lib/main.dart`, `mobile/lib/design_system/theme/app_theme.dart` (removal), `mobile/test/app/`, `../../deployment/configuration-guide.md` | P1/P4 outputs; ADR-004a; OQ5 | `CupidFeatureFlags`, `CupidApp` wiring theme+locale, configuration guide | widget test (flag behavior), `flutter analyze` | DONE |
| P6 | Mobile Developer | Mobile Verification | P0, P1, P2, P3, P4, P5 | NO | `mobile/test/design_system/no_fork_guard_test.dart`, `coding-plan/test-results.md` | all phase outputs; `../architecture/solution.md` Risk Surfaces table | AC 4 source-scan guard test, `test-results.md` | full `flutter test`, `flutter analyze`, registry `flutter build apk --debug`, story runtime startup smoke | DONE |

The final phase (P6) is the verification phase for this `complex` story.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-tokens.md` |
| P1 | `phase-P1-theme-assembly.md` |
| P2 | `phase-P2-icons.md` |
| P3 | `phase-P3-adaptive-widgets.md` |
| P4 | `phase-P4-i18n-arb.md` |
| P5 | `phase-P5-flags-and-app-wiring.md` |
| P6 | `phase-P6-verification.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file; no duplicates exist.
- Every implementation phase is sized to at most six source/test files for one specialist lifecycle.
- No implementation phase test scope contains backend e2e/test_e2e, Playwright/browser e2e, mobile e2e, emulator/simulator lifecycle commands, signing, store upload, traces, scenario reruns, or repository-root local script gates.

## 6. Risks And Notes

- Risks:
  - Existing bootstrap scaffold conflicts: `mobile/lib/main.dart` already declares `CupidApp` and consumes `AppTheme.light` from `mobile/lib/design_system/theme/app_theme.dart`. P5 owns the migration; no earlier phase may edit `main.dart`.
  - `Key('home_screen_ready_signal')` in `mobile/lib/features/home/presentation/home_screen.dart` is the runtime registry readiness signal. P5 rewires the app around it and must not remove or rename it.
  - Bundling the Material Symbols Rounded variable font can disable Flutter icon tree-shaking (ADR-004d). Surfaces at P2/P6 build; fallback is `--no-tree-shake-icons`, recorded by P5 in the configuration guide.
  - Flutter is not on PATH on this machine; every command must resolve the SDK via `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`.
- OQ-driven constraints: OQ5 — all 4 combinations and both locales must build and be test-constructible; only dark + `vi` may be user-exposed. Flags gate exposure, never existence (ADR-004a).
- Migration / rollout notes: no data migration. `AppTheme` is removed in P5 in the same change that introduces `buildCupidTheme`, so the app is never left referencing a deleted symbol.
- Notes: token values are transcribed verbatim from `../ux/uiux-spec.md` sections 2–4. The only sanctioned deviation is ADR-004c (`colorAccentPurpleDark` light carry-over). No other invented values are permitted.
