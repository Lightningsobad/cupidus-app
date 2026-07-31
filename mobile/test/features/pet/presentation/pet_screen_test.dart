import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_screen.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/bun_sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_pet_repository.dart';

Widget _harness(Widget child) {
  return MediaQuery(
    // BunSprite bobs indefinitely for happy/inlove/neutral moods; these
    // tests assert on text/CTA content, not animation, so disable motion
    // the same way bun_sprite_test.dart does to let pumpAndSettle complete.
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

PetStatus _status({required PetMood mood, int level = 3, String name = 'Bun'}) {
  return PetStatus(
    pet: Pet(
      id: 'pet-1',
      coupleId: 'couple-1',
      species: PetSpecies.bunny,
      name: name,
      happiness: 70,
      level: level,
      totalInteractions: 63,
      lastInteraction: null,
    ),
    mood: mood,
    decayedHappiness: 70,
    milestone: null,
    nextMilestone: 100,
  );
}

void main() {
  group('PetScreen locked state (AC3)', () {
    testWidgets(
      'renders no adopt CTA and no interact buttons when unpaired',
      (WidgetTester tester) async {
        final repository = FakePetRepository()..paired = false;

        await tester.pumpWidget(
          _harness(PetScreen(repository: repository)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CupidPrimaryButton), findsNothing);
        expect(find.byIcon(CupidIcons.restaurant), findsNothing);
        expect(find.byIcon(CupidIcons.sportsEsports), findsNothing);
      },
    );

    testWidgets(
      'exposes the locked headline as the screen accessible title',
      (WidgetTester tester) async {
        final repository = FakePetRepository()..paired = false;
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          _harness(PetScreen(repository: repository)),
        );
        await tester.pumpAndSettle();

        final Finder headline = find.text(
          'Pair up to adopt a Bun together',
        );
        expect(headline, findsOneWidget);
        final SemanticsNode node = tester.getSemantics(headline);
        expect(node.flagsCollection.isHeader, isTrue);
        handle.dispose();
      },
    );
  });

  group('PetScreen no-pet state', () {
    testWidgets('renders the adopt CTA when paired with no pet', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null;

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();

      expect(find.byType(CupidPrimaryButton), findsOneWidget);
      expect(find.text('Adopt'), findsOneWidget);
    });
  });

  group('PetScreen ready state', () {
    testWidgets('renders name, level pill, mood label, status line and '
        'sprite for ecstatic', (WidgetTester tester) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = _status(mood: PetMood.ecstatic, level: 5, name: 'Mochi');

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();

      expect(find.text('Mochi'), findsOneWidget);
      expect(find.text('Lv.5 · Delighted'), findsOneWidget);
      expect(find.text('Bun is glowing today ✨'), findsOneWidget);
      // P6 mounts PetReactionsCard's 3 reference sprites alongside the hero
      // card's sprite; the hero card is first in `_ReadyState`'s Column.
      final BunSprite sprite = tester
          .widgetList<BunSprite>(find.byType(BunSprite))
          .first;
      expect(sprite.state, BunSpriteState.inlove);
    });

    testWidgets('renders name, level pill, mood label and status line for '
        'sick', (WidgetTester tester) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = _status(mood: PetMood.sick, level: 2, name: 'Mochi');

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();

      expect(find.text('Lv.2 · Sick'), findsOneWidget);
      expect(
        find.text("Bun isn't feeling well. Go check on Bun."),
        findsOneWidget,
      );
      // The hero card's sprite is first; PetReactionsCard's sick reference
      // sprite would otherwise also match `BunSpriteState.sick` here.
      final BunSprite sprite = tester
          .widgetList<BunSprite>(find.byType(BunSprite))
          .first;
      expect(sprite.state, BunSpriteState.sick);
    });

    testWidgets(
      'exposes the mood label as reachable semantics text',
      (WidgetTester tester) async {
        final repository = FakePetRepository()
          ..paired = true
          ..status = _status(mood: PetMood.happy);
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(_harness(PetScreen(repository: repository)));
        await tester.pumpAndSettle();

        expect(find.text('Lv.3 · Happy'), findsOneWidget);
        final SemanticsNode node = tester.getSemantics(
          find.text('Lv.3 · Happy'),
        );
        expect(node.label, contains('Happy'));
        handle.dispose();
      },
    );
  });

  group('PetScreen failure state', () {
    testWidgets('renders a retry affordance that reloads on tap', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..readPairingError = const NetworkUnavailableFailure();

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();

      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      repository.readPairingError = null;
      repository.paired = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('No internet connection'), findsNothing);
      expect(find.text('Pair up to adopt a Bun together'), findsOneWidget);
    });
  });
}
