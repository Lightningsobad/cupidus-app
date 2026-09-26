import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/content/invariant_terms.dart';
import 'package:cupid_mobile/features/your_view_portrait/domain/portrait_content.dart';
import 'package:cupid_mobile/features/your_view_portrait/domain/portrait_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

const String _fixtureQuestionId = 'portrait.q.fixture.v1';
const String _fixtureAskId = 'portrait.ask.fixture.v1';
const String _fixtureSectionId = 'portrait.section.fixture.v1';

ContentPackage<PortraitQuestion> _parseQuestions(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<PortraitQuestion>(
      source,
      expectedSchemaId: portraitQuestionsSchemaId,
      itemParser: portraitQuestionFromJson,
      source: label,
    );

ContentPackage<PortraitSection> _parseSections(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<PortraitSection>(
      source,
      expectedSchemaId: portraitSectionsSchemaId,
      itemParser: portraitSectionFromJson,
      source: label,
    );

ContentPackage<PortraitAsk> _parseAsks(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<PortraitAsk>(
      source,
      expectedSchemaId: portraitAsksSchemaId,
      itemParser: portraitAskFromJson,
      source: label,
    );

String _questionsPack({
  String prompt = 'Món nào người ấy hay chọn khi hai người đi ăn?',
  List<String> chips = const <String>['Món Việt'],
  String target = 'notebook.interest',
  Object? allowFreeText = true,
  String schemaId = portraitQuestionsSchemaId,
  String version = '1.0.0',
}) =>
    jsonEncode(<String, Object?>{
      'id': 'portrait.questions.fixture',
      'version': version,
      'schema_id': schemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': _fixtureQuestionId,
          'prompt': prompt,
          'target': target,
          'chips': chips,
          'allow_free_text': allowFreeText,
        },
      ],
    });

String _asksPack({
  String text = 'Bữa nào gần đây người ấy nhắc lại?',
  String version = '1.0.0',
}) =>
    jsonEncode(<String, Object?>{
      'id': 'portrait.asks.fixture',
      'version': version,
      'schema_id': portraitAsksSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{'id': _fixtureAskId, 'text': text},
      ],
    });

String _sectionsPack({
  String heading = 'Những điều dễ chịu',
  Map<String, String> bindings = const <String, String>{
    'mon_an': _fixtureQuestionId,
  },
  List<Map<String, Object?>>? clauses,
  List<String> askIds = const <String>[_fixtureAskId],
  String version = '1.0.0',
  int itemCount = 1,
}) =>
    jsonEncode(<String, Object?>{
      'id': 'portrait.sections.fixture',
      'version': version,
      'schema_id': portraitSectionsSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        for (int index = 0; index < itemCount; index++)
          <String, Object?>{
            'id': itemCount == 1 ? _fixtureSectionId : '$_fixtureSectionId.$index',
            'heading': heading,
            'bindings': bindings,
            'clauses': clauses ??
                <Map<String, Object?>>[
                  <String, Object?>{
                    'text': 'Theo cách bạn kể, người ấy hay nghiêng về {mon_an}.',
                    'requires': <String>['mon_an'],
                  },
                ],
            'ask_ids': askIds,
          },
      ],
    });

List<PortraitGateRule> _rulesFrom(List<PortraitViolation> violations) =>
    violations.map((PortraitViolation v) => v.rule).toList(growable: false);

/// Runs the gate over the default fixture triple with only the named override
/// changed, so each test describes the one thing it breaks.
List<PortraitGateRule> _gateRules({
  String? prompt,
  List<String>? chips,
  String? target,
  String? heading,
  Map<String, String>? bindings,
  List<Map<String, Object?>>? clauses,
  List<String>? askIds,
  String? askText,
  String? sectionsVersion,
}) =>
    _rulesFrom(
      validatePortraitPacks(
        questions: _parseQuestions(
          _questionsPack(
            prompt: prompt ?? 'Món nào người ấy hay chọn khi hai người đi ăn?',
            chips: chips ?? const <String>['Món Việt'],
            target: target ?? 'notebook.interest',
          ),
        ),
        sections: _parseSections(
          _sectionsPack(
            heading: heading ?? 'Những điều dễ chịu',
            bindings:
                bindings ?? const <String, String>{'mon_an': _fixtureQuestionId},
            clauses: clauses,
            askIds: askIds ?? const <String>[_fixtureAskId],
            version: sectionsVersion ?? '1.0.0',
          ),
        ),
        asks: _parseAsks(
          _asksPack(text: askText ?? 'Bữa nào gần đây người ấy nhắc lại?'),
        ),
      ),
    );

void main() {
  group('shipped portrait packs pass the gate from disk (AC-36/AC-37/BR-17)',
      () {
    late ContentPackage<PortraitQuestion> questions;
    late ContentPackage<PortraitSection> sections;
    late ContentPackage<PortraitAsk> asks;

    setUp(() {
      questions = _parseQuestions(
        File(portraitQuestionsAssetKey).readAsStringSync(),
        label: portraitQuestionsAssetKey,
      );
      sections = _parseSections(
        File(portraitSectionsAssetKey).readAsStringSync(),
        label: portraitSectionsAssetKey,
      );
      asks = _parseAsks(
        File(portraitAsksAssetKey).readAsStringSync(),
        label: portraitAsksAssetKey,
      );
    });

    test('all three packs exist on disk and are not empty', () {
      for (final String key in <String>[
        portraitQuestionsAssetKey,
        portraitSectionsAssetKey,
        portraitAsksAssetKey,
      ]) {
        expect(File(key).existsSync(), isTrue, reason: key);
      }
      expect(questions.items, isNotEmpty);
      expect(sections.items, isNotEmpty);
      expect(asks.items, isNotEmpty);
    });

    test('the packs on disk report no violation', () {
      expect(
        validatePortraitPacks(
          questions: questions,
          sections: sections,
          asks: asks,
        ).map((PortraitViolation v) => v.toString()),
        isEmpty,
      );
    });

    test('every disk pack file under assets/data/req016 is reachable', () {
      final List<String> onDisk = Directory('assets/data/req016')
          .listSync()
          .whereType<File>()
          .map((File file) => file.path.replaceAll(r'\', '/'))
          .where((String path) => path.contains('/portrait_'))
          .toList(growable: false)
        ..sort();

      expect(onDisk, <String>[
        portraitAsksAssetKey,
        portraitQuestionsAssetKey,
        portraitSectionsAssetKey,
      ]);
    });

    test('the shipped questions cover all three answer targets', () {
      expect(
        questions.items.map((PortraitQuestion q) => q.target).toSet(),
        PortraitAnswerTarget.values.toSet(),
      );
    });

    test('every shipped question offers tap-to-pick chips', () {
      for (final PortraitQuestion question in questions.items) {
        expect(question.chips, isNotEmpty, reason: question.id);
      }
    });

    test('every shipped section ends with a resolvable line to ask (R-1g)', () {
      for (final PortraitSection section in sections.items) {
        expect(section.askIds, isNotEmpty, reason: section.id);
        for (final String askId in section.askIds) {
          expect(asks.itemById(askId), isNotNull, reason: '${section.id}/$askId');
        }
      }
    });

    test('every shipped clause binds only declared variables', () {
      for (final PortraitSection section in sections.items) {
        for (final PortraitClause clause in section.clauses) {
          for (final String variable in clause.requires) {
            expect(
              section.bindings.keys,
              contains(variable),
              reason: '${section.id}: $variable',
            );
          }
        }
        for (final String questionId in section.bindings.values) {
          expect(
            questions.itemById(questionId),
            isNotNull,
            reason: '${section.id}: $questionId',
          );
        }
      }
    });

    test('every shipped line to ask ends with a question mark', () {
      for (final PortraitAsk ask in asks.items) {
        expect(ask.text, endsWith('?'), reason: ask.id);
      }
    });

    test('no portrait wording is written into any Dart or l10n file (BR-15)',
        () {
      final List<String> authored = <String>[
        for (final PortraitQuestion question in questions.items) ...<String>[
          question.prompt,
          ...question.chips,
        ],
        for (final PortraitSection section in sections.items) ...<String>[
          section.heading,
          for (final PortraitClause clause in section.clauses) clause.text,
        ],
        for (final PortraitAsk ask in asks.items) ask.text,
      ];
      final List<String> offenders = <String>[];

      for (final FileSystemEntity entity
          in Directory('lib').listSync(recursive: true)) {
        if (entity is! File ||
            !(entity.path.endsWith('.dart') || entity.path.endsWith('.arb'))) {
          continue;
        }
        final String source = entity.readAsStringSync();
        for (final String text in authored) {
          if (source.contains(text)) {
            offenders.add('${entity.path} contains "$text"');
          }
        }
      }

      expect(authored, isNotEmpty);
      expect(offenders, isEmpty);
    });
  });

  group('the invariant rules have exactly one home (D-15/R-15c)', () {
    test('only invariant_terms.dart declares the assertive-claim terms', () {
      const List<String> probes = <String>[
        'người ấy là',
        'chắc chắn thích',
        'rõ ràng là',
        'vốn dĩ',
      ];
      final List<String> offenders = <String>[];

      for (final FileSystemEntity entity
          in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final String normalised = entity.path.replaceAll(r'\', '/');
        if (normalised.endsWith('lib/core/content/invariant_terms.dart')) {
          continue;
        }
        final String source = entity.readAsStringSync();
        for (final String probe in probes) {
          if (source.contains(probe)) {
            offenders.add('${entity.path} redeclares "$probe"');
          }
        }
      }

      expect(offenders, isEmpty);
    });

    test('every shared rule name resolves to a portrait gate rule', () {
      final Set<String> gateWireValues = PortraitGateRule.values
          .map((PortraitGateRule r) => r.wireValue)
          .toSet();

      for (final InvariantRule rule in InvariantRule.values) {
        expect(gateWireValues, contains(rule.wireValue));
      }
      for (final NotebookBoundaryRule rule in NotebookBoundaryRule.values) {
        expect(gateWireValues, contains(rule.wireValue));
      }
    });

    test('the legal opening frames live in Dart, never in a pack', () {
      final String sectionsSource =
          File(portraitSectionsAssetKey).readAsStringSync();

      for (final String frame in portraitLegalOpeningFrames) {
        expect(
          sectionsSource.contains('"$frame"'),
          isFalse,
          reason: 'the pack must not redeclare the frame list: $frame',
        );
      }
      expect(portraitLegalOpeningFrames, isNotEmpty);
    });
  });

  group('parser rules run before the gate sees a package', () {
    test('an unknown answer target is a parse error, not a default', () {
      expect(
        () => _parseQuestions(_questionsPack(target: 'skill')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported target "skill"'),
          ),
        ),
      );
    });

    test('a question with no chips is rejected', () {
      expect(
        () => _parseQuestions(_questionsPack(chips: const <String>[])),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('at least one seed chip'),
          ),
        ),
      );
    });

    test('a non-boolean allow_free_text is rejected', () {
      expect(
        () => _parseQuestions(_questionsPack(allowFreeText: 'yes')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('"allow_free_text" must be a boolean'),
          ),
        ),
      );
    });

    test('a section with no ask_ids is rejected', () {
      expect(
        () => _parseSections(_sectionsPack(askIds: const <String>[])),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('at least one line to ask'),
          ),
        ),
      );
    });

    test('a pack under another schema id is rejected at load', () {
      expect(
        () => _parseQuestions(
          _questionsPack(schemaId: 'req016.portrait_questions.v2'),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains(
              'does not match the expected "req016.portrait_questions.v1"',
            ),
          ),
        ),
      );
    });
  });

  group('shared invariant rules fire on portrait packs (AC-34/AC-36)', () {
    test('flattery', () {
      expect(
        _gateRules(prompt: 'Người ấy xinh kiểu nào?'),
        contains(PortraitGateRule.flattery),
      );
    });

    test('a percentage figure', () {
      expect(
        _gateRules(prompt: 'Hợp nhau 80% ở điểm nào?'),
        contains(PortraitGateRule.percentDisplay),
      );
    });

    test('a streak or day chain', () {
      expect(
        _gateRules(prompt: 'Mấy buổi liên tiếp vừa rồi đi đâu?'),
        contains(PortraitGateRule.streakDisplay),
      );
    });

    test('a score or ratio', () {
      expect(
        _gateRules(prompt: 'Điểm số buổi hẹn vừa rồi ra sao?'),
        contains(PortraitGateRule.scoreOrRatio),
      );
    });

    test('a recipient-behaviour indicator', () {
      expect(
        _gateRules(prompt: 'Người ấy đã xem tin lúc nào?'),
        contains(PortraitGateRule.recipientBehaviour),
      );
    });

    test('a manipulative tone', () {
      expect(
        _gateRules(prompt: 'Chiêu nào của bạn hiệu quả nhất?'),
        contains(PortraitGateRule.manipulativeTone),
      );
    });

    test('a chip is scanned too, not only the prompt', () {
      expect(
        _gateRules(chips: const <String>['Thả thính']),
        contains(PortraitGateRule.manipulativeTone),
      );
    });

    test('a section heading is scanned', () {
      expect(
        _gateRules(heading: 'Xếp hạng người ấy'),
        contains(PortraitGateRule.scoreOrRatio),
      );
    });

    test('terms match whole words, so "địa điểm" is not a score', () {
      expect(
        _gateRules(prompt: 'Địa điểm nào người ấy hay quay lại?'),
        isEmpty,
      );
    });
  });

  group('the app never asserts about the other person (AC-35/R-1e)', () {
    test('a clause that states what the other person is', () {
      expect(
        _gateRules(
          clauses: <Map<String, Object?>>[
            <String, Object?>{
              'text': 'Theo cách bạn kể, người ấy là kiểu sống nội tâm.',
              'requires': <String>[],
            },
          ],
        ),
        contains(PortraitGateRule.assertiveClaim),
      );
    });

    test('a line to ask that overrides the reader', () {
      expect(
        _gateRules(askText: 'Thực ra người ấy muốn gì?'),
        contains(PortraitGateRule.assertiveClaim),
      );
    });

    test('a question prompt that pre-decides the answer', () {
      expect(
        _gateRules(prompt: 'Người ấy chắc chắn thích món nào?'),
        contains(PortraitGateRule.assertiveClaim),
      );
    });
  });

  group('the notebook boundary is enforced at the input layer (AC-37/BR-6)',
      () {
    test('a frequency question bound for the notebook', () {
      expect(
        _gateRules(prompt: 'Người ấy nhắn cho bạn bao lâu một lần?'),
        contains(PortraitGateRule.frequencyProbe),
      );
    });

    test('a behaviour question bound for the notebook', () {
      expect(
        _gateRules(prompt: 'Người ấy có hay nhắn trước không?'),
        contains(PortraitGateRule.behaviourProbe),
      );
    });

    test('a human-judgement question bound for the notebook', () {
      expect(
        _gateRules(prompt: 'Bạn đánh giá người ấy thế nào?'),
        contains(PortraitGateRule.judgementProbe),
      );
    });

    test('a judgement question hidden in a chip', () {
      expect(
        _gateRules(chips: const <String>['Tính cách dễ chịu']),
        contains(PortraitGateRule.judgementProbe),
      );
    });

    test('an interest question about the same person stays clean', () {
      expect(
        _gateRules(
          prompt: 'Món nào người ấy hay chọn khi hai người đi ăn?',
          chips: const <String>['Món Việt', 'Đồ ngọt'],
        ),
        isEmpty,
      );
    });

    test(
        'the boundary is scoped to notebook targets, so a guess may stay a '
        'guess', () {
      expect(
        _gateRules(
          prompt: 'Bạn đoán người ấy có hay nhắn trước không?',
          target: 'portrait.guess',
        ),
        isEmpty,
      );
    });
  });

  group('the composition rules of a section are a gate rule (AC-19/AC-33)', () {
    test('an ask_id that is not in the store', () {
      expect(
        _gateRules(askIds: const <String>['portrait.ask.missing.v1']),
        contains(PortraitGateRule.unknownAskId),
      );
    });

    test('a binding that points at no question', () {
      expect(
        _gateRules(
          bindings: const <String, String>{
            'mon_an': 'portrait.q.missing.v1',
          },
        ),
        contains(PortraitGateRule.unknownBindingQuestion),
      );
    });

    test('a clause that requires a variable no binding declares', () {
      expect(
        _gateRules(
          clauses: <Map<String, Object?>>[
            <String, Object?>{
              'text': 'Theo cách bạn kể, người ấy nghiêng về {khac}.',
              'requires': <String>['khac'],
            },
          ],
        ),
        contains(PortraitGateRule.unboundRequiresVariable),
      );
    });

    test('a clause that does not open with a legal frame (AC-13/BR-4)', () {
      expect(
        _gateRules(
          clauses: <Map<String, Object?>>[
            <String, Object?>{
              'text': 'Người ấy nghiêng về {mon_an}.',
              'requires': <String>['mon_an'],
            },
          ],
        ),
        contains(PortraitGateRule.illegalOpeningFrame),
      );
    });

    test('every clause is checked, not only the first one', () {
      expect(
        _gateRules(
          clauses: <Map<String, Object?>>[
            <String, Object?>{
              'text': 'Theo cách bạn kể, người ấy nghiêng về {mon_an}.',
              'requires': <String>['mon_an'],
            },
            <String, Object?>{
              'text': 'Điều đó cho thấy gu ăn uống của người ấy.',
              'requires': <String>[],
            },
          ],
        ),
        contains(PortraitGateRule.illegalOpeningFrame),
      );
    });

    test('a line to ask that does not end with a question mark', () {
      expect(
        _gateRules(askText: 'Bữa nào gần đây người ấy nhắc lại.'),
        contains(PortraitGateRule.askNotAQuestion),
      );
    });

    test('a malformed pack version', () {
      expect(
        _gateRules(sectionsVersion: 'one'),
        contains(PortraitGateRule.malformedVersion),
      );
    });
  });

  group('envelope rules the parser cannot reach', () {
    ContentPackage<PortraitAsk> asksWith(List<PortraitAsk> items) =>
        ContentPackage<PortraitAsk>(
          id: 'portrait.asks.fixture',
          version: '1.0.0',
          schemaId: portraitAsksSchemaId,
          items: items,
        );

    test('a duplicate item id is reported', () {
      const PortraitAsk ask = PortraitAsk(
        id: _fixtureAskId,
        text: 'Bữa nào gần đây người ấy nhắc lại?',
      );

      final List<PortraitViolation> violations = validatePortraitPacks(
        questions: _parseQuestions(_questionsPack()),
        sections: _parseSections(_sectionsPack()),
        asks: asksWith(const <PortraitAsk>[ask, ask]),
      );

      expect(_rulesFrom(violations), contains(PortraitGateRule.duplicateItemId));
    });

    test('a pack carrying the wrong schema id is reported', () {
      final List<PortraitViolation> violations = validatePortraitPacks(
        questions: _parseQuestions(_questionsPack()),
        sections: _parseSections(_sectionsPack()),
        asks: ContentPackage<PortraitAsk>(
          id: 'portrait.asks.fixture',
          version: '1.0.0',
          schemaId: 'req016.portrait_asks.v2',
          items: const <PortraitAsk>[
            PortraitAsk(
              id: _fixtureAskId,
              text: 'Bữa nào gần đây người ấy nhắc lại?',
            ),
          ],
        ),
      );

      expect(
        _rulesFrom(violations),
        contains(PortraitGateRule.unexpectedSchemaId),
      );
    });

    test('a question with no chips is reported when it reaches the gate', () {
      final List<PortraitViolation> violations = validatePortraitPacks(
        questions: ContentPackage<PortraitQuestion>(
          id: 'portrait.questions.fixture',
          version: '1.0.0',
          schemaId: portraitQuestionsSchemaId,
          items: const <PortraitQuestion>[
            PortraitQuestion(
              id: _fixtureQuestionId,
              prompt: 'Món nào người ấy hay chọn khi hai người đi ăn?',
              target: PortraitAnswerTarget.notebookInterest,
              chips: <String>[],
              allowFreeText: true,
            ),
          ],
        ),
        sections: _parseSections(_sectionsPack()),
        asks: _parseAsks(_asksPack()),
      );

      expect(_rulesFrom(violations), contains(PortraitGateRule.missingChip));
    });

    test('a section with no ask_ids is reported when it reaches the gate', () {
      final List<PortraitViolation> violations = validatePortraitPacks(
        questions: _parseQuestions(_questionsPack()),
        sections: ContentPackage<PortraitSection>(
          id: 'portrait.sections.fixture',
          version: '1.0.0',
          schemaId: portraitSectionsSchemaId,
          items: const <PortraitSection>[
            PortraitSection(
              id: _fixtureSectionId,
              heading: 'Những điều dễ chịu',
              bindings: <String, String>{'mon_an': _fixtureQuestionId},
              clauses: <PortraitClause>[],
              askIds: <String>[],
            ),
          ],
        ),
        asks: _parseAsks(_asksPack()),
      );

      expect(
        _rulesFrom(violations),
        contains(PortraitGateRule.sectionWithoutAsk),
      );
    });
  });

  group('pack size is data, never a story constant (BR-16/R-15b)', () {
    test('a one-item sections pack passes', () {
      expect(_gateRules(), isEmpty);
    });

    test('a seven-item sections pack passes the same rules', () {
      expect(
        _rulesFrom(
          validatePortraitPacks(
            questions: _parseQuestions(_questionsPack()),
            sections: _parseSections(_sectionsPack(itemCount: 7)),
            asks: _parseAsks(_asksPack()),
          ),
        ),
        isEmpty,
      );
    });
  });
}
