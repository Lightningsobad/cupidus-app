import '../data/pet_models.dart';

/// `AdoptCubit` state (`coding-plan/phase-P3-pet-state.md` §Shared Interfaces
/// Produced). The 24h adopt gate is attempt-based
/// (`architecture/solution.md` D3): there is no client-computed "waiting"
/// state here, only [AdoptRejectedNotYet] after a real `400` from
/// `POST /pets/adopt`.
sealed class AdoptState {
  const AdoptState();
}

/// The species/name form, before submit. [isValid] mirrors `AdoptPetDto`: a
/// species must be selected and the trimmed [name] must be 1-30 characters.
class AdoptEditing extends AdoptState {
  const AdoptEditing({
    required this.species,
    required this.name,
    required this.isValid,
  });

  final PetSpecies? species;
  final String name;
  final bool isValid;
}

class AdoptSubmitting extends AdoptState {
  const AdoptSubmitting();
}

class AdoptSucceeded extends AdoptState {
  const AdoptSucceeded(this.status);

  final PetStatus status;
}

/// `POST /pets/adopt` returned `400` (unpaired, or paired less than 24h).
/// Architecture D3: attempt-based, not a client-computed countdown.
class AdoptRejectedNotYet extends AdoptState {
  const AdoptRejectedNotYet();
}

/// `POST /pets/adopt` returned `409` (the couple already has a pet).
/// [existingName] is parsed from the backend failure message
/// (`pets.service.ts` `adopt`: "...Say hi to {name}") when present, `null`
/// when the failure carries no parseable message text.
class AdoptConflict extends AdoptState {
  const AdoptConflict(this.existingName);

  final String? existingName;
}

/// [failure] is a `CupidApiFailure` other than the two mapped cases above.
class AdoptFailed extends AdoptState {
  const AdoptFailed(this.failure);

  final Object failure;
}
