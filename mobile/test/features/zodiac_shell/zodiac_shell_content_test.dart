import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content.dart';
import 'package:flutter_test/flutter_test.dart';

const Map<String, Object?> _review = <String, Object?>{
  'layer1': 'reviewer.a',
  'layer2': 'reviewer.b',
  'approved_at': '2026-09-24',
};

Map<String, Object?> _optionJson(int index) => <String, Object?>{
      'id': 'o.fixture.$index.v1',
      'label': 'Lựa chọn $index',
      'outcome_key': 'key_$index',
    };

Map<String, Object?> _questionJson(int index) => <String, Object?>{
      'id': 'q.fixture.$index.v1',
      'prompt': 'Bạn nghiêng về phía nào hơn?',
      'subject': 'self',
      'options': <Map<String, Object?>>[_optionJson(index)],
    };

Map<String, Object?> _quizSetJson({
  String id = 'set.fixture.v1',
  int questionCount = 1,
  int questionsPerRound = 1,
  Map<String, Object?>? extraKeys,
}) =>
    <String, Object?>{
      'id': id,
      'kind': 'slice',
      'title': 'Lát thử',
      'blurb': '',
      'questions_per_round': questionsPerRound,
      'questions': <Map<String, Object?>>[
        for (int index = 0; index < questionCount; index++)
          _questionJson(index),
      ],
      'mapping': <Map<String, Object?>>[
        <String, Object?>{'key': 'key_0', 'outcome_id': 'out.fixture.v1'},
      ],
      'fallback_outcome_id': 'out.chung.v1',
      'editorial_review': _review,
      ...?extraKeys,
    };

Map<String, Object?> _outcomeJson({
  String id = 'out.fixture.v1',
  bool aboutOther = false,
  Object? askLine,
  int suggestionCount = 3,
}) =>
    <String, Object?>{
      'id': id,
      'insight': 'Bạn hay quyết nhanh rồi mới cân nhắc.',
      'about_other': aboutOther,
      'ask_line': askLine,
      'suggestions': <Map<String, Object?>>[
        for (int index = 0; index < suggestionCount; index++)
          <String, Object?>{
            'id': 'sg.fixture.$index.v1',
            'title': 'Rủ đi bộ một vòng vào chiều mát',
            'note': null,
            'notebook_tags': <String>[],
          },
      ],
      'editorial_review': _review,
    };

String _packageJson({
  required String id,
  required String schemaId,
  required List<Map<String, Object?>> items,
}) =>
    jsonEncode(<String, Object?>{
      'id': id,
      'version': '1',
      'schema_id': schemaId,
      'items': items,
    });

ContentPackage<ZodiacQuizSet> _parseQuiz(List<Map<String, Object?>> items) =>
    ContentPackage.parse<ZodiacQuizSet>(
      _packageJson(
        id: 'zodiac_quiz.fixture',
        schemaId: zodiacQuizSchemaId,
        items: items,
      ),
      expectedSchemaId: zodiacQuizSchemaId,
      itemParser: zodiacQuizSetFromJson,
      source: '<fixture>',
    );

ContentPackage<ZodiacOutcome> _parseOutcomes(
  List<Map<String, Object?>> items,
) =>
    ContentPackage.parse<ZodiacOutcome>(
      _packageJson(
        id: 'zodiac_outcomes.fixture',
        schemaId: zodiacOutcomesSchemaId,
        items: items,
      ),
      expectedSchemaId: zodiacOutcomesSchemaId,
      itemParser: zodiacOutcomeFromJson,
      source: '<fixture>',
    );

ContentPackage<ZodiacQuizSet> shippedQuizPack() {
  final File file = File(zodiacQuizAssetKey);
  expect(file.existsSync(), isTrue, reason: '$zodiacQuizAssetKey is missing');
  return ContentPackage.parse<ZodiacQuizSet>(
    file.readAsStringSync(),
    expectedSchemaId: zodiacQuizSchemaId,
    itemParser: zodiacQuizSetFromJson,
    source: zodiacQuizAssetKey,
  );
}

ContentPackage<ZodiacOutcome> shippedOutcomesPack() {
  final File file = File(zodiacOutcomesAssetKey);
  expect(
    file.existsSync(),
    isTrue,
    reason: '$zodiacOutcomesAssetKey is missing',
  );
  return ContentPackage.parse<ZodiacOutcome>(
    file.readAsStringSync(),
    expectedSchemaId: zodiacOutcomesSchemaId,
    itemParser: zodiacOutcomeFromJson,
    source: zodiacOutcomesAssetKey,
  );
}

void main() {
  group('the shipped packages parse (AC-30/R-15a)', () {
    test('both packages parse under their contract schema id', () {
      expect(shippedQuizPack().schemaId, zodiacQuizSchemaId);
      expect(shippedOutcomesPack().schemaId, zodiacOutcomesSchemaId);
    });

    test('a wrong expectedSchemaId is a loud failure, not a silent empty pack',
        () {
      expect(
        () => ContentPackage.parse<ZodiacQuizSet>(
          File(zodiacQuizAssetKey).readAsStringSync(),
          expectedSchemaId: zodiacOutcomesSchemaId,
          itemParser: zodiacQuizSetFromJson,
          source: zodiacQuizAssetKey,
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('every set declares the questions one round asks for', () {
      for (final ZodiacQuizSet set in shippedQuizPack().items) {
        expect(
          set.questionsPerRound,
          inInclusiveRange(1, set.questions.length),
          reason: set.id,
        );
      }
    });

    test('every mapping key is the round\'s outcome_keys joined in order '
        '(§3 row 7)', () {
      for (final ZodiacQuizSet set in shippedQuizPack().items) {
        final List<Set<String>> keysByQuestion = <Set<String>>[
          for (final ZodiacQuestion question in set.questions)
            <String>{
              for (final ZodiacOption option in question.options)
                option.outcomeKey,
            },
        ];

        for (final ZodiacOutcomeMapping entry in set.mapping) {
          final List<String> tokens =
              entry.key.split(zodiacOutcomeKeySeparator);
          expect(tokens, hasLength(set.questionsPerRound), reason: entry.key);
          for (int index = 0; index < tokens.length; index++) {
            expect(
              keysByQuestion[index],
              contains(tokens[index]),
              reason: '${set.id} mapping "${entry.key}"',
            );
          }
        }
      }
    });
  });

  group('N is a property of the data (R-15b/AC-31)', () {
    test('a package of one set reports one', () {
      expect(_parseQuiz(<Map<String, Object?>>[_quizSetJson()]).length, 1);
    });

    test('a package of seven sets reports seven', () {
      expect(
        _parseQuiz(<Map<String, Object?>>[
          for (int index = 0; index < 7; index++)
            _quizSetJson(id: 'set.fixture.$index.v1'),
        ]).length,
        7,
      );
    });

    test('a set of one question and a set of seven both parse', () {
      expect(
        _parseQuiz(<Map<String, Object?>>[_quizSetJson()])
            .items
            .single
            .questions,
        hasLength(1),
      );
      expect(
        _parseQuiz(<Map<String, Object?>>[
          _quizSetJson(questionCount: 7, questionsPerRound: 7),
        ]).items.single.questions,
        hasLength(7),
      );
    });

    test('the shipped packages are read through length, never a seed count',
        () {
      expect(shippedQuizPack().length, shippedQuizPack().items.length);
      expect(shippedOutcomesPack().length, greaterThan(0));
    });
  });

  group('the quiz parser rejects what has no valid reading', () {
    test('a missing mandatory field', () {
      final Map<String, Object?> json = _quizSetJson()..remove('title');
      expect(
        () => _parseQuiz(<Map<String, Object?>>[json]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('an unknown kind', () {
      final Map<String, Object?> json = _quizSetJson()
        ..['kind'] = 'horoscope';
      expect(
        () => _parseQuiz(<Map<String, Object?>>[json]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('an unknown subject', () {
      final Map<String, Object?> json = _quizSetJson();
      (json['questions']! as List<Map<String, Object?>>).single['subject'] =
          'about_other';
      expect(
        () => _parseQuiz(<Map<String, Object?>>[json]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('a set with no question', () {
      final Map<String, Object?> json = _quizSetJson(questionCount: 0);
      expect(
        () => _parseQuiz(<Map<String, Object?>>[json]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('a duplicate item id', () {
      expect(
        () => _parseQuiz(<Map<String, Object?>>[
          _quizSetJson(),
          _quizSetJson(),
        ]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('a non-integer questions_per_round', () {
      final Map<String, Object?> json = _quizSetJson()
        ..['questions_per_round'] = '1';
      expect(
        () => _parseQuiz(<Map<String, Object?>>[json]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('an unknown key is ignored so a CMS can evolve its export', () {
      final ZodiacQuizSet set = _parseQuiz(<Map<String, Object?>>[
        _quizSetJson(
          extraKeys: <String, Object?>{'cms_note': 'draft two'},
        ),
      ]).items.single;

      expect(set.id, 'set.fixture.v1');
      expect(set.declaredKeys, contains('cms_note'));
    });
  });

  group('the outcome parser', () {
    test('keeps a missing ask_line parseable so the gate can name it (AC-15)',
        () {
      final ZodiacOutcome outcome = _parseOutcomes(<Map<String, Object?>>[
        _outcomeJson(aboutOther: true),
      ]).items.single;

      expect(outcome.aboutOther, isTrue);
      expect(outcome.askLine, isNull);
    });

    test('keeps a two-suggestion outcome parseable so the gate can name it',
        () {
      expect(
        _parseOutcomes(<Map<String, Object?>>[
          _outcomeJson(suggestionCount: 2),
        ]).items.single.suggestions,
        hasLength(2),
      );
    });

    test('reads an ask_line that is present', () {
      expect(
        _parseOutcomes(<Map<String, Object?>>[
          _outcomeJson(aboutOther: true, askLine: 'Tối nay bạn ấy muốn gì?'),
        ]).items.single.askLine,
        'Tối nay bạn ấy muốn gì?',
      );
    });

    test('rejects a non-boolean about_other', () {
      final Map<String, Object?> json = _outcomeJson()..['about_other'] = 'no';
      expect(
        () => _parseOutcomes(<Map<String, Object?>>[json]),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('reads notebook_tags, empty included', () {
      expect(
        _parseOutcomes(<Map<String, Object?>>[_outcomeJson()])
            .items
            .single
            .suggestions
            .first
            .notebookTags,
        isEmpty,
      );
    });
  });

  group('collectJsonKeys reaches every depth', () {
    test('it finds a key nested inside a list of objects', () {
      expect(
        collectJsonKeys(<String, Object?>{
          'items': <Object?>[
            <String, Object?>{
              'nested': <String, Object?>{'unlocks_at': '2026-09-24'},
            },
          ],
        }),
        containsAll(<String>['items', 'nested', 'unlocks_at']),
      );
    });
  });
}
