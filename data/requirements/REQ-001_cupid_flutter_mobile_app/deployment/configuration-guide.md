# REQ-001 Configuration Guide — Cupid Flutter Mobile App

Owning story: STORY-001 design_system (`architecture/solution.md` ADR-004a,
section 2 DevOps/environment contract). Later stories append to this file;
they do not create a second configuration guide.

## Build-Time Enablement Flags

Two `--dart-define` keys gate **exposure** of the light theme and the `en`
locale. Both default to `false`. Neither gates existence: light `ThemeData`
and `AppL10n` under `Locale('en')` are always built and always directly
constructible in tests, regardless of these flags (OQ5).

| Key | Default | Effect when `true` |
|---|---|---|
| `CUPID_ENABLE_LIGHT_THEME` | `false` | `MaterialApp.themeMode` follows the device (`ThemeMode.system`) instead of pinning `ThemeMode.dark`. |
| `CUPID_ENABLE_EN_LOCALE` | `false` | `MaterialApp.locale` follows the device locale (falling back to `vi` if unsupported) instead of pinning `Locale('vi')`. |

**Release/store builds must pass neither flag.** Passing neither key
reproduces the v1-launch default: dark theme, `vi` locale.

## QA Command — Exercising The Three Non-Default Combinations

Run each of the following from `mobile/` to manually exercise a
non-default combination on a connected device/simulator (there is no
in-app settings picker at v1 — this is a developer/QA override only):

```bash
# Light theme, vi locale
flutter run --dart-define=CUPID_ENABLE_LIGHT_THEME=true

# Dark theme, en locale (falls back to device locale, or vi if unsupported)
flutter run --dart-define=CUPID_ENABLE_EN_LOCALE=true

# Light theme, en locale
flutter run --dart-define=CUPID_ENABLE_LIGHT_THEME=true --dart-define=CUPID_ENABLE_EN_LOCALE=true
```

The default `flutter run` (no `--dart-define`) exercises the fourth,
default combination: dark theme, `vi` locale.

## Icon Asset Tree-Shaking Fallback

The bundled Material Symbols Rounded variable font is materially larger on
disk (~15MB) than the architecture estimate (~1-2MB) — see P1/P2 findings
in `coding-plan/phase-P1-theme-assembly.md` and `phase-P2-icons.md`. If a
release build fails or is rejected for size because Flutter's default icon
tree-shaking cannot analyze the variable-font glyph set, add
`--no-tree-shake-icons` to the build command:

```bash
flutter build apk --release --no-tree-shake-icons
```

Prefer the default (tree-shaking enabled) build first; only add this flag
if the build step reports a tree-shaking failure against
`MaterialSymbolsRounded`.

## API Client Generation (STORY-002)

- **Dart SDK floor normalization.** `mobile/tool/generate_api_client.sh`
  regenerates `mobile/openapi/cupid_api/` from the vendored OpenAPI spec on
  every run (whole-directory replace). The `openapi-generator-cli` `dart-dio`
  template hardcodes `environment: sdk: '>=3.5.0 <4.0.0'` in the generated
  package's `pubspec.yaml`, which is too low for the `json_serializable`
  version pub resolves today (its emitted `.g.dart` uses the "null-aware
  elements" syntax, which requires a higher Dart language version). The
  script patches the generated `sdk:` line to match `mobile/pubspec.yaml`'s
  own constraint (`^3.12.1` today) immediately after
  `openapi-generator-cli generate` and before `dart pub get`. This step is
  idempotent (re-running the generator never drifts the value) and exits
  non-zero with a clear error if the expected `sdk:` line is missing from
  either `pubspec.yaml`, so a future generator-template change cannot
  silently skip the patch. The patch lives only in the script — no file
  under `mobile/openapi/cupid_api/` is ever hand-edited.
- **Preconditions:** Node (tested with v20.x) and a JDK (tested with
  OpenJDK 17) are required to run `npx @openapitools/openapi-generator-cli`.
  The generator-cli version is pinned exactly (no `^`) in
  `mobile/openapitools.json` (currently `7.24.0`).
- **Regenerate the client:** `bash mobile/tool/generate_api_client.sh` from
  `mobile/` (see `mobile/openapi/README.md` for the two-step
  fetch/generate flow).

- **`CUPID_API_BASE_URL` dart-define.** The generated API client's base URL
  (`mobile/lib/core/config/cupid_api_config.dart`) is a build-time
  `String.fromEnvironment('CUPID_API_BASE_URL', defaultValue:
  'http://localhost:3000')`. Override it per run/build target, for example:

  ```bash
  # Android emulator: 10.0.2.2 is the emulator's loopback alias for the host machine
  flutter run --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:3000

  # Physical device or non-default backend host/port
  flutter run --dart-define=CUPID_API_BASE_URL=http://192.168.1.50:3000
  ```

## i18n / ARB Notes

- `app_vi.arb` is the template locale (`mobile/l10n.yaml`
  `template-arb-file`). A key present in `app_vi.arb` but missing from
  `app_en.arb` is reported as a gap in `mobile/l10n-untranslated.json`
  (checked by `mobile/test/l10n/arb_parity_test.dart`), never silently
  falls back.
- `flutter gen-l10n` runs automatically as part of `flutter pub get`
  (`generate: true` in `pubspec.yaml`) — no manual codegen step is needed
  after a clean checkout.
- New string keys are added to both `app_vi.arb` and `app_en.arb` in the
  same change; screen stories own their own copy (STORY-001 ships only a
  smoke key set).
