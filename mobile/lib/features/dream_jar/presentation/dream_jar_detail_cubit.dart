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
///
/// [contributions] backs the "who loves the jar more" comparison the design
/// source places on this screen. It is loaded best-effort: a contributions
/// failure leaves the list empty rather than failing the whole screen, since
/// the jar itself already loaded.
class DreamJarDetailLoaded extends DreamJarDetailState {
  const DreamJarDetailLoaded({
    required this.jar,
    this.contributions = const <Contribution>[],
    this.isAddingContribution = false,
    this.isApproving = false,
    this.isRejecting = false,
    this.contributionFailure,
    this.actionFailure,
  });

  final DreamJar jar;
  final List<Contribution> contributions;
  final bool isAddingContribution;
  final bool isApproving;
  final bool isRejecting;
  final Object? contributionFailure;
  final Object? actionFailure;

  DreamJarDetailLoaded copyWith({
    DreamJar? jar,
    List<Contribution>? contributions,
    bool? isAddingContribution,
    bool? isApproving,
    bool? isRejecting,
    Object? contributionFailure,
    Object? actionFailure,
  }) => DreamJarDetailLoaded(
    jar: jar ?? this.jar,
    contributions: contributions ?? this.contributions,
    isAddingContribution: isAddingContribution ?? this.isAddingContribution,
    isApproving: isApproving ?? this.isApproving,
    isRejecting: isRejecting ?? this.isRejecting,
    contributionFailure: contributionFailure,
    actionFailure: actionFailure,
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
      await _loadContributions();
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
      if (!isClosed) {
        emit(
          DreamJarDetailLoaded(
            jar: updatedJar,
            contributions: currentState.contributions,
          ),
        );
      }
      await _loadContributions();
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

  Future<void> approveJar() async {
    final currentState = state;
    if (currentState is! DreamJarDetailLoaded || currentState.isApproving) {
      return;
    }

    emit(currentState.copyWith(isApproving: true, actionFailure: null));
    try {
      final updatedJar = await _repository.approveJar(_jarId);
      if (!isClosed) {
        emit(
          currentState.copyWith(
            jar: updatedJar,
            isApproving: false,
          ),
        );
      }
    } catch (failure) {
      if (!isClosed) {
        final latest = state;
        if (latest is DreamJarDetailLoaded) {
          emit(latest.copyWith(isApproving: false, actionFailure: failure));
        }
      }
    }
  }

  Future<void> rejectJar() async {
    final currentState = state;
    if (currentState is! DreamJarDetailLoaded || currentState.isRejecting) {
      return;
    }

    emit(currentState.copyWith(isRejecting: true, actionFailure: null));
    try {
      final updatedJar = await _repository.rejectJar(_jarId);
      if (!isClosed) {
        emit(
          currentState.copyWith(
            jar: updatedJar,
            isRejecting: false,
          ),
        );
      }
    } catch (failure) {
      if (!isClosed) {
        final latest = state;
        if (latest is DreamJarDetailLoaded) {
          emit(latest.copyWith(isRejecting: false, actionFailure: failure));
        }
      }
    }
  }

  /// Loads the comparison card's data *after* the jar is already on screen,
  /// so a slow or failing contributions call never delays or breaks the jar
  /// itself — the comparison is a cosmetic aggregate.
  Future<void> _loadContributions() async {
    final List<Contribution> contributions;
    try {
      contributions = await _repository.fetchContributions(_jarId);
    } catch (_) {
      return;
    }
    final currentState = state;
    if (isClosed || currentState is! DreamJarDetailLoaded) return;
    emit(currentState.copyWith(contributions: contributions));
  }
}
