import 'package:drift/drift.dart';

import 'journal_entries.dart';

/// Photos attached to a [JournalEntries] row. Owner scoping is inherited
/// through [entryId]; this table has no `ownerUserId` of its own, so every
/// query must join or subquery through the owning entry.
class JournalPhotos extends Table {
  TextColumn get id => text()();

  TextColumn get entryId =>
      text().references(JournalEntries, #id, onDelete: KeyAction.cascade)();

  /// Relative to the journal media root, never an absolute path — the app
  /// sandbox directory changes between installs and OS upgrades.
  TextColumn get relativePath => text()();

  IntColumn get sortIndex => integer()();

  /// Epoch milliseconds UTC.
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
