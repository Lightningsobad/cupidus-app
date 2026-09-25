import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/content/invariant_terms.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

const String _phaseStatusSourceDirectory = 'lib/features/phase_status';

/// Matches [term] only where it stands on its own, never where it happens to
/// sit inside a longer identifier. A plain substring scan cannot tell a second
/// copy of the rule table — which is what R-15c/D-15 forbids — from a storage
/// key the contract fixes verbatim, such as `phase_status.drip.seen_ids`.
///
/// Deliberately not `\b`: several terms start or end with a non-ASCII letter,
/// and Dart's word boundary is ASCII-only, so `\b` would silently fail to match
/// exactly the Vietnamese terms this scan exists for.
RegExp _standaloneTerm(String term) => RegExp(
      '(?<![a-z0-9_])${RegExp.escape(term.toLowerCase())}(?![a-z0-9_])',
    );

/// A clean line for each family, so a test only has to describe the one string
/// it breaks.
const String _cleanPhasePrimary = 'Chuẩn bị dần cho buổi tới';
const String _cleanPhaseSecondary = 'Bạn có thể chọn trước một chỗ';
const String _cleanPhaseEyebrow = 'PHA 1 · ĐANG ĐỢI';
const String _cleanDripBody = 'Kho của bạn dày thêm khi bạn cất thêm.';
const String _cleanNudgeTitle = 'Về tới nhà chưa?';
const String _cleanNudgeBody = 'Cất lại một tấm ảnh nếu bạn muốn.';

ContentPackage<PhaseContentItem> _parsePhaseContent(
  String source, {
  String label = '<fixture>',
}) =>
    ContentPackage.parse<PhaseContentItem>(
      source,
      expectedSchemaId: phaseContentSchemaId,
      itemParser: phaseContentItemFromJson,
      source: label,
    );

ContentPackage<DripItem> _parseDrip(
  String source, {
  String label = '<fixture>',
}) =>
    ContentPackage.parse<DripItem>(
      source,
      expectedSchemaId: dripSchemaId,
      itemParser: dripItemFromJson,
      source: label,
    );

ContentPackage<NudgeItem> _parseNudges(
  String source, {
  String label = '<fixture>',
}) =>
    ContentPackage.parse<NudgeItem>(
      source,
      expectedSchemaId: nudgesSchemaId,
      itemParser: nudgeItemFromJson,
      source: label,
    );

String _phaseContentPack({
  String primary = _cleanPhasePrimary,
  String? secondary = _cleanPhaseSecondary,
  String? eyebrow = _cleanPhaseEyebrow,
}) =>
    jsonEncode(<String, Object?>{
      'id': 'phase_content.fixture',
      'version': '1.0.0',
      'schema_id': phaseContentSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'phase.fixture.v1',
          'phase_id': 'waiting',
          'primary': primary,
          'secondary': ?secondary,
          'eyebrow': ?eyebrow,
          'surface': 'both',
        },
      ],
    });

String _dripPack({String body = _cleanDripBody}) =>
    jsonEncode(<String, Object?>{
      'id': 'drip.fixture',
      'version': '1.0.0',
      'schema_id': dripSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{'id': 'drip.fixture.v1', 'body': body},
      ],
    });

String _nudgesPack({
  String? title = _cleanNudgeTitle,
  String body = _cleanNudgeBody,
}) =>
    jsonEncode(<String, Object?>{
      'id': 'nudges.fixture',
      'version': '1.0.0',
      'schema_id': nudgesSchemaId,
      'locale': 'vi',
      'thresholds': <int>[5, 10],
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'nudge.fixture.v1',
          'slot': 'neutral',
          'title': ?title,
          'body': body,
        },
      ],
    });

List<PhaseContentViolation> _violations({
  String phasePrimary = _cleanPhasePrimary,
  String? phaseSecondary = _cleanPhaseSecondary,
  String phaseEyebrow = _cleanPhaseEyebrow,
  String dripBody = _cleanDripBody,
  String? nudgeTitle = _cleanNudgeTitle,
  String nudgeBody = _cleanNudgeBody,
}) =>
    validatePhaseContentPackages(
      phaseContent: _parsePhaseContent(
        _phaseContentPack(
          primary: phasePrimary,
          secondary: phaseSecondary,
          eyebrow: phaseEyebrow,
        ),
      ),
      drip: _parseDrip(_dripPack(body: dripBody)),
      nudges: _parseNudges(
        _nudgesPack(title: nudgeTitle, body: nudgeBody),
      ),
    );

List<InvariantRule> _rulesFrom(List<PhaseContentViolation> violations) =>
    violations
        .map((PhaseContentViolation v) => v.rule)
        .toList(growable: false);

final RegExp _singleQuoted = RegExp(r"'[^']*'");
final RegExp _doubleQuoted = RegExp(r'"[^"]*"');

/// Strips string literals and then line comments, so the scans below judge the
/// code a phase actually runs. A dartdoc that *names* a denylisted term while
/// explaining why the module must not redeclare it is prose, not a second copy
/// of the rules.
String _strippedDart(String source) => source
    .replaceAll(_singleQuoted, '')
    .replaceAll(_doubleQuoted, '')
    .split('\n')
    .map((String line) {
      final int marker = line.indexOf('//');
      return marker < 0 ? line : line.substring(0, marker);
    })
    .join('\n');

List<File> _phaseStatusDartFiles() =>
    Directory(_phaseStatusSourceDirectory)
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList(growable: false)
      ..sort((File a, File b) => a.path.compareTo(b.path));

void main() {
  group('the shipped packs pass the gate from disk (AC-37/AC-39)', () {
    late ContentPackage<PhaseContentItem> phaseContent;
    late ContentPackage<DripItem> drip;
    late ContentPackage<NudgeItem> nudges;

    setUp(() {
      phaseContent = _parsePhaseContent(
        File(phaseContentAssetKey).readAsStringSync(),
        label: phaseContentAssetKey,
      );
      drip = _parseDrip(
        File(dripAssetKey).readAsStringSync(),
        label: dripAssetKey,
      );
      nudges = _parseNudges(
        File(nudgesAssetKey).readAsStringSync(),
        label: nudgesAssetKey,
      );
    });

    test('all three packs exist on disk', () {
      expect(File(phaseContentAssetKey).existsSync(), isTrue);
      expect(File(dripAssetKey).existsSync(), isTrue);
      expect(File(nudgesAssetKey).existsSync(), isTrue);
    });

    test('the packs on disk report no violation', () {
      expect(
        validatePhaseContentPackages(
          phaseContent: phaseContent,
          drip: drip,
          nudges: nudges,
        ).map((PhaseContentViolation v) => v.toString()),
        isEmpty,
      );
    });

    test('every phase of the closed set ships at least one line', () {
      final Set<PhaseId> covered =
          phaseContent.items.map((PhaseContentItem i) => i.phaseId).toSet();
      for (final PhaseId id in PhaseId.values) {
        expect(covered, contains(id), reason: id.wireValue);
      }
    });

    test('every shipped phase line carries an eyebrow (D-10/AC-9)', () {
      for (final PhaseContentItem item in phaseContent.items) {
        expect(item.eyebrow.trim(), isNotEmpty, reason: item.id);
      }
    });

    test('a phase entry without an eyebrow fails to parse (D-10/AC-9)', () {
      expect(
        () => _parsePhaseContent(_phaseContentPack(eyebrow: null)),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.toString(),
            'message',
            contains('eyebrow'),
          ),
        ),
      );
      expect(
        () => _parsePhaseContent(_phaseContentPack(eyebrow: '')),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('every nudge slot of the closed set ships a body', () {
      final Set<NudgeSlot> covered =
          nudges.items.map((NudgeItem i) => i.slot).toSet();
      for (final NudgeSlot slot in NudgeSlot.values) {
        expect(covered, contains(slot), reason: slot.wireValue);
      }
    });

    test('an empty drip pack is a legal shipped state (AC-38/BR-16)', () {
      final ContentPackage<DripItem> empty = _parseDrip(
        jsonEncode(<String, Object?>{
          'id': 'drip.fixture',
          'version': '1.0.0',
          'schema_id': dripSchemaId,
          'items': <Object?>[],
        }),
      );

      expect(
        validatePhaseContentPackages(
          phaseContent: phaseContent,
          drip: empty,
          nudges: nudges,
        ),
        isEmpty,
      );
    });
  });

  group('the gate rejects a violating line (AC-39/BR-17)', () {
    test('a clean set of packs reports nothing', () {
      expect(_violations(), isEmpty);
    });

    test('every InvariantRule is caught in a phase line', () {
      for (final MapEntry<InvariantRule, List<String>> entry
          in invariantDeniedTerms.entries) {
        for (final String term in entry.value) {
          expect(
            _rulesFrom(_violations(phasePrimary: 'Hôm nay bạn $term rồi')),
            contains(entry.key),
            reason: '${entry.key.wireValue}: $term',
          );
        }
      }
    });

    test('every InvariantRule is caught in a drip body', () {
      for (final MapEntry<InvariantRule, List<String>> entry
          in invariantDeniedTerms.entries) {
        for (final String term in entry.value) {
          expect(
            _rulesFrom(_violations(dripBody: 'Kho của bạn $term hơn')),
            contains(entry.key),
            reason: '${entry.key.wireValue}: $term',
          );
        }
      }
    });

    test('every InvariantRule is caught in a nudge body', () {
      for (final MapEntry<InvariantRule, List<String>> entry
          in invariantDeniedTerms.entries) {
        for (final String term in entry.value) {
          expect(
            _rulesFrom(_violations(nudgeBody: 'Nhắc bạn về $term nhé')),
            contains(entry.key),
            reason: '${entry.key.wireValue}: $term',
          );
        }
      }
    });

    test('a "%" figure is caught wherever it appears', () {
      expect(
        _rulesFrom(_violations(phasePrimary: 'Bạn đã đi được 40% chặng')),
        contains(InvariantRule.percentDisplay),
      );
      expect(
        _rulesFrom(_violations(phaseSecondary: 'Còn 60% nữa')),
        contains(InvariantRule.percentDisplay),
      );
      expect(
        _rulesFrom(_violations(dripBody: 'Kho của bạn đầy 80%')),
        contains(InvariantRule.percentDisplay),
      );
      expect(
        _rulesFrom(_violations(nudgeTitle: 'Đã xong 90%')),
        contains(InvariantRule.percentDisplay),
      );
      expect(
        _rulesFrom(_violations(nudgeBody: 'Còn 10% nữa thôi')),
        contains(InvariantRule.percentDisplay),
      );
    });

    test('the violation names the pack and the item that carries it', () {
      final List<PhaseContentViolation> violations =
          _violations(dripBody: 'Bạn giữ chuỗi ngày rất tốt');

      expect(violations, hasLength(1));
      expect(violations.single.packageId, 'drip.fixture');
      expect(violations.single.itemId, 'drip.fixture.v1');
      expect(violations.single.rule, InvariantRule.streakDisplay);
      expect(violations.single.toString(), contains('streak_display'));
    });

    test('an absent optional string is not a violation', () {
      expect(
        _violations(phaseSecondary: null, nudgeTitle: null),
        isEmpty,
      );
    });

    test('the eyebrow is scanned like any other display string (D-10)', () {
      for (final MapEntry<InvariantRule, List<String>> entry
          in invariantDeniedTerms.entries) {
        for (final String term in entry.value) {
          expect(
            _rulesFrom(_violations(phaseEyebrow: 'PHA 1 · $term')),
            contains(entry.key),
            reason: '${entry.key.wireValue}: $term',
          );
        }
      }
      expect(
        _rulesFrom(_violations(phaseEyebrow: 'PHA 1 · 40% ĐANG ĐỢI')),
        contains(InvariantRule.percentDisplay),
      );
    });
  });

  group('the gate does not carry a second copy of the rules (R-15c/D-15)', () {
    test('no phase_status source redeclares an invariant term', () {
      final List<String> offenders = <String>[];

      for (final File file in _phaseStatusDartFiles()) {
        final String haystack =
            _strippedDart(file.readAsStringSync()).toLowerCase();
        for (final List<String> terms in invariantDeniedTerms.values) {
          for (final String term in terms) {
            if (_standaloneTerm(term).hasMatch(haystack)) {
              offenders.add('${file.path}: "$term"');
            }
          }
        }
      }

      expect(offenders, isEmpty);
    });

    test('no phase_status source reads a package length (AC-38/BR-16)', () {
      final RegExp lengthRead = RegExp(
        r'(items|package|phaseContent|drip|nudges|thresholds)\s*\.\s*length',
        caseSensitive: false,
      );
      final List<String> offenders = <String>[
        for (final File file in _phaseStatusDartFiles())
          if (lengthRead.hasMatch(_strippedDart(file.readAsStringSync())))
            file.path,
      ];

      expect(offenders, isEmpty);
    });

    test('no phase_status source reaches the network or a model (AC-34)', () {
      final RegExp forbidden = RegExp(
        r'\b(http|https|Dio|HttpClient|openai|anthropic|gemini)\b',
        caseSensitive: false,
      );
      final List<String> offenders = <String>[
        for (final File file in _phaseStatusDartFiles())
          if (forbidden.hasMatch(_strippedDart(file.readAsStringSync())))
            file.path,
      ];

      expect(offenders, isEmpty);
    });
  });
}
