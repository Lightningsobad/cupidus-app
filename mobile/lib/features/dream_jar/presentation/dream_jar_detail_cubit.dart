import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/dream_jar.dart';
import '../data/dream_jar_repository.dart';

/// STORY-014 P2 jar detail state (`ux/uiux-spec.md` §1.1, §1.8).
sealed class DreamJarDetailState {
  const DreamJarDetailState();
}

class DreamJarDetailLoading extends DreamJarDetailState {
  const DreamJarDetailLoading();
}

/// [isAddingContribution] gates the quick-add tiles so a second tap while a
/// `POST .../contributions` is in flight cannot fire a duplicate,
/// non-idempotent contribution (master-plan §3A "Double contribution
/// submission"). [contributionFailure] carries the most recent failed
/// quick-add attempt, if any, for inline display; it is cleared on the next
/// attempt.
class DreamJarDetailLoaded extends DreamJarDetailState {
  const DreamJarDetailLoaded({
    required this.jar,
    this.isAddingContribution = false,
    this.contributionFailure,
  });

  final DreamJar jar;
  final bool isAddingContribution;
  final Object? contributionFailure;

  DreamJarDetailLoaded copyWith({
    DreamJar? jar,
    bool? isAddingContribution,
    Object? contributionFailure,
  }) => DreamJarDetailLoaded(
    jar: jar ?? this.jar,
    isAddingContribution: isAddingContribution ?? this.isAddingContribution,
    contributionFailure: contributionFailure,
  );
}

/// AC3: an unpaired user's `fetchJar` never resolves; render the unpaired
/// notice instead of a bare error.
class DreamJarDetailUnpaired extends DreamJarDetailState {
  const DreamJarDetailUnpaired();
}

/// Any other repository failure (e.g. jar not found, network failure).
class DreamJarDetailFailed extends DreamJarDetailState {
  const DreamJarDetailFailed(this.failure);

  final Object failure;
}

class DreamJarDetailCubit extends Cubit<DreamJarDetailState> {
  DreamJarDetailCubit({required this._repository, required this._jarId})
    : super(const DreamJarDetailLoading());

  final DreamJarRepository _repository;
  final String _jarId;

  Future<void> loadJar() async {
    emit(const DreamJarDetailLoading());
    try {
      final jar = await _repository.fetchJar(_jarId);
      if (!isClosed) emit(DreamJarDetailLoaded(jar: jar));
    } on DreamJarUnpairedFailure {
      if (!isClosed) emit(const DreamJarDetailUnpaired());
    } catch (failure) {
      if (!isClosed) emit(DreamJarDetailFailed(failure));
    }
  }

  /// Ignored while a prior contribution is still in flight, per the
  /// "Double contribution submission" risk surface.
  Future<void> addContribution(num amount) async {
    final currentState = state;
    if (currentState is! DreamJarDetailLoaded ||
        currentState.isAddingContribution) {
      return;
    }

    emit(
      currentState.copyWith(
        isAddingContribution: true,
        contributionFailure: null,
      ),
    );
    try {
      await _repository.addContribution(jarId: _jarId, amount: amount);
      final updatedJar = await _repository.fetchJar(_jarId);
      if (!isClosed) emit(DreamJarDetailLoaded(jar: updatedJar));
    } catch (failure) {
      if (!isClosed) {
        final latestState = state;
        if (latestState is DreamJarDetailLoaded) {
          emit(
            latestState.copyWith(
              isAddingContribution: false,
              contributionFailure: failure,
            ),
          );
        }
      }
    }
  }
}
