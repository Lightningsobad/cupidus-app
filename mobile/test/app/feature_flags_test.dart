import 'dart:typed_data';

import 'package:cupid_mobile/app/cupid_app.dart';
import 'package:cupid_mobile/core/config/cupid_feature_flags.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/theme/cupid_platform.dart';
import 'package:cupid_mobile/design_system/theme/cupid_theme.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake [HttpClientAdapter] so `ChatEntryGate`'s best-effort
/// `refreshFromServer()` call (`chat_entry_gate.dart:38`) never reaches a
/// real network; mirrors `test/core/navigation/app_shell_test.dart`.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() async {
    await getIt.reset();
    final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter();
    getIt.registerSingleton<ChatPartnerStore>(ChatPartnerStore(dio: dio));
  });

  tearDown(() => getIt.reset());

  test('CupidFeatureFlags default to false with no --dart-define supplied', () {
    expect(CupidFeatureFlags.enableLightTheme, isFalse);
    expect(CupidFeatureFlags.enableEnLocale, isFalse);
  });

  testWidgets(
    'CupidApp resolves dark theme mode and vi locale with flags off, and '
    'the runtime readiness key still resolves',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CupidApp());
      await tester.pumpAndSettle();

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.themeMode, ThemeMode.dark);
      expect(app.locale, const Locale('vi'));
      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
    },
  );

  test(
    'light ThemeData stays directly constructible with flags off '
    '(flags gate exposure, never existence, per OQ5)',
    () {
      final ThemeData light = buildCupidTheme(
        platform: CupidPlatform.resolveDefault(),
        brightness: Brightness.light,
      );

      expect(light.brightness, Brightness.light);
    },
  );

  testWidgets(
    'AppL10n under Locale(en) stays directly constructible with flags off',
    (WidgetTester tester) async {
      late AppL10n l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              l10n = AppL10n.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(l10n.app_root_title, isNotEmpty);
    },
  );
}
