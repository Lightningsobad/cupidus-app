# Review Slice P1 — Notebook origin persistence (schema/migration/DAO/repository)

Outcome: PARTIAL_SLICE_ONLY

- Review type: `scoped-slice` (Slice 1 of 4)
- Story: `STORY-001_checkin_notebook_capture` (REQ-017), Complexity `standard`, Lane `shared` (mobile-only in practice)
- Phase under review: P1 — `coding-plan/phase-P1-notebook-origin-persistence.md`
- Worktree: `story-REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture`
- BaseHead: `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1` → HEAD `aa20766f` (worktree clean)
- This slice produces NO story outcome. Story closure is decided by the later `final-synthesis` slice.

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Slice report path: `data/requirements/REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture/review/slice-p1-schema.md`
- Source/test files in scope (diffed against BaseHead):
  - `mobile/lib/core/database/cupid_database.dart` (+14/-3)
  - `mobile/lib/core/database/cupid_database.g.dart` (+245/-0, generated — consistency check only)
  - `mobile/lib/core/database/tables/context_notebook_tables.dart` (+19/-0)
  - `mobile/lib/features/context_notebook/data/context_notebook_dao.dart` (+17/-0)
  - `mobile/lib/features/context_notebook/data/context_notebook_repository.dart` (+73/-0)
  - `mobile/lib/features/context_notebook/domain/context_notebook_models.dart` (+16/-0)
  - `mobile/test/core/database/context_notebook_migration_test.dart` (+72/-3)
  - `mobile/test/features/context_notebook/context_notebook_repository_test.dart` (+150/-0)
- Evidence in scope: `coding-plan/test-results.md` `## P1` (Gates 1-6), `coding-plan/phase-P1-notebook-origin-persistence.md` §1B/§3/§4/§6/§7, `coding-plan/master-plan.md` §3A/§5/§6, `story_master.md` AC-5/8/9/11 + BR-11/BR-12
- Touched risk surfaces: RS-1 notebook local persistence write path; RS-3 per-check-in idempotency; RS-5 origin-label degrade (persistence half); RS-6 notebook consumer non-regression. Persistence/schema/migration + local-storage/offline + typed/generated contract.
- Critical gates for this slice: additive migration proven on a real prior-version file; repository idempotency unit proof; `schemaVersion` ripple regression green in the same run; static analysis delta 0. All four are present and green.
- Out of slice (not reviewed): `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart` (BUG-20260927-001 cherry-pick `248e9179`), `mobile/pubspec.yaml` asset-dir line (P2, per `master-plan.md` §1), all UI/cubit/label work (P3/P4).

## Verdicts

| Id | Claim in scope | Verdict | Evidence |
|----|----------------|---------|----------|
| P1-A1 | Pre-v11 rows read back with all three origin columns `null`; existing notebook behavior unchanged | PASS | `context_notebook_migration_test.dart` group `v10 -> v11 (REQ-017 origin columns)`, test `the pre-v11 row survives...` asserts `value`/`event_on` intact + three `isNull`; `seedV10` derives the fixture from the real table then `ALTER TABLE ... DROP COLUMN` × 3 + `PRAGMA user_version = 10`, so the upgrade runs against a genuine v10 file. test-results Gate 1 `+106`, exit 0 |
| P1-A2 | Same `originCheckInRef` leaves exactly one row; two different refs leave two (AC-8/BR-12) | PASS (sequential/retry path) | `context_notebook_repository.dart:recordFromCheckIn` reads `notebookRowByOrigin` then updates `kind`/`value`/`eventOn`/`updatedAt` in place, returning the same id; tests `the same check-in ref rewrites its one row instead of adding another` (`hasLength(1)`, `second.id == first.id`) and `two different check-ins recording the same interest are two rows`. Gate 2 `+78`, exit 0. Concurrency caveat: F-1 |
| P1-A3 | `updateEntry` with new text/kind preserves all three origin columns (AC-5) | PASS | `updateEntry` companion carries only `value`/`detail`/`eventOn`/`updatedAt` — the three origin columns are absent by construction, so no write path can move them; test `editing the text of a check-in entry leaves its origin untouched (AC-5)` asserts all three survive |
| P1-A4 | `cardTitle == null` at write time → `origin_card_title` null and the write still succeeds (AC-9) | PASS | `originCardTitle: Value(_optionalText(cardTitle))`; `_optionalText` maps null/blank → `null` and never throws (only `value`/`originCheckInRef` go through the throwing `_requireText`). Test `an unreadable card title writes NULL and still succeeds (AC-9)` |
| P1-A5 | `ContextEntrySource` still has exactly two values; `entries()` signature unchanged (BR-11) | PASS | `recordFromCheckIn` hardcodes `ContextEntrySource.askOnTheSpot.wireValue`; no enum value added in `context_notebook_models.dart` diff; test asserts `ContextEntrySource.values, hasLength(2)`. `entries()`/`notebookRows` untouched in the diff |
| P1-INV1 | Migration is additive only — no destructive recreate of a device-authoritative table (RS-1) | PASS | `cupid_database.dart:153-162` uses only `m.addColumn` × 3; no `deleteTable`/`destructivelyRecreate`/`DROP` anywhere in the new branch. The `else if (from < 11)` attaches to `if (from < 6)` (createTable emits the current definition), so a v<6 machine is not double-columned and a v6-v10 machine gets exactly the three columns. Correct today; maintenance hazard recorded as F-2 |
| P1-INV2 | `schemaVersion` 10 → 11 with every stale assertion fixed in the same run | PASS | `cupid_database.dart:86`; test-results Gate 3 (`+74`, exit 0) documents 15 files re-pinned to 11 and the `duplicate column name: origin_check_in_ref` fixture class repaired in the fixtures rather than by defensive production code. Aggregate ripple evidence accepted per handoff: Scrum Master re-ran `flutter test test/core/database` fresh at the P1 seal (`+106`) and after P4 |
| P1-INV3 | Closed column set of `notebook_entries` grew by exactly the three origin columns; nothing measures the partner (REQ-016 AC-25 guard) | PASS | `context_notebook_migration_test.dart:305-323` asserts the exact 13-name set on a fresh `onCreate` database — which is also the proof that the `from < 6` createTable branch emits the three new columns |
| P1-INV4 | No FK/cascade from the origin columns, so a deleted or closed card cannot remove the entry (AC-9, AC-11) | PASS (structural) | `context_notebook_tables.dart` declares `originCardId`/`originCardTitle`/`originCheckInRef` as plain `text().nullable()` with no `references`. This matters because `beforeOpen` runs `PRAGMA foreign_keys = ON` — a cascading FK here would have silently deleted user-authored notebook rows. Behavioral AC-9/AC-11 proof at the UI/label layer belongs to P4 |
| P1-INV5 | Check-in write never touches `activity_cards` (BR-6, card read-only) | PASS | No `activity_cards` write in the P1 diff; `originCardId` is stored as an opaque probe value only |
| P1-INV6 | Owner isolation holds on the new origin lookup | PASS | `notebookRowByOrigin` filters `ownerKey & originCheckInRef` and applies `limit(1)` before `getSingleOrNull()` (so even a pre-existing duplicate cannot throw); test `a second owner on the same device never sees the first one's check-in entry` shows the idempotency key is owner-scoped, not global |
| P1-INV7 | Generated Drift code matches the schema diff | PASS | `cupid_database.g.dart` is +245/-0 — purely additive, so no existing generated column or table definition changed; the new columns are exercised through generated `NotebookEntriesCompanion.insert` named args and `NotebookEntryRow` getters in both test suites, which would not compile if codegen were stale. Not line-reviewed, per handoff |
| P1-INV8 | Existing notebook consumers do not regress (RS-6) | PASS | test-results Gate 2 (`+78`, exit 0) over `ask_cadence_policy`, `ask_on_the_spot_slot`, `context_notebook_closure_filter`, `context_notebook_repository`, `notebook_screen`, `skill_profile_screen`; Gate 5 after the BUG-20260927-001 cherry-pick `+248 ~8: All other tests passed!`, exit 0 |
| P1-INV9 | Static analysis delta from P1 is zero | PASS | Gate 4: `flutter analyze lib/core/database lib/features/context_notebook test/core/database test/features/context_notebook` → `8 issues found.`, exit 1, all `info`/`prefer_initializing_formals` pre-dating P1 (`context_notebook_repository.dart:27-30`, `ask_on_the_spot_cubit.dart:66-69`). Consistent with the known non-zero repo analyze baseline |

No FAIL and no UNVERIFIED item in this slice. No blocking finding.

## Findings

### F-1 — DEFERRED (cross-slice, must be closed by the P3 slice or final synthesis)
Per-check-in idempotency is enforced only in application code: `recordFromCheckIn`
does `notebookRowByOrigin` → `await` → `insertNotebookRow` with no surrounding
`transaction` and no unique index on `(owner_key, origin_check_in_ref)`. Two
concurrent invocations can both observe `existing == null` at the first `await`
and both insert. The test suite proves the sequential case (a retry after a
failed save, a second save of the same check-in), which is the larger half of
AC-8; it cannot prove the "chạm hai lần" half, because that half is decided by
whether the P3 submit path guards re-entry (disabled button / in-flight flag).
Not raised against P1: adding a DB unique constraint was outside the phase's
"no other column, no other change" scope, and the guard naturally belongs to the
caller. Final synthesis must confirm P3 supplies it; if P3 does not, AC-8 is only
half met and the story is `PATCH_REQUIRED`, not on P1's account.

### F-2 — DEFERRED (maintainability, migration shape)
`cupid_database.dart:149-162` chains the v11 branch as
`if (from < 6) { createTable } else if (from < 11) { addColumn × 3 }`. That is
correct at v11, but it is the exact shape the same file argues against 15 lines
above (lines 132-134: "These are sibling `if`s, never an `else if` chain: a
machine sitting on v4 needs the v5 column and no v4 one, so chaining would skip
exactly the largest group of real devices"). The next notebook column added as
another `else if (from < 12)` would skip v11's three columns for every v6-v10
device. Semantically identical and composable alternative:
`if (from >= 6 && from < 11) { ... }`. No user impact today, so not a patch item
for this story.

### F-3 — OBSERVATION (for the P3 slice, not a finding against P1)
`recordFromCheckIn` writes `source = ask_on_the_spot` with `question_id` left
`null`, while the ask-on-the-spot question itself is a durable-id content item
(AC-14/R-15c). This is not a new row shape — `addEntry` can already produce an
`ask_on_the_spot` row without a `question_id` — and the phase explicitly forbade
extra columns, so P1 is consistent with its plan. Flagged so the P3 reviewer can
confirm the cadence / "don't re-ask" path (STORY-012 AC-17) does not key on
`question_id` for entries written from a check-in.

### N-1 — Out of slice (routing note only)
`mobile/pubspec.yaml` `+ assets/data/req017/` appears in the diff but belongs to
P2 per `master-plan.md` §1 and is not in P1's declared Write Scope. Reviewed by
the P2 slice, not here.

## Traceability

- Requirements: `story_master.md` AC-5 (P1-A3), AC-8 (P1-A2, F-1), AC-9 (P1-A4, P1-INV4), AC-11 (P1-INV4), BR-11 (P1-A5), BR-12 (P1-A2). Phase §4's five acceptance items map 1:1 onto P1-A1..P1-A5.
- Architecture: `architecture/solution.md` §1 KD-2/KD-5 and §4 as cited by the phase file — `ContextNotebookRepository` remains the single write door into `notebook_entries` (verified: the new path goes through the DAO, and `_eventOnFor` still enforces "a date only means something on an `event` entry").
- OQ discipline: `story_master.md` `## Open Question Impact` records no blocked scope; OQ-1, OQ-2, A-5 all RESOLVED 2026-09-27 in `req_master.md` `## User Decisions`. Nothing in this slice implements blocked scope or omits unblocked scope.
- Configuration guide: `master-plan.md` §1 records `NOT_APPLICABLE` for P1 (no env var, no secret, no third-party); the single config line is P2's asset dir. No configuration-guide verification owed by this slice.
- Runtime startup smoke: phase §1B records `Startup Smoke: NOT_APPLICABLE` for a data-layer phase. The story-level mobile launch smoke (rule 12g) is a story obligation, not a P1 slice obligation — final synthesis owns it.
- Visual fidelity: phase §6 `Per-story visual fidelity: NOT_APPLICABLE` — P1 renders no screen. Story-level `visual-fidelity/` evidence for `23h-vua-ve-j8` (P3) and `2-so-tay-nguoi-yeu` (P4) is out of this slice.

## State recommendation

None from this slice. `Outcome: PARTIAL_SLICE_ONLY` — P1 contributes no blocking
finding to the story verdict. Carry F-1 into the final synthesis as an open
cross-phase question against P3, and F-2/F-3 as deferred notes.

REVIEW_SLICE_COMPLETE: YES
