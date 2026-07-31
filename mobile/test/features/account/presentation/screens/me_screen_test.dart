import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/presentation/screens/me_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/sign_out_action.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}
