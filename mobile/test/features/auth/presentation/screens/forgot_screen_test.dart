import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/forgot_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Only [sendPasswordResetEmail] is exercised by this screen; every other
/// member throws so an accidental extra call fails loudly.
class _ResetGateway implements FirebaseSignInGateway {
  _ResetGateway({this.failure});

  final Object? failure;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (failure != null) throw failure!;
  }

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
  Future<bool> reloadEmailVerified() => throw UnimplementedError();
}

Widget _harness({Object? failure}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: ForgotScreen(
      authRepository: AuthRepository(
        gateway: _ResetGateway(failure: failure),
        api: CupidApiClient.create(),
        signOut: () => throw UnimplementedError(),
      ),
    ),
  );
}

/// Dark-theme token values the design source's `isForgot` block references.
const CupidColorTokens _dark = CupidColorTokens.dark();

void main() {
  testWidgets('empty state renders the design-source copy and tokens', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    expect(find.text('Quên mật khẩu là chuyện thường'), findsOneWidget);
    expect(
      find.text(
        'Nhập email, tụi mình gửi link đặt lại. Đừng lo, kỷ niệm vẫn còn '
        'nguyên.',
      ),
      findsOneWidget,
    );
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('Gửi link đặt lại'), findsOneWidget);

    final Text title = tester.widget<Text>(
      find.text('Quên mật khẩu là chuyện thường'),
    );
    expect(title.style!.fontFamily, 'Nunito');
    expect(title.style!.fontWeight, FontWeight.w900);
    expect(title.style!.fontSize, 25);
    expect(title.style!.color, _dark.colorText);

    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.border, InputBorder.none);
    expect(field.style!.fontSize, 16);
    expect(field.style!.color, _dark.colorText);
  });

  testWidgets('hero badge and privacy note use the mint/purple accent tints', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    final Iterable<BoxDecoration> decorations = tester
        .widgetList<Container>(find.byType(Container))
        .map((Container c) => c.decoration)
        .whereType<BoxDecoration>();

    expect(
      decorations.any(
        (BoxDecoration d) =>
            d.color == _dark.colorAccentPurple.withValues(alpha: 0.2),
      ),
      isTrue,
      reason: 'hero badge tint (rgba(183,140,245,.2)) missing',
    );
    expect(
      decorations.any(
        (BoxDecoration d) =>
            d.color == _dark.colorMint.withValues(alpha: 0.12) &&
            d.border != null,
      ),
      isTrue,
      reason: 'privacy note surface/border tint missing',
    );
  });

  testWidgets('submitted state reports success without leaving the screen', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    await tester.enterText(find.byType(TextField), 'minh@gmail.com');
    await tester.tap(find.text('Gửi link đặt lại'));
    await tester.pumpAndSettle();

    expect(find.text('Đã gửi email đặt lại mật khẩu.'), findsOneWidget);
    expect(find.byType(ForgotScreen), findsOneWidget);
  });

  testWidgets('failed state renders the error line in the danger token', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(failure: const AuthNetworkFailure()));

    await tester.enterText(find.byType(TextField), 'minh@gmail.com');
    await tester.tap(find.text('Gửi link đặt lại'));
    await tester.pumpAndSettle();

    final Text error = tester.widget<Text>(
      find.text('Không có kết nối mạng'),
    );
    expect(error.style!.color, _dark.colorRed);
  });
}
