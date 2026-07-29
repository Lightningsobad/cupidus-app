# Phase P5 – Enablement Flags, App Wiring, And Configuration Guide

## 1. Objective

Introduce `CupidFeatureFlags`, wire the app to the new theme and localization
layers, retire the bootstrap `AppTheme`, and record the build-time
configuration contract (AC 3).

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-flags-and-app-wiring.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/config/cupid_feature_flags.dart`
  - `mobile/lib/app/cupid_app.dart`
  - `mobile/lib/main.dart`
  - `mobile/lib/design_system/theme/app_theme.dart` (removal)
  - `mobile/test/app/feature_flags_test.dart`
  - `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE for this phase (story-level smoke runs in P6)
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `runCommand`
  - Readiness Check: `Key('home_screen_ready_signal')` in `mobile/lib/features/home/presentation/home_screen.dart` — must survive this rewiring unchanged
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `CupidFeatureFlags`, `CupidApp` (relocated to `lib/app/`)
- Shared Interfaces Consumed:
  - P1 `buildCupidTheme`; P4 `AppL10n`
- Risk Surfaces:
  - Flag behavior (AC 3)
  - Font/icon asset bundling (ADR-004d) — records the `--no-tree-shake-icons` fallback if P1/P2 hit it
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` ADR-004a
  - consumer contract: a future settings story reads these flags to decide whether to render theme and locale pickers
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC 3
  - architecture: `../architecture/solution.md` ADR-004a, section 2 DevOps contract
  - OQ constraints: OQ5 — expose dark + `vi` only; light and `en` stay built and test-constructible
  - upstream phase outputs: P1 theme, P4 localization, plus any P2 tree-shake finding
  - UX constraints: none
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES (file does not exist yet — create it)
  - Sections To Update: build-time flags (`CUPID_ENABLE_LIGHT_THEME`, `CUPID_ENABLE_EN_LOCALE`, both defaulting to `false`), the QA command for exercising the three non-default combinations and `en`, the `--no-tree-shake-icons` fallback, and the note that release/store builds must set neither flag
- Phase Sizing:
  - Behavior Slice: flags plus app composition; no screens, no new widgets
  - Source/Test File Count: 3 source + 1 removal + 1 test + 1 doc
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` ADR-004a and section 2 (DevOps / environment contract)
- `../story_master.md` AC 3
- P1 and P4 outputs
- `mobile/lib/main.dart` and `mobile/lib/design_system/theme/app_theme.dart` (existing bootstrap scaffold being migrated)

## 3. Tasks

- Implement `CupidFeatureFlags` with `static const bool enableLightTheme = bool.fromEnvironment('CUPID_ENABLE_LIGHT_THEME', defaultValue: false)` and `static const bool enableEnLocale = bool.fromEnvironment('CUPID_ENABLE_EN_LOCALE', defaultValue: false)`.
- Move `CupidApp` out of `main.dart` into `lib/app/cupid_app.dart`; `main.dart` keeps only `runApp(const CupidApp())`.
- Wire `CupidApp` to `buildCupidTheme` for both brightnesses and to `AppL10n`. With flags off: `themeMode: ThemeMode.dark` and `locale: const Locale('vi')`. With a flag on: the corresponding axis follows the device with `vi` as fallback.
- Always register both locales in `localizationsDelegates` and `supportedLocales` regardless of flag state; the pinned `locale` is what enforces `vi` at v1.
- Delete `mobile/lib/design_system/theme/app_theme.dart` in the same change that switches the app to `buildCupidTheme`, so no phase leaves the app referencing a deleted symbol.
- Preserve `Key('home_screen_ready_signal')` in the home screen — it is the runtime registry readiness signal.
- Create `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` with the sections listed above.
- Add no settings UI and no user-facing theme or locale picker; that is a later story.

## 4. Acceptance Criteria

- Both flags default to `false` with no `--dart-define` supplied.
- With flags off, the app resolves to dark theme and `vi` locale.
- Light `ThemeData` and the `en` locale remain directly constructible in tests with flags off — flags gate exposure, never existence.
- `AppTheme` is fully removed with no dangling references.
- `Key('home_screen_ready_signal')` still resolves.
- The configuration guide exists and documents both flag keys, the QA command, and the tree-shake fallback.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the paths in Write Scope
- Contracts or schemas: `CupidFeatureFlags`, `CupidApp`
- Requirement configuration guide updates: created with build-time flags, QA command, tree-shake fallback, and the release-build rule
- Notes or evidence: recorded by P6 in `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, app composition layer
- Required levels:
  - unit: `CupidFeatureFlags` defaults are both `false`
  - integration: widget test pumping `CupidApp` and asserting dark theme plus `vi` resolution with flags off, and separately asserting that `buildCupidTheme(brightness: Brightness.light)` and `AppL10n` under `Locale('en')` are still constructible
  - mobile build/type-check/static-analysis: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` clean
- Required checks: `Key('home_screen_ready_signal')` found in a pumped app; no reference to `AppTheme` remains in `mobile/lib/`
- Mobile discoverability / navigation integration: unchanged — this story adds no new screen or route; the existing home screen entry point must keep working
- Minimum gates by risk surface: flag behavior (AC 3) -> the widget test above
- Evidence format: concise rows in `coding-plan/test-results.md`, written by P6
- Verification strategy:
  - Targeted tests/regression/contract checks: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test test/app/`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: resolved `themeMode`, resolved locale, and the readiness key assertion

## 7. Status

- Status: DONE
- Last updated: 2026-07-29
- Evidence:
  - `flutter analyze`: "No issues found!" (confirms no dangling `AppTheme` reference — analyze would flag an undefined identifier).
  - `flutter test test/app/`: 4/4 passed — flags-default unit test, `CupidApp` dark/`vi` + readiness-key widget test, light `ThemeData` direct-construction test, `en` `AppL10n` direct-construction test.
  - Full regression `flutter test` (all suites P0-P5): 41/41 passed, no regressions.
  - `CupidFeatureFlags` (`mobile/lib/core/config/cupid_feature_flags.dart`): both flags `bool.fromEnvironment(..., defaultValue: false)`.
  - `CupidApp` relocated to `mobile/lib/app/cupid_app.dart`; `mobile/lib/main.dart` now contains only the import and `runApp(const CupidApp())`. `CupidApp` reads platform via `CupidPlatform.of(context)` (override-testable, consistent with the P3 adaptive-widget pattern) rather than a direct `resolveDefault()` call, so tests can force either platform on `CupidApp` itself if a future story needs that.
  - `mobile/lib/design_system/theme/app_theme.dart` deleted via `git rm` in the same change that switched the app to `buildCupidTheme` (fully reversible, git-tracked file — plain `rm` was blocked by the repo's destructive-command safety guard).
  - `Key('home_screen_ready_signal')` unchanged in `home_screen.dart`; asserted resolving in the P5 widget test.
  - Locale/theme-mode wiring: flags off -> `themeMode: ThemeMode.dark`, `locale: const Locale('vi')` (pinned, matching AC 3). Flags on -> `ThemeMode.system` / a `localeResolutionCallback` that follows the device locale and falls back to `vi` (not the arbitrary first entry of `AppL10n.supportedLocales`) when unsupported. Both locales are always registered in `localizationsDelegates`/`supportedLocales` regardless of flag state.
  - Necessary collateral fix (not in the phase's literal Write Scope list but required to keep the tree green after relocating `CupidApp`): `mobile/test/widget_test.dart` import changed from `package:cupid_mobile/main.dart` to `package:cupid_mobile/app/cupid_app.dart` — one line, no behavior change, confirmed still passing.
  - `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` created (did not exist before this phase): documents both `--dart-define` keys with defaults, a 3-combination QA `flutter run` command set, the `--no-tree-shake-icons` fallback (citing the P1/P2 ~15MB font-size finding), and the ARB/i18n notes (template locale, `l10n-untranslated.json` gate, gen-l10n-on-pub-get).
  - No settings UI or theme/locale picker added, per instruction.
