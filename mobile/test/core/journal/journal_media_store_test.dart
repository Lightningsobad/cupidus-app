import 'dart:io';

import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory baseDir;
  late List<String> excluded;
  late String? owner;
  late JournalMediaStore store;

  setUp(() {
    baseDir = Directory.systemTemp.createTempSync('journal_media_store_test');
    excluded = <String>[];
    owner = 'user-a';
    store = JournalMediaStore(
      baseDirectory: () async => baseDir,
      ownerUserId: () => owner,
      excludeFromBackup: (path) async => excluded.add(path),
    );
  });

  tearDown(() {
    if (baseDir.existsSync()) {
      baseDir.deleteSync(recursive: true);
    }
  });

  File writeSource(String name, [String content = 'ảnh gốc']) {
    final file = File(p.join(baseDir.path, name));
    file.writeAsStringSync(content);
    return file;
  }

  test('media root resolves under the configured base directory (AC-9)',
      () async {
    final root = await store.rootDir();

    expect(p.dirname(p.dirname(root.path)), baseDir.path);
    expect(p.basename(p.dirname(root.path)), JournalMediaStore.mediaRootName);
    expect(p.basename(root.path), JournalMediaStore.ownerSegment('user-a'));
  });

  test('entryDir is a direct child of the media root named after the entry',
      () async {
    final root = await store.rootDir();
    final dir = await store.entryDir('e-1');

    expect(p.dirname(dir.path), root.path);
    expect(p.basename(dir.path), 'e-1');
  });

  group('owner scoping (F-B1)', () {
    JournalMediaStore storeFor(String ownerUserId) => JournalMediaStore(
          baseDirectory: () async => baseDir,
          ownerUserId: () => ownerUserId,
        );

    test('two owners on the same device never share a media root', () async {
      final rootA = await storeFor('user-a').rootDir();
      final rootB = await storeFor('user-b').rootDir();

      expect(rootA.path, isNot(rootB.path));
      expect(p.dirname(rootA.path), p.dirname(rootB.path));
    });

    test("account B's sweepOrphans leaves account A's photos untouched",
        () async {
      final source = writeSource('picked.jpg', 'ảnh của A');
      final storeA = storeFor('user-a');
      final storeB = storeFor('user-b');
      final relativePathA = await storeA.importPhoto('e-a', source.path);
      await storeB.importPhoto('e-b', source.path);

      // B opens the journal: nothing of B's is live, so B sweeps its own root
      // clean. A's entry id is unknown to B and must survive regardless.
      await storeB.sweepOrphans(const <String>[]);

      expect((await storeA.resolvePhoto(relativePathA)).existsSync(), isTrue);
      expect((await storeB.rootDir()).listSync(), isEmpty);
    });

    test("account B's deleteRoot leaves account A's photos untouched (AC-12)",
        () async {
      final source = writeSource('picked.jpg', 'ảnh của A');
      final storeA = storeFor('user-a');
      final storeB = storeFor('user-b');
      final relativePathA = await storeA.importPhoto('e-a', source.path);
      await storeB.importPhoto('e-b', source.path);

      await storeB.deleteRoot();

      expect((await storeA.resolvePhoto(relativePathA)).existsSync(), isTrue);
      expect((await storeB.rootDir()).existsSync(), isFalse);
    });

    test('the same entry id under two owners resolves to two different files',
        () async {
      final source = writeSource('picked.jpg');
      final storeA = storeFor('user-a');
      final storeB = storeFor('user-b');

      final relativeA = await storeA.importPhoto('shared-id', source.path);
      await storeB.importPhoto('shared-id', source.path);

      expect(
        (await storeA.resolvePhoto(relativeA)).path,
        isNot((await storeB.resolvePhoto(relativeA)).path),
      );
      expect((await storeB.resolvePhoto(relativeA)).existsSync(), isFalse);
    });

    test('an owner id carrying a path separator cannot escape the media root',
        () async {
      final escaping = storeFor('../../other-app');
      final root = await escaping.rootDir();

      expect(p.basename(p.dirname(root.path)),
          JournalMediaStore.mediaRootName);
      expect(p.split(root.path), isNot(contains('..')));
    });

    test('throws instead of falling back to a device-wide root when there is '
        'no owner id', () async {
      owner = null;

      await expectLater(store.rootDir(), throwsStateError);
      await expectLater(store.resolvePhoto('e-1/a.jpg'), throwsStateError);
    });
  });

  group('backup exclusion (AC-9)', () {
    test('marks both the media root and the entry directory, because the iOS '
        'resource key is documented per URL and not as recursive', () async {
      final source = writeSource('picked.jpg');

      await store.importPhoto('e-1', source.path);

      expect(excluded, contains((await store.rootDir()).path));
      expect(excluded, contains((await store.entryDir('e-1')).path));
    });

    test('re-marks the root after deleteRoot, since deleting a directory drops '
        'the attribute with it', () async {
      final source = writeSource('picked.jpg');
      await store.importPhoto('e-1', source.path);
      await store.deleteRoot();
      excluded.clear();

      await store.importPhoto('e-2', source.path);

      expect(excluded, contains((await store.rootDir()).path));
    });
  });

  group('importPhoto', () {
    test('returns a path relative to the media root and keeps the extension',
        () async {
      final source = writeSource('picked.jpg');

      final relativePath = await store.importPhoto('e-1', source.path);

      expect(p.isRelative(relativePath), isTrue);
      expect(p.split(relativePath).first, 'e-1');
      expect(p.extension(relativePath), '.jpg');
      expect((await store.resolvePhoto(relativePath)).existsSync(), isTrue);
    });

    test('gives each import its own file even from the same source', () async {
      final source = writeSource('picked.jpg');

      final first = await store.importPhoto('e-1', source.path);
      final second = await store.importPhoto('e-1', source.path);

      expect(first, isNot(second));
      final dir = await store.entryDir('e-1');
      expect(dir.listSync().length, 2);
    });

    test('copies rather than references: deleting the caller file leaves the '
        'journal photo intact', () async {
      final source = writeSource('picked.jpg', 'nội dung');
      final relativePath = await store.importPhoto('e-1', source.path);

      source.deleteSync();

      final copy = await store.resolvePhoto(relativePath);
      expect(copy.existsSync(), isTrue);
      expect(copy.readAsStringSync(), 'nội dung');
    });

    test('and the reverse: deleting the journal entry leaves the caller file '
        'intact', () async {
      final source = writeSource('picked.jpg', 'nội dung');
      await store.importPhoto('e-1', source.path);

      await store.deleteEntryDir('e-1');

      expect(source.existsSync(), isTrue);
      expect(source.readAsStringSync(), 'nội dung');
    });
  });

  group('deleteEntryDir', () {
    test('removes every file of that entry and leaves other entries alone',
        () async {
      final source = writeSource('picked.jpg');
      await store.importPhoto('e-1', source.path);
      await store.importPhoto('e-2', source.path);

      await store.deleteEntryDir('e-1');

      expect((await store.entryDir('e-1')).existsSync(), isFalse);
      expect((await store.entryDir('e-2')).listSync(), hasLength(1));
    });

    test('is a no-op for an entry that never had photos', () async {
      await expectLater(store.deleteEntryDir('missing'), completes);
    });
  });

  group('deleteRoot', () {
    test('leaves no journal file behind at all (AC-12)', () async {
      final source = writeSource('picked.jpg');
      await store.importPhoto('e-1', source.path);
      await store.importPhoto('e-2', source.path);

      await store.deleteRoot();

      expect((await store.rootDir()).existsSync(), isFalse);
    });

    test('is a no-op when the root was never created', () async {
      await expectLater(store.deleteRoot(), completes);
    });
  });

  group('sweepOrphans', () {
    test('deletes directories whose entry id is no longer live (AC-13)',
        () async {
      final source = writeSource('picked.jpg');
      await store.importPhoto('live-1', source.path);
      await store.importPhoto('orphan-1', source.path);
      await store.importPhoto('orphan-2', source.path);

      await store.sweepOrphans(<String>['live-1']);

      final root = await store.rootDir();
      expect(
        root.listSync().map((e) => p.basename(e.path)),
        <String>['live-1'],
      );
    });

    test('empties the root when nothing is live', () async {
      final source = writeSource('picked.jpg');
      await store.importPhoto('e-1', source.path);

      await store.sweepOrphans(const <String>[]);

      expect((await store.rootDir()).listSync(), isEmpty);
    });

    test('keeps every live entry untouched', () async {
      final source = writeSource('picked.jpg');
      final relativePath = await store.importPhoto('e-1', source.path);

      await store.sweepOrphans(<String>['e-1']);

      expect((await store.resolvePhoto(relativePath)).existsSync(), isTrue);
    });

    test('is a no-op when the root was never created', () async {
      await expectLater(store.sweepOrphans(const <String>['e-1']), completes);
    });
  });
}
