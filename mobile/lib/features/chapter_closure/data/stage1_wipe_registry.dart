import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/cupid_database.dart';
import '../../../core/journal/journal_media_store.dart';

/// One REQ-016 table plus the predicate that selects a single owner's rows in
/// it.
///
/// The predicate is assembled from generated Drift metadata
/// (`actualTableName`, `GeneratedColumn.name`), never from hand-typed SQL
/// identifiers: a renamed column then breaks the build instead of silently
/// leaving rows behind after a wipe. The owner key itself is bound as a `?`
/// variable, so no caller-supplied text ever reaches the statement.
class Stage1WipeTable {
  const Stage1WipeTable({required this.table, required this.ownerWhere});

  final TableInfo<Table, dynamic> table;

  /// SQL predicate containing exactly one `?`, bound to the owner key.
  final String ownerWhere;

  String get tableName => table.actualTableName;

  String get deleteStatement => 'DELETE FROM $tableName WHERE $ownerWhere';
}

/// One app-owned directory tree that holds REQ-016 media for the current owner.
class Stage1MediaRoot {
  const Stage1MediaRoot({
    required this.name,
    required this.directory,
    required this.delete,
  });

  final String name;

  /// Resolves the root without creating it, so a test can assert
  /// `existsSync()` before and after the wipe.
  final Future<Directory> Function() directory;

  final Future<void> Function() delete;
}

/// The single list of everything stage 1 owns on this device
/// (`architecture/contract-summary.md` §4).
///
/// It exists so that "what does leaving actually delete?" has exactly one
/// answer. A new REQ-016 table that is not registered here is caught by
/// `test/features/chapter_closure/stage1_wipe_registry_parity_test.dart`, which
/// compares this list against `CupidDatabase.allTables`.
class Stage1WipeRegistry {
  Stage1WipeRegistry({
    required CupidDatabase db,
    required JournalMediaStore journalMediaStore,
  })  : _db = db,
        _journalMediaStore = journalMediaStore;

  final CupidDatabase _db;
  final JournalMediaStore _journalMediaStore;

  /// Child tables come before their parents. `ON DELETE CASCADE` would also
  /// take them, but only while `PRAGMA foreign_keys = ON` holds; deleting them
  /// explicitly makes the wipe independent of that pragma.
  List<Stage1WipeTable> get tables {
    final $ActivityCardsTable cards = _db.activityCards;
    final $JournalEntriesTable journalEntries = _db.journalEntries;
    final $ChapterClosuresTable closures = _db.chapterClosures;

    return <Stage1WipeTable>[
      Stage1WipeTable(
        table: _db.activityCardPhotos,
        ownerWhere: _viaParent(
          child: _db.activityCardPhotos.cardId,
          parent: cards,
          parentKey: cards.id,
          ownerColumn: cards.ownerKey,
        ),
      ),
      Stage1WipeTable(
        table: _db.inviteMessages,
        ownerWhere: _viaParent(
          child: _db.inviteMessages.cardId,
          parent: cards,
          parentKey: cards.id,
          ownerColumn: cards.ownerKey,
        ),
      ),
      Stage1WipeTable(table: cards, ownerWhere: _ownedBy(cards.ownerKey)),
      Stage1WipeTable(
        table: _db.journalPhotos,
        ownerWhere: _viaParent(
          child: _db.journalPhotos.entryId,
          parent: journalEntries,
          parentKey: journalEntries.id,
          ownerColumn: journalEntries.ownerUserId,
        ),
      ),
      Stage1WipeTable(
        table: journalEntries,
        ownerWhere: _ownedBy(journalEntries.ownerUserId),
      ),
      Stage1WipeTable(
        table: _db.notebookEntries,
        ownerWhere: _ownedBy(_db.notebookEntries.ownerKey),
      ),
      Stage1WipeTable(
        table: _db.skillProfileEntries,
        ownerWhere: _ownedBy(_db.skillProfileEntries.ownerKey),
      ),
      Stage1WipeTable(
        table: _db.askPromptState,
        ownerWhere: _ownedBy(_db.askPromptState.ownerKey),
      ),
      Stage1WipeTable(
        table: _db.chapterClosureItems,
        ownerWhere: _viaParent(
          child: _db.chapterClosureItems.closureId,
          parent: closures,
          parentKey: closures.id,
          ownerColumn: closures.ownerKey,
        ),
      ),
      Stage1WipeTable(table: closures, ownerWhere: _ownedBy(closures.ownerKey)),
    ];
  }

  /// The journal media root is the only app-owned media tree stage 1 writes.
  /// `activity_card_photos.localPath` is deliberately absent: those rows point
  /// at paths this app never copied into a directory of its own, so deleting
  /// the files would reach outside the app's data and destroy the user's own
  /// pictures. Wiping the rows is the whole of that table's cleanup.
  List<Stage1MediaRoot> get mediaRoots => <Stage1MediaRoot>[
        Stage1MediaRoot(
          name: JournalMediaStore.mediaRootName,
          directory: _journalMediaStore.rootDir,
          delete: _journalMediaStore.deleteRoot,
        ),
      ];

  /// Matched by prefix, so a key family that carries an id in its name can be
  /// listed once (`before_you_go.dismissed_on.<cardId>` is one key per card).
  /// An exact key is its own prefix, so a future fixed key needs no new
  /// mechanism.
  ///
  /// Only REQ-016-owned keys appear here. Auth, pairing, realtime, theme,
  /// reminder, gallery and notification preferences belong to other features
  /// and must survive leaving stage 1.
  static const List<String> preferenceKeys = <String>[
    'before_you_go.dismissed_on.',
  ];

  String _ownedBy(GeneratedColumn<String> ownerColumn) =>
      '${ownerColumn.name} = ?';

  String _viaParent({
    required GeneratedColumn<String> child,
    required TableInfo<Table, dynamic> parent,
    required GeneratedColumn<String> parentKey,
    required GeneratedColumn<String> ownerColumn,
  }) {
    return '${child.name} IN (SELECT ${parentKey.name} '
        'FROM ${parent.actualTableName} WHERE ${ownerColumn.name} = ?)';
  }
}
