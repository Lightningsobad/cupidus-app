import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_content_repository.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';

/// Widget-free tests ship no asset bundle, so the real packs are read straight
/// off disk. Reading the shipped files rather than a fixture is the point: this
/// must fail if an author's pack stops resolving.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }
}

/// Serves one overridden asset and falls through to disk for the rest, so a
/// test can break exactly one pack.
class _OverrideBundle extends CachingAssetBundle {
  _OverrideBundle(this.overrides);

  final Map<String, String> overrides;

  @override
  Future<ByteData> load(String key) async {
    if (overrides[key] case final String source) {
      return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
    }
    return ByteData.sublistView(File(key).readAsBytesSync());
  }
}

Map<String, Object?> _diskJson(String assetKey) =>
    jsonDecode(File(assetKey).readAsStringSync()) as Map<String, Object?>;

PhaseContentRepository _repositoryWith(Map<String, String> overrides) =>
    PhaseContentRepository(bundle: _OverrideBundle(overrides));

void main() {
  group('the shipped catalogue loads (AC-37)', () {
    late PhaseContentCatalogue catalogue;

    setUp(() async {
      catalogue =
          await PhaseContentRepository(bundle: _DiskBundle()).catalogue();
    });

    test('each pack carries the schema id the contract pins', () {
      expect(catalogue.phaseContent.schemaId, phaseContentSchemaId);
      expect(catalogue.drip.schemaId, dripSchemaId);
      expect(catalogue.nudges.schemaId, nudgesSchemaId);
    });

    test('every item id is durable and unique inside its pack', () {
      for (final List<String> ids in <List<String>>[
        catalogue.phaseContent.items.map((PhaseContentItem i) => i.id).toList(),
        catalogue.drip.items.map((DripItem i) => i.id).toList(),
        catalogue.nudges.items.map((NudgeItem i) => i.id).toList(),
      ]) {
        expect(ids.toSet(), hasLength(ids.length));
        for (final String id in ids) {
          expect(id, isNotEmpty);
          expect(int.tryParse(id), isNull, reason: id);
        }
      }
    });

    test('itemById resolves a shipped line by its durable id', () {
      final PhaseContentItem first = catalogue.phaseContent.items.first;
      expect(catalogue.phaseContent.itemById(first.id), same(first));
      expect(catalogue.phaseContent.itemById('phase.no.such.line'), isNull);
    });

    test('a widget-only line still carries its primary string', () {
      final Iterable<PhaseContentItem> widgetLines =
          catalogue.phaseContent.items.where(
        (PhaseContentItem i) => i.surface.allowsWidget,
      );

      expect(widgetLines, isNotEmpty);
      for (final PhaseContentItem line in widgetLines) {
        expect(line.primary, isNotEmpty, reason: line.id);
      }
    });

    test('an absent secondary is a valid shipped state, not an error', () {
      expect(
        catalogue.phaseContent.items.any(
          (PhaseContentItem i) => i.secondary == null,
        ),
        isTrue,
      );
      expect(
        catalogue.nudges.items.any((NudgeItem i) => i.title == null),
        isTrue,
      );
    });

    test('only "{n}" is used as a substitution site', () {
      final RegExp brace = RegExp(r'\{[^}]*\}');
      final List<String> strings = <String>[
        for (final PhaseContentItem i in catalogue.phaseContent.items)
          ...i.displayStrings,
        for (final DripItem i in catalogue.drip.items) ...i.displayStrings,
        for (final NudgeItem i in catalogue.nudges.items) ...i.displayStrings,
      ];

      for (final String text in strings) {
        for (final RegExpMatch match in brace.allMatches(text)) {
          expect(match.group(0), phaseContentNumberPlaceholder, reason: text);
        }
      }
    });

    test('the milestone thresholds come back ascending (BR-16)', () {
      expect(catalogue.milestoneThresholds, isNotEmpty);
      expect(
        catalogue.milestoneThresholds,
        orderedEquals(<int>[...catalogue.milestoneThresholds]..sort()),
      );
      expect(
        catalogue.milestoneThresholds.toSet(),
        hasLength(catalogue.milestoneThresholds.length),
      );
    });

    test('the catalogue is parsed once and shared', () async {
      final PhaseContentRepository repository =
          PhaseContentRepository(bundle: _DiskBundle());

      expect(
        await repository.catalogue(),
        same(await repository.catalogue()),
      );
    });
  });

  group('a malformed pack is loud, never degraded (R-15a)', () {
    test('a wrong schema_id throws instead of yielding an empty pack', () {
      final Map<String, Object?> pack = _diskJson(phaseContentAssetKey);
      pack['schema_id'] = 'req016.phase_content.v2';

      expect(
        _repositoryWith(<String, String>{
          phaseContentAssetKey: jsonEncode(pack),
        }).catalogue(),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains(phaseContentSchemaId),
          ),
        ),
      );
    });

    test('a duplicate item id throws', () {
      final Map<String, Object?> pack = _diskJson(dripAssetKey);
      final List<Object?> items = pack['items']! as List<Object?>;
      pack['items'] = <Object?>[items.first, items.first];

      expect(
        _repositoryWith(<String, String>{
          dripAssetKey: jsonEncode(pack),
        }).catalogue(),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('duplicate item id'),
          ),
        ),
      );
    });

    test('an unknown phase_id throws instead of defaulting', () {
      expect(
        () => phaseContentItemFromJson(
          <String, Object?>{
            'id': 'phase.fixture.v1',
            'phase_id': 'reconciling',
            'primary': 'Một dòng',
            'surface': 'both',
          },
          '<fixture>',
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('an unknown surface throws instead of defaulting', () {
      expect(
        () => phaseContentItemFromJson(
          <String, Object?>{
            'id': 'phase.fixture.v1',
            'phase_id': 'waiting',
            'primary': 'Một dòng',
            'surface': 'lockscreen',
          },
          '<fixture>',
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('an unknown nudge slot throws instead of defaulting', () {
      expect(
        () => nudgeItemFromJson(
          <String, Object?>{
            'id': 'nudge.fixture.v1',
            'slot': 'morning_push',
            'body': 'Một dòng',
          },
          '<fixture>',
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('a present-but-empty optional string throws', () {
      expect(
        () => nudgeItemFromJson(
          <String, Object?>{
            'id': 'nudge.fixture.v1',
            'slot': 'neutral',
            'title': '',
            'body': 'Một dòng',
          },
          '<fixture>',
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });
  });

  group('milestone thresholds are package data (BR-16)', () {
    test('an unsorted list is returned ascending', () {
      expect(
        milestoneThresholdsFromJson(
          <String, Object?>{
            milestoneThresholdsKey: <Object?>[25, 5, 100, 10],
          },
          '<fixture>',
        ),
        orderedEquals(<int>[5, 10, 25, 100]),
      );
    });

    test('a missing thresholds key throws', () {
      expect(
        () => milestoneThresholdsFromJson(<String, Object?>{}, '<fixture>'),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('a non-integer entry throws', () {
      expect(
        () => milestoneThresholdsFromJson(
          <String, Object?>{
            milestoneThresholdsKey: <Object?>[5, '10'],
          },
          '<fixture>',
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('a zero or negative entry throws', () {
      expect(
        () => milestoneThresholdsFromJson(
          <String, Object?>{
            milestoneThresholdsKey: <Object?>[0, 5],
          },
          '<fixture>',
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('a duplicate threshold throws', () {
      expect(
        () => milestoneThresholdsFromJson(
          <String, Object?>{
            milestoneThresholdsKey: <Object?>[5, 5],
          },
          '<fixture>',
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });

    test('the returned list is unmodifiable', () {
      final List<int> thresholds = milestoneThresholdsFromJson(
        <String, Object?>{
          milestoneThresholdsKey: <Object?>[5, 10],
        },
        '<fixture>',
      );

      expect(() => thresholds.add(20), throwsUnsupportedError);
    });
  });
}
