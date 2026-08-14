import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/permissions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({
  Set<OnboardingPermission> initiallyGranted = const <OnboardingPermission>{},
  CupidPlatform platform = CupidPlatform.material,
  Locale locale = const Locale('vi'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[Locale('vi'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
    home: CupidPlatformOverride(
      platform: platform,
      child: PermissionsScreen(initiallyGranted: initiallyGranted),
    ),
  );
}

BoxDecoration _toggleTrack(
  WidgetTester tester,
  OnboardingPermission permission,
) {
  final AnimatedContainer track = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byKey(Key('permissions-toggle-${permission.name}')),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return track.decoration! as BoxDecoration;
}

void main() {
  const CupidColorTokens dark = CupidColorTokens.dark();

  testWidgets('renders the design source copy for the vi locale', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());

    expect(find.text('Quyền truy cập'), findsOneWidget);
    expect(find.text('Cho phép vài thứ nhé'), findsOneWidget);
    expect(
      find.text('Bạn có thể từ chối hết. App vẫn chạy, chỉ là kém vui hơn.'),
      findsOneWidget,
    );
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Vân tay'), findsOneWidget);
    expect(find.text('Thư viện ảnh'), findsOneWidget);
    expect(find.text('Tiếp tục'), findsOneWidget);
    expect(find.text('Để sau'), findsOneWidget);
  });

  testWidgets('AC3: every permission icon is a Material Symbols Rounded glyph', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());

    final Iterable<CupidIcon> icons = tester.widgetList<CupidIcon>(
      find.byType(CupidIcon),
    );
    expect(icons, hasLength(3));
    for (final CupidIcon icon in icons) {
      expect(icon.icon.fontFamily, CupidIcons.fontFamily);
      expect(icon.variant, CupidIconVariant.filled);
      expect(icon.size, 23);
    }
  });

  testWidgets('granted and not-yet-decided cards use distinct track styling', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        initiallyGranted: const <OnboardingPermission>{
          OnboardingPermission.notifications,
        },
      ),
    );

    final BoxDecoration grantedTrack = _toggleTrack(
      tester,
      OnboardingPermission.notifications,
    );
    expect(grantedTrack.gradient, dark.gradientHot);
    expect(grantedTrack.color, isNull);

    final BoxDecoration undecidedTrack = _toggleTrack(
      tester,
      OnboardingPermission.photos,
    );
    expect(undecidedTrack.gradient, isNull);
    expect(undecidedTrack.color, dark.colorLine);
  });

  testWidgets('tapping a toggle flips that card between the two states', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());

    await tester.tap(find.byKey(const Key('permissions-toggle-photos')));
    await tester.pumpAndSettle();

    expect(
      _toggleTrack(tester, OnboardingPermission.photos).gradient,
      dark.gradientHot,
    );
  });

  testWidgets('iOS renders the Face ID title from the design source', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(platform: CupidPlatform.ios));

    expect(find.text('Face ID'), findsOneWidget);
    expect(find.text('Vân tay'), findsNothing);
  });

  testWidgets('en locale renders the design source English copy', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(locale: const Locale('en')));

    expect(find.text('A few permissions'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
