# Master Coding Plan – STORY-015 Chi Tiêu Chung (Shared Expenses)

## 1. Planning Metadata

- Story ID: STORY-015
- Complexity: M (`standard`)
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md` (AC1-AC4)
- Source UX: `../ux/uiux-spec.md` §3-§8
- Source Architecture: `../architecture/solution.md` (§2 Downstream Contract Summary, §7 ADR-015.1-015.7, §8 risks)
- OQ Constraints Source: ADR-007 (OQ4) and A1, carried in `../architecture/solution.md` §3
- Review Input: none yet
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` — **NOT_APPLICABLE** for this story (no env var, secret, or third-party integration change)

## 2. Planning Goal

- Shared contract owner: Mobile Developer (P1 owns the expense models + repository contract that P2-P5 consume)
- Contract-first phase required: YES — P1
- Parallel execution possible: NO — single mobile lane, strictly sequential dependency chain
- Critical path: P1 → P2 → P3 → P4 → P5 → P6
- Parallelism notes: P4 (add sheet) and P5 (gate + entry point) are both P3-dependent and could in principle interleave, but they share `expenses_route.dart` and the same screen scaffold, so they stay sequential. There is no second lane to parallelize into.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|----------------------|-------|--------------------|----------------|----------------|----------------------------|
| `Expense` / `ExpenseCategory` domain models | Mobile Dev | direct Dart import | P1 | P2, P3, P4 | `Expense(id, userId, category, amountVnd, description, date, createdAt)` |
| `ExpensesRepository` | Mobile Dev | `get_it` injection | P1 | P3, P4 | `Future<List<Expense>> fetchPage({int limit, int offset})`, `Future<Expense> create(...)` |
| `ExpenseDao` + `expense_sync_metadata` | Mobile Dev | `get_it` injection | P2 | P3, P4 | `watchPage({limit, offset})`, `lastSuccessfulSyncAt` |
| Canonical Drift owner `CupidDatabase` (`mobile/lib/core/database/cupid_database.dart`, fixed by **ADR-010**) | **STORY-007 (external)** | additive table + DAO registration | external | P2 | `@DriftDatabase(tables: [Messages, ..., Expenses, ExpenseSyncMetadata], daos: [MessageDao, ..., ExpenseDao])` |
| `PairingStateReader` | Mobile Dev | `get_it` injection | P5 | P5 | `Future<bool> isPaired()` |
| `expensesRoute` named route | Mobile Dev | Navigator route table | P5 | P5 | `/expenses` → `ExpenseHistoryScreen` |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|--------------|-----------------|-------------------|--------------|---------------------|----------------------------|
| `amount` wire type (String or num) | `expense.entity.ts:25`; `expenses.service.ts:107` | tolerant decoder | unit test with `"250000.00"` **and** `250000` | none | cannot decode live payloads ⇒ blocker |
| Unpaired 404 gating (AC4) | `expenses.service.ts:20-26` | 404 ⇒ `ExpensesNotPairedFailure` ⇒ gate | repository unit test + gate widget test | P1, P5 | AC4 unmet ⇒ blocker |
| Offline read from cache (AC3) | `ExpenseDao` + sync-metadata | cached rows render; freshness caption | in-memory Drift DAO test + widget test both empty states | P2 | AC3 unmet ⇒ blocker |
| Offline write fail-fast (ADR-007) | ADR-007 bound (b) | inline error + Retry; no queue, no optimistic row | `bloc_test` asserting no optimistic emit and no DAO insert | P4 | ADR-007 violated ⇒ blocker |
| Canonical Drift owner | `CupidDatabase` in `mobile/lib/core/database/cupid_database.dart` (ADR-010) | exactly one owner class | codegen + `flutter analyze` clean | ADR-010 (RESOLVED); `cupid_database.dart` present on P2's base | file absent at dispatch ⇒ blocker, escalate; never create a database class |
| Discoverability | `home_screen.dart` entry affordance | feature reachable by tap | widget test navigating entry → history screen | P5 | orphaned feature ⇒ blocker |
| Money-number correctness | cached rows only (ADR-015.3) | hide delta when cache is incomplete | unit test on the aggregator with a partial-cache fixture | P3 | wrong money shown ⇒ blocker |

## 4. Lane Summary

- Backend required: NO — A1 frozen, read-only reference only
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer (P1)
- Final verification owner: Mobile Developer (P6)
- Shared contract owner: Mobile Developer (P1)
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` for implementation phases (registry readiness is a widget-test signal, not an HTTP probe), command/source runtime registry `testCommand` = `flutter test`, `buildCommand` = `flutter build apk --debug`. Flutter SDK is **not on PATH** on this machine — resolve via `FLUTTER_SDK_PATH` (default `$HOME/flutter`) per the registry `sdk.resolutionOrder`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P1 | Mobile Developer | Contract | None | NO | `mobile/lib/features/expenses/data/expense_models.dart`, `expense_category.dart`, `expenses_repository.dart`, `expenses_failure.dart`; `mobile/test/features/expenses/data/*` | `../architecture/solution.md` §2, ADR-015.1/015.2/015.4/015.4a | domain models, category mapping, Dio-direct repository, typed failures | unit (decoder both wire types, repository with mocked Dio, 404 mapping); `flutter analyze` | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/core/database/tables/expenses_table.dart`, `mobile/lib/core/database/daos/expense_dao.dart`; one additive registration edit to `mobile/lib/core/database/cupid_database.dart` (class `CupidDatabase`, ADR-010); `mobile/test/core/database/expense_dao_test.dart` | ADR-010, ADR-015.5, ADR-015.6, P1 models | additive Drift tables + DAO + sync-metadata, schema bump, codegen output | integration (in-memory Drift: insert/upsert, paging, sync-metadata null vs set); `flutter analyze` | DONE |
| P3 | Mobile Developer | Mobile | P1, P2 | NO | `mobile/lib/features/expenses/presentation/expense_history_cubit.dart`, `expense_month_summary.dart`, `expense_strings.dart`, `screens/expense_history_screen.dart`, `widgets/expense_list_item.dart`; `mobile/test/features/expenses/presentation/*` | UX §4, §5, §7; ADR-015.3, ADR-015.5 | history screen, paged read-through, month aggregation, freshness caption, two empty states | unit (aggregator incl. partial cache), `bloc_test`, widget (both empty states, offline caption); `flutter analyze` | NOT_STARTED |
| P4 | Mobile Developer | Mobile | P3 | NO | `mobile/lib/features/expenses/presentation/add_expense_cubit.dart`, `widgets/add_expense_sheet.dart`; `mobile/test/features/expenses/presentation/add_expense_*` | UX §3, §5, §7, §8; ADR-015.2, ADR-015.4, ADR-015.4a | add-expense bottom sheet, validation, fail-fast offline + Retry | `bloc_test` (no optimistic emit, no DAO insert on failure), widget (validation, offline banner, Retry, focus trap); `flutter analyze` | NOT_STARTED |
| P5 | Mobile Developer | Mobile | P4 | NO | `mobile/lib/features/expenses/data/pairing_state_reader.dart`, `presentation/widgets/pairing_required_gate.dart`, `expenses_route.dart`; `mobile/lib/features/home/presentation/home_screen.dart` (additive edit); `mobile/lib/core/di/service_locator.dart` (additive registration); `mobile/test/features/expenses/*` | UX §6; ADR-015.7; R-015.2 | pairing gate, named route, discoverable entry affordance, DI registration | widget (gate for unpaired, entry→screen navigation, readiness key preserved); unit (`PairingStateReader`); `flutter analyze` | NOT_STARTED |
| P6 | Mobile Developer | Mobile | P5 | NO | `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/test-results.md` | all prior phase outputs, AC1-AC4 | AC1-AC4 verification evidence, full `flutter test` + `flutter analyze` + `flutter build apk --debug` | full `flutter test`, `flutter analyze`, mobile build; AC traceability table | NOT_STARTED |

The final phase (P6) is the required verification phase for this `standard` story.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-expense-contract-repository.md` |
| P2 | `phase-P2-drift-cache-additive.md` |
| P3 | `phase-P3-history-screen.md` |
| P4 | `phase-P4-add-expense-sheet.md` |
| P5 | `phase-P5-pairing-gate-entry-point.md` |
| P6 | `phase-P6-verification.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file; no duplicates.
- Every implementation phase fits one specialist lifecycle (P1 4+2, P2 2+1 edit+1, P3 5+2, P4 2+2, P5 5+2 files).
- Implementation phase test scopes exclude backend e2e/test_e2e, Playwright/browser e2e, mobile e2e, emulator/simulator lifecycle, signing, store upload, traces, scenario reruns, repository-root local script gates, and runtime startup smoke.

## 6. Risks And Notes

- Risks:
  - **R-015.1 — RESOLVED by ADR-010** (`data/architecture/system/system_architecture_memory.md` §7). The canonical Drift owner is **`CupidDatabase` in `mobile/lib/core/database/cupid_database.dart`** (from STORY-007), using the `tables/` + `daos/` layout. STORY-012's `AppDatabase` is SUPERSEDED and folds into it at merge time, carrying its `SessionScopedStore.clearOnSignOut()` contract across — that fold is STORY-012's work, not this story's. Residual for P2: `cupid_database.dart` must actually be present on P2's base before dispatch; if it is absent, or if `app_database.dart` still exists unfolded, escalate to Scrum Master. P2 must not create a database class under any circumstance.
  - **R-015.2 (MEDIUM)** P5's entry-point edit touches `home_screen.dart`, a file every sibling story may also touch, and the 5-tab shell / `jar` screen entry point from UX §2 does not exist yet. Keep the edit minimal and additive, and preserve `Key('home_screen_ready_signal')` — it is the `mobile-app` runtime readiness contract.
  - R-015.3 `amount` may arrive as a String (`GET`) or a num (`POST`); one tolerant decoder, tested both ways.
  - R-015.5 Client-side month aggregation over a partial cache can produce a wrong delta — hide it rather than show it wrong.
  - **R-015.6 (NEW, P2 collateral, LOW)** P2's mandated additive `schemaVersion` bump (1 → 2) on `CupidDatabase` makes `mobile/test/core/database/timeline_dao_test.dart:36` (`expect(database.schemaVersion, 1)`, STORY-007-owned, outside P2's `WriteScope`) fail. Not a P2 defect — `mobile/test/core/database/expense_dao_test.dart` passes fully in isolation (9/9) and `flutter analyze` is clean for all P2 files. Needs a one-line literal fix (`1` → `2`) in that sibling file, out of P2's write scope; Scrum Master to route as a trivial follow-up before the `flutter test test/core/database/` gate is fully green.
- OQ-driven constraints: ADR-007 — Drift is a read-through, server-authoritative cache **and there is no offline write/outbox queue**; offline saves fail fast with a user-initiated Retry, never "queued" copy, never an optimistic row. A1 — the `expenses` backend is frozen; no phase may edit `backend/`.
- Migration / rollout notes: additive Drift schema bump only. The cache is disposable and rebuildable from the server, so a destructive-recreate migration is acceptable for these two tables.
- Notes:
  - Three UX-spec elements are deliberately **not** built as specified, per confirmed contract limits: the "Paid by" partner toggle (ADR-015.2 — display-only), literal partner display names (ADR-015.2 — no partner-profile endpoint exists), and `/expenses/report` as the summary source (ADR-015.3 — client-side aggregation instead). Reviewer should check these against the solution's ADRs rather than against the UX spec verbatim.
  - Expense **delete** exists in the contract but is not an AC and ships no UI in this story.
