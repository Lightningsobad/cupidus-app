import 'dart:ui' show Tristate;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/vibes/domain/vibe_mood.dart';
import 'package:cupid_mobile/features/vibes/presentation/vibe_strings.dart';
import 'package:cupid_mobile/features/vibes/presentation/widgets/partner_vibe_card.dart';
import 'package:cupid_mobile/features/vibes/presentation/widgets/vibe_history_strip.dart';
import 'package:cupid_mobile/features/vibes/presentation/widgets/vibe_mood_face.dart';
import 'package:cupid_mobile/features/vibes/presentation/widgets/vibe_mood_grid.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: locale,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('VibeMoodGrid', () {
    testWidgets('renders exactly the 5 frozen moods, no dropped soft cell', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          VibeMoodGrid(selected: null, enabled: true, onPick: (_) {}),
        ),
      );

      expect(find.byType(VibeMoodFace), findsNWidgets(5));
      for (final String label in <String>[
        'Happy',
        'Sad',
        'Angry',
        'Spicy',
        'Tired',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      expect(find.text('Soft'), findsNothing);
    });

    testWidgets('lays out 3 + 2 rows, the bottom row centered at 2/3 width', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          VibeMoodGrid(selected: null, enabled: true, onPick: (_) {}),
        ),
      );

      expect(find.byType(Row), findsNWidgets(2));
      final FractionallySizedBox bottomRow = tester.widget(
        find.byType(FractionallySizedBox),
      );
      expect(bottomRow.widthFactor, 2 / 3);
    });

    testWidgets('the selected mood reports selected semantics, others do not', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _harness(
            VibeMoodGrid(selected: VibeMood.sad, enabled: true, onPick: (_) {}),
          ),
        );

        final SemanticsNode selectedData = tester.getSemantics(
          find.bySemanticsLabel('Sad'),
        );
        expect(
          selectedData.getSemanticsData().flagsCollection.isSelected,
          Tristate.isTrue,
        );
        expect(
          selectedData.getSemanticsData().flagsCollection.isButton,
          isTrue,
        );

        final SemanticsNode unselectedData = tester.getSemantics(
          find.bySemanticsLabel('Happy'),
        );
        expect(
          unselectedData.getSemanticsData().flagsCollection.isSelected,
          isNot(Tristate.isTrue),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('every cell meets the Material --tap minimum (48dp)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          VibeMoodGrid(selected: null, enabled: true, onPick: (_) {}),
        ),
      );

      for (final String label in <String>['Happy', 'Sad', 'Angry']) {
        final Size size = tester.getSize(find.bySemanticsLabel(label));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('enabled: false locks every cell against taps', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        int tapCount = 0;
        await tester.pumpWidget(
          _harness(
            VibeMoodGrid(
              selected: null,
              enabled: false,
              onPick: (_) => tapCount++,
            ),
          ),
        );

        await tester.tap(find.bySemanticsLabel('Happy'));
        await tester.pump();
        expect(tapCount, 0);

        final SemanticsNode data = tester.getSemantics(
          find.bySemanticsLabel('Happy'),
        );
        expect(
          data.getSemanticsData().flagsCollection.isEnabled,
          isNot(Tristate.none),
        );
        expect(
          data.getSemanticsData().flagsCollection.isEnabled,
          Tristate.isFalse,
        );
      } finally {
        handle.dispose();
      }
    });
  });

  group('PartnerVibeCard', () {
    testWidgets('renders the waiting state for a null mood', (tester) async {
      await tester.pumpWidget(_harness(const PartnerVibeCard(mood: null)));

      expect(find.text('Waiting…'), findsOneWidget);
      expect(find.text('Bae has not checked in yet. Nudge them.'), findsOneWidget);
      expect(find.text('Nudge'), findsOneWidget);
    });

    testWidgets('renders the sad/angry/tired nudge copy variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(const PartnerVibeCard(mood: VibeMood.sad)),
      );
      expect(find.text('Bae is down. Send a virtual hug?'), findsOneWidget);
      expect(find.text('Send hug'), findsOneWidget);

      await tester.pumpWidget(
        _harness(const PartnerVibeCard(mood: VibeMood.angry)),
      );
      expect(find.text('Bae is fuming. Milk tea might help.'), findsOneWidget);
      expect(find.text('Order tea'), findsOneWidget);

      await tester.pumpWidget(
        _harness(const PartnerVibeCard(mood: VibeMood.tired)),
      );
      expect(find.text('Bae is drained. Let them sleep in.'), findsOneWidget);
    });

    testWidgets('any other checked-in mood renders the generic acknowledgment', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(const PartnerVibeCard(mood: VibeMood.happy)),
      );
      expect(find.text('Good vibes. Send a sticker back.'), findsOneWidget);
      expect(find.text('Nudge'), findsOneWidget);
    });

    testWidgets('the decorative CTA pill carries no interactive semantics', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _harness(const PartnerVibeCard(mood: VibeMood.sad)),
        );

        final SemanticsNode data = tester.getSemantics(find.text('Send hug'));
        expect(data.getSemanticsData().flagsCollection.isButton, isFalse);
        expect(
          data.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );
      } finally {
        handle.dispose();
      }
    });
  });

  group('VibeHistoryStrip', () {
    testWidgets('renders 7 columns and the none face for a missing day', (
      tester,
    ) async {
      final List<VibeMood?> mine = <VibeMood?>[
        VibeMood.happy,
        null,
        VibeMood.sad,
        VibeMood.angry,
        VibeMood.tired,
        VibeMood.horny,
        VibeMood.happy,
      ];
      final List<VibeMood?> partner = <VibeMood?>[
        null,
        null,
        VibeMood.happy,
        VibeMood.sad,
        VibeMood.tired,
        null,
        VibeMood.angry,
      ];

      await tester.pumpWidget(
        _harness(VibeHistoryStrip(mine: mine, partner: partner)),
      );

      expect(find.byType(VibeMoodFace), findsNWidgets(14));
      final List<VibeMoodFace> faces = tester
          .widgetList<VibeMoodFace>(find.byType(VibeMoodFace))
          .toList();
      expect(faces[0].mood, VibeMood.happy);
      expect(faces[1].mood, null);
      expect(find.text('last 7 days'), findsOneWidget);
    });
  });

  group('VibeLocaleText nudge copy (unit)', () {
    testWidgets('resolves vi/en variants for each mood bucket', (
      tester,
    ) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(ctx.nudgeMessage(VibeMood.sad), 'Bae is down. Send a virtual hug?');
      expect(ctx.nudgeMessage(VibeMood.angry), 'Bae is fuming. Milk tea might help.');
      expect(ctx.nudgeMessage(VibeMood.tired), 'Bae is drained. Let them sleep in.');
      expect(ctx.nudgeMessage(null), 'Bae has not checked in yet. Nudge them.');
      expect(ctx.nudgeMessage(VibeMood.happy), 'Good vibes. Send a sticker back.');

      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
          locale: const Locale('vi'),
        ),
      );

      expect(ctx.nudgeMessage(VibeMood.sad), 'Bae đang tủi. Gửi một cái ôm ảo nha?');
      expect(ctx.historyHeader, '7 ngày gần nhất');
    });
  });
}
