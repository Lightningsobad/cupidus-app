# STORY-012 timeline — ADR-010 Fold Review (scoped)

Scope: this review covers ONLY the ADR-010 canonical-Drift-owner fold applied
on top of the already-`DEFERRED_ONLY`-reviewed P1-P8 implementation at
BaseHead `8b898c427ada94df5a9d058888e545a4c2e7f78d`. That prior verdict is
final and out of scope here. Reviewed diff: `BaseHead..HEAD`
(`7378530` on top of `36ed769`, `5f5587e`).

## What changed

- `mobile/lib/core/database/app_database.dart`/`.g.dart` deleted (102-line
  standalone `AppDatabase` Drift class removed entirely).
- `TimelineEntries`/`TimelineSyncState` table defs moved verbatim (byte-for-byte
  identical columns/primary keys) into
  `mobile/lib/core/database/tables/timeline_tables.dart`.
- A new `TimelineDao` (`DatabaseAccessor<CupidDatabase>` +
  `implements SessionScopedStore`) was added at
  `mobile/lib/core/database/daos/timeline_dao.dart`, carrying
  `watchFirstPage`/`replaceFirstPage`/`lastSyncedAt`/`clearOnSignOut` with
  identical logic to the old `AppDatabase` methods (transaction shape,
  ordering, upsert-by-id-0 sync-state marker, sign-out wipe of both tables).
- `CupidDatabase` (`mobile/lib/core/database/cupid_database.dart`, the
  pre-existing canonical DB owner from STORY-007, staged into this worktree by
  `36ed769`) now declares `tables: [Messages, TimelineEntries,
  TimelineSyncState]`, `daos: [MessageDao, TimelineDao]`. `MessageDao`/
  `Messages` are untouched pass-through additions from the staging commit, not
  edited by the fold itself.
- `TimelineRepository` and all call sites (`timeline_repository.dart`,
  `create_entry_cubit_test.dart`, `create_memory_sheet_test.dart`,
  `timeline_cubit_test.dart`, `timeline_screen_test.dart`,
  `timeline_entry_point_test.dart`, `timeline_repository_test.dart`,
  renamed `app_database_test.dart` -> `timeline_dao_test.dart`) migrated from
  taking `AppDatabase` to taking `TimelineDao`.
- `mobile/lib/core/di/service_locator.dart`: adds one
  `registerLazySingleton<CupidDatabase>(CupidDatabase.new)`, and rewires the
  existing `TimelineDao` registration to resolve
  `getIt<CupidDatabase>().timelineDao` and register *that* as the
  session-scoped store (previously the `AppDatabase` instance itself was
  registered). Single registration site, no duplicates.

## Findings

1. **Schema fold is exact.** `TimelineEntries`/`TimelineSyncState` table
   column sets, types, and primary keys are unchanged char-for-char between
   the deleted `app_database.dart` and the new `tables/timeline_tables.dart`.
   `schemaVersion` stays `1` in both the old `AppDatabase` and the new
   `CupidDatabase` — no migration path is introduced or needed (pre-release,
   single local cache table set, consistent with STORY-012's own prior
   `schemaVersion => 1`).
2. **DAO logic is behavior-preserving.** `TimelineDao`'s four methods are
   line-for-line the same transaction/query logic as the old
   `AppDatabase` methods, just moved from `class AppDatabase extends
   _$AppDatabase` to `class TimelineDao extends DatabaseAccessor<CupidDatabase>
   with _$TimelineDaoMixin`. `implements SessionScopedStore` and
   `clearOnSignOut` are preserved, so the D-012-5 sign-out wipe guarantee
   (no cross-user cache leakage) is intact.
3. **DI wiring correctly threads the new ownership.** `service_locator.dart`
   registers `CupidDatabase` once, derives `TimelineDao` from it, and
   registers the *dao* (not the database) as the scoped store — this is the
   right object to scope, since `clearOnSignOut` lives on the dao now.
   `TimelineRepository` construction correctly takes the dao. No duplicate
   `CupidDatabase` registration exists elsewhere in the file.
4. **No leftover dual-database references.** `git grep -n
   "app_database\|AppDatabase" -- mobile/lib mobile/test` returns zero matches
   (independently reproduced by this review), matching the P9 addendum claim.
   Worktree `git status --porcelain` is clean.
5. **AC1-AC4 are unaffected.** The fold touches only the persistence-layer
   owner (table/DAO location and DI wiring); it does not touch
   `timeline_repository.dart` business logic beyond the constructor
   parameter's static type, nor the cubit, screen, create-sheet, DTO, or
   pairing-store files that actually implement create/view/offline-read/
   pairing-gate behavior. Cross-checked against `story_master.md` AC1-AC4 —
   no AC-relevant behavior change.
6. **P9 evidence is sufficient.** `test-results.md` P9 addendum reports
   `build_runner` PASS (219 outputs, produces `cupid_database.g.dart` +
   `timeline_dao.g.dart`), scoped `flutter test` 76/76 PASS, full `flutter
   test` 196/199 PASS with the same 3 pre-existing/unrelated failures already
   recorded in the P8 gate (reconfirmed via `git stash` against the pre-fold
   HEAD `36ed769`, identical `CouplePairingStore`/GetIt harness-gap stack
   trace), and the `AppDatabase` grep sweep. This is consistent with what this
   review independently verified in the diff and via its own grep sweep.
7. **Minor, non-blocking:** `test-results.md`'s original (pre-P9) "Scope
   note" section still says `... writes through TimelineRepository.createEntry
   -> refresh() -> AppDatabase.replaceFirstPage`, and `story_master.md`'s
   Status header still names `AppDatabase->CupidDatabase fold` as the reason
   it's blocked despite the fold now being applied on this branch. Both are
   stale prose in already-existing docs, not code; they don't affect AC
   behavior or the fold's correctness and are cheap to fix in the next state
   sync, not a merge blocker.

## Outcome

Outcome: CLEAN

The fold is a faithful, behavior-preserving migration of Timeline's Drift
persistence from the standalone `AppDatabase` into the canonical
`CupidDatabase` (ADR-010). Schema, DAO logic, and session-scoped sign-out
wipe are preserved; DI wiring is correct and non-duplicated; no dual-database
references remain; AC1-AC4 are unaffected; P9 verification evidence is
sufficient to support `MOBILE_COMPLETE`. The stale doc prose noted above (item
7) is cosmetic and does not block merge.

REVIEW_COMPLETE: YES
