import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart';
import 'package:cupid_mobile/features/onboarding/presentation/widgets/zodiac_glyph.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const String _ctaLabel = 'Tiếp tục → Love Contract';

/// Mirrors the design canvas' own placeholders (`myName: 'Linh'`,
/// `myDob: '03/03/2001'`, `Song Ngư`, `Tiếng Việt`) and the preview fixture.
final CupidProfile _profile = CupidProfile(
  id: 'user-1',
  email: 'linh@example.com',
  language: 'vi',
  vowTaken: false,
  isGhostModeEnabled: true,
  displayName: 'Linh',
  birthday: DateTime(2001, 3, 3),
);

class _RouteLog extends NavigatorObserver {
  final List<Route<dynamic>> pushed = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
  }
}

Widget _harness({
  CupidProfile? profile,
  VoidCallback? onContinue,
  NavigatorObserver? observer,
}) {
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    navigatorObservers: <NavigatorObserver>[?observer],
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: OnboardingProfileSetupScreen(
      profile: profile ?? _profile,
      onContinue: onContinue ?? () {},
    ),
  );
}

CupidProfile _profileWith({String? displayName, DateTime? birthday, String? photoUrl}) {
  return CupidProfile(
    id: 'user-1',
    email: 'linh@example.com',
    language: 'vi',
    vowTaken: false,
    isGhostModeEnabled: true,
    displayName: displayName,
    birthday: birthday,
    photoUrl: photoUrl,
  );
}

/// The avatar slot is the only circular [BoxDecoration] sized to the design
/// source's 104px; the camera badge is the 36px one.
BoxDecoration _circleDecorationOfSize(WidgetTester tester, double diameter) {
  final Container container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(Stack),
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is Container &&
                widget.constraints?.maxWidth == diameter &&
                widget.constraints?.maxHeight == diameter,
          ),
        )
        .first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('OnboardingProfileSetupScreen (dark + vi)', () {
    testWidgets('renders the canvas header title and the three card labels', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());

      expect(find.text('Hồ sơ của bạn'), findsOneWidget);
      expect(find.text('TÊN GỌI'), findsOneWidget);
      expect(find.text('NGÀY SINH'), findsOneWidget);
      expect(find.text('NGÔN NGỮ'), findsOneWidget);
    });

    testWidgets('renders the three values from the profile', (tester) async {
      await tester.pumpWidget(_harness());

      expect(find.text('Linh'), findsOneWidget);
      expect(find.text('03/03/2001'), findsOneWidget);
      expect(find.text('Tiếng Việt'), findsOneWidget);
    });

    testWidgets('derives the zodiac chip from the birthday', (tester) async {
      await tester.pumpWidget(_harness());

      expect(find.text('Song Ngư'), findsOneWidget);
      final ZodiacGlyph glyph = tester.widget<ZodiacGlyph>(
        find.byType(ZodiacGlyph),
      );
      expect(glyph.sign, 'Pisces');
      expect(glyph.size, 26);
    });

    testWidgets('AC3: an empty avatar shows the placeholder glyph, no image', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());

      final BoxDecoration decoration = _circleDecorationOfSize(tester, 104);
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.image, isNull);
      expect(
        find.descendant(
          of: find.byType(Stack),
          matching: find.byType(CupidIcon),
        ),
        findsNWidgets(2), // placeholder person + inert camera badge
      );
    });

    testWidgets('AC3: a populated avatar paints the photo url', (tester) async {
      await tester.pumpWidget(
        _harness(
          profile: _profileWith(
            displayName: 'Linh',
            birthday: DateTime(2001, 3, 3),
            photoUrl: 'https://cdn.example.com/linh.jpg',
          ),
        ),
      );

      final BoxDecoration decoration = _circleDecorationOfSize(tester, 104);
      final NetworkImage image = decoration.image!.image as NetworkImage;
      expect(image.url, 'https://cdn.example.com/linh.jpg');
      expect(decoration.image!.fit, BoxFit.cover);

      // The widget-test binding answers every HTTP request with a 400, so the
      // decoration's image can never resolve here. AC3 is asserted on the
      // widget configuration above; this consumes the unavoidable load
      // failure so it does not surface as a test error.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isA<NetworkImageLoadException>());
    });

    testWidgets('nullable backend fields fall back without the zodiac chip', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(profile: _profileWith()));

      expect(find.text('—'), findsNWidgets(2));
      expect(find.byType(ZodiacGlyph), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the CTA is enabled and fires onContinue exactly once', (
      tester,
    ) async {
      var continueCalls = 0;
      await tester.pumpWidget(_harness(onContinue: () => continueCalls++));

      final InkWell cta = tester.widget<InkWell>(
        find.widgetWithText(InkWell, _ctaLabel),
      );
      expect(cta.onTap, isNotNull);

      await tester.tap(find.text(_ctaLabel));
      await tester.pumpAndSettle();

      expect(continueCalls, 1);
    });

    testWidgets('AC4: renders standalone and pushes no route of its own', (
      tester,
    ) async {
      final _RouteLog observer = _RouteLog();

      await tester.pumpWidget(_harness(observer: observer));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingProfileSetupScreen), findsOneWidget);
      expect(observer.pushed, hasLength(1));
      expect(tester.takeException(), isNull);
    });
  });
}
