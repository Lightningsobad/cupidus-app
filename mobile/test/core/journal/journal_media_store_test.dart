import 'dart:io';

import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory baseDir;
  late JournalMediaStore store;

  setUp(() {
    baseDir = Directory.systemTemp.createTempSync('journal_media_store_test');
    store = JournalMediaStore(baseDirectory: () async => baseDir);
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

    expect(p.dirname(root.path), baseDir.path);
    expect(p.basename(root.path), JournalMediaStore.mediaRootName);
  });

  test('entryDir is a direct child of the media root named after the entry',
      () async {
    final root = await store.rootDir();
    final dir = await store.entryDir('e-1');

    expect(p.dirname(dir.path), root.path);
    expect(p.basename(dir.path), 'e-1');
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
