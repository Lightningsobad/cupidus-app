import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/content/invariant_terms.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content_gate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _featureDir = 'lib/features/zodiac_shell';

/// AC-22/AC-23: the shell plays with the radio off, so no transport, no
/// generated API client, and no model call may be reachable from this module.
const List<String> _forbiddenImportFragments = <String>[
  'package:http',
  'package:dio',
  'package:cupid_api',
  'package:socket_io_client',
  'package:firebase',
  'api_client',
  'dart:io',
];

const ZodiacEditorialReview _completeReview = ZodiacEditorialReview(
  layer1: 'reviewer.a',
  layer2: 'reviewer.b',
  approvedAt: '2026-09-24',
);

/// Reads assets off disk so the gate runs against the bytes that ship, without
/// depending on a test-time asset manifest.
class _DiskAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw StateError('asset "$key" is missing');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }
}

ZodiacQuestion _question({
  String id = 'q.fixture.v1',
  String prompt = 'Bạn nghiêng về phía nào hơn?',
  ZodiacQuestionSubject subject = ZodiacQuestionSubject.self,
}) =>
    ZodiacQuestion(
      id: id,
      prompt: prompt,
      subject: subject,
      options: const <ZodiacOption>[
        ZodiacOption(
          id: 'o.fixture.v1',
          label: 'Lựa chọn một',
          outcomeKey: 'key_0',
        ),
      ],
    );

ZodiacQuizSet _set({
  String id = 'set.fixture.v1',
  List<ZodiacQuestion>? questions,
  int questionsPerRound = 1,
  List<ZodiacOutcomeMapping> mapping = const <ZodiacOutcomeMapping>[
    ZodiacOutcomeMapping(key: 'key_0', outcomeId: 'out.fixture.v1'),
  ],
  String fallbackOutcomeId = 'out.chung.v1',
  Set<String> declaredKeys = const <String>{'id', 'kind', 'questions'},
  ZodiacEditorialReview? editorialReview = _completeReview,
}) =>
    ZodiacQuizSet(
      id: id,
      kind: ZodiacSetKind.slice,
      title: 'Lát thử',
      blurb: '',
      questionsPerRound: questionsPerRound,
      questions: questions ?? <ZodiacQuestion>[_question()],
      mapping: mapping,
      fallbackOutcomeId: fallbackOutcomeId,
      declaredKeys: declaredKeys,
      editorialReview: editorialReview,
    );

ZodiacSuggestion _suggestion({
  String id = 'sg.fixture.v1',
  String title = 'Rủ đi bộ một vòng vào chiều mát',
  String? note,
}) =>
    ZodiacSuggestion(
      id: id,
      title: title,
      note: note,
      notebookTags: const <String>[],
    );

ZodiacOutcome _outcome({
  String id = 'out.fixture.v1',
  String insight = 'Bạn hay quyết nhanh rồi mới cân nhắc.',
  bool aboutOther = false,
  String? askLine,
  List<ZodiacSuggestion>? suggestions,
  Set<String> declaredKeys = const <String>{'id', 'insight', 'suggestions'},
  ZodiacEditorialReview? editorialReview = _completeReview,
}) =>
    ZodiacOutcome(
      id: id,
      insight: insight,
      aboutOther: aboutOther,
      askLine: askLine,
      suggestions: suggestions ??
          <ZodiacSuggestion>[
            _suggestion(id: 'sg.fixture.0.v1'),
            _suggestion(id: 'sg.fixture.1.v1'),
            _suggestion(id: 'sg.fixture.2.v1'),
          ],
      declaredKeys: declaredKeys,
      editorialReview: editorialReview,
    );

ContentPackage<ZodiacQuizSet> _quizPack(List<ZodiacQuizSet> items) =>
    ContentPackage<ZodiacQuizSet>(
      id: 'zodiac_quiz.fixture',
      version: '1',
      schemaId: zodiacQuizSchemaId,
      items: items,
    );

ContentPackage<ZodiacOutcome> _outcomePack(List<ZodiacOutcome> items) =>
    ContentPackage<ZodiacOutcome>(
      id: 'zodiac_outcomes.fixture',
      version: '1',
      schemaId: zodiacOutcomesSchemaId,
      items: items,
    );

List<ZodiacOutcome> _referencedOutcomes() => <ZodiacOutcome>[
      _outcome(),
      _outcome(id: 'out.chung.v1'),
    ];

List<ZodiacViolation> _validate({
  List<ZodiacQuizSet>? sets,
  List<ZodiacOutcome>? outcomes,
}) =>
    validateZodiacPacks(
      quiz: _quizPack(sets ?? <ZodiacQuizSet>[_set()]),
      outcomes: _outcomePack(outcomes ?? _referencedOutcomes()),
    );

List<ZodiacGateRule> _rulesFrom(List<ZodiacViolation> violations) => violations
    .map((ZodiacViolation violation) => violation.rule)
    .toList(growable: false);

List<ZodiacViolation> _violationsFor(
  ZodiacGateRule rule,
  List<ZodiacViolation> violations,
) =>
    violations
        .where((ZodiacViolation violation) => violation.rule == rule)
        .toList(growable: false);

ContentPackage<ZodiacQuizSet> _shippedQuizPack() =>
    ContentPackage.parse<ZodiacQuizSet>(
      File(zodiacQuizAssetKey).readAsStringSync(),
      expectedSchemaId: zodiacQuizSchemaId,
      itemParser: zodiacQuizSetFromJson,
      source: zodiacQuizAssetKey,
    );

ContentPackage<ZodiacOutcome> _shippedOutcomesPack() =>
    ContentPackage.parse<ZodiacOutcome>(
      File(zodiacOutcomesAssetKey).readAsStringSync(),
      expectedSchemaId: zodiacOutcomesSchemaId,
      itemParser: zodiacOutcomeFromJson,
      source: zodiacOutcomesAssetKey,
    );

List<File> _featureSourceFiles() => Directory(_featureDir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File file) => file.path.endsWith('.dart'))
    .toList(growable: false);

List<String> _importLines(String source) => <String>[
      for (final String line in const LineSplitter().convert(source))
        if (line.trimLeft().startsWith('import ') ||
            line.trimLeft().startsWith('export '))
          line,
    ];

/// A denied term written as its own Dart string literal would be a second
/// denylist (R-15c). A term this module declares as a banned *JSON key* is not
/// one: `streak` is on both lists for different reasons, and the key ban is
/// what `contract-summary.md` §6 asks for.
List<String> _deniedTermLiterals(String source) => <String>[
      for (final List<String> terms in invariantDeniedTerms.values)
        for (final String term in terms)
          if (!zodiacTimeGatingKeys.contains(term) &&
              (source.contains("'$term'") || source.contains('"$term"')))
            term,
    ];

void main() {
  group('the shipped packages pass the gate (AC-33/AC-34)', () {
    test('they report no violation at all', () {
      expect(
        validateZodiacPacks(
          quiz: _shippedQuizPack(),
          outcomes: _shippedOutcomesPack(),
        ).map((ZodiacViolation violation) => violation.toString()),
        isEmpty,
      );
    });

    test('loaded through ContentPackageLoader they still report nothing',
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final ContentPackageLoader loader =
          ContentPackageLoader(bundle: _DiskAssetBundle());

      final ContentPackage<ZodiacQuizSet> quiz =
          await loader.load<ZodiacQuizSet>(
        zodiacQuizAssetKey,
        expectedSchemaId: zodiacQuizSchemaId,
        itemParser: zodiacQuizSetFromJson,
      );
      final ContentPackage<ZodiacOutcome> outcomes =
          await loader.load<ZodiacOutcome>(
        zodiacOutcomesAssetKey,
        expectedSchemaId: zodiacOutcomesSchemaId,
        itemParser: zodiacOutcomeFromJson,
      );

      expect(quiz.length, greaterThan(0));
      expect(outcomes.length, greaterThan(0));
      expect(
        () => assertZodiacPacksClean(quiz: quiz, outcomes: outcomes),
        returnsNormally,
      );
    });

    test('every outcome the shipped sets point at exists', () {
      final Set<String> outcomeIds = <String>{
        for (final ZodiacOutcome outcome in _shippedOutcomesPack().items)
          outcome.id,
      };

      for (final ZodiacQuizSet set in _shippedQuizPack().items) {
        expect(outcomeIds, contains(set.fallbackOutcomeId), reason: set.id);
        for (final ZodiacOutcomeMapping entry in set.mapping) {
          expect(outcomeIds, contains(entry.outcomeId), reason: entry.key);
        }
      }
    });
  });

  group('structural rules the gate owns', () {
    test('the clean fixture reports nothing, so the controls below isolate '
        'one rule', () {
      expect(_validate(), isEmpty);
    });

    test('an outcome about the other person with no ask_line (AC-15)', () {
      final List<ZodiacViolation> violations = _validate(
        outcomes: <ZodiacOutcome>[
          _outcome(aboutOther: true),
          _outcome(id: 'out.chung.v1'),
        ],
      );

      expect(
        _violationsFor(ZodiacGateRule.askLineMissing, violations).single.itemId,
        'out.fixture.v1',
      );
    });

    test('an ask_line that closes as a verdict instead of asking (AC-15/R-1g)',
        () {
      final List<ZodiacViolation> violations = _validate(
        outcomes: <ZodiacOutcome>[
          _outcome(
            aboutOther: true,
            askLine: 'Bạn ấy muốn một buổi tối yên.',
          ),
          _outcome(id: 'out.chung.v1'),
        ],
      );

      expect(
        _violationsFor(ZodiacGateRule.missingQuestionEnding, violations)
            .single
            .detail,
        contains('Bạn ấy muốn một buổi tối yên.'),
      );
    });

    test('an ask_line ending in the fullwidth question mark is clean', () {
      expect(
        _validate(
          outcomes: <ZodiacOutcome>[
            _outcome(aboutOther: true, askLine: 'Tối nay bạn ấy muốn gì？'),
            _outcome(id: 'out.chung.v1'),
          ],
        ),
        isEmpty,
      );
    });

    test('an ask_line on an outcome that is not about the other person', () {
      final List<ZodiacViolation> violations = _validate(
        outcomes: <ZodiacOutcome>[
          _outcome(askLine: 'Tối nay bạn ấy muốn gì?'),
          _outcome(id: 'out.chung.v1'),
        ],
      );

      expect(
        _rulesFrom(violations),
        contains(ZodiacGateRule.askLineWithoutAboutOther),
      );
    });

    test('an outcome offering fewer than three suggestions (AC-4/BR-2)', () {
      final List<ZodiacViolation> violations = _validate(
        outcomes: <ZodiacOutcome>[
          _outcome(
            suggestions: <ZodiacSuggestion>[
              _suggestion(id: 'sg.fixture.0.v1'),
              _suggestion(id: 'sg.fixture.1.v1'),
            ],
          ),
          _outcome(id: 'out.chung.v1'),
        ],
      );

      expect(
        _violationsFor(ZodiacGateRule.suggestionPoolTooSmall, violations)
            .single
            .detail,
        contains('2 suggestions'),
      );
    });

    test('a pool longer than three stays clean (§4)', () {
      expect(
        _validate(
          outcomes: <ZodiacOutcome>[
            _outcome(
              suggestions: <ZodiacSuggestion>[
                _suggestion(id: 'sg.fixture.0.v1'),
                _suggestion(id: 'sg.fixture.1.v1'),
                _suggestion(id: 'sg.fixture.2.v1'),
                _suggestion(id: 'sg.fixture.3.v1'),
              ],
            ),
            _outcome(id: 'out.chung.v1'),
          ],
        ),
        isEmpty,
      );
    });

    test('a mapping pointing at an outcome that does not exist (§5)', () {
      final List<ZodiacViolation> violations = _validate(
        sets: <ZodiacQuizSet>[
          _set(
            mapping: const <ZodiacOutcomeMapping>[
              ZodiacOutcomeMapping(key: 'key_0', outcomeId: 'out.missing.v1'),
            ],
          ),
        ],
      );

      expect(
        _violationsFor(ZodiacGateRule.outcomeReferenceMissing, violations)
            .single
            .detail,
        contains('out.missing.v1'),
      );
    });

    test('a fallback_outcome_id that does not exist (§5)', () {
      final List<ZodiacViolation> violations = _validate(
        sets: <ZodiacQuizSet>[_set(fallbackOutcomeId: 'out.missing.v1')],
      );

      expect(
        _violationsFor(ZodiacGateRule.outcomeReferenceMissing, violations)
            .single
            .detail,
        contains('fallback_outcome_id'),
      );
    });

    test('questions_per_round above the number of questions', () {
      final List<ZodiacViolation> violations = _validate(
        sets: <ZodiacQuizSet>[_set(questionsPerRound: 2)],
      );

      expect(
        _violationsFor(ZodiacGateRule.questionsPerRoundOutOfRange, violations)
            .single
            .detail,
        contains('outside 1..1'),
      );
    });

    test('questions_per_round below one', () {
      expect(
        _rulesFrom(_validate(sets: <ZodiacQuizSet>[_set(questionsPerRound: 0)])),
        contains(ZodiacGateRule.questionsPerRoundOutOfRange),
      );
    });

    test('an incomplete editorial_review (AC-29/SB-123)', () {
      expect(
        _rulesFrom(
          _validate(
            sets: <ZodiacQuizSet>[
              _set(
                editorialReview: const ZodiacEditorialReview(
                  layer1: 'reviewer.a',
                  layer2: 'reviewer.b',
                ),
              ),
            ],
          ),
        ),
        contains(ZodiacGateRule.editorialReviewIncomplete),
      );
    });

    test('a missing editorial_review', () {
      expect(
        _rulesFrom(
          _validate(
            outcomes: <ZodiacOutcome>[
              _outcome(editorialReview: null),
              _outcome(id: 'out.chung.v1'),
            ],
          ),
        ),
        contains(ZodiacGateRule.editorialReviewIncomplete),
      );
    });
  });

  group('time gating is refused outright (AC-18/19/20, §6)', () {
    for (final String key in zodiacTimeGatingKeys) {
      test('a set declaring "$key"', () {
        final List<ZodiacViolation> violations = _validate(
          sets: <ZodiacQuizSet>[_set(declaredKeys: <String>{'id', key})],
        );

        expect(
          _violationsFor(ZodiacGateRule.timeGatingKey, violations)
              .single
              .detail,
          contains('"$key"'),
        );
      });
    }

    test('an outcome declaring a time-gating key nested anywhere', () {
      expect(
        _rulesFrom(
          _validate(
            outcomes: <ZodiacOutcome>[
              _outcome(declaredKeys: <String>{'id', 'valid_from'}),
              _outcome(id: 'out.chung.v1'),
            ],
          ),
        ),
        contains(ZodiacGateRule.timeGatingKey),
      );
    });

    test('the shipped packages declare none of them', () {
      final Set<String> declared = <String>{
        for (final ZodiacQuizSet set in _shippedQuizPack().items)
          ...set.declaredKeys,
        for (final ZodiacOutcome outcome in _shippedOutcomesPack().items)
          ...outcome.declaredKeys,
      };

      expect(declared.intersection(zodiacTimeGatingKeys.toSet()), isEmpty);
    });
  });

  group('the output layer delegates its lexicon (R-15c)', () {
    List<ZodiacViolation> violationsForInsight(String insight) => _validate(
          outcomes: <ZodiacOutcome>[
            _outcome(insight: insight),
            _outcome(id: 'out.chung.v1'),
          ],
        );

    test('flattery', () {
      expect(
        _rulesFrom(violationsForInsight('Bạn xinh nên ai cũng quý.')),
        contains(ZodiacGateRule.flattery),
      );
    });

    test('a percentage figure (AC-13/AC-14)', () {
      expect(
        _rulesFrom(violationsForInsight('Hai người hợp nhau 90%.')),
        contains(ZodiacGateRule.percentDisplay),
      );
    });

    test('a streak', () {
      expect(
        _rulesFrom(violationsForInsight('Đây là lần thứ ba liên tiếp.')),
        contains(ZodiacGateRule.streakDisplay),
      );
    });

    test('a score or ratio', () {
      expect(
        _rulesFrom(violationsForInsight('Điểm số của bạn khá cao.')),
        contains(ZodiacGateRule.scoreOrRatio),
      );
    });

    test('a recipient-behaviour indicator (R-1b)', () {
      expect(
        _rulesFrom(violationsForInsight('Bạn ấy đã xem tin của bạn.')),
        contains(ZodiacGateRule.recipientBehaviour),
      );
    });

    test('a manipulative tone (R-1e)', () {
      expect(
        _rulesFrom(violationsForInsight('Đây là chiêu quen thuộc.')),
        contains(ZodiacGateRule.manipulativeTone),
      );
    });

    test('an assertive claim (SB-136)', () {
      expect(
        _rulesFrom(violationsForInsight('Bạn ấy chắc chắn là người hợp.')),
        contains(ZodiacGateRule.assertiveClaim),
      );
    });

    test('a suggestion title', () {
      expect(
        _rulesFrom(
          _validate(
            outcomes: <ZodiacOutcome>[
              _outcome(
                suggestions: <ZodiacSuggestion>[
                  _suggestion(id: 'sg.a.v1', title: 'Chấm điểm buổi hẹn'),
                  _suggestion(id: 'sg.b.v1'),
                  _suggestion(id: 'sg.c.v1'),
                ],
              ),
              _outcome(id: 'out.chung.v1'),
            ],
          ),
        ),
        contains(ZodiacGateRule.scoreOrRatio),
      );
    });

    test('a suggestion note', () {
      expect(
        _rulesFrom(
          _validate(
            outcomes: <ZodiacOutcome>[
              _outcome(
                suggestions: <ZodiacSuggestion>[
                  _suggestion(id: 'sg.a.v1', note: 'Giữ chuỗi ngày cho đều.'),
                  _suggestion(id: 'sg.b.v1'),
                  _suggestion(id: 'sg.c.v1'),
                ],
              ),
              _outcome(id: 'out.chung.v1'),
            ],
          ),
        ),
        contains(ZodiacGateRule.streakDisplay),
      );
    });

    test('terms still match whole words, so "địa điểm" is not a score', () {
      expect(violationsForInsight('Địa điểm bạn chọn thường gần nhà.'),
          isEmpty);
    });
  });

  group('the input layer refuses questions that measure the other person '
      '(AC-34/R-1b)', () {
    List<ZodiacViolation> violationsForPrompt(String prompt) => _validate(
          sets: <ZodiacQuizSet>[
            _set(questions: <ZodiacQuestion>[_question(prompt: prompt)]),
          ],
        );

    test('a frequency probe', () {
      expect(
        _rulesFrom(violationsForPrompt('Bạn ấy nhắn cho bạn tần suất ra sao?')),
        contains(ZodiacGateRule.frequencyProbe),
      );
    });

    test('a behaviour probe', () {
      expect(
        _rulesFrom(violationsForPrompt('Bạn ấy trả lời tin nhanh hay chậm?')),
        contains(ZodiacGateRule.behaviourProbe),
      );
    });

    test('a judgement probe', () {
      expect(
        _rulesFrom(violationsForPrompt('Bạn thấy tính cách bạn ấy thế nào?')),
        contains(ZodiacGateRule.judgementProbe),
      );
    });

    test('a prompt that shows a figure is caught too', () {
      expect(
        _rulesFrom(violationsForPrompt('Bạn hợp với người kia bao nhiêu %?')),
        contains(ZodiacGateRule.percentDisplay),
      );
    });

    test('a guess question about the other person stays allowed (AC-12)', () {
      expect(
        _validate(
          sets: <ZodiacQuizSet>[
            _set(
              questions: <ZodiacQuestion>[
                _question(
                  prompt: 'Bạn đoán bạn ấy thích một buổi tối thế nào?',
                  subject: ZodiacQuestionSubject.guessAboutOther,
                ),
              ],
            ),
          ],
        ),
        isEmpty,
      );
    });
  });

  group('the gate is loud', () {
    test('assertZodiacPacksClean throws with every violation it found', () {
      expect(
        () => assertZodiacPacksClean(
          quiz: _quizPack(<ZodiacQuizSet>[
            _set(fallbackOutcomeId: 'out.missing.v1'),
          ]),
          outcomes: _outcomePack(_referencedOutcomes()),
        ),
        throwsA(
          isA<ZodiacContentGateException>().having(
            (ZodiacContentGateException error) => error.violations,
            'violations',
            isNotEmpty,
          ),
        ),
      );
    });
  });

  group('the module stays offline and content-free (AC-22/AC-23/R-15a)', () {
    test('the source scan finds files to scan', () {
      expect(_featureSourceFiles(), isNotEmpty);
    });

    test('no source under the feature imports a transport or API client', () {
      final List<String> offenders = <String>[
        for (final File file in _featureSourceFiles())
          for (final String line in _importLines(file.readAsStringSync()))
            for (final String fragment in _forbiddenImportFragments)
              if (line.contains(fragment)) '${file.path}: $line',
      ];

      expect(offenders, isEmpty);
    });

    test('the import scan actually catches one', () {
      expect(
        <String>[
          for (final String line
              in _importLines("import 'package:dio/dio.dart';\nclass A {}"))
            for (final String fragment in _forbiddenImportFragments)
              if (line.contains(fragment)) line,
        ],
        isNotEmpty,
      );
    });

    test('no source writes down how many items a package ships (R-15b)', () {
      final List<int> seedCounts = <int>[
        _shippedQuizPack().length,
        _shippedOutcomesPack().length,
      ];
      final List<String> offenders = <String>[
        for (final File file in _featureSourceFiles())
          for (final int count in seedCounts)
            if (RegExp('(?<![\\w.])$count(?![\\w.])')
                .hasMatch(file.readAsStringSync()))
              '${file.path} writes down $count',
      ];

      expect(offenders, isEmpty);
    });

    test('no shipped wording lives in a Dart file under the feature', () {
      final List<String> authored = <String>[
        for (final ZodiacOutcome outcome in _shippedOutcomesPack().items)
          outcome.insight,
        for (final ZodiacQuizSet set in _shippedQuizPack().items)
          for (final ZodiacQuestion question in set.questions) question.prompt,
      ];
      final List<String> offenders = <String>[
        for (final File file in _featureSourceFiles())
          for (final String text in authored)
            if (file.readAsStringSync().contains(text))
              '${file.path} contains "$text"',
      ];

      expect(authored, isNotEmpty);
      expect(offenders, isEmpty);
    });

    test('the feature declares no second denylist', () {
      final List<String> offenders = <String>[
        for (final File file in _featureSourceFiles())
          for (final String term
              in _deniedTermLiterals(file.readAsStringSync()))
            '${file.path} declares "$term"',
      ];

      expect(offenders, isEmpty);
    });

    test('the denylist scan actually catches a copied term', () {
      expect(
        _deniedTermLiterals("const List<String> terms = <String>['thả thính'];"),
        isNotEmpty,
      );
    });
  });
}
