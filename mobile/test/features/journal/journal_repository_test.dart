import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/journal/data/journal_repository.dart';
import 'package:cupid_mobile/features/journal/domain/journal_entry.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late CupidDatabase database;
  late Directory baseDir;
  late JournalMediaStore mediaStore;
  late BackendUserIdStore userIdStore;
  late JournalRepository repository;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    baseDir = Directory.systemTemp.createTempSync('journal_repository_test');
    userIdStore = BackendUserIdStore()..updateUserId('user-a');
    mediaStore = JournalMediaStore(
      baseDirectory: () async => baseDir,
      ownerUserId: () => userIdStore.backendUserId,
    );
    repository = JournalRepository(
      database: database,
      mediaStore: mediaStore,
      backendUserIdStore: userIdStore,
    );
  });

  tearDown(() async {
    await database.close();
    if (baseDir.existsSync()) {
      baseDir.deleteSync(recursive: true);
    }
  });

  File writeSource(String name) {
    final file = File(p.join(baseDir.path, name));
    file.writeAsStringSync('ảnh $name');
    return file;
  }

  Future<List<FileSystemEntity>> rootContents() async {
    final root = await mediaStore.rootDir();
    return root.existsSync() ? root.listSync(recursive: true) : const [];
  }

  /// The media root is owner-scoped (F-B1), so a signed-out `mediaStore` has no
  /// path to report on. This is how the signed-out cases still inspect what
  /// `user-a` left on disk.
  JournalMediaStore storeFor(String ownerUserId) => JournalMediaStore(
        baseDirectory: () async => baseDir,
        ownerUserId: () => ownerUserId,
      );

  group('saveEntry', () {
    test('stores the entry with its imported photos', () async {
      final source = writeSource('a.jpg');

      final saved = await repository.saveEntry(
        id: 'e-1',
        bodyText: 'hôm nay trời đẹp',
        photoSourcePaths: <String>[source.path],
        now: DateTime.utc(2026, 9, 7),
      );

      expect(saved, isNotNull);
      expect(saved!.bodyText, 'hôm nay trời đẹp');
      expect(saved.ownerUserId, 'user-a');
      expect(saved.origin, JournalEntryOrigin.manual);
      expect(saved.photos, hasLength(1));
      expect(
        (await mediaStore.resolvePhoto(saved.photos.single.relativePath))
            .existsSync(),
        isTrue,
      );
    });

    test('re-saving the same id keeps createdAt and does not mint a new row '
        '(AC-3)', () async {
      await repository.saveEntry(
        id: 'e-1',
        bodyText: 'bản 1',
        now: DateTime.utc(2026, 9, 7),
      );

      final edited = await repository.saveEntry(
        id: 'e-1',
        bodyText: 'bản 2',
        now: DateTime.utc(2026, 9, 8),
      );

      expect(edited!.bodyText, 'bản 2');
      expect(edited.createdAt, DateTime.utc(2026, 9, 7).millisecondsSinceEpoch);
      expect(edited.updatedAt, DateTime.utc(2026, 9, 8).millisecondsSinceEpoch);
      expect(await repository.watchEntries().first, hasLength(1));
    });

    test('skips a seed path that is no longer readable instead of failing '
        '(contract-summary §3)', () async {
      final present = writeSource('a.jpg');
      final missing = File(p.join(baseDir.path, 'gone.jpg'));

      final saved = await repository.saveEntry(
        id: 'e-1',
        bodyText: '',
        photoSourcePaths: <String>[missing.path, present.path],
      );

      expect(saved!.photos, hasLength(1));
    });

    test('deletes the files it just imported when the transaction fails',
        () async {
      final source = writeSource('a.jpg');
      await database.customStatement('DROP TABLE journal_photos');

      await expectLater(
        repository.saveEntry(
          id: 'e-1',
          bodyText: 'sẽ hỏng',
          photoSourcePaths: <String>[source.path],
        ),
        throwsA(anything),
      );

      final leftover = (await rootContents()).whereType<File>();
      expect(leftover, isEmpty);
      expect(source.existsSync(), isTrue);
    });

    test('records an external entry with its opaque originRef', () async {
      final saved = await repository.saveEntry(
        id: 'e-1',
        bodyText: 'từ màn khác',
        origin: JournalEntryOrigin.external,
        originRef: 'opaque-token',
      );

      expect(saved!.origin, JournalEntryOrigin.external);
      expect(saved.originRef, 'opaque-token');
    });
  });

  group('deleteEntry', () {
    test('leaves no file of the deleted entry and keeps the others (AC-12)',
        () async {
      final source = writeSource('a.jpg');
      await repository.saveEntry(
        id: 'e-1',
        bodyText: 'một',
        photoSourcePaths: <String>[source.path],
      );
      await repository.saveEntry(
        id: 'e-2',
        bodyText: 'hai',
        photoSourcePaths: <String>[source.path],
      );

      await repository.deleteEntry('e-1');

      expect((await mediaStore.entryDir('e-1')).existsSync(), isFalse);
      expect((await mediaStore.entryDir('e-2')).listSync(), hasLength(1));
      expect(await repository.entryById('e-1'), isNull);
      expect(await repository.entryById('e-2'), isNotNull);
    });
  });

  group('deleteAll', () {
    test('empties both the table and the media root (AC-12)', () async {
      final source = writeSource('a.jpg');
      await repository.saveEntry(
        id: 'e-1',
        bodyText: 'một',
        photoSourcePaths: <String>[source.path],
      );
      await repository.saveEntry(
        id: 'e-2',
        bodyText: 'hai',
        photoSourcePaths: <String>[source.path],
      );

      await repository.deleteAll();

      expect(await repository.watchEntries().first, isEmpty);
      expect((await mediaStore.rootDir()).existsSync(), isFalse);
    });
  });

  group('sweepOrphans', () {
    test('cleans up files left by a process killed between the two delete '
        'phases (AC-13)', () async {
      final source = writeSource('a.jpg');
      await repository.saveEntry(
        id: 'e-1',
        bodyText: 'một',
        photoSourcePaths: <String>[source.path],
      );
      await repository.saveEntry(
        id: 'e-2',
        bodyText: 'hai',
        photoSourcePaths: <String>[source.path],
      );

      // Phase 1 only: the DB transaction commits, then the process dies before
      // the media directory is removed.
      await database.journalDao.deleteEntry('user-a', 'e-1');
      expect((await mediaStore.entryDir('e-1')).existsSync(), isTrue);

      await repository.sweepOrphans();

      expect((await mediaStore.entryDir('e-1')).existsSync(), isFalse);
      expect((await mediaStore.entryDir('e-2')).listSync(), hasLength(1));
    });
  });

  group('two owners on one device (F-B1, AC-2)', () {
    late String relativePathA;

    setUp(() async {
      final source = writeSource('a.jpg');
      final saved = await repository.saveEntry(
        id: 'e-a',
        bodyText: 'của user-a',
        photoSourcePaths: <String>[source.path],
      );
      relativePathA = saved!.photos.single.relativePath;
      userIdStore.updateUserId('user-b');
    });

    Future<bool> photoOfAExists() async =>
        (await storeFor('user-a').resolvePhoto(relativePathA)).existsSync();

    test('B opening the journal sweeps only B, leaving A\'s photo files',
        () async {
      await repository.sweepOrphans();

      expect(await photoOfAExists(), isTrue);
      userIdStore.updateUserId('user-a');
      final entries = await repository.watchEntries().first;
      expect(entries, hasLength(1));
      expect(entries.single.photos, hasLength(1));
    });

    test('B\'s "xoá toàn bộ nhật ký" leaves A\'s rows and files intact (AC-12)',
        () async {
      await repository.saveEntry(id: 'e-b', bodyText: 'của user-b');

      await repository.deleteAll();

      expect(await repository.watchEntries().first, isEmpty);
      expect(await photoOfAExists(), isTrue);
      userIdStore.updateUserId('user-a');
      expect(await repository.watchEntries().first, hasLength(1));
    });

    test('B cannot read A\'s entry even by id (AC-2)', () async {
      expect(await repository.entryById('e-a'), isNull);
      expect(await repository.watchEntries().first, isEmpty);
    });
  });

  group('without a backend user id', () {
    setUp(() async {
      final source = writeSource('a.jpg');
      await repository.saveEntry(
        id: 'e-1',
        bodyText: 'của user-a',
        photoSourcePaths: <String>[source.path],
      );
      await userIdStore.clearOnSignOut();
    });

    test('reads return empty rather than an unfiltered query (AC-2)', () async {
      expect(await repository.watchEntries().first, isEmpty);
      expect(await repository.entryById('e-1'), isNull);
    });

    test('writes are refused and nothing reaches disk', () async {
      final source = writeSource('b.jpg');

      final saved = await repository.saveEntry(
        id: 'e-2',
        bodyText: 'không được lưu',
        photoSourcePaths: <String>[source.path],
      );

      expect(saved, isNull);
      expect((await storeFor('user-a').entryDir('e-2')).existsSync(), isFalse);
    });

    test('deletes and sweeps do not touch the signed-out user data', () async {
      await repository.deleteEntry('e-1');
      await repository.deleteAll();
      await repository.sweepOrphans();

      expect((await storeFor('user-a').entryDir('e-1')).listSync(),
          hasLength(1));
      userIdStore.updateUserId('user-a');
      expect(await repository.watchEntries().first, hasLength(1));
    });
  });

  group('privacy egress gate', () {
    const forbidden = <String>[
      'share_plus',
      'dio',
      'cupid_api',
      'RealtimeCoordinator',
      'Clipboard',
      'hydrated_bloc',
    ];

    for (final path in const <String>[
      'lib/core/journal/journal_media_store.dart',
      'lib/features/journal/domain/journal_entry.dart',
      'lib/features/journal/data/journal_repository.dart',
    ]) {
      test('$path imports nothing that could carry journal content off device '
          '(AC-6, AC-7, AC-10)', () {
        final imports = File(path)
            .readAsLinesSync()
            .where((line) => line.startsWith('import '));

        for (final token in forbidden) {
          expect(
            imports.where((line) => line.contains(token)),
            isEmpty,
            reason: '$path must not import $token',
          );
        }
      });
    }
  });
}
