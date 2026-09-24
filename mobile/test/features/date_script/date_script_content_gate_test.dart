import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/content/invariant_terms.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/date_script/domain/date_script_content.dart';
import 'package:cupid_mobile/features/date_script/domain/date_script_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

const String _featureDir = 'lib/features/date_script';

const DateScriptEditorialReview _completeReview = DateScriptEditorialReview(
  layer1: 'reviewer.a',
  layer2: 'reviewer.b',
  approvedAt: '2026-09-11',
);

/// The J7 boundary in phrase form (BR-3/AC-13/AC-14): the "during" part is text
/// read beforehand, so it must never tell the reader to operate the app while
/// they are sitting with the other person. Kept in the test rather than in the
/// gate because it is a review heuristic over prose, not a schema rule.
const List<String> _appInstructionPhrases = <String>[
  'mở app',
  'mở ứng dụng',
  'quay lại app',
  'bấm nút',
  'bấm vào',
  'nhấn nút',
  'mở màn hình',
  'ghi vào app',
  'đánh dấu',
  'bấm bắt đầu',
  'bật thông báo',
  'đặt hẹn giờ',
  'bấm lưu',
];

ContentPackage<DateScriptPreset> _shippedPack() {
  final File file = File(dateScriptAssetKey);
  expect(file.existsSync(), isTrue, reason: '$dateScriptAssetKey is missing');
  return ContentPackage.parse<DateScriptPreset>(
    file.readAsStringSync(),
    expectedSchemaId: dateScriptSchemaId,
    itemParser: dateScriptPresetFromJson,
    source: dateScriptAssetKey,
  );
}

DateScriptSentence _sentence(
  String text, {
  List<DateScriptVariable> requires = const <DateScriptVariable>[],
  bool aboutPartner = false,
}) =>
    DateScriptSentence(
      text: text,
      requires: requires,
      aboutPartner: aboutPartner,
    );

DateScriptPartContent _part(
  DateScriptPart part, {
  List<DateScriptSentence>? sentences,
}) =>
    DateScriptPartContent(
      part: part,
      sentences: sentences ??
          <DateScriptSentence>[_sentence('Câu mẫu không điều kiện.')],
    );

List<DateScriptPartContent> _defaultParts() => <DateScriptPartContent>[
      _part(DateScriptPart.before),
      _part(DateScriptPart.during),
      _part(DateScriptPart.after),
    ];

DateScriptPreset _preset({
  String id = 'fixture.one.v1',
  List<ActivityType> activityTypes = const <ActivityType>[],
  List<DateScriptPartContent>? parts,
  DateScriptEditorialReview? editorialReview = _completeReview,
}) =>
    DateScriptPreset(
      id: id,
      activityTypes: activityTypes,
      parts: parts ?? _defaultParts(),
      editorialReview: editorialReview,
    );

ContentPackage<DateScriptPreset> _pack(List<DateScriptPreset> items) =>
    ContentPackage<DateScriptPreset>(
      id: 'date_script.fixture',
      version: '1.0.0',
      schemaId: dateScriptSchemaId,
      items: items,
    );

List<DateScriptGateRule> _rulesFrom(List<DateScriptViolation> violations) =>
    violations
        .map((DateScriptViolation v) => v.rule)
        .toList(growable: false);

List<DateScriptViolation> _violationsFor(DateScriptGateRule rule,
        List<DateScriptViolation> violations) =>
    violations
        .where((DateScriptViolation v) => v.rule == rule)
        .toList(growable: false);

List<String> _appInstructionHits(Iterable<String> texts) => <String>[
      for (final String text in texts)
        for (final String phrase in _appInstructionPhrases)
          if (text.toLowerCase().contains(phrase)) '$text ~ $phrase',
    ];

/// A denied term written as its own Dart string literal is a second denylist.
/// A wire value that merely contains the term as a substring, such as the
/// `score_or_ratio` rule name, is not (R-15c).
List<String> _deniedTermLiterals(String source) => <String>[
      for (final List<String> terms in invariantDeniedTerms.values)
        for (final String term in terms)
          if (source.contains("'$term'") || source.contains('"$term"')) term,
    ];

List<File> _featureSourceFiles() => Directory(_featureDir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File file) => file.path.endsWith('.dart'))
    .toList(growable: false);

void main() {
  group('the shipped pack passes the gate (AC-36/BR-18)', () {
    test('it reports no violation at all', () {
      final ContentPackage<DateScriptPreset> pack = _shippedPack();

      expect(
        validateDateScriptPack(pack)
            .map((DateScriptViolation v) => v.toString()),
        isEmpty,
      );
    });

    test('the "during" part never tells the reader to touch the app (BR-3)',
        () {
      final ContentPackage<DateScriptPreset> pack = _shippedPack();
      final List<String> duringTexts = <String>[
        for (final DateScriptPreset preset in pack.items)
          for (final DateScriptPartContent part in preset.parts)
            if (part.part == DateScriptPart.during)
              for (final DateScriptSentence sentence in part.sentences)
                sentence.text,
      ];

      expect(duringTexts, isNotEmpty);
      expect(_appInstructionHits(duringTexts), isEmpty);
    });

    test('the J7 scan actually catches an app instruction', () {
      expect(
        _appInstructionHits(<String>['Mở app rồi bấm nút bắt đầu buổi hẹn.']),
        isNotEmpty,
      );
    });
  });

  group('structural rules the gate owns', () {
    test('the clean fixture reports nothing, so the controls below isolate one '
        'rule', () {
      expect(validateDateScriptPack(_pack(<DateScriptPreset>[_preset()])),
          isEmpty);
    });

    test('a preset missing a part', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[
          _preset(
            parts: <DateScriptPartContent>[
              _part(DateScriptPart.before),
              _part(DateScriptPart.during),
            ],
          ),
        ]),
      );

      expect(_rulesFrom(violations), contains(DateScriptGateRule.partsShape));
      expect(
        _violationsFor(DateScriptGateRule.partsShape, violations).single.presetId,
        'fixture.one.v1',
      );
    });

    test('the three parts in the wrong order', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[
          _preset(
            parts: <DateScriptPartContent>[
              _part(DateScriptPart.before),
              _part(DateScriptPart.after),
              _part(DateScriptPart.during),
            ],
          ),
        ]),
      );

      expect(_rulesFrom(violations), contains(DateScriptGateRule.partsShape));
    });

    test('a pack with no generic preset (AC-34)', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[
          _preset(activityTypes: <ActivityType>[ActivityType.dining]),
        ]),
      );

      expect(
        _rulesFrom(violations),
        contains(DateScriptGateRule.genericPresetMissing),
      );
      expect(
        _violationsFor(DateScriptGateRule.genericPresetMissing, violations)
            .single
            .presetId,
        isNull,
      );
    });

    test('a part whose every sentence is conditional (AC-10/AC-37)', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[
          _preset(
            parts: <DateScriptPartContent>[
              _part(DateScriptPart.before),
              _part(
                DateScriptPart.during,
                sentences: <DateScriptSentence>[
                  _sentence(
                    'Chỗ hẹn là {place}.',
                    requires: <DateScriptVariable>[DateScriptVariable.place],
                  ),
                ],
              ),
              _part(DateScriptPart.after),
            ],
          ),
        ]),
      );

      expect(
        _violationsFor(
          DateScriptGateRule.unconditionalSentenceMissing,
          violations,
        ).single.detail,
        contains('part "during"'),
      );
    });

    test('a placeholder that is not declared in "requires"', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[
          _preset(
            parts: <DateScriptPartContent>[
              _part(
                DateScriptPart.before,
                sentences: <DateScriptSentence>[
                  _sentence('Chỗ hẹn là {place}.'),
                ],
              ),
              _part(DateScriptPart.during),
              _part(DateScriptPart.after),
            ],
          ),
        ]),
      );

      final DateScriptViolation violation = _violationsFor(
        DateScriptGateRule.undeclaredPlaceholder,
        violations,
      ).single;
      expect(violation.detail, contains('{place}'));
      expect(violation.detail, contains('Chỗ hẹn là {place}.'));
    });

    test('a sentence about the other person that does not ask (AC-26/R-1g)',
        () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[
          _preset(
            parts: <DateScriptPartContent>[
              _part(DateScriptPart.before),
              _part(
                DateScriptPart.during,
                sentences: <DateScriptSentence>[
                  _sentence('Câu mẫu không điều kiện.'),
                  _sentence('Bạn ấy chắc chắn muốn đi chỗ khác.',
                      aboutPartner: true),
                ],
              ),
              _part(DateScriptPart.after),
            ],
          ),
        ]),
      );

      expect(
        _violationsFor(
          DateScriptGateRule.partnerSentenceNotQuestion,
          violations,
        ).single.detail,
        contains('Bạn ấy chắc chắn muốn đi chỗ khác.'),
      );
    });

    test('a sentence about the other person that does ask is clean', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[
          _preset(
            parts: <DateScriptPartContent>[
              _part(DateScriptPart.before),
              _part(
                DateScriptPart.during,
                sentences: <DateScriptSentence>[
                  _sentence('Câu mẫu không điều kiện.'),
                  _sentence('Bạn ấy muốn đi chỗ khác không?',
                      aboutPartner: true),
                ],
              ),
              _part(DateScriptPart.after),
            ],
          ),
        ]),
      );

      expect(violations, isEmpty);
    });

    test('a duplicate preset id', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[_preset(), _preset()]),
      );

      expect(
        _violationsFor(DateScriptGateRule.duplicatePresetId, violations),
        hasLength(1),
      );
    });

    test('a non-ASCII preset id', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[_preset(id: 'kịch_bản.v1')]),
      );

      expect(
        _violationsFor(DateScriptGateRule.nonAsciiPresetId, violations)
            .single
            .presetId,
        'kịch_bản.v1',
      );
    });

    test('a missing editorial_review (AC-31/SB-123)', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[_preset(editorialReview: null)]),
      );

      expect(
        _rulesFrom(violations),
        contains(DateScriptGateRule.editorialReviewIncomplete),
      );
    });

    test('an editorial_review without approved_at', () {
      final List<DateScriptViolation> violations = validateDateScriptPack(
        _pack(<DateScriptPreset>[
          _preset(
            editorialReview: const DateScriptEditorialReview(
              layer1: 'reviewer.a',
              layer2: 'reviewer.b',
            ),
          ),
        ]),
      );

      expect(
        _rulesFrom(violations),
        contains(DateScriptGateRule.editorialReviewIncomplete),
      );
    });
  });

  group('the lexical layer is delegated, not copied (R-15c)', () {
    List<DateScriptViolation> violationsForText(String text) =>
        validateDateScriptPack(
          _pack(<DateScriptPreset>[
            _preset(
              parts: <DateScriptPartContent>[
                _part(
                  DateScriptPart.before,
                  sentences: <DateScriptSentence>[_sentence(text)],
                ),
                _part(DateScriptPart.during),
                _part(DateScriptPart.after),
              ],
            ),
          ]),
        );

    test('flattery', () {
      expect(
        _rulesFrom(violationsForText('Bạn ấy xinh nên cứ khen thật nhiều.')),
        contains(DateScriptGateRule.flattery),
      );
    });

    test('a percentage figure', () {
      expect(
        _rulesFrom(violationsForText('Khả năng vui là 90%.')),
        contains(DateScriptGateRule.percentDisplay),
      );
    });

    test('a streak', () {
      expect(
        _rulesFrom(violationsForText('Đây là buổi thứ ba liên tiếp.')),
        contains(DateScriptGateRule.streakDisplay),
      );
    });

    test('a score or ratio', () {
      expect(
        _rulesFrom(violationsForText('Chấm điểm buổi hẹn sau khi về.')),
        contains(DateScriptGateRule.scoreOrRatio),
      );
    });

    test('a recipient-behaviour indicator (R-1b)', () {
      expect(
        _rulesFrom(violationsForText('Xem bạn ấy đã xem tin chưa.')),
        contains(DateScriptGateRule.recipientBehaviour),
      );
    });

    test('a manipulative tone (R-1e)', () {
      expect(
        _rulesFrom(violationsForText('Đây là chiêu quen thuộc.')),
        contains(DateScriptGateRule.manipulativeTone),
      );
    });

    test('a frequency probe crosses the notebook boundary (R-1f)', () {
      expect(
        _rulesFrom(violationsForText('Hỏi tần suất bạn ấy đi chơi.')),
        contains(DateScriptGateRule.frequencyProbe),
      );
    });

    test('a behaviour probe crosses the notebook boundary', () {
      expect(
        _rulesFrom(violationsForText('Để ý cách bạn ấy trả lời tin.')),
        contains(DateScriptGateRule.behaviourProbe),
      );
    });

    test('a judgement probe crosses the notebook boundary', () {
      expect(
        _rulesFrom(violationsForText('Ghi lại nhận xét về bạn ấy.')),
        contains(DateScriptGateRule.judgementProbe),
      );
    });

    test('terms still match whole words, so "địa điểm" is not a score', () {
      expect(violationsForText('Địa điểm đã chốt.'), isEmpty);
    });
  });

  group('content stays out of code (R-15a/R-15c)', () {
    test('the feature source scan finds files to scan', () {
      expect(_featureSourceFiles(), isNotEmpty);
    });

    test('no shipped script wording lives in a Dart file under the feature', () {
      final List<String> authored = <String>[
        for (final DateScriptPreset preset in _shippedPack().items)
          for (final DateScriptPartContent part in preset.parts)
            for (final DateScriptSentence sentence in part.sentences)
              sentence.text,
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
