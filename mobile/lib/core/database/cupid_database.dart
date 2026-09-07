import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'daos/activity_card_dao.dart';
import 'daos/expense_dao.dart';
import 'daos/message_dao.dart';
import 'daos/timeline_dao.dart';
import 'tables/activity_cards_table.dart';
import 'tables/expenses_table.dart';
import 'tables/messages_table.dart';
import 'tables/timeline_tables.dart';

part 'cupid_database.g.dart';

/// The app's single Drift owner (`architecture/solution.md` §4 Boundaries And
/// Ownership). Later long-history domains (timeline, expenses per ADR-007)
/// add their tables and DAOs here, not in their own feature directories,
/// because Drift's single-database annotation forces one owner and `core/`
/// must never import `features/`.
///
/// Two data layers live here with different rules. Everything except
/// [ActivityCards]/[ActivityCardPhotos] is a disposable read-through cache
/// (ADR-007), where a destructive drop-and-recreate migration is legitimate.
/// The activity card tables are client-owned solo data with no server
/// counterpart, so they are the only copy in existence: their migrations must
/// always be additive (`architecture/solution.md` §1 Key Discovery).
@DriftDatabase(
  tables: [
    Messages,
    TimelineEntries,
    TimelineSyncState,
    Expenses,
    ExpenseSyncMetadata,
    ActivityCards,
    ActivityCardPhotos,
  ],
  daos: [MessageDao, TimelineDao, ExpenseDao, ActivityCardDao],
)
class CupidDatabase extends _$CupidDatabase {
  CupidDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  /// Every upgrade step here is additive. v2 (expenses) is additive to v1
  /// (messages, timeline) and would also tolerate a destructive recreate since
  /// the cache is disposable; v3 (activity cards) must NOT, because those rows
  /// are user-owned originals.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(expenses);
            await m.createTable(expenseSyncMetadata);
          }
          if (from < 3) {
            await m.createTable(activityCards);
            await m.createTable(activityCardPhotos);
            await m.createIndex(activityCardsOwnerStatus);
          }
        },
        // `ON DELETE CASCADE` on activity_card_photos.card_id is inert unless
        // foreign key enforcement is switched on for the connection, and
        // sqlite defaults it off on every open.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final file = File('${documentsDir.path}${Platform.pathSeparator}cupid.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}
