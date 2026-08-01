import 'package:cupid_mobile/features/reminders/data/reminder_local_prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ReminderLocalPrefs weekdays', () {
    test('loadWeekdays returns empty when nothing was saved', () async {
      final prefs = ReminderLocalPrefs();

      expect(await prefs.loadWeekdays(), isEmpty);
    });

    test('a saved weekday selection survives a store re-instantiation', () async {
      final first = ReminderLocalPrefs();
      await first.saveWeekdays({1, 3, 5});

      final second = ReminderLocalPrefs();

      expect(await second.loadWeekdays(), {1, 3, 5});
    });

    test('saveWeekdays overwrites a previous selection', () async {
      final prefs = ReminderLocalPrefs();
      await prefs.saveWeekdays({1, 2});

      await prefs.saveWeekdays({6, 7});

      expect(await prefs.loadWeekdays(), {6, 7});
    });
  });

  group('ReminderLocalPrefs pending timeout notice', () {
    test('loadPendingTimeoutNotice defaults to false', () async {
      final prefs = ReminderLocalPrefs();

      expect(await prefs.loadPendingTimeoutNotice(), isFalse);
    });

    test('a set notice flag survives a store re-instantiation', () async {
      final first = ReminderLocalPrefs();
      await first.setPendingTimeoutNotice(true);

      final second = ReminderLocalPrefs();

      expect(await second.loadPendingTimeoutNotice(), isTrue);
    });

    test('setPendingTimeoutNotice(false) clears a previously set flag', () async {
      final prefs = ReminderLocalPrefs();
      await prefs.setPendingTimeoutNotice(true);

      await prefs.setPendingTimeoutNotice(false);

      expect(await prefs.loadPendingTimeoutNotice(), isFalse);
    });
  });

  group('ReminderLocalPrefs.clearOnSignOut', () {
    test('removes both the weekday selection and the notice flag', () async {
      final prefs = ReminderLocalPrefs();
      await prefs.saveWeekdays({2, 4});
      await prefs.setPendingTimeoutNotice(true);

      await prefs.clearOnSignOut();

      expect(await prefs.loadWeekdays(), isEmpty);
      expect(await prefs.loadPendingTimeoutNotice(), isFalse);
    });
  });
}
