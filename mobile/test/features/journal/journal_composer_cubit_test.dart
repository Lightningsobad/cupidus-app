import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/journal/data/journal_repository.dart';
import 'package:cupid_mobile/features/journal/domain/journal_entry.dart';
import 'package:cupid_mobile/features/journal/presentation/journal_composer_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

void main() {
  late db.CupidDatabase database;
  late Directory baseDir;
  late Directory callerDir;
  late JournalMediaStore mediaStore;
  late JournalRepository repository;

  setUp(() {
    database = db.CupidDatabase(NativeDatabase.memory());
    baseDir = Directory.systemTemp.createTempSync('journal_composer_media');
    callerDir = Directory.systemTemp.createTempSync('journal_composer_caller');
    mediaStore = JournalMediaStore(baseDirectory: () async => baseDir);
    repository = JournalRepository(
      database: database,
      mediaStore: mediaStore,
      backendUserIdStore: BackendUserIdStore()..updateUserId('user-a'),
    );
  });

  tearDown(() async {
    await database.close();
    for (final Directory dir in <Directory>[baseDir, callerDir]) {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }
  });

  /// A file the *caller* owns, standing in for a picker result or a seed path
  /// handed over by another surface.
  File callerFile(String name) {
    return File(p.join(callerDir.path, name))
      ..writeAsBytesSync(<int>[for (var i = 0; i < 32; i++) i]);
  }

  /// Drains the microtasks the async factories and `save` run on.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  Future<JournalEntry?> reload(String id) => repository.entryById(id);

  Future<List<JournalEntry>> allEntries() => repository.watchEntries().first;

  group('three entry modes', () {
    test('blank opens empty, not editing, and saves as manual', () async {
      final JournalComposerCubit cubit = JournalComposerCubit.blank(
        repository: repository,
        mediaStore: mediaStore,
        newEntryId: () => 'entry-blank',
      );
      addTearDown(cubit.close);

      expect(cubit.state.bodyText, '');
      expect(cubit.state.photoPaths, isEmpty);
      expect(cubit.state.isEditing, isFalse);
      expect(cubit.state.isReady, isTrue);
      expect(cubit.state.canSave, isFalse);

      cubit.bodyChanged('Một buổi tối yên.');
      await cubit.save();

      final JournalEntry? saved = await reload('entry-blank');
      expect(saved, isNotNull);
      expect(saved!.bodyText, 'Một buổi tối yên.');
      expect(saved.origin, JournalEntryOrigin.manual);
      expect(saved.originRef, isNull);
      expect(cubit.state.savedEntryId, 'entry-blank');
    });

    test('editing loads the saved entry and reports the edit title',
        () async {
      final File photo = callerFile('seed.bin');
      await repository.saveEntry(
        id: 'entry-edit',
        bodyText: 'Bản đầu.',
        photoSourcePaths: <String>[photo.path],
      );

      final JournalComposerCubit cubit = JournalComposerCubit.editing(
        repository: repository,
        mediaStore: mediaStore,
        entryId: 'entry-edit',
      );
      addTearDown(cubit.close);

      expect(cubit.state.isEditing, isTrue);
      expect(cubit.state.isReady, isFalse);

      await settle();

      expect(cubit.state.isReady, isTrue);
      expect(cubit.state.bodyText, 'Bản đầu.');
      expect(cubit.state.photoPaths, hasLength(1));
      // The loaded attachment is the journal's own copy, not the caller's file.
      expect(p.isWithin(baseDir.path, cubit.state.photoPaths.single), isTrue);
    });

    test('seeded pre-fills the fields, keeps originRef, and saves as external',
        () async {
      final File photo = callerFile('from-elsewhere.bin');
      final JournalComposerCubit cubit = JournalComposerCubit.seeded(
        repository: repository,
        mediaStore: mediaStore,
        seedText: 'Ảnh này mình muốn giữ.',
        seedPhotoPaths: <String>[photo.path, '/no/such/file.jpg'],
        originRef: 'story-007:thankyou-42',
        newEntryId: () => 'entry-seeded',
      );
      addTearDown(cubit.close);

      // An unreadable seed path is dropped, not raised: the composer still
      // opens (`architecture/contract-summary.md` §3).
      expect(cubit.state.photoPaths, <String>[photo.path]);
      expect(cubit.state.bodyText, 'Ảnh này mình muốn giữ.');

      await cubit.save();

      final JournalEntry? saved = await reload('entry-seeded');
      expect(saved!.origin, JournalEntryOrigin.external);
      expect(saved.originRef, 'story-007:thankyou-42');
    });

    test('seeded content stays editable and erasable before saving', () async {
      final File photo = callerFile('seeded-editable.bin');
      final JournalComposerCubit cubit = JournalComposerCubit.seeded(
        repository: repository,
        mediaStore: mediaStore,
        seedText: 'Câu mồi của story khác',
        seedPhotoPaths: <String>[photo.path],
        newEntryId: () => 'entry-editable-seed',
      );
      addTearDown(cubit.close);

      cubit.bodyChanged('Lời của chính mình');
      cubit.removePhotoAt(0);

      expect(cubit.state.bodyText, 'Lời của chính mình');
      expect(cubit.state.photoPaths, isEmpty);

      await cubit.save();

      final JournalEntry? saved = await reload('entry-editable-seed');
      expect(saved!.bodyText, 'Lời của chính mình');
      expect(saved.photos, isEmpty);
    });
  });

  group('editing overwrites in place (AC-3)', () {
    test('keeps the same id and produces no second row', () async {
      await repository.saveEntry(id: 'entry-1', bodyText: 'Bản đầu.');

      final JournalComposerCubit cubit = JournalComposerCubit.editing(
        repository: repository,
        mediaStore: mediaStore,
        entryId: 'entry-1',
      );
      addTearDown(cubit.close);
      await settle();

      cubit.bodyChanged('Bản đã sửa.');
      await cubit.save();

      final List<JournalEntry> entries = await allEntries();
      expect(entries, hasLength(1));
      expect(entries.single.id, 'entry-1');
      expect(entries.single.bodyText, 'Bản đã sửa.');
      expect(cubit.state.savedEntryId, 'entry-1');
    });

    test('a photo dropped while editing leaves no file behind', () async {
      final File photo = callerFile('dropped.bin');
      await repository.saveEntry(
        id: 'entry-2',
        bodyText: 'Có ảnh.',
        photoSourcePaths: <String>[photo.path],
      );
      final JournalEntry before = (await reload('entry-2'))!;
      final File storedBefore =
          await mediaStore.resolvePhoto(before.photos.single.relativePath);
      expect(storedBefore.existsSync(), isTrue);

      final JournalComposerCubit cubit = JournalComposerCubit.editing(
        repository: repository,
        mediaStore: mediaStore,
        entryId: 'entry-2',
      );
      addTearDown(cubit.close);
      await settle();

      cubit.removePhotoAt(0);
      await cubit.save();

      final JournalEntry after = (await reload('entry-2'))!;
      expect(after.photos, isEmpty);
      // AC-13: the removed photo is gone from disk, not merely unreferenced.
      expect(storedBefore.existsSync(), isFalse);
      expect(
        (await mediaStore.entryDir('entry-2')).listSync(),
        isEmpty,
      );
    });
  });

  group('nothing is written without the save tap (BR-5)', () {
    test('opening seeded and closing creates no entry', () async {
      final File photo = callerFile('abandoned.bin');
      final JournalComposerCubit cubit = JournalComposerCubit.seeded(
        repository: repository,
        mediaStore: mediaStore,
        seedText: 'Không bao giờ được lưu',
        seedPhotoPaths: <String>[photo.path],
        newEntryId: () => 'entry-abandoned',
      );

      cubit.bodyChanged('Vẫn không lưu');
      await cubit.close();

      expect(await allEntries(), isEmpty);
      expect(await reload('entry-abandoned'), isNull);
      expect((await mediaStore.rootDir()).existsSync(), isFalse);
    });

    test('save is refused while the composer is empty', () async {
      final JournalComposerCubit cubit = JournalComposerCubit.blank(
        repository: repository,
        mediaStore: mediaStore,
        newEntryId: () => 'entry-empty',
      );
      addTearDown(cubit.close);

      cubit.bodyChanged('   ');
      await cubit.save();

      expect(await allEntries(), isEmpty);
    });
  });

  group('photos become the journal\'s own copies', () {
    test('picked photos produce one entry row and n photo rows in media root',
        () async {
      final File first = callerFile('a.bin');
      final File second = callerFile('b.bin');
      final JournalComposerCubit cubit = JournalComposerCubit.blank(
        repository: repository,
        mediaStore: mediaStore,
        newEntryId: () => 'entry-multi',
        pickImages: () async =>
            <XFile>[XFile(first.path), XFile(second.path)],
      );
      addTearDown(cubit.close);

      await cubit.attachPhotos();
      expect(cubit.state.photoPaths, hasLength(2));
      cubit.bodyChanged('Hai tấm.');
      await cubit.save();

      final List<JournalEntry> entries = await allEntries();
      expect(entries, hasLength(1));
      expect(entries.single.photos, hasLength(2));
      for (final JournalEntryPhoto photo in entries.single.photos) {
        final File stored = await mediaStore.resolvePhoto(photo.relativePath);
        expect(stored.existsSync(), isTrue);
        expect(p.isWithin(baseDir.path, stored.path), isTrue);
      }
    });

    test('a seed photo is copied, not referenced by the caller\'s path',
        () async {
      final File photo = callerFile('caller-owned.bin');
      final JournalComposerCubit cubit = JournalComposerCubit.seeded(
        repository: repository,
        mediaStore: mediaStore,
        seedPhotoPaths: <String>[photo.path],
        newEntryId: () => 'entry-copy',
      );
      addTearDown(cubit.close);

      await cubit.save();

      final JournalEntry saved = (await reload('entry-copy'))!;
      final File stored =
          await mediaStore.resolvePhoto(saved.photos.single.relativePath);
      expect(stored.path, isNot(photo.path));
      expect(p.isWithin(baseDir.path, stored.path), isTrue);

      // The two lifetimes are independent from here on: the caller deleting
      // its own file leaves the journal entry whole.
      photo.deleteSync();
      expect(stored.existsSync(), isTrue);
      expect((await reload('entry-copy'))!.photos, hasLength(1));
    });
  });
}
