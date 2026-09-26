import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/context_notebook/domain/ask_cadence_policy.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_content.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:flutter_test/flutter_test.dart';

AskQuestion _question(String id, AskTarget target) => AskQuestion(
      id: id,
      prompt: 'Câu hỏi $id',
      target: target,
      chips: const <String>['A', 'B'],
      allowFreeText: true,
    );

ContentPackage<AskQuestion> _package(List<AskQuestion> items) =>
    ContentPackage<AskQuestion>(
      id: 'req016.ask_questions',
      version: '1.0.0',
      schemaId: askQuestionsSchemaId,
      items: items,
    );

void main() {
  const AskCadencePolicy policy = AskCadencePolicy();

  late AskSessionSkips session;
  late ContentPackage<AskQuestion> questions;

  setUp(() {
    session = AskSessionSkips();
    questions = _package(<AskQuestion>[
      _question('ask.interest.food', AskTarget.notebookInterest),
      _question('ask.interest.hobby', AskTarget.notebookInterest),
      _question('ask.event.upcoming', AskTarget.notebookEvent),
      _question('ask.skill.handy', AskTarget.skill),
    ]);
  });

  AskQuestion? next({
    required List<String> neededFieldIds,
    Map<String, AskPromptStatus> settled = const <String, AskPromptStatus>{},
  }) =>
      policy.nextQuestion(
        questions: questions,
        neededFieldIds: neededFieldIds,
        settled: settled,
        sessionSkips: session,
      );

  group('chọn câu theo thứ tự ưu tiên (BR-2)', () {
    test('takes the first question of the first needed target', () {
      final AskQuestion? picked = next(
        neededFieldIds: <String>['notebook.interest', 'notebook.event'],
      );

      expect(picked!.id, 'ask.interest.food');
    });

    test('needed-field order beats package order', () {
      final AskQuestion? picked = next(
        neededFieldIds: <String>['skill', 'notebook.interest'],
      );

      expect(picked!.id, 'ask.skill.handy');
    });

    test('a target with no questions falls through to the next one', () {
      questions = _package(<AskQuestion>[
        _question('ask.skill.handy', AskTarget.skill),
      ]);

      final AskQuestion? picked = next(
        neededFieldIds: <String>['notebook.event', 'skill'],
      );

      expect(picked!.id, 'ask.skill.handy');
    });

    test('a target id outside contract-summary §2 is a caller bug, not a skip',
        () {
      expect(
        () => next(neededFieldIds: <String>['notebook.rating']),
        throwsArgumentError,
      );
    });
  });

  group('câu đã trả lời không quay lại (AC-1/AC-4)', () {
    test('an answered question is dropped for good', () {
      final AskQuestion? picked = next(
        neededFieldIds: <String>['notebook.interest'],
        settled: const <String, AskPromptStatus>{
          'ask.interest.food': AskPromptStatus.answered,
        },
      );

      expect(picked!.id, 'ask.interest.hobby');
    });

    test('nothing left to ask returns null rather than repeating', () {
      final AskQuestion? picked = next(
        neededFieldIds: <String>['notebook.event'],
        settled: const <String, AskPromptStatus>{
          'ask.event.upcoming': AskPromptStatus.answered,
        },
      );

      expect(picked, isNull);
    });
  });

  group('bỏ qua là phạm vi phiên, không phải đồng hồ (AC-3)', () {
    test('a question skipped this session is out for the rest of it', () {
      session.add('ask.interest.food');

      expect(
        next(neededFieldIds: <String>['notebook.interest'])!.id,
        'ask.interest.hobby',
      );
    });

    test('every question skipped this session leaves nothing to ask', () {
      session
        ..add('ask.interest.food')
        ..add('ask.interest.hobby');

      expect(next(neededFieldIds: <String>['notebook.interest']), isNull);
    });

    test('a question skipped in an earlier session queues behind fresh ones',
        () {
      final AskQuestion? picked = next(
        neededFieldIds: <String>['notebook.interest'],
        settled: const <String, AskPromptStatus>{
          'ask.interest.food': AskPromptStatus.skipped,
        },
      );

      expect(picked!.id, 'ask.interest.hobby');
    });

    test('a question skipped in an earlier session does come back eventually',
        () {
      final AskQuestion? picked = next(
        neededFieldIds: <String>['notebook.interest'],
        settled: const <String, AskPromptStatus>{
          'ask.interest.food': AskPromptStatus.skipped,
          'ask.interest.hobby': AskPromptStatus.answered,
        },
      );

      expect(picked!.id, 'ask.interest.food');
    });

    test('skipping it again this session takes it back out', () {
      session.add('ask.interest.food');

      final AskQuestion? picked = next(
        neededFieldIds: <String>['notebook.interest'],
        settled: const <String, AskPromptStatus>{
          'ask.interest.food': AskPromptStatus.skipped,
          'ask.interest.hobby': AskPromptStatus.answered,
        },
      );

      expect(picked, isNull);
    });
  });
}
