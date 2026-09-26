import 'dart:io';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/quick_entry_strip.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The strip in isolation, away from the hub that routes its cells. STORY-011
/// P4 filled the last of the three, so this file pins the shape the strip keeps
/// regardless of which story owns a destination: three cells, fixed order,
/// fixed labels and glyphs, and one handler call per tap.
const Size _wideViewport = Size(415, 400);

const String _stripSource =
    'lib/features/activity_cards/presentation/widgets/quick_entry_strip.dart';

/// Label and glyph per cell, in the `ux/uiux-spec.md` §6 order.
const List<(QuickEntryCell, String, IconData)> _cells =
    <(QuickEntryCell, String, IconData)>[
  (QuickEntryCell.giftIdeas, 'Gợi ý quà', CupidIcons.redeem),
  (QuickEntryCell.conversationStarters, 'Mồi chuyện', CupidIcons.mood),
  (QuickEntryCell.zodiacShell, 'Vỏ hoàng đạo', CupidIcons.autoAwesome),
];

Widget _host(Widget child) => MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  group('UX §6: hình dạng cố định của dải', () {
    testWidgets('ba ô, đúng thứ tự, đúng nhãn và icon', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = _wideViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(const QuickEntryStrip()));
      await tester.pumpAndSettle();

      expect(QuickEntryCell.values.length, kQuickEntryCellCount);
      expect(find.byKey(const Key('activity_quick_entry_strip')), findsOneWidget);

      for (int slot = 0; slot < kQuickEntryCellCount; slot++) {
        final (QuickEntryCell cell, String label, IconData glyph) =
            _cells[slot];
        expect(QuickEntryCell.values[slot], cell);

        final Finder cellFinder = find.byKey(Key('activity_quick_entry_slot_$slot'));
        expect(cellFinder, findsOneWidget);
        expect(
          find.descendant(of: cellFinder, matching: find.text(label)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: cellFinder, matching: find.byIcon(glyph)),
          findsOneWidget,
        );
      }

      expect(
        find.byKey(const Key('activity_quick_entry_slot_$kQuickEntryCellCount')),
        findsNothing,
      );
    });

    testWidgets('mỗi ô gọi handler đúng một lần với chính giá trị của nó', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = _wideViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final List<QuickEntryCell> selected = <QuickEntryCell>[];
      await tester.pumpWidget(
        _host(QuickEntryStrip(onCellSelected: selected.add)),
      );
      await tester.pumpAndSettle();

      for (int slot = 0; slot < kQuickEntryCellCount; slot++) {
        await tester.tap(find.byKey(Key('activity_quick_entry_slot_$slot')));
        await tester.pump();
      }

      expect(selected, QuickEntryCell.values);
      // A handled tap is the hub's to route: the strip never also answers with
      // its own placeholder.
      expect(
        find.byKey(const Key('activity_quick_entry_coming_soon')),
        findsNothing,
      );
    });

    testWidgets('ô thứ ba của STORY-011 không có biến thể bị khoá', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = _wideViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final List<QuickEntryCell> selected = <QuickEntryCell>[];
      await tester.pumpWidget(
        _host(QuickEntryStrip(onCellSelected: selected.add)),
      );
      await tester.pumpAndSettle();

      final int slot =
          QuickEntryCell.values.indexOf(QuickEntryCell.zodiacShell);
      final Finder cell = find.byKey(Key('activity_quick_entry_slot_$slot'));

      expect(
        find.descendant(of: cell, matching: find.byIcon(Icons.lock)),
        findsNothing,
      );
      expect(find.text('Sắp có'), findsNothing);

      await tester.tap(cell);
      await tester.pump();
      expect(selected, <QuickEntryCell>[QuickEntryCell.zodiacShell]);
    });

    testWidgets(
      'khung hẹp: dải cuộn ngang thay vì bóp ba ô, cả ba vẫn chạm tới được',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(280, 400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_host(const QuickEntryStrip()));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('activity_quick_entry_strip_scroll')),
          findsOneWidget,
        );
        for (int slot = 0; slot < kQuickEntryCellCount; slot++) {
          final Finder cell =
              find.byKey(Key('activity_quick_entry_slot_$slot'));
          expect(cell, findsOneWidget);
          expect(
            tester.getSize(cell).width,
            greaterThanOrEqualTo(kQuickEntryMinCellWidth),
          );
        }
      },
    );
  });

  group('hợp đồng nguồn của dải', () {
    test('không ô nào mang điều kiện mở khoá', () {
      final String source = File(_stripSource).readAsStringSync();
      const List<String> gates = <String>[
        'Geolocator',
        'premium',
        'Premium',
        'paywall',
        'subscription',
        'entitlement',
        'onboarding',
        'isUnlocked',
        'isLocked',
      ];
      for (final String gate in gates) {
        expect(
          source.contains(gate),
          isFalse,
          reason: 'R-13/R-14 không áp dụng cho dải: nguồn nhắc tới "$gate"',
        );
      }
    });
  });
}
