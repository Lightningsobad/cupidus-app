import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every method throws — this suite never drives a real registration, it only
/// needs an [AuthRepository] instance to satisfy [RegisterScreen]'s
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

const CupidColorTokens _dark = CupidColorTokens.dark();
const CupidPlatformTokens _material = CupidPlatformTokens.material();

Widget _harness() {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: CupidPlatformOverride(
      platform: CupidPlatform.material,
      child: RegisterScreen(
        authRepository: AuthRepository(
          gateway: _UnusedGateway(),
          api: CupidApiClient.create(),
          signOut: () => throw UnimplementedError(),
        ),
      ),
    ),
  );
}

Iterable<BoxDecoration> _boxDecorations(WidgetTester tester) sync* {
  for (final Container container in tester.widgetList<Container>(
    find.byType(Container),
  )) {
    final Decoration? decoration = container.decoration;
    if (decoration is BoxDecoration) yield decoration;
  }
}

Iterable<BoxDecoration> _foregroundDecorations(WidgetTester tester) sync* {
  for (final Container container in tester.widgetList<Container>(
    find.byType(Container),
  )) {
    final Decoration? decoration = container.foregroundDecoration;
    if (decoration is BoxDecoration) yield decoration;
  }
}

void main() {
  testWidgets('renders the design source heading block in vi', (tester) async {
    await tester.pumpWidget(_harness());

    expect(find.text('Tạo tài khoản'), findsWidgets);
    expect(
      find.text('Một người tạo, người kia ghép vào sau bằng mã.'),
      findsOneWidget,
    );

    final Text title = tester.widget<Text>(find.text('Tạo tài khoản').first);
    expect(title.style!.fontFamily, 'Nunito');
    expect(title.style!.fontWeight, FontWeight.w900);
    expect(title.style!.fontSize, 26);
  });

  testWidgets('renders each field as an uppercase-labelled surface card', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    expect(find.text('TÊN GỌI'), findsOneWidget);
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('MẬT KHẨU'), findsOneWidget);

    final List<BoxDecoration> cards = _boxDecorations(
      tester,
    ).where((d) => d.color == _dark.colorSurface).toList();
    expect(cards, hasLength(3));
    for (final BoxDecoration card in cards) {
      expect(card.borderRadius, BorderRadius.circular(_material.radiusCard));
      expect(card.boxShadow, _material.elevationShadow);
    }
  });

  testWidgets('focused field card paints the accent ring without insetting '
      'the card', (tester) async {
    await tester.pumpWidget(_harness());

    bool hasAccentRing() => _foregroundDecorations(
      tester,
    ).any((d) => d.border?.top.color == _dark.colorAccentPink);

    final Finder card = find
        .ancestor(of: find.text('TÊN GỌI'), matching: find.byType(Container))
        .first;
    final Size cardSize = tester.getSize(card);
    final Offset labelOrigin = tester.getTopLeft(find.text('TÊN GỌI'));

    expect(hasAccentRing(), isFalse);

    await tester.tap(find.byType(TextField).first);
    await tester.pump();

    expect(hasAccentRing(), isTrue);
    // The ring is a foreground decoration, so it consumes no layout space and
    // the card keeps the design's borderless `13px 16px` box.
    expect(tester.getSize(card), cardSize);
    expect(tester.getTopLeft(find.text('TÊN GỌI')), labelOrigin);
    expect(
      _boxDecorations(tester)
          .where((d) => d.color == _dark.colorSurface)
          .every((d) => d.border == null),
      isTrue,
    );
  });

  testWidgets('field inputs expose their label to screen readers', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(_harness());

    expect(find.bySemanticsLabel('Tên gọi'), findsOneWidget);
    expect(find.bySemanticsLabel('Email'), findsOneWidget);
    expect(find.bySemanticsLabel('Mật khẩu'), findsOneWidget);
    // The uppercase visual label is excluded, so nothing is announced twice.
    expect(find.bySemanticsLabel('TÊN GỌI'), findsNothing);

    handle.dispose();
  });

  testWidgets('consent control meets the platform tap target while the '
      'painted box stays 24x24', (tester) async {
    await tester.pumpWidget(_harness());

    final Finder paintedBox = find
        .ancestor(of: find.byType(CupidIcon), matching: find.byType(Container))
        .first;
    expect(tester.getSize(paintedBox), const Size(24, 24));

    final Finder hitArea = find
        .ancestor(
          of: find.byType(CupidIcon),
          matching: find.byType(GestureDetector),
        )
        .first;
    final Size hitSize = tester.getSize(hitArea);
    expect(hitSize.width, greaterThanOrEqualTo(_material.tapTarget));
    expect(hitSize.height, greaterThanOrEqualTo(_material.tapTarget));

    // A tap below the 24px painted box still toggles consent.
    await tester.tapAt(tester.getCenter(paintedBox) + const Offset(0, 20));
    await tester.pump();

    expect(find.byType(CupidIcon), findsNothing);
  });

  testWidgets('password meter fills 3 of 4 segments and shows the strong '
      'caption for the design source sample password', (tester) async {
    await tester.pumpWidget(_harness());

    expect(find.text('Mạnh — Bae có đoán cũng chịu'), findsNothing);

    await tester.enterText(find.byType(TextField).at(2), 'loveyou247');
    await tester.pump();

    final List<BoxDecoration> segments = _boxDecorations(tester)
        .where((d) => d.color == _dark.colorMint || d.color == _dark.colorLine)
        .toList();
    expect(segments, hasLength(4));
    expect(segments.where((d) => d.color == _dark.colorMint), hasLength(3));
    expect(find.text('Mạnh — Bae có đoán cũng chịu'), findsOneWidget);
  });

  testWidgets('terms consent box toggles between gradient and outline', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    bool hasGradientBox() =>
        _boxDecorations(tester).any((d) => d.gradient == _dark.gradientHot);

    expect(hasGradientBox(), isTrue);
    expect(find.byType(CupidIcon), findsOneWidget);

    await tester.tap(find.byType(CupidIcon));
    await tester.pump();

    expect(hasGradientBox(), isFalse);
    expect(find.byType(CupidIcon), findsNothing);
  });
}
