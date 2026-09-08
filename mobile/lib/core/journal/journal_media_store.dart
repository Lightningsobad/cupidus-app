import 'dart:convert';
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
///
/// [ownerUserId] is required because the media root is per-owner: `ownerUserId`
/// is "the only isolation between two accounts sharing one device"
/// (`domain/journal_entry.dart`), and a device-wide root would let account B's
/// `sweepOrphans`/`deleteRoot` delete account A's photo files while leaving A's
/// rows behind (F-B1).
class JournalMediaStore {
  JournalMediaStore({
    required Future<Directory> Function() baseDirectory,
    required String? Function() ownerUserId,
    Future<void> Function(String absolutePath)? excludeFromBackup,
  })  : _baseDirectory = baseDirectory,
        _ownerUserId = ownerUserId,
        _excludeFromBackup = excludeFromBackup ?? _backupExclusionNotNeeded;

  static const String mediaRootName = 'journal_media';

  static Future<void> _backupExclusionNotNeeded(String _) async {}

  final Future<Directory> Function() _baseDirectory;
  final String? Function() _ownerUserId;
  final Future<void> Function(String absolutePath) _excludeFromBackup;
  final Random _random = Random.secure();

  /// Hex of the owner id's UTF-8 bytes rather than the id itself: the id comes
  /// from the backend, so it must not be able to carry a path separator or
  /// `..` into a path, and hex is injective so two owners can never collide
  /// onto one directory.
  static String ownerSegment(String ownerUserId) => utf8
      .encode(ownerUserId)
      .map((int b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  /// Throws when there is no owner id. Every write path is already gated on an
  /// owner by `JournalRepository`; the one ungated read (`resolvePhoto` behind
  /// the list thumbnail) degrades to a neutral square rather than reading from
  /// a shared root.
  String _requireOwnerSegment() {
    final owner = _ownerUserId();
    if (owner == null || owner.isEmpty) {
      throw StateError(
        'JournalMediaStore has no owner id; journal media is owner-scoped and '
        'has no device-wide root to fall back to.',
      );
    }
    return ownerSegment(owner);
  }

  /// The shared `journal_media/` parent. Holds no files of its own — only one
  /// subdirectory per owner — and exists here so the backup-exclusion tag can
  /// be applied to every level of the chain.
  Future<Directory> mediaRootDir() async {
    final base = await _baseDirectory();
    return Directory(p.join(base.path, mediaRootName));
  }

  /// The current owner's media root, `journal_media/<ownerSegment>/`.
  Future<Directory> rootDir() async {
    final parent = await mediaRootDir();
    return Directory(p.join(parent.path, _requireOwnerSegment()));
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
    // Every level is tagged separately: Apple documents isExcludedFromBackup
    // per URL and never states that it descends into a directory's contents.
    await _createExcluded(await mediaRootDir());
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
