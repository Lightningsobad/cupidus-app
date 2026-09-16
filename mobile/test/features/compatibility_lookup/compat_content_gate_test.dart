import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/compatibility_lookup/domain/compat_content.dart';
import 'package:cupid_mobile/features/compatibility_lookup/domain/compat_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

const String _fixtureBandId = 'band.fixture';
const List<String> _fixtureAxisIds = <String>['alpha', 'beta'];

const String _fixtureFit =
    'Hai bên cùng thích lên kế hoạch trước, nên buổi hẹn ít khi lỡ.';
const String _fixtureFriction =
    'Cùng ngại nói thẳng nên chuyện chưa vừa ý dễ bị để đó.';
const String _fixtureActivity =
    'Chọn một việc nhỏ hai người cùng làm trong một buổi tối.';
const String _fixtureQuestion =
    'Có chuyện gì bạn muốn nói với mình mà vẫn đang để đó không?';

ContentPackage<CompatBand> _parseBands(
  String source, {
  String label = '<fixture>',
}) =>
    ContentPackage.parse<CompatBand>(
      source,
      expectedSchemaId: compatBandsSchemaId,
      itemParser: compatBandFromJson,
      source: label,
    );

ContentPackage<CompatItem> _parseLookup(
  String source, {
  String expectedSchemaId = compatZodiacSchemaId,
  String label = '<fixture>',
}) =>
    ContentPackage.parse<CompatItem>(
      source,
      expectedSchemaId: expectedSchemaId,
      itemParser: compatItemFromJson,
      source: label,
    );

String _bandsPack({
  Map<String, Object?> firstBandOverrides = const <String, Object?>{},
}) =>
    jsonEncode(<String, Object?>{
      'id': 'compat_bands.fixture',
      'version': '1.0.0',
      'schema_id': compatBandsSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': _fixtureBandId,
          'label': 'Dễ bắt nhịp',
          ...firstBandOverrides,
        },
      ],
    });

/// A lookup pack that covers every ordered pair of [axisIds], so a test only
/// has to describe the one thing it breaks. Overrides land on the first cell.
String _lookupPack({
  List<String> axisIds = _fixtureAxisIds,
  String bandId = _fixtureBandId,
  Map<String, Object?> firstCellOverrides = const <String, Object?>{},
  Map<String, Object?> firstAxisOverrides = const <String, Object?>{},
  List<String> dropPairIds = const <String>[],
  List<Map<String, Object?>> extraItems = const <Map<String, Object?>>[],
  String schemaId = compatZodiacSchemaId,
}) {
  final List<Map<String, Object?>> items = <Map<String, Object?>>[];

  bool firstAxis = true;
  for (final String axisId in axisIds) {
    items.add(<String, Object?>{
      'id': axisId,
      'kind': 'axis_value',
      'label': 'Nhãn $axisId',
      ...firstAxis ? firstAxisOverrides : const <String, Object?>{},
    });
    firstAxis = false;
  }

  bool firstCell = true;
  for (final String selfId in axisIds) {
    for (final String partnerId in axisIds) {
      final String pairId = '${selfId}__$partnerId';
      if (dropPairIds.contains(pairId)) {
        continue;
      }
      items.add(<String, Object?>{
        'id': pairId,
        'kind': 'cell',
        'self_id': selfId,
        'partner_id': partnerId,
        'band_id': bandId,
        'fit': _fixtureFit,
        'friction': _fixtureFriction,
        'activity': _fixtureActivity,
        'question': _fixtureQuestion,
        ...firstCell ? firstCellOverrides : const <String, Object?>{},
      });
      firstCell = false;
    }
  }

  items.addAll(extraItems);

  return jsonEncode(<String, Object?>{
    'id': 'compat_lookup.fixture',
    'version': '1.0.0',
    'schema_id': schemaId,
    'locale': 'vi',
    'items': items,
  });
}

/// Runs the gate over a clean band pack, a zodiac pack the test may break, and
/// a clean MBTI pack.
List<CompatViolation> _violations({
  Map<String, Object?> firstBandOverrides = const <String, Object?>{},
  List<String> axisIds = _fixtureAxisIds,
  String bandId = _fixtureBandId,
  Map<String, Object?> firstCellOverrides = const <String, Object?>{},
  Map<String, Object?> firstAxisOverrides = const <String, Object?>{},
  List<String> dropPairIds = const <String>[],
  List<Map<String, Object?>> extraItems = const <Map<String, Object?>>[],
}) =>
    validateCompatPacks(
      bands: _parseBands(_bandsPack(firstBandOverrides: firstBandOverrides)),
      zodiac: _parseLookup(
        _lookupPack(
          axisIds: axisIds,
          bandId: bandId,
          firstCellOverrides: firstCellOverrides,
          firstAxisOverrides: firstAxisOverrides,
          dropPairIds: dropPairIds,
          extraItems: extraItems,
        ),
      ),
      mbti: _parseLookup(
        _lookupPack(schemaId: compatMbtiSchemaId),
        expectedSchemaId: compatMbtiSchemaId,
      ),
    );

List<CompatGateRule> _rulesFrom(List<CompatViolation> violations) =>
    violations.map((CompatViolation v) => v.rule).toList(growable: false);

final RegExp _singleQuoted = RegExp(r"'[^']*'");
final RegExp _doubleQuoted = RegExp(r'"[^"]*"');

/// The axis-count literals AC-36 forbids in `lib/`. They are written as strings
/// so this list is not itself a hardcoded count.
const List<String> _forbiddenAxisLiterals = <String>['12', '16', '144', '256'];

final RegExp _forbiddenAxisLiteral = RegExp(
  '(?<![\\w.])(${_forbiddenAxisLiterals.join('|')})(?![\\w.])',
);

/// Removes string literals first, then line comments, so an asset key such as
/// `assets/data/req016/...` is not mistaken for a hardcoded axis size.
String _strippedDart(String source) => source
    .replaceAll(_singleQuoted, '')
    .replaceAll(_doubleQuoted, '')
    .split('\n')
    .map((String line) {
      final int marker = line.indexOf('//');
      return marker < 0 ? line : line.substring(0, marker);
    })
    .join('\n');

List<File> _compatFeatureDartFiles() =>
    Directory('lib/features/compatibility_lookup')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList(growable: false);

void main() {
  group('the shipped packs pass the gate from disk (AC-37/AC-38)', () {
    late ContentPackage<CompatBand> bands;
    late ContentPackage<CompatItem> zodiac;
    late ContentPackage<CompatItem> mbti;

    setUp(() {
      bands = _parseBands(
        File(compatBandsAssetKey).readAsStringSync(),
        label: compatBandsAssetKey,
      );
      zodiac = _parseLookup(
        File(compatZodiacAssetKey).readAsStringSync(),
        label: compatZodiacAssetKey,
      );
      mbti = _parseLookup(
        File(compatMbtiAssetKey).readAsStringSync(),
        expectedSchemaId: compatMbtiSchemaId,
        label: compatMbtiAssetKey,
      );
    });

    test('all three packs exist on disk and are not empty', () {
      expect(File(compatBandsAssetKey).existsSync(), isTrue);
      expect(File(compatZodiacAssetKey).existsSync(), isTrue);
      expect(File(compatMbtiAssetKey).existsSync(), isTrue);
      expect(bands.items, isNotEmpty);
      expect(zodiac.items, isNotEmpty);
      expect(mbti.items, isNotEmpty);
    });

    test('the packs on disk report no violation', () {
      expect(
        validateCompatPacks(bands: bands, zodiac: zodiac, mbti: mbti)
            .map((CompatViolation v) => v.toString()),
        isEmpty,
      );
    });

    test('each shipped pack covers every ordered pair of its own axis (AC-38)',
        () {
      for (final ContentPackage<CompatItem> pack in <ContentPackage<CompatItem>>[
        zodiac,
        mbti,
      ]) {
        final List<String> axisIds = pack.items
            .whereType<CompatAxisValue>()
            .map((CompatAxisValue v) => v.id)
            .toList(growable: false);
        final List<CompatCell> cells =
            pack.items.whereType<CompatCell>().toList(growable: false);

        expect(axisIds.length, greaterThanOrEqualTo(2), reason: pack.id);
        expect(cells.length, axisIds.length * axisIds.length, reason: pack.id);

        for (final String selfId in axisIds) {
          for (final String partnerId in axisIds) {
            expect(
              lookupCell(pack, selfId: selfId, partnerId: partnerId),
              isNotNull,
              reason: '${pack.id}/$selfId vs $partnerId',
            );
          }
        }
      }
    });

    test('a pair is ordered: the two directions are different cells (BR-2)', () {
      final CompatCell? forward =
          lookupCell(zodiac, selfId: 'aries', partnerId: 'taurus');
      final CompatCell? reverse =
          lookupCell(zodiac, selfId: 'taurus', partnerId: 'aries');

      expect(forward, isNotNull);
      expect(reverse, isNotNull);
      expect(forward!.id, isNot(reverse!.id));
      expect(forward.fit, isNot(reverse.fit));
      expect(forward.friction, isNot(reverse.friction));
      expect(forward.question, isNot(reverse.question));
    });

    test('an unknown pair resolves to nothing rather than to a neighbour', () {
      expect(
        lookupCell(zodiac, selfId: 'aries', partnerId: 'ophiuchus'),
        isNull,
      );
      expect(lookupCell(zodiac, selfId: 'intj', partnerId: 'enfp'), isNull);
    });

    test('every shipped cell carries the full quartet and asks at the end',
        () {
      final List<CompatCell> cells = <CompatCell>[
        ...zodiac.items.whereType<CompatCell>(),
        ...mbti.items.whereType<CompatCell>(),
      ];

      expect(cells, isNotEmpty);
      for (final CompatCell cell in cells) {
        for (final String text in cell.quartet) {
          expect(text.trim(), isNotEmpty, reason: cell.id);
        }
        expect(cell.question.trim().endsWith('?'), isTrue, reason: cell.id);
      }
    });

    test('no cell wording is written into a Dart or l10n file (R-15a/R-15b)',
        () {
      final List<String> authored = <String>[
        for (final CompatCell cell in zodiac.items.whereType<CompatCell>())
          ...cell.quartet,
        for (final CompatCell cell in mbti.items.whereType<CompatCell>())
          ...cell.quartet,
        for (final CompatBand band in bands.items) band.label,
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

  group('the axis size is data, never a compile-time constant (AC-36)', () {
    test('the literal scan itself can tell a count from an asset key', () {
      expect(
        _forbiddenAxisLiteral.hasMatch(_strippedDart('const int axis = 12;')),
        isTrue,
      );
      expect(
        _forbiddenAxisLiteral
            .hasMatch(_strippedDart("const String k = 'req016/a'; // 16")),
        isFalse,
      );
    });

    test('no Dart file in the feature hardcodes an axis size', () {
      final List<File> files = _compatFeatureDartFiles();
      final List<String> offenders = <String>[];

      for (final File file in files) {
        final String stripped = _strippedDart(file.readAsStringSync());
        for (final RegExpMatch match
            in _forbiddenAxisLiteral.allMatches(stripped)) {
          offenders.add('${file.path} hardcodes "${match.group(0)}"');
        }
      }

      expect(files, isNotEmpty);
      expect(offenders, isEmpty);
    });

    test('widening the axis needs no code change', () {
      final List<CompatViolation> wider = validateCompatPacks(
        bands: _parseBands(_bandsPack()),
        zodiac: _parseLookup(
          _lookupPack(axisIds: const <String>['alpha', 'beta', 'gamma']),
        ),
        mbti: _parseLookup(
          _lookupPack(schemaId: compatMbtiSchemaId),
          expectedSchemaId: compatMbtiSchemaId,
        ),
      );

      expect(wider, isEmpty);
    });
  });

  group('parser rules run before the gate sees a package', () {
    test('the fixture baseline is clean, so every red below is the one break',
        () {
      expect(_violations(), isEmpty);
    });

    test('a cell without a friction point is a parse error, not a variant', () {
      expect(
        () => _parseLookup(
          _lookupPack(firstCellOverrides: <String, Object?>{'friction': null}),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('field "friction" must be a non-empty string'),
          ),
        ),
      );
    });

    test('a cell missing the closing question is a parse error', () {
      expect(
        () => _parseLookup(
          _lookupPack(firstCellOverrides: <String, Object?>{'question': null}),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('field "question" must be a non-empty string'),
          ),
        ),
      );
    });

    test('an unknown item kind is a parse error, not a default', () {
      expect(
        () => _parseLookup(
          _lookupPack(firstAxisOverrides: <String, Object?>{'kind': 'score'}),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported kind "score"'),
          ),
        ),
      );
    });

    test('a pack under another schema id is rejected at load', () {
      expect(
        () => _parseLookup(_lookupPack(schemaId: compatMbtiSchemaId)),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('does not match the expected "req016.compat_zodiac.v1"'),
          ),
        ),
      );
    });
  });

  group('coverage must be complete, with n read from the data (AC-36/AC-38)',
      () {
    test('a missing ordered pair is a violation', () {
      final List<CompatViolation> violations =
          _violations(dropPairIds: const <String>['beta__alpha']);

      expect(_rulesFrom(violations), contains(CompatGateRule.coverageGap));
      expect(
        violations.map((CompatViolation v) => v.itemId),
        contains('beta__alpha'),
      );
    });

    test('a cell pointing at an axis value the pack never declares', () {
      final List<CompatViolation> violations = _violations(
        extraItems: <Map<String, Object?>>[
          <String, Object?>{
            'id': 'gamma__alpha',
            'kind': 'cell',
            'self_id': 'gamma',
            'partner_id': 'alpha',
            'band_id': _fixtureBandId,
            'fit': _fixtureFit,
            'friction': _fixtureFriction,
            'activity': _fixtureActivity,
            'question': _fixtureQuestion,
          },
        ],
      );

      expect(_rulesFrom(violations), contains(CompatGateRule.coverageGap));
      expect(
        violations
            .where((CompatViolation v) => v.itemId == 'gamma__alpha')
            .map((CompatViolation v) => v.detail)
            .join(),
        contains('does not declare'),
      );
    });

    test('two cells claiming the same ordered pair is a violation', () {
      final List<CompatViolation> violations = _violations(
        extraItems: <Map<String, Object?>>[
          <String, Object?>{
            'id': 'alpha__alpha.duplicate',
            'kind': 'cell',
            'self_id': 'alpha',
            'partner_id': 'alpha',
            'band_id': _fixtureBandId,
            'fit': _fixtureFit,
            'friction': _fixtureFriction,
            'activity': _fixtureActivity,
            'question': _fixtureQuestion,
          },
        ],
      );

      expect(_rulesFrom(violations), contains(CompatGateRule.coverageGap));
      expect(
        violations
            .where((CompatViolation v) => v.rule == CompatGateRule.coverageGap)
            .map((CompatViolation v) => v.detail)
            .join(),
        contains('a second cell claims the ordered pair "alpha__alpha"'),
      );
    });
  });

  group('no number may reach the data layer (AC-37c)', () {
    test('a numeric field on a cell', () {
      final List<CompatViolation> violations =
          _violations(firstCellOverrides: <String, Object?>{'weight': 3});

      expect(_rulesFrom(violations), contains(CompatGateRule.numberInContent));
      expect(
        violations
            .where(
              (CompatViolation v) => v.rule == CompatGateRule.numberInContent,
            )
            .map((CompatViolation v) => v.detail)
            .join(),
        contains('"weight"'),
      );
    });

    test('a number nested inside a list', () {
      final List<CompatViolation> violations = _violations(
        firstCellOverrides: <String, Object?>{
          'tags': <Object?>[
            'a',
            <String, Object?>{'score': 0.8},
          ],
        },
      );

      expect(_rulesFrom(violations), contains(CompatGateRule.numberInContent));
      expect(
        violations
            .where(
              (CompatViolation v) => v.rule == CompatGateRule.numberInContent,
            )
            .map((CompatViolation v) => v.detail)
            .join(),
        contains('tags[1].score'),
      );
    });

    test('an ordering field on a band, which is what turns a label into a scale',
        () {
      expect(
        _rulesFrom(_violations(firstBandOverrides: <String, Object?>{'order': 1})),
        contains(CompatGateRule.numberInContent),
      );
    });
  });

  group('the quartet is structural, not editorial (AC-12/AC-37b/AC-37e)', () {
    test('a whitespace-only friction point', () {
      final List<CompatViolation> violations =
          _violations(firstCellOverrides: <String, Object?>{'friction': '   '});

      expect(
        _rulesFrom(violations),
        contains(CompatGateRule.missingQuartetField),
      );
      expect(
        violations
            .where(
              (CompatViolation v) =>
                  v.rule == CompatGateRule.missingQuartetField,
            )
            .map((CompatViolation v) => v.detail)
            .join(),
        contains('"friction"'),
      );
    });

    test('a whitespace-only activity', () {
      expect(
        _rulesFrom(
          _violations(firstCellOverrides: <String, Object?>{'activity': ' '}),
        ),
        contains(CompatGateRule.missingQuartetField),
      );
    });

    test('a closing line that states a verdict instead of asking', () {
      expect(
        _rulesFrom(
          _violations(
            firstCellOverrides: <String, Object?>{
              'question': 'Hai người này hợp nhau về lâu dài.',
            },
          ),
        ),
        contains(CompatGateRule.questionWithoutAsk),
      );
    });
  });

  group('cross-pack ids and the id convention must hold', () {
    test('a band_id the band pack does not declare', () {
      final List<CompatViolation> violations =
          _violations(bandId: 'band.khong_ton_tai');

      expect(_rulesFrom(violations), contains(CompatGateRule.unknownBandId));
      expect(
        violations
            .where((CompatViolation v) => v.rule == CompatGateRule.unknownBandId)
            .map((CompatViolation v) => v.detail)
            .join(),
        contains('band_id "band.khong_ton_tai"'),
      );
    });

    test('a cell id that does not match its own ordered pair', () {
      final List<CompatViolation> violations = _violations(
        firstCellOverrides: <String, Object?>{'partner_id': 'beta'},
      );

      expect(_rulesFrom(violations), contains(CompatGateRule.cellIdMismatch));
      expect(
        violations
            .where(
              (CompatViolation v) => v.rule == CompatGateRule.cellIdMismatch,
            )
            .map((CompatViolation v) => v.detail)
            .join(),
        contains('derives the id "alpha__beta"'),
      );
    });
  });

  group('the shared invariant rules fire on compat packs too (R-15c)', () {
    test('flattery', () {
      expect(
        _rulesFrom(
          _violations(
            firstCellOverrides: <String, Object?>{
              'fit': 'Người kia hoàn hảo với bạn ở gần như mọi mặt.',
            },
          ),
        ),
        contains(CompatGateRule.flattery),
      );
    });

    test('a percentage figure (AC-37c)', () {
      expect(
        _rulesFrom(
          _violations(
            firstCellOverrides: <String, Object?>{
              'fit': 'Hai người hợp nhau tới 80% về nhịp sinh hoạt.',
            },
          ),
        ),
        contains(CompatGateRule.percentDisplay),
      );
    });

    test('a score or ranking (AC-37c)', () {
      expect(
        _rulesFrom(
          _violations(
            firstCellOverrides: <String, Object?>{
              'fit': 'Cặp này xếp hạng cao trong các cặp cùng nhóm.',
            },
          ),
        ),
        contains(CompatGateRule.scoreOrRatio),
      );
    });

    test('a streak (AC-37d)', () {
      expect(
        _rulesFrom(
          _violations(
            firstCellOverrides: <String, Object?>{
              'activity': 'Giữ chuỗi ngày nhắn tin cho nhau không đứt.',
            },
          ),
        ),
        contains(CompatGateRule.streakDisplay),
      );
    });

    test('a recipient-behaviour indicator (AC-37a)', () {
      expect(
        _rulesFrom(
          _violations(
            firstCellOverrides: <String, Object?>{
              'friction': 'Người kia hay để tin nhắn đã xem mà không trả lời.',
            },
          ),
        ),
        contains(CompatGateRule.recipientBehaviour),
      );
    });

    test('a band label is scanned too, not only a cell', () {
      expect(
        _rulesFrom(
          _violations(
            firstBandOverrides: <String, Object?>{'label': 'Thứ hạng cao'},
          ),
        ),
        contains(CompatGateRule.scoreOrRatio),
      );
    });

    test('an axis label is scanned too', () {
      expect(
        _rulesFrom(
          _violations(
            firstAxisOverrides: <String, Object?>{'label': 'Nhóm tuyệt vời'},
          ),
        ),
        contains(CompatGateRule.flattery),
      );
    });
  });

  group('the notebook boundary is read one key at a time (AC-37a)', () {
    test('a how-often claim about the other person is a violation', () {
      expect(
        _rulesFrom(
          _violations(
            firstCellOverrides: <String, Object?>{
              'friction': 'Người kia không nhắn lại thường xuyên như bạn mong.',
            },
          ),
        ),
        contains(CompatGateRule.frequencyProbe),
      );
    });

    test('the judgement-probe terms are the legitimate subject here', () {
      // Wiring `notebookBoundaryHitsIn` whole would fire on every one of these
      // and make the gate unpassable rather than strict.
      expect(
        _rulesFrom(
          _violations(
            firstCellOverrides: <String, Object?>{
              'fit': 'Điểm mạnh của hai bên là cùng chịu khó nói rõ ý mình.',
              'friction': 'Tính cách của hai bên đều ngại nhường trước.',
              'question': 'Điểm yếu nào của mình bạn thấy khó chịu nhất?',
            },
          ),
        ),
        isEmpty,
      );
    });
  });
}
