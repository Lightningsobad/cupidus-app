import '../../../core/network/cupid_api_failure.dart';
import '../domain/vibe_entry.dart';
import '../domain/vibe_mood.dart';

const _emptyWeek = <VibeMood?>[null, null, null, null, null, null, null];

/// `vibe` screen state (`ux/uiux-spec.md` §4,
/// `coding-plan/phase-P1-vibe-cubit.md`). The mood grid is simultaneously
/// the input control and the status display, so every field renders
/// together rather than switching between mutually exclusive screens
/// (contrast the auth cubits' sealed states).
class VibeState {
  const VibeState({
    this.myToday,
    this.myWeek = _emptyWeek,
    this.partnerWeek = _emptyWeek,
    this.optimisticMood,
    this.loading = false,
    this.submitting = false,
    this.failure,
  });

  /// `GET /vibes/today`; authoritative for "my today" (D-010-3 — never
  /// recomputed from history).
  final VibeEntry? myToday;

  /// 7-slot, oldest→newest, local-day mood bucket of my history.
  final List<VibeMood?> myWeek;

  /// 7-slot, oldest→newest, local-day mood bucket of the partner's history.
  final List<VibeMood?> partnerWeek;

  /// The partner's mood for local today, derived from [partnerWeek]'s last
  /// (newest) slot — never a separate `days=1` call (D-010-3).
  VibeMood? get partnerToday => partnerWeek.isEmpty ? null : partnerWeek.last;

  /// The tapped-but-unconfirmed mood shown immediately on submit
  /// (`ux/uiux-spec.md` §4); overlays [myToday] until the submit settles.
  final VibeMood? optimisticMood;

  /// The mood the grid should currently highlight: the pending optimistic
  /// pick if one is in flight, otherwise the last confirmed value.
  VibeMood? get selectedMood => optimisticMood ?? myToday?.mood;

  /// `true` only during the initial `load()`; `refresh()` does not toggle
  /// this (the pull-to-refresh spinner is owned by `RefreshIndicator`, not
  /// the cubit).
  final bool loading;

  /// `true` while a submit is in flight; locks the grid against re-taps
  /// (R-010-2).
  final bool submitting;

  /// The last `CupidApiFailure`, or `null` once cleared. Presentation maps
  /// it to inline text only.
  final CupidApiFailure? failure;

  static const _unset = Object();

  VibeState copyWith({
    Object? myToday = _unset,
    List<VibeMood?>? myWeek,
    List<VibeMood?>? partnerWeek,
    Object? optimisticMood = _unset,
    bool? loading,
    bool? submitting,
    Object? failure = _unset,
  }) {
    return VibeState(
      myToday: identical(myToday, _unset) ? this.myToday : myToday as VibeEntry?,
      myWeek: myWeek ?? this.myWeek,
      partnerWeek: partnerWeek ?? this.partnerWeek,
      optimisticMood: identical(optimisticMood, _unset)
          ? this.optimisticMood
          : optimisticMood as VibeMood?,
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      failure: identical(failure, _unset) ? this.failure : failure as CupidApiFailure?,
    );
  }
}
