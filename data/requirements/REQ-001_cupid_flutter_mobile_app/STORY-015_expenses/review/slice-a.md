# STORY-015 Review — Slice A (P1 expense contract/domain layer)

Reviewer: Iris-QC (Tier 3 scoped-slice review)
Scope: `RUN-REQ-001_cupid_flutter_mobile_app-STORY-015-reviewer-slice-a`
BaseHead: `0a467d03babf1ed4102c3fab09c61b2dec941a0b`

## Files Reviewed

- `mobile/lib/features/expenses/data/expense_models.dart`
- `mobile/lib/features/expenses/data/expense_category.dart`
- `mobile/lib/features/expenses/data/expenses_repository.dart`
- `mobile/lib/features/expenses/data/expenses_failure.dart`
- `mobile/test/features/expenses/data/expense_models_test.dart`
- `mobile/test/features/expenses/data/expenses_repository_test.dart`

Diff obtained via the exact scoped pathspec command specified in the handoff;
no unscoped diff was run.

## AC1 — "A paired user can add an expense entry"

`ExpensesRepository.create()` posts exactly the contract's four fields
(`category`, `amount`, `description?`, `date`) to `POST /expenses`. It invents
no client-side `userId`/`paidBy` field (ADR-015.2: server derives `userId`
from the JWT), no `currency` field (ADR-015.4), and no split/settlement/balance
field (ADR-015.4a). `expenses_repository_test.dart`'s "sends exactly the four
contract fields" test asserts `body.length == 4` and the exact key set, which
is a good regression guard against a forbidden field being added later. The
future-date guard (R-015.6) rejects a future date client-side before any
request is sent, matching `architecture/solution.md` §7 ADR text, and is
covered by a dedicated test that fails if a request is ever sent. The 404→
`ExpensesNotPairedFailure` mapping (AC4-adjacent, but exercised by this
repository) is also tested for both `fetchPage` and `create`.

Assessment: AC1 coverage in this slice is correct and matches the frozen
backend contract and ADR-015.2/015.4/015.4a constraints. No invented
capability found.

## AC3 (data-model half only) — domain/persistence separation

`expense_models.dart`'s `Expense` class imports only `expense_category.dart`
and has zero Drift-specific imports or types. It is a plain domain model
(`id`, `userId`, `category`, `amountVnd`, `description`, `date`, `createdAt`)
that decodes directly from the wire JSON. This should let Slice B's Drift
table map to/from `Expense` without leaking Drift row types into the domain
layer. `ExpenseCategory` similarly wraps the generated
`CreateExpenseDtoCategoryEnum` rather than a hand-copied enum, per ADR-015.1,
and stays outside the persistence layer.

Assessment: clean separation; nothing in this slice couples the domain model
to persistence concerns. (Offline/Drift persistence itself is out of this
slice's scope per the handoff.)

## `expenses_failure.dart` — failure modeling

`ExpensesFailure` is a `sealed` class with two concrete cases
(`ExpensesNotPairedFailure`, `ExpensesFutureDateFailure`), each documented with
its AC/risk-id justification. `_mapFailure` in the repository maps a 404 to
`ExpensesNotPairedFailure` and otherwise rethrows the underlying
`CupidApiFailure` from `DioException.error` (or `UnexpectedFailure` if absent),
following the documented `AuthRepository` precedent. No stringly-typed error
handling and no swallowed exceptions in the Dio error path.

NOTE (non-blocking): `Expense.fromJson` decode failures (e.g. the
`FormatException` thrown by `_decodeAmount` for an unrecognized `amount` wire
type, or an `as` cast failure on malformed JSON) happen *inside* the `try`
block in both `fetchPage` and `create`, but are not `DioException`s, so they
are not caught by the `on DioException catch (e)` clause and propagate as raw
exceptions rather than a typed `ExpensesFailure`/`CupidApiFailure`. This is
consistent with treating a decode failure as a contract-violation bug rather
than a recoverable failure, but a downstream presentation-layer slice should
be aware raw exceptions can surface from this repository, not only typed
failures.

NOTE (non-blocking, informational): the contract's `amount` bounds (`>=1`,
`<=999999999999`) are not validated client-side in this slice. Not required by
AC1 as written; likely a presentation-layer (P3/P4) concern if not already
covered there.

## Test Coverage

`expense_models_test.dart`: asserts actual decoded values (String vs num
amount both decode to `250000.0`, nullable description, category fallback to
`other` for both `Expense.fromJson` and `ExpenseCategory.fromWire`, date vs
createdAt parsing). Not constructor-only smoke tests — each test exercises the
decode contract behavior described in `architecture/solution.md` §8's risk
table (R-015.3).

`expenses_repository_test.dart`: uses a scripted `HttpClientAdapter` fake
(no network) and asserts concrete request/response behavior: exact query
params sent as strings, exact decoded rows, exact POST body field set and
values (including the description-omission case and future-date short-circuit
which never issues a request), and the 404 mapping for both `fetchPage` and
`create`. This is meaningful behavioral coverage of the repository contract,
not smoke-only.

## Findings

- NOTE: `Expense.fromJson` decode failures propagate as raw (non-`DioException`,
  non-`ExpensesFailure`) exceptions from both `fetchPage` and `create`, rather
  than being wrapped in a typed failure. Non-blocking; flagged for downstream
  slices' awareness.
- NOTE: no client-side validation of the contract's `amount` bounds
  (`>=1`/`<=999999999999`) in this slice. Non-blocking; likely presentation-
  layer scope.

No BLOCKING findings.

## Verdict

Slice A (P1 expense contract/domain layer) correctly implements AC1's add-
expense flow within the frozen backend contract, respects ADR-015.2/015.4/
015.4a (no invented paid-by/currency/split capability), keeps the domain model
clean of Drift concerns for Slice B, and has behaviorally meaningful test
coverage for both the model decoder and the repository.

Slice-Verdict: CLEAN
