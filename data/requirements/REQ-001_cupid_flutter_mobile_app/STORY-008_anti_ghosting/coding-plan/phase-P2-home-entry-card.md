# Phase P2 – Home Entry Card And Discoverable Navigation Mount

## 1. Objective

Make the Anti-Ghosting settings screen reachable through a discoverable home
surface, so the capability is not an orphaned feature, without disturbing the
runtime readiness signal that `HomeScreen` currently carries.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-home-entry-card.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart`
  - `mobile/lib/features/anti_ghosting/anti_ghosting.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart` (additive only)
  - `mobile/test/features/anti_ghosting/presentation/anti_ghost_entry_card_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A for this phase
  - Readiness Check: registry `mobile-app.readiness.widgetKey` =
    `home_screen_ready_signal`, which this phase must preserve
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `AntiGhostEntryCard`
  - `anti_ghosting.dart` feature barrel (the export surface STORY-007 consumes)
- Shared Interfaces Consumed:
  - `AntiGhostCubit`, `AntiGhostScreen` (P1)
  - `GhostConfigRepository` (P0) via `get_it`
  - `CupidColorTokens`, `CupidIcon`
- Risk Surfaces:
  - Runtime readiness key
  - Design-system no-fork guard
  - Cross-story merge surface (`home_screen.dart`)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §2.1;
    `../architecture/solution.md` §3 Assumption 2 and §7
  - consumer contract: the card's subtitle reflects the real lifecycle state and
    routes to the review state when the partner is the proposer
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC3
  - architecture: `../architecture/solution.md` §3 Assumption 2, §4 Affected
    Components, §7 risk table
  - OQ constraints: none
  - upstream phase outputs: P1 `AntiGhostCubit` state contract and `AntiGhostScreen`
  - UX constraints, if truly required: `../ux/uiux-spec.md` §2.1 (card states and
    amber pending badge), §3 (tap target), §4 (no colour-only signalling)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: one entry card plus its mount and export surface
  - Source/Test File Count: 4
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../architecture/solution.md` §3 Assumption 2, §7
- `../ux/uiux-spec.md` §2.1
- P1 outputs: `anti_ghost_cubit.dart`, `screens/anti_ghost_screen.dart`
- `mobile/lib/features/home/presentation/home_screen.dart`
- `mobile/test/widget_test.dart`
- `data/devops/system/runtime-command-registry.json` -> `mobile-app.readiness`

## 3. Tasks

- Add `AntiGhostEntryCard`: icon tile on the purple accent token, title
  "Anti-Ghosting" (untranslated), and a subtitle driven by the real lifecycle
  state per UX §2.1 — not set up yet / `{timeoutMinutes} min · {penalty label}` /
  waiting for partner to confirm / partner suggested new rules. Show the amber
  dot badge for both pending variants, always paired with an icon and text.
- Tapping the card pushes `AntiGhostScreen`. When the pending proposal was made
  by the partner, the card routes straight into the review state (State C)
  rather than the edit form.
- Add `anti_ghosting.dart` as the feature barrel exporting `AntiGhostScreen`,
  `AntiGhostEntryCard`, `AntiGhostCubit`, and `GhostConfigRepository`. P3 appends
  `GhostStateRow` and `GhostStormCubit` to this same barrel.
- Mount `AntiGhostEntryCard` into `HomeScreen` **additively**: keep the existing
  `Scaffold`, `AppBar`, and the `Text` carrying `Key('home_screen_ready_signal')`
  exactly as they are, and add the card alongside them. Do not restructure the
  screen, do not remove or rename the readiness key, and do not convert
  `HomeScreen` into a dashboard — that is another story's scope.
- Hide the card entirely when the user has no partner, consistent with UX §1's
  "no entry point at all for unpaired users"; the screen-level guard from P1
  remains the defence in depth.
- Meet the `--tap` minimum (44pt iOS / 48dp Android) using the existing platform
  tokens, never a platform conditional.

## 4. Acceptance Criteria

- The Anti-Ghosting settings screen is reachable from `HomeScreen` by tapping a
  visible, labelled card — verified by widget test, not by direct construction.
- `Key('home_screen_ready_signal')` is still present and still pumps, verified by
  `mobile/test/widget_test.dart` passing unchanged.
- The card renders all four subtitle states from UX §2.1, verified by widget test.
- A partner-proposed pending config routes to the review state, verified by test.
- An unpaired user sees no card.
- The `home_screen.dart` diff is additive: no existing widget is removed,
  renamed, or reordered.
- `no_fork_guard_test` stays green; no `Icons.` reference and no raw colour.

## 5. Planned Outputs

- Code directories or files: the four paths in Write Scope
- Contracts or schemas: `anti_ghosting.dart` barrel as the cross-story export
  surface
- Requirement configuration guide updates: none
- Notes or evidence: navigation-reachability assertion recorded for P4

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, home surface and navigation
- Required levels:
  - unit: card subtitle/badge state selection
  - integration: pump `HomeScreen`, tap the card, assert `AntiGhostScreen` is
    pushed
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile/`
- Required checks: `flutter test test/features/anti_ghosting/`,
  `flutter test test/widget_test.dart`,
  `flutter test test/design_system/no_fork_guard_test.dart`, `flutter analyze`
- Mobile discoverability / navigation integration: REQUIRED — the widget test
  must prove the entry point is reachable by tap from `HomeScreen`; construction
  of `AntiGhostScreen` in isolation is not acceptable evidence
- Minimum gates by risk surface: readiness key -> `widget_test.dart` green;
  no-fork guard -> existing test green; merge surface -> additive-only diff
- Required regression or contract coverage: `mobile/test/widget_test.dart` and
  `mobile/test/app/feature_flags_test.dart` stay green
- Evidence format: concise rows appended to `coding-plan/test-results.md` in P4
- Verification strategy:
  - Targeted tests/regression/contract checks: as above
  - Build/type-check/lint command when required:
    `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` in `mobile/`
  - Required assertion evidence: tap-to-navigate assertion plus explicit
    assertion that the readiness key still resolves

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Commit: `854c472a501e8a36c4140d058789ef8c6e3a7c4e` (worktree
  `story-REQ-001_cupid_flutter_mobile_app-STORY-008`, branch
  `codex/REQ-001_cupid_flutter_mobile_app-STORY-008`)
- Evidence:
  - `flutter analyze` in `mobile/`: zero errors/warnings in any P2 file (all
    errors present are pre-existing, in generated
    `build/ios/SourcePackages/checkouts/flutterfire/...` Firebase test
    fixtures, unrelated to this feature).
  - `flutter test test/features/anti_ghosting/ test/widget_test.dart
    test/design_system/no_fork_guard_test.dart`: 47 passed, 0 failed.
  - `anti_ghost_entry_card_test.dart` covers: readiness key survives
    alongside the card; all four UX §2.1 subtitle states (not-set-up,
    active, pending-mine, pending-partner); unpaired user sees no card
    (AC3 defence in depth); tap-to-navigate reachability asserted from a
    mounted `HomeScreen` (not direct `AntiGhostScreen` construction); and
    partner-proposed pending config routes straight to the State C review
    UI (Accept/Decline) on tap.
- Deviations from declared Write Scope (flagged for Tech Lead/Scrum Master
  awareness, not hidden):
  - Added one additive ARB key pair, `anti_ghost_card_not_set_up_subtitle`
    (English: "Not set up yet"; Vietnamese: "Chưa thiết lập"), to
    `mobile/lib/l10n/arb/app_en.arb` and `app_vi.arb`. These files are
    outside this phase's declared Write Scope, but AC3 of this phase
    requires rendering a "not set up yet" subtitle and no existing key
    covered it; all other three subtitle variants reuse P1-authored keys
    verbatim.
  - Discovered (did not fix outside scope): `setupServiceLocator()` is never
    invoked on the live `HomeScreen` boot path (`main.dart` ->
    `cupid_app.dart` -> `app_shell.dart`), so any unconditional
    `getIt<...>()` call in a widget mounted on `HomeScreen` would crash the
    app's first frame and `mobile/test/widget_test.dart`. Worked around
    entirely inside this phase's own new widget file with a
    `getIt.isRegistered<T>()` guard and a static fallback chrome; did not
    touch `main.dart`/`cupid_app.dart`/`app_shell.dart` since that
    bootstrap gap is pre-existing and cross-cutting, not scoped to P2.
    Recommend a follow-up item to call `setupServiceLocator()` on real app
    boot.
