import '../domain/reminder_stage.dart';
import '../domain/synced_reminder.dart';

/// [ReminderScheduleBloc]'s composite view state.
class ReminderScheduleState {
  const ReminderScheduleState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.reminders = const <SyncedReminder>[],
    this.viewerId,
    this.weekdays = const <int>{},
    this.pendingTimeoutNotice = false,
    this.failure,
  });

  final bool isLoading;
  final bool isSubmitting;
  final List<SyncedReminder> reminders;
  final String? viewerId;

  /// Compatibility getter returning the primary/first reminder.
  SyncedReminder? get reminder => reminders.isNotEmpty ? reminders.first : null;

  /// Per-viewer derivation of [reminder], `null` when [reminder] or [viewerId] is.
  ReminderStage? get stage {
    final r = reminder;
    final v = viewerId;
    if (r == null || v == null) return null;
    return r.stageFor(v);
  }

  /// Client-local weekday selection for single-reminder compatibility.
  final Set<int> weekdays;

  /// Client-local unacknowledged-timeout flag.
  final bool pendingTimeoutNotice;

  /// A surfaced failure for inline display.
  final Object? failure;

  ReminderScheduleState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<SyncedReminder>? reminders,
    String? viewerId,
    Set<int>? weekdays,
    bool? pendingTimeoutNotice,
    Object? failure,
    bool clearFailure = false,
  }) {
    return ReminderScheduleState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      reminders: reminders ?? this.reminders,
      viewerId: viewerId ?? this.viewerId,
      weekdays: weekdays ?? this.weekdays,
      pendingTimeoutNotice:
          pendingTimeoutNotice ?? this.pendingTimeoutNotice,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
