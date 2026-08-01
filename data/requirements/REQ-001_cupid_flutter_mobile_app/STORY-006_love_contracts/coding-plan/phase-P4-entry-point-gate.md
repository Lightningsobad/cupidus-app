# Phase P4 – Entry Point And Pairing Gate

## 1. Objective

Make the feature reachable: mount a discoverable "Love Contract" tile on `HomeScreen` that appears
only for paired users (AC4, hide-not-disable) and navigates to `LoveContractScreen`, without
breaking the `mobile-app` runtime readiness signal.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-entry-point-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/love_contracts/presentation/love_contract_entry_tile_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` — not run in this phase
  - Readiness Check: `Key('home_screen_ready_signal')` must still pump in
    `mobile/test/widget_test.dart` after this edit (registry `readiness.sourceFile` is
    `mobile/lib/features/home/presentation/home_screen.dart`)
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `LoveContractEntryTile` (movable to a real `Me`/profile screen later, unchanged)
  - the navigation edge `HomeScreen → LoveContractScreen`
- Shared Interfaces Consumed:
  - P0's `LoveContractGateRepository` / `PairingState`
  - P2/P3's `LoveContractScreen`
- Risk Surfaces:
  - AC4 pairing gate
  - Runtime readiness regression on `home_screen.dart`
  - Feature discoverability (an unmounted screen is an orphaned feature)
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §3 and §7; `../architecture/solution.md` §3 A-2,
    §4 Entry Point and Pairing Gate
  - consumer contract: the tile's visibility rule keyed on `PairingState.partnerId`
- Primary Inputs Summary:
  - UX constraints: `../ux/uiux-spec.md` §3 (row style, `draw` icon, chevron, standard chrome on
    the target screen), §7 (hide-not-disable gate on `partnerId`)
  - architecture: `../architecture/solution.md` §3 A-2 (why `HomeScreen`, not a `Me` screen),
    §4 Entry Point, §4 Pairing Gate
  - upstream phase outputs: P0's gate repository, P2/P3's screen
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: discoverable entry point plus the AC4 gate
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §3, §7
- `../architecture/solution.md` §3 A-2, §4 Entry Point, §4 Pairing Gate
- `mobile/lib/features/home/presentation/home_screen.dart`
- `mobile/test/widget_test.dart`
- P0's `love_contract_gate_repository.dart`; P2/P3's `love_contract_screen.dart`

## 3. Tasks

- Build `LoveContractEntryTile`: a `--surf` card row with the `draw` icon, the localized
  "Love Contract" label, and a chevron affordance, in the same list-item style described in
  UX §3. It resolves `PairingState` from `LoveContractGateRepository` (via `get_it`) and renders
  nothing when `partnerId` is null or when the gate fetch fails (architecture §4 Pairing Gate).
- Mount the tile in `HomeScreen`. Keep the existing `Key('home_screen_ready_signal')` text widget
  in place and unchanged — it is the runtime readiness signal for `mobile-app`.
- Tapping the tile pushes `LoveContractScreen` with standard chrome and a working back affordance.
  Direct-route-only access is not acceptable; the tile is the discoverable surface.
- Have `LoveContractScreen` re-assert the gate on open so a stale navigation cannot show contract UI
  to an unpaired user.
- Add the tile's label/subtitle strings to both `app_vi.arb` and `app_en.arb`.
- Do not build a `Me`/profile screen, a tab bar, or any other navigation shell in this phase.
- Keep the `home_screen.dart` edit to the minimum needed to mount the tile — STORY-005 may be
  editing the same file on a sibling branch.

## 4. Acceptance Criteria

- The tile is absent when `partnerId` is null and when the gate fetch fails (AC4, hide-not-disable).
- The tile is present and navigates to `LoveContractScreen` when `partnerId` is set.
- `LoveContractScreen` is reachable through the tile, not by direct route only.
- `Key('home_screen_ready_signal')` still pumps in `mobile/test/widget_test.dart`.
- New strings exist in both ARB files.
- No `Me` screen, tab bar, or navigation shell is introduced.

## 5. Planned Outputs

- Code files: `love_contract_entry_tile.dart` plus the minimal `home_screen.dart` mount
- Contracts: the tile widget and the `HomeScreen → LoveContractScreen` navigation edge
- Requirement configuration guide updates: none
- Notes or evidence: concise rows in `test-results.md` (P5 consolidates)

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter widget tests (`mobile` package), `HomeScreen` + `LoveContractEntryTile`
- Required levels:
  - integration: widget-level `HomeScreen` render with a fake gate repository (paired, unpaired,
    failing) and a tap-navigates assertion
  - mobile build/type-check/static-analysis: `flutter analyze` clean
  - visual inspection: N/A in this phase (requirement-level mobile visual audit only)
- Required checks:
  - `flutter test test/features/love_contracts/presentation/love_contract_entry_tile_test.dart`
  - `flutter test test/widget_test.dart`
  - `flutter test test/l10n/arb_parity_test.dart`
  - `flutter analyze`
- Mobile discoverability / navigation integration: the tile is the required discoverable surface;
  the test must assert both its presence for a paired user and that tapping it reaches
  `LoveContractScreen`
- Minimum gates by risk surface:
  - AC4 pairing gate → tile absent for unpaired and for gate failure, present when paired
  - runtime readiness regression → `widget_test.dart` still finds `home_screen_ready_signal`
  - discoverability → the tap-navigates assertion
- Required regression or contract coverage: `mobile/test/widget_test.dart`,
  `mobile/test/app/feature_flags_test.dart`, and the P2/P3 screen tests stay green
- Evidence format: concise rows in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: the new tile test plus the `widget_test.dart` and ARB parity regressions
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: tile presence/absence per gate state and the pushed route

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
