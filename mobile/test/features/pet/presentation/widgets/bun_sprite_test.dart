import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/bun_sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(Widget child, {bool disableAnimations = false}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('BunSprite / PetSprite', () {
    for (final PetSpecies species in PetSpecies.values) {
      for (final BunSpriteState state in BunSpriteState.values) {
        for (final double size in <double>[206, 74, 46, 38]) {
          testWidgets(
            'renders species $species at state $state and size $size without exception',
            (WidgetTester tester) async {
              await tester.pumpWidget(
                _harness(PetSprite(species: species, state: state, size: size)),
              );
              await tester.pump(const Duration(milliseconds: 500));

              expect(tester.takeException(), isNull);
              expect(find.byType(PetSprite), findsOneWidget);
              final Size renderedSize = tester.getSize(find.byType(PetSprite));
              expect(renderedSize.width, size);
              expect(renderedSize.height, size);
            },
          );
        }
      }
    }

    testWidgets(
      'settles to a static frame with no pending timers under reduce-motion',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _harness(
            const BunSprite(state: BunSpriteState.happy, size: 206),
            disableAnimations: true,
          ),
        );

        await tester.pump();
        expect(tester.takeException(), isNull);
        // pumpAndSettle would time out if a repeating animation were still
        // scheduling frames; reduce-motion must hold a still pose instead.
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('is excluded from the semantics tree (decorative)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(const BunSprite(state: BunSpriteState.neutral, size: 206)),
      );

      expect(
        find.descendant(
          of: find.byType(BunSprite),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });
  });

  group('CupidIcons new pet glyphs (Material Symbols Rounded)', () {
    test('each new constant uses the shared font family', () {
      for (final IconData icon in <IconData>[
        CupidIcons.restaurant,
        CupidIcons.sportsEsports,
        CupidIcons.lock,
        CupidIcons.pets,
        CupidIcons.celebration,
      ]) {
        expect(icon.fontFamily, CupidIcons.fontFamily);
        expect(icon.fontFamily, 'Material Symbols Rounded');
      }
    });
  });
}
