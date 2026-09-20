import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/chapter_closure_dao.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/chapter_closure/data/chapter_closure_service.dart';
import 'package:cupid_mobile/features/chapter_closure/domain/chapter_closure_gate.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The AC-6 classification predicate and the single-transaction write
/// (`architecture/contract-summary.md` §3, `solution.md` §1 Key Discovery).
///
/// Everything runs against a real in-memory `CupidDatabase`: the predicate is
/// SQL, and the failure this phase has to rule out — a card the user never
/// showed anyone being swept into the closed drawer — is a silent wrong-row
/// failure, not an exception.
void main() {
  late CupidDatabase database;
  late ChapterClosureService service;
  late ChapterClosureGate gate;

  const owner = 'user-1';
  final stamp = DateTime.utc(2026, 9, 12);

  ChapterClosureService serviceWith(ChapterClosureDao dao) =>
      ChapterClosureService(
        db: database,
        dao: dao,
        ownerKeyStore: BackendUserIdStore()..updateUserId(owner),
        newId: () => 'closure-1',
        now: () => stamp,
      );

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    gate = ChapterClosureGate(database.chapterClosureDao);
    service = serviceWith(database.chapterClosureDao);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertCard(
    String id, {
    String ownerKey = owner,
    String status = 'idea',
    bool invited = false,
    String replyState = 'not_answered',
  }) {
    return database.into(database.activityCards).insert(
          ActivityCardsCompanion.insert(
            id: id,
            ownerKey: ownerKey,
            title: 'Thẻ $id',
            origin: 'manual',
            status: Value(status),
            invited: Value(invited),
            replyState: Value(replyState),
            createdAt: stamp,
            updatedAt: stamp,
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

  Future<void> insertSkill(String id) {
    return database.into(database.skillProfileEntries).insert(
          SkillProfileEntriesCompanion.insert(
            id: id,
            ownerKey: owner,
            label: 'Kỹ năng $id',
            source: 'manual',
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
  }

  Future<void> insertPromptState(String questionId) {
    return database.into(database.askPromptState).insert(
          AskPromptStateCompanion.insert(
            ownerKey: owner,
            questionId: questionId,
            state: 'answered',
            updatedAt: stamp,
          ),
        );
  }

  Future<void> insertJournalEntry(String id) {
    return database.into(database.journalEntries).insert(
          JournalEntriesCompanion.insert(
            id: id,
            ownerUserId: owner,
            bodyText: 'Nhật ký riêng $id',
            createdAt: stamp.millisecondsSinceEpoch,
            updatedAt: stamp.millisecondsSinceEpoch,
          ),
        );
  }

  group('vị từ phân loại gắn người (AC-6, AC-7, AC-10)', () {
    setUp(() async {
      await insertCard('card-invited', invited: true);
      await insertCard('card-answered', replyState: 'answered');
      await insertCard('card-messaged');
      await insertInvite('invite-1', cardId: 'card-messaged');
      await insertCard('card-untouched');
      await insertCard('card-scheduled-alone', status: 'scheduled');
    });

    test('chỉ ba tín hiệu dương tính đóng một thẻ', () async {
      await service.close();

      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.activityCard),
        <String>{'card-invited', 'card-answered', 'card-messaged'},
      );
    });

    test('thẻ chưa từng mời ở lại luồng thường ngày (AC-7)', () async {
      await service.close();

      final closed = await gate.closedIdsOf(ChapterClosureItemKind.activityCard);
      expect(closed, isNot(contains('card-untouched')));
    });

    test('ca không dứt khoát giữ lại, không đóng (AC-10)', () async {
      // Lên lịch một mình không phải tín hiệu gắn người: không ai được mời,
      // không ai trả lời. "Người dùng chưa đụng tới" cũng vậy.
      await service.close();

      final closed = await gate.closedIdsOf(ChapterClosureItemKind.activityCard);
      expect(closed, isNot(contains('card-scheduled-alone')));
      expect(closed.length, 3);
    });

    test('thẻ của chủ khác không bao giờ bị đóng', () async {
      await insertCard('card-other-owner', ownerKey: 'user-2', invited: true);

      await service.close();

      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.activityCard),
        isNot(contains('card-other-owner')),
      );
    });

    test('lời mời không có item_kind riêng', () async {
      await service.close();

      final kinds = await database.select(database.chapterClosureItems).get();
      expect(
        kinds.map((row) => row.itemKind).toSet(),
        <String>{'activity_card'},
      );
      expect(kinds.map((row) => row.itemId), isNot(contains('invite-1')));
    });
  });

  group('sổ tay, hồ sơ kỹ năng và nhật ký riêng', () {
    setUp(() async {
      await insertNotebookEntry('entry-a');
      await insertNotebookEntry('entry-b');
      await insertNotebookEntry('entry-other', ownerKey: 'user-2');
      await insertSkill('skill-a');
      await insertPromptState('ask.birthday.v1');
      await insertPromptState('ask.coffee.v1');
      await insertJournalEntry('journal-a');
    });

    test('mọi mục sổ tay người yêu của chủ hiện tại vào sổ đóng', () async {
      await service.close();

      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.notebookEntry),
        <String>{'entry-a', 'entry-b'},
      );
    });

    test('hồ sơ kỹ năng không bao giờ là thành viên (AC-8)', () async {
      await service.close();

      final allIds = await database.select(database.chapterClosureItems).get();
      expect(allIds.map((row) => row.itemId), isNot(contains('skill-a')));
    });

    test('nhật ký riêng không bao giờ là thành viên (BR-6)', () async {
      await service.close();

      final allIds = await database.select(database.chapterClosureItems).get();
      expect(allIds.map((row) => row.itemId), isNot(contains('journal-a')));
      expect(
        await database.select(database.journalEntries).get(),
        hasLength(1),
      );
    });

    test('ask_prompt lưu question_id làm item_id (§2)', () async {
      await service.close();

      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.askPrompt),
        <String>{'ask.birthday.v1', 'ask.coffee.v1'},
      );
    });
  });

  group('giao dịch đơn (AC-1)', () {
    test('lỗi giữa chừng không để lại closure một nửa', () async {
      await insertCard('card-invited', invited: true);
      await insertNotebookEntry('entry-a');
      final failing = _FailsAfterWritingDao(database);

      await expectLater(
        serviceWith(failing).close(),
        throwsA(isA<StateError>()),
      );

      expect(await gate.hasAnyClosure(), isFalse);
      expect(
        await database.select(database.chapterClosureItems).get(),
        isEmpty,
      );
      expect(failing.wroteBeforeThrowing, isTrue);
    });
  });

  group('đóng lại và mở lại (AC-17)', () {
    setUp(() async {
      await insertCard('card-invited', invited: true);
      await insertNotebookEntry('entry-a');
    });

    test('close trả về id của closure vừa ghi', () async {
      expect(await service.close(), 'closure-1');
    });

    test('đóng lần hai thay thế ảnh chụp cũ, không xếp chồng', () async {
      await service.close();
      await insertCard('card-second', invited: true);

      await service.close();

      expect(
        await database.select(database.chapterClosures).get(),
        hasLength(1),
      );
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.activityCard),
        <String>{'card-invited', 'card-second'},
      );
    });

    test('reopen xoá hàng closure và mọi thành viên theo cascade', () async {
      await service.close();

      await service.reopen();

      expect(await gate.hasAnyClosure(), isFalse);
      expect(
        await database.select(database.chapterClosureItems).get(),
        isEmpty,
      );
    });

    test('reopen khi chưa đóng gì là no-op, không ném lỗi', () async {
      await service.reopen();

      expect(await gate.hasAnyClosure(), isFalse);
    });
  });
}

/// Writes a real closure row and its items, then throws — the only way to prove
/// the outer transaction in `ChapterClosureService.close()` is what rolls a
/// half-written ledger back (AC-1). A DAO that threw before writing would pass
/// the same assertions without the transaction existing at all.
class _FailsAfterWritingDao extends ChapterClosureDao {
  _FailsAfterWritingDao(super.db);

  bool wroteBeforeThrowing = false;

  @override
  Future<void> createClosure({
    required String id,
    required String ownerKey,
    required DateTime closedAt,
    required Map<String, Set<String>> itemIdsByKind,
  }) async {
    await super.createClosure(
      id: id,
      ownerKey: ownerKey,
      closedAt: closedAt,
      itemIdsByKind: itemIdsByKind,
    );
    wroteBeforeThrowing = (await closureCount()) > 0;
    throw StateError('mất điện giữa lúc đóng ngăn');
  }
}
