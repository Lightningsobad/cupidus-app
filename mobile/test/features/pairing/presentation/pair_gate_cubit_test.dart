import 'package:cupid_mobile/core/navigation/app_shell.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness({required Future<PartnerLink> Function() getPartnerLink}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: AppShell(
      createPairGateCubit: () => PairGateCubit(getPartnerLink: getPartnerLink),
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

        // Reachable: tappable without throwing.
        await tester.tap(find.text('Pair with your partner'));
        await tester.pump();
        expect(find.byKey(const Key('pairing_stack')), findsOneWidget);
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
