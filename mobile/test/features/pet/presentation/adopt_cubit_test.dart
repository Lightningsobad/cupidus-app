import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/presentation/adopt_cubit.dart';
import 'package:cupid_mobile/features/pet/presentation/adopt_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_pet_repository.dart';

PetStatus _status() => PetStatus(
      pet: Pet(
        id: 'pet-1',
        coupleId: 'couple-1',
        species: PetSpecies.bunny,
        name: 'Bun',
        happiness: 50,
        level: 1,
        totalInteractions: 0,
        lastInteraction: null,
      ),
      mood: PetMood.content,
      decayedHappiness: 50,
      milestone: null,
      nextMilestone: 50,
    );

void main() {
  group('AdoptCubit validation', () {
    test('starts with no species, empty name, and invalid', () {
      final cubit = AdoptCubit(repository: FakePetRepository());
      addTearDown(cubit.close);

      final state = cubit.state as AdoptEditing;
      expect(state.species, isNull);
      expect(state.name, isEmpty);
      expect(state.isValid, isFalse);
    });

    test('is invalid without a selected species even with a valid name', () {
      final cubit = AdoptCubit(repository: FakePetRepository());
      addTearDown(cubit.close);

      cubit.nameChanged('Bun');

      expect((cubit.state as AdoptEditing).isValid, isFalse);
    });

    test('is invalid for an empty name', () {
      final cubit = AdoptCubit(repository: FakePetRepository());
      addTearDown(cubit.close);

      cubit.selectSpecies(PetSpecies.bunny);
      cubit.nameChanged('');

      expect((cubit.state as AdoptEditing).isValid, isFalse);
    });

    test('is invalid for a whitespace-only name', () {
      final cubit = AdoptCubit(repository: FakePetRepository());
      addTearDown(cubit.close);

      cubit.selectSpecies(PetSpecies.bunny);
      cubit.nameChanged('   ');

      expect((cubit.state as AdoptEditing).isValid, isFalse);
    });

    test('is valid for a 1-character name', () {
      final cubit = AdoptCubit(repository: FakePetRepository());
      addTearDown(cubit.close);

      cubit.selectSpecies(PetSpecies.cat);
      cubit.nameChanged('A');

      expect((cubit.state as AdoptEditing).isValid, isTrue);
    });

    test('is valid for a 30-character name', () {
      final cubit = AdoptCubit(repository: FakePetRepository());
      addTearDown(cubit.close);

      cubit.selectSpecies(PetSpecies.dog);
      cubit.nameChanged('A' * 30);

      expect((cubit.state as AdoptEditing).isValid, isTrue);
    });

    test('is invalid for a 31-character name', () {
      final cubit = AdoptCubit(repository: FakePetRepository());
      addTearDown(cubit.close);

      cubit.selectSpecies(PetSpecies.dog);
      cubit.nameChanged('A' * 31);

      expect((cubit.state as AdoptEditing).isValid, isFalse);
    });
  });

  group('AdoptCubit.submit', () {
    test('is a no-op when the form is invalid', () async {
      final repository = FakePetRepository();
      final cubit = AdoptCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.submit();

      expect(repository.adoptCalls, 0);
      expect(cubit.state, isA<AdoptEditing>());
    });

    test('emits AdoptSucceeded with the trimmed name on success', () async {
      final repository = FakePetRepository()..status = _status();
      final cubit = AdoptCubit(repository: repository);
      addTearDown(cubit.close);
      cubit.selectSpecies(PetSpecies.bunny);
      cubit.nameChanged('  Bun  ');

      await cubit.submit();

      expect(repository.adoptCalls, 1);
      expect(repository.lastAdoptArgs, (species: PetSpecies.bunny, name: 'Bun'));
      expect(cubit.state, isA<AdoptSucceeded>());
    });

    test('maps a 400 to AdoptRejectedNotYet', () async {
      final repository = FakePetRepository()
        ..adoptError = const HttpStatusFailure(
          400,
          'You must be paired for at least 24 hours to adopt a pet',
        );
      final cubit = AdoptCubit(repository: repository);
      addTearDown(cubit.close);
      cubit.selectSpecies(PetSpecies.bunny);
      cubit.nameChanged('Bun');

      await cubit.submit();

      expect(cubit.state, isA<AdoptRejectedNotYet>());
    });

    test(
      'maps a 409 to AdoptConflict, parsing the existing name from the message',
      () async {
        final repository = FakePetRepository()
          ..adoptError = const HttpStatusFailure(
            409,
            'Your couple already has a pet! Say hi to Mochi',
          );
        final cubit = AdoptCubit(repository: repository);
        addTearDown(cubit.close);
        cubit.selectSpecies(PetSpecies.bunny);
        cubit.nameChanged('Bun');

        await cubit.submit();

        final state = cubit.state as AdoptConflict;
        expect(state.existingName, 'Mochi');
      },
    );

    test('AdoptConflict has a null existingName when the message is unparseable', () async {
      final repository = FakePetRepository()
        ..adoptError = const HttpStatusFailure(409, null);
      final cubit = AdoptCubit(repository: repository);
      addTearDown(cubit.close);
      cubit.selectSpecies(PetSpecies.bunny);
      cubit.nameChanged('Bun');

      await cubit.submit();

      final state = cubit.state as AdoptConflict;
      expect(state.existingName, isNull);
    });

    test('maps any other failure to AdoptFailed', () async {
      final repository = FakePetRepository()
        ..adoptError = const NetworkUnavailableFailure();
      final cubit = AdoptCubit(repository: repository);
      addTearDown(cubit.close);
      cubit.selectSpecies(PetSpecies.bunny);
      cubit.nameChanged('Bun');

      await cubit.submit();

      expect(cubit.state, isA<AdoptFailed>());
      expect((cubit.state as AdoptFailed).failure, isA<NetworkUnavailableFailure>());
    });
  });
}
