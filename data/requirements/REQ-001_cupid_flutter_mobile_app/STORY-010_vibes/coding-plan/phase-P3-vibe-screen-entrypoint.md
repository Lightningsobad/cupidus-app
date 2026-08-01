# Phase P3 – Vibe Screen And Discoverable Entry Point

## 1. Objective

Compose the vibe screen from the P1 cubit and P2 widgets, and mount a
discoverable entry point on the existing `HomeScreen` so the capability is
reachable — not an orphaned screen.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-vibe-screen-entrypoint.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/vibes/presentation/vibe_screen.dart`
  - `mobile/lib/features/vibes/presentation/widgets/vibe_entry_card.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/lib/design_system/icons/cupid_icons.dart` (append-only, 1 constant)
  - `mobile/test/features/vibes/presentation/vibe_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: `Key('home_screen_ready_signal')` must remain present and
    pumpable on `HomeScreen` (registry readiness contract)
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `VibeScreen`
  - `VibeEntryCard({VibeMood? today, VibeMood? partnerToday, required onTap})`
    — v1 mounts it navigation-only with both snapshots omitted (D-010-5)
- Shared Interfaces Consumed:
  - P1 `VibeCubit` / `VibeState` (via `getIt`), P2 widgets, `VibeLocaleText`
- Risk Surfaces:
  - Entry-point discoverability
  - Optimistic submit + revert (screen-level error surface)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §4
    D-010-4, D-010-5, plus the AC3 subsection; `../ux/uiux-spec.md` §2, §4, §7
  - consumer contract: requirement integration / home-dashboard story
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC2, AC3
  - architecture: `../architecture/solution.md` §4 (D-010-4, D-010-5, AC3
    subsection), §6
  - OQ constraints: none new
  - upstream phase outputs: P1 cubit/state, P2 widgets
  - UX constraints, if truly required: `../ux/uiux-spec.md` §2 (entry from home,
    back behavior), §4 (inline error placement), §7 (no screen-level pairing
    guard as the primary control)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: screen composition + entry-point wiring
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §4 (D-010-4, D-010-5, AC3 subsection), §6
- `../ux/uiux-spec.md` §2, §4, §7
- P1 and P2 outputs under `mobile/lib/features/vibes/`
- `mobile/lib/features/home/presentation/home_screen.dart`
- `mobile/lib/core/navigation/app_shell.dart`

## 3. Tasks

- `VibeScreen`: provide `getIt<VibeCubit>()` via `BlocProvider`, call `load()`
  once on create, and compose header → mood grid → partner card → history strip.
  Wrap the body in `RefreshIndicator.adaptive` calling `refresh()` (the pull
  affordance implied by UX §10.4 pull/refresh delivery); no platform fork.
- Bind grid `enabled` to `!state.submitting` and `selected` to
  `state.optimisticMood ?? state.myToday?.mood`.
- Render `state.failure` as a single non-blocking inline error using the `--red`
  token and the STORY-003 failure→text mapping convention; announce it through an
  accessible live region at the point of revert (UX §4, §8). Never a full-screen
  error state.
- `VibeEntryCard`: a discoverable tap target (label + icon + chevron/`Lịch sử`
  affordance) that pushes `VibeScreen`. Accept optional `today`/`partnerToday`
  snapshots for the future home dashboard, but mount it in v1 without them so no
  duplicate fetch occurs.
- Mount `VibeEntryCard` in `HomeScreen`, keeping `Key('home_screen_ready_signal')`
  present and pumpable. Do not restructure `AppShell` or add tab-bar navigation
  (out of scope; owned by the home-dashboard/shell work).
- Do **not** add a screen-level "are you paired" guard as the primary control
  (UX §7). The screen must simply render the waiting/`none` states when the
  partner data is empty.
- Append one `tipsAndUpdates` Material Symbols constant to `CupidIcons` at the
  end of the class if the nudge banner icon is needed — single additive line, no
  reordering of existing constants (R-010-4).

## 4. Acceptance Criteria

- `VibeScreen` is reachable by tapping the entry card on `HomeScreen`; a widget
  test proves the navigation.
- `Key('home_screen_ready_signal')` still resolves on `HomeScreen`, so the
  `mobile-app` readiness contract is unbroken.
- Tapping a mood cell shows the optimistic highlight and locks the grid; a
  failing submit reverts the highlight and shows exactly one inline error.
- Pull-to-refresh re-runs the three reads.
- With an empty partner history the screen renders the waiting/`none` states and
  no error (AC3 defensive path, UX §7 unpair edge case).
- No screen-level pairing guard is introduced; no tab-bar or `AppShell`
  restructure; `cupid_icons.dart` changes are additive only.

## 5. Planned Outputs

- Code directories or files:
  `mobile/lib/features/vibes/presentation/vibe_screen.dart`,
  `widgets/vibe_entry_card.dart`, edited
  `mobile/lib/features/home/presentation/home_screen.dart`
- Contracts or schemas: `VibeEntryCard` mount contract for the home-dashboard
  story
- Requirement configuration guide updates: none
- Notes or evidence: widget test results recorded in P4

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile widget tests, `mobile/` package
- Required levels:
  - unit: none new (covered by P0/P1)
  - integration: widget-level screen + fake cubit/repository composition
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: entry-card tap pushes `VibeScreen`;
  `home_screen_ready_signal` still present; optimistic highlight + grid lock;
  single inline error on failure; empty-partner waiting state; pull-to-refresh
  triggers `refresh()`
- Mobile discoverability / navigation integration: REQUIRED — the entry card on
  `HomeScreen` is the discoverable surface; direct-instantiation-only access is
  not acceptable
- Minimum gates by risk surface:
  - Entry-point discoverability → navigation widget test, else
    `ENTRYPOINT_UNVERIFIED`
  - Optimistic submit + revert → screen-level widget test, else
    `SUBMIT_UNVERIFIED`
- Required regression or contract coverage: `mobile/test/widget_test.dart` and
  any existing `home_screen` readiness assertion must still pass
- Evidence format: concise rows in `coding-plan/test-results.md` (written in P4)
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/features/vibes test/widget_test.dart`
  - Build/type-check/lint command when required:
    `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" analyze`
  - Required assertion evidence: navigation assertion, widget key presence,
    rendered error count, refresh callback invocation

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
