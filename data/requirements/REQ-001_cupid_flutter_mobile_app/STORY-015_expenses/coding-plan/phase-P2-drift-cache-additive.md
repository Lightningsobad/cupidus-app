# Phase P2 – Additive Drift Cache And Sync Metadata

## 1. Objective

Add the expenses read-through cache as an **additive** extension to the single
canonical mobile Drift database: an `Expenses` table, an `ExpenseSyncMetadata`
single-row table, and an `ExpenseDao` supporting paged reads.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-drift-cache-additive.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1; **R-015.1 canonical-Drift-owner decision (see §1C)**
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/database/expenses_table.dart`
  - `mobile/lib/core/database/expense_dao.dart`
  - the canonical database class file — **additive registration edit only**
  - `mobile/test/core/database/expense_dao_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A for this phase
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ExpenseDao.watchPage({limit, offset})` / `getPage({limit, offset})`
  - `ExpenseDao.upsertAll(List<Expense>)`
  - `ExpenseDao.lastSuccessfulSyncAt` / `markSyncedNow()`
  - `ExpenseDao.monthRows(DateTime month)` for P3's aggregation
- Shared Interfaces Consumed:
  - P1 `Expense` / `ExpenseCategory` models
  - the canonical Drift database class (external, from a sibling story)
- Risk Surfaces:
  - Canonical Drift owner conflict (R-015.1)
  - Offline read correctness (AC3)
  - Never-synced vs. zero-expenses discrimination (ADR-015.5)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` ADR-015.5, ADR-015.6
  - consumer contract: P3 and P4 read and invalidate the cache only through `ExpenseDao`
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC2, AC3
  - architecture: `../architecture/solution.md` ADR-015.5, ADR-015.6, §5 (paging, R4)
  - OQ constraints: ADR-007 — Drift is a **read-through cache**, server-authoritative; no outbox, no pending-write table of any kind
  - upstream phase outputs: P1 models
  - UX constraints: none required beyond the two empty-state signals
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: local cache + paging + sync-provenance signal
  - Source/Test File Count: 2 new source + 1 additive edit + 1 test (plus generated codegen output)
  - Split Required: NO

## 1C. Hard Constraint — Do Not Create A Database Class

STORY-015 must **not** create a Drift database class. Two owners are already in
flight in this wave (`cupid_database.dart` from STORY-007 and `app_database.dart`
from STORY-012) and neither exists at this story's `BaseHead` (`d9af8b5`).

- ADR-015.6 tie-breaks to `CupidDatabase` in
  `mobile/lib/core/database/cupid_database.dart` on the repo-wide `Cupid*`
  naming convention.
- Before starting, confirm which owner class actually exists on the integration
  branch and register into **that one**.
- If neither exists yet, or if both exist, **stop and escalate to Scrum Master**
  (R-015.1). Do not proceed by creating a third database.

## 2. Required Reads

- `../architecture/solution.md` ADR-015.5, ADR-015.6
- the canonical database class file, to match its existing table-registration and
  schema-version style
- an existing sibling DAO in `mobile/lib/core/database/` as the local convention
  example, if one is present

## 3. Tasks

- Create `expenses_table.dart` with:
  - `Expenses` — `id` (text, primary key), `userId` (text), `category` (text),
    `amount` (real or int in a single documented unit), `description`
    (nullable text), `date` (text `'YYYY-MM-DD'` or `DateTime`, chosen to keep
    `date DESC, createdAt DESC` ordering identical to the server),
    `createdAt` (`DateTime`).
  - `ExpenseSyncMetadata` — a single-row table with a fixed primary key and
    `lastSuccessfulSyncAt` (nullable `DateTime`).
- Create `ExpenseDao` with:
  - `upsertAll(List<Expense>)` — idempotent by `id`, so a re-fetched page cannot
    duplicate rows;
  - `getPage({limit, offset})` / `watchPage({limit, offset})` ordered
    `date DESC, createdAt DESC` — **paged queries only**, never a full-table read
    into memory (system memory §5 line 76, R4);
  - `monthRows(DateTime month)` for P3's client-side aggregation;
  - `lastSuccessfulSyncAt` getter and `markSyncedNow()`, written **only** after a
    successful server fetch;
  - `countAll()` so P3 can distinguish "zero rows" from "no page loaded yet".
- Register both tables in the canonical database class and bump its
  `schemaVersion`. A destructive-recreate migration for these two cache tables is
  acceptable (ADR-015.6 / ADR-007 — the cache is disposable).
- Run Drift codegen and commit the generated output alongside the source, matching
  the existing repo convention.
- Do **not** add a pending-write, outbox, or draft table. ADR-007 forbids it.

## 4. Acceptance Criteria

- `upsertAll` called twice with the same page yields no duplicate rows.
- `getPage` returns rows in `date DESC, createdAt DESC` order and honors
  `limit`/`offset`.
- `lastSuccessfulSyncAt` is `null` on a fresh database and non-null only after
  `markSyncedNow()`.
- `countAll() == 0` with `lastSuccessfulSyncAt == null` is distinguishable from
  `countAll() == 0` with a non-null timestamp (this is the ADR-015.5 signal P3
  depends on).
- Exactly one Drift database class exists in `mobile/lib/core/database/` after
  this phase.
- Codegen output is committed; `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: Write Scope files plus generated Drift output
- Contracts or schemas: `Expenses`, `ExpenseSyncMetadata`, `ExpenseDao`
- Requirement configuration guide updates: none
- Notes or evidence: test output in §7; the canonical owner class actually used

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, local persistence
- Required levels:
  - integration: `ExpenseDao` against an in-memory Drift database — upsert
    idempotency, paging/order, sync-metadata null-vs-set, `countAll`
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: exactly one database class present; no outbox/pending-write
  table introduced; codegen output committed and in sync with source
- Mobile discoverability / navigation integration: N/A for this phase
- Minimum gates by risk surface: offline read ⇒ paging/order integration test;
  ADR-015.5 ⇒ sync-metadata discrimination test; R-015.1 ⇒ single-owner check
- Required regression or contract coverage: DAO ordering must match the server's
  `date DESC, createdAt DESC`
- Evidence format: `flutter test` + `flutter analyze` output excerpt in §7
- Verification strategy:
  - Targeted tests/regression/contract checks: `expense_dao_test.dart`
  - Build/type-check/lint command when required: `flutter analyze`, `flutter test test/core/database/`
  - Required assertion evidence: passing idempotency, ordering, and
    sync-metadata discrimination assertions

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
