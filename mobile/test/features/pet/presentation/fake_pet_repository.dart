import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_repository.dart';

/// A hand-rolled `PetRepository` double: this story's write scope forbids a
/// new pub dependency (`architecture/solution.md` §4 Mobile Lane Handoff),
/// so no mocking package is available (mirrors `pet_repository_test.dart`'s
/// own hand-rolled `HttpClientAdapter` double for the same reason).
class FakePetRepository implements PetRepository {
  bool paired = true;
  PetStatus? status;

  Object? readPairingError;
  Object? readStatusError;
  Object? interactError;
  Object? adoptError;

  /// Set to override the status returned by a successful `interact()`;
  /// falls back to [status] when null.
  PetStatus? statusAfterInteract;

  /// Set to override the status returned by a successful `adopt()`; falls
  /// back to [status] when null.
  PetStatus? statusAfterAdopt;

  int readPairingCalls = 0;
  int readStatusCalls = 0;
  int interactCalls = 0;
  int adoptCalls = 0;

  ({PetSpecies species, String name})? lastAdoptArgs;

  @override
  Future<PetPairing> readPairing() async {
    readPairingCalls++;
    if (readPairingError != null) throw readPairingError!;
    return PetPairing(isPaired: paired);
  }

  @override
  Future<PetStatus?> readStatus() async {
    readStatusCalls++;
    if (readStatusError != null) throw readStatusError!;
    return status;
  }

  @override
  Future<PetStatus> interact() async {
    interactCalls++;
    if (interactError != null) throw interactError!;
    status = statusAfterInteract ?? status;
    return status!;
  }

  @override
  Future<PetStatus> adopt({
    required PetSpecies species,
    required String name,
  }) async {
    adoptCalls++;
    lastAdoptArgs = (species: species, name: name);
    if (adoptError != null) throw adoptError!;
    status = statusAfterAdopt ?? status;
    return status!;
  }
}
