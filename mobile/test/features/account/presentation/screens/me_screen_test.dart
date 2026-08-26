import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/data/notification_preferences_store.dart';
import 'package:cupid_mobile/features/account/presentation/screens/me_screen.dart';
import 'package:cupid_mobile/features/account/presentation/screens/notification_settings_screen.dart';
import 'package:cupid_mobile/features/account/presentation/screens/privacy_screen.dart';
import 'package:cupid_mobile/features/account/presentation/screens/profile_edit_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/sign_out_action.dart';
import 'package:cupid_mobile/features/themes/data/themes_repository.dart';
import 'package:cupid_mobile/features/themes/presentation/screens/theme_store_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _Handler = ResponseBody Function(RequestOptions options, String? body);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final _Handler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options, null);

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> json, {int statusCode = 200}) {
  return ResponseBody.fromBytes(
    utf8.encode(jsonEncode(json)),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> _profileJson() => {
  'id': 'user-1',
  'email': 'alex@example.com',
  'displayName': 'Alex',
  'photoUrl': null,
  'birthday': '1996-05-15',
  'relationshipStartDate': null,
  'zodiacSign': 'Taurus',
  'language': 'vi',
  'partnerId': null,
  'coupleType': null,
  'vowTaken': false,
  'isGhostModeEnabled': true,
};

AccountRepository _repository(_Handler handler) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.httpClientAdapter = _FakeAdapter(handler);
  dio.interceptors.add(const CupidErrorInterceptor());
  return AccountRepository(api: CupidApi(dio: dio, interceptors: const []));
}

Widget _harness(AccountRepository repository) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: MeScreen(accountRepository: repository),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    getIt.registerLazySingleton<NotificationPreferencesStore>(
      NotificationPreferencesStore.new,
    );
    getIt.registerLazySingleton<ThemesRepository>(
      () => ThemesRepository(
        api: CupidApi(
          dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
            ..httpClientAdapter = _FakeAdapter(
              (options, body) => _jsonBody({
                'coupleId': 'userA:userB',
                'activeThemeId': 'nebula',
                'ownedThemeIds': <String>['nebula'],
                'heartsBalance': 1000,
              }),
            ),
          interceptors: const [],
        ),
      ),
    );
  });

  tearDown(() {
    getIt.unregister<NotificationPreferencesStore>();
    getIt.unregister<ThemesRepository>();
  });

  group('MeScreen', () {
    testWidgets('shows the loading state while the profile fetch is in flight', (
      tester,
    ) async {
      final repository = _repository((options, body) => _jsonBody(_profileJson()));

      await tester.pumpWidget(_harness(repository));

      expect(find.text('Loading profile…'), findsOneWidget);

      // Drain the in-flight fetch so no timer is left pending at teardown.
      await tester.pumpAndSettle();
    });

    testWidgets(
      'renders the profile summary and menu rows once loaded, with no sign-out action',
      (tester) async {
        final repository = _repository((options, body) => _jsonBody(_profileJson()));

        await tester.pumpWidget(_harness(repository));
        await tester.pumpAndSettle();

        expect(find.text('Alex'), findsOneWidget);
        expect(find.text('My data'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Typing Ghost'), findsOneWidget);
        expect(find.text('Love Contract'), findsOneWidget);
        expect(find.byType(SignOutAction), findsNothing);
      },
    );

    testWidgets('shows a retry action on load failure that re-triggers the fetch', (
      tester,
    ) async {
      var callCount = 0;
      final repository = _repository((options, body) {
        callCount++;
        return _jsonBody({'message': 'boom'}, statusCode: 500);
      });

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load your profile"), findsOneWidget);
      expect(callCount, 1);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(callCount, 2);
    });

    testWidgets('tapping the privacy row navigates to PrivacyScreen', (
      tester,
    ) async {
      final repository = _repository((options, body) => _jsonBody(_profileJson()));

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My data'));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyScreen), findsOneWidget);
    });

    testWidgets(
      'tapping the notifications row navigates to NotificationSettingsScreen',
      (tester) async {
        final repository = _repository((options, body) => _jsonBody(_profileJson()));

        await tester.pumpWidget(_harness(repository));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Notifications'));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationSettingsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'tapping the Theme store row navigates to ThemeStoreScreen',
      (tester) async {
        final repository = _repository((options, body) => _jsonBody(_profileJson()));

        await tester.pumpWidget(_harness(repository));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Theme store'));
        await tester.pumpAndSettle();

        expect(find.byType(ThemeStoreScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Typing Ghost and Love Contract rows remain non-interactive',
      (tester) async {
        final repository = _repository((options, body) => _jsonBody(_profileJson()));

        await tester.pumpWidget(_harness(repository));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Typing Ghost'));
        await tester.pumpAndSettle();
        expect(find.text('Typing Ghost'), findsOneWidget);
        expect(find.byType(PrivacyScreen), findsNothing);
        expect(find.byType(NotificationSettingsScreen), findsNothing);

        await tester.tap(find.text('Love Contract'));
        await tester.pumpAndSettle();
        expect(find.text('Love Contract'), findsOneWidget);
        expect(find.byType(PrivacyScreen), findsNothing);
        expect(find.byType(NotificationSettingsScreen), findsNothing);
      },
    );

    testWidgets(
      'renders every settings row the design source states, in order',
      (tester) async {
        final repository = _repository((options, body) => _jsonBody(_profileJson()));

        await tester.pumpWidget(_harness(repository));
        await tester.pumpAndSettle();

        expect(
          tester
              .widgetList<Text>(find.byType(Text))
              .map((text) => text.data)
              .whereType<String>()
              .where(_designRowLabels.contains)
              .toList(),
          _designRowLabels,
        );
      },
    );

    testWidgets('renders the zodiac icon and birthday beside the name', (
      tester,
    ) async {
      final repository = _repository((options, body) => _jsonBody(_profileJson()));

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      final icon = tester.widget<CupidZodiacIcon>(
        find.byType(CupidZodiacIcon),
      );
      expect(icon.sign, CupidZodiacSign.taurus);
      expect(find.text('Taurus'), findsOneWidget);
      expect(find.text('15/05/1996'), findsOneWidget);
    });

    testWidgets('trailing values read from the loaded profile', (tester) async {
      final repository = _repository(
        (options, body) => _jsonBody({
          ..._profileJson(),
          'isGhostModeEnabled': false,
          'language': 'en',
        }),
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(find.text('OFF'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('renders the Digital Divorce teaser and the version line', (
      tester,
    ) async {
      final repository = _repository((options, body) => _jsonBody(_profileJson()));

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      // Both sit below the default test viewport's fold.
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Digital Divorce'), findsOneWidget);
      expect(find.text('Phase 1.5'), findsOneWidget);
      expect(
        find.text('Cupid 1.0.0 (MVP) · iOS 15+ / Android 8+'),
        findsOneWidget,
      );
    });

    testWidgets('tapping the profile summary card opens the edit screen', (
      tester,
    ) async {
      final repository = _repository((options, body) => _jsonBody(_profileJson()));

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alex'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileEditScreen), findsOneWidget);
    });
  });
}

/// The seven rows of `Cupid Screens.dc.html` §isMe, in source order.
const List<String> _designRowLabels = <String>[
  'My data',
  'Notifications',
  'Theme store',
  'Share cards',
  'Typing Ghost',
  'Love Contract',
  'Language',
];
