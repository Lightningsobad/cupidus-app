import 'package:flutter_test/flutter_test.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';

void main() {
  group('PetSpecies', () {
    test('round-trips fromJson/wireValue for every backend species', () {
      for (final species in PetSpecies.values) {
        expect(PetSpecies.fromJson(species.wireValue), species);
        expect(PetSpecies.fromJson(species.characterId), species);
      }
      expect(PetSpecies.cat.wireValue, 'cat');
      expect(PetSpecies.dog.wireValue, 'dog');
      expect(PetSpecies.bunny.wireValue, 'bunny');
      expect(PetSpecies.bear.wireValue, 'bear');
      expect(PetSpecies.chick.wireValue, 'chick');
      expect(PetSpecies.panda.wireValue, 'panda');

      expect(PetSpecies.fromJson('bun'), PetSpecies.cat);
      expect(PetSpecies.fromJson('bo'), PetSpecies.dog);
      expect(PetSpecies.fromJson('shiba'), PetSpecies.dog);
      expect(PetSpecies.fromJson('sua'), PetSpecies.bunny);
      expect(PetSpecies.fromJson('mochi'), PetSpecies.bear);
      expect(PetSpecies.fromJson('xoai'), PetSpecies.chick);
      expect(PetSpecies.fromJson('kem'), PetSpecies.panda);
    });
  });

  group('PetStatus.fromJson', () {
    final fullPayload = <String, dynamic>{
      'pet': <String, dynamic>{
        'id': 'pet-1',
        'coupleId': 'couple-1',
        'species': 'bunny',
        'name': 'Bún',
        'happiness': 72,
        'level': 2,
        'totalInteractions': 63,
        'lastInteraction': '2026-07-30T02:10:00.000Z',
      },
      'mood': 'happy',
      'decayedHappiness': 72,
      'milestone': '50 interactions!',
      'nextMilestone': 100,
    };

    test('parses the §4 example payload with every field populated', () {
      final status = PetStatus.fromJson(fullPayload);

      expect(status.pet.id, 'pet-1');
      expect(status.pet.coupleId, 'couple-1');
      expect(status.pet.species, PetSpecies.bunny);
      expect(status.pet.name, 'Bún');
      expect(status.pet.happiness, 72);
      expect(status.pet.level, 2);
      expect(status.pet.totalInteractions, 63);
      expect(
        status.pet.lastInteraction,
        DateTime.parse('2026-07-30T02:10:00.000Z'),
      );
      expect(status.mood, PetMood.happy);
      expect(status.decayedHappiness, 72);
      expect(status.milestone, '50 interactions!');
      expect(status.nextMilestone, 100);
    });

    test(
      'derives levelProgress and interactionsTowardNextMilestone without '
      'reimplementing backend math',
      () {
        final status = PetStatus.fromJson(fullPayload);

        expect(status.levelProgress, closeTo(63 % 50 / 50, 0.0001));

        final (totalInteractions, nextMilestone) =
            status.interactionsTowardNextMilestone;
        expect(totalInteractions, 63);
        expect(nextMilestone, 100);
      },
    );

    test(
      'maps an unrecognised mood string to content/neutral without throwing',
      () {
        final payload = <String, dynamic>{...fullPayload, 'mood': 'furious'};

        final status = PetStatus.fromJson(payload);

        expect(status.mood, PetMood.content);
        expect(BunSpriteState.fromMood(status.mood), BunSpriteState.neutral);
      },
    );

    test('parses a payload with lastInteraction and milestone both null', () {
      final payload = <String, dynamic>{
        'pet': <String, dynamic>{
          'id': 'pet-2',
          'coupleId': 'couple-2',
          'species': 'cat',
          'name': 'Miu',
          'happiness': 50,
          'level': 1,
          'totalInteractions': 0,
          'lastInteraction': null,
        },
        'mood': 'content',
        'decayedHappiness': 50,
        'milestone': null,
        'nextMilestone': 50,
      };

      final status = PetStatus.fromJson(payload);

      expect(status.pet.lastInteraction, isNull);
      expect(status.milestone, isNull);
    });
  });

  group('PetPairing.fromJson', () {
    test('is paired when partnerId is a non-empty string', () {
      expect(PetPairing.fromJson({'partnerId': 'user-2'}).isPaired, isTrue);
    });

    test('is not paired when partnerId is absent, null, or empty', () {
      expect(PetPairing.fromJson({}).isPaired, isFalse);
      expect(PetPairing.fromJson({'partnerId': null}).isPaired, isFalse);
      expect(PetPairing.fromJson({'partnerId': ''}).isPaired, isFalse);
    });
  });
}
