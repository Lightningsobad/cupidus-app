import 'package:cupid_mobile/features/account/data/notification_preferences_store.dart';
import 'package:cupid_mobile/features/account/presentation/notification_settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('NotificationSettingsCubit', () {
    test('emits loaded with the persisted defaults on construction', () async {
      final cubit = NotificationSettingsCubit(
        store: NotificationPreferencesStore(),
      );
      addTearDown(cubit.close);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<NotificationSettingsLoaded>()]),
      );

      await expectation;
      expect(
        (cubit.state as NotificationSettingsLoaded).preferences,
        NotificationPreferencesStore.defaults,
      );
    });

    test('setEnabled emits the flipped value and persists it', () async {
      final store = NotificationPreferencesStore();
      final cubit = NotificationSettingsCubit(store: store);
      addTearDown(cubit.close);

      await expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<NotificationSettingsLoaded>()]),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<NotificationSettingsLoaded>()]),
      );
      await cubit.setEnabled('baeTyping', true);
      await expectation;

      expect(
        (cubit.state as NotificationSettingsLoaded).preferences['baeTyping'],
        isTrue,
      );
      expect((await store.load())['baeTyping'], isTrue);
    });
  });
}
