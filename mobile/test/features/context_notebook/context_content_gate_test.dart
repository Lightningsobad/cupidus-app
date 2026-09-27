import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/content/invariant_terms.dart';
import 'package:cupid_mobile/features/context_notebook/domain/checkin_capture_content.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_content.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

ContentPackage<AskQuestion> _parseAsk(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<AskQuestion>(
      source,
      expectedSchemaId: askQuestionsSchemaId,
      itemParser: askQuestionFromJson,
      source: label,
    );

ContentPackage<SkillSeed> _parseSeeds(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<SkillSeed>(
      source,
      expectedSchemaId: skillSeedsSchemaId,
      itemParser: skillSeedFromJson,
      source: label,
    );

String _askPack({
  String prompt = 'Người ấy hợp gu ăn uống kiểu nào?',
  List<String> chips = const <String>['Món Việt'],
  String target = 'notebook.interest',
  Object? allowFreeText = true,
  String schemaId = askQuestionsSchemaId,
}) =>
    jsonEncode(<String, Object?>{
      'id': 'ask.fixture',
      'version': '1.0.0',
      'schema_id': schemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'ask.fixture.one.v1',
          'prompt': prompt,
          'target': target,
          'chips': chips,
          'allow_free_text': allowFreeText,
        },
      ],
    });

/// A seed pack that always carries the four required ids, so a test only has to
/// describe the one thing it breaks.
String _seedPack({
  List<String>? ids,
  String label = 'Nhớ dai',
}) =>
    jsonEncode(<String, Object?>{
      'id': 'skill.fixture',
      'version': '1.0.0',
      'schema_id': skillSeedsSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        for (final String id in ids ?? requiredSkillSeedIds)
          <String, Object?>{'id': id, 'label': label},
      ],
    });

ContentPackage<CheckinCaptureCopy> _parseCapture(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<CheckinCaptureCopy>(
      source,
      expectedSchemaId: checkinCaptureSchemaId,
      itemParser: checkinCaptureCopyFromJson,
      source: label,
    );

/// A capture pack carrying one clean line, so a test only has to describe the
/// one thing it breaks.
String _capturePack({String text = 'Hôm nay biết thêm gì về người ấy?'}) =>
    jsonEncode(<String, Object?>{
      'id': 'req017.capture.fixture',
      'version': '1.0.0',
      'schema_id': checkinCaptureSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{'id': checkinCaptureQuestionId, 'text': text},
      ],
    });

List<ContextGateRule> _rulesFrom(List<ContextViolation> violations) =>
    violations.map((ContextViolation v) => v.rule).toList(growable: false);

List<ContextGateRule> _askRules({
  String prompt = 'Người ấy hợp gu ăn uống kiểu nào?',
  List<String> chips = const <String>['Món Việt'],
}) =>
    _rulesFrom(
      validateContextPacks(
        askQuestions: _parseAsk(_askPack(prompt: prompt, chips: chips)),
        skillSeeds: _parseSeeds(_seedPack()),
        checkinCapture: _parseCapture(_capturePack()),
      ),
    );

List<ContextViolation> _captureViolations(String text) => validateContextPacks(
      askQuestions: _parseAsk(_askPack()),
      skillSeeds: _parseSeeds(_seedPack()),
      checkinCapture: _parseCapture(_capturePack(text: text)),
    );

void main() {
  group('shipped packs pass the gate from disk (AC-35/AC-36/BR-18)', () {
    late ContentPackage<AskQuestion> askQuestions;
    late ContentPackage<SkillSeed> skillSeeds;
    late ContentPackage<CheckinCaptureCopy> checkinCapture;

    setUp(() {
      askQuestions = _parseAsk(
        File(askQuestionsAssetKey).readAsStringSync(),
        label: askQuestionsAssetKey,
      );
      skillSeeds = _parseSeeds(
        File(skillSeedsAssetKey).readAsStringSync(),
        label: skillSeedsAssetKey,
      );
      checkinCapture = _parseCapture(
        File(checkinCaptureAssetKey).readAsStringSync(),
        label: checkinCaptureAssetKey,
      );
    });

    test('all three packs exist on disk and are not empty', () {
      expect(File(askQuestionsAssetKey).existsSync(), isTrue);
      expect(File(skillSeedsAssetKey).existsSync(), isTrue);
      expect(File(checkinCaptureAssetKey).existsSync(), isTrue);
      expect(askQuestions.items, isNotEmpty);
      expect(skillSeeds.items, isNotEmpty);
      expect(checkinCapture.items, isNotEmpty);
    });

    test('the packs on disk report no violation', () {
      expect(
        validateContextPacks(
          askQuestions: askQuestions,
          skillSeeds: skillSeeds,
          checkinCapture: checkinCapture,
        ).map((ContextViolation v) => v.toString()),
        isEmpty,
      );
    });

    test('the shipped questions cover all three targets', () {
      expect(
        askQuestions.items.map((AskQuestion q) => q.target).toSet(),
        AskTarget.values.toSet(),
      );
    });

    test('every shipped question offers tap-to-pick seeds (AC-10)', () {
      for (final AskQuestion question in askQuestions.items) {
        expect(question.chips, isNotEmpty, reason: question.id);
      }
    });

    test('the four required soft skills are on disk (AC-11)', () {
      for (final String id in requiredSkillSeedIds) {
        expect(skillSeeds.itemById(id), isNotNull, reason: id);
      }
    });

    test('no pack wording is written into any Dart or l10n file (BR-16)', () {
      final List<String> authored = <String>[
        for (final AskQuestion question in askQuestions.items) ...<String>[
          question.prompt,
          ...question.chips,
        ],
        for (final SkillSeed seed in skillSeeds.items) seed.label,
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
    test('only invariant_terms.dart declares denylisted terms', () {
      const List<String> probes = <String>[
        'thả thính',
        'điểm số',
        'xếp hạng',
        'chuỗi ngày',
        'hoạt động lần cuối',
        'tần suất',
        'xứng đáng',
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

    test('every gate rule name resolves to a shared rule', () {
      final Set<String> gateWireValues =
          ContextGateRule.values.map((ContextGateRule r) => r.wireValue).toSet();

      for (final InvariantRule rule in InvariantRule.values) {
        expect(gateWireValues, contains(rule.wireValue));
      }
      for (final NotebookBoundaryRule rule in NotebookBoundaryRule.values) {
        expect(gateWireValues, contains(rule.wireValue));
      }
    });
  });

  group('parser rules run before the gate sees a package', () {
    test('an unknown target is a parse error, not a default', () {
      expect(
        () => _parseAsk(_askPack(target: 'notebook.judgement')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported target "notebook.judgement"'),
          ),
        ),
      );
    });

    test('a question with no seed chips is rejected (AC-10)', () {
      expect(
        () => _parseAsk(_askPack(chips: const <String>[])),
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
        () => _parseAsk(_askPack(allowFreeText: 'yes')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('"allow_free_text" must be a boolean'),
          ),
        ),
      );
    });

    test('a pack under another schema id is rejected at load', () {
      expect(
        () => _parseAsk(_askPack(schemaId: 'req016.ask_questions.v2')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('does not match the expected "req016.ask_questions.v1"'),
          ),
        ),
      );
    });
  });

  group('shared invariant rules fire on context packs (AC-35)', () {
    test('flattery', () {
      expect(
        _askRules(prompt: 'Người ấy xinh kiểu nào?'),
        contains(ContextGateRule.flattery),
      );
    });

    test('a percentage figure', () {
      expect(
        _askRules(prompt: 'Hợp nhau 80% ở điểm nào?'),
        contains(ContextGateRule.percentDisplay),
      );
    });

    test('a streak or day chain', () {
      expect(
        _askRules(prompt: 'Mấy buổi liên tiếp vừa rồi đi đâu?'),
        contains(ContextGateRule.streakDisplay),
      );
    });

    test('a score or ratio', () {
      expect(
        _askRules(prompt: 'Điểm số buổi hẹn vừa rồi ra sao?'),
        contains(ContextGateRule.scoreOrRatio),
      );
    });

    test('a recipient-behaviour indicator', () {
      expect(
        _askRules(prompt: 'Người ấy đã xem tin lúc nào?'),
        contains(ContextGateRule.recipientBehaviour),
      );
    });

    test('a manipulative tone', () {
      expect(
        _askRules(prompt: 'Chiêu nào của bạn hiệu quả nhất?'),
        contains(ContextGateRule.manipulativeTone),
      );
    });

    test('a seed chip is scanned too, not only the prompt', () {
      expect(
        _askRules(chips: const <String>['Thả thính']),
        contains(ContextGateRule.manipulativeTone),
      );
    });

    test('a skill seed label is scanned', () {
      final List<ContextViolation> violations = validateContextPacks(
        askQuestions: _parseAsk(_askPack()),
        skillSeeds: _parseSeeds(_seedPack(label: 'Xếp hạng bạn bè')),
        checkinCapture: _parseCapture(_capturePack()),
      );

      expect(_rulesFrom(violations), contains(ContextGateRule.scoreOrRatio));
    });

    test('terms match whole words, so "địa điểm" is not a score', () {
      expect(
        _askRules(prompt: 'Địa điểm nào người ấy hay quay lại?'),
        isEmpty,
      );
    });
  });

  group('the notebook boundary is enforced at the input layer (AC-36/BR-4)',
      () {
    test('a frequency question', () {
      expect(
        _askRules(prompt: 'Người ấy nhắn cho bạn bao lâu một lần?'),
        contains(ContextGateRule.frequencyProbe),
      );
    });

    test('a behaviour question', () {
      expect(
        _askRules(prompt: 'Người ấy có hay nhắn trước không?'),
        contains(ContextGateRule.behaviourProbe),
      );
    });

    test('a human-judgement question', () {
      expect(
        _askRules(prompt: 'Bạn đánh giá người ấy thế nào?'),
        contains(ContextGateRule.judgementProbe),
      );
    });

    test('a judgement question hidden in a seed chip', () {
      expect(
        _askRules(chips: const <String>['Tính cách dễ chịu']),
        contains(ContextGateRule.judgementProbe),
      );
    });

    test('an interest question about the same person stays clean', () {
      expect(
        _askRules(
          prompt: 'Người ấy hợp gu ăn uống kiểu nào?',
          chips: const <String>['Món Việt', 'Đồ ngọt'],
        ),
        isEmpty,
      );
    });
  });

  group('the required soft-skill seeds are a gate rule (AC-11)', () {
    test('a seed pack missing one required id is a violation', () {
      final List<String> incomplete = requiredSkillSeedIds
          .where((String id) => id != 'skill.nho_dai.v1')
          .toList(growable: false);

      final List<ContextViolation> violations = validateContextPacks(
        askQuestions: _parseAsk(_askPack()),
        skillSeeds: _parseSeeds(_seedPack(ids: incomplete)),
        checkinCapture: _parseCapture(_capturePack()),
      );

      expect(
        _rulesFrom(violations),
        contains(ContextGateRule.missingRequiredSkillSeed),
      );
      expect(
        violations
            .where(
              (ContextViolation v) =>
                  v.rule == ContextGateRule.missingRequiredSkillSeed,
            )
            .map((ContextViolation v) => v.itemId),
        <String>['skill.nho_dai.v1'],
      );
    });

    test('an empty seed pack reports all four missing ids', () {
      final List<ContextViolation> violations = validateContextPacks(
        askQuestions: _parseAsk(_askPack()),
        skillSeeds: _parseSeeds(_seedPack(ids: const <String>[])),
        checkinCapture: _parseCapture(_capturePack()),
      );

      expect(
        violations.map((ContextViolation v) => v.itemId),
        requiredSkillSeedIds,
      );
    });
  });

  group('the check-in capture pack is gated too (REQ-017 AC-14)', () {
    test('a denylisted term in capture copy is attributed to its own pack', () {
      final List<ContextViolation> violations =
          _captureViolations('Điểm số hôm nay của người ấy?');

      expect(
        violations.where(
          (ContextViolation v) => v.packageId == 'req017.capture.fixture',
        ),
        isNotEmpty,
      );
      expect(_rulesFrom(violations), contains(ContextGateRule.scoreOrRatio));
      expect(
        violations
            .where(
              (ContextViolation v) => v.rule == ContextGateRule.scoreOrRatio,
            )
            .map((ContextViolation v) => v.itemId),
        contains(checkinCaptureQuestionId),
      );
    });

    test('a notebook-boundary probe in capture copy is a violation', () {
      expect(
        _rulesFrom(_captureViolations('Người ấy nhắn bao lâu một lần?')),
        contains(ContextGateRule.frequencyProbe),
      );
    });

    test('clean capture copy leaves the other two packs clean', () {
      expect(_captureViolations('Hôm nay biết thêm gì về người ấy?'), isEmpty);
    });
  });
}
