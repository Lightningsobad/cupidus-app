# Phase P4 – Timeline Presentation State And Strings

## 1. Objective

Own every UI state the timeline can be in as an explicit cubit state, and land all
vi/en strings the remaining UI phases consume, so P5–P7 build widgets against a
finished state contract.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-timeline-state-strings.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/timeline/presentation/timeline_cubit.dart`
  - `mobile/lib/features/timeline/presentation/timeline_state.dart`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/test/features/timeline/presentation/timeline_cubit_test.dart`
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
  - `TimelineState`: `loading`, `ready(entries, isOffline)`, `empty`, `offlineNoCache`, `error(CupidApiFailure)`
  - `TimelineCubit.load()` / `retry()` and an `isOffline` flag the create sheet reads
  - All timeline vi/en message keys (screen, entry card, sheet, entry-point card)
- Shared Interfaces Consumed:
  - P3 `TimelineRepository`
  - generated `AppL10n` (`flutter: generate: true`, `l10n.yaml`)
- Risk Surfaces:
  - Drift read-through cache (state derivation)
  - Offline write prohibition (the `isOffline` flag P6 gates Save on)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §2 States; `../architecture/solution.md` §2 mobile contract
  - consumer contract: `TimelineState` + message keys, consumed by P5, P6, P7
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC2, AC3
  - architecture: `../architecture/solution.md` §2, §4 error contract
  - OQ constraints: ADR-007 — offline is a first-class state, not an error
  - upstream phase outputs: P3 `TimelineRepository` and `TimelineRefreshOutcome`
  - UX constraints, if truly required: `../ux/uiux-spec.md` §2 — all six states, including the distinction between "no memories yet" and "can't load your timeline yet"
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: state machine + localization, no widgets
  - Source/Test File Count: 5 (two are additive `.arb` edits)
  - Split Required: NO

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md` §2, §4
- `../ux/uiux-spec.md` §2 States (and §1.3 only for the sheet's copy keys)
- P3 outputs
- `mobile/lib/l10n/arb/app_en.arb` and `app_vi.arb` (for the existing key style)

## 3. Tasks

- Define `TimelineState` as a sealed/immutable state set matching UX §2 exactly: `loading` (drives the 5-card skeleton), `ready(entries, isOffline)`, `empty` (synced, zero entries), `offlineNoCache` (never synced and unreachable), `error(failure)`.
- Implement `TimelineCubit`: subscribe to `repository.watchEntries()` on `load()`, trigger `refresh()`, and map `TimelineRefreshOutcome` to state — `synced` → `ready`/`empty`, `offlineWithCache` → `ready(isOffline: true)`, `offlineNoCache` → `offlineNoCache`, `failed` → `error`. Never drop cached entries because a refresh failed.
- Expose `retry()` re-running `refresh()` without tearing down the stream subscription, and cancel the subscription in `close()`.
- Add all vi/en keys in one contiguous block per file: screen title, offline banner, empty heading/body, offline-no-cache heading/body, generic error + retry label, "auto-added" pill, add-memory CTA, sheet title/field labels/validation/save/cancel, offline-save-blocked copy, pairing-required copy, and the entry-point card label. Use the vi/en copy already given in `../ux/uiux-spec.md` §1 and §2 where it exists.
- Keep the `.arb` edits additive and contiguous — both files are merge hotspots in this wave.

## 4. Acceptance Criteria

- Each of the five states is reachable and asserted by a test.
- `offlineWithCache` yields `ready(isOffline: true)` with the cached entries still present.
- A synced-empty timeline yields `empty`, while never-synced-and-offline yields `offlineNoCache` — the two are never conflated.
- A refresh failure never clears already-emitted entries.
- `retry()` re-attempts refresh and can transition `offlineNoCache` → `ready`.
- `flutter pub get` regenerates `AppL10n` with every new key present in both locales, and no key exists in only one locale.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: cubit + state files; both `.arb` files
- Contracts or schemas: `TimelineState` and the timeline message-key set
- Notes or evidence: none beyond tests

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), cubit unit tests with a fake repository
- Required levels:
  - unit: state transitions for all five states, offline derivation, cache retained on refresh failure, `retry()` recovery, subscription cancelled on close
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: `flutter test test/features/timeline/presentation/timeline_cubit_test.dart`, `flutter analyze`, and a localization check that both `.arb` files carry the same key set
- Mobile discoverability / navigation integration: N/A for this phase (no widgets)
- Minimum gates by risk surface:
  - Drift read-through cache: cached entries survive a failed refresh
  - Offline write prohibition: `isOffline` is exposed and asserted for P6 to gate on
- Evidence format: concise rows added to `coding-plan/test-results.md` by P8
- Verification strategy:
  - Targeted tests/regression/contract checks: the cubit test file
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: emitted state sequences and locale key parity

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
