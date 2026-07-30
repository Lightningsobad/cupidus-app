# Phase P1 – Config Lifecycle State And Anti-Ghosting Settings Screen

## 1. Objective

Deliver AC1 and AC3: a paired user can view and propose anti-ghosting
configuration through the four contract-accurate lifecycle states, and an
unpaired user cannot.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-lifecycle-and-settings-screen.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/anti_ghosting/presentation/anti_ghost_cubit.dart`
  - `mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart`
  - `mobile/lib/design_system/icons/cupid_icons.dart` (append new glyphs only)
  - `mobile/lib/l10n/arb/app_en.arb` (append keys only)
  - `mobile/lib/l10n/arb/app_vi.arb` (append keys only)
  - `mobile/test/features/anti_ghosting/presentation/anti_ghost_cubit_test.dart`
  - `mobile/test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A for this phase
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `AntiGhostCubit` with states A (no config), B (proposed by me), C (proposed
    by partner), D (active), plus loading, guard (unpaired), and failure states
  - `AntiGhostScreen`
  - new `CupidIcons` glyphs and new ARB keys
- Shared Interfaces Consumed:
  - `GhostConfigRepository`, `GhostConfig`, `Penalty`, `ConfigStatus` (P0)
  - `BackendUserIdStore` (`core/realtime/backend_user_id_store.dart`)
  - `CupidColorTokens`, `CupidPrimaryButton`, `CupidHeader`, `CupidIcon`
- Risk Surfaces:
  - Pairing gate (AC3)
  - Approval-role derivation
  - Design-system no-fork guard
  - l10n parity
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §4 Mobile
    Lane Handoff and ADR-4/ADR-5/ADR-6; `../ux/uiux-spec.md` §2.3 States A-D
  - consumer contract: State B vs State C is selected by comparing
    `GhostConfig.proposedBy` to the backend user id, never the Firebase uid
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC3
  - architecture: `../architecture/solution.md` §4 Mobile Lane Handoff, ADR-2
    (refresh triggers), ADR-4, ADR-5, ADR-6
  - OQ constraints: none
  - upstream phase outputs: P0 repository and models
  - UX constraints, if truly required: `../ux/uiux-spec.md` §1 (access guard),
    §2.3 (States A-D), §3 (adaptive behaviour), §4 (accessibility), §5 (i18n)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: config lifecycle state machine plus its one screen
  - Source/Test File Count: 4 source/test files, plus 3 append-only
    token/localization asset edits
  - Split Required: NO
  - Split Rationale: the ARB and icon edits are additive asset entries, not
    logic, so they do not consume the specialist lifecycle budget

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md` §4 Mobile Lane Handoff, §6 ADR-2, ADR-4, ADR-5, ADR-6
- `../ux/uiux-spec.md` §1, §2.3, §3, §4, §5
- P0 outputs: `ghost_config_repository.dart`, `ghost_config_models.dart`
- `mobile/lib/features/auth/presentation/sign_in_cubit.dart` and
  `sign_out_cubit.dart` (cubit + failure-state precedent)
- `mobile/lib/design_system/design_system.dart` and
  `mobile/lib/design_system/icons/cupid_icons.dart`

## 3. Tasks

- Add `AntiGhostCubit` that loads state by calling `fetchActive()` and
  `fetchPending()` together, then resolves exactly one of: guard (no partner),
  State A (no active, no pending), State B (pending and `proposedBy` == backend
  user id), State C (pending and `proposedBy` != backend user id), State D
  (active, no pending). When the backend user id is unknown, render the
  read-only pending summary with no actions (ADR-4).
- Expose `propose(timeoutMinutes, penalty)`, `approve()`, `reject()`, and
  `refresh()`. Every successful mutation triggers a refetch (ADR-2). Guard the
  propose path with an in-flight flag so a double tap cannot create two
  `pending_approval` rows.
- Map `HttpStatusFailure(400)` on a mutation to a stale-state refetch plus a
  user-visible message, not a retry loop.
- Add `AntiGhostScreen` rendering all four states per UX §2.3:
  - State A: intro card, 5/10/15 preset chips plus a "Custom" control bounded to
    1-120, a **single-select radio-semantics** 3-option penalty control
    (Emoji Storm / Noise / None), and a `CupidPrimaryButton` "Propose to
    {partner}" in the bottom ~30%.
  - State B: read-only proposed summary; controls **disabled and visible**, each
    exposing an accessible disabled reason; no withdraw action (ADR-6).
  - State C: review card with Accept (primary) then Decline (secondary), each
    carrying a full accessible label naming the actual values being decided.
  - State D: active summary plus "Change", which reopens the State A form
    pre-filled and submits as a new proposal.
  - Guard state: unpaired users get a hard empty state, not a hidden control.
- Do not implement the mockup's public-countdown toggle, sound-override toggle,
  or custom emoji grid (ADR-5).
- Refresh on screen entry and on app foreground resume (ADR-2). Do not add any
  timer in this phase.
- Append the glyphs this screen needs (for example blur/cyclone/volume/timer) to
  `CupidIcons` as Material Symbols Rounded codepoints. Never reference `Icons.`
  directly.
- Append all new copy keys to both `app_en.arb` and `app_vi.arb`, keeping
  "Anti-Ghosting" and "Emoji Storm" untranslated in `vi` (UX §5).
- Pair every amber signal with an icon and a text label; never signal by colour
  alone (UX §4).

## 4. Acceptance Criteria

- AC1: a paired user sees current configuration and can submit a proposal with a
  timeout in 1-120 and exactly one penalty, verified by cubit and widget test.
- AC3: with no `partnerId`, the screen renders the guard state and no mutating
  repository call is made, verified by test.
- State B vs State C is chosen correctly for proposed-by-me, proposed-by-partner,
  and unknown-backend-id, verified by cubit test.
- The penalty control is single-select with radio semantics; selecting one option
  deselects the others, verified by widget test.
- State B controls are present but disabled, and no withdraw affordance exists.
- Double-tapping propose issues exactly one `POST`, verified by test.
- `mobile/test/l10n/arb_parity_test.dart` and
  `mobile/test/design_system/no_fork_guard_test.dart` stay green.
- No `Icons.` reference, no raw colour literal, no platform branching in feature
  code; no new `pubspec.yaml` entry.

## 5. Planned Outputs

- Code directories or files: the seven paths in Write Scope
- Contracts or schemas: `AntiGhostCubit` state contract consumed by P2
- Requirement configuration guide updates: none
- Notes or evidence: AC1/AC3 test assertions recorded for P4

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, presentation layer
- Required levels:
  - unit: `anti_ghost_cubit_test.dart` — state resolution for all four states
    plus guard and unknown-id, mutation refetch, in-flight double-tap guard,
    400-as-stale handling
  - integration: cubit driven through a fake `GhostConfigRepository`
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile/`
  - visual inspection: none in this phase (deferred to the requirement-level
    mobile visual audit)
- Required checks: `flutter test test/features/anti_ghosting/`,
  `flutter test test/l10n/arb_parity_test.dart`,
  `flutter test test/design_system/no_fork_guard_test.dart`, `flutter analyze`
- Mobile discoverability / navigation integration: not in this phase — the
  discoverable entry point is P2's responsibility
- Minimum gates by risk surface: pairing gate -> guard test with zero mutating
  calls; approval-role derivation -> three-case cubit test; no-fork guard and
  ARB parity -> existing tests stay green
- Required regression or contract coverage: `arb_parity_test`,
  `no_fork_guard_test`, `adaptive_widgets_test`, `theme_matrix_test`,
  `contrast_test`, `icon_variant_test` stay green after the `CupidIcons` edit
- Evidence format: concise rows appended to `coding-plan/test-results.md` in P4
- Verification strategy:
  - Targeted tests/regression/contract checks: as above
  - Build/type-check/lint command when required:
    `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` in `mobile/`
  - Required assertion evidence: per-state widget-finder assertions and
    repository-call assertions for the guard and double-tap cases

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
