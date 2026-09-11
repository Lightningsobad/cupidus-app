# Review Slice S1 — P1 Local Card Store (schema · DAO · v2→v3 migration)

Phase: SCOPED_SLICE
REVIEW_SLICE_COMPLETE: YES
Slice verdict: PASS_WITH_FINDINGS (no blocking finding raised by this slice)

## Identity

- Story: STORY-001, REQ-016
- Slice: S1 of 8, per `review/scope-gate.md` § Prescribed Slice Plan
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Diff baseline: `9207f7296a64cd37ca60e432939469ca96860762`
- AC source of truth: `requirements/requirements.md` (AC-1..AC-23), per scope gate

## Files Actually Read

All 9 in-scope source/test files were opened. `cupid_database.g.dart` was
spot-checked by range only (lines 2380-2409, 2900-3019, 3195-3246, 5100-5218) —
`activity_cards` column emission, `activity_card_photos` FK constraint, the
`Index` declaration, and `allSchemaEntities`. Evidence: `requirements.md`,
`phase-P1-local-card-store.md`, `contract-summary.md` §1-§4, `solution.md` §4,
`test-results.md` lines 1-99 (P1 section only).

## Critical Gates

| # | Gate | Rule source | Verdict | Evidence |
|---|---|---|---|---|
| G1 | v2→v3 migration is additive, no destructive recreate | ADR-015.6 / master-plan §6 / solution §4 | **PASS** | `cupid_database.dart:53-72` — `onUpgrade` contains only `createTable`/`createIndex`; no `drop*`, no `deleteTable`, no recreate. `from < 2` and `from < 3` are independent additive steps, so a v1 device also upgrades cleanly. |
| G2 | Migration verified on a populated older DB | phase-P1 §4, solution §4 (`MIGRATION_TEST_UNAVAILABLE`) | **PASS** | `activity_card_migration_test.dart:61-72` asserts `user_version == 3` plus survival of a v2 expense row and a v1 timeline row. |
| G3 | R-1b — no read-receipt / seen / open-count column or field | AC-18, contract §4 | **PASS** | `activity_cards_table.dart:47-97` — 17 columns, none matching `seen`/`opened`/`openCount`/`viewedAt`/`partner_*`/`*_latency`/`response_rate`/`last_seen`. `activity_cards_table.dart:106-118` — photo table carries only `id`/`card_id`/`local_path`/`sort_index`. `activity_card_dao.dart` exposes no behaviour read or write. |
| G4 | Column set is **exactly** the §3 allowlist, enforced by test | phase-P1 §6, solution §4 (`R1B_SCHEMA_GATE_MISSING`) | **PASS** | `activity_card_dao_test.dart:68-92` uses set **equality**, not subset — any added column fails the build. Fragment blocklist at `:95-118` covers every name in contract §4. |
| G5 | `schemaVersion` bumped 2 → 3 | contract §5 | **PASS** | `cupid_database.dart:46`; asserted in `activity_card_dao_test.dart:62`, `expense_dao_test.dart`, `timeline_dao_test.dart`. |
| G6 | SC-1' / AC-21 — exactly one card store | AC-21, BR-1, ADR-010 | **PASS** | `activity_card_dao_test.dart:128-142` scans `lib/` and asserts exactly one `@DriftDatabase`. Both tables are registered on the existing `CupidDatabase` (`cupid_database.dart:30-41`), not a second Drift owner. |
| G7 | AC-8 — full structured field set present from this story (BR-13/SB-76) | AC-8 | **PASS** | All 10 AC-8 fields map 1:1: `title:50` · `activityType:64` · `scheduledOn:69` · `priceVnd:71` · `distanceKm:73` · `needsBooking:76` · `indoorOutdoor:78` · `note:80` · photos → `ActivityCardPhotos:106` · `sourceLink:83`. Only `title` is NOT NULL (AC-6). |
| G8 | AC-9 — every card carries an internal `origin`, never a metric | AC-9 | **PASS** | `activity_cards_table.dart:62` `origin` TEXT NOT NULL, no default → insert-time required. Display prohibition is a UI concern (S4/S6). |
| G9 | Card store survives sign-out (client-owned originals) | solution §4 row 1 (`LOCAL_DATA_OWNERSHIP_UNVERIFIED`), BR-12 | **PASS** | `activity_card_dao.dart:15-18` does not implement `SessionScopedStore`; `activity_card_dao_test.dart:304-334` asserts both the type fact and card survival after running every listed `clearOnSignOut()`. |
| G10 | `ON DELETE CASCADE` is actually enforced, not inert | phase-P1 §3 | **PASS** | FK emitted at `cupid_database.g.dart:2920-2923`; `PRAGMA foreign_keys = ON` in `beforeOpen` (`cupid_database.dart:69-71`), which drift runs **after** migrations — correct ordering, since FK enforcement during a table-creating migration is the usual failure mode. Behaviour proven at `activity_card_dao_test.dart:279-301`. |
| G11 | Pane index exists after upgrade, and is not double-created | phase-P1 §3 | **PASS** | Declared once at `cupid_database.g.dart:3223-3226` and listed as a separate entity in `allSchemaEntities:3237-3246`, so `createAll()` (fresh install) and `createIndex` (upgrade) are mutually exclusive paths, never both in one run. Asserted at `activity_card_migration_test.dart:74-91`. |
| G12 | Changes outside the declared P1 write scope are minimal and behaviour-neutral | phase-P1 §1B | **PASS** | `git diff` of the two extra test files is +3/−2 each: only the pinned `schemaVersion` assertion and the test name. No other assertion touched. Matches the disclosure at `test-results.md:81-93`. |
| G13 | `owner_key` filtering on **every** query | contract §3 `owner_key` row; `activity_cards_table.dart:37-39`; `activity_card_dao.dart:13-14` | **FAIL (non-blocking, see F-1)** | 3 of 8 DAO methods take no `ownerKey`: `upsertCard:72`, `upsertPhoto:97`, `photosForCard:101`. |
| G14 | AC-15 — status-only write does not clear other fields, at the store layer | solution §4 (`LIFECYCLE_PURITY_UNVERIFIED`); master-plan §3A binds AC-15 to P2+P6 | **UNVERIFIED at this layer** | `updateCard:78-86` uses a partial `Companion`, so drift writes only present columns — structurally column-pure. But no P1 test asserts that `scheduled → idea` preserves `scheduled_on`/`note`/photos. Owner: S2 (repository) and S6 (detail screen). |
| G15 | AC-10 — the leading *Tất cả* pane has a read path | AC-10 (added by D-1) | **UNVERIFIED at this layer** | The DAO offers no all-status read; `cardsByStatus`/`watchCardsByStatus` both require a `status`. Owner: S2/S4. See F-3. |

Not applicable to this slice: runtime startup smoke and per-story visual
fidelity, both declared `NOT_APPLICABLE` in `phase-P1-local-card-store.md`
§1B/§6 because P1 builds no screen. Confirmed correct — no widget code in scope.

## Findings

### F-1 — MEDIUM — `owner_key` isolation claim is broader than the code

`mobile/lib/core/database/daos/activity_card_dao.dart:72` (`upsertCard`),
`:97` (`upsertPhoto`), `:101` (`photosForCard`).

Three documents state the isolation invariant without qualification:
`contract-summary.md` §3 (`owner_key` … "mọi truy vấn lọc theo cột này"),
`activity_cards_table.dart:37-39` ("Multi-user isolation on a shared device is
done with `ownerKey` on every query"), and `activity_card_dao.dart:13-14`
("`ownerKey` filtering on every query"). Three of the eight DAO methods do not
take an `ownerKey` at all. `upsertCard` is an `insertOnConflictUpdate` keyed on
the `id` primary key only, so a caller holding another owner's card id can
rewrite that row — including reassigning its `ownerKey`. `photosForCard` will
return another owner's local photo paths for a known card id.

This is the load-bearing claim behind the decision **not** to implement
`SessionScopedStore` (G9): the story trades sign-out wiping for query-time
isolation, so the query-time half should hold everywhere. The isolation tests at
`activity_card_dao_test.dart:254-276` cover only the four read/delete methods
that already filter, so the gap is untested in both directions.

Practical exposure is low — ids are client-generated UUID v4s and callers
normally obtain them from an owner-filtered read — which is why this is MEDIUM
and not blocking. Recommended fix, cheapest first: add `required String
ownerKey` to `photosForCard` (join through `activity_cards`), and either add an
owner guard to `upsertCard`/`upsertPhoto` or narrow the three doc comments to
say "every read path", so the contract stops promising more than it enforces.

### F-2 — LOW — sign-out survival is cited as AC-22, which says something else

`mobile/lib/core/database/tables/activity_cards_table.dart:39` ·
`mobile/lib/core/database/daos/activity_card_dao.dart:13` ·
`mobile/test/core/database/activity_card_dao_test.dart:12`, `:304`.

All three cite AC-22 for "the card store must survive sign-out". In the AC
source of truth, AC-22 (`requirements.md:182-192`) is the *positioning + 4-tab
navigation* criterion ("Muốn làm · Ý tưởng · Sổ tay · Nhật ký"); it says nothing
about sign-out. The sign-out rule actually comes from `solution.md` §1 Key
Discovery and the §4 risk row *Mất dữ liệu gốc khi đăng xuất*, plus BR-12 —
which is exactly what `phase-P1-local-card-store.md` §1B lists as its
requirement inputs (AC-8, AC-9, AC-17, AC-18, BR-5, BR-12, BR-13; AC-22 is
absent).

The behaviour is correct and well tested; only the citation is wrong. Left
uncorrected it will mislead the 11 downstream stories that read this contract,
and it double-books the "AC-22" label with S4's real tab-bar work. Fix is a
three-line comment edit: cite `solution.md` §1/§4 + BR-12.

Note for S8: the same numbering drift is present in `scope-gate.md` itself,
whose S1 query keys name "AC-3, AC-6" for the structured field set and
behaviour-tracking ban. Under `requirements.md` those are AC-8 and AC-18. This
slice verified against `requirements.md`, per the scope gate's own instruction
that `requirements.md` is authoritative.

### F-3 — LOW — no all-status read path for the *Tất cả* pane (AC-10)

`mobile/lib/core/database/daos/activity_card_dao.dart:21-46`.

AC-10 was patched in by ruling D-1 and now requires a leading *Tất cả* view
listing cards in every status. The store layer, written before that patch,
exposes only per-status reads. This is not necessarily a defect — the repository
can union four queries, or S2 may already have added an all-status read above
this layer — but it is not resolvable inside S1's file list. S2/S4 must confirm
the *Tất cả* pane has a real backing read; if it is assembled by four separate
paged queries, the paging semantics of the combined view need a look, because
`limit`/`offset` do not compose across four independent queries.

### F-4 — INFO — the migration fixture is derived from the current schema

`mobile/test/core/database/activity_card_migration_test.dart:19-50`.

The "v2" database is built by opening the *v3* schema on a file, dropping the
three v3 objects, and setting `PRAGMA user_version = 2`. The tradeoff is
disclosed both in the test comment and at `test-results.md:52-54`, and it is the
right call for keeping the fixture in step with the real v1/v2 table
definitions. It does mean the test cannot detect a divergence between today's
`expenses`/`timeline` definitions and the DDL genuinely shipped at v2. Given
those are disposable caches under ADR-007, the residual risk is acceptable. If
this story's tables ever need a v3→v4 migration, drift's schema-dump tooling
(`drift_dev schema dump` + generated verifier) is the durable answer, since
`activity_cards` will no longer be droppable to build the fixture.

### F-5 — INFO — `clearOnSignOut` enumeration is hand-written, not read from DI

`mobile/test/core/database/activity_card_dao_test.dart:313-319`.

The "run every registered `clearOnSignOut`" test iterates a literal list of
stores rather than the real DI graph, so a future story that registers the card
DAO as a session-scoped store through `service_locator.dart` would not fail this
test. The companion assertion at `:305-307` (`dao` is not a
`SessionScopedStore`) is type-level and does catch the most likely regression,
so coverage is adequate; recording it only so a later story does not over-trust
this test's name.

## Test Evidence Assessment

`test-results.md:19-50` records `flutter test test/core/database/` → 40/40 pass,
exit 0, with each of the phase file's §6 named gates mapped to a concrete test
name. Every mapped test name in that table exists in the two test files as
written — spot-checked all 19 rows against
`activity_card_dao_test.dart`/`activity_card_migration_test.dart`. The static
analysis entry (`:56-79`) is honest about `flutter analyze lib test` exiting 1
with 188 pre-existing issues and reports 0 errors with none in P1's files;
the scoped run `flutter analyze lib/core/database test/core/database` is clean.
No re-run performed in this slice — the evidence is specific enough to check by
name, which it passes.

## Carried To S8

- F-1 (MEDIUM) needs a disposition: patch the three methods, or narrow the three
  doc comments. Owner: Mobile Developer.
- F-2 (LOW) citation fix, 3 lines. Owner: Mobile Developer.
- F-3 (LOW) must be closed by S2 or S4, not by S1.
- G14 (AC-15 store-layer purity) is UNVERIFIED here by design and belongs to
  S2/S6 — do not treat this slice's silence as a pass.
- Neither FLAG-1 nor FLAG-2 from `scope-gate.md` is resolvable at this layer;
  S1 found nothing in the store that contradicts either.

REVIEW_SLICE_COMPLETE: YES
