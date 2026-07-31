import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/account/presentation/screens/profile_edit_screen.dart';
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

AccountRepository _repository(_Handler handler) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.httpClientAdapter = _FakeAdapter(handler);
  dio.interceptors.add(const CupidErrorInterceptor());
  return AccountRepository(api: CupidApi(dio: dio, interceptors: const []));
}

final CupidProfile _profile = CupidProfile(
  id: 'user-1',
  email: 'alex@example.com',
  language: 'vi',
  vowTaken: false,
  isGhostModeEnabled: true,
  displayName: 'Alex',
  birthday: DateTime(1996, 5, 15),
  zodiacSign: 'Taurus',
);

Widget _harness(AccountRepository repository) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: ProfileEditScreen(accountRepository: repository, profile: _profile),
  );
}

void main() {
  group('ProfileEditScreen', () {
    testWidgets('renders fields populated from the initial profile', (tester) async {
      final repository = _repository((options, body) => _jsonBody({}));

      await tester.pumpWidget(_harness(repository));

      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('15/05/1996'), findsOneWidget);
      expect(find.text('Taurus'), findsOneWidget);
    });

    testWidgets('Save is disabled until the draft becomes dirty', (tester) async {
      final repository = _repository((options, body) => _jsonBody({}));

      await tester.pumpWidget(_harness(repository));

      final TextButton saveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(saveButton.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Alexandra');
      await tester.pump();

      final TextButton dirtySaveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(dirtySaveButton.onPressed, isNotNull);
    });

    testWidgets('shows an inline error and blocks submit when the name is cleared', (
      tester,
    ) async {
      var patchCalls = 0;
      final repository = _repository((options, body) {
        if (options.method == 'PATCH') patchCalls++;
        return _jsonBody({});
      });

      await tester.pumpWidget(_harness(repository));

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Display name is required'), findsOneWidget);
      expect(patchCalls, 0);
    });
  });
}
