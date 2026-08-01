import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/pet_models.dart';
import '../data/pet_repository.dart';
import 'adopt_state.dart';

class AdoptCubit extends Cubit<AdoptState> {
  AdoptCubit({required this._repository})
      : super(const AdoptEditing(species: null, name: '', isValid: false));

  final PetRepository _repository;

  /// Matches the tail of `pets.service.ts` `adopt`'s 409 message:
  /// `'Your couple already has a pet! Say hi to ' + existing.name`.
  static final _existingNamePattern = RegExp(r'Say hi to (.+)$');

  void selectSpecies(PetSpecies species) {
    final current = state;
    if (current is! AdoptEditing) return;
    emit(_editingWith(current, species: species));
  }

  void nameChanged(String name) {
    final current = state;
    if (current is! AdoptEditing) return;
    emit(_editingWith(current, name: name));
  }

  Future<void> submit() async {
    final current = state;
    if (current is! AdoptEditing || !current.isValid) return;
    final species = current.species!;
    final name = current.name.trim();
    emit(const AdoptSubmitting());
    try {
      final status = await _repository.adopt(species: species, name: name);
      if (!isClosed) emit(AdoptSucceeded(status));
    } on CupidApiFailure catch (failure) {
      if (isClosed) return;
      if (failure is HttpStatusFailure && failure.statusCode == 400) {
        emit(const AdoptRejectedNotYet());
      } else if (failure is HttpStatusFailure && failure.statusCode == 409) {
        emit(AdoptConflict(_existingNameFrom(failure.message)));
      } else {
        emit(AdoptFailed(failure));
      }
    }
  }

  AdoptEditing _editingWith(
    AdoptEditing current, {
    PetSpecies? species,
    String? name,
  }) {
    final nextSpecies = species ?? current.species;
    final nextName = name ?? current.name;
    final trimmedLength = nextName.trim().length;
    return AdoptEditing(
      species: nextSpecies,
      name: nextName,
      isValid: nextSpecies != null && trimmedLength >= 1 && trimmedLength <= 30,
    );
  }

  String? _existingNameFrom(String? message) {
    if (message == null) return null;
    return _existingNamePattern.firstMatch(message)?.group(1)?.trim();
  }
}
