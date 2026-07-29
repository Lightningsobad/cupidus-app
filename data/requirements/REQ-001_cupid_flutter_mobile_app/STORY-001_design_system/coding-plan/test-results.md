# Test Results — REQ-001 / STORY-001 Design System

Evidence rows are appended by each phase's owning specialist per
`coding-plan/phase-Px-*.md` section 6 Evidence format. This file accumulates
across P0–P6; do not remove prior-phase rows when adding new ones.

## P0 — Design Tokens

| Date | Command | Result | Notes |
|------|---------|--------|-------|
| 2026-07-29 | `flutter analyze` | PASS — No issues found! | Clean across all 6 P0 Write Scope files. |
| 2026-07-29 | `flutter test test/design_system/contrast_test.dart` | PASS — 10/10 tests | All 4 ADR-004b contrast tripwire assertions pass: light `colorAccentPink`/`colorSurface` ratio in `[3.0, 4.5)`; dark `colorAccentPink`/`colorSurface` ratio `>= 4.5`; dark and light `colorText`/`colorBackground` ratios both `>= 4.5`. Additional groups also pass: token completeness (every `.dark()`/`.light()`/`.ios()`/`.material()` field non-null per design), `copyWith`/`lerp` endpoint checks on all 3 `ThemeExtension`s, and `CupidPlatformOverride` widget test. |

Acceptance Criteria 4 (source, `phase-P0-tokens.md` section 4):

- Every token name/value in UX sections 2–4 has exactly one corresponding
  field; no invented values other than ADR-004c (`colorAccentPurpleDark`
  light carry-over) — MET.
- All three extensions (`CupidPlatformTokens`, `CupidColorTokens`,
  `CupidTypographyTokens`) implement `copyWith` and `lerp` — MET.
- `CupidPlatformOverride` lets a test render either platform regardless of
  the host device — MET (see `CupidPlatformOverride` widget test).
- Contrast tripwire test passes and fails if a light accent value is changed
  to something that silently claims AA compliance — MET.
- `flutter analyze` is clean — MET.

## P1 — Theme Assembly, Fonts, And Import Surface

| Date | Command | Result | Notes |
|------|---------|--------|-------|
| 2026-07-29 | `flutter analyze` | PASS — No issues found! | Clean across all 6 P1 Write Scope files. |
| 2026-07-29 | `flutter test test/design_system/theme_matrix_test.dart` | PASS — 9/9 tests | 4-combination matrix (`ios`/`material` x `dark`/`light`) each resolves all 3 extensions; platform tokens differ `ios` vs `material`; color tokens differ `dark` vs `light`; `body` text style picks up platform `uiFontFamily`; declared font assets exist on disk; `CupidThemeContext` accessors (`cupidColors`/`cupidPlatform`/`cupidType`) resolve. |

Acceptance Criteria (source, `phase-P1-theme-assembly.md` section 4):

- `buildCupidTheme` produces a valid `ThemeData` for all four combinations
  without throwing — MET (4-combination matrix test).
- All three extensions resolve non-null from every produced `ThemeData` —
  MET.
- `colorScheme` values trace back to `CupidColorTokens` fields, not
  hardcoded literals — MET (`cupid_theme.dart` derives `ColorScheme` fields
  from `colorTokens.*`).
- Fonts resolve from bundled assets with no network access — MET (declared
  font assets exist on disk, checked by test; no `google_fonts` or runtime
  font-fetch dependency added).
- `flutter analyze` is clean — MET.

Non-blocking finding (recorded for P5): Material Symbols Rounded variable
font is ~15MB on disk (larger than `solution.md`'s ~1-2MB estimate),
raising the likelihood `--no-tree-shake-icons` would be required. Resolved
at P6: the registry `flutter build apk --debug` gate succeeded without that
flag (debug builds do not tree-shake icons; the flag remains documented in
the configuration guide as a release-build fallback).

## P2 — Icon Family And Variant Tokens

| Date | Command | Result | Notes |
|------|---------|--------|-------|
| 2026-07-29 | `flutter analyze` | PASS — No issues found! | Clean across all 4 P2 Write Scope files. |
| 2026-07-29 | `flutter test test/design_system/icon_variant_test.dart` | PASS — 5/5 tests | All 3 `CupidIconVariant` axis mappings assert exact values (`filled` = FILL 1/wght 400/GRAD 0/opsz 24; `line` = FILL 0/wght 350/GRAD 0/opsz 24; `soft` = FILL 1/wght 300/GRAD -25/opsz 24); `CupidIcon` renders inside a `buildCupidTheme` wrapper with no missing-extension assertion; `CupidIcon` default color derives from `context.cupidColors`, not a literal. |

Acceptance Criteria (source, `phase-P2-icons.md` section 4):

- All three variants map to the exact axis values in UX section 2 — MET.
- No platform branching exists in `icons/` — MET (confirmed again at P6 by
  the AC 4 no-fork guard, which does not flag `design_system/` at all since
  it is the one exempted directory).
- No color literal appears in `icons/`; colors come from the theme — MET.
- `flutter analyze` is clean — MET.

## P3 — The Four Named Adaptive Widgets

| Date | Command | Result | Notes |
|------|---------|--------|-------|
| 2026-07-29 | `flutter analyze` | PASS — No issues found! | Clean across all 6 P3 Write Scope files. |
| 2026-07-29 | `flutter test test/design_system/adaptive_widgets_test.dart` | PASS — 8/8 tests | Both-platform coverage for all 4 widgets: `CupidTabBar` (iOS/Material, `tapTarget`-sized items), `CupidHeader` (iOS chevron+text back affordance vs Material arrow-only), `CupidPrimaryButton` (iOS pill `radiusButton`=999 vs Material 20dp CTA corner radius), `CupidAddAction` (iOS icon button vs Material FAB). |

Acceptance Criteria (source, `phase-P3-adaptive-widgets.md` section 4):

- Each widget renders both platform variants correctly under
  `CupidPlatformOverride` — MET.
- Behavior matches UX section 6 for all four categories — MET.
- No color, radius, or spacing literal appears in `adaptive/` — MET, with
  two sourced/documented sanctioned-literal exceptions (iOS tab icon 26pt /
  label 10pt; Material CTA corner radius 20dp) transcribed verbatim from UX
  section 6, since no token field maps to those exact values (same pattern
  as ADR-004c's `skyGradient`).
- Minimum hit target is satisfied on every interactive element — MET
  (`tapTarget`-sized `ConstrainedBox`/`SizedBox` wrapping every interactive
  element, asserted by the widget tests).
- `flutter analyze` is clean — MET.

Non-blocking note carried forward for Reviewer: structural platform
branching uses `CupidPlatform.of(context)` (the override-aware resolver)
while `context.cupidPlatform` is used only for token values — both honor
`CupidPlatformOverride`; neither reads `Platform.is*`/`defaultTargetPlatform`
directly.

## P4 — i18n / ARB Pipeline

| Date | Command | Result | Notes |
|------|---------|--------|-------|
| 2026-07-29 | `flutter pub get` (triggers `flutter gen-l10n` codegen) | PASS | Clean; generated `AppL10n` at `lib/l10n/generated/app_l10n.dart`. |
| 2026-07-29 | `flutter analyze` | PASS — No issues found! | Clean, including the generated `AppL10n` output (`// ignore_for_file: type=lint`). |
| 2026-07-29 | `flutter test test/l10n/` | PASS — 4/4 tests | `app_vi.arb`/`app_en.arb` declare identical key sets; `l10n-untranslated.json` is empty after generation; `AppL10n` resolves the 3 smoke keys under `Locale('vi')`; resolves under `Locale('en')`, asserted distinct from `vi`. |

Acceptance Criteria (source, `phase-P4-i18n-arb.md` section 4):

- `AppL10n` is generated and resolves the smoke keys in both `vi` and `en`
  — MET.
- `vi` is the template locale, so a missing `en` translation is reported
  rather than silently falling back — MET (`app_vi.arb` is
  `template-arb-file`; parity test enforces symmetry).
- `l10n-untranslated.json` is empty after generation — MET.
- Both ARB files contain identical key sets — MET.
- Generated output is gitignored and reproducible from a clean checkout —
  MET.
- `flutter analyze` is clean — MET.

Non-blocking note: `l10n.yaml`'s `synthetic-package: false` (named in the
phase task text) was omitted — the installed Flutter SDK reports it as a
deprecated no-op ("no longer has any effect and should be removed"). All
other `l10n.yaml` keys match the task text exactly.

## P5 — Enablement Flags, App Wiring, And Configuration Guide

| Date | Command | Result | Notes |
|------|---------|--------|-------|
| 2026-07-29 | `flutter analyze` | PASS — No issues found! | Confirms zero dangling `AppTheme` references after its removal. |
| 2026-07-29 | `flutter test test/app/` | PASS — 4/4 tests | `CupidFeatureFlags` both default `false`; `CupidApp` resolves `themeMode: ThemeMode.dark` and `locale: Locale('vi')` with flags off, and `Key('home_screen_ready_signal')` resolves; light `ThemeData` is directly constructible with flags off; `AppL10n` under `Locale('en')` is directly constructible with flags off. |

Acceptance Criteria (source, `phase-P5-flags-and-app-wiring.md` section 4):

- Both flags default to `false` with no `--dart-define` supplied — MET.
- With flags off, the app resolves to dark theme and `vi` locale — MET.
- Light `ThemeData` and the `en` locale remain directly constructible in
  tests with flags off — MET (flags gate exposure, never existence, per
  OQ5).
- `AppTheme` is fully removed with no dangling references — MET (`git rm`
  deletion; `flutter analyze` clean confirms no undefined-identifier
  reference remains).
- `Key('home_screen_ready_signal')` still resolves — MET.
- The configuration guide exists and documents both flag keys, the QA
  command, and the tree-shake fallback — MET
  (`deployment/configuration-guide.md`, created this phase).
- `flutter analyze` is clean — MET.

## P6 — Verification

| Date | Command | Result | Notes |
|------|---------|--------|-------|
| 2026-07-29 | `flutter test` (full suite) | PASS — 42/42 tests | All P0–P6 suites green in one run: `contrast_test.dart` (10), `theme_matrix_test.dart` (9), `icon_variant_test.dart` (5), `adaptive_widgets_test.dart` (8), `arb_parity_test.dart` (4), `feature_flags_test.dart` (4), `no_fork_guard_test.dart` (1), `widget_test.dart` (1). |
| 2026-07-29 | `flutter analyze` | PASS — No issues found! | Clean across the full `mobile/lib` and `mobile/test` trees. |
| 2026-07-29 | `flutter build apk --debug` (registry `mobile-app` `buildCommand`) | PASS — `build/app/outputs/flutter-apk/app-debug.apk` built | No `--no-tree-shake-icons` flag needed for a debug build (debug builds do not tree-shake icons); the flag stays documented in the configuration guide as the release-build fallback per the P1 ~15MB font-size finding. |
| 2026-07-29 | `flutter test test/design_system/no_fork_guard_test.dart` | PASS — 1/1 test | AC 4 source-scan guard: scans `lib/features/`, `lib/app/`, `lib/core/` (recursive) for `Color(0x`, `Colors.`, `Platform.is`, `defaultTargetPlatform`. Zero violations today — passes vacuously as designed; the guard itself is the deliverable that protects the 31 later screens from forking off the shared widget tree. |

Verification tasks (source, `phase-P6-verification.md` section 3):

- `master-plan.md` uses the required Phase Overview table schema — MET
  (section 5, all 10 required columns present for P0–P6).
- Every listed phase has exactly one canonical `phase-Px-*.md` file, no
  duplicates — MET (7 files on disk, `phase-P0-tokens.md` ...
  `phase-P6-verification.md`, one-to-one with the `master-plan.md` Phase
  file mapping table).
- AC 4 source-scan guard authored and runs as part of `flutter test` — MET.
- Full mobile test suite, static analysis, and registry build gate all run
  and recorded — MET (rows above).

### Risk-Surface Gate Summary (`architecture/solution.md` Risk Surfaces And Verification Contract)

| Risk Surface | Gate | Status |
|---|---|---|
| 4-combination completeness (AC 1) | `theme_matrix_test.dart` 4-combination matrix (P1) | PASS |
| Light-accent contrast (ADR-004b) | `contrast_test.dart` contrast tripwire (P0) | PASS |
| Locale parity (AC 2) | `arb_parity_test.dart` key-parity + both-locale resolution + empty `l10n-untranslated.json` (P4) | PASS |
| No-fork discipline (AC 4) | `no_fork_guard_test.dart` source-scan guard over `lib/features/`, `lib/app/`, `lib/core/` (P6) | PASS |
| Flag behavior (AC 3) | `feature_flags_test.dart` defaults + `CupidApp` dark/`vi` widget test + light/`en` direct-construction tests (P5) | PASS |
| Font/icon asset bundling (ADR-004d) | registry `flutter build apk --debug` (P6) | PASS — no tree-shake flag required for debug; fallback documented for release |

### AC 1–4 Traceability (`story_master.md`)

| AC | Requirement | Passing Gate |
|---|---|---|
| AC 1 | Token set buildable for all 4 platform x theme combinations | `theme_matrix_test.dart` 4-combination matrix (P1) |
| AC 2 | i18n ARB files exist for `vi`/`en`; app resolves strings in either locale | `arb_parity_test.dart` (P4) |
| AC 3 | v1 defaults to and only exposes dark + `vi`; light/`en` remain present and switchable behind a flag | `feature_flags_test.dart` (P5) |
| AC 4 | No screen-specific forking; platform variance stays inside the 4 named adaptive widgets | `adaptive_widgets_test.dart` (P3) both-platform coverage + `no_fork_guard_test.dart` (P6) source-scan guard |

### Story-Level Runtime Startup Smoke

`Key('home_screen_ready_signal')` (registry `mobile-app` readiness signal,
widget-test based, not an HTTP probe) resolves under the full `flutter
test` run — confirmed in the `widget_test.dart` row above and separately in
the P5 `feature_flags_test.dart` `CupidApp` widget test.

### Review-Rework: ADR-004d Single-Icon-Family Fix

Review gate returned `PATCH_REQUIRED` for one scoped finding: two P3
adaptive widgets (`cupid_header.dart`, `cupid_add_action.dart`) used
Flutter's stock `Icons` class (bundled `MaterialIcons` font) at 4 call
sites instead of the single `Material Symbols Rounded` family mandated by
ADR-004d.

Fix: added 3 named constants to `cupid_icons.dart`
(`CupidIcons.chevronLeft`, `CupidIcons.arrowBack`, `CupidIcons.add`) —
codepoints read directly from the bundled
`MaterialSymbolsRounded-Variable.ttf` cmap via `fontTools` (0xe5cb, 0xe5c4,
0xe145 respectively; not invented from memory of a different icon font's
PUA range). Swapped all 4 call sites (`cupid_header.dart:110,166`,
`cupid_add_action.dart:35,48`) from `Icons.*` to `CupidIcons.*`, keeping
the same `Icon(...)`/`IconButton` structure, explicit `colorAccentPink`
tinting, and no size/variant change — a font-family swap only, not a
visual redesign. Collateral fix: `adaptive_widgets_test.dart`'s 3
`find.byIcon(Icons.*)` assertions updated to `find.byIcon(CupidIcons.*)`
to match (they had been asserting on the pre-fix, wrong font family).

Evidence: `flutter analyze` — "No issues found!". Full `flutter test` —
42/42 passed (no regressions; same total as before, since this was an
in-place assertion fix, not a new test). Changed files:
`mobile/lib/design_system/icons/cupid_icons.dart`,
`mobile/lib/design_system/adaptive/cupid_header.dart`,
`mobile/lib/design_system/adaptive/cupid_add_action.dart`,
`mobile/test/design_system/adaptive_widgets_test.dart`.

### Handoff To Reviewer

All 6 phases (P0–P5) plus this verification phase (P6) are DONE, and the
ADR-004d review-rework finding above is resolved. No blocked gates. No
critical regressions. Two non-blocking notes are carried forward from P3
and P4 respectively (see those sections above) for Reviewer awareness;
neither affects a passing gate. The story is ready for re-review of the
touched files.
