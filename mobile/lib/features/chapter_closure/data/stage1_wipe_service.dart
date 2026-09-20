import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/cupid_database.dart';
import '../../../core/database/daos/chapter_closure_dao.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../domain/chapter_closure_gate.dart';
import 'stage1_wipe_registry.dart';

/// Leaving stage 1 for real (AC-14/AC-15,
/// `architecture/contract-summary.md` §4).
///
/// Deliberately not a `SessionScopedStore` and it never calls
/// `clearOnSignOut()` (AC-29): leaving is a decision the user makes about their
/// own data, not a session teardown, and the session is expected to still be
/// usable afterwards. Routing it through sign-out would both log the user out
/// and leave the sign-out path deleting data it does not own.
class Stage1WipeService {
  Stage1WipeService({
    required CupidDatabase db,
    required ChapterClosureDao dao,
    required ChapterClosureGate gate,
    required BackendUserIdStore ownerKeyStore,
    required Stage1WipeRegistry registry,
    Future<SharedPreferences> Function() preferences =
        SharedPreferences.getInstance,
  })  : _db = db,
        _dao = dao,
        _gate = gate,
        _ownerKeyStore = ownerKeyStore,
        _registry = registry,
        _preferences = preferences;

  final CupidDatabase _db;
  final ChapterClosureDao _dao;
  final ChapterClosureGate _gate;
  final BackendUserIdStore _ownerKeyStore;
  final Stage1WipeRegistry _registry;
  final Future<SharedPreferences> Function() _preferences;

  /// Deletes everything stage 1 owns for the current owner: every registered
  /// table in one transaction, then the media roots, then the preference keys.
  ///
  /// Rows before files, matching `JournalRepository.deleteAll()`. A crash
  /// between the two can then only leave surplus files whose rows are already
  /// gone — recoverable — never a row pointing at a file that no longer exists.
  Future<void> wipeAll() async {
    final String ownerKey = await _requireOwnerKey();

    await _db.transaction(() async {
      for (final Stage1WipeTable entry in _registry.tables) {
        await _db.customUpdate(
          entry.deleteStatement,
          variables: <Variable<Object>>[Variable<String>(ownerKey)],
          updates: <TableInfo<Table, dynamic>>{entry.table},
          updateKind: UpdateKind.delete,
        );
      }
    });

    for (final Stage1MediaRoot root in _registry.mediaRoots) {
      await root.delete();
    }

    final SharedPreferences prefs = await _preferences();
    for (final String key in prefs.getKeys().toList(growable: false)) {
      if (Stage1WipeRegistry.preferenceKeys.any(key.startsWith)) {
        await prefs.remove(key);
      }
    }
  }

  /// Hard-deletes only what the current closure snapshot holds (AC-15), leaving
  /// everything the user kept untouched.
  ///
  /// The snapshot is the authority on membership, not a recomputed predicate:
  /// a card that survived the closure and has since been invited again must not
  /// be dragged into the purge (AC-9).
  ///
  /// No file work here. Private journal entries are never closure members
  /// (BR-6), so nothing under a media root can be part of a closure, and the
  /// activity-card photo rows point at paths this app never copied.
  Future<void> purgeClosed() async {
    final String ownerKey = await _requireOwnerKey();
    final Set<String> cardIds =
        await _gate.closedIdsOf(ChapterClosureItemKind.activityCard);
    final Set<String> notebookIds =
        await _gate.closedIdsOf(ChapterClosureItemKind.notebookEntry);
    final Set<String> questionIds =
        await _gate.closedIdsOf(ChapterClosureItemKind.askPrompt);

    await _db.transaction(() async {
      if (cardIds.isNotEmpty) {
        await (_db.delete(_db.activityCardPhotos)
              ..where((row) => row.cardId.isIn(cardIds)))
            .go();
        await (_db.delete(_db.inviteMessages)
              ..where((row) => row.cardId.isIn(cardIds)))
            .go();
        await (_db.delete(_db.activityCards)
              ..where(
                (row) => row.ownerKey.equals(ownerKey) & row.id.isIn(cardIds),
              ))
            .go();
      }

      if (notebookIds.isNotEmpty) {
        await (_db.delete(_db.notebookEntries)
              ..where(
                (row) =>
                    row.ownerKey.equals(ownerKey) & row.id.isIn(notebookIds),
              ))
            .go();
      }

      if (questionIds.isNotEmpty) {
        await (_db.delete(_db.askPromptState)
              ..where(
                (row) =>
                    row.ownerKey.equals(ownerKey) &
                    row.questionId.isIn(questionIds),
              ))
            .go();
      }

      // The ledger goes last and goes entirely: its members no longer exist, so
      // keeping the rows would leave the "Đã đóng" pane pointing at nothing.
      await _dao.deleteClosuresForOwner(ownerKey);
    });
  }

  Future<String> _requireOwnerKey() async {
    final String? ownerKey = await _ownerKeyStore.resolve();
    if (ownerKey == null || ownerKey.isEmpty) {
      throw StateError(
        'Stage1WipeService used before a backend user id resolved.',
      );
    }
    return ownerKey;
  }
}
