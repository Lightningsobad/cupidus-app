import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/data/pet_repository.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_screen.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_preview_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_pet_repository.dart';

Widget _harness(Widget child) {
  return MediaQuery(
    // BunSprite bobs indefinitely for happy/inlove/neutral moods; disable
    // motion so pumpAndSettle can complete (mirrors pet_screen_test.dart).
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
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
  group('PetPreviewCard on HomeScreen (entry-point reachability)', () {
    // PetRoute always resolves PetScreen's own PetRepository through
    // `getIt<PetRepository>()` (it never receives PetPreviewCard's
    // repository override, matching production wiring) — every test that
    // pushes the route needs a registration, mirroring
    // realtime_coordinator_test.dart's `getIt.reset` DI-registration
    // pattern.
    setUp(getIt.reset);
    tearDown(getIt.reset);

    testWidgets(
      'renders the ready variant with sprite, name and level for a paired '
      'couple with a pet',
      (WidgetTester tester) async {
        final repository = FakePetRepository()
          ..paired = true
          ..status = _status(mood: PetMood.happy, level: 4, name: 'Mochi');

        await tester.pumpWidget(
          _harness(
            Scaffold(body: PetPreviewCard(repository: repository)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Mochi'), findsOneWidget);
        expect(find.text('Lv.4 · Happy'), findsOneWidget);
      },
    );

    testWidgets(
      'renders the compact locked variant with no adopt entry when unpaired '
      '(AC3)',
      (WidgetTester tester) async {
        final repository = FakePetRepository()..paired = false;

        await tester.pumpWidget(
          _harness(
            Scaffold(body: PetPreviewCard(repository: repository)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pair up to adopt a Bun together'), findsOneWidget);
        expect(find.byType(CupidPrimaryButton), findsNothing);
      },
    );

    testWidgets('tapping the preview card navigates to PetScreen', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = _status(mood: PetMood.content);
      getIt.registerSingleton<PetRepository>(repository);

      await tester.pumpWidget(
        _harness(
          Scaffold(body: PetPreviewCard(repository: repository)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PetPreviewCard));
      await tester.pumpAndSettle();

      expect(find.byType(PetScreen), findsOneWidget);
    });

    group('regression: home_screen_ready_signal', () {
      testWidgets(
        'still pumps after mounting PetPreviewCard',
        (WidgetTester tester) async {
          getIt.registerSingleton<PetRepository>(
            FakePetRepository()..paired = false,
          );

          await tester.pumpWidget(
            _harness(
              // Overrides the default `getIt<CouplePairingStore>()` lookup
              // (mirrors `home_screen_test.dart`): this test only exercises
              // the pet preview card, so it never registers a
              // `CouplePairingStore` and must not depend on one.
              HomeScreen(
                resolvePairingStatus: () async => PairingStatus.unknown,
              ),
            ),
          );
          await tester.pump();

          expect(
            find.byKey(const Key('home_screen_ready_signal')),
            findsOneWidget,
          );
        },
      );
    });
  });
}
