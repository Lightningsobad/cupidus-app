import 'package:cupid_mobile/features/phase_status/data/phase_status_prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PhaseStatusPrefs prefs;

  void useStore(Map<String, Object> initial) {
    SharedPreferences.setMockInitialValues(initial);
    prefs = PhaseStatusPrefs();
  }

  setUp(() => useStore(<String, Object>{}));

  group('key names — copy exactly', () {
    test('the reminder key is namespaced per card', () {
      expect(
        phaseStatusRemindedOnKey('card-42'),
        'phase_status.reminded_on.card-42',
      );
    });

    test('the five fixed keys match the phase contract', () {
      expect(phaseStatusDripLastShownOnKey, 'phase_status.drip.last_shown_on');
      expect(phaseStatusDripSeenIdsKey, 'phase_status.drip.seen_ids');
      expect(
        phaseStatusMilestoneLastShownValueKey,
        'phase_status.milestone.last_shown_value',
      );
      expect(
        phaseStatusEveningCheckInEnabledKey,
        'notifications.evening_check_in.enabled',
      );
      expect(
        phaseStatusQuietDripEnabledKey,
        'notifications.quiet_drip.enabled',
      );
    });

    test('a write lands under the exact key and nowhere else', () async {
      await prefs.markReminded('card-42', '2026-09-15');

      final SharedPreferences raw = await SharedPreferences.getInstance();
      expect(raw.getString('phase_status.reminded_on.card-42'), '2026-09-15');
      expect(raw.getKeys(), <String>{'phase_status.reminded_on.card-42'});
    });
  });

  group('reminder record', () {
    test('is absent until the reminder is handled', () async {
      expect(await prefs.remindedOn('card-1'), isNull);
    });

    test('records the civil date it applies to', () async {
      await prefs.markReminded('card-1', '2026-09-15');

      expect(await prefs.remindedOn('card-1'), '2026-09-15');
      expect(await prefs.remindedOn('card-2'), isNull);
    });

    test('clearing removes the key rather than writing a sentinel', () async {
      await prefs.markReminded('card-1', '2026-09-15');
      await prefs.clearReminded('card-1');

      expect(await prefs.remindedOn('card-1'), isNull);
      final SharedPreferences raw = await SharedPreferences.getInstance();
      expect(raw.getKeys(), isEmpty);
    });
  });

  group('drip cursor', () {
    test('starts with no date and no seen ids', () async {
      expect(await prefs.dripLastShownOn(), isNull);
      expect(await prefs.dripSeenIds(), isEmpty);
    });

    test('stores the last shown civil date', () async {
      await prefs.setDripLastShownOn('2026-09-15');
      expect(await prefs.dripLastShownOn(), '2026-09-15');
    });

    test('appends seen ids in order', () async {
      await prefs.markDripSeen('drip.a.v1');
      await prefs.markDripSeen('drip.b.v1');

      expect(await prefs.dripSeenIds(), <String>['drip.a.v1', 'drip.b.v1']);
    });

    test('re-marking an id is a no-op', () async {
      await prefs.markDripSeen('drip.a.v1');
      await prefs.markDripSeen('drip.a.v1');

      expect(await prefs.dripSeenIds(), <String>['drip.a.v1']);
    });

    test('the returned list cannot be mutated by a caller', () async {
      await prefs.markDripSeen('drip.a.v1');
      final List<String> seen = await prefs.dripSeenIds();

      expect(() => seen.add('drip.b.v1'), throwsUnsupportedError);
    });
  });

  group('milestone cursor', () {
    test('null and zero are different states', () async {
      expect(await prefs.milestoneLastShownValue(), isNull);

      await prefs.setMilestoneLastShownValue(0);
      expect(await prefs.milestoneLastShownValue(), 0);
    });

    test('stores the announced threshold', () async {
      await prefs.setMilestoneLastShownValue(25);
      expect(await prefs.milestoneLastShownValue(), 25);
    });
  });

  group('notification toggles', () {
    test('both default to on without a first-run write', () async {
      expect(await prefs.eveningCheckInEnabled(), isTrue);
      expect(await prefs.quietDripEnabled(), isTrue);

      final SharedPreferences raw = await SharedPreferences.getInstance();
      expect(raw.getKeys(), isEmpty);
    });

    test('turning one off is an explicit stored false', () async {
      await prefs.setEveningCheckInEnabled(false);

      expect(await prefs.eveningCheckInEnabled(), isFalse);
      expect(await prefs.quietDripEnabled(), isTrue);

      final SharedPreferences raw = await SharedPreferences.getInstance();
      expect(raw.getBool('notifications.evening_check_in.enabled'), isFalse);
    });

    test('an existing stored value is honoured on load', () async {
      useStore(<String, Object>{
        'notifications.quiet_drip.enabled': false,
      });

      expect(await prefs.quietDripEnabled(), isFalse);
      expect(await prefs.eveningCheckInEnabled(), isTrue);
    });

    test('the two toggles are independent', () async {
      await prefs.setQuietDripEnabled(false);
      await prefs.setEveningCheckInEnabled(true);

      expect(await prefs.quietDripEnabled(), isFalse);
      expect(await prefs.eveningCheckInEnabled(), isTrue);
    });
  });

  test('an injected accessor is used instead of the real store', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'phase_status.drip.last_shown_on': '2026-01-01',
    });
    int calls = 0;
    final PhaseStatusPrefs injected = PhaseStatusPrefs(
      preferences: () async {
        calls++;
        return SharedPreferences.getInstance();
      },
    );

    expect(await injected.dripLastShownOn(), '2026-01-01');
    expect(calls, 1);
  });
}
