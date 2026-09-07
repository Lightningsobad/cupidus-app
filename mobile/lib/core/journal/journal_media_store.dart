import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

/// Sole owner of every filesystem path under the private journal's media root
/// (`architecture/solution.md` §4 Boundaries And Ownership). No other file may
/// build a journal photo path: two-phase delete (AC-13) is only sound while one
/// class decides where a photo lives and what "orphan" means.
///
/// [baseDirectory] is injected rather than resolved inline so it stays the
/// single place the OS-backup-excluded location is decided (AC-9). On Android
/// the exclusion is declarative and this class does nothing for it; on iOS
/// there is no manifest equivalent, so [excludeFromBackup] tags each directory
/// as it is created. Both mechanisms and their sources are recorded in
/// `coding-plan/test-results.md`.
class JournalMediaStore {
  JournalMediaStore({
    required Future<Directory> Function() baseDirectory,
    Future<void> Function(String absolutePath)? excludeFromBackup,
  })  : _baseDirectory = baseDirectory,
        _excludeFromBackup = excludeFromBackup ?? _backupExclusionNotNeeded;

  static const String mediaRootName = 'journal_media';

  static Future<void> _backupExclusionNotNeeded(String _) async {}

  final Future<Directory> Function() _baseDirectory;
  final Future<void> Function(String absolutePath) _excludeFromBackup;
  final Random _random = Random.secure();

  Future<Directory> rootDir() async {
    final base = await _baseDirectory();
    return Directory(p.join(base.path, mediaRootName));
  }

  Future<Directory> entryDir(String entryId) async {
    final root = await rootDir();
    return Directory(p.join(root.path, entryId));
  }

  /// Copies [sourcePath] into this entry's directory under a fresh id and
  /// returns the path relative to [rootDir], which is what `journal_photos`
  /// stores. The copy is what makes the caller's file and the journal's file
  /// independent lifetimes (`contract-summary.md` §3).
  Future<String> importPhoto(String entryId, String sourcePath) async {
    // Root and entry directory are tagged separately: Apple documents
    // isExcludedFromBackup per URL and never states that it descends into a
    // directory's contents.
    await _createExcluded(await rootDir());
    final dir = await _createExcluded(await entryDir(entryId));
    final fileName = '${_newFileId()}${p.extension(sourcePath)}';
    await File(sourcePath).copy(p.join(dir.path, fileName));
    return p.join(entryId, fileName);
  }

  Future<File> resolvePhoto(String relativePath) async {
    final root = await rootDir();
    return File(p.join(root.path, relativePath));
  }

  Future<void> deleteEntryDir(String entryId) async {
    final dir = await entryDir(entryId);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> deleteRoot() async {
    final root = await rootDir();
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  }

  /// Deletes every directory under the media root whose name is not a live
  /// entry id. This is the compensating half of the DB-row-first delete: if the
  /// process dies after the transaction commits but before the files go, the
  /// next feature open is what finally removes them (AC-13).
  Future<void> sweepOrphans(Iterable<String> liveEntryIds) async {
    final root = await rootDir();
    if (!root.existsSync()) {
      return;
    }
    final live = liveEntryIds.toSet();
    await for (final entity in root.list(followLinks: false)) {
      if (!live.contains(p.basename(entity.path))) {
        await entity.delete(recursive: true);
      }
    }
  }

  Future<Directory> _createExcluded(Directory dir) async {
    final created = await dir.create(recursive: true);
    await _excludeFromBackup(created.path);
    return created;
  }

  String _newFileId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
