# Review Slice: P2+P3 Icons + Adaptive Widgets

Scope: REQ-001/STORY-001, Slice 2 of scoped-slice review.
Reviewer: Iris-QC
BaseHead: 9b8b91da56f3df06d8001e93ee1c58b8d1a21975 (== HEAD; all 8 slice files
are new/untracked, read directly rather than diffed, same as Slice 1).

Files reviewed (8):
- `mobile/lib/design_system/icons/cupid_icons.dart`
- `mobile/lib/design_system/icons/cupid_icon.dart`
- `mobile/test/design_system/icon_variant_test.dart`
- `mobile/lib/design_system/adaptive/cupid_tab_bar.dart`
- `mobile/lib/design_system/adaptive/cupid_header.dart`
- `mobile/lib/design_system/adaptive/cupid_primary_button.dart`
- `mobile/lib/design_system/adaptive/cupid_add_action.dart`
- `mobile/test/design_system/adaptive_widgets_test.dart`

Conditional input read: `architecture/solution.md` ADR-004d (and surrounding
§2/§4 contract text for the adaptive-widget invariant and the AC4 source-scan
guard's exact scan boundary).

## AC 4 — Widget-layer contract (no literal leakage outside `design_system/`, both-platform coverage)

**PASS**, with one minor non-blocking documentation gap noted below.

- All 4 widgets resolve platform via `CupidPlatform.of(context)` for
  structural branching (`cupid_tab_bar.dart:46`, `cupid_header.dart:42`,
  `cupid_primary_button.dart:33`, `cupid_add_action.dart:24`) — none reads
  `Platform.is*`/`defaultTargetPlatform` directly, matching
  `solution.md`'s AC4 source-scan guard boundary ("no `Color(0x`, `Colors.`,
  `Platform.is`, or `defaultTargetPlatform` outside `lib/design_system/`" —
  note this guard's scope is screens/features, not `design_system/` itself,
  so these 4 files being the *only* platform-branching files in the repo is
  the actual invariant, and that holds here: solution.md §4 explicitly names
  exactly these four as "the only files in the repo allowed to branch on
  `CupidPlatform`").
- Radius/spacing tokens are consumed from `CupidPlatformTokens`/`CupidSpacing`
  throughout (`platformTokens.radiusButton`, `.tapTarget`, `.safeTop`,
  `CupidSpacing.xs/sm/md`), not raw literals, with exactly the two
  documented/sourced exceptions already verified by P3 test-results.md and
  re-confirmed here: `_iosTabIconSize = 26` / `_iosTabLabelSize = 10`
  (`cupid_tab_bar.dart:22,25`, dartdoc cites `ux/uiux-spec.md` §6 "Tab bar"
  row, no token field covers it) and `_materialPrimaryCtaRadius = 20`
  (`cupid_primary_button.dart:14`, dartdoc cites §6 "Primary CTA" row).
  Matches the pattern ADR-004c set for `colorAccentPurpleDark`.
- Colors are consumed from `CupidColorTokens` (`colors.colorAccentPink`,
  `colors.colorText`, `colors.colorSurface`, `colors.colorLine`), not raw
  `Color(0x...)` literals, in all 4 widgets.
- Both-platform test coverage confirmed and test count independently
  recounted: `adaptive_widgets_test.dart` has 2 `testWidgets` per widget x 4
  widgets = 8 blocks, matching the "8/8 tests" claim in
  `coding-plan/test-results.md` P3 row exactly. Coverage includes: iOS/vs-Material
  tap-target sizing for `CupidTabBar` (`>=44` iOS / `>=48` Material, matching
  `CupidPlatformTokens.ios()/.material()` `tapTarget` values), iOS
  chevron+label vs Material arrow-only back affordance for `CupidHeader`,
  iOS pill (`radiusButton`=999) vs Material 20dp corner radius for
  `CupidPrimaryButton`, iOS icon-button vs Material FAB for `CupidAddAction`.

**Minor non-blocking note:** `cupid_tab_bar.dart:57` and `:128` use
`colors.colorSurface.withAlpha(217)` and `colors.colorAccentPink.withAlpha(38)`
for the iOS translucent tab-bar background and the Material selected-pill
tint. Unlike the two radius/size exceptions above, these alpha literals carry
no sourcing comment (no UX-spec citation, no "no token field covers this"
note). They don't introduce a new raw color (hue still derives from a
`CupidColorTokens` field), so they're not a `Color(0x...)` leak the AC4 guard
targets, but they're inconsistent with this story's own documentation
convention for undocumented literals. Suggest a one-line sourcing comment if
touched again; not a blocker for this story.

## ADR-004d — Icon family and variant axis mapping

**Variant axis mapping: PASS. Single-icon-family principle: FAIL** for 2 of
the 4 adaptive widgets.

**Axis mapping (PASS):** `CupidIconVariant` (`cupid_icon.dart:9-30`) maps
exactly to `solution.md` ADR-004d's cited source values (verified against the
`ux/uiux-spec.md`-derived axis table in `icon_variant_test.dart`, which itself
matches `story_master.md`/`test-results.md` claims):
`filled(fill:1, weight:400, grade:0, opticalSize:24)`,
`line(fill:0, weight:350, grade:0, opticalSize:24)`,
`soft(fill:1, weight:300, grade:-25, opticalSize:24)`. `CupidIcon` passes
these through to `Icon(..., fill:, weight:, grade:, opticalSize:)` unmodified
(`cupid_icon.dart:53-61`), and defaults `color` to
`context.cupidColors.colorText` rather than a literal. `icon_variant_test.dart`
independently recounted: 3 (axis-mapping group) + 2 (`Required checks` group)
= 5 tests, matching the "5/5 tests" claim in `test-results.md` P2 row exactly.

**Single-icon-family principle (FAIL):** `solution.md` ADR-004d's decision is
"Adopt Material Symbols Rounded on both platforms for v1," with explicit
rationale "a second icon set would add a fifth platform fork point and
contradict D3." `cupid_icons.dart`'s own dartdoc restates this: "no second
icon package, no platform-specific icon set." However, two of the four
adaptive widgets hardcode Flutter's stock `Icons` class (the bundled
"MaterialIcons" font shipped with the Flutter SDK) instead of
`CupidIcon`/`CupidIcons.fontFamily` (Material Symbols Rounded):
- `cupid_header.dart:110` — `Icon(Icons.chevron_left, color: colors.colorAccentPink)`
- `cupid_header.dart:166` — `Icon(Icons.arrow_back)`
- `cupid_add_action.dart:35` — `Icon(Icons.add, color: colors.colorAccentPink)`
- `cupid_add_action.dart:48` — `Icon(Icons.add)`

`Icons.*` is a materially different bundled font from
`'Material Symbols Rounded'` (`CupidIcons.fontFamily`) — this is exactly the
"second icon package" ADR-004d rules out, and it appears inside the two of
the four widgets solution.md names as the sole sanctioned platform-fork
points for the entire 31-screen codebase. `CupidTabBar` is unaffected (its
`icon` field is caller-supplied `IconData`, not chosen by the widget itself;
`adaptive_widgets_test.dart` supplies `Icons.home`/`Icons.favorite` only as
test fixture data, which is a separate, lower-severity concern since it's not
production code). `CupidPrimaryButton` has no icon usage.

No dartdoc, ADR reference, or `--no-tree-shake-icons`-style documented
exception justifies this deviation anywhere in the 8 reviewed files or in
`solution.md`. `test-results.md` P2/P3 rows do not mention icon-family
consistency in `adaptive/` at all — only variant-axis mapping (P2) and
color/radius/spacing literal-scanning (P3) were checked, so this gap was not
caught by the existing test suite (the AC4 no-fork source-scan guard also
does not catch it, since that guard scans `lib/features/`, `lib/app/`,
`lib/core/` and explicitly excludes `lib/design_system/` itself). Since these
four widgets are the reusable foundation every future screen story is
expected to consume unmodified, an uncorrected icon-family inconsistency here
would propagate a second icon package into the codebase from its very
origin point — recommend routing back to Mobile Developer for a fix (swap the
4 call sites to `CupidIcon`/raw `IconData(codePoint, fontFamily:
CupidIcons.fontFamily)` glyphs) before this slice closes out, or an explicit
Tech Lead sanctioned-exception decision if there's a reason (e.g. glyph
availability gap in the bundled variable font) not reflected in the current
docs.

## Carried-forward non-blocking note (P3): `CupidPlatform.of(context)` vs `context.cupidPlatform`

**Clarified, not blocking** (per the handoff's own instruction: report but
don't treat as blocking unless it actually breaks the contract — it does not
in current code).

- `CupidPlatform.of(context)` (used for structural branching in all 4
  widgets) does dynamically consult `CupidPlatformOverride` first
  (`cupid_platform.dart:18-20`: `CupidPlatformOverride.maybeOf(context) ??
  resolveDefault()`) — confirmed correct.
- `context.cupidPlatform` (used only for token values: `radiusButton`,
  `tapTarget`, `safeTop`, etc.) is a `ThemeExtension` lookup
  (`Theme.of(this).extension<CupidPlatformTokens>()`,
  `cupid_theme_context.dart:12-22`). It does **not** itself query
  `CupidPlatformOverride` — its value is fixed by whichever `platform` was
  passed to `buildCupidTheme(...)` when the enclosing `ThemeData` was built,
  independent of any `CupidPlatformOverride` ancestor. The test-results.md
  P3 phrasing "both honor `CupidPlatformOverride`" is imprecise at the
  mechanism level: `context.cupidPlatform` only *appears* to honor the
  override because every current call site (the widget tests' `_harness()`
  in `adaptive_widgets_test.dart:5-13`, and by extension any real caller
  following the same convention) always pairs `CupidPlatformOverride
  (platform: p)` with `buildCupidTheme(platform: p, ...)` using the same `p`.
  This is a correct and consistent convention today (no test or code path
  decouples the two), so it does not break AC 4 or any current test, but a
  future caller that sets `CupidPlatformOverride` without also rebuilding the
  theme for the same platform would get a widget that renders the *token
  values* (radius/tap-target/safe-area) for one platform while branching
  structurally for another. Worth a one-line dartdoc clarification on
  `context.cupidPlatform` or `CupidPlatformOverride` if a screen story hits
  this; not a fix required for this story.

## Summary

| Item | Status |
|---|---|
| AC 4 (no literal leakage outside `design_system/`, both-platform coverage) | PASS (1 minor non-blocking doc gap: undocumented alpha literals in `cupid_tab_bar.dart`) |
| ADR-004d — variant axis mapping (FILL/wght/GRAD/opsz) | PASS |
| ADR-004d — single icon family / no second icon package | **FAIL** — `Icons.chevron_left`/`Icons.arrow_back`/`Icons.add` used in `cupid_header.dart` and `cupid_add_action.dart` instead of `CupidIcon`/Material Symbols Rounded |
| Carried-forward note: `CupidPlatform.of` vs `context.cupidPlatform` override handling | Clarified — accurate for `CupidPlatform.of`; `context.cupidPlatform` doesn't itself query the override but is kept in sync by current call-site convention; not currently blocking |

One FAIL item in this slice (ADR-004d single-icon-family principle). Not
returning a story-level `Outcome:` per scope — flagging this FAIL for
final-synthesis / Mobile Developer follow-up.

REVIEW_SLICE_COMPLETE: YES
