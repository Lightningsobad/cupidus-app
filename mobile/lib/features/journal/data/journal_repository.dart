import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/cupid_database.dart' as db;
import '../../../core/database/daos/journal_dao.dart';
import '../../../core/journal/journal_media_store.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../domain/journal_entry.dart';

/// Joins [JournalDao] and [JournalMediaStore] into the atomic operations the
/// journal UI calls (`architecture/solution.md` §4 Contracts And Integrations).
///
/// The ordering rules here are the whole point of the class:
/// * save imports files *before* the transaction, and unwinds them if the
///   transaction throws, so a failed save leaves no file behind;
/// * delete commits the row removal *before* touching files, so a crash can
///   only ever leave surplus files — which [sweepOrphans] removes on the next
///   feature open (AC-13) — and never a row pointing at a missing photo.
class JournalRepository {
  JournalRepository({
    required db.CupidDatabase database,
    required JournalMediaStore mediaStore,
    required BackendUserIdStore backendUserIdStore,
  })  : _database = database,
        _mediaStore = mediaStore,
        _backendUserIdStore = backendUserIdStore;

  final db.CupidDatabase _database;
  final JournalMediaStore _mediaStore;
  final BackendUserIdStore _backendUserIdStore;

  JournalDao get _dao => _database.journalDao;

  /// `null` before the first backend profile sync. Every method below treats
  /// that as "read nothing, write nothing" rather than falling back to an
  /// unfiltered query, which would leak one account's journal to the next
  /// account on the same device (AC-2).
  String? get _ownerUserId {
    final id = _backendUserIdStore.backendUserId;
    return (id == null || id.isEmpty) ? null : id;
  }

  Stream<List<JournalEntry>> watchEntries({int limit = 50, int offset = 0}) {
    final owner = _ownerUserId;
    if (owner == null) {
      return Stream<List<JournalEntry>>.value(const <JournalEntry>[]);
    }
    return _dao
        .watchEntries(owner, limit: limit, offset: offset)
        .asyncMap((rows) => Future.wait(rows.map(_toDomain)));
  }

  Future<JournalEntry?> entryById(String id) async {
    final owner = _ownerUserId;
    if (owner == null) {
      return null;
    }
    final row = await _dao.entryById(owner, id);
    return row == null ? null : _toDomain(row);
  }

  /// Writes (or rewrites) one entry together with its photos. Returns `null`
  /// when there is no owner id yet, meaning the write was refused.
  Future<JournalEntry?> saveEntry({
    required String id,
    required String bodyText,
    List<String> photoSourcePaths = const <String>[],
    JournalEntryOrigin origin = JournalEntryOrigin.manual,
    String? originRef,
    DateTime? now,
  }) async {
    final owner = _ownerUserId;
    if (owner == null) {
      return null;
    }

    final timestamp = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final existing = await _dao.entryById(owner, id);

    final imported = <db.JournalPhotosCompanion>[];
    final importedPaths = <String>[];
    for (var i = 0; i < photoSourcePaths.length; i++) {
      final source = photoSourcePaths[i];
      // An unreadable seed path is skipped, not raised: the caller's file may
      // have gone away between picking and saving (`contract-summary.md` §3).
      if (!File(source).existsSync()) {
        continue;
      }
      final relativePath = await _mediaStore.importPhoto(id, source);
      importedPaths.add(relativePath);
      imported.add(
        db.JournalPhotosCompanion.insert(
          id: '$id-${importedPaths.length}-$timestamp',
          entryId: id,
          relativePath: relativePath,
          sortIndex: i,
          createdAt: timestamp,
        ),
      );
    }

    try {
      await _database.transaction(() async {
        await _dao.upsertEntry(
          owner,
          db.JournalEntry(
            id: id,
            ownerUserId: owner,
            bodyText: bodyText,
            createdAt: existing?.createdAt ?? timestamp,
            updatedAt: timestamp,
            origin: origin.name,
            originRef: originRef,
          ),
        );
        await (_database.delete(_database.journalPhotos)
              ..where((t) => t.entryId.equals(id)))
            .go();
        for (final photo in imported) {
          await _database.into(_database.journalPhotos).insert(photo);
        }
      });
    } catch (_) {
      for (final relativePath in importedPaths) {
        final file = await _mediaStore.resolvePhoto(relativePath);
        if (file.existsSync()) {
          await file.delete();
        }
      }
      rethrow;
    }

    return entryById(id);
  }

  Future<void> deleteEntry(String id) async {
    final owner = _ownerUserId;
    if (owner == null) {
      return;
    }
    await _dao.deleteEntry(owner, id);
    await _mediaStore.deleteEntryDir(id);
  }

  /// AC-12: one confirmation, one transaction, then the media root goes with
  /// it. No undo buffer keeps a copy.
  Future<void> deleteAll() async {
    final owner = _ownerUserId;
    if (owner == null) {
      return;
    }
    await _dao.deleteAllEntries(owner);
    await _mediaStore.deleteRoot();
  }

  /// Called when the journal feature opens. Without an owner id nothing is
  /// known to be live, so sweeping would delete the signed-out user's photos.
  Future<void> sweepOrphans() async {
    final owner = _ownerUserId;
    if (owner == null) {
      return;
    }
    await _mediaStore.sweepOrphans(await _dao.liveEntryIds(owner));
  }

  Future<JournalEntry> _toDomain(db.JournalEntry row) async {
    final photos = await (_database.select(_database.journalPhotos)
          ..where((t) => t.entryId.equals(row.id))
          ..orderBy([(t) => OrderingTerm(expression: t.sortIndex)]))
        .get();
    return JournalEntry(
      id: row.id,
      ownerUserId: row.ownerUserId,
      bodyText: row.bodyText,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      origin: JournalEntryOrigin.fromStorage(row.origin),
      originRef: row.originRef,
      photos: photos
          .map(
            (p) => JournalEntryPhoto(
              id: p.id,
              relativePath: p.relativePath,
              sortIndex: p.sortIndex,
              createdAt: p.createdAt,
            ),
          )
          .toList(),
    );
  }
}
