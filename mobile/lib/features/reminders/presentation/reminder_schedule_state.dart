import '../domain/reminder_stage.dart';
import '../domain/synced_reminder.dart';

/// [ReminderScheduleBloc]'s composite view state. A single mutable-shaped
/// immutable class (rather than the sealed-variant style used by the
/// one-shot auth cubits) because the schedule screen must keep showing
/// already-loaded [reminder]/[stage] data underneath an inline retry
/// affordance on [failure] (`architecture/solution.md` §4 D1/D2 error
/// contract: never a silent drop, never a full-screen wipe).
class ReminderScheduleState {
  const ReminderScheduleState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.reminder,
    this.stage,
    this.weekdays = const <int>{},
    this.pendingTimeoutNotice = false,
    this.failure,
  });

  /// True while the initial hydrate or a manual/realtime-triggered refresh
  /// is in flight.
  final bool isLoading;

  /// True while a `setTime`/`confirm` write is in flight.
  final bool isSubmitting;

  /// Server-owned view; `null` is the valid empty-schedule state (§4 D2:
  /// `GET /alarms` may return `null`, not an error).
  final SyncedReminder? reminder;

  /// Per-viewer derivation of [reminder] (§4 D3), `null` when [reminder] is.
  final ReminderStage? stage;

  /// Client-local weekday selection (§4 Data, ASSUMPTION-1).
  final Set<int> weekdays;

  /// Client-local unacknowledged-timeout flag (§4 D4/Data).
  final bool pendingTimeoutNotice;

  /// A `RealtimeNotLiveFailure` or `CupidApiFailure` surfaced as an inline
  /// retry affordance -- never replaces already-loaded [reminder]/[stage].
  final Object? failure;

  ReminderScheduleState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    Set<int>? weekdays,
    bool? pendingTimeoutNotice,
    Object? failure,
    bool clearFailure = false,
  }) {
    return ReminderScheduleState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      reminder: reminder,
      stage: stage,
      weekdays: weekdays ?? this.weekdays,
      pendingTimeoutNotice: pendingTimeoutNotice ?? this.pendingTimeoutNotice,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
