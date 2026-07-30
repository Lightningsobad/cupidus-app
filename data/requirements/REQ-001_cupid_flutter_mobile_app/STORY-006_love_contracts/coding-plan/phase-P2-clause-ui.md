# Phase P2 – Clause UI And Screen Shell

## 1. Objective

Build the `contract` screen shell with the clause toggle list, the "add our own clause" sheet, and
the loading/empty states, wired to the P1 Bloc, using existing design-system tokens and adaptive
widgets only.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-clause-ui.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`
  - `mobile/lib/features/love_contracts/presentation/widgets/clause_toggle_row.dart`
  - `mobile/lib/features/love_contracts/presentation/widgets/add_clause_sheet.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/love_contracts/presentation/love_contract_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` — not run in this phase
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `LoveContractScreen` (standard-chrome route target for P4)
  - `ClauseToggleRow`, `AddClauseSheet`
  - `loveContract*` ARB message keys
- Shared Interfaces Consumed:
  - P1's `LoveContractBloc`, `LoveContractState`, `LoveContractEvent`
  - `mobile/lib/design_system/design_system.dart` tokens and adaptive widgets
- Risk Surfaces:
  - Custom-gesture and toggle accessibility (UX §8)
  - Clause constraints 1..20 as surfaced in the UI
  - l10n parity
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §4 and §6; `mobile/l10n.yaml` for ARB layout
  - consumer contract: `LoveContractScreen` as pushed by P4
- Primary Inputs Summary:
  - UX constraints: `../ux/uiux-spec.md` §4 (header card, clause rows, add-clause sheet, 1..20),
    §6 (loading + empty), §8 (toggle state not colour-only, sheet focus behavior, `--tap` minimum)
  - architecture: `../architecture/solution.md` §4 Boundaries And Ownership
  - upstream phase outputs: P1's event/state/bloc files
  - design system: `mobile/lib/design_system/design_system.dart`,
    `mobile/lib/design_system/adaptive/cupid_header.dart`,
    `mobile/lib/design_system/adaptive/cupid_add_action.dart`
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: clause authoring UI plus the screen's non-signing states
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §4, §6, §8
- `../architecture/solution.md` §4 Boundaries And Ownership
- P1 outputs in `mobile/lib/features/love_contracts/presentation/`
- `mobile/lib/design_system/design_system.dart` and the adaptive widget files it exports
- `mobile/l10n.yaml`

## 3. Tasks

- Build `LoveContractScreen` as a `BlocProvider` + `BlocBuilder` over `LoveContractBloc`,
  dispatching `LoveContractOpened` on init. Standard chrome: `CupidHeader` with a back affordance
  and the title from the `loveContractTitle` ARB key.
- Render the header card per UX §4: contract sequence label, title, and the
  "Between {me} & {partner}" subtext, where a `null` partner name falls back to the neutral
  localized partner label (architecture §3 A-1). Do not fetch the partner name here.
- Build `ClauseToggleRow`: filled check icon when on, outlined circle when off, mono `§{n}` clause
  id, and a `Semantics` toggle exposing the on/off state (never colour alone, UX §8). Respect the
  `--tap` minimum from STORY-001 tokens.
- Build `AddClauseSheet`: a single-line input inside the existing sheet chrome (`--r-sheet` radius)
  with a helper caption and Save/Cancel. Trap focus while open and return focus to the "+ Add" row
  on cancel (UX §8). Disable/hide the "+ Add" affordance when 20 clauses are already present.
- Render the loading state with the existing STORY-001 card skeleton/placeholder treatment — do not
  introduce a new spinner. Render the empty state as the same screen with every preset deselected
  and the sign area disabled (UX §6); do not build a separate illustration screen.
- Add the ARB keys used by this phase to `app_vi.arb` (template) **and** `app_en.arb` in the same
  commit so `arb_parity_test.dart` stays green. Keep "Love Contract" as an English proper noun in
  both locales per the i18n convention noted in UX §3.
- Leave the signing control as an explicit placeholder slot that P3 fills; do not implement the
  hold gesture in this phase.
- Do not add a design token, a new adaptive widget, or a per-platform screen fork (D3).
- Do not port the raw prototype button labels/handlers flagged in `../ux/uiux-spec.md` §9-3.

## 4. Acceptance Criteria

- The screen renders loading, empty, and clause-populated states from `LoveContractState` alone.
- Toggling a clause row dispatches `ClauseToggled` and never calls the network directly.
- The "+ Add" affordance is unavailable at 20 clauses.
- A clause row exposes its on/off state semantically, not only by colour.
- The add-clause sheet traps focus and restores focus to the "+ Add" row on cancel.
- Every new user-facing string is an ARB key present in both `app_vi.arb` and `app_en.arb`.
- No new pub dependency, no new token, no new adaptive widget, no platform screen fork.

## 5. Planned Outputs

- Code files: the three `presentation/` files in Write Scope
- Contracts: `LoveContractScreen` route target; `loveContract*` ARB keys
- Requirement configuration guide updates: none
- Notes or evidence: concise rows in `test-results.md` (P5 consolidates)

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter widget tests (`mobile` package), `LoveContractScreen` and its rows
- Required levels:
  - unit: none beyond the widget level for this phase
  - integration: widget-level integration of screen + Bloc with a fake repository
  - mobile build/type-check/static-analysis: `flutter analyze` clean
  - visual inspection: N/A in this phase (requirement-level mobile visual audit only)
- Required checks:
  - `flutter test test/features/love_contracts/presentation/love_contract_screen_test.dart`
  - `flutter test test/l10n/arb_parity_test.dart`
  - `flutter analyze`
- Mobile discoverability / navigation integration: N/A for this phase (owned by P4)
- Minimum gates by risk surface:
  - accessibility → assert the clause row exposes a semantic toggle state and the sheet's focus
    trap/return behavior
  - clause constraints → assert the "+ Add" affordance is unavailable at 20 clauses
  - l10n parity → the existing ARB parity test
- Required regression or contract coverage: `mobile/test/design_system/no_fork_guard_test.dart`
  and `mobile/test/design_system/theme_matrix_test.dart` must stay green
- Evidence format: concise rows in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: the new screen widget test plus the ARB parity and design-system guard tests
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: rendered state per Bloc state, semantics node for the toggle,
    focus owner before/after the sheet

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
