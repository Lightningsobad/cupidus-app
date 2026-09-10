import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/card_detail_overflow_menu.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(ValueChanged<CardDetailOverflowAction> onSelected) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: CardDetailOverflowMenu(onSelected: onSelected),
          ),
        ),
      ),
    );

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('card_detail_overflow')));
  await tester.pumpAndSettle();
}

void main() {
  group('A-1 · the "…" overflow is one level deep', () {
    testWidgets('the closed trigger is the ellipsis glyph and nothing else',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host((_) {}));
      await tester.pumpAndSettle();

      // U+2026, the one both bundled text fonts carry. U+22EF would tofu.
      expect(find.text('…'), findsOneWidget);
      expect(find.text('⋯'), findsNothing);
      // Closed means closed: no item is mounted before the tap.
      expect(find.byType(PopupMenuItem<CardDetailOverflowAction>), findsNothing);
    });

    testWidgets('opening it shows the three actions, each labelled in Vietnamese',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host((_) {}));
      await tester.pumpAndSettle();
      await _open(tester);

      expect(
        find.byType(PopupMenuItem<CardDetailOverflowAction>),
        findsNWidgets(3),
      );
      expect(CardDetailOverflowAction.values, hasLength(3));
      for (final CardDetailOverflowAction action
          in CardDetailOverflowAction.values) {
        expect(
          find.byKey(Key('card_detail_overflow_${action.name}')),
          findsOneWidget,
          reason: action.name,
        );
      }
      expect(find.text('Chuyển trạng thái'), findsOneWidget);
      expect(find.text('Xoá thẻ'), findsOneWidget);
      expect(find.text('Đánh dấu đã trả lời / chưa trả lời'), findsOneWidget);
    });

    testWidgets('no item opens a second menu', (WidgetTester tester) async {
      await tester.pumpWidget(_host((_) {}));
      await tester.pumpAndSettle();
      await _open(tester);

      // Invariant 1 of §12.2: one tap, one dialog. A nested PopupMenuButton
      // inside any item would be a submenu, so the tree must hold exactly the
      // one button that was tapped.
      expect(find.byType(PopupMenuButton<CardDetailOverflowAction>),
          findsOneWidget);
      for (final CardDetailOverflowAction action
          in CardDetailOverflowAction.values) {
        expect(
          find.descendant(
            of: find.byKey(Key('card_detail_overflow_${action.name}')),
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is PopupMenuButton,
            ),
          ),
          findsNothing,
          reason: action.name,
        );
      }
    });

    testWidgets('each item reports its own action exactly once, then closes',
        (WidgetTester tester) async {
      final List<CardDetailOverflowAction> selected =
          <CardDetailOverflowAction>[];
      await tester.pumpWidget(_host(selected.add));
      await tester.pumpAndSettle();

      for (final CardDetailOverflowAction action
          in CardDetailOverflowAction.values) {
        await _open(tester);
        await tester.tap(find.byKey(Key('card_detail_overflow_${action.name}')));
        await tester.pumpAndSettle();

        expect(selected.last, action, reason: action.name);
        expect(
          find.byType(PopupMenuItem<CardDetailOverflowAction>),
          findsNothing,
          reason: '${action.name} left the menu open',
        );
      }
      expect(selected, CardDetailOverflowAction.values);
    });

    testWidgets('the three actions carry three distinct icons',
        (WidgetTester tester) async {
      final Set<IconData> icons = <IconData>{
        for (final CardDetailOverflowAction action
            in CardDetailOverflowAction.values)
          cardDetailOverflowActionIcon(action),
      };
      expect(icons, hasLength(3));
    });
  });
}
