# Phase P7 – Dashboard Entry Point And Unpaired Gate

## 1. Objective

Make the timeline discoverable: add the "Love Timeline" dashboard card that
navigates to `TimelineScreen`, and satisfy AC4 by hiding that card for users who
are not paired — without breaking the app's runtime readiness signal.

## 1A. Ownership

- Phase ID: P7
- Canonical Phase File: `phase-P7-entry-point-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P6
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/lib/features/timeline/presentation/widgets/timeline_entry_point_card.dart`
  - `mobile/lib/core/navigation/app_shell.dart`
  - `mobile/test/features/home/presentation/timeline_entry_point_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: `Key('home_screen_ready_signal')` on the home screen, per registry `healthCheck.sourceFile` — this phase must keep it present and pumping
  - Port Contract: N/A
- Shared Interfaces Produced:
  - discoverable dashboard entry point + navigation route to `TimelineScreen`
- Shared Interfaces Consumed:
  - P3 `CouplePairingStore.resolve()`, P5 `TimelineScreen`, P4 entry-card label string
- Risk Surfaces:
  - AC4 pairing gate that must hold offline
  - Runtime readiness signal on the home screen
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §1.1 dashboard entry card and the unpaired-gate bullet in §2; `data/devops/system/runtime-command-registry.json` (`mobile-app.healthCheck`)
  - consumer contract: the reachable navigation path dashboard → timeline
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC2, AC4
  - architecture: `../architecture/solution.md` §4 Risk Surfaces and Mobile guardrails
  - OQ constraints: none additional
  - upstream phase outputs: P3 pairing store, P5 screen, P6 sheet
  - UX constraints, if truly required: `../ux/uiux-spec.md` §1.1 card composition (icon, label, chevron), §2 unpaired users must not reach the screen at all
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one entry point plus its gate
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../story_master.md` AC4
- `../architecture/solution.md` §4 Risk Surfaces, Mobile guardrails
- `../ux/uiux-spec.md` §1.1 and the unpaired-gate bullet in §2
- P3, P5, P6 outputs
- `mobile/lib/core/navigation/app_shell.dart`, `mobile/lib/features/home/presentation/home_screen.dart`

## 3. Tasks

- Build `TimelineEntryPointCard` in the timeline feature directory (icon, localized "Love Timeline" label, chevron affordance) so the home screen edit stays a single additive block — `home_screen.dart` is a merge hotspot for sibling epic-4 stories in this wave.
- Mount the card on the home screen and wire navigation to `TimelineScreen`, providing `TimelineCubit` at the route boundary. Direct-URL-only or code-only access is not acceptable; the card is the discoverable surface.
- Gate the card on `CouplePairingStore.resolve()`: render it only for `paired`. For `unpaired` and `unknown`, do not render it, so an unpaired user cannot reach the screen at all (AC4, UX §2).
- Keep the widget tree containing `Key('home_screen_ready_signal')` intact and still pumped — the runtime registry uses it as the app's readiness signal. Do not rename, move behind a conditional, or delete it.
- Do not restructure the placeholder home screen beyond adding the card; a future dashboard story may re-home it.
- Give the card a tap target meeting the 44pt/48dp token and an accessible label.

## 4. Acceptance Criteria

- With `PairingStatus.paired`, the card renders and tapping it lands on `TimelineScreen` (AC2 reachability).
- With `unpaired` or `unknown`, the card is absent from the tree.
- `Key('home_screen_ready_signal')` is still present and pumps after this change.
- The route provides `TimelineCubit`, so the screen loads without a missing-provider error.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the entry-point card widget, the home-screen mount, the navigation wiring
- Contracts or schemas: none new
- Notes or evidence: none beyond tests

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), widget tests with a fake pairing store
- Required levels:
  - unit: gate decision per `PairingStatus`
  - integration: tap the card and assert `TimelineScreen` is pushed with its cubit available
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: `flutter test test/features/home/presentation/timeline_entry_point_test.dart`, `flutter analyze`
- Mobile discoverability / navigation integration: REQUIRED — the timeline must be reachable from the dashboard card, and that reachability is asserted in this phase's tests
- Minimum gates by risk surface:
  - AC4 pairing gate: card hidden for `unpaired` and `unknown`, including with no connectivity
  - Runtime readiness signal: widget test asserts `Key('home_screen_ready_signal')` still pumps
- Required regression or contract coverage: the readiness-key assertion is a regression guard for the requirement-wide runtime smoke, not an optional check
- Evidence format: concise rows added to `coding-plan/test-results.md` by P8
- Requirement mobile visual audit: deferred to the requirement-level audit after all REQ-001 stories are otherwise complete
- Verification strategy:
  - Targeted tests/regression/contract checks: the widget test file
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: widget finders for card presence/absence, the pushed route, and the readiness key

## 7. Status

- Status: DONE
- Evidence:
  - `flutter test test/features/home/presentation/timeline_entry_point_test.dart` — 5/5 passed (`home_screen_ready_signal pumps immediately, before the pairing status resolves`, `paired: the entry-point card renders`, `unpaired: the entry-point card is absent`, `unknown (e.g. no connectivity and nothing cached): the entry-point card is absent`, `tapping the card pushes TimelineScreen with its cubit available (no missing-provider error)`).
  - `flutter analyze` (scoped to the 4 touched files plus `app_shell.dart`) — No issues found.
  - `TimelineEntryPointCard` is mounted additively in `home_screen.dart` via a `_TimelineEntryPointGate` (`FutureBuilder` over `CouplePairingStore.resolve()`) appended after the existing `VibeEntryCard`/`_ReminderEntryCard` children; `Key('home_screen_ready_signal')` is untouched and pumps before the pairing future resolves. The card renders only for `PairingStatus.paired` and is absent for `unpaired`/`unknown` (AC4). Tapping the card pushes `TimelineScreen(createCubit: ...)`, providing `TimelineCubit` at the route boundary.
  - `app_shell.dart` was not modified — it already boots directly into `HomeScreen` with no `ReminderOverlayHost` wrapper present in this worktree, so no additional wrapper preservation was required.
- NOTE (carried over from P6, not fixed in this phase): `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart` is still outside this phase's write scope and its `onAddMemory` callbacks remain hardcoded to `() {}`. `CreateMemorySheet.show(...)` (P6) and the dashboard reachability path to `TimelineScreen` (P7) are each independently implemented and tested, but the in-screen "Add a memory" CTA does not yet open the P6 sheet. AC1 (create and see the entry at the top of the list) is not reachable end-to-end from the real screen until a follow-up phase with explicit write scope on `timeline_screen.dart` wires `onAddMemory` to `CreateMemorySheet.show`.
- Last updated: 2026-07-31
