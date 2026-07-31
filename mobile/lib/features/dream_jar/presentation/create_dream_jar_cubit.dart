import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/dream_jar.dart';
import '../data/dream_jar_repository.dart';

/// STORY-014 P3 create-jar state (`ux/uiux-spec.md` §1.3).
sealed class CreateDreamJarState {
  const CreateDreamJarState();
}

class CreateDreamJarIdle extends CreateDreamJarState {
  const CreateDreamJarIdle();
}

class CreateDreamJarSubmitting extends CreateDreamJarState {
  const CreateDreamJarSubmitting();
}

class CreateDreamJarSuccess extends CreateDreamJarState {
  const CreateDreamJarSuccess(this.jar);

  final DreamJar jar;
}

/// [nameInvalid] and [targetAmountInvalid] flag a blank name or a target
/// amount below the backend's min-1 floor (`ux/uiux-spec.md` §1.3). The
/// screen maps these booleans to localized messages rather than the cubit
/// carrying pre-formatted text.
class CreateDreamJarValidationFailed extends CreateDreamJarState {
  const CreateDreamJarValidationFailed({
    required this.nameInvalid,
    required this.targetAmountInvalid,
  });

  final bool nameInvalid;
  final bool targetAmountInvalid;
}

class CreateDreamJarFailed extends CreateDreamJarState {
  const CreateDreamJarFailed(this.failure);

  final Object failure;
}

class CreateDreamJarCubit extends Cubit<CreateDreamJarState> {
  CreateDreamJarCubit(this._repository) : super(const CreateDreamJarIdle());

  final DreamJarRepository _repository;

  /// Ignored while a prior submit is in flight (mirrors
  /// `DreamJarDetailCubit.addContribution`'s double-submission guard: the
  /// state check and the synchronous `emit(Submitting)` both run before the
  /// first `await`, so two back-to-back synchronous calls only reach the
  /// repository once). Validates locally before issuing a request: a blank
  /// [name] or a [targetAmount] below 1 emits
  /// [CreateDreamJarValidationFailed] and never reaches the repository.
  Future<void> submit({
    required String name,
    required num? targetAmount,
    DateTime? deadline,
  }) async {
    if (state is CreateDreamJarSubmitting) return;

    final bool nameInvalid = name.trim().isEmpty;
    final bool targetAmountInvalid = targetAmount == null || targetAmount < 1;
    if (nameInvalid || targetAmountInvalid) {
      emit(
        CreateDreamJarValidationFailed(
          nameInvalid: nameInvalid,
          targetAmountInvalid: targetAmountInvalid,
        ),
      );
      return;
    }

    emit(const CreateDreamJarSubmitting());
    try {
      final jar = await _repository.createJar(
        name: name.trim(),
        targetAmount: targetAmount,
        deadline: deadline,
      );
      if (!isClosed) emit(CreateDreamJarSuccess(jar));
    } catch (failure) {
      if (!isClosed) emit(CreateDreamJarFailed(failure));
    }
  }
}
