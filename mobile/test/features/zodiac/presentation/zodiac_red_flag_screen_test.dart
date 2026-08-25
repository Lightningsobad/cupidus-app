import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/zodiac/domain/zodiac_red_flag.dart';
import 'package:cupid_mobile/features/zodiac/presentation/widgets/zodiac_conflict_index_card.dart';
import 'package:cupid_mobile/features/zodiac/presentation/widgets/zodiac_daily_tips_card.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_cubit.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_red_flag_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'zodiac_screen_fixtures.dart';

/// `Text.rich` builds a [Text] with a `textSpan`, which `find.text` never
/// matches; the score and the tip rows are both built that way.
Finder _richText(String value) => find.byWidgetPredicate(
  (Widget widget) =>
      widget is Text && widget.textSpan?.toPlainText() == value,
  description: 'Text.rich "$value"',
);

Future<void> _pumpScreen(
  WidgetTester tester,
  FakeZodiacRepository repository,
) async {
  await tester.pumpWidget(
    zodiacHarness(
      ZodiacRedFlagScreen(
        createCubit: () => ZodiacCubit(repository: repository),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ZodiacRedFlagScreen ready state (AC1, AC2)', () {
    testWidgets('mounts Card 1/2/3 with the payload it was given', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, FakeZodiacRepository.ready());

      expect(find.text(kZodiacReadyFixture.conflictIndex.headline), findsOneWidget);
      expect(find.text(kZodiacReadyFixture.conflictIndex.body), findsOneWidget);
      expect(find.byType(ZodiacConflictIndexCard), findsOneWidget);
      expect(find.byType(ZodiacDailyTipsCard), findsOneWidget);
    });

    testWidgets('the eyebrow date comes from contentDate, not the clock', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, FakeZodiacRepository.ready());

      // 2026-07-29 is in the past for every run of this suite, so a
      // `DateTime.now()` implementation could not produce it.
      expect(find.text('RED FLAG · 29/07'), findsOneWidget);

      final DateTime now = DateTime.now();
      final String today =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}';
      if (today != '29/07') {
        expect(find.text('RED FLAG · $today'), findsNothing);
      }
    });

    testWidgets('the score renders as score/scoreMax from the payload', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, FakeZodiacRepository.ready());

      expect(_richText('7/10'), findsOneWidget);
    });

    testWidgets('the bar width is fillFraction, not a design literal', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, FakeZodiacRepository.ready());

      expect(
        tester
            .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
            .widthFactor,
        kZodiacReadyFixture.conflictIndex.fillFraction,
      );
    });

    testWidgets('an off-scale payload moves the score and the bar with it', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(
        tester,
        FakeZodiacRepository.ready(kZodiacOffScaleFixture),
      );

      expect(_richText('3/6'), findsOneWidget);
      expect(
        tester
            .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
            .widthFactor,
        0.5,
      );
    });

    testWidgets('both partners get a CupidZodiacIcon disc in wire order', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, FakeZodiacRepository.ready());

      final List<CupidZodiacSign> rendered = tester
          .widgetList<CupidZodiacIcon>(find.byType(CupidZodiacIcon))
          .map((CupidZodiacIcon icon) => icon.sign)
          .toList();

      expect(rendered, <CupidZodiacSign>[
        CupidZodiacSign.cancer,
        CupidZodiacSign.pisces,
      ]);
      // Element ink is applied by the icon itself; overriding `color` here
      // would silently drop the fire/earth/air/water colour coding.
      expect(
        tester
            .widgetList<CupidZodiacIcon>(find.byType(CupidZodiacIcon))
            .every((CupidZodiacIcon icon) => icon.color == null),
        isTrue,
      );
    });

    testWidgets('a null displayName falls back to the sign label', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(
        tester,
        FakeZodiacRepository.ready(kZodiacOffScaleFixture),
      );

      expect(find.text(CupidZodiacSign.aries.viLabel), findsOneWidget);
      expect(find.text(CupidZodiacSign.taurus.viLabel), findsOneWidget);
      for (final String placeholder in <String>[
        'Bạn',
        'Người ấy',
        'Partner',
        'You',
        '—',
      ]) {
        expect(find.text(placeholder), findsNothing);
      }
    });

    testWidgets('Card 3 renders exactly the tips it was given, in wire order', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, FakeZodiacRepository.ready());

      final List<String> rows = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(ZodiacDailyTipsCard),
              matching: find.byType(Text),
            ),
          )
          .map((Text text) => text.textSpan!.toPlainText())
          .toList();

      expect(rows, <String>[
        for (final ZodiacDailyTip tip in kZodiacReadyFixture.dailyTips)
          '${tip.title} — ${tip.body}',
      ]);
    });

    testWidgets('a short tip list is rendered short, not padded', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(
        tester,
        FakeZodiacRepository.ready(kZodiacOffScaleFixture),
      );

      expect(
        find
            .descendant(
              of: find.byType(ZodiacDailyTipsCard),
              matching: find.byType(Text),
            )
            .evaluate()
            .length,
        1,
      );
    });
  });

  group('ZodiacRedFlagScreen incomplete-profile state (AC3, §2c)', () {
    testWidgets('mounts none of Card 1/2/3 and names no partner', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, FakeZodiacRepository.incomplete());

      expect(find.text('Chưa đủ thông tin cung hoàng đạo'), findsOneWidget);

      expect(find.byType(ZodiacConflictIndexCard), findsNothing);
      expect(find.byType(ZodiacDailyTipsCard), findsNothing);
      expect(find.byType(CupidZodiacIcon), findsNothing);
      expect(find.byType(FractionallySizedBox), findsNothing);
      expect(find.text(kZodiacReadyFixture.conflictIndex.headline), findsNothing);
      expect(find.text(kZodiacReadyFixture.conflictIndex.body), findsNothing);
      expect(find.text('RED FLAG · 29/07'), findsNothing);

      for (final ZodiacPartner partner in kZodiacReadyFixture.partners) {
        expect(find.text(partner.label), findsNothing);
        expect(find.text(partner.sign.viLabel), findsNothing);
      }
    });

    testWidgets('is not dressed as an error: no retry affordance', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, FakeZodiacRepository.incomplete());

      expect(find.text('Thử lại'), findsNothing);
    });
  });

  group('ZodiacRedFlagScreen error state (§2d)', () {
    testWidgets('shows the generic message and retries through the cubit', (
      WidgetTester tester,
    ) async {
      final FakeZodiacRepository repository = FakeZodiacRepository.failing();
      await _pumpScreen(tester, repository);

      expect(find.byType(ZodiacConflictIndexCard), findsNothing);
      expect(find.byType(ZodiacDailyTipsCard), findsNothing);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(repository.fetchCount, 1);

      await tester.tap(find.text('Thử lại'));
      await tester.pump();

      expect(repository.fetchCount, 2);
    });
  });

  group('ZodiacRedFlagScreen loading state', () {
    testWidgets('shows a skeleton before the first payload resolves', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        zodiacHarness(
          ZodiacRedFlagScreen(
            createCubit: () =>
                ZodiacCubit(repository: FakeZodiacRepository.ready()),
          ),
        ),
      );

      // No `pump()`: the fetch has not completed yet.
      expect(find.byType(ZodiacConflictIndexCard), findsNothing);
      expect(find.byType(CupidHeader), findsOneWidget);
    });
  });
}
