# STORY-015_expenses-solution.md

## 0. Metadata

- User Story ID: STORY-015
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/story_master.md`
- Complexity: M (`standard`)
- Referenced Inputs: `story_master.md` (AC1-AC4, Open Items); `ux/uiux-spec.md` §3-§8; `backend/src/modules/expenses/**` (frozen, A1); `backend/src/modules/users/entities/user.entity.ts`; `mobile/openapi/cupid_api/lib/src/api/epic5_expenses_api.dart`; `mobile/lib/features/auth/data/auth_repository.dart` (Dio-direct precedent); system architecture memory §5-§7 (ADR-006, ADR-007)
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md`
- Solution Number: 015
- Version: v1.0
- Date: 2026-07-30
- Status: Final

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: Scan Architecture (mobile expenses area is net-new; the REST contract and Drift decision already exist)
- Architecture Drivers: AC1-AC4; A1 (backend frozen); ADR-006 (generated client is REST-only); ADR-007 (Drift = server-authoritative read-through, no offline write queue); ADR-003 (Cubit for CRUD screens); R4 (low-end Android); system memory §5 line 76 (long lists paged from Drift).
- Architectural invariants / non-goals: no `expenses` endpoint change; no split/settlement/balance capability; no offline write or outbox queue; no new Drift database class.
- Proposed technical direction: a feature-first `mobile/lib/features/expenses/` module with a Dio-direct `ExpensesRepository` (the generated client cannot return typed bodies — see ADR-015.1), an **additive** Drift table + DAO registered into the single canonical database owner, and two Cubits (history, add). Reads are served from Drift and refreshed from REST; writes go straight to REST and fail fast offline.
- Why this fits the current system or new area: it reuses every existing seam (`CupidApi.dio`, `CupidErrorInterceptor` → `HttpStatusFailure`, `get_it`, adaptive widgets) and adds no new shared pattern beyond the sync-metadata row that ADR-007's UX contract requires.

## 2. Downstream Contract Summary

- Backend contract: **unchanged — read-only consumption of the frozen module.** Confirmed surface:
  - `POST /expenses` — body `{ category: 'food'|'date'|'travel'|'shopping'|'other', amount: number (>=1, <=999999999999), description?: string, date: ISO-8601 string, not in the future }`. Server derives `userId` from the JWT and `coupleId` from `getCoupleId(userId, partnerId)`. Returns the saved row.
  - `GET /expenses?limit=&offset=` — returns `Expense[]`, ordered `date DESC, createdAt DESC`. Offset paging. Server defaults `limit=50`, `offset=0`; the generated client makes both **required strings**.
  - `GET /expenses/report?period=week|month` — returns `{ period: string, total: number, byCategory: Record<string, number>, count: number }`. `month` = 1st of current month → today; `week` = today-7 → today.
  - `DELETE /expenses/:id` — either partner may delete (service checks `coupleId` only, by explicit design note `expenses.service.ts:58-59`).
  - `Expense` row: `{ id: uuid, coupleId: string, userId: string, category: enum, amount: decimal(15,2), description: string|null, date: 'YYYY-MM-DD', createdAt: ISO timestamp }`.
  - **All four endpoints throw `NotFoundException('User not found or not paired')` → HTTP 404 when the caller has no `partnerId`.**
- Frontend contract: N/A (no web surface in this story).
- Mobile contract: `ExpensesRepository` is the only expenses I/O owner; `ExpenseDao` is the only expenses persistence owner. Cubits never touch `Dio` or Drift directly.
- DevOps / environment contract: none. No new env var, secret, or third-party integration.
- Requirement configuration guide impact: **NOT_APPLICABLE** — no configuration change.
- Data model / migration contract: additive Drift tables only (`expenses`, `expense_sync_metadata`) inside the existing canonical mobile database; a schema-version bump on that database. No backend migration.
- API / event / worker queue contract: no events, no realtime. Expenses are pull-only; the backend emits no expense socket/FCM event, so there is no live partner-update path in v1 (see Risk R-015.4).
- Test and verification expectations: unit tests for the amount/date/category decoders, `ExpensesRepository` (mocked Dio), `ExpenseDao` (in-memory Drift), and both Cubits (`bloc_test`); widget tests for the history screen states and the add sheet; `flutter analyze` + `flutter test` per phase. No e2e, no emulator lifecycle, no startup smoke in implementation phases.
- Risk surfaces and verification contract: see §4 table.
- OQ constraints that downstream lanes must preserve: ADR-007 both bounds — Drift is a read-through cache and **there is no offline write queue**. Never render "queued"/"will sync"; offline save fails fast with Retry. A1 — no endpoint may be added or altered.

## 3. Scope And Assumptions

- In Scope: expense creation (AC1), shared history read (AC2), Drift-backed offline read + never-synced/offline states (AC3), unpaired gating (AC4).
- Out Of Scope: any endpoint change; offline write/outbox; split/settlement/balance; expense edit (no `PATCH` exists); multi-currency; the Dream Jar (`jar`) screen; the 5-tab app shell.
- Assumptions affecting design:
  - A-015.1 Delete is available in the contract but is **not** an AC. Planned as not-implemented in this story; the DAO/repository leave room for it without shipping UI.
  - A-015.2 `GET /users/me` returns the caller's own row including `partnerId`; it does **not** return the partner's `displayName` (verified: `partnerId` is a plain column, not a relation).
  - A-015.3 The canonical Drift owner class is created by a sibling story in this same wave, not by STORY-015 (see ADR-015.6).

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| OQ4 | RESOLVED (ADR-007) | Offline write queue / outbox for new expenses; optimistic insert | Drift read-through cache, paged reads, client-side aggregation | ADR-015.4, ADR-015.5 |
| A1 | FROZEN | Any new/changed `expenses` endpoint or field | Client-side derivation from the existing payload only | ADR-015.1, ADR-015.2, ADR-015.3 |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/expenses/` (new), plus additive files under `mobile/lib/core/database/`.
- New or changed boundaries: `ExpensesRepository` owns all `/expenses` I/O and all payload decoding; `ExpenseDao` owns all local persistence and paging; `ExpenseHistoryCubit` / `AddExpenseCubit` own presentation state. No cross-Cubit reads (ADR-003).
- Shared patterns reused: Dio-direct-through-`CupidApi.dio` (AuthRepository precedent), `HttpStatusFailure` from `CupidErrorInterceptor`, `get_it` registration in `service_locator.dart`, adaptive widgets (`CupidAddAction`, `CupidPrimaryButton`, `CupidHeader`).

### Affected Components And Layers

- Backend: none (read-only reference).
- Frontend: none.
- Mobile: new `features/expenses/{data,presentation}`; additive `core/database/expenses_table.dart`, `core/database/expense_dao.dart`; one registration edit to the canonical database class; one `service_locator.dart` registration; one entry-point edit (see ADR-015.7).
- Data: two additive Drift tables + schema-version bump.
- Infrastructure: none.

### Contracts And Integrations

- APIs / events / schemas affected: consumes `POST /expenses`, `GET /expenses`, `GET /users/me`. Does **not** consume `GET /expenses/report` (see ADR-015.3).
- External or trust-boundary implications: none new. Amounts are non-sensitive relative to existing data; Drift still stores no tokens (§5 of system memory).
- Contract owner: backend (frozen). The mobile side is a pure consumer.
- Connection pattern and dependency direction: `Screen → Cubit → Repository → { CupidApi.dio, ExpenseDao }`. Dependency direction is strictly downward; the DAO never calls the repository.
- Example request / response / payload / signature:
  - `POST /expenses` body: `{"category":"food","amount":250000,"description":"Bún chả","date":"2026-07-30T00:00:00.000Z"}`
  - `GET /expenses?limit=50&offset=0` item: `{"id":"…uuid…","coupleId":"…","userId":"…","category":"food","amount":"250000.00","description":"Bún chả","date":"2026-07-30","createdAt":"2026-07-30T09:12:44.101Z"}`
- Error, retry, timeout, idempotency, and empty-state contract:
  - 404 on any expenses call ⇒ treat as *not paired* (the only 404 path for the collection `GET`); route to the Pairing-Required gate.
  - 401 is already handled by the existing refresh interceptor (one retry).
  - **No idempotency key exists** in the contract, which is exactly why ADR-007 forbids a replay queue. Save is therefore a single non-retried attempt plus a *user-initiated* Retry.
  - Two distinct empty states, discriminated by the sync-metadata row (ADR-015.5): never-synced vs. genuinely zero expenses.
- Compatibility or versioning posture: additive Drift migration; a destructive-recreate migration is acceptable for these cache-only tables since Drift is not a source of truth (ADR-007).

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|-------------------|-------------------|----------------------------|
| `amount` wire type (String vs num) | `expense.entity.ts:25` `decimal` + `expenses.service.ts:107` `Number(exp.amount)` | Decoder accepts both `String` and `num`; stores minor-unit-safe value | Unit test with both `"250000.00"` and `250000` fixtures | Cannot decode real payloads ⇒ blocker |
| Unpaired gating (AC4) | `expenses.service.ts:20-26` 404 | 404 ⇒ Pairing-Required gate, not a generic error | Repository unit test asserting 404 ⇒ `ExpensesNotPairedFailure` | Cannot satisfy AC4 ⇒ blocker |
| Offline read (AC3) | `ExpenseDao` + sync-metadata row | Cached rows render; freshness caption when offline | DAO integration test (in-memory Drift) + widget test for both empty states | Cannot satisfy AC3 ⇒ blocker |
| Offline write fail-fast (ADR-007) | ADR-007 bound (b) | Inline error + Retry; never queued, never optimistic | `bloc_test` asserting no optimistic emit and no persisted row | Violates ADR-007 ⇒ blocker |
| Canonical Drift owner | Sibling story's database class | One database class only | `flutter analyze` + codegen succeed against the single owner | Two owner classes ⇒ blocker, escalate (R-015.1) |
| Entry-point discoverability | `app_shell.dart` / `home_screen.dart` | Feature reachable from a discoverable surface | Widget test navigating from the entry affordance to the history screen | Orphaned feature ⇒ blocker |

### Mobile Lane Handoff

- Mobile responsibilities: all six phases. This is a single-lane mobile story.
- Mobile inputs that are authoritative: this solution §2, the frozen backend module, `ux/uiux-spec.md` §3-§8.
- Mobile constraints derived from UX: two non-interchangeable empty states (§5); freshness caption only while offline (§5); no "queued" wording anywhere (§5); "Paid by" is display-only (ADR-015.2); focus trap + return focus on the sheet (§7); 44pt/48dp tap targets (§8).
- Mobile guardrails: never import `package:cupid_api/...` directly (import `core/network/cupid_api.dart`); never construct `Dio`; never add a second database class; never write an expense to Drift that the server has not acknowledged.

### Backend Lane Handoff

- Backend responsibilities: **none.** A1 frozen. If any phase believes a backend change is needed, stop and escalate rather than editing `backend/`.

### DevOps Lane Handoff

- DevOps responsibilities: none.
- Requirement configuration guide update: NOT_APPLICABLE
- DevOps guardrails: no runtime registry change; `mobile-app` entry already exists.

## 5. Non-Functional Impact

- Security / privacy: no new secret or token surface. Drift holds only expense rows already visible to both partners. All authorization stays server-side (`coupleId` is server-derived and never client-supplied).
- Reliability / performance / scalability: history is paged from Drift (`limit`/`offset`), never held whole in Cubit state (system memory §5 line 76, R4). Client-side monthly aggregation runs over the current month's cached rows only, not the whole table.
- Observability / operations: repository failures surface as typed `CupidApiFailure` subtypes so the existing crash/error reporting keeps working; offline is an expected state, not an error to report.
- Migration / rollout / rollback constraints: additive Drift schema bump; cache can be dropped and rebuilt from the server at any time.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Generated `Epic5ExpensesApi` methods | ADR-006 prefers the generated client | **Rejected for reads/create** | All four generated methods return `Response<void>` (`epic5_expenses_api.dart:34,107,167,225`) — the OpenAPI spec declares no response schema, so the payload is unreachable through them. Same root cause as `AuthRepository._syncBackendProfile`. |
| `GET /expenses/report` for the monthly header | It exists and returns a total | **Rejected** | It returns `byCategory` only — no per-day buckets for the 7-bar chart, and no previous-month window for the vs-last-month delta. Two sources for one number would also drift from the cached list offline. Aggregate client-side from Drift instead (ADR-015.3). |
| New Drift database class for expenses | Lane isolation in a parallel wave | **Rejected** | Would be the third parallel database in `core/database/`. Additive table into the canonical owner instead (ADR-015.6). |
| Optimistic insert then reconcile | Snappier add UX | **Rejected** | ADR-007 bound (b): no idempotency field exists, so a failed optimistic write cannot be made duplicate-safe. Fail fast instead. |

## 7. Story-Scoped Architecture Decisions

These are story-scoped ids (`ADR-015.x`) to avoid colliding with sibling stories claiming global ADR numbers in the same wave.

- **ADR-015.1 — Dio-direct repository, not the generated client.** `ExpensesRepository` calls `_api.dio.get<Object?>('/expenses', queryParameters: {'limit': …, 'offset': …})` and `_api.dio.post<Object?>('/expenses', data: …)`, decoding by hand. Rationale: the generated methods are `Future<Response<void>>`. This follows the documented `AuthRepository` precedent verbatim, including rethrowing `DioException.error` (the mapped `CupidApiFailure`) rather than the raw exception. The generated `CreateExpenseDtoCategoryEnum` (`food|date|travel|shopping|other`) **is** reused as the category source of truth so the enum is never hand-copied.
- **ADR-015.2 — "Paid by" is server-derived and display-only. Resolves the story's open item.** `CreateExpenseDto` has no `userId`/`paidBy` field; the server sets `userId` from the JWT (`expenses.controller.ts:21-22`). Therefore the UX spec's §3 "Paid by — attribution-only toggle between the two partners" is **not implementable** and must not ship as a toggle. The add sheet shows a non-interactive "Paid by: You" row; the list `who` label is derived on read as `expense.userId == ownBackendUserId ? "Bạn/You" : "Người ấy/Partner"`. Literal partner names ("Minh"/"Linh") from the design source are **not** available — `GET /users/me` returns the caller's own `displayName` and the partner's `partnerId` uuid only, and no partner-profile endpoint exists anywhere in the backend (verified across all `*.controller.ts`). Own backend user id comes from the existing `BackendUserIdStore` (STORY-004 room-key contract).
- **ADR-015.3 — Monthly total, delta, and chart are computed client-side from Drift; `/expenses/report` is unused.** The report endpoint exposes `byCategory` and a single-period `total` with no per-day buckets and no configurable window, so it can satisfy neither the 7-bar chart nor the vs-last-month delta. Both are derived from cached rows. **Consequence downstream must honor:** the delta and chart are only as complete as the cache; when the current cache does not cover the full previous month, hide the delta rather than render a wrong one.
- **ADR-015.4 — Currency is a fixed display unit, not data. Resolves the story's open item.** There is no `currency` field anywhere in the entity or DTO; `amount` is a bare `decimal(15,2)` and the service logs it as VND (`expenses.service.ts:41`). VND is therefore a hard-coded presentation constant. Do not add a currency selector, do not persist a currency code, and do not imply multi-currency support.
- **ADR-015.4a — There is no splitting or settlement capability. Resolves the story's open item.** The contract has no share, split, percentage, balance, or settlement field of any kind. The UI must not compute or display "who owes whom", a per-partner balance, or a Dream-Jar-style comparative standing. `amount` is a whole shared expense.
- **ADR-015.5 — Never-synced vs. zero-expenses is discriminated by a local sync-metadata row. Resolves the UX spec's second open item.** No backend signal exists, so the client owns it: an `expense_sync_metadata` single-row Drift table holding `lastSuccessfulSyncAt` (nullable). `null` ⇒ never-synced placeholder ("Kết nối mạng để tải chi tiêu chung lần đầu"); non-null with zero rows ⇒ ordinary "no expenses yet". The same field feeds §5's freshness caption. The row is written only after a successful `GET /expenses`.
- **ADR-015.6 — Expenses extends the single canonical Drift owner; it does not create one.** STORY-015 adds `expenses_table.dart`, `expense_sync_metadata` and `expense_dao.dart` and registers them into the existing owner class. **Tie-break for the wave:** the canonical owner is `CupidDatabase` in `mobile/lib/core/database/cupid_database.dart`, matching the repo-wide `Cupid*` prefix convention (`CupidApi`, `CupidSession`, `CupidTheme`, `CupidTabBar`, `CupidAddAction`). See R-015.1 — this is an escalation, not something STORY-015 can settle alone.
- **ADR-015.7 — Pairing state is read through a narrow seam, keyed on `partnerId`.** AC4's authoritative gate is pairing state, not an error code: a `PairingStateReader` seam exposes `Future<bool> isPaired()`. If STORY-005 (pairing) has landed a pairing-state source, consume it; otherwise the seam reads `GET /users/me` via Dio-direct and tests `partnerId != null`. A 404 from an expenses call is a secondary corroborating signal that flips the same gate, so a stale cached pairing state cannot leave the feature open.

## 8. Risks And Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| **R-015.1 Two competing Drift owner classes already in flight** — STORY-007 is landing `cupid_database.dart` and STORY-012 is landing `app_database.dart`, both under `mobile/lib/core/database/`. Neither exists at this story's `BaseHead`. | HIGH — a third addition, or a merge of both, breaks codegen and duplicates the schema | ADR-015.6 picks `CupidDatabase` on naming convention and STORY-015 adds only additive files. **Escalated to Scrum Master:** the wave must canonicalize one owner before P2 merges. STORY-015's P2 is explicitly `Depends-On` the canonical owner existing. |
| **R-015.2 Entry-point wiring touches a high-conflict shared file** — the 5-tab shell does not exist (`app_shell.dart` returns `HomeScreen` directly) and the `jar` screen that the UX spec uses as the entry point is another story's scope. | MEDIUM — merge conflict in a parallel wave; or an orphaned feature | P5 adds one small additive affordance to `home_screen.dart`, preserving `Key('home_screen_ready_signal')` (the `mobile-app` readiness contract). When the shell/jar story lands, the entry moves to the Money tab; the route itself is story-owned and stable. |
| R-015.3 `amount` arrives as a String from `GET` but may be a num from `POST` (TypeORM `save()` returns the in-memory value) | MEDIUM — decode crash on the happy path | Single tolerant decoder covering both, unit-tested with both fixtures. |
| R-015.4 No expense socket/FCM event exists, so a partner's new expense does not appear live | LOW — stale-until-refresh shared view | Pull-to-refresh + refresh on screen focus. Do not invent a realtime channel; ADR-008/A1 forbid it. |
| R-015.5 Client-side month aggregation over a partial cache yields a wrong delta | MEDIUM — a wrong money number is worse than no number | ADR-015.3: hide the delta unless the cache demonstrably covers the previous month. |
| R-015.6 `date` is a date-only string while the DTO wants an ISO datetime, and the backend's future-date check uses **server** local time | LOW — off-by-one rejection near midnight/timezone edges | Send the local calendar date at `T00:00:00.000Z`; client-side blocks future dates before submit so the server check is a backstop, not the primary UX. |

## 9. Handoff Notes

- Implementation guardrails: no backend edits; no new database class; no optimistic writes; no "queued" copy; no currency picker; no split/balance UI; no "Paid by" toggle; import only `core/network/cupid_api.dart`.
- OQ-driven constraints to preserve: ADR-007 (a) read-through cache and (b) no offline write queue; A1 frozen backend.
- Shared contract-first work required: YES — P1 (models + repository) is the contract-first phase every later phase consumes.
- Shared coding plan required: YES — `coding-plan/master-plan.md` with phases P1-P6.
- Memory updates required: **none from this story.** `data/architecture/system/system_architecture_memory.md` is intentionally left untouched (ADR-007 is confirmed, not changed). Two items are worth promoting after review, out of this story's scope: the Drift read-through + sync-metadata pattern (ADR-015.5) and the canonical-database-owner rule (ADR-015.6).
- Open questions / blockers: **R-015.1 requires a Scrum Master decision** on the canonical Drift owner before P2 merges. Both of the story's own open items and both of the UX spec's Tech Lead open items are now resolved (ADR-015.2, ADR-015.4, ADR-015.4a, ADR-015.5).
