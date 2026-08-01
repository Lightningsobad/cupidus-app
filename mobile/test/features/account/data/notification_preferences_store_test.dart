import 'package:cupid_mobile/features/account/data/notification_preferences_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('NotificationPreferencesStore persistence (§6.2 P5, OQ-B)', () {
    test('load returns the design-source defaults when nothing is persisted', () async {
      final store = NotificationPreferencesStore();

      final preferences = await store.load();

      expect(preferences, NotificationPreferencesStore.defaults);
    });

    test('a toggled preference survives a store re-instantiation', () async {
      final first = NotificationPreferencesStore();
      await first.setEnabled('baeTyping', true);

      final second = NotificationPreferencesStore();
      final preferences = await second.load();

      expect(preferences['baeTyping'], isTrue);
      expect(
        preferences['syncedAlarm'],
        NotificationPreferencesStore.defaults['syncedAlarm'],
      );
    });

    test('setEnabled leaves every other row untouched', () async {
      final store = NotificationPreferencesStore();

      await store.setEnabled('loveTimelineOnThisDay', true);
      await store.setEnabled('vibeCheck', false);

      final preferences = await store.load();

      expect(preferences['loveTimelineOnThisDay'], isTrue);
      expect(preferences['vibeCheck'], isFalse);
      expect(preferences['emojiStorm'], NotificationPreferencesStore.defaults['emojiStorm']);
    });

    test('clearOnSignOut resets every row back to defaults', () async {
      final store = NotificationPreferencesStore();
      await store.setEnabled('baeTyping', true);

      await store.clearOnSignOut();

      expect(await store.load(), NotificationPreferencesStore.defaults);
    });
  });
}
