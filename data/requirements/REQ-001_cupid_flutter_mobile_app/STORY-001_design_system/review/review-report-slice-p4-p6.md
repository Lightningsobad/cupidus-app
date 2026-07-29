# Review Slice: P4+P5+P6 — i18n/ARB, Flags/App Wiring, Final Verification

Scope: REQ-001/STORY-001, Slice 3 of scoped-slice review.
Reviewer: Iris-QC
BaseHead: 9b8b91da56f3df06d8001e93ee1c58b8d1a21975 (== HEAD; all reviewed
files are new/untracked, read directly rather than diffed, same as Slices 1-2).

Files reviewed (11):
- `mobile/l10n.yaml`
- `mobile/lib/l10n/arb/app_vi.arb`
- `mobile/lib/l10n/arb/app_en.arb`
- `mobile/test/l10n/arb_parity_test.dart`
- `mobile/lib/core/config/cupid_feature_flags.dart`
- `mobile/lib/app/cupid_app.dart`
- `mobile/lib/main.dart`
- `mobile/test/app/feature_flags_test.dart`
- `mobile/test/widget_test.dart`
- `mobile/test/design_system/no_fork_guard_test.dart`
- `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`

Supplementary files read to verify chained claims (not separately in the
handoff's file list, but load-bearing for AC2/AC3/runtime-smoke evidence):
`mobile/lib/core/navigation/app_shell.dart`,
`mobile/lib/features/home/presentation/home_screen.dart`,
`mobile/pubspec.yaml`, `mobile/lib/l10n/generated/app_l10n.dart`,
`mobile/l10n-untranslated.json`, `mobile/.gitignore`,
`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/story_master.md`
(AC2/AC3 exact text only — AC1/AC4 text and ADR-004b/c/d already loaded from
Slices 1-2, not reread).

## AC 2 — i18n ARB files exist for `vi`/`en`; app resolves strings via the ARB pipeline

**PASS.**

- `app_vi.arb` (`@@locale: "vi"`, template per `l10n.yaml`
  `template-arb-file`) and `app_en.arb` (`@@locale: "en"`) both declare the
  identical 3-key smoke set: `app_root_title`, `home_screen_greeting`,
  `common_actions_continue`. Confirmed by reading both files directly.
- Generated codegen output exists and is consistent with these ARB files:
  `lib/l10n/generated/app_l10n.dart` defines `AppL10n` with exactly these 3
  getters, `supportedLocales = [Locale('en'), Locale('vi')]`, and
  `lookupAppL10n` switching on both `en`/`vi` language codes — confirms
  `flutter gen-l10n` ran and both locales are wired into the delegate.
- `l10n-untranslated.json` (the ADR-004e drift gate) contains `{}` — an empty
  object confirms `app_en.arb` has zero missing keys relative to the
  `app_vi.arb` template, consistent with the two ARB files having identical
  key sets.
- `.gitignore` correctly excludes `/lib/l10n/generated/` and
  `/l10n-untranslated.json` as regenerated build output, with a comment
  documenting a specific `flutter_tools` path-resolution quirk
  (`_untranslatedMessagesFileFromPath` resolves relative to project root, not
  `output-dir`) — this is accurate, non-speculative tooling knowledge, not a
  copy-paste boilerplate comment.
- `arb_parity_test.dart` manually recounted: 1 (key-set-equality test) + 1
  (untranslated-file-empty test) + 2 (`AppL10n resolution` group:
  resolves-under-vi, resolves-under-en-and-differs-from-vi) = 4 blocks,
  matching the "4/4 tests" claim in `coding-plan/test-results.md` P4 row
  exactly. The vi/en-resolve-to-distinct-values assertion
  (`enL10n.home_screen_greeting, isNot(viGreeting)`) is a genuine
  differentiation check, not just a non-null check.

## AC 3 — v1 defaults to dark theme + `vi` only; light/`en` present but not user-selectable

**PASS.**

- `CupidFeatureFlags.enableLightTheme` / `.enableEnLocale`
  (`cupid_feature_flags.dart:7-15`) are both `const bool.fromEnvironment`
  with `defaultValue: false` — confirms the "off by default, no
  `--dart-define` needed for v1 default" contract.
- `CupidApp.build` (`cupid_app.dart:19-39`): `themeMode` is pinned
  `ThemeMode.dark` when `enableLightTheme` is false, else `ThemeMode.system`;
  `locale` is pinned `const Locale('vi')` when `enableEnLocale` is false,
  else `null` with a custom `localeResolutionCallback` that follows the
  device locale and falls back to `vi` (not the arbitrary first
  `supportedLocales` entry, which is `en` — this ordering detail matters and
  is handled correctly). When `locale` is explicitly set (flag off), Flutter
  ignores `localeResolutionCallback` and device locale entirely, so the
  dark+`vi` default is deterministic, not merely device-dependent.
- Existence is never gated: `supportedLocales`/`localizationsDelegates`
  always register both `en` and `vi` regardless of flag state (confirmed
  above under AC2), and light `ThemeData` is always passed to
  `MaterialApp.theme` — only `themeMode`/`locale` selection is gated. This
  matches OQ5's "gates exposure not existence" resolution exactly.
- `configuration-guide.md` confirms there is no in-app settings picker at
  v1 ("this is a developer/QA override only"), which is what makes light
  theme/`en` locale "not user-selectable" in practice, not just in the flag
  default — the two `--dart-define` keys are documented with defaults,
  effects, and QA commands for all 3 non-default combinations.
- `feature_flags_test.dart` manually recounted: 1 (flags default false) + 1
  (`CupidApp` resolves dark+`vi` with flags off, `Key('home_screen_ready_signal')`
  resolves) + 1 (light `ThemeData` directly constructible with flags off) +
  1 (`AppL10n` under `Locale('en')` directly constructible with flags off) =
  4 blocks, matching the "4/4 tests" claim in `test-results.md` P5 row
  exactly. The last two tests are the ones that actually prove
  "exists-but-not-exposed" rather than merely "flag defaults to false."

## AC 4 source-scan guard — `no_fork_guard_test.dart`

**PASS.**

- Guard definition matches `architecture/solution.md`'s stated scan boundary
  exactly (already loaded from Slice 2, not reread): guarded directories
  `lib/features`, `lib/app`, `lib/core`; forbidden substrings `Color(0x`,
  `Colors.`, `Platform.is`, `defaultTargetPlatform`. `lib/design_system/`
  itself is correctly excluded from the scan (that's the layer allowed to
  hold these patterns).
- Independently spot-checked every P4-P6-scope file against these 4
  patterns by reading them directly: `cupid_app.dart`, `main.dart`,
  `app_shell.dart`, `home_screen.dart`, `cupid_feature_flags.dart` — none
  contain any of the 4 forbidden substrings. `cupid_app.dart` uses
  `CupidPlatform.of(context)` for platform resolution, which does not match
  the `Platform.is` pattern (that pattern targets `dart:io`'s
  `Platform.isIOS`/`isAndroid`, a materially different API).
- The test currently passes because the violation list is empty by
  construction, not because the check is weak — the invariant under test is
  "these directories contain zero forbidden patterns," and an empty
  violation list is the correct passing condition for that invariant, not a
  vacuous/no-op test. 1 test block, matching the "1/1 tests" claim in
  `test-results.md` P6 row.

## Story-level runtime startup smoke

**PASS.**

- Traced the full boot chain by reading each file in sequence: `main.dart`
  (`runApp(const CupidApp())`) → `cupid_app.dart` (`MaterialApp(..., home:
  const AppShell())`) → `app_shell.dart` (`return const HomeScreen();`) →
  `home_screen.dart` (`Scaffold` with a `Text` carrying
  `key: Key('home_screen_ready_signal')`). The chain is unbroken and every
  link was read directly, not inferred from test-results.md's claim alone.
- Both `widget_test.dart` and `feature_flags_test.dart` independently pump
  `CupidApp` and assert `find.byKey(const Key('home_screen_ready_signal'))`
  resolves — this is intentional redundant coverage of the same boot
  assertion in two files, not a defect, though it's a minor duplication
  worth collapsing into one canonical smoke test if this file set is touched
  again (non-blocking).
- Cross-check on the full-suite count: summing every phase's independently
  recounted test blocks across all 3 slices — P0 10 + P1 9 + P2 5 + P3 8 +
  P4 4 + P5 4 + P6 1 = 41, plus `widget_test.dart`'s own 1 test = 42,
  matching the "Full `flutter test` 42/42 passed" claim in `test-results.md`
  and the Scrum Master checkpoint exactly. This is an independent
  cross-check computed from files actually read across all 3 review slices,
  not a re-citation of the same claim.

## Summary

| Item | Status |
|---|---|
| AC 2 (i18n ARB files exist, ARB pipeline resolves both locales) | PASS |
| AC 3 (v1 defaults dark+`vi`, light/`en` present but gated, not user-selectable) | PASS |
| AC 4 source-scan guard (`lib/features`/`lib/app`/`lib/core` clean) | PASS |
| Story-level runtime startup smoke (`home_screen_ready_signal` resolves) | PASS |

No FAIL or UNVERIFIED items in this slice. One non-blocking observation:
`widget_test.dart` and `feature_flags_test.dart` duplicate the same boot
assertion — not a blocker, just a minor test-suite tidiness note. This is a
slice-scoped verdict for the 11 files in this slice only, not the full story
verdict — final-synthesis still owns combining this with Slices 1-2,
including the carried-forward ADR-004d single-icon-family FAIL from Slice 2.

REVIEW_SLICE_COMPLETE: YES

Outcome: CLEAN
