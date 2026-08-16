import 'dart:typed_data';

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/navigation/pair_gate_shell.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/invite_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/invite_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/paired_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
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

/// Fakes for [PairGateShell]'s [InviteScreen]/[JoincodeScreen] test seams: both
/// screens otherwise default to a `getIt`-backed cubit, which this test's
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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
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

    test('emits PairGateUnpaired (fail-safe) when the check throws', () async {
      final cubit = PairGateCubit(
        getPartnerLink: () async =>
            throw Exception('transient network failure'),
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
  });

  group('PairGateShell gate (AC4)', () {
    testWidgets('unpaired routes into the pairing stack with no tab bar and a '
        'reachable "Pair with your partner" entry action', (tester) async {
      await tester.pumpWidget(
        _harness(
          getPartnerLink: () async => const PartnerLink(partnerId: null),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('pairing_stack')), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.text('Pair with your partner'), findsOneWidget);
      expect(find.text('I already have a code'), findsOneWidget);

      // Reachable: tapping the primary entry action actually navigates to
      // InviteScreen, not just "tappable without throwing".
      await tester.tap(find.text('Pair with your partner'));
      await tester.pumpAndSettle();
      expect(find.byType(InviteScreen), findsOneWidget);
      expect(find.byKey(const Key('pairing_stack')), findsNothing);
    });

    testWidgets(
      '"I already have a code" navigates directly to JoincodeScreen',
      (tester) async {
        await tester.pumpWidget(
          _harness(
            getPartnerLink: () async => const PartnerLink(partnerId: null),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('I already have a code'));
        await tester.pumpAndSettle();

        expect(find.byType(JoincodeScreen), findsOneWidget);
        expect(find.byKey(const Key('pairing_stack')), findsNothing);
      },
    );

    testWidgets(
      'accepting a code via "I already have a code" navigates through to '
      'PairedScreen (onPaired production wiring)',
      (tester) async {
        await tester.pumpWidget(
          _harness(
            getPartnerLink: () async => const PartnerLink(partnerId: null),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('I already have a code'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '3F9A2B');
        await tester.tap(find.text('Pair up'));
        await tester.pump();
        await tester.pump();
        // Bounded pumps rather than `pumpAndSettle`: `PairedScreen`'s bob
        // animation repeats forever by design and would never settle
        // (mirrors `paired_screen_test.dart`'s own pattern).
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(PairedScreen), findsOneWidget);
        expect(find.byType(JoincodeScreen), findsNothing);
      },
    );

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

    testWidgets('a failed check falls back to the pairing stack, never '
        'exposing the tab shell while unresolved', (tester) async {
      await tester.pumpWidget(
        _harness(getPartnerLink: () async => throw Exception('network error')),
      );
      await tester.pump();

      expect(find.byKey(const Key('pairing_stack')), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
