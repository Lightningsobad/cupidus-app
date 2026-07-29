# Phase P4 – i18n / ARB Pipeline

## 1. Objective

Wire the `flutter_localizations` + `gen-l10n` ARB pipeline for `vi` (template)
and `en` so every later screen story adds copy through one mechanism (AC 2).

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-i18n-arb.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES — genuinely independent of the P0–P3 token chain. Not scheduled in parallel because mobile-dev is the only lane on this story; the implementer may pull it forward if convenient.
- Write Scope:
  - `mobile/l10n.yaml`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/pubspec.yaml` (l10n dependencies and `generate: true` only)
  - `mobile/.gitignore`
  - `mobile/test/l10n/arb_parity_test.dart`
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
  - `AppL10n` generated localization class and the ARB key convention
- Shared Interfaces Consumed:
  - None
- Risk Surfaces:
  - Locale parity (AC 2)
- Source Of Truth:
  - authoritative artifact or convention: `app_vi.arb` is the template locale; `../architecture/solution.md` ADR-004e
  - consumer contract: screen stories add every new key to both ARB files in the same change
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC 2
  - architecture: `../architecture/solution.md` ADR-004e
  - OQ constraints: OQ5 — `en` must resolve through the pipeline even though it is not user-selectable at v1
  - upstream phase outputs: none
  - UX constraints: none required (per-screen copy extraction is future screen-story work)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (P5 owns the single write)
- Phase Sizing:
  - Behavior Slice: localization pipeline plus a smoke key set; no screen copy
  - Source/Test File Count: 3 source + 2 manifest edits + 1 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` ADR-004e
- `../story_master.md` AC 2

## 3. Tasks

- Add `flutter_localizations` (SDK) and `intl` to `pubspec.yaml`; set `generate: true` under the `flutter:` section. Add no other dependency.
- Create `mobile/l10n.yaml` with `arb-dir: lib/l10n/arb`, `template-arb-file: app_vi.arb`, `output-localization-file: app_l10n.dart`, `output-class: AppL10n`, `output-dir: lib/l10n/generated`, `synthetic-package: false`, `nullable-getter: false`, `untranslated-messages-file: l10n-untranslated.json`.
- Create `app_vi.arb` and `app_en.arb` with a small smoke key set only, following the `snake_case` `<feature>_<screen>_<element>` convention. Do not extract screen copy from the design source in this story.
- Gitignore the generated output directory and `l10n-untranslated.json`.
- Confirm `flutter gen-l10n` runs as part of `flutter pub get` so a fresh clone builds without a manual codegen step.
- Write the parity and resolution tests.

## 4. Acceptance Criteria

- `AppL10n` is generated and resolves the smoke keys in both `vi` and `en`.
- `vi` is the template locale, so a missing `en` translation is reported rather than silently falling back.
- `l10n-untranslated.json` is empty after generation.
- Both ARB files contain identical key sets.
- Generated output is gitignored and reproducible from a clean checkout.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the paths in Write Scope
- Contracts or schemas: `AppL10n`, ARB key convention
- Requirement configuration guide updates: none written here
- Notes or evidence: recorded by P6 in `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, localization layer
- Required levels:
  - unit: ARB key-parity test comparing the key sets of `app_vi.arb` and `app_en.arb` and failing on any asymmetric key
  - integration: resolution test loading `AppL10n` under `Locale('vi')` and `Locale('en')` and asserting the smoke keys return different, non-empty strings
  - mobile build/type-check/static-analysis: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` clean
- Required checks: `l10n-untranslated.json` is empty after `flutter gen-l10n`
- Minimum gates by risk surface: locale parity (AC 2) -> parity test plus both-locale resolution test
- Evidence format: concise rows in `coding-plan/test-results.md`, written by P6
- Verification strategy:
  - Targeted tests/regression/contract checks: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test test/l10n/`
  - Build/type-check/lint command when required: `flutter pub get` (triggers codegen) then `flutter analyze`
  - Required assertion evidence: parity assertion output plus both-locale resolved strings

## 7. Status

- Status: DONE
- Last updated: 2026-07-29
- Evidence:
  - `flutter pub get` (triggers `flutter gen-l10n` codegen): clean, no errors.
  - `flutter analyze`: "No issues found!"
  - `flutter test test/l10n/`: 4/4 passed — key-parity test, `l10n-untranslated.json` emptiness test, `Locale(vi)` smoke-key resolution, `Locale(en)` smoke-key resolution asserted distinct from `vi`.
  - Full regression run (`flutter test`, all suites including P0–P3): 37/37 passed — no regressions from the `pubspec.yaml`/`generate: true` edit.
  - `app_vi.arb` is the template locale (`template-arb-file` in `l10n.yaml`); both ARB files use snake_case `<feature>_<screen>_<element>` keys per ADR-004e (`app_root_title`, `home_screen_greeting`, `common_actions_continue`) — smoke key set only, no screen copy extracted.
  - Generated output (`lib/l10n/generated/`, `l10n-untranslated.json`) is gitignored; the `.gitignore` comment cites `_untranslatedMessagesFileFromPath` in Flutter SDK `gen_l10n.dart`, confirming the untranslated-messages file resolves relative to the project root, not `output-dir`.
  - Non-blocking note: `l10n.yaml`'s `synthetic-package: false` (named in section 3's task text) was omitted after `flutter pub get` reported it as a deprecated no-op key in the installed Flutter SDK ("no longer has any effect and should be removed"). All other `l10n.yaml` keys match the task text exactly.
