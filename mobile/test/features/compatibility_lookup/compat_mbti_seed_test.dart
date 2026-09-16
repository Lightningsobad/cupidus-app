import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/compatibility_lookup/domain/compat_content.dart';
import 'package:cupid_mobile/features/compatibility_lookup/domain/compat_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

/// The MBTI axis size is pinned here, in `test/`, because AC-36 forbids the
/// same literals under `lib/`.
const int _mbtiAxisCount = 16;
const int _mbtiCellCount = _mbtiAxisCount * _mbtiAxisCount;

const List<String> _expectedAxisIds = <String>[
  'intj',
  'enfp',
  'intp',
  'entj',
  'entp',
  'infj',
  'infp',
  'enfj',
  'istj',
  'isfj',
  'estj',
  'esfj',
  'istp',
  'isfp',
  'estp',
  'esfp',
];

void main() {
  late ContentPackage<CompatBand> bands;
  late ContentPackage<CompatItem> mbti;
  late List<CompatAxisValue> axisValues;
  late List<CompatCell> cells;

  setUp(() {
    bands = ContentPackage.parse<CompatBand>(
      File(compatBandsAssetKey).readAsStringSync(),
      expectedSchemaId: compatBandsSchemaId,
      itemParser: compatBandFromJson,
      source: compatBandsAssetKey,
    );
    mbti = ContentPackage.parse<CompatItem>(
      File(compatMbtiAssetKey).readAsStringSync(),
      expectedSchemaId: compatMbtiSchemaId,
      itemParser: compatItemFromJson,
      source: compatMbtiAssetKey,
    );
    axisValues = mbti.items.whereType<CompatAxisValue>().toList(
          growable: false,
        );
    cells = mbti.items.whereType<CompatCell>().toList(growable: false);
  });

  group('the shipped MBTI seed is complete (AC-36/AC-38)', () {
    test('the axis declares exactly the sixteen types, in a stable order', () {
      expect(
        axisValues.map((CompatAxisValue v) => v.id).toList(growable: false),
        _expectedAxisIds,
      );
      expect(axisValues.length, _mbtiAxisCount);
    });

    test('every axis value carries a non-empty label', () {
      for (final CompatAxisValue value in axisValues) {
        expect(value.label.trim(), isNotEmpty, reason: value.id);
      }
      expect(
        axisValues.map((CompatAxisValue v) => v.label).toSet().length,
        _mbtiAxisCount,
      );
    });

    test('the pack holds exactly one cell per ordered pair', () {
      expect(cells.length, _mbtiCellCount);
      expect(cells.map((CompatCell c) => c.id).toSet().length, _mbtiCellCount);

      for (final String selfId in _expectedAxisIds) {
        for (final String partnerId in _expectedAxisIds) {
          final Iterable<CompatCell> matches = cells.where(
            (CompatCell c) => c.selfId == selfId && c.partnerId == partnerId,
          );
          expect(matches.length, 1, reason: '$selfId vs $partnerId');
          expect(matches.single.id, compatCellId(selfId, partnerId));
        }
      }
    });

    test('every cell names a band declared by the bands pack', () {
      final Set<String> bandIds =
          bands.items.map((CompatBand b) => b.id).toSet();
      for (final CompatCell cell in cells) {
        expect(bandIds, contains(cell.bandId), reason: cell.id);
      }
    });

    test('each cell fills the whole quartet with distinct wording', () {
      for (final CompatCell cell in cells) {
        final List<String> quartet = <String>[
          cell.fit,
          cell.friction,
          cell.activity,
          cell.question,
        ];
        for (final String field in quartet) {
          expect(field.trim(), isNotEmpty, reason: cell.id);
        }
        expect(quartet.toSet().length, quartet.length, reason: cell.id);
        expect(cell.question.trim().endsWith('?'), isTrue, reason: cell.id);
      }
    });

    test('the two directions of a pair are written separately (BR-2)', () {
      for (final String selfId in _expectedAxisIds) {
        for (final String partnerId in _expectedAxisIds) {
          if (selfId == partnerId) {
            continue;
          }
          final CompatCell forward =
              lookupCell(mbti, selfId: selfId, partnerId: partnerId)!;
          final CompatCell reverse =
              lookupCell(mbti, selfId: partnerId, partnerId: selfId)!;
          final String reason = '$selfId vs $partnerId';

          expect(forward.fit, isNot(reverse.fit), reason: reason);
          expect(forward.friction, isNot(reverse.friction), reason: reason);
          expect(forward.activity, isNot(reverse.activity), reason: reason);
          expect(forward.question, isNot(reverse.question), reason: reason);
        }
      }
    });

    test('the seed is not one sentence repeated across the grid', () {
      expect(cells.map((CompatCell c) => c.fit).toSet().length, _mbtiCellCount);
      expect(
        cells.map((CompatCell c) => c.friction).toSet().length,
        _mbtiCellCount,
      );
      expect(
        cells.map((CompatCell c) => c.question).toSet().length,
        _mbtiCellCount,
      );
    });

    test('the seed passes the content gate with no rule relaxed (AC-37)', () {
      final ContentPackage<CompatItem> zodiac =
          ContentPackage.parse<CompatItem>(
        File(compatZodiacAssetKey).readAsStringSync(),
        expectedSchemaId: compatZodiacSchemaId,
        itemParser: compatItemFromJson,
        source: compatZodiacAssetKey,
      );

      expect(
        validateCompatPacks(bands: bands, zodiac: zodiac, mbti: mbti)
            .map((CompatViolation v) => v.toString()),
        isEmpty,
      );
    });
  });
}
