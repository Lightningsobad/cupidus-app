import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every method throws — this suite never drives a real sign-in, it only
/// needs an [AuthRepository] instance to satisfy [WelcomeScreen]'s
/// constructor.
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

Widget _harness({CupidPlatform platform = CupidPlatform.material}) {
  final AuthRepository authRepository = AuthRepository(
    gateway: _UnusedGateway(),
    api: CupidApiClient.create(),
    signOut: () => throw UnimplementedError(),
  );

  return MaterialApp(
    theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    locale: const Locale('vi'),
    home: CupidPlatformOverride(
      platform: platform,
      child: WelcomeScreen(authRepository: authRepository),
    ),
  );
}

const String _tagline = 'Yêu nghiêm túc.\nChia tay đàng hoàng.';
const String _subCopy =
    'App cho hai người. Không có newsfeed, không có người thứ ba.';
const String _footnote =
    'Đăng ký nghĩa là bạn chấp nhận bị dỗi khi seen không trả lời.';

void main() {
  testWidgets('renders the design source hero block in vi', (tester) async {
    await tester.pumpWidget(_harness());

    expect(find.text('Cupid'), findsOneWidget);
    expect(find.text(_tagline), findsOneWidget);
    expect(find.text(_subCopy), findsOneWidget);
    expect(find.text(_footnote), findsOneWidget);
  });

  testWidgets('hero content is left-aligned, not centered', (tester) async {
    await tester.pumpWidget(_harness());

    final Column hero = tester.widget<Column>(
      find.ancestor(of: find.text('Cupid'), matching: find.byType(Column)).first,
    );

    expect(hero.crossAxisAlignment, CrossAxisAlignment.start);
    expect(hero.mainAxisAlignment, MainAxisAlignment.center);
    expect(tester.widget<Text>(find.text(_tagline)).textAlign, isNull);
  });

  testWidgets('background uses the token palette on the 165deg sweep', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    final BoxDecoration decoration = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((DecoratedBox box) => box.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((BoxDecoration d) => d.gradient != null);
    final LinearGradient gradient = decoration.gradient! as LinearGradient;

    expect(
      gradient.colors,
      const CupidColorTokens.dark().gradientHot.colors.reversed.toList(),
    );
    expect(gradient.begin, const Alignment(-0.25881904510252074, -0.9659258262890683));
    expect(gradient.end, const Alignment(0.25881904510252074, 0.9659258262890683));
  });

  testWidgets('CTAs are 52pt pills stacked with the design source gap', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    final Finder google = find.widgetWithText(
      ElevatedButton,
      'Tiếp tục với Google',
    );
    final Finder email = find.widgetWithText(OutlinedButton, 'Dùng email');

    expect(tester.getSize(google).height, _ctaHeightExpectation);
    expect(tester.getSize(email).height, _ctaHeightExpectation);
    expect(
      tester.getTopLeft(email).dy - tester.getBottomLeft(google).dy,
      _ctaGapExpectation,
    );

    final double pillRadius = const CupidPlatformTokens.material().radiusButton;
    expect(
      _resolvedRadius(tester.widget<ElevatedButton>(google).style!),
      BorderRadius.circular(pillRadius),
    );
    expect(
      _resolvedRadius(tester.widget<OutlinedButton>(email).style!),
      BorderRadius.circular(pillRadius),
    );
  });

  testWidgets('Apple CTA is iOS-only', (tester) async {
    await tester.pumpWidget(_harness());
    expect(find.text('Tiếp tục với Apple'), findsNothing);

    await tester.pumpWidget(_harness(platform: CupidPlatform.ios));
    expect(find.text('Tiếp tục với Apple'), findsOneWidget);
  });

  testWidgets('carries no CTA the design source does not define', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    expect(find.text('Chưa có tài khoản? Đăng ký'), findsNothing);
  });
}

const double _ctaHeightExpectation = 52;
const double _ctaGapExpectation = 10;

BorderRadiusGeometry _resolvedRadius(ButtonStyle style) {
  final RoundedRectangleBorder shape =
      style.shape!.resolve(<WidgetState>{})! as RoundedRectangleBorder;
  return shape.borderRadius;
}
