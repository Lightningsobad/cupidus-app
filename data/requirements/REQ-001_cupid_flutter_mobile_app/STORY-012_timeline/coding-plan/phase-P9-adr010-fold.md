# STORY-012 timeline — P9 ADR-010 Canonical-Drift-Owner Fold

Post-P8 hardening pass: ADR-010 requires exactly one canonical Drift database
class. Timeline had drifted onto a second, non-canonical `AppDatabase`
(`mobile/lib/core/database/app_database.dart`) instead of extending the
canonical `CupidDatabase` (`mobile/lib/core/database/cupid_database.dart`,
already owning `MessageDao`/`Messages`). This phase folds Timeline's tables
and DAO into `CupidDatabase` and removes `AppDatabase` entirely.

## Tables/DAO merged

- `TimelineEntries`, `TimelineSyncState` — moved verbatim (doc comments
  preserved) from `app_database.dart` into new file
  `mobile/lib/core/database/tables/timeline_tables.dart`.
- New `TimelineDao` (`mobile/lib/core/database/daos/timeline_dao.dart`),
  `@DriftAccessor(tables: [TimelineEntries, TimelineSyncState])`, extending
  `DatabaseAccessor<CupidDatabase>` and implementing `SessionScopedStore`
  (matching the existing `MessageDao` convention). Carries the same
  `watchFirstPage`, `replaceFirstPage`, `lastSyncedAt`, `clearOnSignOut`
  methods `AppDatabase` previously exposed directly.
- `mobile/lib/core/database/cupid_database.dart` `@DriftDatabase` annotation
  extended: `tables: [Messages, TimelineEntries, TimelineSyncState]`,
  `daos: [MessageDao, TimelineDao]`. `cupid_database.g.dart` and
  `timeline_dao.g.dart` regenerated via
  `dart run build_runner build --delete-conflicting-outputs`.

## Call sites migrated (AppDatabase → CupidDatabase/TimelineDao)

- `mobile/lib/features/timeline/data/timeline_repository.dart`: constructor
  parameter retyped from `db.AppDatabase` to `TimelineDao`; body unchanged
  (already only called DAO-shaped methods).
- `mobile/lib/core/di/service_locator.dart`: removed the standalone
  `AppDatabase` singleton registration. `CupidDatabase` is now the single
  registered singleton; `TimelineDao` is registered as
  `getIt<CupidDatabase>().timelineDao`, registered as the `SessionScopedStore`
  with `CupidSession` (replacing the prior direct `AppDatabase` registration),
  and injected into `TimelineRepository`. The pre-existing `CouplePairingStore`
  registration immediately below is untouched.
- Deleted `mobile/lib/core/database/app_database.dart` and
  `mobile/lib/core/database/app_database.g.dart`. Confirmed via
  `git grep -rn "app_database\|AppDatabase" -- mobile/lib mobile/test` →
  no matches.

## Tests updated

Moved/rewritten off `AppDatabase` onto `CupidDatabase`/`TimelineDao`:

- `mobile/test/core/database/app_database_test.dart` → renamed
  `timeline_dao_test.dart`; DAO-method tests now call `dao.*`, direct-table
  tests (`schemaVersion`, raw `select`) still call `database.*`.
- `mobile/test/features/timeline/data/timeline_repository_test.dart`
- `mobile/test/features/timeline/presentation/timeline_cubit_test.dart`
- `mobile/test/features/timeline/presentation/create_entry_cubit_test.dart`
- `mobile/test/features/timeline/presentation/create_memory_sheet_test.dart`
- `mobile/test/features/timeline/presentation/timeline_screen_test.dart`
- `mobile/test/features/home/presentation/timeline_entry_point_test.dart`

Each sets up `database = CupidDatabase(NativeDatabase.memory())` /
`dao = database.timelineDao` in `setUp`, constructs
`TimelineRepository(dao, ...)`, and calls DAO methods (`dao.replaceFirstPage`,
`dao.lastSyncedAt`) instead of the old direct database methods. Direct-table
assertions (`database.select(database.timelineEntries)`) and
`database.close()` teardown were left unchanged.

## Verification

See `coding-plan/test-results.md` P9 addendum for the full command output and
pre-existing-failure confirmation. Summary: scoped Timeline+DB suite 76/76
pass; full unscoped `flutter test` 196/199 pass, with the same 3 failures as
recorded in the P8 gate (unrelated `CouplePairingStore`/GetIt test-harness gap
in `feature_flags_test.dart`, `splash_screen_test.dart`, `widget_test.dart`),
confirmed still identical and reproducible on pre-fold HEAD via `git stash`.
No new failures introduced by this fold.
