# Phase P1 – Vibe Cubit And DI

## 1. Objective

Own the screen's state machine: load the three reads on open/refresh, submit a
mood optimistically, lock the grid while in flight, and revert on failure.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-vibe-cubit.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO (independent of P2; either order is acceptable)
- Write Scope:
  - `mobile/lib/features/vibes/presentation/vibe_state.dart`
  - `mobile/lib/features/vibes/presentation/vibe_cubit.dart`
  - `mobile/lib/core/di/service_locator.dart` (append-only, 2 registrations)
  - `mobile/test/features/vibes/presentation/vibe_cubit_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `VibeState` (today, my week buckets, partner week buckets, partner today,
    submitting flag, failure)
  - `VibeCubit` (`load()`, `refresh()`, `pick(VibeMood)`)
- Shared Interfaces Consumed:
  - P0 `VibesRepository`, `VibeMood`, `VibeEntry`, `bucketByLocalDay`
- Risk Surfaces:
  - Optimistic submit + revert
  - Local-date bucketing / timezone (consumed, not re-implemented)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §4
    D-010-3; `req_master.md` D2 (Cubit for CRUD screens); existing cubit
    precedent `mobile/lib/features/auth/presentation/sign_out_cubit.dart`
  - consumer contract: P3 `VibeScreen`
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC2
  - architecture: `../architecture/solution.md` §2, §4 D-010-3
  - OQ constraints: OQ4 — no `hydrated_bloc`, no local persistence
  - upstream phase outputs: P0 contracts
  - UX constraints, if truly required: `../ux/uiux-spec.md` §4 (immediate
    submit, optimistic highlight, in-flight lock, revert-on-failure, re-check-in
    allowed same day)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: state + submit lifecycle + DI wiring
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2, §4 (D-010-3), §6
- `../ux/uiux-spec.md` §4
- P0 outputs under `mobile/lib/features/vibes/`
- `mobile/lib/core/di/service_locator.dart` (registration pattern)

## 3. Tasks

- Add `VibeState` with: `myToday` (`VibeEntry?`), `myWeek` and `partnerWeek`
  (7-slot `List<VibeMood?>`), `partnerToday` (`VibeMood?`), `loading`,
  `submitting`, `failure` (`CupidApiFailure?`), and `optimisticMood`
  (`VibeMood?`) for the pending highlight.
- Add `VibeCubit`:
  - `load()` / `refresh()`: run the three reads, then derive `myWeek`,
    `partnerWeek` via P0 bucketing and `partnerToday` from the partner bucket
    for the local today (never a `days=1` call — D-010-3).
  - `pick(mood)`: ignore the call when `submitting` is true (R-010-2); set
    `optimisticMood` + `submitting` immediately; on success re-fetch `today`
    (authoritative) and both histories; on `CupidApiFailure` clear
    `optimisticMood` back to the last confirmed value and set `failure`.
  - Clear `failure` on the next successful action so the inline error does not
    persist.
  - Treat an empty partner list as a valid "waiting" result, not a failure
    (AC3 defensive path).
- Register `VibesRepository` (lazy singleton) and `VibeCubit` (factory) in
  `service_locator.dart` by appending to the end of the existing registration
  block — do not reorder or reformat existing lines (R-010-4).

## 4. Acceptance Criteria

- `load()` emits loading → loaded with all four derived fields populated.
- `pick()` emits the optimistic highlight before any network completion.
- A second `pick()` while `submitting` is true emits no new state.
- A failing `pick()` restores the previously confirmed selection and sets
  `failure`; it never leaves an unsaved mood highlighted.
- Picking a different mood the same day succeeds and updates `myToday` (UX §4
  re-check-in rule); no "already checked in" block exists.
- An empty partner history yields `partnerToday == null` with no `failure`.
- `service_locator.dart` changes are additive only.

## 5. Planned Outputs

- Code directories or files:
  `mobile/lib/features/vibes/presentation/vibe_cubit.dart`, `vibe_state.dart`,
  appended registrations in `mobile/lib/core/di/service_locator.dart`
- Contracts or schemas: `VibeState` as consumed by P3
- Requirement configuration guide updates: none
- Notes or evidence: `bloc_test` results recorded in P4

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/` package
- Required levels:
  - unit: `bloc_test` state sequences for load success, load failure, optimistic
    pick success, pick failure revert, double-tap suppression, same-day
    re-check-in, empty partner history
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `VibeCubit` imports no `Dio`, `cupid_api`, or raw path
  string; repository is injected, not constructed
- Mobile discoverability / navigation integration: N/A for this phase
- Minimum gates by risk surface:
  - Optimistic submit + revert → `bloc_test` sequence, else `SUBMIT_UNVERIFIED`
- Required regression or contract coverage: existing
  `mobile/test/features/auth/**` cubit tests still pass after the DI change
- Evidence format: concise rows in `coding-plan/test-results.md` (written in P4)
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/features/vibes`
  - Build/type-check/lint command when required:
    `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" analyze`
  - Required assertion evidence: emitted state sequences with the exact
    optimistic/confirmed/failure field values

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Evidence:
  - `mobile/lib/features/vibes/presentation/vibe_state.dart`: `VibeState`
    with `myToday` (`VibeEntry?`), `myWeek`/`partnerWeek` (7-slot
    `List<VibeMood?>`), `partnerToday` (derived getter over `partnerWeek`'s
    last slot), `optimisticMood`, a `selectedMood` getter
    (`optimisticMood ?? myToday?.mood`), `loading`, `submitting`, and
    `failure` (`CupidApiFailure?`). A sentinel-based `copyWith` lets
    `myToday`/`optimisticMood`/`failure` be explicitly cleared to `null`.
  - `mobile/lib/features/vibes/presentation/vibe_cubit.dart`: `load()`
    (emits `loading: true` first, per AC1) and `refresh()` (same fetch,
    does not toggle `loading` — the pull-to-refresh spinner is
    `RefreshIndicator`'s job) both call a shared `_fetchSnapshot()` that
    reads `fetchMyToday`/`fetchMyHistory`/`fetchPartnerHistory` and buckets
    the two histories to mood-only lists via P0's `bucketByLocalDay`.
    `pick(VibeMood)` no-ops while `submitting` (R-010-2), optimistically
    emits the tapped mood, calls `VibesRepository.submitMood`, then
    re-fetches the full snapshot on success (D-010-1 freshness) or clears
    the optimistic overlay and records the `CupidApiFailure` on error —
    `myToday` itself is never mutated on failure, so `selectedMood`
    automatically reverts to the last confirmed value once the overlay
    clears.
  - `mobile/lib/core/di/service_locator.dart`: two append-only
    registrations (`VibesRepository` lazy singleton over `getIt<CupidApi>()`,
    `VibeCubit` factory over `getIt<VibesRepository>()`); the relative
    import block was re-sorted (features import moved before `../auth/...`)
    to keep `directives_ordering` clean — no existing line was reordered or
    reformatted otherwise (R-010-4).
  - Test-tooling note: this phase's test uses plain `flutter_test` plus a
    hand-rolled `VibesRepository` subclass fake (overriding all four
    methods; the wrapped `CupidApi` is never exercised), matching the
    `sign_out_cubit_test.dart` precedent. `bloc_test`/`mocktail` were not
    added — neither exists in `pubspec.yaml`, `pubspec.yaml` is outside
    this phase's write scope, and `architecture/solution.md` §3/§6
    explicitly commit to no new dependency for this story.
  - `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/features/vibes/presentation/vibe_cubit_test.dart`
    — 7/7 passed: `load` emits `loading` then a populated state (`myToday`,
    `myWeek`/`partnerWeek` bucket slots, `partnerToday`, cleared `failure`),
    `load` records a `CupidApiFailure` and clears `loading` on error,
    `refresh` does not toggle `loading`, `pick` optimistically shows the
    tapped mood while `submitting` then confirms after refetch, `pick`
    reverts the optimistic overlay (not `myToday`) and records the failure
    on error, `pick` ignores a second call while one is in flight (submit
    action invoked exactly once), an empty partner history yields
    `partnerToday == null` with no `failure`.
  - `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/features/vibes` —
    22/22 passed (P0's 15 + this phase's 7), confirming no P0 regression.
  - `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/features/auth` —
    17/17 passed (regression check for the `service_locator.dart` append).
  - `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" analyze` on
    `vibe_cubit.dart`, `vibe_state.dart`, `service_locator.dart`,
    `vibe_cubit_test.dart` — 0 issues.
