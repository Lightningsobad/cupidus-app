import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/content/invariant_terms.dart';
import 'package:cupid_mobile/features/before_you_go/domain/before_you_go_content.dart';
import 'package:cupid_mobile/features/before_you_go/domain/before_you_go_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _hintJson({
  String id = 'cash',
  Object? order = 10,
  Object? labelVi = 'Mang đủ tiền mặt',
  Object? icon = 'payments',
  String? action,
  Object? when,
  Map<String, Object?> extraKeys = const <String, Object?>{},
}) =>
    <String, Object?>{
      'id': id,
      'order': order,
      'labelVi': labelVi,
      'icon': icon,
      'action': ?action,
      'when': when ??
          <Map<String, Object?>>[
            <String, Object?>{'field': 'priceVnd', 'op': 'gt', 'value': 0},
          ],
      ...extraKeys,
    };

String _packJson({
  List<Map<String, Object?>>? items,
  List<Map<String, Object?>>? regions,
  String schemaId = beforeYouGoSchemaId,
}) =>
    jsonEncode(<String, Object?>{
      'id': 'before_you_go.fixture',
      'version': '1.0.0',
      'schema_id': schemaId,
      'locale': 'vi',
      'items': items ?? <Map<String, Object?>>[_hintJson()],
      'regions': regions ??
          <Map<String, Object?>>[
            <String, Object?>{
              'id': 'bac',
              'aliases': <String>['ha noi'],
              'rainyMonths': <int>[5, 6],
            },
          ],
    });

ChecklistHint _hint({
  String id = 'cash',
  int order = 10,
  String labelVi = 'Mang đủ tiền mặt',
  String icon = 'payments',
  List<HintClause>? when,
}) =>
    ChecklistHint(
      id: id,
      order: order,
      labelVi: labelVi,
      icon: icon,
      when: when ??
          const <HintClause>[
            HintClause(field: HintFact.always, op: HintOp.isTrue),
          ],
    );

ContentPackage<ChecklistHint> _package(List<ChecklistHint> items) =>
    ContentPackage<ChecklistHint>(
      id: 'before_you_go.fixture',
      version: '1.0.0',
      schemaId: beforeYouGoSchemaId,
      items: items,
    );

const List<RegionEntry> _cleanRegions = <RegionEntry>[
  RegionEntry(
    id: 'bac',
    aliases: <String>['ha noi'],
    rainyMonths: <int>[5, 6],
  ),
];

List<BeforeYouGoGateRule> _rulesFor(
  ChecklistHint hint, {
  List<RegionEntry> regions = _cleanRegions,
}) =>
    validateBeforeYouGoPack(
      hints: _package(<ChecklistHint>[hint]),
      regions: regions,
    ).map((BeforeYouGoViolation v) => v.rule).toList(growable: false);

void main() {
  group('the shipped pack passes the gate from disk (AC-29/AC-31/BR-17)', () {
    late BeforeYouGoPack pack;

    setUp(() {
      pack = parseBeforeYouGoPack(
        File(beforeYouGoAssetKey).readAsStringSync(),
        source: beforeYouGoAssetKey,
      );
    });

    test('the pack exists on disk and parses under the pinned schema id', () {
      expect(File(beforeYouGoAssetKey).existsSync(), isTrue);
      expect(pack.hints.schemaId, 'req016.before_you_go.v1');
      expect(pack.hints.items, isNotEmpty);
      expect(pack.regions, isNotEmpty);
    });

    test('every shipped row id is unique and ASCII', () {
      final List<String> ids =
          pack.hints.items.map((ChecklistHint h) => h.id).toList();

      expect(ids.toSet().length, ids.length);
      for (final String id in ids) {
        expect(RegExp(r'^[a-z0-9_]+$').hasMatch(id), isTrue, reason: id);
      }
    });

    test('the pack on disk reports no violation', () {
      expect(
        validateBeforeYouGoPack(hints: pack.hints, regions: pack.regions)
            .map((BeforeYouGoViolation v) => v.toString()),
        isEmpty,
      );
    });

    test('the distance threshold is data, not a Dart constant', () {
      final ChecklistHint? fuel = pack.hints.itemById('fuel');

      expect(fuel, isNotNull);
      expect(
        fuel!.when
            .where((HintClause c) => c.field == HintFact.distanceKm)
            .map((HintClause c) => c.value),
        isNotEmpty,
      );
    });

    test('no shipped row label is written into any Dart file (AC-29/BR-15)',
        () {
      final List<String> authored =
          pack.hints.items.map((ChecklistHint h) => h.labelVi).toList();
      final List<String> offenders = <String>[];

      for (final FileSystemEntity entity
          in Directory('lib/features/before_you_go').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final String source = entity.readAsStringSync();
        for (final String label in authored) {
          if (source.contains(label)) {
            offenders.add('${entity.path} contains "$label"');
          }
        }
      }

      expect(authored, isNotEmpty);
      expect(offenders, isEmpty);
    });

    test('every shared invariant rule has a name in this gate (D-15)', () {
      final Set<String> gateWireValues = BeforeYouGoGateRule.values
          .map((BeforeYouGoGateRule r) => r.wireValue)
          .toSet();

      for (final InvariantRule rule in InvariantRule.values) {
        expect(gateWireValues, contains(rule.wireValue));
      }
    });
  });

  group('the closed DSL is enforced at load, never defaulted', () {
    test('an unsupported fact throws', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(
            items: <Map<String, Object?>>[
              _hintJson(
                when: <Map<String, Object?>>[
                  <String, Object?>{
                    'field': 'priceVND',
                    'op': 'gt',
                    'value': 0,
                  },
                ],
              ),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported fact "priceVND"'),
          ),
        ),
      );
    });

    test('an unsupported operator throws', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(
            items: <Map<String, Object?>>[
              _hintJson(
                when: <Map<String, Object?>>[
                  <String, Object?>{
                    'field': 'priceVnd',
                    'op': 'greaterThan',
                    'value': 0,
                  },
                ],
              ),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported operator "greaterThan"'),
          ),
        ),
      );
    });

    test('an unsupported action throws', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(
            items: <Map<String, Object?>>[_hintJson(action: 'shareLocation')],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported action "shareLocation"'),
          ),
        ),
      );
    });

    test('an unknown item key is a schema error, not an ignored extra', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(
            items: <Map<String, Object?>>[
              _hintJson(
                extraKeys: const <String, Object?>{'price_vnd': 1000},
              ),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unknown key "price_vnd"'),
          ),
        ),
      );
    });

    test('an unknown clause key is a schema error', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(
            items: <Map<String, Object?>>[
              _hintJson(
                when: <Map<String, Object?>>[
                  <String, Object?>{
                    'field': 'priceVnd',
                    'op': 'gt',
                    'value': 0,
                    'unit': 'vnd',
                  },
                ],
              ),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unknown key "unit"'),
          ),
        ),
      );
    });

    test('an empty "when" is a schema error', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(
            items: <Map<String, Object?>>[
              _hintJson(when: <Map<String, Object?>>[]),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('at least one clause'),
          ),
        ),
      );
    });

    test('a unary operator carrying a value is a schema error', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(
            items: <Map<String, Object?>>[
              _hintJson(
                when: <Map<String, Object?>>[
                  <String, Object?>{
                    'field': 'needsBooking',
                    'op': 'isTrue',
                    'value': true,
                  },
                ],
              ),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('takes none'),
          ),
        ),
      );
    });

    test('a comparison without a number is a schema error', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(
            items: <Map<String, Object?>>[
              _hintJson(
                when: <Map<String, Object?>>[
                  <String, Object?>{
                    'field': 'distanceKm',
                    'op': 'gte',
                    'value': 'xa',
                  },
                ],
              ),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('number value'),
          ),
        ),
      );
    });

    test('a non-integer order is a schema error', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(items: <Map<String, Object?>>[_hintJson(order: '10')]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('"order" must be an integer'),
          ),
        ),
      );
    });

    test('a pack under another schema id is rejected at load', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(schemaId: 'req016.before_you_go.v2'),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('does not match the expected "req016.before_you_go.v1"'),
          ),
        ),
      );
    });

    test('a duplicate row id is rejected at load', () {
      expect(
        () => parseBeforeYouGoPack(
          _packJson(
            items: <Map<String, Object?>>[_hintJson(), _hintJson()],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('duplicate item id "cash"'),
          ),
        ),
      );
    });
  });

  group('negative control: the gate rejects a violating row (AC-31)', () {
    test('flattery', () {
      expect(
        _rulesFor(_hint(labelVi: 'Mặc đồ cho thật xinh')),
        contains(BeforeYouGoGateRule.flattery),
      );
    });

    test('a percentage figure', () {
      expect(
        _rulesFor(_hint(labelVi: 'Chuẩn bị xong 80% đầu việc')),
        contains(BeforeYouGoGateRule.percentDisplay),
      );
    });

    test('a streak or day chain', () {
      expect(
        _rulesFor(_hint(labelVi: 'Giữ chuỗi ngày chuẩn bị đầy đủ')),
        contains(BeforeYouGoGateRule.streakDisplay),
      );
    });

    test('a score or ratio', () {
      expect(
        _rulesFor(_hint(labelVi: 'Xem điểm số buổi hẹn')),
        contains(BeforeYouGoGateRule.scoreOrRatio),
      );
    });

    test('a recipient-behaviour indicator', () {
      expect(
        _rulesFor(_hint(labelVi: 'Kiểm tra xem lời mời đã xem chưa')),
        contains(BeforeYouGoGateRule.recipientBehaviour),
      );
    });

    test('a manipulative tone', () {
      expect(
        _rulesFor(_hint(labelVi: 'Chuẩn bị chiêu mở đầu')),
        contains(BeforeYouGoGateRule.manipulativeTone),
      );
    });

    test('counting how many times the checklist was finished (AC-27)', () {
      expect(
        _rulesFor(_hint(labelVi: 'Ghi lại số lần chuẩn bị đủ')),
        contains(BeforeYouGoGateRule.completionCount),
      );
    });

    test('content with a tone about the other person (BR-14)', () {
      expect(
        _rulesFor(_hint(labelVi: 'Chuẩn bị câu mở đầu gây ấn tượng')),
        contains(BeforeYouGoGateRule.partnerDirectedTone),
      );
    });

    test('the violation names the offending row', () {
      final List<BeforeYouGoViolation> violations = validateBeforeYouGoPack(
        hints: _package(<ChecklistHint>[
          _hint(),
          _hint(id: 'bad_row', labelVi: 'Mặc đồ cho thật xinh'),
        ]),
        regions: _cleanRegions,
      );

      expect(
        violations.map((BeforeYouGoViolation v) => v.itemId),
        <String>['bad_row'],
      );
    });

    test('a non-ASCII row id', () {
      expect(
        _rulesFor(_hint(id: 'tiền_mặt')),
        contains(BeforeYouGoGateRule.invalidItemId),
      );
    });

    test('a duplicate row id reaching the gate directly', () {
      final List<BeforeYouGoViolation> violations = validateBeforeYouGoPack(
        hints: _package(<ChecklistHint>[_hint(), _hint()]),
        regions: _cleanRegions,
      );

      expect(
        violations.map((BeforeYouGoViolation v) => v.rule),
        contains(BeforeYouGoGateRule.duplicateItemId),
      );
    });

    test('a blank label', () {
      expect(
        _rulesFor(_hint(labelVi: '   ')),
        contains(BeforeYouGoGateRule.emptyLabel),
      );
    });

    test('a label past the one-glance limit', () {
      expect(
        _rulesFor(_hint(labelVi: 'a' * (beforeYouGoMaxLabelLength + 1))),
        contains(BeforeYouGoGateRule.labelTooLong),
      );
    });

    test('an icon this build does not ship', () {
      expect(
        _rulesFor(_hint(icon: 'rocket_launch')),
        contains(BeforeYouGoGateRule.unknownIcon),
      );
    });

    test('a row with no condition', () {
      expect(
        _rulesFor(_hint(when: const <HintClause>[])),
        contains(BeforeYouGoGateRule.emptyCondition),
      );
    });

    test('a region month outside the calendar', () {
      expect(
        _rulesFor(
          _hint(),
          regions: const <RegionEntry>[
            RegionEntry(
              id: 'bac',
              aliases: <String>['ha noi'],
              rainyMonths: <int>[13],
            ),
          ],
        ),
        contains(BeforeYouGoGateRule.invalidRegion),
      );
    });

    test('one alias claimed by two regions', () {
      expect(
        _rulesFor(
          _hint(),
          regions: const <RegionEntry>[
            RegionEntry(
              id: 'bac',
              aliases: <String>['ha noi'],
              rainyMonths: <int>[5],
            ),
            RegionEntry(
              id: 'nam',
              aliases: <String>['ha noi'],
              rainyMonths: <int>[6],
            ),
          ],
        ),
        contains(BeforeYouGoGateRule.duplicateRegionAlias),
      );
    });

    test('a clean functional row reports nothing', () {
      expect(_rulesFor(_hint()), isEmpty);
    });
  });
}
