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

List<Container> _decoratedContainers(WidgetTester tester) => tester
    .widgetList<Container>(
      find.descendant(
        of: find.byType(CupidTabBar),
        matching: find.byType(Container),
      ),
    )
    .where((Container c) => c.decoration is BoxDecoration)
    .toList();

/// The bar chrome itself is the only decorated container carrying a border.
BoxDecoration _barDecoration(WidgetTester tester) =>
    _decoratedContainers(tester)
        .map((Container c) => c.decoration! as BoxDecoration)
        .firstWhere((BoxDecoration d) => d.border != null);

/// Material-only active-state indicators, in item order.
List<Container> _pills(WidgetTester tester) => _decoratedContainers(tester)
    .where(
      (Container c) => (c.decoration! as BoxDecoration).borderRadius != null,
    )
    .toList();

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

    testWidgets('iOS bar is a transparent translucent-blur surface', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.ios,
          CupidTabBar(items: items, currentIndex: 0, onTap: (_) {}),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(CupidTabBar),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );

      final BoxDecoration decoration = _barDecoration(tester);
      expect(decoration.color, Colors.transparent);
      expect(
        decoration.border,
        Border(top: BorderSide(color: const CupidColorTokens.dark().colorLine)),
      );
    });

    testWidgets('iOS item is a 26pt icon over a 10pt bold label, no pill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.ios,
          CupidTabBar(items: items, currentIndex: 0, onTap: (_) {}),
        ),
      );

      final Icon icon = tester.widget(find.byIcon(Icons.home));
      expect(icon.size, 26);
      expect(icon.color, const CupidColorTokens.dark().colorAccentPink);

      final TextStyle label = tester.widget<Text>(find.text('Home')).style!;
      expect(label.fontSize, 10);
      expect(label.fontWeight, FontWeight.w700);
      expect(label.letterSpacing, closeTo(0.1, 0.0001));

      // The pill indicator is the Material-only treatment.
      expect(_pills(tester), isEmpty);
    });

    testWidgets('Material item is a pill-backed 24dp icon over an 11pt label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.material,
          CupidTabBar(items: items, currentIndex: 0, onTap: (_) {}),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(CupidTabBar),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );
      expect(
        _barDecoration(tester).color,
        const CupidColorTokens.dark().colorSurface,
      );

      final Icon icon = tester.widget(find.byIcon(Icons.home));
      expect(icon.size, 24);

      final TextStyle label = tester.widget<Text>(find.text('Home')).style!;
      expect(label.fontSize, 11);
      expect(label.fontWeight, FontWeight.w700);

      final List<Container> pills = _pills(tester);
      expect(pills, hasLength(2));
      final BoxDecoration selectedPill =
          pills.first.decoration! as BoxDecoration;
      // Selected pill carries `rgba(255,127,182,.22)`; unselected is bare.
      expect(
        selectedPill.color,
        const CupidColorTokens.dark().colorAccentPink.withAlpha(56),
      );
      expect(
        (pills.last.decoration! as BoxDecoration).color,
        Colors.transparent,
      );
      expect(
        (selectedPill.borderRadius! as BorderRadius).topLeft.x,
        const CupidPlatformTokens.material().radiusButton,
      );

      final EdgeInsets pillPadding = pills.first.padding! as EdgeInsets;
      expect(pillPadding.horizontal / 2, 19);
      expect(pillPadding.vertical / 2, 5);
    });

    testWidgets('every destination takes an equal share of the bar width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CupidPlatform.material,
          CupidTabBar(items: items, currentIndex: 0, onTap: (_) {}),
        ),
      );

      final List<Size> sizes = tester
          .widgetList<InkWell>(find.byType(InkWell))
          .map((InkWell w) => tester.getSize(find.byWidget(w)))
          .toList();
      expect(sizes, hasLength(2));
      expect(sizes.first.width, sizes.last.width);
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

  group('CupidHeader trailing slot', () {
    // Long enough that the title always wants more width than it is given, so
    // the slot's effect on the title's share is measurable.
    const String longTitle = 'A pairing title long enough to want every pixel';
    // Stand-ins: this suite must not reach into `lib/features` for the real
    // presence chip. Neither is a SizedBox, so the only SizedBox in a header
    // row is the slot's own gap.
    const Widget slot = Icon(Icons.circle, key: ValueKey<String>('slot'));
    const Widget action = Icon(
      Icons.more_horiz,
      key: ValueKey<String>('action'),
    );

    Widget headerUnder(
      CupidPlatform platform,
      List<Widget> actions, {
      Widget? trailing,
    }) => _harness(
      platform,
      CupidHeader(
        title: longTitle,
        onBack: () {},
        backLabel: 'Back',
        actions: actions,
        trailing: trailing,
      ),
    );

    Row headerRow(WidgetTester tester) => tester.widget<Row>(
      find
          .descendant(of: find.byType(CupidHeader), matching: find.byType(Row))
          .first,
    );

    testWidgets('iOS: an unset slot adds neither a widget nor the 10dp gap', (
      WidgetTester tester,
    ) async {
      final List<Widget> actions = <Widget>[action];
      await tester.pumpWidget(headerUnder(CupidPlatform.ios, actions));

      final Row row = headerRow(tester);
      // Nothing was inserted between the title and the caller's own action...
      expect(row.children.last, same(action));
      // ...and no gap box was reserved for the absent slot.
      expect(row.children.whereType<SizedBox>(), isEmpty);
      expect(find.byKey(const ValueKey<String>('slot')), findsNothing);
    });

    testWidgets('iOS: a populated slot sits after the title, behind the gap', (
      WidgetTester tester,
    ) async {
      final List<Widget> actions = <Widget>[action];
      await tester.pumpWidget(
        headerUnder(CupidPlatform.ios, actions, trailing: slot),
      );

      final List<Widget> children = headerRow(tester).children;
      final int slotIndex = children.indexOf(slot);
      expect(slotIndex, greaterThan(0));
      expect(
        children[slotIndex - 1],
        isA<SizedBox>().having((SizedBox box) => box.width, 'width', 10),
      );
      expect(children.last, same(action));
    });

    testWidgets('Material: an unset slot hands back the caller\'s own list', (
      WidgetTester tester,
    ) async {
      final List<Widget> actions = <Widget>[action];
      await tester.pumpWidget(headerUnder(CupidPlatform.material, actions));

      // Literal tree identity: the unset branch builds no new actions list, so
      // this consumer renders the tree it rendered before the slot existed.
      expect(tester.widget<AppBar>(find.byType(AppBar)).actions, same(actions));
      expect(find.byKey(const ValueKey<String>('slot')), findsNothing);
    });

    testWidgets('Material: a populated slot is prepended behind the gap', (
      WidgetTester tester,
    ) async {
      final List<Widget> actions = <Widget>[action];
      await tester.pumpWidget(
        headerUnder(CupidPlatform.material, actions, trailing: slot),
      );

      final List<Widget> rendered = tester
          .widget<AppBar>(find.byType(AppBar))
          .actions!;
      expect(
        rendered.first,
        isA<SizedBox>().having((SizedBox box) => box.width, 'width', 10),
      );
      expect(rendered[1], same(slot));
      expect(rendered.last, same(action));
    });

    // Guards the assertions above against passing vacuously: if the unset
    // branch reserved space, the two widths would match.
    for (final CupidPlatform platform in CupidPlatform.values) {
      testWidgets('${platform.name}: the title yields width only when the slot '
          'is populated', (WidgetTester tester) async {
        await tester.pumpWidget(headerUnder(platform, <Widget>[action]));
        final double unsetWidth = tester.getSize(find.text(longTitle)).width;

        await tester.pumpWidget(
          headerUnder(platform, <Widget>[action], trailing: slot),
        );
        final double populatedWidth = tester
            .getSize(find.text(longTitle))
            .width;

        expect(populatedWidth, lessThan(unsetWidth));
      });
    }

    testWidgets(
      'titleSemanticLabel is unset for every consumer that omits it',
      (WidgetTester tester) async {
        for (final CupidPlatform platform in CupidPlatform.values) {
          await tester.pumpWidget(headerUnder(platform, <Widget>[action]));
          expect(
            tester.widget<Text>(find.text(longTitle)).semanticsLabel,
            isNull,
            reason: '${platform.name} must read its visible title verbatim',
          );
        }
      },
    );
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

    testWidgets('paints the hot gradient, the glow and the 52pt CTA band', (
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
        expect(size.height, 52);

        final TextStyle style = tester
            .widget<Text>(find.text('Continue'))
            .style!;
        expect(style.fontSize, 15.5);
        expect(style.fontWeight, FontWeight.w800);

        expect(
          find.descendant(
            of: find.byType(CupidPrimaryButton),
            matching: find.byType(Icon),
          ),
          findsNothing,
        );
      }
    });

    testWidgets('opts in to a leading glyph with an 8pt gap', (
      WidgetTester tester,
    ) async {
      for (final CupidPlatform platform in <CupidPlatform>[
        CupidPlatform.ios,
        CupidPlatform.material,
      ]) {
        await tester.pumpWidget(
          _harness(
            platform,
            CupidPrimaryButton(
              label: 'Continue',
              leadingIcon: CupidIcons.add,
              onPressed: () {},
            ),
          ),
        );

        expect(
          tester.widget<Icon>(find.byIcon(CupidIcons.add)).size,
          21,
        );
        expect(
          tester.getTopLeft(find.text('Continue')).dx -
              tester.getTopRight(find.byIcon(CupidIcons.add)).dx,
          8,
        );
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

    testWidgets('Material FAB is a 60pt rounded square on the hot gradient', (
      WidgetTester tester,
    ) async {
      const CupidColorTokens dark = CupidColorTokens.dark();

      await tester.pumpWidget(
        _harness(CupidPlatform.material, CupidAddAction(onPressed: () {})),
      );

      expect(
        tester.getSize(find.byType(FloatingActionButton)),
        const Size(60, 60),
      );

      final BoxDecoration decoration =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(CupidAddAction),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(decoration.gradient, dark.gradientHot);
      expect(decoration.boxShadow, dark.glowShadow);
      expect(decoration.borderRadius, BorderRadius.circular(20));

      expect(tester.widget<Icon>(find.byIcon(CupidIcons.add)).size, 27);
    });

    /// Pins the measured deviation, not AC1's 60x60 target. `CupidHeader`'s
    /// Material branch hands `actions` to an `AppBar` whose toolbar band is
    /// `kToolbarHeight`, which clamps the 60pt box on the cross axis. Closing it
    /// means editing `cupid_header.dart`, outside this story's write scope, so
    /// this locks current behaviour for the follow-up item to flip.
    testWidgets('Material FAB is clamped to 60x56 inside CupidHeader.actions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCupidTheme(
            platform: CupidPlatform.material,
            brightness: Brightness.dark,
          ),
          home: CupidPlatformOverride(
            platform: CupidPlatform.material,
            child: Scaffold(
              appBar: CupidHeader(
                title: 'Hũ Ước Mơ',
                actions: <Widget>[CupidAddAction(onPressed: () {})],
              ),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      final Size size = tester.getSize(find.byType(FloatingActionButton));
      expect(size, const Size(60, 56));
      expect(size.height, kToolbarHeight);
    });
  });
}
