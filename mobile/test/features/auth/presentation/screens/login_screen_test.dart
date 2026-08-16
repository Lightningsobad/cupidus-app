import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every method throws — this suite never drives a real sign-in, it only
/// needs an [AuthRepository] instance to satisfy [LoginScreen]'s constructor.
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

const CupidColorTokens _dark = CupidColorTokens.dark();

Widget _harness({CupidPlatform platform = CupidPlatform.material}) {
  final AuthRepository authRepository = AuthRepository(
    gateway: _UnusedGateway(),
    api: CupidApiClient.create(),
    signOut: () => throw UnimplementedError(),
  );

  return MaterialApp(
    theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: CupidPlatformOverride(
      platform: platform,
      child: LoginScreen(authRepository: authRepository),
    ),
  );
}

void main() {
  testWidgets('heading renders the Nunito 900 / 27px design-source style', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    final Text heading = tester.widget<Text>(
      find.text('Mừng bạn quay lại 🎀'),
    );
    expect(heading.style?.fontFamily, 'Nunito');
    expect(heading.style?.fontWeight, FontWeight.w900);
    expect(heading.style?.fontSize, 27);
    expect(heading.style?.color, _dark.colorText);
    expect(heading.textAlign, TextAlign.center);
  });

  testWidgets('design-source subtext slot renders below the heading', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    final Text subtitle = tester.widget<Text>(
      find.text('Bae đang đợi ở trong đấy'),
    );
    expect(subtitle.style?.fontSize, 13);
    expect(subtitle.style?.color, _dark.colorTextMuted);
    expect(
      tester.getTopLeft(find.text('Bae đang đợi ở trong đấy')).dy,
      greaterThan(tester.getTopLeft(find.text('Mừng bạn quay lại 🎀')).dy),
    );
  });

  testWidgets('session-expired variant swaps only the heading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: LoginScreen(
          authRepository: AuthRepository(
            gateway: _UnusedGateway(),
            api: CupidApiClient.create(),
            signOut: () => throw UnimplementedError(),
          ),
          sessionExpired: true,
        ),
      ),
    );

    expect(find.text('Đăng nhập lại để tiếp tục'), findsOneWidget);
    expect(find.text('Bae đang đợi ở trong đấy'), findsOneWidget);
  });

  testWidgets('form fields render as uppercase-labelled borderless surface '
      'cards', (tester) async {
    await tester.pumpWidget(_harness());

    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('MẬT KHẨU'), findsOneWidget);

    final Text label = tester.widget<Text>(find.text('EMAIL'));
    expect(label.style?.fontSize, 11);
    expect(label.style?.letterSpacing, 0.66);
    expect(label.style?.color, _dark.colorTextMuted);

    for (final TextField field in tester.widgetList<TextField>(
      find.byType(TextField),
    )) {
      expect(field.decoration?.border, InputBorder.none);
      expect(field.decoration?.labelText, isNull);
      expect(field.style?.fontSize, 16);
      expect(field.style?.color, _dark.colorText);
    }

    final BoxDecoration card = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((DecoratedBox box) => box.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((BoxDecoration d) => d.color == _dark.colorSurface);
    expect(
      card.borderRadius,
      BorderRadius.circular(const CupidPlatformTokens.material().radiusCard),
    );
    expect(card.boxShadow, const CupidPlatformTokens.material().elevationShadow);
  });

  testWidgets('both field cards measure the design-source 63.6dp, not the '
      'font-metric line box', (tester) async {
    await tester.pumpWidget(_harness());

    for (final String label in <String>['EMAIL', 'MẬT KHẨU']) {
      final Finder card = find
          .ancestor(of: find.text(label), matching: find.byType(DecoratedBox))
          .first;
      expect(
        tester.getSize(card).height,
        moreOrLessEquals(63.6, epsilon: 0.01),
        reason: '$label card must match the design-source card height',
      );
    }
  });

  testWidgets('password field carries a real show/hide toggle', (tester) async {
    await tester.pumpWidget(_harness());

    Finder obscuredField() => find.byWidgetPredicate(
      (Widget widget) => widget is TextField && widget.obscureText,
    );
    Finder glyph(IconData icon) => find.byWidgetPredicate(
      (Widget widget) => widget is Icon && widget.icon == icon,
    );

    expect(obscuredField(), findsOneWidget);
    expect(glyph(CupidIcons.visibilityOff), findsOneWidget);
    expect(glyph(CupidIcons.visibility), findsNothing);

    final Icon rendered = tester.widget<Icon>(glyph(CupidIcons.visibilityOff));
    expect(rendered.size, 21);
    expect(rendered.color, _dark.colorTextMuted);
    expect(rendered.fill, CupidIconVariant.line.fill);
    expect(rendered.weight, CupidIconVariant.line.weight);

    await tester.tap(glyph(CupidIcons.visibilityOff));
    await tester.pump();

    expect(obscuredField(), findsNothing);
    expect(glyph(CupidIcons.visibility), findsOneWidget);
  });

  for (final CupidPlatform platform in CupidPlatform.values) {
    testWidgets('password toggle keeps a --tap hit box on ${platform.name} '
        'without stretching the card', (tester) async {
      await tester.pumpWidget(_harness(platform: platform));

      final double tapTarget = platform == CupidPlatform.ios
          ? const CupidPlatformTokens.ios().tapTarget
          : const CupidPlatformTokens.material().tapTarget;
      final Finder toggleGlyph = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Icon && widget.icon == CupidIcons.visibilityOff,
      );

      final Size hitBox = tester.getSize(
        find
            .ancestor(of: toggleGlyph, matching: find.byType(GestureDetector))
            .first,
      );
      expect(hitBox.height, greaterThanOrEqualTo(tapTarget));
      expect(hitBox.width, greaterThanOrEqualTo(tapTarget));

      final Rect card = tester.getRect(
        find
            .ancestor(
              of: find.text('MẬT KHẨU'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(card.height, moreOrLessEquals(63.6, epsilon: 0.01));

      // `align-items:flex-end`: the glyph's baseline box bottom lines up with
      // the password input's, both 13pt above the card's bottom edge.
      final Rect glyphRect = tester.getRect(toggleGlyph);
      expect(
        glyphRect.bottom,
        moreOrLessEquals(card.bottom - 13, epsilon: 0.01),
      );
      expect(glyphRect.right, moreOrLessEquals(card.right - 16, epsilon: 0.01));
    });
  }

  testWidgets('forgot-password link uses the accent-pink 12.5/700 style and '
      'sits flush right', (tester) async {
    await tester.pumpWidget(_harness());

    final Text link = tester.widget<Text>(find.text('Quên mật khẩu?'));
    expect(link.style?.fontSize, 12.5);
    expect(link.style?.fontWeight, FontWeight.w700);
    expect(link.style?.color, _dark.colorAccentPink);

    expect(
      tester.getTopRight(find.text('Quên mật khẩu?')).dx,
      moreOrLessEquals(tester.getTopRight(find.byType(CupidPrimaryButton)).dx),
    );
  });

  for (final CupidPlatform platform in CupidPlatform.values) {
    final double tapTarget = platform == CupidPlatform.ios
        ? const CupidPlatformTokens.ios().tapTarget
        : const CupidPlatformTokens.material().tapTarget;

    testWidgets('forgot-password link keeps a --tap hit area on '
        '${platform.name} without unbalancing its band', (tester) async {
      await tester.pumpWidget(_harness(platform: platform));

      expect(
        tester.getSize(find.byType(TextButton)).height,
        greaterThanOrEqualTo(tapTarget),
      );

      // The hit area grows symmetrically into the transparent gap, so the
      // text stays centred in the band between the password card and the CTA.
      final Rect passwordCard = tester.getRect(
        find
            .ancestor(
              of: find.text('MẬT KHẨU'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final Rect cta = tester.getRect(find.byType(CupidPrimaryButton));
      expect(
        tester.getRect(find.text('Quên mật khẩu?')).center.dy,
        moreOrLessEquals((passwordCard.bottom + cta.top) / 2, epsilon: 0.5),
      );
    });

    testWidgets('register link keeps a --tap hit area on ${platform.name} '
        'and stays 22pt below the social row', (tester) async {
      await tester.pumpWidget(_harness(platform: platform));

      final Finder registerLink = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Chưa có tài khoản? Đăng ký',
      );
      expect(
        tester.getSize(registerLink).height,
        greaterThanOrEqualTo(tapTarget),
      );

      final Rect socialRow = tester.getRect(
        find
            .ancestor(
              of: find.text('Google'),
              matching: find.byType(OutlinedButton),
            )
            .first,
      );
      expect(
        tester.getRect(registerLink).top - socialRow.bottom,
        moreOrLessEquals(22, epsilon: 0.5),
      );
    });
  }

  testWidgets('"hoặc" divider renders a rule on both sides', (tester) async {
    await tester.pumpWidget(_harness());

    final Text divider = tester.widget<Text>(find.text('hoặc'));
    expect(divider.style?.fontSize, 11.5);
    expect(divider.style?.color, _dark.colorTextMuted);

    final Offset dividerCentre = tester.getCenter(find.text('hoặc'));
    final Iterable<Offset> ruleCentres = tester
        .widgetList<ColoredBox>(find.byType(ColoredBox))
        .where((ColoredBox box) => box.color == _dark.colorLine)
        .map((ColoredBox box) => tester.getCenter(find.byWidget(box)));
    expect(ruleCentres.length, 2);
    expect(ruleCentres.first.dx, lessThan(dividerCentre.dx));
    expect(ruleCentres.last.dx, greaterThan(dividerCentre.dx));
  });

  testWidgets('social row puts Google first beside Facebook on Material', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    expect(find.text('Apple'), findsNothing);
    final Offset google = tester.getCenter(find.text('Google'));
    final Offset facebook = tester.getCenter(find.text('Facebook'));
    expect(google.dy, moreOrLessEquals(facebook.dy));
    expect(google.dx, lessThan(facebook.dx));

    final Size googleButton = tester.getSize(
      find.ancestor(
        of: find.text('Google'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(googleButton.height, 50);
  });

  testWidgets('social buttons draw the design-source brand marks before their '
      'labels', (tester) async {
    await tester.pumpWidget(_harness());

    Finder markOf(CupidBrandMark mark) => find.byWidgetPredicate(
      (Widget widget) => widget is CupidBrandMarkIcon && widget.mark == mark,
    );

    for (final (CupidBrandMark mark, String label, double size, double gap)
        in <(CupidBrandMark, String, double, double)>[
          (CupidBrandMark.google, 'Google', 19, 8),
          (CupidBrandMark.facebook, 'Facebook', 18, 7),
        ]) {
      expect(markOf(mark), findsOneWidget);
      expect(tester.getSize(markOf(mark)), Size(size, size));

      final Rect markRect = tester.getRect(markOf(mark));
      final Rect labelRect = tester.getRect(find.text(label));
      expect(
        labelRect.left - markRect.right,
        moreOrLessEquals(gap, epsilon: 0.01),
      );
      expect(
        markRect.center.dy,
        moreOrLessEquals(labelRect.center.dy, epsilon: 0.5),
      );
    }

    // The four Google brand colors and Facebook's #1877F2 are painted, not
    // approximated by a tinted single-color glyph.
    expect(
      tester.renderObject(
        find.descendant(
          of: markOf(CupidBrandMark.google),
          matching: find.byType(CustomPaint),
        ),
      ),
      paints
        ..path(color: const Color(0xFF4285F4))
        ..path(color: const Color(0xFF34A853))
        ..path(color: const Color(0xFFFBBC05))
        ..path(color: const Color(0xFFEA4335)),
    );
    expect(
      tester.renderObject(
        find.descendant(
          of: markOf(CupidBrandMark.facebook),
          matching: find.byType(CustomPaint),
        ),
      ),
      paints..path(color: const Color(0xFF1877F2)),
    );
  });

  testWidgets('social row puts Google first beside Apple on iOS', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(platform: CupidPlatform.ios));

    expect(find.text('Facebook'), findsNothing);
    expect(
      tester.getCenter(find.text('Google')).dx,
      lessThan(tester.getCenter(find.text('Apple')).dx),
    );
  });

  testWidgets('register link highlights "Đăng ký" in accent pink', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    final RichText link = tester.widget<RichText>(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Chưa có tài khoản? Đăng ký',
      ),
    );
    expect(link.text.style?.color, _dark.colorTextMuted);

    TextSpan? emphasis;
    link.text.visitChildren((InlineSpan span) {
      if (span is TextSpan && span.text == 'Đăng ký') {
        emphasis = span;
      }
      return true;
    });
    expect(emphasis, isNotNull);
    expect(emphasis!.style?.color, _dark.colorAccentPink);
    expect(emphasis!.style?.fontWeight, FontWeight.w700);
  });
}
