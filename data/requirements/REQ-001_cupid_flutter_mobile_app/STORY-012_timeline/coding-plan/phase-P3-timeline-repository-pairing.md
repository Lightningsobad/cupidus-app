# Phase P3 – Read-Through Repository And Pairing Store

## 1. Objective

Join the Drift cache and the remote source into the single feature-facing seam
(`TimelineRepository`) implementing ADR-007 read-through semantics, and add the
minimal cached pairing status the AC4 gate needs offline.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-timeline-repository-pairing.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/timeline/data/timeline_repository.dart`
  - `mobile/lib/core/couple/couple_pairing_store.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/timeline/data/timeline_repository_test.dart`
  - `mobile/test/core/couple/couple_pairing_store_test.dart`
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
  - `TimelineRepository.watchEntries()` / `refresh()` → `TimelineRefreshOutcome` / `createEntry(TimelineDraft)`
  - `TimelineRefreshOutcome` = `synced | offlineWithCache | offlineNoCache | failed(CupidApiFailure)`
  - `CouplePairingStore.resolve()` → `PairingStatus.paired | unpaired | unknown`
- Shared Interfaces Consumed:
  - P1 DAO methods, P2 `TimelineRemoteDataSource` and `TimelineEntry`
  - `CupidSession.registerScopedStore`, `shared_preferences`, `mobile/lib/core/network/cupid_api.dart`
- Risk Surfaces:
  - Drift read-through cache (ADR-007)
  - Offline write prohibition (ADR-007)
  - AC4 pairing gate that must hold offline
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §2 mobile contract, §3 OQ table, §4 error contract
  - consumer contract: repository and pairing-store signatures above, consumed by P4, P6, P7
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC2, AC3, AC4
  - architecture: `../architecture/solution.md` §2, §3, §4
  - OQ constraints: ADR-007 — read-through only, no offline write queue, no optimistic insert
  - upstream phase outputs: P1 `AppDatabase`, P2 `TimelineRemoteDataSource` / `TimelineEntry`
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: caching policy and pairing resolution, no UI
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md` §2, §3, §4
- P1 and P2 outputs
- `mobile/lib/core/auth/cupid_session.dart` (`SessionScopedStore`, `registerScopedStore` only)
- `mobile/lib/core/di/service_locator.dart`

## 3. Tasks

- Implement `TimelineRepository`:
  - `watchEntries()` returns the Drift stream mapped to `TimelineEntry`. This is the only read path the UI sees — never return network results directly.
  - `refresh()` calls the remote source, writes the page through `replaceFirstPage()`, and returns `synced`. On `NetworkUnavailableFailure` / `TimeoutFailure`, return `offlineWithCache` when `lastSyncedAt() != null` and `offlineNoCache` when it is `null`; do not clear the cache. On any other `CupidApiFailure`, return `failed(failure)` and leave the cache untouched.
  - `createEntry(draft)` calls `POST /timeline` and, on success, calls `refresh()` so the server-assigned id and `createdAt` become the local truth. On failure, rethrow the `CupidApiFailure` and write nothing locally. No optimistic insert, no outbox, no automatic retry (ADR-007).
- Implement `CouplePairingStore implements SessionScopedStore`:
  - `resolve()` returns the cached `PairingStatus` immediately if present, then refreshes it in the background from `GET /users/me` (`partnerId != null` → `paired`, else `unpaired`).
  - With no cached value and no connectivity, return `unknown` — never guess `paired`.
  - Persist the resolved status in `shared_preferences` keyed per backend user id so it survives restart and satisfies AC4 offline.
  - `clearOnSignOut()` removes the persisted value.
- Register `TimelineRepository` and `CouplePairingStore` in `service_locator.dart` and register the pairing store as a session-scoped store. Keep the edit additive and contiguous.

## 4. Acceptance Criteria

- `watchEntries()` emits cached content before any network call completes.
- A successful `refresh()` replaces the first page and the stream re-emits.
- With a populated cache and no connectivity, `refresh()` returns `offlineWithCache` and the cached rows remain readable (AC3).
- With no prior sync and no connectivity, `refresh()` returns `offlineNoCache`.
- A synced-but-empty timeline is distinguishable from never-synced.
- `createEntry` failure leaves zero new rows in Drift and rethrows a `CupidApiFailure`.
- `resolve()` returns `paired`/`unpaired` from cache while offline, `unknown` when nothing is cached and the network is unavailable, and nothing survives sign-out.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the two source files in Write Scope plus DI registration
- Contracts or schemas: `TimelineRefreshOutcome`, `PairingStatus`
- Notes or evidence: none beyond tests

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), unit tests with in-memory Drift and a fake remote source
- Required levels:
  - unit: read-through order; offline-serves-cache; never-synced vs synced-empty; create fail-fast with no local write; pairing cached / offline / unknown / cleared on sign-out
  - integration: repository over a real in-memory `AppDatabase` plus a fake remote source (no network, no device)
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: `flutter test test/features/timeline/data/timeline_repository_test.dart test/core/couple/couple_pairing_store_test.dart`, `flutter analyze`
- Mobile discoverability / navigation integration: N/A for this phase (no UI)
- Minimum gates by risk surface:
  - Drift read-through cache: read-through and offline-with-cache tests pass
  - Offline write prohibition: post-failure row count is unchanged
  - AC4 pairing gate: all four pairing states asserted
- Required regression or contract coverage: assert `createEntry` performs exactly one `POST` and no local insert on failure
- Evidence format: concise rows added to `coding-plan/test-results.md` by P8
- Verification strategy:
  - Targeted tests/regression/contract checks: the two test files above
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: emitted stream contents, returned `TimelineRefreshOutcome` values, row counts, persisted pairing value

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
