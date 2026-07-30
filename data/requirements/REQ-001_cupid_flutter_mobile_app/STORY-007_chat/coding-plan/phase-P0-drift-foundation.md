# Phase P0 – Drift Foundation (chat table slice)

## 1. Objective

Land the app's single Drift owner (`core/database/`) with the chat-only table
slice and a `MessageDao` that supports id-keyed upsert and ascending paged
reads. This is the ADR-007 / F5 persistence seam every later phase consumes.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-drift-foundation.md`
- Owner: Mobile Developer
- Lane: Mobile (contract-first)

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/pubspec.yaml`
  - `mobile/lib/core/database/**`
  - `mobile/test/core/database/**`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A (interactive, needs a connected device)
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `CupidDatabase` (schemaVersion 1)
  - `MessageDao`
- Shared Interfaces Consumed:
  - None
- Risk Surfaces:
  - Local persistence (ADR-007)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §2 "Data model / migration contract"
  - consumer contract: `MessageDao` as listed in `master-plan.md` §3
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2 (Mobile contract, Data model contract), §4 Risk Surfaces row "Local persistence"
  - OQ constraints: `../architecture/solution.md` §3 (OQ4/ADR-007 — no offline write queue)
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: local chat persistence seam only — no feature code, no UI
  - Source/Test File Count: 5 authored (`pubspec.yaml`, `cupid_database.dart`, `messages_table.dart`, `message_dao.dart`, `message_dao_test.dart`) + 1 generated (`cupid_database.g.dart`)
  - Split Required: NO
  - Split Rationale: fits one specialist lifecycle

## 2. Required Reads

- `../architecture/solution.md` §2, §3, §4 Risk Surfaces
- `mobile/pubspec.yaml`

## 3. Tasks

- Add the Drift dependency set to `mobile/pubspec.yaml`: `drift`, `sqlite3_flutter_libs`, `path_provider` under `dependencies`; `drift_dev` and `build_runner` under `dev_dependencies`. Keep the existing pin style.
- Create `mobile/lib/core/database/tables/messages_table.dart` declaring the `Messages` table with exactly these columns and no others: `id` (text, primary key — the server `Message.id` uuid), `senderId` (text), `receiverId` (text), `content` (text), `type` (text), `status` (text), `readAt` (dateTime, nullable), `createdAt` (dateTime), `cachedAt` (dateTime).
- Do **not** add `localId`, `pending`, `queued`, `outbox`, `retryCount`, `sendState`, or any equivalent. Their absence is the AC4 gate (`../architecture/solution.md` §2 invariant 2).
- Create `mobile/lib/core/database/cupid_database.dart` with the `@DriftDatabase` annotation, `schemaVersion => 1`, and a `QueryExecutor` opened from `path_provider`'s application-documents directory. Accept an injectable executor so tests can pass an in-memory database.
- Add a short doc comment stating that `core/database/` is the app's single Drift owner and that later long-history domains (timeline, expenses per ADR-007) add their tables here, because `core/` must never import `features/`.
- Create `mobile/lib/core/database/daos/message_dao.dart` exposing:
  - `Future<void> upsertAll(List<MessageRow>)` using `insertOnConflictUpdate` so re-fetching the same server `id` never duplicates a row.
  - `Future<List<Message>> pageForPartner({required String myId, required String partnerId, required int limit, required int offset})` returning **ascending** `createdAt` order (the REST source is newest-first; ordering is normalized here, not in the UI).
  - `Stream<List<Message>> watchForPartner({required String myId, required String partnerId, required int limit})` for the thread view.
  - `Future<void> markSeenLocally({required String senderId, required String receiverId})` setting `status = 'seen'` and `readAt`.
  - `Future<void> clearAll()` for sign-out teardown.
- Run `dart run build_runner build --delete-conflicting-outputs` and commit the generated `cupid_database.g.dart`.
- Write `mobile/test/core/database/message_dao_test.dart` against an in-memory database.

## 4. Acceptance Criteria

- `flutter pub get` and `dart run build_runner build` both succeed; the generated file is committed.
- Upserting the same server `id` twice leaves exactly one row, with the second write's values.
- `pageForPartner` returns rows in ascending `createdAt` order and respects `limit`/`offset` for both directions of the conversation (rows where I am sender and rows where I am receiver).
- A test asserts the `messages` table exposes no column whose name matches `pending`, `queued`, `outbox`, `retry`, `local`, or `sendState` (enumerate the generated column set and assert the absence).
- `flutter analyze` reports no new issues.

## 5. Planned Outputs

- Code: `mobile/lib/core/database/cupid_database.dart`, `mobile/lib/core/database/cupid_database.g.dart`, `mobile/lib/core/database/tables/messages_table.dart`, `mobile/lib/core/database/daos/message_dao.dart`, `mobile/pubspec.yaml`
- Contracts: `CupidDatabase` (schemaVersion 1), `MessageDao`
- Requirement configuration guide updates: none
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, local persistence layer (no UI)
- Required levels:
  - unit: DAO upsert dedupe, ascending paged read for both conversation directions, `markSeenLocally`, schema-column-absence assertion
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: `dart run build_runner build --delete-conflicting-outputs` completes and the generated file is committed
- Mobile discoverability / navigation integration: N/A — this phase ships no user-visible surface; discoverability is P4's gate
- Minimum gates by risk surface:
  - Local persistence (ADR-007): double-upsert yields one row; paged read ascending; schema-absence assertion passes
- Required regression or contract coverage: none (new module, no existing consumers)
- Evidence format: concise rows recorded by P5 in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/core/database/`
  - Build/type-check/lint command: `flutter analyze`
  - Required assertion evidence: row-count assertion after double upsert; ordering assertion; enumerated column-name set

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
