// Not a test. This is a `flutter run -t` entrypoint used to capture the
// implemented Love Pet screen from a device for STORY-024's visual-fidelity
// evidence. It injects a fake repository so the ready state renders without a
// backend, a paired couple, or the service locator.
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_screen.dart';
import 'package:flutter/material.dart';

import 'fake_pet_repository.dart';

void main() {
  final FakePetRepository repository = FakePetRepository()
    ..paired = true
    ..status = PetStatus(
      pet: Pet(
        id: 'pet-1',
        coupleId: 'couple-1',
        species: PetSpecies.bunny,
        name: 'Bún',
        happiness: 78,
        level: 3,
        totalInteractions: 163,
        lastInteraction: null,
      ),
      mood: PetMood.happy,
      decayedHappiness: 78,
      milestone: null,
      nextMilestone: 200,
    );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      // Override the ambient Locale rather than adding a 'vi' delegate set the
      // app does not ship (mirrors pet_engagement_test.dart's harness).
      home: Builder(
        builder: (BuildContext context) => Localizations.override(
          context: context,
          locale: const Locale('vi'),
          child: PetScreen(repository: repository),
        ),
      ),
    ),
  );
}
