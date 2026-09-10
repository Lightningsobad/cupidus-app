import 'dart:typed_data';

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/activity_card_dao.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/navigation/pair_gate_shell.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/invite_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/paired_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Always returns `{}`; mirrors `test/features/reminders/
/// reminder_entry_point_test.dart`. This suite drives the gate through
/// [PairGateShell]'s injected [PairGateCubit], so the stores below only need a
/// non-throwing `/users/me` response, never a real payload.
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

/// Fakes for [PairGateShell]'s still-accepted (but now unreachable)
/// `createInviteCubit`/`createJoincodeCubit` constructor seams: both cubits
/// otherwise default to a `getIt`-backed dependency, which this test's
/// harness never registers (mirrors `invite_screen_test.dart`'s own fake
/// pattern).
///
/// `partnerStore` is threaded through to the paired branch's [AppShell], whose
/// `ChatEntryGate` wrap resolves it eagerly on build.
///
/// `router` stands in for the `getIt`-registered production registry, which
/// this harness never calls `setupServiceLocator()` to build. Only `paired` is
/// registered: it is the one node the pairing leg's tail actually resets to.
Widget _harness({required Future<PartnerLink> Function() getPartnerLink}) {
  final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter();
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: PairGateShell(
      createPairGateCubit: () => PairGateCubit(getPartnerLink: getPartnerLink),
      createInviteCubit: () => InviteCubit(
        generateInvitation: () async => PairingInvitation(
          code: '3F9A2B',
          expiresAt: DateTime.utc(2026, 1, 2),
        ),
      ),
      createJoincodeCubit: () => JoincodeCubit(acceptInvitation: (_) async {}),
      router: OnboardingRouter(
        builders: <OnboardingNode, WidgetBuilder>{
          OnboardingNode.paired: (_) => const PairedScreen(),
        },
      ),
      partnerStore: ChatPartnerStore(dio: dio),
    ),
  );
}

/// Registers the composition-root dependencies the solo surface's
/// `ActivityCardHubView` resolves through `getIt`, backed by an in-memory
/// database — mirrors `test/core/navigation/pair_gate_shell_test.dart`'s
/// harness.
void _registerActivityCardRepository() {
  final BackendUserIdStore backendUserIdStore = BackendUserIdStore()
    ..updateFromLoginResponse(<String, Object?>{'id': 'me-1'});
  final CupidDatabase database = CupidDatabase(NativeDatabase.memory());
  getIt.registerSingleton<CupidDatabase>(
    database,
    dispose: (CupidDatabase db) => db.close(),
  );
  getIt.registerSingleton<ActivityCardRepository>(
    ActivityCardRepositoryImpl(
      dao: ActivityCardDao(database),
      ownerKeyStore: backendUserIdStore,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    _registerActivityCardRepository();
    // The paired branch mounts `AppShell`, whose Home tab resolves
    // `CouplePairingStore` through GetIt on build with no constructor
    // override reachable from `AppShell`'s `const HomeScreen()`.
    getIt.registerSingleton<CouplePairingStore>(
      CouplePairingStore(
        api: CupidApi(
          dio: Dio()..httpClientAdapter = _FakeHttpClientAdapter(),
          interceptors: const [],
        ),
        backendUserIdStore: BackendUserIdStore(),
      ),
    );
  });

  tearDown(() => getIt.reset());

  group('PairGateCubit', () {
    test('emits PairGateUnpaired when partnerId is null', () async {
      final cubit = PairGateCubit(
        getPartnerLink: () async => const PartnerLink(partnerId: null),
      );
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state, isA<PairGateUnpaired>());
    });

    test('emits PairGatePaired when partnerId is non-null', () async {
      final cubit = PairGateCubit(
        getPartnerLink: () async => const PartnerLink(partnerId: 'partner-1'),
      );
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state, isA<PairGatePaired>());
    });

    test('emits PairGateNetworkError when check throws NetworkUnavailableFailure', () async {
      final cubit = PairGateCubit(
        getPartnerLink: () async => throw const NetworkUnavailableFailure(),
      );
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state, isA<PairGateNetworkError>());
    });

    test('emits PairGateNetworkError when check throws TimeoutFailure', () async {
      final cubit = PairGateCubit(
        getPartnerLink: () async => throw const TimeoutFailure(),
      );
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state, isA<PairGateNetworkError>());
    });

    test('emits PairGateUnpaired (fail-safe) when the check throws unexpected error', () async {
      final cubit = PairGateCubit(
        getPartnerLink: () async =>
            throw Exception('unexpected error'),
      );
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state, isA<PairGateUnpaired>());
    });

    test('starts in PairGateChecking before the check resolves', () {
      final cubit = PairGateCubit(
        getPartnerLink: () async => const PartnerLink(partnerId: null),
      );
      addTearDown(cubit.close);

      expect(cubit.state, isA<PairGateChecking>());
    });

    test('retry() transitions through PairGateChecking and re-evaluates', () async {
      var shouldFail = true;
      final cubit = PairGateCubit(
        getPartnerLink: () async {
          if (shouldFail) {
            throw const NetworkUnavailableFailure();
          }
          return const PartnerLink(partnerId: 'partner-1');
        },
      );
      addTearDown(cubit.close);

      await pumpEventQueue();
      expect(cubit.state, isA<PairGateNetworkError>());

      shouldFail = false;
      cubit.retry();
      expect(cubit.state, isA<PairGateChecking>());

      await pumpEventQueue();
      expect(cubit.state, isA<PairGatePaired>());
    });
  });

  group('PairGateShell gate (AC4)', () {
    testWidgets('unpaired routes into the solo surface, never the couple '
        'dashboard', (tester) async {
      await tester.pumpWidget(
        _harness(
          getPartnerLink: () async => const PartnerLink(partnerId: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('solo_stage_one_shell')), findsOneWidget);
      expect(find.byKey(const Key('home_screen_ready_signal')), findsNothing);
    });

    testWidgets('paired routes into the main tab shell', (tester) async {
      await tester.pumpWidget(
        _harness(
          getPartnerLink: () async => const PartnerLink(partnerId: 'partner-1'),
        ),
      );
      // Settles rather than single-pumps: unlike the unpaired branches, this
      // one really mounts `AppShell`, whose `ChatEntryGate` and Home tab each
      // kick off a store fetch on build (mirrors `app_shell_test.dart`).
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('pairing_stack')), findsNothing);
    });

    testWidgets('a failed check with network error renders network error screen and retry works', (tester) async {
      var shouldFail = true;
      await tester.pumpWidget(
        _harness(
          getPartnerLink: () async {
            if (shouldFail) {
              throw const NetworkUnavailableFailure();
            }
            return const PartnerLink(partnerId: 'partner-1');
          },
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('pair_gate_network_error')), findsOneWidget);
      expect(find.text('Cannot connect to server'), findsOneWidget);
      expect(find.byKey(const Key('pairing_stack')), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);

      // Tap Retry
      shouldFail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('pair_gate_network_error')), findsNothing);
    });

    testWidgets('a non-network failed check falls back to the solo surface (fail-safe)', (tester) async {
      await tester.pumpWidget(
        _harness(getPartnerLink: () async => throw Exception('fatal error')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pairing_stack')), findsNothing);
      expect(find.byKey(const Key('solo_stage_one_shell')), findsOneWidget);
      expect(find.byKey(const Key('pair_gate_network_error')), findsNothing);
    });
  });
}
