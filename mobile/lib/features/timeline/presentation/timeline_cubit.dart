import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart'
    as repo;
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Drives the Timeline screen's states from [repo.TimelineRepository]
/// (`architecture/solution.md` §4, `ux/uiux-spec.md` §2). [load] subscribes
/// to the Drift read-through stream and kicks off the first [refresh]; a
/// failed refresh never clears already-emitted [TimelineReady] entries
/// (ADR-007, D-012-1).
class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit(this._repository) : super(const TimelineLoading());

  final repo.TimelineRepository _repository;
  StreamSubscription<List<TimelineEntry>>? _subscription;

  List<TimelineEntry> _lastEntries = const [];
  bool _hasSyncedOnce = false;
  bool _isOffline = false;
  CupidApiFailure? _pendingFailure;

  /// Whether the last refresh attempt found no connectivity. The create
  /// sheet reads this before attempting a save, so the write attempt itself
  /// is prevented while offline rather than failing silently after the fact
  /// (ADR-007: no offline write/outbox queue).
  bool get isOffline => _isOffline;

  Future<void> load() async {
    await _subscription?.cancel();
    _subscription = _repository.watchEntries().listen(_onEntries);
    await refresh();
  }

  Future<void> retry() => refresh();

  Future<void> refresh() async {
    final outcome = await _repository.refresh();
    _applyOutcome(outcome);
  }

  /// Fails fast without ever calling the repository while [isOffline], so no
  /// local write is attempted (ADR-007). Any failure from
  /// [repo.TimelineRepository.createEntry] is rethrown as-is so the sheet
  /// can keep the input populated and show inline retry copy.
  Future<void> createEntry(TimelineDraft draft) async {
    if (_isOffline) {
      throw const NetworkUnavailableFailure();
    }
    final outcome = await _repository.createEntry(draft);
    _applyOutcome(outcome);
  }

  void _onEntries(List<TimelineEntry> entries) {
    _lastEntries = entries;
    _emitForCurrentData();
  }

  void _applyOutcome(repo.TimelineRefreshOutcome outcome) {
    switch (outcome) {
      case repo.TimelineSynced():
        _hasSyncedOnce = true;
        _isOffline = false;
        _pendingFailure = null;
      case repo.TimelineOfflineWithCache():
        _isOffline = true;
        _pendingFailure = null;
      case repo.TimelineOfflineNoCache():
        _isOffline = true;
        _pendingFailure = null;
        if (!isClosed) emit(const TimelineOfflineNoCache());
        return;
      case repo.TimelineRefreshFailed(:final failure):
        _pendingFailure = failure;
    }
    _emitForCurrentData();
  }

  void _emitForCurrentData() {
    if (isClosed) return;
    if (_lastEntries.isNotEmpty) {
      emit(TimelineReady(_lastEntries, isOffline: _isOffline));
      return;
    }
    if (_hasSyncedOnce) {
      emit(const TimelineEmpty());
      return;
    }
    if (_pendingFailure != null) {
      emit(TimelineError(_pendingFailure!));
      return;
    }
    emit(const TimelineLoading());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
