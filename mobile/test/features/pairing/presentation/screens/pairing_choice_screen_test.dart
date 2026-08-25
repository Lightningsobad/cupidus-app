import 'package:cupid_mobile/core/navigation/pair_gate_shell.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/invite_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/invite_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/pairing_choice_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The `create*Cubit` seams are supplied because both destinations otherwise
/// resolve a `getIt`-backed cubit, and this suite never calls
/// `setupServiceLocator()`.
Widget _harness({TextScaler? textScaler}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    // Applied above the navigator so the pushed route inherits the override
    // too; the `home` widget resolves its `MediaQuery` from here.
    builder: textScaler == null
        ? null
        : (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
    home: PairingChoiceScreen(
      createInviteCubit: () => InviteCubit(
        generateInvitation: () async => PairingInvitation(
          code: '3F9A2B',
          expiresAt: DateTime.utc(2026, 1, 2),
        ),
        now: () => DateTime.utc(2026, 1, 1),
      ),
      createJoincodeCubit: () => JoincodeCubit(acceptInvitation: (_) async {}),
    ),
  );
}

void main() {
  testWidgets('renders both entry actions under the pairing stack key', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.byKey(const Key('pairing_stack')), findsOneWidget);
    expect(find.text('Pair with your partner'), findsOneWidget);
    expect(find.text('I already have a code'), findsOneWidget);
  });

  testWidgets('the primary action opens invite', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    await tester.tap(find.text('Pair with your partner'));
    // Bounded pumps rather than `pumpAndSettle`: `InviteScreen`'s QR frame
    // animates forever, so no frame is ever quiet once it is mounted.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(InviteScreen), findsOneWidget);
    expect(find.byKey(const Key('pairing_stack')), findsNothing);
  });

  testWidgets('the secondary action opens joincode directly', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    await tester.tap(find.text('I already have a code'));
    await tester.pumpAndSettle();

    expect(find.byType(JoincodeScreen), findsOneWidget);
    expect(find.byType(InviteScreen), findsNothing);
  });

  testWidgets('carries no header or tab chrome (AC4 NO_CHROME/NO_TABS)', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(CupidHeader), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(CupidTabBar), findsNothing);
  });

  testWidgets('does not overflow on a rotated short viewport (AC1)', (
    tester,
  ) async {
    // A 360x640dp phone rotated to landscape, with 48dp of system insets so
    // `SafeArea` leaves the ~312dp usable height the regression was derived
    // against. `FakeViewPadding` is in physical pixels, hence dpr 1.0.
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness(textScaler: const TextScaler.linear(1.3)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('pairing_stack')), findsOneWidget);
    expect(find.text('Pair with your partner'), findsOneWidget);
  });

  group('AC4/AC5 back edges from the unpaired pair gate', () {
    testWidgets('invite pops back to the pairing stack', (tester) async {
      await tester.pumpWidget(_gateHarness());
      await tester.pump();

      expect(find.byKey(const Key('pairing_stack')), findsOneWidget);

      // Bounded pumps rather than `pumpAndSettle`: `InviteScreen`'s QR frame
      // animates forever, so no frame is ever quiet once it is mounted.
      await tester.tap(find.text('Ghép đôi với người ấy'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(InviteScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('pairing_stack')), findsOneWidget);
      expect(find.byType(InviteScreen), findsNothing);
    });

    testWidgets('join-code pops back to the pairing stack', (tester) async {
      await tester.pumpWidget(_gateHarness());
      await tester.pump();

      await tester.tap(find.text('Tôi đã có mã'));
      await tester.pumpAndSettle();
      expect(find.byType(JoincodeScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pairing_stack')), findsOneWidget);
      expect(find.byType(JoincodeScreen), findsNothing);
    });
  });
}

/// Mounts the real [PairGateShell] rather than [PairingChoiceScreen] directly,
/// so the entry point is proved (`PairGateUnpaired` really does render the
/// pairing stack) and the back edges resolve through the same navigator the app
/// uses — INV-2: pairing-choice is the only pusher, so `maybePop()` can only
/// land there.
///
/// Locale is `vi`, the only enabled user-facing configuration (OQ5 disposition).
Widget _gateHarness() {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: PairGateShell(
      createPairGateCubit: () => PairGateCubit(
        getPartnerLink: () async => const PartnerLink(partnerId: null),
      ),
      createInviteCubit: () => InviteCubit(
        generateInvitation: () async => PairingInvitation(
          code: '3F9A2B',
          expiresAt: DateTime.utc(2026, 1, 2),
        ),
        now: () => DateTime.utc(2026, 1, 1),
      ),
      createJoincodeCubit: () => JoincodeCubit(acceptInvitation: (_) async {}),
    ),
  );
}
