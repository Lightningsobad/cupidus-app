# Phase P1 – Expense Contract, Models, And Dio-Direct Repository

## 1. Objective

Establish the expenses contract layer every later phase consumes: domain models,
category mapping sourced from the generated enum, typed failures, and a
Dio-direct `ExpensesRepository` for `GET /expenses` and `POST /expenses`.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-expense-contract-repository.md`
- Owner: Mobile Developer
- Lane: Contract

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/expenses/data/expense_category.dart`
  - `mobile/lib/features/expenses/data/expense_models.dart`
  - `mobile/lib/features/expenses/data/expenses_failure.dart`
  - `mobile/lib/features/expenses/data/expenses_repository.dart`
  - `mobile/test/features/expenses/data/expense_models_test.dart`
  - `mobile/test/features/expenses/data/expenses_repository_test.dart`
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
  - `Expense`, `ExpenseCategory` domain models
  - `ExpensesRepository.fetchPage({limit, offset})`, `ExpensesRepository.create(...)`
  - `ExpensesNotPairedFailure`
- Shared Interfaces Consumed:
  - `mobile/lib/core/network/cupid_api.dart` (`CupidApi.dio`, `HttpStatusFailure`)
  - `package:cupid_api` `CreateExpenseDtoCategoryEnum` (via `core/network/cupid_api.dart` only)
  - `mobile/lib/core/realtime/backend_user_id_store.dart` (own backend user id)
- Risk Surfaces:
  - `amount` wire type (String from `GET`, num from `POST`)
  - Unpaired 404 mapping (AC4 foundation)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §2 Downstream Contract Summary; `backend/src/modules/expenses/**` (read-only)
  - consumer contract: P2/P3/P4 import these models and this repository; nothing else may call `/expenses`
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC2, AC4
  - architecture: `../architecture/solution.md` §2, ADR-015.1, ADR-015.2, ADR-015.4, ADR-015.4a
  - OQ constraints: A1 — backend frozen, no endpoint edits
  - upstream phase outputs: none
  - UX constraints: none required for this phase
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: typed, tested access to the frozen expenses contract
  - Source/Test File Count: 4 source + 2 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2 and §7 (ADR-015.1, ADR-015.2, ADR-015.4, ADR-015.4a)
- `../story_master.md`
- `mobile/lib/features/auth/data/auth_repository.dart` — the Dio-direct precedent to follow, including how it rethrows `DioException.error`
- `backend/src/modules/expenses/entities/expense.entity.ts` and `dto/create-expense.dto.ts` — read-only field reference

## 3. Tasks

- Create `ExpenseCategory` mapping over the generated `CreateExpenseDtoCategoryEnum`
  (`food`, `date`, `travel`, `shopping`, `other`). Do **not** hand-copy the enum
  values; derive from the generated enum so a regenerated client cannot drift.
  Include a display label + icon key per category for P3/P4 to consume.
- Create the `Expense` model with a `fromJson` that:
  - accepts `amount` as **either** `String` (`"250000.00"`) or `num` (`250000`)
    and normalizes to a single numeric representation;
  - parses `date` as a date-only `'YYYY-MM-DD'` value and `createdAt` as an ISO
    timestamp;
  - treats `description` as nullable;
  - tolerates an unknown `category` string by falling back to `other` rather
    than throwing.
- Create `expenses_failure.dart` with `ExpensesNotPairedFailure` (and any other
  narrow typed failure needed), built on the existing `CupidApiFailure` family.
- Create `ExpensesRepository` taking `CupidApi` by constructor injection:
  - `fetchPage({int limit = 50, int offset = 0})` → `_api.dio.get<Object?>('/expenses', queryParameters: {'limit': '$limit', 'offset': '$offset'})`, decoded to `List<Expense>`;
  - `create({required ExpenseCategory category, required num amountVnd, String? description, required DateTime date})` → `_api.dio.post<Object?>('/expenses', data: …)`, decoded to the created `Expense`;
  - send `date` as the local calendar date at `T00:00:00.000Z` (R-015.6) and
    reject a future date before the request is issued;
  - map a 404 (`HttpStatusFailure.statusCode == 404`) to
    `ExpensesNotPairedFailure`; rethrow `DioException.error` otherwise, never the
    raw `DioException`.
- Do **not** call `GET /expenses/report` (ADR-015.3) and do **not** implement
  delete (not an AC).
- Do **not** use the generated `Epic5ExpensesApi` methods — they return
  `Response<void>` and cannot yield a body (ADR-015.1).

## 4. Acceptance Criteria

- `Expense.fromJson` decodes both `"250000.00"` and `250000` for `amount` to the
  same value, and an unknown category to `other`.
- `fetchPage` issues `GET /expenses` with string `limit`/`offset` query params and
  returns decoded models in server order.
- `create` issues `POST /expenses` with exactly the four contract fields and no
  invented field (no `userId`, no `paidBy`, no `currency`, no split field).
- A 404 from either call surfaces as `ExpensesNotPairedFailure`.
- A future `date` is rejected client-side before any request is sent.
- `flutter analyze` is clean; no direct `package:cupid_api/...` import and no
  `Dio` construction in this phase's files.

## 5. Planned Outputs

- Code directories or files: the six files in the Write Scope above
- Contracts or schemas: `Expense`, `ExpenseCategory`, `ExpensesRepository`, `ExpensesNotPairedFailure`
- Requirement configuration guide updates: none
- Notes or evidence: test output pasted into the phase Status section

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, data layer
- Required levels:
  - unit: `Expense.fromJson` (both `amount` wire types, null description, unknown category, date-only parsing); `ExpensesRepository` with a mocked/`DioAdapter` Dio for both calls, 404 → `ExpensesNotPairedFailure`, future-date rejection
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: no `package:cupid_api/...` direct import; no `Dio()` construction; request body contains exactly the four contract fields
- Mobile discoverability / navigation integration: N/A for this phase
- Minimum gates by risk surface: `amount` wire type ⇒ dual-fixture unit test; unpaired 404 ⇒ failure-mapping unit test
- Required regression or contract coverage: assert the outgoing `POST` body keys match `CreateExpenseDto` exactly
- Evidence format: `flutter test` + `flutter analyze` output excerpt in §7
- Verification strategy:
  - Targeted tests/regression/contract checks: the two test files above
  - Build/type-check/lint command when required: `flutter analyze`, `flutter test test/features/expenses/`
  - Required assertion evidence: passing dual-fixture amount test and 404 mapping test

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
