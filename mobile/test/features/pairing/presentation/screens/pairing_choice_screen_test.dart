import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/presentation/invite_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
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

/// The three option rows in the design source's own top-to-bottom order.
const List<(Key, String, IconData)> _rows = <(Key, String, IconData)>[
  (createCodeRowKey, "I'll create the code", CupidIcons.qrCode2),
  (enterCodeRowKey, 'They already have a code', CupidIcons.dialpad),
  (scanQrRowKey, 'Scan the QR on their phone', CupidIcons.qrCodeScanner),
];

void main() {
  testWidgets('renders exactly the three option rows, in order, under the '
      'pairing stack key', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.byKey(const Key('pairing_stack')), findsOneWidget);
    expect(find.byType(InkWell), findsNWidgets(_rows.length));

    double previousTop = double.negativeInfinity;
    for (final (Key key, String title, IconData icon) in _rows) {
      expect(find.byKey(key), findsOneWidget, reason: '$title row is missing');
      expect(find.text(title), findsOneWidget);
      expect(
        find.descendant(of: find.byKey(key), matching: find.byIcon(icon)),
        findsOneWidget,
        reason: '$title must carry its own design-source glyph',
      );

      final double top = tester.getTopLeft(find.byKey(key)).dy;
      expect(top, greaterThan(previousTop), reason: 'row order must match the '
          'design source: create code, enter code manually, scan QR');
      previousTop = top;
    }

    // The two-option layout this screen replaced (AC1).
    expect(find.byType(CupidPrimaryButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('the create-code row opens invite', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    await tester.tap(find.byKey(createCodeRowKey));
    // Bounded pumps rather than `pumpAndSettle`: `InviteScreen`'s QR frame
    // animates forever, so no frame is ever quiet once it is mounted.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(InviteScreen), findsOneWidget);
    expect(find.byKey(const Key('pairing_stack')), findsNothing);
  });

  testWidgets('the enter-code row opens joincode directly', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    await tester.tap(find.byKey(enterCodeRowKey));
    await tester.pumpAndSettle();

    expect(find.byType(JoincodeScreen), findsOneWidget);
    expect(find.byType(InviteScreen), findsNothing);
  });

  testWidgets('the scan-QR row lands on the same joincode screen (AC3)', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    await tester.tap(find.byKey(scanQrRowKey));
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
    expect(find.text("I'll create the code"), findsOneWidget);
  });
}
