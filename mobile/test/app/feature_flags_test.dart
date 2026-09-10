import 'dart:typed_data';

import 'package:cupid_mobile/app/cupid_app.dart';
import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/config/cupid_feature_flags.dart';
import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/activity_card_dao.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/theme/cupid_platform.dart';
import 'package:cupid_mobile/design_system/theme/cupid_theme.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/auth/presentation/session_gate_cubit.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake [HttpClientAdapter] so `ChatEntryGate`'s best-effort
/// `refreshFromServer()` call (`chat_entry_gate.dart:38`) never reaches a
/// real network; mirrors `test/core/navigation/app_shell_test.dart`.
///
/// `/users/me` answers with a partner id on purpose. This test declares a
/// paired session through `PairGateCubit`, but `HomeScreen` resolves pairing a
/// second time through its own `getIt<CouplePairingStore>()`; an empty `{}`
/// there would report unpaired and (post-REQ-016 P9) mount the solo card hub
/// instead of the couple dashboard this test asserts on. Same shape as
/// `app_shell_test.dart`'s paired harness.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String body = options.path == '/users/me'
        ? '{"partnerId":"partner-1","displayName":"Partner One",'
              '"isGhostModeEnabled":false}'
        : '{}';
    return ResponseBody.fromString(
      body,
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
    // `HomeScreen` (mounted by `AppShell`'s Home tab) has no override hook
    // for its default `getIt<CouplePairingStore>()` lookup, unlike
    // `AppShell`'s other stores above; register one backed by the same fake
    // adapter so the readiness gate resolves without a real network call.
    getIt.registerSingleton<CouplePairingStore>(
      CouplePairingStore(
        api: CupidApi(dio: dio, interceptors: const []),
        backendUserIdStore: BackendUserIdStore(),
      ),
    );
    // REQ-016 STORY-001 P9: the fake adapter answers `/users/me` with `{}`, so
    // `HomeScreen`'s own resolver reports unpaired and mounts the solo card
    // hub, which resolves its repository through the composition root. An
    // in-memory database keeps that off disk and off the network; mirrors
    // `test/core/navigation/app_shell_test.dart`.
    final backendUserIdStore = BackendUserIdStore()
      ..updateFromLoginResponse(<String, Object?>{'id': 'u1'});
    final activityDatabase = CupidDatabase(NativeDatabase.memory());
    getIt.registerSingleton<CupidDatabase>(
      activityDatabase,
      dispose: (CupidDatabase database) => database.close(),
    );
    getIt.registerSingleton<ActivityCardRepository>(
      ActivityCardRepositoryImpl(
        dao: ActivityCardDao(activityDatabase),
        ownerKeyStore: backendUserIdStore,
      ),
    );
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
      await tester.pumpWidget(
        CupidApp(
          // REQ-002 STORY-001 ADR-1: splash is the entry route now, so booting
          // to home means resolving the launch session check first. A real
          // `CupidSession` needs a live/mocked `FirebaseAuth`, hence the seam.
          createSessionGateCubit: () => SessionGateCubit(
            sessionState: Stream<CupidSessionState>.value(
              const CupidSessionSignedIn(uid: 'u1', email: 'a@b.com'),
            ),
            idToken: ({forceRefresh = false}) async => 'token',
          ),
          createPairGateCubit: () => PairGateCubit(
            getPartnerLink: () async =>
                const PartnerLink(partnerId: 'partner-1'),
          ),
        ),
      );
      // Not pumpAndSettle: CupidAppBackground twinkles forever at the
      // composition root, so the tree never settles. Order matters: clear the
      // splash's 2s dwell (AC4) first so it calls pushReplacement, then pump
      // the frame that builds the pushed route plus its 300ms transition.
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

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
