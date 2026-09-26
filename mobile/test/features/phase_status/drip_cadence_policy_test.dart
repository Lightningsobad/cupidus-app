import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_status_prefs.dart';
import 'package:cupid_mobile/features/phase_status/domain/drip_cadence_policy.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ContentPackage<DripItem> _store(int itemCount) {
  return ContentPackage<DripItem>(
    id: 'drip',
    version: '1.0.0',
    schemaId: dripSchemaId,
    items: <DripItem>[
      for (int index = 0; index < itemCount; index++)
        DripItem(id: 'drip.item.$index', body: 'body $index'),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PhaseStatusPrefs prefs;
  late DripCadencePolicy policy;

  void useStore(Map<String, Object> initial) {
    SharedPreferences.setMockInitialValues(initial);
    prefs = PhaseStatusPrefs();
    policy = DripCadencePolicy(prefs);
  }

  setUp(() => useStore(<String, Object>{}));

  group('the BR-9 ceiling is a constant, not a function of the pack', () {
    test('it is one week', () {
      expect(dripMinimumDaysBetweenShows, 7);
    });
  });

  group('cadence — at most one a week, never two days running (AC-22/BR-9)',
      () {
    test('the first ask in a quiet stretch may show', () async {
      final DripItem? item = await policy.nextItem(
        drip: _store(8),
        today: DateTime(2026, 9, 1),
      );

      expect(item, isNotNull);
      expect(await prefs.dripLastShownOn(), '2026-09-01');
      expect(await prefs.dripSeenIds(), <String>[item!.id]);
    });

    test('the very next day is silent', () async {
      await policy.nextItem(drip: _store(8), today: DateTime(2026, 9, 1));

      expect(
        await policy.nextItem(drip: _store(8), today: DateTime(2026, 9, 2)),
        isNull,
      );
    });

    test('six days later is still silent, seven days later may show', () async {
      final ContentPackage<DripItem> store = _store(8);
      await policy.nextItem(drip: store, today: DateTime(2026, 9, 1));

      expect(
        await policy.nextItem(drip: store, today: DateTime(2026, 9, 7)),
        isNull,
      );
      expect(
        await policy.nextItem(drip: store, today: DateTime(2026, 9, 8)),
        isNotNull,
      );
    });

    test('opening the app every day for eight weeks shows at most weekly',
        () async {
      final ContentPackage<DripItem> store = _store(8);
      final List<DateTime> shownOn = <DateTime>[];

      DateTime day = DateTime(2026, 9, 1);
      for (int elapsed = 0; elapsed < 56; elapsed++) {
        final DripItem? item = await policy.nextItem(drip: store, today: day);
        if (item != null) {
          shownOn.add(day);
        }
        day = day.add(const Duration(days: 1));
      }

      expect(shownOn.length, lessThanOrEqualTo(8));
      for (int index = 1; index < shownOn.length; index++) {
        expect(
          shownOn[index].difference(shownOn[index - 1]).inDays,
          greaterThanOrEqualTo(dripMinimumDaysBetweenShows),
        );
      }
    });

    test('a daylight-saving week still counts as seven whole days', () async {
      final ContentPackage<DripItem> store = _store(8);
      await policy.nextItem(drip: store, today: DateTime(2026, 3, 8));

      expect(
        await policy.nextItem(drip: store, today: DateTime(2026, 3, 14)),
        isNull,
      );
      expect(
        await policy.nextItem(drip: store, today: DateTime(2026, 3, 15)),
        isNotNull,
      );
    });
  });

  group('consumption is by id, not by index (R-15a)', () {
    test('an item already read never comes back', () async {
      final ContentPackage<DripItem> store = _store(3);
      final List<String> shown = <String>[];

      DateTime day = DateTime(2026, 9, 1);
      for (int week = 0; week < 3; week++) {
        shown.add((await policy.nextItem(drip: store, today: day))!.id);
        day = day.add(const Duration(days: 7));
      }

      expect(shown.toSet().length, 3);
      expect(await prefs.dripSeenIds(), shown);
    });

    test('reordering or growing the pack does not resurrect a read item',
        () async {
      await policy.nextItem(drip: _store(2), today: DateTime(2026, 9, 1));
      final List<String> seen = await prefs.dripSeenIds();

      final ContentPackage<DripItem> reordered = ContentPackage<DripItem>(
        id: 'drip',
        version: '2.0.0',
        schemaId: dripSchemaId,
        items: <DripItem>[
          const DripItem(id: 'drip.item.1', body: 'body 1'),
          const DripItem(id: 'drip.item.0', body: 'body 0'),
          const DripItem(id: 'drip.item.2', body: 'body 2'),
        ],
      );

      final DripItem? next = await policy.nextItem(
        drip: reordered,
        today: DateTime(2026, 9, 8),
      );

      expect(seen, <String>['drip.item.0']);
      expect(next!.id, isNot('drip.item.0'));
    });
  });

  group('exhaustion is silence, at any pack size (AC-38/BR-16)', () {
    test('a one-item pack shows once in eight weeks, then never', () async {
      final ContentPackage<DripItem> store = _store(1);
      int shows = 0;

      DateTime day = DateTime(2026, 9, 1);
      for (int elapsed = 0; elapsed < 56; elapsed++) {
        if (await policy.nextItem(drip: store, today: day) != null) {
          shows++;
        }
        day = day.add(const Duration(days: 1));
      }

      expect(shows, 1);
    });

    test('a zero-item pack returns null without reading a string', () async {
      final ContentPackage<DripItem> empty = _store(0);

      expect(empty.length, 0);
      expect(
        await policy.nextItem(drip: empty, today: DateTime(2026, 9, 1)),
        isNull,
      );
      expect(await prefs.dripLastShownOn(), isNull);
      expect(await prefs.dripSeenIds(), isEmpty);
    });

    test('an exhausted pack does not widen the window to fill the gap',
        () async {
      final ContentPackage<DripItem> store = _store(1);
      await policy.nextItem(drip: store, today: DateTime(2026, 9, 1));

      // Long past the ceiling, with nothing left: still null, and the cursor
      // is untouched, so no "catch up" is queued for later either.
      expect(
        await policy.nextItem(drip: store, today: DateTime(2026, 12, 1)),
        isNull,
      );
      expect(await prefs.dripLastShownOn(), '2026-09-01');
    });

    test('exhaustion returns the same null as a quiet week — indistinguishable',
        () async {
      final ContentPackage<DripItem> store = _store(1);

      final DripItem? onlyShow = await policy.nextItem(
        drip: store,
        today: DateTime(2026, 9, 1),
      );
      expect(onlyShow, isNotNull);

      final DripItem? withinTheWeek = await policy.nextItem(
        drip: store,
        today: DateTime(2026, 9, 3),
      );
      final DripItem? afterExhaustion = await policy.nextItem(
        drip: store,
        today: DateTime(2026, 9, 30),
      );

      expect(withinTheWeek, isNull);
      expect(afterExhaustion, isNull);
    });
  });

  group('a corrupt cursor re-arms rather than silencing forever', () {
    test('an unparseable last_shown_on is treated as no record', () async {
      useStore(<String, Object>{
        phaseStatusDripLastShownOnKey: 'not-a-date',
      });

      final DripItem? item = await policy.nextItem(
        drip: _store(4),
        today: DateTime(2026, 9, 1),
      );

      expect(item, isNotNull);
      expect(await prefs.dripLastShownOn(), '2026-09-01');
    });
  });
}
