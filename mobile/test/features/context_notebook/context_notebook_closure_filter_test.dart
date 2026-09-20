import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ContextNotebookReader.entries()` hides closed entries; `skills()` never
/// hides anything (`architecture/contract-summary.md` §3, AC-8/AC-9).
///
/// The empty notebook after a closure is the contracted behaviour, not a
/// failure state: AC-12 asks for "sổ tay còn trống", with no error message.
void main() {
  late CupidDatabase database;
  late ContextNotebookRepository repository;

  const owner = 'user-1';

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    repository = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: BackendUserIdStore()..updateUserId(owner),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> closeEntries(Iterable<String> ids, {String id = 'closure-1'}) {
    return database.chapterClosureDao.createClosure(
      id: id,
      ownerKey: owner,
      closedAt: DateTime.utc(2026, 9, 12),
      itemIdsByKind: <String, Set<String>>{'notebook_entry': ids.toSet()},
    );
  }

  group('sổ tay sau khi đóng ngăn (AC-12)', () {
    late String interestId;
    late String eventId;

    setUp(() async {
      interestId = (await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Trà sữa ít đường',
        source: ContextEntrySource.manual,
      ))
          .id;
      eventId = (await repository.addEntry(
        kind: NotebookKind.event,
        value: 'Sinh nhật',
        source: ContextEntrySource.askOnTheSpot,
        eventOn: '2026-11-02',
      ))
          .id;
      await repository.addSkill(
        label: 'Nấu ăn',
        source: ContextEntrySource.manual,
      );
    });

    test('entries() trả list rỗng, không ném lỗi', () async {
      await closeEntries(<String>[interestId, eventId]);

      expect(await repository.entries(), isEmpty);
    });

    test('lọc theo kind cũng rỗng sau khi đóng', () async {
      await closeEntries(<String>[interestId, eventId]);

      expect(await repository.entries(kind: NotebookKind.interest), isEmpty);
      expect(await repository.entries(kind: NotebookKind.event), isEmpty);
    });

    test('hồ sơ kỹ năng không bao giờ bị lọc (AC-8)', () async {
      await closeEntries(<String>[interestId, eventId]);

      final skills = await repository.skills();
      expect(skills, hasLength(1));
      expect(skills.single.label, 'Nấu ăn');
    });

    test('đóng một phần chỉ giấu đúng mục đã đóng', () async {
      await closeEntries(<String>[interestId]);

      final remaining = await repository.entries();
      expect(remaining.map((entry) => entry.id).toList(), <String>[eventId]);
    });

    test('mở lại đưa đúng tập mục đó trở lại (AC-17)', () async {
      await closeEntries(<String>[interestId, eventId]);
      await database.chapterClosureDao.deleteClosure('closure-1');

      expect(
        (await repository.entries()).map((entry) => entry.id).toSet(),
        <String>{interestId, eventId},
      );
    });

    test('id đóng dưới kind khác không giấu mục sổ tay', () async {
      await database.chapterClosureDao.createClosure(
        id: 'closure-2',
        ownerKey: owner,
        closedAt: DateTime.utc(2026, 9, 12),
        itemIdsByKind: <String, Set<String>>{
          'activity_card': <String>{interestId, eventId},
        },
      );

      expect(await repository.entries(), hasLength(2));
    });
  });

  group('trạng thái rỗng', () {
    test('chưa đóng gì thì anti-join không giấu gì', () async {
      await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Đi bộ buổi tối',
        source: ContextEntrySource.manual,
      );

      expect(await repository.entries(), hasLength(1));
    });

    test('mục viết sau khi đóng vẫn hiện ra bình thường', () async {
      final stale = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Mục cũ',
        source: ContextEntrySource.manual,
      );
      await closeEntries(<String>[stale.id]);

      final fresh = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Mục mới sau khi đóng ngăn',
        source: ContextEntrySource.manual,
      );

      expect(
        (await repository.entries()).map((entry) => entry.id).toList(),
        <String>[fresh.id],
      );
    });
  });
}
