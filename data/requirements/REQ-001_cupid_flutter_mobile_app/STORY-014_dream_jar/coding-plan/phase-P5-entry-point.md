# Phase P5 – Discoverable Entry Point And DI Registration

## 1. Objective

Make Dream Jar reachable. Register the repository in `getIt` and mount a
discoverable "Dream Jar" Money card on `HomeScreen` that navigates to the jar
list, so the feature is not an orphaned module reachable only by direct route.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-entry-point.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2, P3, P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/di/service_locator.dart` (append one registration)
  - `mobile/lib/features/dream_jar/presentation/widgets/dream_jar_entry_card.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/lib/l10n/arb/app_en.arb`, `mobile/lib/l10n/arb/app_vi.arb` (append keys only)
  - `mobile/test/features/dream_jar/presentation/dream_jar_entry_card_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: the existing `Key('home_screen_ready_signal')` widget-test signal on `HomeScreen` must keep pumping
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `DreamJarEntryCard` mounted on `HomeScreen`
  - `getIt<DreamJarRepository>()` registration
- Shared Interfaces Consumed:
  - P1 `DreamJarRepository`, P3 `DreamJarListScreen`
  - `mobile/lib/core/di/service_locator.dart` `getIt` conventions, `mobile/lib/design_system/**`
- Risk Surfaces:
  - Entry-point discoverability
  - ARB key parity
  - Design-system compliance
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` entry-point paragraph before §1.1 (Money group card: `savings` icon, "Dream Jar" title, `{percent}% · {jarLabel}` subtitle)
  - consumer contract: `DreamJarListScreen` is the only Dream Jar entry route
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §4 `Boundaries And Ownership`, §4 `Risk Surfaces And Source Of Truth` (entry-point row)
  - OQ constraints: ADR-014a — the card must carry no encryption/lock/shield affordance
  - upstream phase outputs: P1 repository, P3 list screen (and, through it, P2 detail and P4 history)
  - UX constraints: the spec assumes the Money card already exists, which is true only in the HTML design prototype — `app_shell.dart` currently renders `HomeScreen` alone, so this phase must actually create the card
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: DI plus one discoverable navigation edge
  - Source/Test File Count: 2 new/edited source + 1 DI edit + 1 test (plus append-only ARB edits)
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §4 `Boundaries And Ownership`, §4 `Risk Surfaces And Source Of Truth`
- `../ux/uiux-spec.md` entry-point paragraph before §1.1, §4
- `mobile/lib/core/di/service_locator.dart`
- `mobile/lib/features/home/presentation/home_screen.dart`
- P3 `screens/dream_jar_list_screen.dart`

## 3. Tasks

- Register `DreamJarRepository` as a `registerLazySingleton` resolving `getIt<CupidApi>()`, following the existing registration style.
- Build `DreamJarEntryCard`: design-system card with the `savings` icon, localized "Dream Jar" title, a short localized subtitle, and an `onTap` that pushes `DreamJarListScreen`.
- Mount `DreamJarEntryCard` in `HomeScreen`'s body as a visible, tappable item. Preserve the existing `Key('home_screen_ready_signal')` readiness signal and the existing app bar.
- Give the card a stable `Key` so the reachability test does not depend on localized text.
- Do not add a bottom navigation bar, router package, or new shell abstraction; a `Navigator.push` from the Home card is the whole integration for this story.
- Append the new strings to both ARB files with matching keys.

## 4. Acceptance Criteria

- `HomeScreen` renders a visible Dream Jar card; tapping it pushes `DreamJarListScreen`.
- `getIt<DreamJarRepository>()` resolves after service-locator setup.
- The `Key('home_screen_ready_signal')` readiness signal still pumps, and existing home/widget tests pass unchanged.
- Dream Jar is reachable purely through UI interaction, with no direct-route-only access required.
- `app_en.arb` and `app_vi.arb` contain the same new keys; the card carries no encryption affordance.

## 5. Planned Outputs

- Code files: the paths listed in `Write Scope`
- Contracts: `DreamJarEntryCard`, `getIt<DreamJarRepository>()`
- Requirement configuration guide updates: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, home entry point and DI
- Required levels:
  - unit: service-locator resolution of `DreamJarRepository`
  - mobile build/type-check/static-analysis: `flutter analyze` clean for touched files
- Required checks: widget test finds the card by `Key` on `HomeScreen`, taps it, and asserts `DreamJarListScreen` is pushed
- Mobile discoverability / navigation integration: REQUIRED and owned by this phase — the entry card plus the navigation assertion is the gate that prevents an orphaned feature
- Minimum gates by risk surface: entry-point discoverability → the tap-and-navigate widget test; ARB parity → existing `test/l10n/arb_parity_test.dart`; design-system compliance → existing `test/design_system/` guards
- Required regression or contract coverage: `mobile/test/widget_test.dart` and any existing home-screen readiness test stay green
- Evidence format: concise rows in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/dream_jar test/widget_test.dart`
  - Static analysis: `flutter analyze`
  - Required assertion evidence: found card key, pushed route type, resolved DI instance

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Scope note: implemented as specified in §3 Tasks with two documented
  deviations:
  - `savings` is a new glyph, not yet in `mobile/lib/design_system/icons/cupid_icons.dart`
    (out of this phase's original Write Scope). Added it there (codepoint
    `0xe2eb`, confirmed against the bundled
    `MaterialSymbolsRounded-Variable.ttf` cmap via `fontTools`), matching prior
    phases' precedent of extending the shared icon file when a phase needs a
    glyph that does not exist yet.
  - The UX spec's dynamic `{percent}% · {jarLabel}` subtitle assumes Home
    already has jar data loaded; this phase's scope is only the discoverable
    navigation edge (no Home-level jar fetch), so the subtitle is static
    localized copy instead (`dream_jar_entry_card_subtitle`). Documented in the
    widget and `app_vi.arb` description metadata.
  - Added `mobile/test/features/home/home_screen_test.dart` (new file/new
    directory) in addition to the named
    `dream_jar_entry_card_test.dart`, to cover the tap-and-navigate
    reachability assertion required by §6 directly on `HomeScreen` (per the
    Scrum Master handoff's `WriteScope`, which included this test path).
- Implementation notes:
  - `getIt<DreamJarRepository>()` is registered in
    `mobile/lib/core/di/service_locator.dart` following the existing
    `registerLazySingleton` style, resolving `getIt<CupidApi>()`.
  - `DreamJarEntryCard` is a design-system card (`ClipRRect`/`Material`/
    `InkWell`, `CupidPlatformTokens.radiusCard`/`tapTarget`) with the
    `savings` icon, localized title/subtitle, and an `onTap` callback; it
    carries no encryption/lock/shield affordance (ADR-014a).
  - `HomeScreen` mounts the card below the existing
    `Key('home_screen_ready_signal')` text, inside the existing `AppBar`
    scaffold; `getIt<DreamJarRepository>()` is resolved lazily inside the
    `onTap` closure only, never during `build()`, so the pre-existing
    `test/widget_test.dart` (which pumps `CupidApp()` without calling
    `setupServiceLocator()`) is unaffected.
  - Both ARB files were edited additively only (2 new keys each); no existing
    key changed.
- Evidence:
  - `flutter test test/features/dream_jar/ test/features/home/ test/l10n/arb_parity_test.dart`
    — 74 tests passed, 0 failed.
  - `flutter test test/widget_test.dart` — 1 test passed (regression: app-boot
    readiness signal unaffected by the new card).
  - `flutter analyze lib test` — 19 pre-existing `info`-level
    `prefer_initializing_formals` lints in unrelated files
    (`fcm_transport.dart`, `realtime_coordinator.dart`, `socket_transport.dart`,
    `auth_repository.dart`, `splash_screen.dart`,
    `contribution_history_cubit.dart`); no error or warning on any file
    touched by this phase. The full-project `flutter analyze` run separately
    surfaces ~10,217 pre-existing issues from vendored
    `build/ios/SourcePackages/checkouts/flutterfire/**` build-cache files,
    unrelated to this phase and confirmed to contain none of the files
    touched here.
  - `git status --porcelain` in the story worktree shows only the five
    write-scope files (1 DI edit, 1 new widget, 1 home-screen edit, 2 ARB
    additive edits) plus the icon-file addition and the two new test files;
    no P1/P2/P3/P4 source file changed.
