import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/chapter_closure/data/stage1_last_opened_store.dart';
import 'package:cupid_mobile/features/chapter_closure/data/stage1_wipe_registry.dart';
import 'package:cupid_mobile/features/chapter_closure/data/stage1_wipe_service.dart';
import 'package:cupid_mobile/features/chapter_closure/domain/chapter_closure_gate.dart';
import 'package:cupid_mobile/features/chapter_closure/domain/return_gate_resolver.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Leaving stage 1 (AC-14) and purging what a closure holds (AC-15).
///
/// Everything runs against a real in-memory `CupidDatabase` and a real
/// temporary directory: both failures this phase has to rule out — a table the
/// wipe forgot, and a purge that took a row the user kept — are silent
/// wrong-row failures rather than exceptions, so they are only visible against
/// real storage.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CupidDatabase database;
  late Directory baseDir;
  late JournalMediaStore mediaStore;
  late Stage1WipeRegistry registry;
  late Stage1WipeService service;
  late ChapterClosureGate gate;
  late BackendUserIdStore ownerKeyStore;

  const String owner = 'user-1';
  const String otherOwner = 'user-2';
  final DateTime stamp = DateTime.utc(2026, 9, 16);

  Stage1WipeService serviceFor(BackendUserIdStore store) => Stage1WipeService(
        db: database,
        dao: database.chapterClosureDao,
        gate: gate,
        ownerKeyStore: store,
        registry: registry,
        preferences: SharedPreferences.getInstance,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = CupidDatabase(NativeDatabase.memory());
    baseDir = await Directory.systemTemp.createTemp('stage1-wipe-');
    mediaStore = JournalMediaStore(
      baseDirectory: () async => baseDir,
      ownerUserId: () => owner,
    );
    registry = Stage1WipeRegistry(db: database, journalMediaStore: mediaStore);
    gate = ChapterClosureGate(database.chapterClosureDao);
    ownerKeyStore = BackendUserIdStore()..updateUserId(owner);
    service = serviceFor(ownerKeyStore);
  });

  tearDown(() async {
    await database.close();
    if (baseDir.existsSync()) {
      await baseDir.delete(recursive: true);
    }
  });

  /// Row counts per registry table for one owner, produced by the registry's
  /// own predicates — the same SQL the wipe runs, so a predicate that selects
  /// the wrong rows shows up here instead of hiding behind a hand-written
  /// count query.
  Future<Map<String, int>> countsFor(String ownerKey) async {
    final Map<String, int> counts = <String, int>{};
    for (final Stage1WipeTable entry in registry.tables) {
      final QueryRow row = await database.customSelect(
        'SELECT COUNT(*) AS c FROM ${entry.tableName} WHERE ${entry.ownerWhere}',
        variables: <Variable<Object>>[Variable<String>(ownerKey)],
      ).getSingle();
      counts[entry.tableName] = row.read<int>('c');
    }
    return counts;
  }

  Future<void> insertCard(
    String id, {
    String ownerKey = owner,
    bool invited = false,
  }) {
    return database.into(database.activityCards).insert(
          ActivityCardsCompanion.insert(
            id: id,
            ownerKey: ownerKey,
            title: 'Thẻ $id',
            origin: 'manual',
            invited: Value(invited),
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
  }

  Future<void> insertCardPhoto(String id, {required String cardId}) {
    return database.into(database.activityCardPhotos).insert(
          ActivityCardPhotosCompanion.insert(
            id: id,
            cardId: cardId,
            localPath: '/ngoai/thu-vien/$id.jpg',
          ),
        );
  }

  Future<void> insertInvite(String id, {required String cardId}) {
    return database.into(database.inviteMessages).insert(
          InviteMessagesCompanion.insert(
            id: id,
            cardId: cardId,
            categoryId: 'invite',
            presetId: 'invite.coffee.v1',
            packVersion: '1',
            filledValues: '{}',
            createdAt: stamp.millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> insertNotebookEntry(String id, {String ownerKey = owner}) {
    return database.into(database.notebookEntries).insert(
          NotebookEntriesCompanion.insert(
            id: id,
            ownerKey: ownerKey,
            kind: 'interest',
            value: 'Mục $id',
            source: 'manual',
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
  }

  Future<void> insertSkill(String id, {String ownerKey = owner}) {
    return database.into(database.skillProfileEntries).insert(
          SkillProfileEntriesCompanion.insert(
            id: id,
            ownerKey: ownerKey,
            label: 'Kỹ năng $id',
            source: 'manual',
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
  }

  Future<void> insertPromptState(String questionId, {String ownerKey = owner}) {
    return database.into(database.askPromptState).insert(
          AskPromptStateCompanion.insert(
            ownerKey: ownerKey,
            questionId: questionId,
            state: 'answered',
            updatedAt: stamp,
          ),
        );
  }

  Future<void> insertJournalEntry(String id, {String ownerKey = owner}) {
    return database.into(database.journalEntries).insert(
          JournalEntriesCompanion.insert(
            id: id,
            ownerUserId: ownerKey,
            bodyText: 'Nhật ký riêng $id',
            createdAt: stamp.millisecondsSinceEpoch,
            updatedAt: stamp.millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> insertJournalPhoto(String id, {required String entryId}) {
    return database.into(database.journalPhotos).insert(
          JournalPhotosCompanion.insert(
            id: id,
            entryId: entryId,
            relativePath: '$entryId/$id.jpg',
            sortIndex: 0,
            createdAt: stamp.millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> insertMessage(String id) {
    return database.into(database.messages).insert(
          MessagesCompanion.insert(
            id: id,
            senderId: owner,
            receiverId: otherOwner,
            content: 'tin nhắn $id',
            type: 'text',
            status: 'sent',
            createdAt: stamp,
            cachedAt: stamp,
          ),
        );
  }

  Future<void> closeChapter({
    String ownerKey = owner,
    String closureId = 'closure-1',
    Set<String> cardIds = const <String>{},
    Set<String> notebookIds = const <String>{},
    Set<String> questionIds = const <String>{},
  }) {
    return database.chapterClosureDao.createClosure(
      id: closureId,
      ownerKey: ownerKey,
      closedAt: stamp,
      itemIdsByKind: <String, Set<String>>{
        ChapterClosureItemKind.activityCard.wireValue: cardIds,
        ChapterClosureItemKind.notebookEntry.wireValue: notebookIds,
        ChapterClosureItemKind.askPrompt.wireValue: questionIds,
      },
    );
  }

  Future<File> seedMediaFile(String ownerKey) async {
    final Directory root = Directory(
      '${baseDir.path}/${JournalMediaStore.mediaRootName}/'
      '${JournalMediaStore.ownerSegment(ownerKey)}',
    );
    await root.create(recursive: true);
    final File photo = File('${root.path}/entry-1/photo.jpg');
    await photo.create(recursive: true);
    await photo.writeAsString('ảnh giả');
    return photo;
  }

  /// Seeds every registry table for [ownerKey] so a wipe that misses one table
  /// cannot pass by accident.
  Future<void> seedEverything(String ownerKey) async {
    final String suffix = ownerKey;
    await insertCard('card-$suffix', ownerKey: ownerKey, invited: true);
    await insertCardPhoto('cardphoto-$suffix', cardId: 'card-$suffix');
    await insertInvite('invite-$suffix', cardId: 'card-$suffix');
    await insertJournalEntry('journal-$suffix', ownerKey: ownerKey);
    await insertJournalPhoto(
      'journalphoto-$suffix',
      entryId: 'journal-$suffix',
    );
    await insertNotebookEntry('note-$suffix', ownerKey: ownerKey);
    await insertSkill('skill-$suffix', ownerKey: ownerKey);
    await insertPromptState('question-$suffix', ownerKey: ownerKey);
    await closeChapter(
      ownerKey: ownerKey,
      closureId: 'closure-$suffix',
      cardIds: <String>{'card-$suffix'},
      notebookIds: <String>{'note-$suffix'},
      questionIds: <String>{'question-$suffix'},
    );
    await seedMediaFile(ownerKey);
  }

  group('wipeAll xoá hết phần stage 1 của chủ sở hữu (AC-14)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'before_you_go.dismissed_on.card-user-1': '2026-09-16',
        'before_you_go.dismissed_on.card-cu': '2026-01-01',
        Stage1LastOpenedStore.preferenceKey: 1757980800000,
        'theme.selected': 'aurora',
        'auth.signed_in_before': true,
      });
      await seedEverything(owner);
      await seedEverything(otherOwner);
      await insertMessage('message-1');
    });

    test('mọi bảng trong registry về 0 hàng cho chủ sở hữu', () async {
      final Map<String, int> before = await countsFor(owner);
      expect(
        before.values.every((int count) => count > 0),
        isTrue,
        reason: 'mọi bảng phải có dữ liệu trước khi xoá: $before',
      );

      await service.wipeAll();

      final Map<String, int> after = await countsFor(owner);
      // ignore: avoid_print
      print('BẰNG CHỨNG số hàng theo bảng — trước: $before, sau: $after');
      expect(
        after,
        before.map((String table, _) => MapEntry<String, int>(table, 0)),
      );
      expect(after.keys.length, 10);
    });

    test('dữ liệu của người dùng khác trên cùng máy không suy suyển', () async {
      final Map<String, int> before = await countsFor(otherOwner);

      await service.wipeAll();

      expect(await countsFor(otherOwner), before);
    });

    test('gốc media biến mất khỏi đĩa, gốc của người khác thì không', () async {
      final Directory root = await mediaStore.rootDir();
      final Directory otherRoot = Directory(
        '${baseDir.path}/${JournalMediaStore.mediaRootName}/'
        '${JournalMediaStore.ownerSegment(otherOwner)}',
      );
      expect(root.existsSync(), isTrue);
      expect(otherRoot.existsSync(), isTrue);

      await service.wipeAll();

      // ignore: avoid_print
      print(
        'BẰNG CHỨNG existsSync gốc media — của mình: ${root.existsSync()}, '
        'của người khác: ${otherRoot.existsSync()}',
      );
      expect(root.existsSync(), isFalse);
      expect(otherRoot.existsSync(), isTrue);
    });

    test('không còn tệp ảnh mồ côi dưới gốc media đã xoá', () async {
      final Directory root = await mediaStore.rootDir();

      await service.wipeAll();

      expect(root.existsSync(), isFalse);
      expect(
        Directory('${baseDir.path}/${JournalMediaStore.mediaRootName}')
            .listSync()
            .map((FileSystemEntity e) => e.path.split('/').last),
        <String>[JournalMediaStore.ownerSegment(otherOwner)],
      );
    });

    test('khoá tuỳ chọn của REQ-016 bị xoá, khoá tính năng khác ở lại (AC-27)',
        () async {
      final SharedPreferences before = await SharedPreferences.getInstance();
      expect(before.getInt(Stage1LastOpenedStore.preferenceKey), isNotNull);

      await service.wipeAll();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getKeys().where((String k) => k.startsWith('before_you_go.')),
        isEmpty,
      );
      // ignore: avoid_print
      print(
        'BẰNG CHỨNG khoá prefs sau wipeAll — còn lại: ${prefs.getKeys()}',
      );
      expect(
        prefs.getKeys(),
        isNot(contains(Stage1LastOpenedStore.preferenceKey)),
      );
      expect(
        await Stage1LastOpenedStore().absentAtLeast(
          kReturnAbsenceThreshold,
          now: DateTime(2030),
        ),
        isFalse,
        reason: 'không còn mốc nào, nên lần quay lại kế tiếp là cài mới',
      );
      expect(prefs.getString('theme.selected'), 'aurora');
      expect(prefs.getBool('auth.signed_in_before'), isTrue);
    });

    test('sổ đóng ngăn của tài khoản khác vẫn còn nguyên', () async {
      await service.wipeAll();

      // `ChapterClosureGate` cố ý không có vị từ chủ sở hữu (xem
      // `chapter_closure_dao.dart`), nên trên máy dùng chung, sổ của tài khoản
      // kia vẫn đọc được sau khi mình rời đi — đúng như thiết kế ledger của P2.
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.activityCard),
        <String>{'card-$otherOwner'},
      );
      expect(await gate.hasAnyClosure(), isTrue);
    });

    test('phiên đăng nhập sống sót: vẫn ghi được ngay sau khi xoá (AC-29)',
        () async {
      await service.wipeAll();

      // Bộ nhớ đệm do đăng xuất sở hữu vẫn còn: wipeAll không đi qua
      // `clearOnSignOut()`, nó chỉ đụng đúng các bảng trong registry.
      expect(await database.select(database.messages).get(), hasLength(1));
      expect(await ownerKeyStore.resolve(), owner);

      await insertCard('card-sau-khi-xoa');
      expect(
        await (database.select(database.activityCards)
              ..where((row) => row.ownerKey.equals(owner)))
            .get(),
        hasLength(1),
      );
    });

    test('không có chủ sở hữu thì dừng lại thay vì xoá nhầm', () async {
      final Stage1WipeService orphan = serviceFor(BackendUserIdStore());

      await expectLater(orphan.wipeAll(), throwsStateError);
      expect((await countsFor(owner)).values.every((int c) => c > 0), isTrue);
    });
  });

  group('tài khoản duy nhất trên máy rời giai đoạn 1 (AC-14)', () {
    setUp(() async {
      await seedEverything(owner);
    });

    test('hasAnyClosure về false và mọi đọc đều rỗng, không ném lỗi', () async {
      expect(await gate.hasAnyClosure(), isTrue);

      await service.wipeAll();

      expect(await gate.hasAnyClosure(), isFalse);
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.activityCard),
        isEmpty,
      );
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.notebookEntry),
        isEmpty,
      );
      expect(await gate.closedIdsOf(ChapterClosureItemKind.askPrompt), isEmpty);
      expect(await database.select(database.activityCards).get(), isEmpty);
      expect(await database.select(database.notebookEntries).get(), isEmpty);
      expect(await database.select(database.journalEntries).get(), isEmpty);
      expect(await database.select(database.askPromptState).get(), isEmpty);
    });

    test('xoá hai lần liên tiếp vẫn im lặng và vẫn rỗng', () async {
      await service.wipeAll();
      await service.wipeAll();

      expect((await countsFor(owner)).values.every((int c) => c == 0), isTrue);
      expect((await mediaStore.rootDir()).existsSync(), isFalse);
    });
  });

  group('purgeClosed chỉ xoá đúng phần đã đóng (AC-15)', () {
    setUp(() async {
      await insertCard('card-da-dong', invited: true);
      await insertCardPhoto('anh-da-dong', cardId: 'card-da-dong');
      await insertInvite('moi-da-dong', cardId: 'card-da-dong');
      await insertCard('card-giu-lai');
      await insertCardPhoto('anh-giu-lai', cardId: 'card-giu-lai');
      await insertInvite('moi-giu-lai', cardId: 'card-giu-lai');
      await insertNotebookEntry('note-da-dong');
      await insertNotebookEntry('note-giu-lai');
      await insertPromptState('question-da-dong');
      await insertPromptState('question-giu-lai');
      await insertSkill('skill-1');
      await insertJournalEntry('journal-1');
      await insertJournalPhoto('journalphoto-1', entryId: 'journal-1');
      await closeChapter(
        cardIds: <String>{'card-da-dong'},
        notebookIds: <String>{'note-da-dong'},
        questionIds: <String>{'question-da-dong'},
      );
    });

    Future<List<String>> idsOf<T extends Table, R>(
      TableInfo<T, R> table,
      String Function(R row) id,
    ) async {
      final List<R> rows = await database.select(table).get();
      final List<String> ids = rows.map(id).toList()..sort();
      return ids;
    }

    test('thẻ đã đóng biến mất, thẻ giữ lại còn nguyên từng id một', () async {
      await service.purgeClosed();

      expect(
        await idsOf(database.activityCards, (ActivityCardRow r) => r.id),
        <String>['card-giu-lai'],
      );
      expect(
        await idsOf(
          database.activityCardPhotos,
          (ActivityCardPhotoRow r) => r.id,
        ),
        <String>['anh-giu-lai'],
      );
      expect(
        await idsOf(database.inviteMessages, (InviteMessageRow r) => r.id),
        <String>['moi-giu-lai'],
      );
    });

    test('mục sổ tay và câu hỏi đã đóng biến mất, phần giữ lại còn nguyên',
        () async {
      await service.purgeClosed();

      expect(
        await idsOf(database.notebookEntries, (NotebookEntryRow r) => r.id),
        <String>['note-giu-lai'],
      );
      expect(
        await idsOf(
          database.askPromptState,
          (AskPromptStateRow r) => r.questionId,
        ),
        <String>['question-giu-lai'],
      );
    });

    test('hồ sơ kỹ năng và nhật ký riêng không bao giờ bị purge chạm vào',
        () async {
      await service.purgeClosed();

      expect(
        await idsOf(
          database.skillProfileEntries,
          (SkillProfileEntryRow r) => r.id,
        ),
        <String>['skill-1'],
      );
      expect(
        await idsOf(database.journalEntries, (JournalEntry r) => r.id),
        <String>['journal-1'],
      );
      expect(
        await idsOf(database.journalPhotos, (JournalPhoto r) => r.id),
        <String>['journalphoto-1'],
      );
    });

    test('sổ đóng ngăn biến mất cùng các thành viên của nó', () async {
      await service.purgeClosed();

      expect(await gate.hasAnyClosure(), isFalse);
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.activityCard),
        isEmpty,
      );
    });

    test('purge khi chưa từng đóng ngăn không xoá gì cả', () async {
      await database.chapterClosureDao.deleteClosuresForOwner(owner);

      await service.purgeClosed();

      expect(
        await idsOf(database.activityCards, (ActivityCardRow r) => r.id),
        <String>['card-da-dong', 'card-giu-lai'],
      );
      expect(
        await idsOf(database.notebookEntries, (NotebookEntryRow r) => r.id),
        <String>['note-da-dong', 'note-giu-lai'],
      );
    });

    test('purge không với sang dữ liệu của người dùng khác', () async {
      await insertCard('card-nguoi-khac', ownerKey: otherOwner);
      await insertNotebookEntry('note-nguoi-khac', ownerKey: otherOwner);

      await service.purgeClosed();

      expect(
        await idsOf(database.activityCards, (ActivityCardRow r) => r.id),
        <String>['card-giu-lai', 'card-nguoi-khac'],
      );
      expect(
        await idsOf(database.notebookEntries, (NotebookEntryRow r) => r.id),
        <String>['note-giu-lai', 'note-nguoi-khac'],
      );
    });
  });
}
