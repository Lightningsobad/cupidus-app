import 'dart:async';

import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/session_gate_cubit.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// STORY-003 design fidelity: `splash` must match the locked design source
/// `cupid-app-design-system/project/Cupid Screens.dc.html` (the `isSplash`
/// block) in the enabled dark theme + `vi` locale. Every literal asserted
/// here is transcribed from that block.
const double _designSafeBottom = 24;

/// Every method throws — this suite never drives a sign-in, it only needs an
/// [AuthRepository] instance to satisfy [SplashScreen]'s constructor.
class _UnusedGateway implements FirebaseSignInGateway {
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<void> signInWithApple() => throw UnimplementedError();

  @override
  Future<void> signInWithFacebook() => throw UnimplementedError();

  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<bool> reloadEmailVerified() => throw UnimplementedError();
}

Widget _harness(StreamController<CupidSessionState> controller) {
  return MaterialApp(
    locale: const Locale('vi'),
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Builder(
      builder: (BuildContext context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: const EdgeInsets.only(bottom: _designSafeBottom)),
        child: SplashScreen(
          authRepository: AuthRepository(
            gateway: _UnusedGateway(),
            api: CupidApiClient.create(),
            signOut: () => throw UnimplementedError(),
          ),
          createSessionGateCubit: () => SessionGateCubit(
            sessionState: controller.stream,
            idToken: ({bool forceRefresh = false}) async => 'token',
          ),
          resolvePairingStatus: () async => PairingStatus.unknown,
        ),
      ),
    ),
  );
}

Finder _decoratedBoxWhere(bool Function(BoxDecoration) test) {
  return find.byWidgetPredicate(
    (Widget w) =>
        w is DecoratedBox &&
        w.decoration is BoxDecoration &&
        test(w.decoration as BoxDecoration),
  );
}

void main() {
  late StreamController<CupidSessionState> controller;

  setUp(() {
    controller = StreamController<CupidSessionState>();
    addTearDown(controller.close);
  });

  testWidgets('paints the design source splash gradient, not gradientDream', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(controller));

    expect(
      _decoratedBoxWhere((BoxDecoration d) => d.gradient == SplashPalette.background),
      findsOneWidget,
    );
  });

  testWidgets('renders the breathing glow orb at 150px, top 22% / left 14%', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(controller));

    final Finder glow = _decoratedBoxWhere(
      (BoxDecoration d) => d.gradient == SplashPalette.glow,
    );
    expect(glow, findsOneWidget);
    expect(tester.getSize(glow), const Size(150, 150));

    final Size screen = tester.getSize(find.byType(Scaffold));
    final Offset topLeft = tester.getTopLeft(glow);
    expect(topLeft.dy, closeTo(screen.height * 0.22, 0.01));
    expect(topLeft.dx, closeTo(screen.width * 0.14, 0.01));
  });

  testWidgets('wordmark is Nunito 900 / 58px / -.03em in design white', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(controller));

    final TextStyle style = tester.widget<Text>(find.text('Cupid')).style!;
    expect(style.fontFamily, 'Nunito');
    expect(style.fontWeight, FontWeight.w900);
    expect(style.fontSize, 58);
    expect(style.letterSpacing, -1.74);
    expect(style.color, SplashPalette.foreground);
  });

  testWidgets('loading treatment is three 9px dots spaced 8px apart', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(controller));

    final Finder dots = _decoratedBoxWhere(
      (BoxDecoration d) =>
          d.color == SplashPalette.dot && d.shape == BoxShape.circle,
    );
    expect(dots, findsNWidgets(3));
    expect(tester.getSize(dots.first), const Size(9, 9));
    expect(
      tester.getTopLeft(dots.at(1)).dx - tester.getTopRight(dots.at(0)).dx,
      closeTo(8, 0.01),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('status line and tap pill render from the first frame', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(controller));

    final TextStyle caption = tester
        .widget<Text>(find.text('Đang mở khoá kỷ niệm của hai bạn…'))
        .style!;
    expect(caption.fontSize, 11.5);
    expect(caption.color, SplashPalette.caption);

    final TextStyle label = tester
        .widget<Text>(find.text('Chạm để tiếp tục'))
        .style!;
    expect(label.fontSize, 12);
    expect(label.fontWeight, FontWeight.w700);
    expect(label.color, SplashPalette.foreground);
  });

  testWidgets('tap affordance is a translucent pill, not bare text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(controller));

    final Finder pill = _decoratedBoxWhere(
      (BoxDecoration d) => d.color == SplashPalette.pillFill,
    );
    expect(pill, findsOneWidget);

    final BoxDecoration decoration =
        tester.widget<DecoratedBox>(pill).decoration as BoxDecoration;
    expect(decoration.border, Border.all(color: SplashPalette.pillBorder));
    expect(decoration.borderRadius, BorderRadius.circular(999));

    final Rect pillRect = tester.getRect(pill);
    final Rect labelRect = tester.getRect(find.text('Chạm để tiếp tục'));
    expect(labelRect.left - pillRect.left, closeTo(16, 0.01));
    expect(labelRect.top - pillRect.top, closeTo(8, 0.01));
  });

  testWidgets('bottom block sits 26px above the safe-area bottom inset', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(controller));

    final double screenBottom = tester.getRect(find.byType(Scaffold)).bottom;
    final Finder pill = _decoratedBoxWhere(
      (BoxDecoration d) => d.color == SplashPalette.pillFill,
    );

    expect(
      tester.getRect(pill).bottom,
      closeTo(screenBottom - _designSafeBottom - 26, 0.01),
    );
  });
}
