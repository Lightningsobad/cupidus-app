import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'daos/activity_card_dao.dart';
import 'daos/chapter_closure_dao.dart';
import 'daos/expense_dao.dart';
import 'daos/invite_message_dao.dart';
import 'daos/journal_dao.dart';
import 'daos/message_dao.dart';
import 'daos/relationship_labels_dao.dart';
import 'daos/timeline_dao.dart';
import 'tables/activity_cards_table.dart';
import 'tables/calendar_event_state_table.dart';
import 'tables/chapter_closure_tables.dart';
import 'tables/context_notebook_tables.dart';
import 'tables/expenses_table.dart';
import 'tables/invite_messages_table.dart';
import 'tables/journal_entries.dart';
import 'tables/journal_photos.dart';
import 'tables/messages_table.dart';
import 'tables/portrait_answers_table.dart';
import 'tables/relationship_labels_table.dart';
import 'tables/thank_you_activations_table.dart';
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
/// Tags one absolute path as excluded from OS backup. Injected rather than
/// imported so `core/database/` stays free of a platform channel and tests keep
/// running without a binary messenger (`architecture/solution.md` §7.4).
typedef BackupExclusion = Future<void> Function(String absolutePath);

@DriftDatabase(
  tables: [
    Messages,
    TimelineEntries,
    TimelineSyncState,
    Expenses,
    ExpenseSyncMetadata,
    ActivityCards,
    ActivityCardPhotos,
    JournalEntries,
    JournalPhotos,
    InviteMessages,
    NotebookEntries,
    SkillProfileEntries,
    AskPromptState,
    CalendarEventState,
    PortraitAnswers,
    RelationshipLabels,
    ChapterClosures,
    ChapterClosureItems,
    ThankYouActivations,
  ],
  daos: [
    MessageDao,
    TimelineDao,
    ExpenseDao,
    ActivityCardDao,
    JournalDao,
    InviteMessageDao,
    RelationshipLabelsDao,
    ChapterClosureDao,
  ],
)
class CupidDatabase extends _$CupidDatabase {
  CupidDatabase([QueryExecutor? executor, BackupExclusion? excludeFromBackup])
      : super(executor ?? _openConnection(excludeFromBackup));

  @override
  int get schemaVersion => 11;

  /// From v3 onward this database is NO LONGER a disposable cache, and a
  /// destructive-recreate migration is forbidden.
  ///
  /// v1 (messages, timeline) and v2 (expenses) hold server-authoritative rows
  /// that a refetch can rebuild, which is why the v2 upgrade note said dropping
  /// everything would also have been acceptable. v3 adds `activity_cards` /
  /// `activity_card_photos` AND `journal_entries` / `journal_photos` together
  /// (STORY-001 + STORY-003 merged into one version, not two): all four tables
  /// are device-authoritative, they exist nowhere else, on no server, and a
  /// recreate would silently destroy content the user typed
  /// (`architecture/solution.md` §1 Key Discovery 1 and 3). v4 adds the five
  /// B-1 activity-card columns. v5 adds `activity_cards.location` and the
  /// device-authoritative `invite_messages` table. v6 adds the three
  /// device-authoritative context-notebook tables. v7 adds the
  /// device-authoritative `calendar_event_state` and `portrait_answers`
  /// tables. v8 adds the device-authoritative `relationship_labels` table.
  /// v9 adds the two chapter-closure ledger tables (STORY-013, authored
  /// assuming it would land at v7; renumbered to v9 when merged after
  /// STORY-009's v7 and STORY-010's v8). v10 adds the device-authoritative
  /// `thank_you_activations` ledger (STORY-007). v11 adds the three nullable
  /// origin columns on `notebook_entries` (REQ-017 STORY-001). Every migration
  /// step here and onward must therefore be additive, or migrate the data
  /// explicitly.
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
            await m.createTable(journalEntries);
            await m.createTable(journalPhotos);
          } else {
            // `createTable` above always emits the *current* table definition,
            // so a machine coming from v2 already received every later column
            // (and the journal tables) and re-adding them would fail on a
            // duplicate column/table name. Only machines that stopped at v3 or
            // v4 have a narrower activity_cards table.
            //
            // These are sibling `if`s, never an `else if` chain: a machine
            // sitting on v4 needs the v5 column and no v4 one, so chaining
            // would skip exactly the largest group of real devices.
            if (from < 4) {
              await m.addColumn(activityCards, activityCards.durationMinutes);
              await m.addColumn(activityCards, activityCards.timeOfDaySlot);
              await m.addColumn(activityCards, activityCards.noteKeywords);
              await m.addColumn(activityCards, activityCards.linkSourceLabel);
              await m.addColumn(activityCards, activityCards.linkSavedAt);
            }
            if (from < 5) {
              await m.addColumn(activityCards, activityCards.location);
            }
          }
          if (from < 5) {
            await m.createTable(inviteMessages);
          }
          if (from < 6) {
            await m.createTable(notebookEntries);
            await m.createTable(skillProfileEntries);
            await m.createTable(askPromptState);
          } else if (from < 11) {
            // `createTable` above emits the *current* `notebook_entries`
            // definition, so a machine coming from v5 already received the
            // three origin columns and re-adding them would fail on a
            // duplicate column name. Only machines that stopped between v6 and
            // v10 have the narrower table.
            await m.addColumn(notebookEntries, notebookEntries.originCheckInRef);
            await m.addColumn(notebookEntries, notebookEntries.originCardId);
            await m.addColumn(notebookEntries, notebookEntries.originCardTitle);
          }
          if (from < 7) {
            await m.createTable(calendarEventState);
            await m.createTable(portraitAnswers);
          }
          if (from < 8) {
            await m.createTable(relationshipLabels);
          }
          if (from < 9) {
            await m.createTable(chapterClosures);
            await m.createTable(chapterClosureItems);
            await m.createIndex(chapterClosureItemsKindItem);
          }
          if (from < 10) {
            await m.createTable(thankYouActivations);
          }
        },
        // `ON DELETE CASCADE` on activity_card_photos.card_id,
        // journal_photos.entryId and invite_messages.card_id is inert unless
        // foreign key enforcement is switched on for the connection, and
        // sqlite defaults it off on every open.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection([BackupExclusion? excludeFromBackup]) {
  return LazyDatabase(() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final file = File('${documentsDir.path}${Platform.pathSeparator}cupid.sqlite');
    if (excludeFromBackup != null) {
      // Runs on the root isolate: `createInBackground`'s setup callbacks have
      // no binary messenger, so a MethodChannel would fail there. The file is
      // created empty first because the tag has to be in place before the
      // first journal line is written; SQLite reads a zero-byte file as a
      // valid empty database. The sidecars are best-effort — today's
      // journaling mode only ever produces `-journal`, and it is normally
      // absent (`architecture/solution.md` §7.1, §7.5).
      if (!file.existsSync()) {
        await file.create(recursive: true);
      }
      for (final path in <String>[
        file.path,
        '${file.path}-journal',
        '${file.path}-wal',
        '${file.path}-shm',
      ]) {
        if (File(path).existsSync()) {
          await excludeFromBackup(path);
        }
      }
    }
    return NativeDatabase.createInBackground(file);
  });
}
