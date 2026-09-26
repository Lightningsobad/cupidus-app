import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/date_script/domain/date_script_content.dart';
import 'package:cupid_mobile/features/date_script/domain/date_script_selector.dart';
import 'package:flutter_test/flutter_test.dart';

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

DateScriptPreset _preset(
  String id, {
  List<ActivityType> activityTypes = const <ActivityType>[],
}) =>
    DateScriptPreset(
      id: id,
      activityTypes: activityTypes,
      parts: <DateScriptPartContent>[
        for (final DateScriptPart part in DateScriptPart.values)
          DateScriptPartContent(
            part: part,
            sentences: const <DateScriptSentence>[
              DateScriptSentence(
                text: 'Câu không điều kiện.',
                requires: <DateScriptVariable>[],
                aboutPartner: false,
              ),
            ],
          ),
      ],
    );

ContentPackage<DateScriptPreset> _pack(List<DateScriptPreset> items) =>
    ContentPackage<DateScriptPreset>(
      id: 'date_script',
      version: '1.0.0',
      schemaId: dateScriptSchemaId,
      items: items,
    );

ActivityCard _card(String id, {ActivityType? activityType}) => ActivityCard(
      id: id,
      ownerKey: 'owner',
      title: 'Đi cà phê',
      status: ActivityCardStatus.scheduled,
      origin: ActivityCardOrigin.manual,
      activityType: activityType,
      invited: false,
      replyState: ActivityCardReplyState.notAnswered,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  group('stableHash', () {
    // Published FNV-1a 32-bit vectors. Written out as literals rather than
    // recomputed, so this test is independent evidence of the algorithm rather
    // than a restatement of the implementation.
    test('matches the published FNV-1a 32-bit vectors', () {
      expect(stableHash(''), 0x811c9dc5);
      expect(stableHash('a'), 0xe40c292c);
      expect(stableHash('foobar'), 0xbf9cf968);
    });

    test('is not String.hashCode', () {
      // The regression this file exists for: `String.hashCode` is seeded per
      // process in some runtimes, so swapping it in would re-pick a card's
      // script on the next launch and break AC-8 silently.
      const String sample = 'card-9f2c';
      expect(stableHash(sample), isNot(sample.hashCode));
    });

    test('stays inside 32 bits for long and non-ASCII input', () {
      for (final String sample in <String>[
        'card-' * 200,
        'thẻ-cà-phê-chiều-thứ-bảy',
        '🌙',
      ]) {
        expect(stableHash(sample), inInclusiveRange(0, 0xFFFFFFFF));
      }
    });

    test('depends on byte order, not just on the set of bytes', () {
      // Catches an XOR- or sum-only implementation, which would give every
      // anagram of a card id the same script.
      expect(stableHash('abc'), isNot(stableHash('cba')));
    });
  });

  group('selectPreset', () {
    test('returns the same preset on 100 consecutive calls', () {
      final ContentPackage<DateScriptPreset> pack = _shippedPack();
      final ActivityCard card = _card('card-1', activityType: ActivityType.dining);

      final DateScriptPreset first = selectPreset(pack, card);
      for (int i = 0; i < 100; i++) {
        expect(identical(selectPreset(pack, card), first), isTrue);
      }
    });

    test('is total over every ActivityType and over null', () {
      final ContentPackage<DateScriptPreset> pack = _shippedPack();
      final List<ActivityType?> types = <ActivityType?>[
        ...ActivityType.values,
        null,
      ];

      for (final ActivityType? type in types) {
        final ActivityCard card = _card('card-total', activityType: type);
        final DateScriptPreset preset = selectPreset(pack, card);
        expect(
          preset.parts.map((DateScriptPartContent part) => part.part),
          DateScriptPart.values,
          reason: 'type ${type?.wireValue ?? 'null'} lost a part',
        );
      }
    });

    test('prefers a preset that declares the card type', () {
      final ContentPackage<DateScriptPreset> pack = _pack(<DateScriptPreset>[
        _preset('generic.a'),
        _preset('dining.a', activityTypes: <ActivityType>[ActivityType.dining]),
      ]);

      expect(
        selectPreset(pack, _card('card-1', activityType: ActivityType.dining)).id,
        'dining.a',
      );
    });

    test('falls back to generic for a type no preset declares', () {
      final ContentPackage<DateScriptPreset> pack = _pack(<DateScriptPreset>[
        _preset('generic.a'),
        _preset('dining.a', activityTypes: <ActivityType>[ActivityType.dining]),
      ]);

      expect(
        selectPreset(pack, _card('card-1', activityType: ActivityType.photo)).id,
        'generic.a',
      );
    });

    test('falls back to generic when the card has no type at all', () {
      final ContentPackage<DateScriptPreset> pack = _pack(<DateScriptPreset>[
        _preset('dining.a', activityTypes: <ActivityType>[ActivityType.dining]),
        _preset('generic.a'),
      ]);

      expect(selectPreset(pack, _card('card-1')).id, 'generic.a');
    });

    test('serves a pack of exactly one preset', () {
      // N is a property of the data (R-15b): the one-preset pack is as valid as
      // the ten-preset seed and gets the same answer every time.
      final ContentPackage<DateScriptPreset> pack =
          _pack(<DateScriptPreset>[_preset('only.a')]);

      for (final ActivityType? type in <ActivityType?>[
        ...ActivityType.values,
        null,
      ]) {
        expect(selectPreset(pack, _card('card-$type', activityType: type)).id,
            'only.a');
      }
    });

    test('spreads different card ids across the candidates', () {
      // Not a distribution claim — just that the id is actually read, so a
      // constant-returning selector cannot pass the determinism test above.
      final ContentPackage<DateScriptPreset> pack = _pack(<DateScriptPreset>[
        _preset('generic.a'),
        _preset('generic.b'),
        _preset('generic.c'),
      ]);

      final Set<String> picked = <String>{
        for (int i = 0; i < 50; i++) selectPreset(pack, _card('card-$i')).id,
      };
      expect(picked.length, greaterThan(1));
    });

    test('each card keeps its own preset when others are added', () {
      final ContentPackage<DateScriptPreset> pack = _pack(<DateScriptPreset>[
        _preset('generic.a'),
        _preset('generic.b'),
      ]);

      final Map<String, String> before = <String, String>{
        for (int i = 0; i < 20; i++)
          'card-$i': selectPreset(pack, _card('card-$i')).id,
      };

      for (final MapEntry<String, String> entry in before.entries) {
        expect(selectPreset(pack, _card(entry.key)).id, entry.value);
      }
    });

    test('rejects a package with no generic preset loudly', () {
      // Unreachable for a pack that passed the ship gate; reachable for one an
      // out-of-repo CMS builds in memory, and a named error beats a RangeError.
      final ContentPackage<DateScriptPreset> pack = _pack(<DateScriptPreset>[
        _preset('dining.a', activityTypes: <ActivityType>[ActivityType.dining]),
      ]);

      expect(
        () => selectPreset(pack, _card('card-1', activityType: ActivityType.walk)),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });
  });

  group('cycleIndex', () {
    test('wraps for a length of one', () {
      for (int i = 0; i < 5; i++) {
        expect(cycleIndex(i, 1), 0);
      }
    });

    test('alternates for a length of two', () {
      expect(<int>[for (int i = 0; i < 5; i++) cycleIndex(i, 2)],
          <int>[0, 1, 0, 1, 0]);
    });

    test('returns to the start after a full lap of a large N', () {
      const int length = 347;
      expect(cycleIndex(length, length), 0);
      expect(cycleIndex(length + 4, length), 4);
      expect(cycleIndex(length * 9 + 12, length), 12);
    });

    test('has no exhausted state: every index stays inside the pack', () {
      const int length = 7;
      for (int i = 0; i < length * 4; i++) {
        expect(cycleIndex(i, length), inInclusiveRange(0, length - 1));
      }
    });

    test('a cursor that ran backwards still lands inside the pack', () {
      expect(cycleIndex(-1, 5), 4);
      expect(cycleIndex(-6, 5), 4);
    });
  });
}
