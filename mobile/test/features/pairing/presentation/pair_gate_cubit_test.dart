import 'package:cupid_mobile/core/navigation/app_shell.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/invite_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/invite_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/paired_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fakes for [AppShell]'s [InviteScreen]/[JoincodeScreen] test seams: both
/// screens otherwise default to a `getIt`-backed cubit, which this test's
/// harness never registers (mirrors `invite_screen_test.dart`'s own fake
/// pattern).
Widget _harness({required Future<PartnerLink> Function() getPartnerLink}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: AppShell(
      createPairGateCubit: () => PairGateCubit(getPartnerLink: getPartnerLink),
      createInviteCubit: () => InviteCubit(
        generateInvitation: () async => PairingInvitation(
          code: '3F9A2B',
          expiresAt: DateTime.utc(2026, 1, 2),
        ),
      ),
      createJoincodeCubit: () =>
          JoincodeCubit(acceptInvitation: (_) async {}),
    ),
  );
}

void main() {
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
        getPartnerLink: () async =>
            const PartnerLink(partnerId: 'partner-1'),
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

  group('AppShell gate (AC4)', () {
    testWidgets(
      'unpaired routes into the pairing stack with no tab bar and a '
      'reachable "Pair with your partner" entry action',
      (tester) async {
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
      },
    );

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
          getPartnerLink: () async =>
              const PartnerLink(partnerId: 'partner-1'),
        ),
      );
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('pairing_stack')), findsNothing);
    });

    testWidgets('a failed check falls back to the pairing stack, never '
        'exposing the tab shell while unresolved', (tester) async {
      await tester.pumpWidget(
        _harness(
          getPartnerLink: () async => throw Exception('network error'),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('pairing_stack')), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
