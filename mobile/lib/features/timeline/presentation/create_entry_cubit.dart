import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// States for [CreateEntryCubit] (`coding-plan/phase-P6-create-memory-
/// sheet.md`).
sealed class CreateEntryState {
  const CreateEntryState();
}

/// The sheet is open and awaiting input; also the state after an empty-title
/// submit is rejected (no network call, matching the backend required-field
/// contract).
class CreateEntryEditing extends CreateEntryState {
  const CreateEntryEditing();
}

/// A create request is in flight.
class CreateEntrySubmitting extends CreateEntryState {
  const CreateEntrySubmitting();
}

/// The create succeeded; the timeline list refreshes through the existing
/// Drift stream, so this state carries no data.
class CreateEntrySuccess extends CreateEntryState {
  const CreateEntrySuccess();
}

/// The submit was blocked or failed on connectivity (ADR-007: no offline
/// write/outbox queue). Reached either proactively, before any repository
/// call, or after a [NetworkUnavailableFailure]/[TimeoutFailure] from
/// [TimelineRepository.createEntry]. Callers must keep every field populated
/// and never queue the entry.
class CreateEntryBlockedOffline extends CreateEntryState {
  const CreateEntryBlockedOffline();
}

/// The backend 404d the create because the user is not paired.
class CreateEntryPairingRequired extends CreateEntryState {
  const CreateEntryPairingRequired();
}

/// Any other [CupidApiFailure]; the generic error copy applies.
class CreateEntryFailed extends CreateEntryState {
  const CreateEntryFailed(this.failure);

  final CupidApiFailure failure;
}

/// Drives the create-memory sheet's submit flow. Calls
/// [TimelineRepository.createEntry] directly rather than through
/// `TimelineCubit.createEntry` (P4): a successful create's cache write is
/// picked up by the shared `TimelineCubit`'s own `watchEntries` subscription,
/// so this cubit never mutates the timeline list itself and stays
/// independently testable.
class CreateEntryCubit extends Cubit<CreateEntryState> {
  CreateEntryCubit(this._repository, {required bool Function() isOffline})
    // ignore: prefer_initializing_formals
    : _isOffline = isOffline,
      super(const CreateEntryEditing());

  final TimelineRepository _repository;
  final bool Function() _isOffline;

  /// Rejects an empty title with no network call, then fails fast without
  /// calling the repository while the timeline is already known to be
  /// offline (ADR-007). [UnauthorizedFailure] is rethrown so it reaches the
  /// app's existing session/re-auth path rather than a second one built here.
  Future<void> submit(TimelineDraft draft) async {
    if (draft.title.trim().isEmpty) {
      emit(const CreateEntryEditing());
      return;
    }
    if (_isOffline()) {
      emit(const CreateEntryBlockedOffline());
      return;
    }
    emit(const CreateEntrySubmitting());
    try {
      await _repository.createEntry(draft);
      emit(const CreateEntrySuccess());
    } on UnauthorizedFailure {
      rethrow;
    } on CupidApiFailure catch (failure) {
      if (failure is NetworkUnavailableFailure || failure is TimeoutFailure) {
        emit(const CreateEntryBlockedOffline());
      } else if (failure is HttpStatusFailure && failure.statusCode == 404) {
        emit(const CreateEntryPairingRequired());
      } else {
        emit(CreateEntryFailed(failure));
      }
    }
  }
}
