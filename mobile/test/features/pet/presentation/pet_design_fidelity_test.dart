import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_screen.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_action_row.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_hero_card.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_reactions_card.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_stats_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_pet_repository.dart';

const CupidColorTokens _colors = CupidColorTokens.dark();
const CupidPlatformTokens _platform = CupidPlatformTokens.material();

Widget _harness(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      home: child,
    ),
  );
}

PetStatus _status() {
  return PetStatus(
    pet: Pet(
      id: 'pet-1',
      coupleId: 'couple-1',
      species: PetSpecies.bunny,
      name: 'Bun',
      happiness: 70,
      level: 3,
      totalInteractions: 63,
      lastInteraction: null,
    ),
    mood: PetMood.happy,
    decayedHappiness: 70,
    milestone: null,
    nextMilestone: 100,
  );
}

BoxDecoration _decorationOf(WidgetTester tester, Finder container) {
  return tester.widget<Container>(container).decoration! as BoxDecoration;
}

void main() {
  group('Love Pet hero card matches the design source', () {
    testWidgets('carries the 178deg hero gradient, hairline border and card '
        'elevation shadow', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(PetHeroCard(status: _status())));
      await tester.pumpAndSettle();

      final BoxDecoration decoration = _decorationOf(
        tester,
        find
            .descendant(
              of: find.byType(PetHeroCard),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(decoration.gradient, PetHeroGradient.gradient);
      expect(decoration.boxShadow, _platform.elevationShadow);
      expect((decoration.border! as Border).top.color, _colors.colorLine);
    });

    testWidgets('renders the pet name in the Nunito display role', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_harness(PetHeroCard(status: _status())));
      await tester.pumpAndSettle();

      final TextStyle style = tester.widget<Text>(find.text('Bun')).style!;
      expect(style.fontFamily, 'Nunito');
      expect(style.fontWeight, FontWeight.w900);
      expect(style.fontSize, 34);
    });

    testWidgets('renders the level/mood pill on a translucent light fill '
        'with a matching hairline border', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(PetHeroCard(status: _status())));
      await tester.pumpAndSettle();

      final Finder pill = find.ancestor(
        of: find.textContaining('Lv.3'),
        matching: find.byType(Container),
      );
      final BoxDecoration decoration = _decorationOf(tester, pill.first);

      expect(decoration.color, _colors.colorText.withValues(alpha: 0.2));
      expect(
        (decoration.border! as Border).top.color,
        _colors.colorText.withValues(alpha: 0.28),
      );

      final TextStyle style = tester
          .widget<Text>(find.textContaining('Lv.3'))
          .style!;
      expect(style.fontWeight, FontWeight.w800);
      expect(style.fontFamily, _platform.uiFontFamily);
    });
  });

  group('Love Pet reference row matches the design source', () {
    testWidgets('tints each reaction tile with its role color at 14%', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_harness(const PetReactionsCard()));
      await tester.pumpAndSettle();

      final List<Color?> tints = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(PetReactionsCard),
              matching: find.byType(Container),
            ),
          )
          .map((Container container) {
            final Decoration? decoration = container.decoration;
            return decoration is BoxDecoration ? decoration.color : null;
          })
          .toList();

      expect(tints, <Color?>[
        _colors.colorSurface,
        _colors.colorMint.withValues(alpha: 0.14),
        _colors.colorAmber.withValues(alpha: 0.14),
        _colors.colorPeach.withValues(alpha: 0.14),
      ]);
    });

    testWidgets('renders the section title as an uppercase muted eyebrow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_harness(const PetReactionsCard()));
      await tester.pumpAndSettle();

      final Text title = tester.widget<Text>(find.text('HOW BUN REACTS'));
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.color, _colors.colorTextMuted);
      expect(title.style!.letterSpacing, closeTo(0.65, 0.0001));
    });
  });

  group('Love Pet stat tiles match the design source', () {
    testWidgets('centers each tile and uses the Nunito 19 stat value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_harness(PetStatsRow(status: _status())));
      await tester.pumpAndSettle();

      final TextStyle style = tester.widget<Text>(find.text('63')).style!;
      expect(style.fontFamily, 'Nunito');
      expect(style.fontWeight, FontWeight.w900);
      expect(style.fontSize, 19);

      final Column column = tester.widget<Column>(
        find
            .descendant(
              of: find.byType(PetStatsRow),
              matching: find.byType(Column),
            )
            .first,
      );
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
    });
  });

  group('Love Pet action row matches the design source', () {
    testWidgets('gives the primary CTA the glow shadow and the secondary '
        'CTA a pink glyph', (WidgetTester tester) async {
      await tester.pumpWidget(
        _harness(const PetActionRow(cooldownRemaining: null)),
      );
      await tester.pumpAndSettle();

      final BoxDecoration feed = _decorationOf(
        tester,
        find
            .ancestor(
              of: find.byIcon(CupidIcons.restaurant),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(feed.gradient, _colors.gradientHot);
      expect(feed.boxShadow, _colors.glowShadow);

      final BoxDecoration play = _decorationOf(
        tester,
        find
            .ancestor(
              of: find.byIcon(CupidIcons.sportsEsports),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(play.color, _colors.colorSurfaceAlt);
      expect(play.boxShadow, isNull);

      final Icon playIcon = tester.widget<Icon>(
        find.byIcon(CupidIcons.sportsEsports),
      );
      expect(playIcon.color, _colors.colorAccentPink);
    });
  });

  group('Love Pet screen gutter matches the design source', () {
    testWidgets('uses a 16pt horizontal gutter, not the 24pt page inset', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = _status();

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();

      final SingleChildScrollView scrollView = tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(
        scrollView.padding,
        const EdgeInsets.fromLTRB(16, 8, 16, 32),
      );
    });
  });
}
