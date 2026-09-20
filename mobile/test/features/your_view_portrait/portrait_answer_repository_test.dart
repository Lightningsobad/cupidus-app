import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/your_view_portrait/data/portrait_answer_dao.dart';
import 'package:cupid_mobile/features/your_view_portrait/data/portrait_answer_repository.dart';
import 'package:cupid_mobile/features/your_view_portrait/domain/portrait_content.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase P2: answers survive a session, and the ones that belong in the
/// notebook flow there through exactly one narrow door
/// (`STORY-009/architecture/contract-summary.md` §3, §5).
void main() {
  BackendUserIdStore storeFor(String userId) =>
      BackendUserIdStore()..updateUserId(userId);

  group('portrait_answers schema (§5)', () {
    Future<Set<String>> columnNames(CupidDatabase database, String table) async {
      final rows =
          await database.customSelect("PRAGMA table_info('$table')").get();
      return rows.map((row) => row.read<String>('name')).toSet();
    }

    late CupidDatabase database;

    setUp(() {
      database = CupidDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('opens at the current schema version with the table present',
        () async {
      expect(database.schemaVersion, 7);
      await database.select(database.portraitAnswers).get();
    });

    test('carries exactly the contracted columns and no measuring column '
        '(R-1b / AC-12 / AC-28)', () async {
      final columns = await columnNames(database, 'portrait_answers');

      expect(columns, <String>{
        'owner_key',
        'question_id',
        'state',
        'option_id',
        'answer_value',
        'notebook_entry_id',
        'updated_at',
      });
    });

    test('is keyed by (owner_key, question_id) so re-answering replaces '
        'rather than accumulates', () async {
      final rows = await database
          .customSelect("PRAGMA table_info('portrait_answers')")
          .get();
      final primaryKey = rows
          .where((row) => row.read<int>('pk') > 0)
          .map((row) => row.read<String>('name'))
          .toSet();

      expect(primaryKey, <String>{'owner_key', 'question_id'});
    });

    test('no data-layer source names a progress, count, or score concept',
        () async {
      const paths = <String>[
        'lib/core/database/tables/portrait_answers_table.dart',
        'lib/features/your_view_portrait/data/portrait_answer_dao.dart',
        'lib/features/your_view_portrait/data/portrait_answer_repository.dart',
      ];
      const forbidden = <String>[
        'answeredcount',
        'completedat',
        'streak',
        'percent',
        'progress',
        'score',
        'badge',
        'proficiency',
      ];

      for (final path in paths) {
        final code = await File(path)
            .readAsLines()
            .then((lines) => lines
                .where((line) => !line.trimLeft().startsWith('//'))
                .join('\n')
                .toLowerCase());

        for (final term in forbidden) {
          expect(
            code.contains(term),
            isFalse,
            reason: '$path names "$term" outside a comment',
          );
        }
      }
    });
  });

  group('v6 -> v7 migration', () {
    Future<int> readUserVersion(CupidDatabase database) async {
      final row = await database.customSelect('PRAGMA user_version').getSingle();
      return row.read<int>('user_version');
    }

    /// Opens the current schema on a file, seeds rows in the client-owned
    /// tables that existed at v6, then removes exactly the v7 addition and
    /// rewinds `user_version` — so the fixture tracks the real table
    /// definitions instead of being retyped by hand.
    Future<void> seedV6(File file) async {
      final seeded = CupidDatabase(NativeDatabase(file));
      await seeded.activityCardDao.upsertCard(
        ActivityCardsCompanion.insert(
          id: 'card-old',
          ownerKey: 'user-1',
          title: 'Đi ăn lẩu',
          origin: 'manual',
          note: const Value('thẻ viết từ hồi v6'),
          createdAt: DateTime.utc(2026, 9, 1),
          updatedAt: DateTime.utc(2026, 9, 1),
        ),
      );
      await seeded.into(seeded.notebookEntries).insert(
            NotebookEntriesCompanion.insert(
              id: 'entry-old',
              ownerKey: 'user-1',
              kind: 'interest',
              value: 'Trà sữa ít đường',
              source: 'manual',
              createdAt: DateTime.utc(2026, 9, 1),
              updatedAt: DateTime.utc(2026, 9, 1),
            ),
          );
      await seeded.customStatement('DROP TABLE portrait_answers');
      await seeded.customStatement('PRAGMA user_version = 6');
      await seeded.close();
    }

    late Directory tempDir;
    late File databaseFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cupid_db_migration_v7');
      databaseFile =
          File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');
      await seedV6(databaseFile);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('lands on v7 with portrait_answers created', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final tables = await upgraded
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();

      expect(await readUserVersion(upgraded), 7);
      expect(
        tables.map((row) => row.read<String>('name')).toSet(),
        contains('portrait_answers'),
      );
    });

    test('every pre-existing client-owned row survives the upgrade intact',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final cards = await upgraded.select(upgraded.activityCards).get();
      final entries = await upgraded.select(upgraded.notebookEntries).get();

      expect(cards, hasLength(1));
      expect(cards.single.note, 'thẻ viết từ hồi v6');
      expect(entries, hasLength(1));
      expect(entries.single.value, 'Trà sữa ít đường');
    });

    test('the new table is writable right after the upgrade', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      await upgraded.into(upgraded.portraitAnswers).insert(
            PortraitAnswersCompanion.insert(
              ownerKey: 'user-1',
              questionId: 'portrait.q.guess.comfort.v1',
              state: 'answered',
              answerValue: const Value('Ở nhà, đèn vàng'),
              updatedAt: DateTime.utc(2026, 9, 12),
            ),
          );

      final stored = await upgraded.select(upgraded.portraitAnswers).get();

      expect(stored.single.answerValue, 'Ở nhà, đèn vàng');
    });
  });

  group('PortraitAnswerRepository', () {
    late CupidDatabase database;
    late PortraitAnswerRepository repository;

    setUp(() {
      database = CupidDatabase(NativeDatabase.memory());
      repository = PortraitAnswerRepository(
        dao: PortraitAnswerDao(database),
        ownerKeyStore: storeFor('user-1'),
        now: () => DateTime.utc(2026, 9, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('a guess answer keeps its value here and writes nothing to the '
        'notebook (AC-23)', () async {
      await repository.upsertAnswer(
        questionId: 'portrait.q.guess.comfort.v1',
        target: PortraitAnswerTarget.portraitGuess,
        optionId: 'chip.home',
        answerValue: 'Ở nhà, đèn vàng',
      );

      final stored = await repository.answerFor('portrait.q.guess.comfort.v1');
      final notebookRows = await database.select(database.notebookEntries).get();

      expect(stored!.state, PortraitAnswerState.answered);
      expect(stored.answerValue, 'Ở nhà, đèn vàng');
      expect(stored.optionId, 'chip.home');
      expect(stored.notebookEntryId, isNull);
      expect(notebookRows, isEmpty);
    });

    test('a notebook answer stores the entry id and never a second copy of '
        'the value (AC-22)', () async {
      await repository.upsertAnswer(
        questionId: 'portrait.q.interest.food.v1',
        target: PortraitAnswerTarget.notebookInterest,
        notebookEntryId: 'entry-1',
      );

      final stored = await repository.answerFor('portrait.q.interest.food.v1');

      expect(stored!.notebookEntryId, 'entry-1');
      expect(stored.answerValue, isNull);
    });

    test('a notebook answer carrying its own value copy is rejected', () {
      expect(
        () => repository.upsertAnswer(
          questionId: 'portrait.q.interest.food.v1',
          target: PortraitAnswerTarget.notebookInterest,
          answerValue: 'Lẩu nóng',
          notebookEntryId: 'entry-1',
        ),
        throwsArgumentError,
      );
    });

    test('a notebook answer without the entry it wrote is rejected', () {
      expect(
        () => repository.upsertAnswer(
          questionId: 'portrait.q.event.own_day.v1',
          target: PortraitAnswerTarget.notebookEvent,
          notebookEntryId: '  ',
        ),
        throwsArgumentError,
      );
    });

    test('a guess answer pointing at a notebook entry is rejected (AC-23)', () {
      expect(
        () => repository.upsertAnswer(
          questionId: 'portrait.q.guess.crowd.v1',
          target: PortraitAnswerTarget.portraitGuess,
          answerValue: 'Nhóm nhỏ',
          notebookEntryId: 'entry-1',
        ),
        throwsArgumentError,
      );
    });

    test('answering the same question twice leaves one row with the second '
        "write's value", () async {
      await repository.upsertAnswer(
        questionId: 'portrait.q.guess.comfort.v1',
        target: PortraitAnswerTarget.portraitGuess,
        answerValue: 'Ở nhà, đèn vàng',
      );
      await repository.upsertAnswer(
        questionId: 'portrait.q.guess.comfort.v1',
        target: PortraitAnswerTarget.portraitGuess,
        answerValue: 'Quán quen, góc trong',
      );

      final rows = await database.select(database.portraitAnswers).get();

      expect(rows, hasLength(1));
      expect(rows.single.answerValue, 'Quán quen, góc trong');
    });

    test('skipping clears whatever a previous answer left (AC-27)', () async {
      await repository.upsertAnswer(
        questionId: 'portrait.q.guess.comfort.v1',
        target: PortraitAnswerTarget.portraitGuess,
        optionId: 'chip.home',
        answerValue: 'Ở nhà, đèn vàng',
      );

      final skipped =
          await repository.markSkipped(questionId: 'portrait.q.guess.comfort.v1');

      expect(skipped.state, PortraitAnswerState.skipped);
      expect(skipped.answerValue, isNull);
      expect(skipped.optionId, isNull);
      expect(skipped.notebookEntryId, isNull);
    });

    test('a second user on the same device sees none of the first answers',
        () async {
      await repository.upsertAnswer(
        questionId: 'portrait.q.guess.comfort.v1',
        target: PortraitAnswerTarget.portraitGuess,
        answerValue: 'Ở nhà, đèn vàng',
      );

      final otherUser = PortraitAnswerRepository(
        dao: PortraitAnswerDao(database),
        ownerKeyStore: storeFor('user-2'),
      );

      expect(await otherUser.answers(), isEmpty);
      expect((await repository.answers()).keys, hasLength(1));
    });

    test('refuses to read or write before a backend user id resolved', () {
      final unresolved = PortraitAnswerRepository(
        dao: PortraitAnswerDao(database),
        ownerKeyStore: BackendUserIdStore(),
      );

      expect(unresolved.answers(), throwsStateError);
    });
  });

  group('resume cursor is derived, never stored (AC-25 / AC-26)', () {
    const questionIds = <String>['q.one', 'q.two', 'q.three'];

    PortraitAnswer answer(String questionId, PortraitAnswerState state) =>
        PortraitAnswer(
          ownerKey: 'user-1',
          questionId: questionId,
          state: state,
          updatedAt: DateTime.utc(2026, 9, 12),
        );

    test('an untouched set opens on the first question', () {
      expect(
        resolveResumeQuestionId(questionIds, const <String, PortraitAnswer>{}),
        'q.one',
      );
    });

    test('a half-finished set reopens on the first unsettled question', () {
      final settled = <String, PortraitAnswer>{
        'q.one': answer('q.one', PortraitAnswerState.answered),
      };

      expect(resolveResumeQuestionId(questionIds, settled), 'q.two');
    });

    test('a skipped question is not the resume point while anything is still '
        'unseen', () {
      final settled = <String, PortraitAnswer>{
        'q.one': answer('q.one', PortraitAnswerState.skipped),
      };

      expect(resolveResumeQuestionId(questionIds, settled), 'q.two');
    });

    test('a skipped question comes back around once everything has been seen',
        () {
      final settled = <String, PortraitAnswer>{
        'q.one': answer('q.one', PortraitAnswerState.answered),
        'q.two': answer('q.two', PortraitAnswerState.skipped),
        'q.three': answer('q.three', PortraitAnswerState.answered),
      };

      expect(resolveResumeQuestionId(questionIds, settled), 'q.two');
    });

    test('a fully answered set has no resume point and no dead-end state', () {
      final settled = <String, PortraitAnswer>{
        for (final id in questionIds)
          id: answer(id, PortraitAnswerState.answered),
      };

      expect(resolveResumeQuestionId(questionIds, settled), isNull);
    });

    test('the repository derives the same cursor from stored answers',
        () async {
      final database = CupidDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = PortraitAnswerRepository(
        dao: PortraitAnswerDao(database),
        ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
      );

      await repository.upsertAnswer(
        questionId: 'q.one',
        target: PortraitAnswerTarget.portraitGuess,
        answerValue: 'Ở nhà',
      );

      expect(await repository.resumeQuestionId(questionIds), 'q.two');
    });
  });

  group('recordAnsweredQuestion — the one narrow write door (§3)', () {
    late CupidDatabase database;

    setUp(() {
      database = CupidDatabase(NativeDatabase.memory());
      getIt.registerSingleton<ContextNotebookRepository>(
        ContextNotebookRepository(
          dao: ContextNotebookDao(database),
          ownerKeyStore: storeFor('user-1'),
        ),
      );
    });

    tearDown(() async {
      await getIt.unregister<ContextNotebookRepository>();
      await database.close();
    });

    test('an answered interest question is readable back through '
        'ContextNotebookReader (AC-22)', () async {
      final entryId = await recordAnsweredQuestion(
        entryPointId: 'your_view_portrait',
        questionId: 'portrait.q.interest.food.v1',
        kind: NotebookKind.interest,
        value: 'Lẩu nóng',
      );

      final entries = await contextNotebookReader().entries();

      expect(entries.single.id, entryId);
      expect(entries.single.value, 'Lẩu nóng');
      expect(entries.single.kind, NotebookKind.interest);
    });

    test('the written entry carries its question id and the ask provenance',
        () async {
      await recordAnsweredQuestion(
        entryPointId: 'your_view_portrait',
        questionId: 'portrait.q.event.own_day.v1',
        kind: NotebookKind.event,
        value: 'Sinh nhật người ấy',
        eventOn: '2026-11-03',
      );

      final rows = await database.select(database.notebookEntries).get();

      expect(rows.single.questionId, 'portrait.q.event.own_day.v1');
      expect(rows.single.source, 'ask_on_the_spot');
      expect(rows.single.eventOn, '2026-11-03');
    });

    test('an answer with no question id is refused, so nothing lands in the '
        'notebook detached from what was asked', () async {
      await expectLater(
        recordAnsweredQuestion(
          entryPointId: 'your_view_portrait',
          questionId: '   ',
          kind: NotebookKind.interest,
          value: 'Lẩu nóng',
        ),
        throwsArgumentError,
      );

      expect(await database.select(database.notebookEntries).get(), isEmpty);
    });

    test('an answer with no calling entry point is refused', () {
      expect(
        recordAnsweredQuestion(
          entryPointId: '',
          questionId: 'portrait.q.interest.food.v1',
          kind: NotebookKind.interest,
          value: 'Lẩu nóng',
        ),
        throwsArgumentError,
      );
    });

    test('the door writes one answer per call: there is no kind outside '
        'interest and event to write through it', () {
      expect(
        NotebookKind.values,
        <NotebookKind>[NotebookKind.interest, NotebookKind.event],
      );
    });

    test('a portrait.guess target never reaches this door', () {
      expect(
        PortraitAnswerTarget.portraitGuess.writesToNotebook,
        isFalse,
      );
      expect(PortraitAnswerTarget.notebookInterest.writesToNotebook, isTrue);
      expect(PortraitAnswerTarget.notebookEvent.writesToNotebook, isTrue);
    });
  });
}
