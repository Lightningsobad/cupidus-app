import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/cupid_api_failure.dart';
import '../data/vibes_repository.dart';
import '../domain/vibe_entry.dart';
import '../domain/vibe_mood.dart';
import 'vibe_state.dart';

/// Drives the `vibe` screen (`ux/uiux-spec.md` §4, `architecture/solution.md`
/// §4 D-010-1/D-010-3, `coding-plan/phase-P1-vibe-cubit.md`). Loads
/// today/history/partner on open and refresh, and submits a mood tap
/// optimistically with revert-on-failure and an in-flight lock so rapid
/// double-taps cannot create duplicate same-day records (R-010-2).
class VibeCubit extends Cubit<VibeState> {
  VibeCubit({required this._repository}) : super(const VibeState());

  final VibesRepository _repository;

  /// Initial fetch; emits a `loading: true` state first (AC1).
  Future<void> load() => _fetchAndEmit(showLoading: true);

  /// Pull-to-refresh fetch; the spinner is owned by `RefreshIndicator`, so
  /// this does not toggle `loading`.
  Future<void> refresh() => _fetchAndEmit(showLoading: false);

  Future<void> _fetchAndEmit({required bool showLoading}) async {
    if (showLoading) emit(state.copyWith(loading: true));
    try {
      final snapshot = await _fetchSnapshot();
      if (isClosed) return;
      emit(
        state.copyWith(
          myToday: snapshot.myToday,
          myWeek: snapshot.myWeek,
          partnerWeek: snapshot.partnerWeek,
          loading: false,
          failure: null,
        ),
      );
    } on CupidApiFailure catch (failure) {
      if (!isClosed) emit(state.copyWith(loading: false, failure: failure));
    }
  }

  /// Immediate-submit mood check-in (UX §4): no separate confirm step, so
  /// tapping a cell optimistically highlights [mood] before the network
  /// call resolves. Ignored while a prior submit is still in flight.
  /// Reverts the optimistic overlay (never `myToday` itself, which was
  /// never touched) and records the failure if the call fails; re-fetches
  /// the full snapshot on success (D-010-1 freshness contract).
  Future<void> pick(VibeMood mood) async {
    if (state.submitting) return;

    emit(
      state.copyWith(optimisticMood: mood, submitting: true, failure: null),
    );

    try {
      await _repository.submitMood(mood);
      final snapshot = await _fetchSnapshot();
      if (isClosed) return;
      emit(
        state.copyWith(
          myToday: snapshot.myToday,
          myWeek: snapshot.myWeek,
          partnerWeek: snapshot.partnerWeek,
          optimisticMood: null,
          submitting: false,
        ),
      );
    } on CupidApiFailure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(optimisticMood: null, submitting: false, failure: failure),
      );
    }
  }

  Future<_Snapshot> _fetchSnapshot() async {
    final myToday = await _repository.fetchMyToday();
    final myHistory = await _repository.fetchMyHistory();
    final partnerHistory = await _repository.fetchPartnerHistory();
    return _Snapshot(
      myToday: myToday,
      myWeek: _moodBucket(myHistory),
      partnerWeek: _moodBucket(partnerHistory),
    );
  }

  List<VibeMood?> _moodBucket(List<VibeEntry> entries) =>
      bucketByLocalDay(entries).map((entry) => entry?.mood).toList(growable: false);
}

class _Snapshot {
  const _Snapshot({
    required this.myToday,
    required this.myWeek,
    required this.partnerWeek,
  });

  final VibeEntry? myToday;
  final List<VibeMood?> myWeek;
  final List<VibeMood?> partnerWeek;
}
