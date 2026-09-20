# Slice Review — P1 (context notebook persistence)

- Story: REQ-016 / STORY-004
- Slice: P1-persistence (3 Drift tables + single owning repository)
- Reviewer: Iris-QC
- Date: 2026-09-11
- Diff base: `e5b3741743744241cd8cfb60543cf6d37f0ec946`
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Scope note: this is a bounded slice verdict only, not a story-level verdict.

## 1. Verdict table

| Item | Result | Evidence |
|---|---|---|
| AC-4 | PASS (persistence layer) | `context_notebook_tables.dart:45` `questionId` TEXT NULL; repository `addEntry` writes it (`context_notebook_repository.dart:73`), `entries`/`entryById` read it back (`:249`); tests `an answered question round-trips with its stable question id`, `a manually typed entry carries no question id`. Edit/delete paths exist (`updateEntry` `:88`, `deleteEntry` `:118`). |
| AC-6 | PASS (schema layer) | `NotebookKind` is a closed 2-value enum `interest`/`event` (`context_notebook_models.dart:10-23`); no third "đánh giá/nhận xét người ấy" kind exists. `detail` is a note *inside* the same row (`context_notebook_tables.dart:33`), not a category. Column set asserted by exact set-equality in `notebook_entries measures nothing about the partner (AC-25)` (`context_notebook_migration_test.dart:228-239`) — no rating/comment column can be added without turning that test red. |
| AC-9 | PASS | Group `sửa và xoá có hiệu lực ngay (AC-9)` (`context_notebook_repository_test.dart:114-189`), 4 tests: edit rewrites value/detail and re-reads changed; clearing `detail` writes a real NULL; `deleteEntry` returns `1` and `entryById` then returns `null`; skill edit+delete take effect immediately. No soft-delete/trash column exists in the schema. |
| AC-12 | PASS | `SkillProfileEntries` has exactly `id, ownerKey, label, seedId, source, createdAt, updatedAt` (`context_notebook_tables.dart:58-79`); domain `SkillEntry` mirrors it (`context_notebook_models.dart:105-126`). Test `skill_profile_entries carries no proficiency dimension (AC-12)` asserts exact column-set equality plus explicit denial of `level/star/stars/score/rank/rating/proficiency`. |
| AC-25 | PASS (storage half) | `notebook_entries` column set asserted equal to `{id, owner_key, kind, value, detail, event_on, source, question_id, created_at, updated_at}`; no `partner_*`/`seen_*`/`reply_*`/`frequency_*` prefix allowed (`context_notebook_migration_test.dart:224-252`). `ask_prompt_state` has no counter column — asserted at `:254-263`, and the "how many times asked" dimension is absent by design (`context_notebook_tables.dart:83-86`). Nothing in this slice stores a partner-behavior quantity. |
| R-15a (durable ids) | PASS | `id` is a client-generated UUID v4 TEXT primary key, never rowid/autoincrement (`context_notebook_tables.dart:20,52`; generator `context_notebook_repository.dart:268-278`, `Random.secure()`, correct v4/variant bits, 8-4-4-4-12 layout). Ids are never rewritten on update (`updateEntry`/`updateSkill` touch only value/label/detail/eventOn/updatedAt). Content-pack references are stored as stable text ids, not code symbols: `question_id` (`:45`), `seed_id` (`:68`), so swapping the content source needs no schema or code change. Test `two adds produce two different client-generated ids (R-15a)`. |
| R-15c (invariant rules enforced as a runnable gate, projected here as the banned-column list) | PASS | The forbidden-column list of `architecture/contract-summary.md` §4 is enforced executably, not editorially: three tests in group `cột bị cấm vĩnh viễn (R-1b / AC-12 / AC-25)` compare the *generated* SQLite schema (`PRAGMA table_info`) against an exact allowlist. Because the assertion is set-equality rather than `containsAll`, any future added column — including one whose name is not on the denylist — turns the build red. |

## 2. Phase acceptance criteria (phase-P1 §4)

| Phase AC | Result | Evidence |
|---|---|---|
| Three tables exist; `schemaVersion` +1 over the real prior value | PASS | `cupid_database.dart` 5 → 6; `NotebookEntries, SkillProfileEntries, AskPromptState` added to `tables:`; migration step is `if (from < 6) { createTable × 3 }` — `CREATE TABLE` only, no `ALTER`, no drop-recreate. Verified live: `expect(await readUserVersion(fresh), 6)` and `expect(fresh.schemaVersion, 6)` both green. |
| Migration preserves all `activity_cards` / `journal_entries` / `invite_messages` rows | PASS | `every pre-existing client-owned row survives the upgrade intact` seeds one real row per table, strips the v6 additions, rewinds `PRAGMA user_version = 5`, reopens, and asserts content (`Đi ăn lẩu`, `thẻ viết từ hồi v5`, `Hôm nay trời đẹp`, `invite.rap_phim.v1`). |
| Repository edit/delete effective immediately (AC-9); ask-on-the-spot entry re-readable with `question_id` (AC-4) | PASS | See AC-9 / AC-4 rows above. |
| No grading column on `skill_profile_entries`, no partner-behavior column on `notebook_entries` | PASS | See AC-12 / AC-25 rows above. |

## 3. Independent test verification

Re-run by the reviewer (not merely quoted from the dev record):

```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test \
  test/core/database/context_notebook_migration_test.dart \
  test/features/context_notebook/context_notebook_repository_test.dart --reporter compact
=> 00:03 +25: All tests passed!
```

25 = 8 migration + 17 repository, which matches the counts recorded in
`test-results.md` §"Phase P1" (`+8`, `+17`) exactly. The story-root
`test-results.md` is the file that carries §Phase P1; `coding-plan/test-results.md`
has no P1 section (it starts at P4) — the phase file §7 pointer (`../test-results.md`)
is the correct one, the handoff's path is not.

Analyzer result (`flutter analyze lib test`: 0 error · 35 warning · 178 info) is
taken from the recorded evidence and not re-run in this slice; the 4 new
`prefer_initializing_formals` info items at `context_notebook_repository.dart:27-30`
are consistent with the constructor as written.

## 4. Contract conformance

`architecture/contract-summary.md` §4 was compared column-for-column against
`context_notebook_tables.dart`. All three tables match exactly, including
nullability, the `TEXT`-not-`DateTime` choice for `event_on` (civil date, no UTC
drift), and the composite PK `(owner_key, question_id)` on `ask_prompt_state`
(asserted live at `context_notebook_migration_test.dart:168-180`).

Single-door rule holds: `ContextNotebookDao` is the only code touching the three
tables, every DAO method takes `ownerKey` explicitly, and there is no unfiltered
read. Cross-owner isolation is proven, not assumed — `a second user on the same
device sees none of the first user rows` and `another owner cannot edit or delete
rows that are not theirs` (update returns `null`, delete returns `0`).

## 5. Sibling-file ripple spot-check

Spot-checked 2 of the 6 disclosed schemaVersion-shift files:

- `test/core/database/expense_dao_test.dart`: 1 line, `expect(database.schemaVersion, 5)` → `6`. No logic change.
- `test/core/database/migration_v5_test.dart`: 3 lines, all `readUserVersion`/`schemaVersion` `5` → `6`; surrounding `location` column and `invite_messages` assertions untouched.

Both are constant-only, matching the disclosed pattern. The remaining 4 were not
deep-reviewed, per slice instructions.

## 6. Observations and residual risks (none blocking this slice)

1. **v5 fixture is derived from v6, not from a real historical v5.** `seedV5`
   opens the current schema and then drops the three new tables. This proves the
   additive step, but it cannot catch a v6 change that silently altered an
   *existing* table's shape, because the fixture would inherit that change too.
   Mitigated in practice: the diff touches no other table definition, and
   `migration_v5_test.dart` still asserts `location` + `invite_messages` on the
   upgraded database. Worth noting for the next schema bump, not a defect here.
2. **Weak timestamp assertion.** `context_notebook_repository_test.dart:135`
   asserts `reread.updatedAt.isBefore(created.updatedAt), isFalse` using the real
   `DateTime.now`. The repository already accepts an injectable `now` (`:26`), so
   a strictly-greater assertion with a fake clock would be tighter. Cosmetic.
3. **`fromWireValue` throws on an unknown value** (`context_notebook_models.dart:19,36,56`).
   For a closed enum written only by this app that is the correct strict choice;
   it becomes a hard read failure only in a downgrade scenario where a newer
   build wrote an unknown `kind`. Acceptable given the append-only rule stated in
   the file header.
4. **Out of slice, flagged for the P6 reviewer only:** the `service_locator.dart`
   diff also registers `GiftRepository` and `GiftSelector` (`+ contextNotebookReader()`),
   which belong to P6, not P1. The context-notebook registrations themselves
   (`ContextNotebookDao`, `ContextNotebookRepository`, both `registerLazySingleton`,
   neither a `SessionScopedStore`) are correct for client-owned data that must
   survive sign-out.
5. **Generated file.** `cupid_database.g.dart` was regenerated in the same commit
   (`ca111f7`) and is the only `.g.dart` changed; its content was not reviewed, per
   slice instructions.

## 7. Slice result

Outcome: PARTIAL_SLICE_ONLY

This value is the scoped-slice pass: every item inside the declared P1 scope is
PASS, and no story-level verdict is asserted. The final story outcome comes from
the later final-synthesis pass, not from this file.

All 5 slice ACs (AC-4, AC-6, AC-9, AC-12, AC-25) and both invariants (R-15a,
R-15c) are PASS at the persistence layer. Nothing in this slice is FAIL or
UNVERIFIED.

Deferred by design to later slices, not defects here: the UI half of AC-4/AC-6/
AC-9 (edit and delete affordances on the notebook and skill screens) and the
display half of AC-25 belong to the P4 screen slice.

REVIEW_SLICE_COMPLETE: YES
