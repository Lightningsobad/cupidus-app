import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'daos/expense_dao.dart';
import 'daos/journal_dao.dart';
import 'daos/message_dao.dart';
import 'daos/timeline_dao.dart';
import 'tables/expenses_table.dart';
import 'tables/journal_entries.dart';
import 'tables/journal_photos.dart';
import 'tables/messages_table.dart';
import 'tables/timeline_tables.dart';

part 'cupid_database.g.dart';

/// The app's single Drift owner (`architecture/solution.md` §4 Boundaries And
/// Ownership). Later long-history domains (timeline, expenses per ADR-007)
/// add their tables and DAOs here, not in their own feature directories,
/// because Drift's single-database annotation forces one owner and `core/`
/// must never import `features/`.
@DriftDatabase(
  tables: [
    Messages,
    TimelineEntries,
    TimelineSyncState,
    Expenses,
    ExpenseSyncMetadata,
    JournalEntries,
    JournalPhotos,
  ],
  daos: [MessageDao, TimelineDao, ExpenseDao, JournalDao],
)
class CupidDatabase extends _$CupidDatabase {
  CupidDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  /// From v3 onward this database is NO LONGER a disposable cache, and a
  /// destructive-recreate migration is forbidden.
  ///
  /// v1 (messages, timeline) and v2 (expenses) hold server-authoritative rows
  /// that a refetch can rebuild, which is why the v2 upgrade note said dropping
  /// everything would also have been acceptable. v3 adds `journal_entries` /
  /// `journal_photos`, which are device-authoritative: they exist nowhere else,
  /// on no server, and a recreate would silently destroy content the user
  /// typed (`architecture/solution.md` §1 Key Discovery 1 and 3). Every future
  /// migration must therefore be additive, or migrate journal data explicitly.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(expenses);
            await m.createTable(expenseSyncMetadata);
          }
          if (from < 3) {
            await m.createTable(journalEntries);
            await m.createTable(journalPhotos);
          }
        },
        beforeOpen: (details) async {
          // Enforces `journal_photos.entryId` ON DELETE CASCADE; SQLite
          // ignores foreign keys unless this is set per connection.
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
