# Phase P6 – Create-Memory Bottom Sheet

## 1. Objective

Deliver AC1: a paired user can create a timeline entry through a bottom sheet,
with the ADR-007 no-offline-write rule enforced in the UI so an entry can never be
silently queued or lost.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-create-memory-sheet.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P5
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/timeline/presentation/create_entry_cubit.dart`
  - `mobile/lib/features/timeline/presentation/widgets/create_memory_sheet.dart`
  - `mobile/test/features/timeline/presentation/create_entry_cubit_test.dart`
  - `mobile/test/features/timeline/presentation/create_memory_sheet_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `CreateMemorySheet.show(context)` opened by the "Add a memory" affordance built in P5
  - `CreateEntryCubit` states: `editing`, `submitting`, `success`, `blockedOffline`, `pairingRequired`, `failed`
- Shared Interfaces Consumed:
  - P3 `TimelineRepository.createEntry`, P4 `TimelineCubit.isOffline` and message keys, P5 `TimelineScreen` host
  - design system: `CupidPrimaryButton`, sheet radius token, platform-adaptive sheet behavior
- Risk Surfaces:
  - Offline write prohibition (ADR-007)
  - Unpaired create (backend returns 404)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §1.3 create flow and §2 "Offline while attempting to create"; `../architecture/solution.md` §3 OQ table
  - consumer contract: sheet entry point invoked from `TimelineScreen`
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC3, AC4
  - architecture: `../architecture/solution.md` §3 OQ table, §4 error contract
  - OQ constraints: ADR-007 — no offline write queue, no optimistic insert, no automatic retry
  - upstream phase outputs: P3 repository, P4 cubit/strings, P5 screen host
  - UX constraints, if truly required: `../ux/uiux-spec.md` §1.3 field set, sheet pattern and CTA, §2 offline-save copy
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one create flow
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md` §2, §3, §4
- `../ux/uiux-spec.md` §1.3 and the offline-create bullet in §2
- P3, P4, P5 outputs

## 3. Tasks

- Build `CreateMemorySheet` as a platform-adaptive bottom sheet using the design-system sheet radius token, opened from the P5 "Add a memory" affordance.
- Fields: title (required, trimmed, max 100 to match the backend DTO), date (required, defaults to today, backdatable via the platform date picker), description (optional, multi-line, max 500). Do **not** add a photo attachment field — deferred by architecture D-012-7; do not add `image_picker`.
- Enforce the backend length limits client-side so a create cannot fail on a validation error the UI could have prevented.
- Implement `CreateEntryCubit.submit()` calling `repository.createEntry(draft)`. On success emit `success`; the timeline list refreshes through the existing Drift stream, so do not insert locally and do not manually mutate the list.
- Gate Save on connectivity: when the timeline is already known to be offline, render Save disabled with the localized "needs a connection" copy (UX §2).
- If a submit still fails with `NetworkUnavailableFailure` / `TimeoutFailure`, emit `blockedOffline`, keep every field populated, show the retry affordance, and write nothing locally. Never queue the entry.
- Map `HttpStatusFailure(404)` to `pairingRequired` (the backend 404s creates for an unpaired user) and any other `CupidApiFailure` to `failed` with the generic error copy. Let `UnauthorizedFailure` propagate to the existing session/re-auth path — do not add a second auth path.
- Dismiss on success and on explicit cancel/swipe-down only; never auto-dismiss on failure.
- Meet the 44pt/48dp tap-target token for the CTA and give the icon-only close affordance an accessible label.

## 4. Acceptance Criteria

- A paired, online user can create an entry and see it at the top of the list without a manual reload (AC1).
- A backdated entry appears in the correct newest-first position after refresh.
- Empty title blocks submit with inline validation and no network call.
- Save is disabled with explanatory copy while the timeline is known to be offline.
- A submit that fails on connectivity preserves all input, shows retry, and adds no Drift row.
- A 404 renders the pairing-required message rather than a generic error.
- The sheet stays open on failure and closes on success.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the two source files in Write Scope
- Contracts or schemas: `CreateEntryCubit` state set
- Notes or evidence: none beyond tests

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), cubit unit tests plus widget tests with a fake repository
- Required levels:
  - unit: submit success, validation rejection, `blockedOffline` preserving input with no local write, `pairingRequired` on 404, generic failure mapping
  - integration: sheet + cubit + in-memory repository asserting the list gains the entry via the Drift stream after success
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: `flutter test test/features/timeline/presentation/create_entry_cubit_test.dart test/features/timeline/presentation/create_memory_sheet_test.dart`, `flutter analyze`
- Mobile discoverability / navigation integration: the sheet must be reachable from the P5 "Add a memory" affordance, asserted by a widget test
- Minimum gates by risk surface:
  - Offline write prohibition: input preserved, zero Drift rows added, no queue created
  - Unpaired create: 404 → `pairingRequired`
- Required regression or contract coverage: assert exactly one `POST /timeline` per submit and none when validation fails or Save is disabled
- Evidence format: concise rows added to `coding-plan/test-results.md` by P8
- Verification strategy:
  - Targeted tests/regression/contract checks: the two test files above
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: emitted state sequences, captured request count, Drift row counts, retained field values

## 7. Status

- Status: DONE
- Evidence:
  - `flutter test test/features/timeline/presentation/create_entry_cubit_test.dart test/features/timeline/presentation/create_memory_sheet_test.dart` — 14/14 passed.
  - `flutter analyze` (scoped to the 4 touched files) — No issues found.
  - `CreateEntryCubit` implements `editing`/`submitting`/`success`/`blockedOffline`/`pairingRequired`/`failed`; empty-title and proactive-offline paths never call the repository; `NetworkUnavailableFailure`/`TimeoutFailure` map to `blockedOffline` with no Drift row written; `HttpStatusFailure(404)` maps to `pairingRequired`; other `CupidApiFailure`s map to `failed`; `UnauthorizedFailure` is rethrown (propagates to the app's existing session/re-auth path, no second auth path added).
  - `CreateMemorySheet` is text-only (title/date/description, no photo field, no `image_picker` dependency); Save uses `CupidPrimaryButton` (meets the `tapTarget` token); the close affordance carries an accessible `Semantics` label; the sheet dismisses only on success or explicit cancel, never on failure.
- NOTE (discoverability gap, not fixed in this phase): neither this phase nor P7 has `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart` in its write scope, but that file's `onAddMemory` callbacks are still hardcoded to `() {}` (P5's own inline comment marks this "P6 scope"). `CreateMemorySheet.show(...)` is fully implemented and unit/widget-tested against a self-contained harness (not the real `TimelineScreen`), but nothing yet wires the P5 CTA to it. A follow-up phase/task needs explicit write scope on `timeline_screen.dart` to pass `CreateMemorySheet.show` into `onAddMemory`.
- BLOCKER (ADR-010, not fixed in this phase, out of write scope): `mobile/lib/core/database/app_database.dart` still literally declares `class AppDatabase extends _$AppDatabase implements SessionScopedStore` — the ADR-010 rename `AppDatabase` -> `CupidDatabase` has not happened in source. Per the standing instruction, no broad rename was performed here and the Cross-Lane Contract Summary table in `coding-plan/master-plan.md` is left referencing `AppDatabase` (accurate to current source) rather than being silently rewritten to `CupidDatabase`. Scrum Master should route a dedicated rename task if the ADR-010 rename is still intended.
- Last updated: 2026-07-30
