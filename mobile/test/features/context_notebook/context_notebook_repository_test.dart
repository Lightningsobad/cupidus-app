import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CupidDatabase database;
  late BackendUserIdStore ownerKeyStore;
  late ContextNotebookRepository repository;

  ContextNotebookRepository repositoryFor(BackendUserIdStore store) =>
      ContextNotebookRepository(
        dao: ContextNotebookDao(database),
        ownerKeyStore: store,
      );

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    ownerKeyStore = BackendUserIdStore()..updateUserId('user-1');
    repository = repositoryFor(ownerKeyStore);
  });

  tearDown(() async {
    await database.close();
  });

  group('trạng thái rỗng và ghi cơ bản (AC-8)', () {
    test('a fresh owner reads an empty notebook and an empty skill profile',
        () async {
      expect(await repository.entries(), isEmpty);
      expect(await repository.skills(), isEmpty);
      expect(await repository.promptStates(), isEmpty);
    });

    test('two adds produce two different client-generated ids (R-15a)',
        () async {
      final first = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Trà sữa ít đường',
        source: ContextEntrySource.manual,
      );
      final second = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Đi bộ buổi tối',
        source: ContextEntrySource.manual,
      );

      expect(first.id, isNotEmpty);
      expect(first.id, isNot(second.id));
      expect(first.ownerKey, 'user-1');
    });
  });

  group('ghi từ hỏi-tại-chỗ đọc lại được kèm question_id (AC-4)', () {
    test('an answered question round-trips with its stable question id',
        () async {
      await repository.addEntry(
        kind: NotebookKind.event,
        value: 'Sinh nhật',
        source: ContextEntrySource.askOnTheSpot,
        eventOn: '2026-11-02',
        questionId: 'ask.birthday.v1',
      );

      final stored = (await repository.entries()).single;

      expect(stored.value, 'Sinh nhật');
      expect(stored.kind, NotebookKind.event);
      expect(stored.eventOn, '2026-11-02');
      expect(stored.source, ContextEntrySource.askOnTheSpot);
      expect(stored.questionId, 'ask.birthday.v1');
    });

    test('a manually typed entry carries no question id', () async {
      await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Mèo',
        source: ContextEntrySource.manual,
      );

      expect((await repository.entries()).single.questionId, isNull);
    });

    test('answered and skipped are both recorded, and re-recording replaces '
        'the previous state instead of stacking rows (AC-2/BR-3)', () async {
      await repository.recordPromptState(
        questionId: 'ask.birthday.v1',
        state: AskPromptStatus.skipped,
      );
      await repository.recordPromptState(
        questionId: 'ask.food.v1',
        state: AskPromptStatus.answered,
      );
      await repository.recordPromptState(
        questionId: 'ask.birthday.v1',
        state: AskPromptStatus.answered,
      );

      expect(await repository.promptStates(), <String, AskPromptStatus>{
        'ask.birthday.v1': AskPromptStatus.answered,
        'ask.food.v1': AskPromptStatus.answered,
      });
      expect(
        await repository.promptState('ask.food.v1'),
        AskPromptStatus.answered,
      );
      expect(await repository.promptState('ask.never-asked.v1'), isNull);
    });
  });

  group('sửa và xoá có hiệu lực ngay (AC-9)', () {
    test('editing an entry rewrites value/detail and bumps updated_at only',
        () async {
      final created = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Cà phê',
        source: ContextEntrySource.manual,
        detail: 'không đường',
      );

      final edited = await repository.updateEntry(
        id: created.id,
        value: 'Cà phê sữa',
        detail: 'ít đá',
      );
      final reread = await repository.entryById(created.id);

      expect(edited!.value, 'Cà phê sữa');
      expect(edited.detail, 'ít đá');
      expect(reread!.value, 'Cà phê sữa');
      expect(reread.createdAt, created.createdAt);
      expect(reread.updatedAt.isBefore(created.updatedAt), isFalse);
    });

    test('clearing detail on edit writes a real NULL, not "leave it alone"',
        () async {
      final created = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Cà phê',
        source: ContextEntrySource.manual,
        detail: 'không đường',
      );

      final edited = await repository.updateEntry(
        id: created.id,
        value: 'Cà phê',
      );

      expect(edited!.detail, isNull);
    });

    test('deleting removes the row immediately', () async {
      final created = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Mèo',
        source: ContextEntrySource.manual,
      );

      final deleted = await repository.deleteEntry(created.id);

      expect(deleted, 1);
      expect(await repository.entries(), isEmpty);
      expect(await repository.entryById(created.id), isNull);
    });

    test('editing and deleting a skill take effect immediately', () async {
      final created = await repository.addSkill(
        label: 'nhớ dai',
        source: ContextEntrySource.manual,
        seedId: 'skill.nho_dai.v1',
      );

      final edited = await repository.updateSkill(
        id: created.id,
        label: 'nhớ rất dai',
      );
      final afterEdit = await repository.skills();
      final deleted = await repository.deleteSkill(created.id);

      expect(edited!.label, 'nhớ rất dai');
      expect(edited.seedId, 'skill.nho_dai.v1');
      expect(afterEdit.single.label, 'nhớ rất dai');
      expect(deleted, 1);
      expect(await repository.skills(), isEmpty);
    });
  });

  group('chuẩn hoá nằm ở repository, không ở UI', () {
    test('value and label are trimmed, and a blank one is rejected', () async {
      final entry = await repository.addEntry(
        kind: NotebookKind.interest,
        value: '  Trà sữa  ',
        source: ContextEntrySource.manual,
      );
      final skill = await repository.addSkill(
        label: '  gói quà đẹp ',
        source: ContextEntrySource.manual,
      );

      expect(entry.value, 'Trà sữa');
      expect(skill.label, 'gói quà đẹp');
      expect(
        () => repository.addEntry(
          kind: NotebookKind.interest,
          value: '   ',
          source: ContextEntrySource.manual,
        ),
        throwsArgumentError,
      );
      expect(
        () => repository.addSkill(
          label: '',
          source: ContextEntrySource.manual,
        ),
        throwsArgumentError,
      );
    });

    test('a whitespace-only detail becomes NULL rather than an empty string',
        () async {
      final entry = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Mèo',
        source: ContextEntrySource.manual,
        detail: '   ',
      );

      expect(entry.detail, isNull);
    });

    test('event_on is dropped on an interest entry, kept on an event entry',
        () async {
      final interest = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Mèo',
        source: ContextEntrySource.manual,
        eventOn: '2026-11-02',
      );
      final event = await repository.addEntry(
        kind: NotebookKind.event,
        value: 'Kỷ niệm',
        source: ContextEntrySource.manual,
        eventOn: '2026-11-02',
      );

      expect(interest.eventOn, isNull);
      expect(event.eventOn, '2026-11-02');
    });

    test('a seed-less skill stores NULL seed_id, meaning "user typed it"',
        () async {
      final typed = await repository.addSkill(
        label: 'pha cà phê',
        source: ContextEntrySource.manual,
      );

      expect(typed.seedId, isNull);
    });
  });

  group('lọc theo owner_key (AC-22 tinh thần: cô lập trên cùng thiết bị)', () {
    test('kind filtering returns only the requested kind', () async {
      await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Mèo',
        source: ContextEntrySource.manual,
      );
      await repository.addEntry(
        kind: NotebookKind.event,
        value: 'Sinh nhật',
        source: ContextEntrySource.manual,
        eventOn: '2026-11-02',
      );

      final interests = await repository.entries(kind: NotebookKind.interest);
      final events = await repository.entries(kind: NotebookKind.event);

      expect(interests.map((e) => e.value), <String>['Mèo']);
      expect(events.map((e) => e.value), <String>['Sinh nhật']);
      expect(await repository.entries(), hasLength(2));
    });

    test('a second user on the same device sees none of the first user rows',
        () async {
      await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Mèo',
        source: ContextEntrySource.manual,
      );
      await repository.addSkill(
        label: 'nhớ dai',
        source: ContextEntrySource.manual,
      );
      await repository.recordPromptState(
        questionId: 'ask.birthday.v1',
        state: AskPromptStatus.answered,
      );

      final second =
          repositoryFor(BackendUserIdStore()..updateUserId('user-2'));

      expect(await second.entries(), isEmpty);
      expect(await second.skills(), isEmpty);
      expect(await second.promptStates(), isEmpty);
      // The first user's rows are untouched, not wiped by the second session.
      expect(await repository.entries(), hasLength(1));
    });

    test('another owner cannot edit or delete rows that are not theirs',
        () async {
      final mine = await repository.addEntry(
        kind: NotebookKind.interest,
        value: 'Mèo',
        source: ContextEntrySource.manual,
      );
      final second =
          repositoryFor(BackendUserIdStore()..updateUserId('user-2'));

      expect(
        await second.updateEntry(id: mine.id, value: 'Chó'),
        isNull,
      );
      expect(await second.deleteEntry(mine.id), 0);
      expect((await repository.entries()).single.value, 'Mèo');
    });

    test('the repository refuses to work before a backend user id resolves',
        () async {
      final anonymous = repositoryFor(BackendUserIdStore());

      expect(anonymous.entries(), throwsStateError);
      expect(anonymous.skills(), throwsStateError);
    });
  });
}
