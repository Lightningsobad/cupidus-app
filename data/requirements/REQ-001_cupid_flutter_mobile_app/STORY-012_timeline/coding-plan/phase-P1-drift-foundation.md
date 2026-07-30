# Phase P1 – Drift Persistence Foundation

## 1. Objective

Land the app's first local persistence layer: a Drift `AppDatabase` (schema v1)
with the timeline cache tables, DAO methods, and sign-out teardown, registered in
the service locator. This is the ADR-007 F5 seam that P3 consumes.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-drift-foundation.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/pubspec.yaml`
  - `mobile/lib/core/database/app_database.dart`
  - `mobile/lib/core/database/app_database.g.dart` (generated, committed)
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/core/database/app_database_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A (interactive device required per registry note)
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `AppDatabase` tables `timeline_entries` (id PK, type, title, description, photoUrl, icon, createdAt) and `timeline_sync_state` (single row, `lastSyncedAt`)
  - DAO methods `watchFirstPage()`, `replaceFirstPage(List<...>)`, `lastSyncedAt()`, `clearOnSignOut()`
- Shared Interfaces Consumed:
  - `CupidSession.registerScopedStore` (`mobile/lib/core/auth/cupid_session.dart`, read-only — do not edit that file)
- Risk Surfaces:
  - Drift read-through cache (ADR-007)
  - Session data leakage between users on one device
  - Native build after adding bundled SQLite (proved later in P8)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §2 mobile contract, §4 Risk Surfaces, §3 OQ table
  - consumer contract: the DAO methods above, consumed by P3
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC3
  - architecture: `../architecture/solution.md` §2, §3, §4
  - OQ constraints: ADR-007 — cache is read-through and server-authoritative
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (P5 writes the single note for this story)
- Phase Sizing:
  - Behavior Slice: local cache schema + lifecycle, no feature behavior
  - Source/Test File Count: 5 (one generated)
  - Split Required: NO

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md` §2, §3, §4
- `mobile/lib/core/auth/cupid_session.dart` (the `SessionScopedStore` interface and `registerScopedStore` only)
- `mobile/lib/core/di/service_locator.dart`

## 3. Tasks

- Add dependencies to `mobile/pubspec.yaml`: `drift`, `sqlite3_flutter_libs`, `path_provider`; dev dependencies `drift_dev`, `build_runner`. Do not add any other package.
- Define `timeline_entries` and `timeline_sync_state` in `app_database.dart` with `schemaVersion = 1`. Store `createdAt` as a `DateTime` column and keep the server `id` (uuid string) as the primary key — the server assigns ids, the client never generates them.
- Implement DAO methods on `AppDatabase`: `Stream<List<TimelineEntryRow>> watchFirstPage()` ordered `createdAt DESC`; `Future<void> replaceFirstPage(List<TimelineEntryRow>)` that deletes and re-inserts inside one transaction and stamps `timeline_sync_state.lastSyncedAt`; `Future<DateTime?> lastSyncedAt()`.
- Implement `AppDatabase implements SessionScopedStore` with `clearOnSignOut()` deleting all rows in both tables, and register it via `CupidSession.registerScopedStore` from `service_locator.dart`.
- Register `AppDatabase` as a lazy singleton in `service_locator.dart` using the existing registration style. Keep the edit additive and contiguous — this file is a merge hotspot in this wave.
- Run codegen and commit the output: record the exact command (`dart run build_runner build --delete-conflicting-outputs` from `mobile/`) in the phase evidence so later stories can reproduce it.
- Constructor must accept an injectable `QueryExecutor` so tests can pass an in-memory `NativeDatabase`.

## 4. Acceptance Criteria

- `AppDatabase` opens with schema version 1 and both tables exist.
- `watchFirstPage()` emits on every `replaceFirstPage()` call and returns newest-first order.
- `replaceFirstPage()` is atomic: a mid-write failure leaves the previous rows intact.
- `lastSyncedAt()` returns `null` before the first `replaceFirstPage()` and a timestamp after.
- `clearOnSignOut()` empties both tables, and the database is registered as a session-scoped store.
- No token, credential, or auth material is written to Drift.
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/core/database/app_database.dart` (+ committed `app_database.g.dart`), `mobile/pubspec.yaml`, `mobile/lib/core/di/service_locator.dart`
- Contracts or schemas: Drift schema v1; DAO method set listed in 1B
- Notes or evidence: exact `build_runner` command used

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), pure Dart unit tests
- Required levels:
  - unit: DAO behavior on an in-memory `NativeDatabase` — insert/replace ordering, atomic replace, `lastSyncedAt` null-then-set, `clearOnSignOut` wipes both tables
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: `flutter test test/core/database/app_database_test.dart`, `flutter analyze`
- Mobile discoverability / navigation integration: N/A for this phase (no UI)
- Minimum gates by risk surface:
  - Drift read-through cache: DAO unit tests pass
  - Session data leakage: sign-out wipe test passes
- Evidence format: concise rows added to `coding-plan/test-results.md` by P8
- Verification strategy:
  - Targeted tests/regression/contract checks: the DAO unit test file above
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: emitted stream contents and post-wipe row counts

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
