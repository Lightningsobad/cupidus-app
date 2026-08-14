import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(CupidPlatform platform, Widget child) {
  return MaterialApp(
    theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
    home: CupidPlatformOverride(
      platform: platform,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('CupidTabBar', () {
    final List<CupidTabBarItem> items = const <CupidTabBarItem>[
      CupidTabBarItem(icon: Icons.home, label: 'Home'),
      CupidTabBarItem(icon: Icons.favorite, label: 'Match'),
    ];

    testWidgets('renders under iOS override with tapTarget-sized items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.ios,
          CupidTabBar(items: items, currentIndex: 0, onTap: (_) {}),
        ),
      );

      expect(find.byType(CupidTabBar), findsOneWidget);
      final Size size = tester.getSize(find.byType(InkWell).first);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('renders under Material override with tapTarget-sized items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.material,
          CupidTabBar(items: items, currentIndex: 0, onTap: (_) {}),
        ),
      );

      expect(find.byType(CupidTabBar), findsOneWidget);
      final Size size = tester.getSize(find.byType(InkWell).first);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });

  group('CupidHeader', () {
    testWidgets('iOS back affordance is chevron plus text label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.ios,
          CupidHeader(title: 'Title', onBack: () {}, backLabel: 'Back'),
        ),
      );

      expect(find.byIcon(CupidIcons.chevronLeft), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.byIcon(CupidIcons.arrowBack), findsNothing);
    });

    testWidgets('Material back affordance is arrow-only, no text label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.material,
          CupidHeader(title: 'Title', onBack: () {}, backLabel: 'Back'),
        ),
      );

      expect(find.byIcon(CupidIcons.arrowBack), findsOneWidget);
      expect(find.byIcon(CupidIcons.chevronLeft), findsNothing);
      expect(find.text('Back'), findsNothing);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Material header is transparent over a backdrop blur', (
      WidgetTester tester,
    ) async {
      const CupidColorTokens dark = CupidColorTokens.dark();

      await tester.pumpWidget(
        _harness(
          CupidPlatform.material,
          CupidHeader(title: 'Title', onBack: () {}, backLabel: 'Back'),
        ),
      );

      expect(
        tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        Colors.transparent,
      );
      expect(
        find.descendant(
          of: find.byType(CupidHeader),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).color,
        dark.colorAccentPink,
      );
    });

    testWidgets('iOS header blurs instead of painting an opaque band', (
      WidgetTester tester,
    ) async {
      const CupidColorTokens dark = CupidColorTokens.dark();

      await tester.pumpWidget(
        _harness(
          CupidPlatform.ios,
          CupidHeader(title: 'Title', onBack: () {}, backLabel: 'Back'),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(CupidHeader),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(CupidHeader),
                matching: find.byType(Container),
              ),
            )
            .map((Container container) => container.color),
        isNot(contains(dark.colorBackground)),
      );
    });
  });

  group('CupidPrimaryButton', () {
    testWidgets('iOS uses the pill radiusButton token (999)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.ios,
          CupidPrimaryButton(label: 'Continue', onPressed: () {}),
        ),
      );

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      final RoundedRectangleBorder shape =
          button.style!.shape!.resolve(<WidgetState>{})!
              as RoundedRectangleBorder;
      expect(
        (shape.borderRadius as BorderRadius).topLeft.x,
        const CupidPlatformTokens.ios().radiusButton,
      );

      final Size size = tester.getSize(find.byType(SizedBox).first);
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('Material uses the 20dp CTA corner radius, not the pill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.material,
          CupidPrimaryButton(label: 'Continue', onPressed: () {}),
        ),
      );

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      final RoundedRectangleBorder shape =
          button.style!.shape!.resolve(<WidgetState>{})!
              as RoundedRectangleBorder;
      expect((shape.borderRadius as BorderRadius).topLeft.x, 20);

      final Size size = tester.getSize(find.byType(SizedBox).first);
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('paints the hot gradient, the glow and the 54pt CTA band', (
      WidgetTester tester,
    ) async {
      const CupidColorTokens dark = CupidColorTokens.dark();

      for (final CupidPlatform platform in <CupidPlatform>[
        CupidPlatform.ios,
        CupidPlatform.material,
      ]) {
        await tester.pumpWidget(
          _harness(
            platform,
            CupidPrimaryButton(label: 'Continue', onPressed: () {}),
          ),
        );

        final BoxDecoration decoration =
            tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(CupidPrimaryButton),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        expect(decoration.gradient, dark.gradientHot);
        expect(decoration.boxShadow, dark.glowShadow);

        final Size size = tester.getSize(
          find
              .descendant(
                of: find.byType(CupidPrimaryButton),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(size.height, 54);

        final TextStyle style = tester
            .widget<Text>(find.text('Continue'))
            .style!;
        expect(style.fontSize, 16.5);
        expect(style.fontWeight, FontWeight.w800);
      }
    });
  });

  group('CupidAddAction', () {
    testWidgets('iOS renders an icon button, no FAB', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(CupidPlatform.ios, CupidAddAction(onPressed: () {})),
      );

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(CupidIcons.add), findsOneWidget);
    });

    testWidgets('Material renders a FAB, no plain icon button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(CupidPlatform.material, CupidAddAction(onPressed: () {})),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
      final Size size = tester.getSize(find.byType(FloatingActionButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
