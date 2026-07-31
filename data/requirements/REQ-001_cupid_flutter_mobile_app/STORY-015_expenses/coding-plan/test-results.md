# STORY-015 P6 — Verification Results

## Gates (this session, BaseHead `e2c393ab7e5b6448df85ab13b4967a37afad2556`)

| Gate | Command | Scope | Result |
|------|---------|-------|--------|
| Static analysis (story scope) | `flutter analyze lib/features/expenses test/features/expenses lib/core/database test/core/database lib/core/di/service_locator.dart lib/features/home/presentation/home_screen.dart` | STORY-015 write-scope files | **No issues found!** (1.9s) |
| Unit/widget tests (story scope) | `flutter test test/features/expenses test/core/database test/features/home` | STORY-015 write-scope tests | **81/81 passed, 0 failures** |
| Mobile build | `flutter build apk --debug` | whole app | **✓ Built `build/app/outputs/flutter-apk/app-debug.apk`** |

## AC Traceability

| AC | Evidence | Phase | Result |
|----|----------|-------|--------|
| AC1 paired user can add an expense | `add_expense_sheet_test.dart` ("a successful submit sends exactly the four contract fields and pops the sheet"); `AddExpenseCubit` success path (`add_expense_cubit.dart` `submit()` → `AddExpenseSuccess`) | P4 | PASS |
| AC2 both partners view shared history | `expense_history_screen` widget tests (shared dataset, no per-partner filter); `whoYou`/`whoPartner` own-vs-partner label assertions (`expense_strings.dart`) | P3 | PASS |
| AC3 history readable offline after one sync; writes need connectivity | Offline widget tests with cached rows + `freshnessCaption`; never-synced vs empty-zero-expenses states (`ExpenseSyncMetadata`/`lastSuccessfulSyncAt`); no-optimistic-write path proven by construction (`AddExpenseCubit` holds no `ExpenseDao` reference; `ExpenseDao` has no user-write method, only `upsertAll` from server-fetched rows) | P2, P3, P4 | PASS |
| AC4 unpaired users cannot access | `expenses_entry_point_test.dart` ("ExpensesEntryPoint (ADR-015.7 AC4 gate) unpaired: shows PairingRequiredGate, never ExpenseHistoryScreen"); 404 → `ExpensesNotPairedFailure` mapping in `expenses_repository.dart::_mapFailure`; P5 entry affordance always routes through `ExpensesEntryPoint`, which resolves the gate itself | P1, P5 | PASS |

## R-015.1 — Canonical Drift database class

Exactly one `@DriftDatabase`-annotated class exists in `mobile/lib`: `CupidDatabase` (`mobile/lib/core/database/cupid_database.dart`). No second/superseded database class found. Not blocked.

## `home_screen_ready_signal` readiness key

Confirmed present and intact in `mobile/lib/features/home/presentation/home_screen.dart` (referenced by `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart` as well). Unaffected by STORY-015.

## ADR-007 bounds (server-authoritative read-through cache; no offline write/outbox)

Verified by inspection of the expenses feature and database files:

- `mobile/lib/core/database/tables/expenses_table.dart`: `Expenses` table has cache columns only (`id`, `userId`, `category`, `amount`, `description`, `date`, `createdAt`); `ExpenseSyncMetadata` is a single-row sync marker, not an outbox. Table doc comment states explicitly: "no pending-write/outbox column exists here by design (ADR-007 bound (b))".
- `mobile/lib/core/database/daos/expense_dao.dart`: `ExpenseDao` exposes only `upsertAll` (from server-fetched rows), `getPage`/`watchPage`/`monthRows` (reads), `lastSuccessfulSyncAt`/`markSyncedNow`, and `countAll`. No user-initiated insert/write method exists.
- `mobile/lib/features/expenses/presentation/add_expense_cubit.dart`: `AddExpenseCubit` calls `ExpensesRepository.create` directly and holds no `ExpenseDao` reference at all — no DAO handle exists for a bug to accidentally write through on a failed submit. `submit()` calls the repository at most once per invocation; re-invoking with the same draft after failure *is* the Retry affordance (no separate retry/background-retry method).
- `mobile/lib/features/expenses/data/expenses_repository.dart`: Dio-direct HTTP calls only (`GET /expenses`, `POST /expenses`); no local persistence on write.
- `mobile/lib/features/expenses/presentation/expense_strings.dart`: `addSaveFailedOffline` copy is "No connection — try again" / "Không có kết nối — thử lại", with an explicit doc comment: "never 'queued'/'will sync' wording (ADR-007)".

No outbox table, no optimistic insert, no background retry, no "queued"/"will sync" copy found. ADR-007 bounds hold by inspection and by the existing P4 `verifyNever`-style no-optimistic-write test (AC3 evidence above).

## Deliberate UX deviations (shipped as decided)

1. **Non-interactive "Paid by"**: `addPaidByLabel` ("Paid by" / "Người trả") pairs with `whoYou` for the value; doc comment on the ADR-015.2 section confirms "never a toggle between partners." Confirmed by inspection of `expense_strings.dart` and `add_expense_cubit.dart`/`add_expense_sheet.dart` (no partner-selection state anywhere in the submit flow).
2. **No partner display names**: `whoYou`/`whoPartner` always resolve to "Bạn"/"Người ấy" ("You"/"Partner"), never a literal name — doc comment confirms "no partner-profile endpoint exists (ADR-015.2)."
3. **Client-side summary, not `/expenses/report`**: `expenses_repository.dart` exposes only `fetchPage`/`create` against `/expenses` — no `/expenses/report` call exists. Monthly aggregation is computed client-side via `ExpenseDao.monthRows` (doc comment: "P3's client-side monthly aggregation (ADR-015.3)").

All three confirmed shipped as decided.

## Phase minimum-gate re-confirmation (P1-P5)

All five phases were previously marked `DONE` in `master-plan.md` §5 with individually passing gates (see phase files P1-P5, not re-read per Do-Not-Re-read scope). This session's full-project `flutter test` run and the STORY-015-scoped rerun above re-exercise every P1-P5 test file under `test/features/expenses`, `test/core/database`, and `test/features/home`, all of which pass (81/81). No regression found in any P1-P5 phase's own scope.

## Known pre-existing issues (out of scope, NOT caused by STORY-015)

Found during a whole-project `flutter analyze lib test` and full-project `flutter test` run for cross-check purposes. None are in STORY-015's write scope (`expenses` feature, `core/database`, `home_screen.dart`, `service_locator.dart`); documented here per the `master-plan.md` R-015.6 out-of-scope-finding precedent, not fixed in this pass.

- **79 whole-project `flutter analyze` issues**: 76 `prefer_initializing_formals` info-lints + 1 `use_null_aware_elements` info + 1 `deprecated_member_use` warning, scattered across other feature lanes (pairing, reminders, vibes, chat, anti_ghosting, auth, dream_jar, gallery, core/realtime, core/navigation). Plus 3 `undefined_named_parameter` compile errors in `test/features/pairing/presentation/pair_gate_cubit_test.dart` (calls `AppShell(createPairGateCubit: ...)` — those constructor params belong to `PairGateShell`, not `AppShell`). Confirmed pre-existing on `codex/REQ-001_cupid_flutter_mobile_app-integration` itself via `git show`, i.e. inherited, not introduced by this story.
- **10 full-project `flutter test` failures**, none in STORY-015's own scoped run:
  - 8 share one root cause: `StateError: Bad state: GetIt: Object/factory with type CouplePairingStore is not registered inside GetIt`, thrown via `HomeScreen._defaultResolvePairingStatus` → `_TimelineEntryPointGate` (`home_screen.dart:71/132`), a default dependency introduced by STORY-012's Timeline feature (per `home_screen.dart`'s own pre-existing doc comment attributing it to "STORY-012 P3/P7"). Proven not caused by P5 via a direct diff of P5's `home_screen.dart` commit (`c8bf81b4...` → `e2c393ab...`): the P5 change is purely additive (new import, doc comment, `_ExpensesEntryCard` widget + its mount point) and never touches `_defaultResolvePairingStatus`/`_TimelineEntryPointGate`. Affected: `app_shell_test.dart` (×2), `feature_flags_test.dart`, `gallery_cubit_test.dart`, `vibe_screen_test.dart`, `pet_entry_point_test.dart`, `reminder_entry_point_test.dart`, and `test/widget_test.dart` (top-level app-boot smoke test — flagged prominently for follow-up given it is the app's own root smoke test, even though provably not caused by STORY-015).
  - 1 is the same `pair_gate_cubit_test.dart` load error described above (test file fails to load due to the `AppShell`/`PairGateShell` constructor mismatch).
  - 1 (`reminder_copy_guard_test.dart`) scans a generated, non-committed l10n file (`lib/l10n/generated/app_l10n_vi.dart`) for a forbidden reminders-feature term — unrelated to expenses.

**Recommendation**: route the `CouplePairingStore`/GetIt registration gap (affecting `test/widget_test.dart` and 7 other pre-existing test files) and the `pair_gate_cubit_test.dart` constructor mismatch to Scrum Master as separate follow-up work (pairing/timeline lane), not blocking STORY-015 P6.

## Excluded from this phase (per governing scope)

Mobile e2e, emulator/simulator lifecycle, signing, store upload, traces, and scenario reruns were not planned or run, per phase-P6-verification.md §3 and this handoff's explicit exclusions.
