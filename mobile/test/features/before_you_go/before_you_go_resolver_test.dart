import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/before_you_go/domain/before_you_go_content.dart';
import 'package:cupid_mobile/features/before_you_go/domain/before_you_go_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime _rainyDayInTheNorth = DateTime(2026, 6, 15);
final DateTime _dryDayInTheNorth = DateTime(2026, 1, 15);

ActivityCard _card({
  String id = 'card-1',
  ActivityCardStatus status = ActivityCardStatus.scheduled,
  String? scheduledOn = '2026-06-15',
  int? priceVnd,
  double? distanceKm,
  bool? needsBooking,
  ActivityCardIndoorOutdoor? indoorOutdoor,
  String? location,
}) =>
    ActivityCard(
      id: id,
      ownerKey: 'owner-1',
      title: 'Buổi hẹn',
      status: status,
      origin: ActivityCardOrigin.manual,
      scheduledOn: scheduledOn,
      priceVnd: priceVnd,
      distanceKm: distanceKm,
      needsBooking: needsBooking,
      indoorOutdoor: indoorOutdoor,
      location: location,
      invited: false,
      replyState: ActivityCardReplyState.notAnswered,
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 1),
    );

void main() {
  late BeforeYouGoPack pack;

  setUp(() {
    pack = parseBeforeYouGoPack(
      File(beforeYouGoAssetKey).readAsStringSync(),
      source: beforeYouGoAssetKey,
    );
  });

  List<String> resolveIds(ActivityCard card, {DateTime? today}) => resolveHints(
        hints: pack.hints,
        facts: BeforeYouGoFacts.fromCard(
          card,
          today: today ?? _rainyDayInTheNorth,
          regions: pack.regions,
        ),
      ).map((ChecklistHint hint) => hint.id).toList(growable: false);

  group('the resolver is a pure function of card, date, and pack', () {
    test('the same inputs give the same rows twice running (AC-10)', () {
      final ActivityCard card = _card(
        priceVnd: 200000,
        distanceKm: 25,
        needsBooking: true,
        indoorOutdoor: ActivityCardIndoorOutdoor.outdoor,
        location: 'Hồ Tây, Hà Nội',
      );

      expect(resolveIds(card), resolveIds(card));
      expect(resolveIds(card), isNotEmpty);
    });

    test('rows come back ordered by the pack order', () {
      final List<ChecklistHint> resolved = resolveHints(
        hints: pack.hints,
        facts: BeforeYouGoFacts.fromCard(
          _card(
            priceVnd: 200000,
            distanceKm: 25,
            needsBooking: true,
            indoorOutdoor: ActivityCardIndoorOutdoor.outdoor,
            location: 'Hà Nội',
          ),
          today: _rainyDayInTheNorth,
          regions: pack.regions,
        ),
      );
      final List<int> orders =
          resolved.map((ChecklistHint hint) => hint.order).toList();

      expect(orders, List<int>.from(orders)..sort());
    });

    test('a pack trimmed to zero rows resolves to an empty list (AC-30)', () {
      final BeforeYouGoPack emptyPack = parseBeforeYouGoPack(
        jsonEncode(<String, Object?>{
          'id': 'before_you_go.fixture',
          'version': '1.0.0',
          'schema_id': beforeYouGoSchemaId,
          'items': <Map<String, Object?>>[],
          'regions': <Map<String, Object?>>[
            <String, Object?>{
              'id': 'bac',
              'aliases': <String>['ha noi'],
              'rainyMonths': <int>[6],
            },
          ],
        }),
      );

      expect(
        resolveHints(
          hints: emptyPack.hints,
          facts: BeforeYouGoFacts.fromCard(
            _card(priceVnd: 200000, location: 'Hà Nội'),
            today: _rainyDayInTheNorth,
            regions: emptyPack.regions,
          ),
        ),
        isEmpty,
      );
    });

    test('no path in this module reads the clock directly (AC-10)', () {
      final List<String> offenders = <String>[];

      for (final FileSystemEntity entity
          in Directory('lib/features/before_you_go').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        if (entity.readAsStringSync().contains('DateTime.now()')) {
          offenders.add(entity.path);
        }
      }

      expect(offenders, isEmpty);
    });
  });

  group('a card with every field gives exactly its rows (AC-7)', () {
    test('price, distance, and booking give three rows plus share location',
        () {
      expect(
        resolveIds(
          _card(priceVnd: 200000, distanceKm: 25, needsBooking: true),
        ),
        <String>['cash', 'fuel', 'booking', 'share_location'],
      );
    });

    test('a distance under the packaged threshold drops the fuel row', () {
      expect(
        resolveIds(_card(priceVnd: 200000, distanceKm: 2, needsBooking: true)),
        <String>['cash', 'booking', 'share_location'],
      );
    });

    test('a free card drops the cash row', () {
      expect(
        resolveIds(_card(priceVnd: 0, distanceKm: 25, needsBooking: true)),
        <String>['fuel', 'booking', 'share_location'],
      );
    });

    test('needsBooking false drops the booking row', () {
      expect(
        resolveIds(_card(priceVnd: 200000, needsBooking: false)),
        <String>['cash', 'share_location'],
      );
    });
  });

  group('a missing field drops its row, it is never defaulted (AC-9/BR-4)',
      () {
    test('a nearly empty card keeps only the always-on row (AC-12)', () {
      expect(resolveIds(_card()), <String>['share_location']);
    });

    test('no price means no cash row', () {
      expect(resolveIds(_card(distanceKm: 25)), isNot(contains('cash')));
    });

    test('no distance means no fuel row', () {
      expect(resolveIds(_card(priceVnd: 200000)), isNot(contains('fuel')));
    });

    test('no booking flag means no booking row', () {
      expect(resolveIds(_card(priceVnd: 200000)), isNot(contains('booking')));
    });
  });

  group('the rain row is derived from region and date only (AC-8/AC-11)', () {
    test('outdoor in a northern rainy month gives the rain row', () {
      expect(
        resolveIds(
          _card(
            indoorOutdoor: ActivityCardIndoorOutdoor.outdoor,
            location: 'Hồ Tây, Hà Nội',
          ),
        ),
        contains('rain'),
      );
    });

    test('indoor never gives the rain row, rainy month or not (AC-8)', () {
      expect(
        resolveIds(
          _card(
            indoorOutdoor: ActivityCardIndoorOutdoor.indoor,
            location: 'CGV Vincom, Hà Nội',
          ),
        ),
        isNot(contains('rain')),
      );
    });

    test('outdoor outside the rainy months gives no rain row', () {
      expect(
        resolveIds(
          _card(
            indoorOutdoor: ActivityCardIndoorOutdoor.outdoor,
            location: 'Hồ Tây, Hà Nội',
          ),
          today: _dryDayInTheNorth,
        ),
        isNot(contains('rain')),
      );
    });

    test('a location matching no alias leaves rainySeason null', () {
      final BeforeYouGoFacts facts = BeforeYouGoFacts.fromCard(
        _card(
          indoorOutdoor: ActivityCardIndoorOutdoor.outdoor,
          location: 'Quán cà phê góc phố',
        ),
        today: _rainyDayInTheNorth,
        regions: pack.regions,
      );

      expect(facts.regionId, isNull);
      expect(facts.rainySeason, isNull);
      expect(
        resolveIds(
          _card(
            indoorOutdoor: ActivityCardIndoorOutdoor.outdoor,
            location: 'Quán cà phê góc phố',
          ),
        ),
        isNot(contains('rain')),
      );
    });

    test('a card with no location at all leaves rainySeason null', () {
      final BeforeYouGoFacts facts = BeforeYouGoFacts.fromCard(
        _card(indoorOutdoor: ActivityCardIndoorOutdoor.outdoor),
        today: _rainyDayInTheNorth,
        regions: pack.regions,
      );

      expect(facts.rainySeason, isNull);
    });
  });

  group('region matching folds diacritics and matches whole tokens', () {
    test('a diacritic-heavy place name resolves', () {
      expect(regionForLocation('Đà Nẵng', pack.regions)?.id, 'trung');
    });

    test('punctuation and case do not matter', () {
      expect(regionForLocation('Quận 1, TP.HCM', pack.regions)?.id, 'nam');
    });

    test('an alias inside a longer word does not match', () {
      expect(regionForLocation('Huebner Road', pack.regions), isNull);
    });

    test('an unknown place resolves to no region', () {
      expect(regionForLocation('Ở nhà', pack.regions), isNull);
    });

    test('a null location resolves to no region', () {
      expect(regionForLocation(null, pack.regions), isNull);
    });
  });

  group('BeforeYouGoPhase is the state STORY-012 reads (AC-24/BR-11)', () {
    test('scheduled today and not dismissed', () {
      final BeforeYouGoPhase phase = BeforeYouGoPhase.fromCard(
        _card(),
        today: _rainyDayInTheNorth,
      );

      expect(phase.cardId, 'card-1');
      expect(phase.dateIso, '2026-06-15');
      expect(phase.isActive, isTrue);
      expect(phase.isDismissed, isFalse);
    });

    test('scheduled today and dismissed today', () {
      final BeforeYouGoPhase phase = BeforeYouGoPhase.fromCard(
        _card(),
        today: _rainyDayInTheNorth,
        dismissedOnIso: '2026-06-15',
      );

      expect(phase.isActive, isTrue);
      expect(phase.isDismissed, isTrue);
    });

    test('scheduled for another day is not active', () {
      final BeforeYouGoPhase phase = BeforeYouGoPhase.fromCard(
        _card(scheduledOn: '2026-06-20'),
        today: _rainyDayInTheNorth,
      );

      expect(phase.isActive, isFalse);
      expect(phase.isDismissed, isFalse);
    });

    test('another status on the same day is not active', () {
      final BeforeYouGoPhase phase = BeforeYouGoPhase.fromCard(
        _card(status: ActivityCardStatus.idea),
        today: _rainyDayInTheNorth,
        dismissedOnIso: '2026-06-15',
      );

      expect(phase.isActive, isFalse);
      expect(phase.isDismissed, isTrue);
    });

    test('a dismissal from yesterday does not carry over', () {
      final BeforeYouGoPhase phase = BeforeYouGoPhase.fromCard(
        _card(),
        today: _rainyDayInTheNorth,
        dismissedOnIso: '2026-06-14',
      );

      expect(phase.isDismissed, isFalse);
    });

    test('the dismissal key is namespaced per card', () {
      expect(
        beforeYouGoDismissedOnKey('card-1'),
        'before_you_go.dismissed_on.card-1',
      );
    });

    test('the civil date is zero padded', () {
      expect(civilDateIso(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });
}
