import '../data/pet_models.dart';

/// `PetCubit` state (`architecture/solution.md` §2 Mobile contract,
/// `coding-plan/phase-P3-pet-state.md` §Shared Interfaces Produced). AC3's
/// unpaired hard gate is [PetLocked]; [PetReady.cooldownRemaining] is
/// re-derived from `status.pet.lastInteraction` rather than stored as a
/// countdown, so it stays correct across reload and backgrounding.
sealed class PetState {
  const PetState();
}

/// Shown before the first `load()` resolves, and while a reload is in
/// flight.
class PetLoading extends PetState {
  const PetLoading();
}

/// AC3 hard gate: the current user has no partner. `PetCubit` never calls
/// `readStatus()`, `interact()`, or `adopt()` while in this state.
class PetLocked extends PetState {
  const PetLocked();
}

/// Paired, but `GET /pets/status` returned an empty body — no pet adopted
/// yet.
class PetNoPet extends PetState {
  const PetNoPet();
}

/// A pet exists. [cooldownRemaining] is `null` when Feed/Play may be tapped,
/// otherwise the time left before the backend's 5s interaction cooldown
/// clears (`ux/uiux-spec.md` §5 Open Item 1).
class PetReady extends PetState {
  const PetReady({required this.status, required this.cooldownRemaining});

  final PetStatus status;
  final Duration? cooldownRemaining;
}

/// [failure] is a `CupidApiFailure` — map it with a failure-text helper
/// before showing it. Never emitted for the cooldown `400` (see `PetCubit`).
class PetFailure extends PetState {
  const PetFailure(this.failure);

  final Object failure;
}
