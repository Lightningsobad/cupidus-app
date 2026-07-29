# Review Slice: P0+P1 Contract Layer (Tokens + Theme Assembly)

Scope: REQ-001/STORY-001, Slice 1 of scoped-slice review.
Reviewer: Iris-QC
BaseHead: 9b8b91da56f3df06d8001e93ee1c58b8d1a21975 (== current HEAD; all 10
slice files are new/untracked, so read directly rather than diffed).

Files reviewed (10):
- `mobile/lib/design_system/tokens/cupid_platform_tokens.dart`
- `mobile/lib/design_system/tokens/cupid_color_tokens.dart`
- `mobile/lib/design_system/tokens/cupid_typography_tokens.dart`
- `mobile/lib/design_system/tokens/cupid_spacing.dart`
- `mobile/lib/design_system/theme/cupid_platform.dart`
- `mobile/test/design_system/contrast_test.dart`
- `mobile/lib/design_system/theme/cupid_theme.dart`
- `mobile/lib/design_system/theme/cupid_theme_context.dart`
- `mobile/lib/design_system/design_system.dart`
- `mobile/test/design_system/theme_matrix_test.dart`

## AC 1 — Token set buildable for all 4 platform x theme combinations

**PASS.**

- `buildCupidTheme` (`cupid_theme.dart:14`) composes `CupidPlatformTokens`
  (`.ios()`/`.material()`), `CupidColorTokens` (`.dark()`/`.light()`), and
  `CupidTypographyTokens.forPlatform(platform)` into one `ThemeData`, with
  `colorScheme` fields derived from `colorTokens.*` (not literals) —
  satisfies the "no divergent palette" contract stated in the file's dartdoc.
- `theme_matrix_test.dart:17-33` iterates the full 2x2 (`CupidPlatform` x
  `Brightness`) cross product and asserts all 3 `ThemeExtension`s resolve
  non-null for each of the 4 combinations, plus `theme.brightness` matches.
  Manually counted test/testWidgets blocks in this file: 4 (combination loop)
  + 1 (platform tokens differ) + 1 (color tokens differ) + 1 (body font
  family) + 1 (font assets exist) + 1 (`CupidThemeContext` accessors) = 9,
  matching the "9/9 tests" claim in
  `coding-plan/test-results.md` P1 row exactly.
- Differentiation is asserted, not just presence: `radiusCard`/`tapTarget`
  differ iOS vs Material, `uiFontFamily` is `null` on iOS vs `'Roboto'` on
  Material (`theme_matrix_test.dart:35-54`); `colorBackground`/`colorSurface`
  differ dark vs light (`theme_matrix_test.dart:56-73`).
- Font assets declared in the test (`assets/fonts/Nunito-Variable.ttf`,
  `Roboto-Variable.ttf`, `RobotoMono-Variable.ttf`,
  `MaterialSymbolsRounded-Variable.ttf`) were independently confirmed present
  on disk under `mobile/assets/fonts/`.
- `CupidThemeContext` extension (`cupid_theme_context.dart`) provides
  `cupidPlatform`/`cupidColors`/`cupidType` getters reading
  `Theme.of(this).extension<T>()`, each with a debug-mode assert guarding
  against a missing extension — consistent with `theme_matrix_test.dart:117-146`
  confirming all three resolve inside a `MaterialApp` built via
  `buildCupidTheme`.
- `design_system.dart` barrel exports the theme/token files reviewed here
  (plus P2/P3 files out of this slice's scope), matching the "one barrel
  import" contract referenced in its own dartdoc.
- Test-results.md P0/P1 rows (`flutter analyze` clean, `contrast_test.dart`
  10/10, `theme_matrix_test.dart` 9/9) are cited evidence and were not
  re-run; the test counts were independently verified by reading and
  counting blocks in both files (both match exactly), so the cited PASS rows
  are corroborated, not just trusted at face value.

## ADR-004b — Light-accent contrast rule

**PASS.**

- `CupidColorTokens.light()` dartdoc (`cupid_color_tokens.dart:88-97`)
  documents that `colorAccentPink`, `colorAccentPinkDark`,
  `colorAccentPurple`, `colorAccentPurpleDark` fail 4.5:1 AA for
  normal/small text in light theme and restricts them to large
  text/icons/borders/focus rings/gradients/decorative use; each of the 4
  fields carries a `dartdoc` pointer back to this restriction
  (`cupid_color_tokens.dart:161-175`).
- `contrast_test.dart`'s tripwire group computes WCAG contrast ratios
  dynamically from the actual token `Color` values (not hardcoded ratio
  literals), so the test fails if a future edit silently changes a light
  accent value into an AA-passing one — this is a genuine tripwire, not a
  cosmetic check.
- Independently recomputed all 4 asserted ratios in Python from the exact
  ARGB literals in `cupid_color_tokens.dart` (WCAG relative-luminance
  formula), and all match the test's PASS boundaries:
  - light `colorAccentPink` (`#E8558F`) on light `colorSurface` (`#FFFFFF`)
    = 3.427 → within asserted `[3.0, 4.5)` ✓
  - dark `colorAccentPink` (`#FF7FB6`) on dark `colorSurface` (`#241B42`)
    = 6.840 → asserted `>= 4.5` ✓
  - dark `colorText` (`#F7EEFB`) on dark `colorBackground` (`#171129`)
    = 16.174 → asserted `>= 4.5` ✓
  - light `colorText` (`#3E2645`) on light `colorBackground` (`#FFF6FB`)
    = 12.645 → asserted `>= 4.5` ✓
- Manually counted `contrast_test.dart` test/testWidgets blocks: 4
  (contrast tripwire group) + 1 (token completeness) + 4 (lerp/copyWith
  group) + 1 (`CupidPlatformOverride` widget test) = 10, matching the
  "10/10 tests" claim in `coding-plan/test-results.md` P0 row exactly.

## ADR-004c — `colorAccentPurpleDark` light carry-over

**PASS.**

- `CupidColorTokens.light()` sets `colorAccentPurpleDark = Color(0xFF8E5FD6)`
  (`cupid_color_tokens.dart:114`), identical to the value in `.dark()`
  (`cupid_color_tokens.dart:50`) — confirms the documented "carry the dark
  value unchanged" decision was actually implemented, not just described.
- The inline comment (`cupid_color_tokens.dart:108-113`) states the design
  source has no light-theme override for this token, the carried value
  "measures ~4.4:1 on white — non-text-safe under ADR-004b," and instructs
  not to substitute a different value without a UI/UX Designer decision.
  Independently recomputed: `#8E5FD6` on `#FFFFFF` = 4.4136:1, matching the
  "~4.4:1" claim and correctly below the 4.5:1 AA threshold, consistent
  with the "non-text-safe" framing.
- The field-level dartdoc (`cupid_color_tokens.dart:173-175`) cross-references
  both ADR-004b and ADR-004c for this token, so the usage restriction and the
  design-source gap are both discoverable at the field, not only in the
  constructor-body comment.

## Other observations (non-blocking, no action required for this slice)

- `CupidPlatformTokens.copyWith` (`cupid_platform_tokens.dart:94-116`) and
  `CupidColorTokens.copyWith` follow the standard nullable-param `?? this.x`
  pattern correctly; spot-checked against `theme_matrix_test.dart`'s
  `copyWith overrides only the given fields` test — consistent.
- `cupid_platform.dart`'s `CupidPlatform.of` correctly prefers
  `CupidPlatformOverride.maybeOf(context)` before falling back to
  `resolveDefault()`, matching the P0 `CupidPlatformOverride` widget test's
  two-platform-on-one-device scenario.
- No color, radius, or platform-detection literal leakage was observed in
  the 10 reviewed files outside the documented token/theme layer itself.

## Summary

| Item | Status |
|---|---|
| AC 1 (4-combination buildability) | PASS |
| ADR-004b (light-accent contrast rule) | PASS |
| ADR-004c (`colorAccentPurpleDark` light carry-over) | PASS |

No FAIL or UNVERIFIED items in this slice. No blockers for Slice 1.

REVIEW_SLICE_COMPLETE: YES

Outcome: CLEAN
