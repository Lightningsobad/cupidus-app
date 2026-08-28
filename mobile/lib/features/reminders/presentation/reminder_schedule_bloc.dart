import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/realtime/backend_user_id_store.dart';
import '../../../core/realtime/cupid_realtime.dart';
import '../data/reminder_local_prefs.dart';
import '../data/reminder_repository.dart';
import 'reminder_schedule_state.dart';

sealed class ReminderScheduleEvent {
  const ReminderScheduleEvent();
}

/// Dispatched once when the schedule screen mounts: hydrates the local
/// weekday/timeout-notice prefs, loads all server-owned reminders,
/// and starts the inbound realtime subscription.
class ReminderScheduleStarted extends ReminderScheduleEvent {
  const ReminderScheduleStarted();
}

/// The inline-retry affordance.
class ReminderScheduleRefreshRequested extends ReminderScheduleEvent {
  const ReminderScheduleRefreshRequested();
}

/// Client-local weekday selection edit -- persisted.
class ReminderScheduleWeekdaysChanged extends ReminderScheduleEvent {
  const ReminderScheduleWeekdaysChanged(this.weekdays);

  final Set<int> weekdays;
}

/// Submits a time proposal for the single/primary reminder.
class ReminderScheduleTimeSubmitted extends ReminderScheduleEvent {
  const ReminderScheduleTimeSubmitted(this.time);

  final DateTime time;
}

/// Creates a new synced reminder with time, description, and repeat weekdays.
class ReminderScheduleCreated extends ReminderScheduleEvent {
  const ReminderScheduleCreated({
    required this.time,
    this.description,
    this.weekdays,
    this.isActive,
  });

  final DateTime time;
  final String? description;
  final Set<int>? weekdays;
  final bool? isActive;
}

/// Updates an existing synced reminder.
class ReminderScheduleUpdated extends ReminderScheduleEvent {
  const ReminderScheduleUpdated({
    required this.id,
    this.time,
    this.description,
    this.weekdays,
    this.isActive,
  });

  final String id;
  final DateTime? time;
  final String? description;
  final Set<int>? weekdays;
  final bool? isActive;
}

/// Requests a toggle on/off for a reminder (mutual consent required).
class ReminderScheduleToggleRequested extends ReminderScheduleEvent {
  const ReminderScheduleToggleRequested({
    required this.id,
    required this.isActive,
  });

  final String id;
  final bool isActive;
}

/// Requests deletion of a reminder (mutual consent required).
class ReminderScheduleDeleteRequested extends ReminderScheduleEvent {
  const ReminderScheduleDeleteRequested(this.id);

  final String id;
}

/// Confirms an action (create, edit, toggle, or delete) on a reminder.
class ReminderScheduleConfirmRequested extends ReminderScheduleEvent {
  const ReminderScheduleConfirmRequested(this.id);

  final String id;
}

/// Confirms the primary reminder (backward compatibility).
class ReminderScheduleConfirmPressed extends ReminderScheduleEvent {
  const ReminderScheduleConfirmPressed();
}

/// Rejects a proposed action on a reminder.
class ReminderScheduleRejectRequested extends ReminderScheduleEvent {
  const ReminderScheduleRejectRequested(this.id);

  final String id;
}

/// Clears the local `pending_timeout_notice` flag once the toast it drives
/// has been shown.
class ReminderScheduleTimeoutNoticeAcknowledged extends ReminderScheduleEvent {
  const ReminderScheduleTimeoutNoticeAcknowledged();
}

/// Bridges `ReminderRepository.events()` into the bloc's event queue.
class ReminderScheduleRealtimeEventReceived extends ReminderScheduleEvent {
  const ReminderScheduleRealtimeEventReceived();
}

/// Drives the reminder schedule screen with multi-alarm and mutual-consent support.
class ReminderScheduleBloc
    extends Bloc<ReminderScheduleEvent, ReminderScheduleState> {
  ReminderScheduleBloc({
    required this._repository,
    required this._localPrefs,
    required this._backendUserIdStore,
  }) : super(const ReminderScheduleState()) {
    on<ReminderScheduleStarted>(_onStarted);
    on<ReminderScheduleRefreshRequested>(_onRefreshRequested);
    on<ReminderScheduleWeekdaysChanged>(_onWeekdaysChanged);
    on<ReminderScheduleTimeSubmitted>(_onTimeSubmitted);
    on<ReminderScheduleCreated>(_onCreated);
    on<ReminderScheduleUpdated>(_onUpdated);
    on<ReminderScheduleToggleRequested>(_onToggleRequested);
    on<ReminderScheduleDeleteRequested>(_onDeleteRequested);
    on<ReminderScheduleConfirmRequested>(_onConfirmRequested);
    on<ReminderScheduleConfirmPressed>(_onConfirmPressed);
    on<ReminderScheduleRejectRequested>(_onRejectRequested);
    on<ReminderScheduleTimeoutNoticeAcknowledged>(
      _onTimeoutNoticeAcknowledged,
    );
    on<ReminderScheduleRealtimeEventReceived>(_onRealtimeEventReceived);
  }

  final ReminderRepository _repository;
  final ReminderLocalPrefs _localPrefs;
  final BackendUserIdStore _backendUserIdStore;
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;

  Future<void> _onStarted(
    ReminderScheduleStarted event,
    Emitter<ReminderScheduleState> emit,
  ) async {
    _realtimeSubscription ??= _repository.events().listen(
      (_) => add(const ReminderScheduleRealtimeEventReceived()),
    );
    final weekdays = await _localPrefs.loadWeekdays();
    final pendingTimeoutNotice = await _localPrefs.loadPendingTimeoutNotice();
    emit(
      state.copyWith(
        isLoading: true,
        weekdays: weekdays,
        pendingTimeoutNotice: pendingTimeoutNotice,
        viewerId: _backendUserIdStore.backendUserId,
        clearFailure: true,
      ),
    );
    try {
      final reminders = await _repository.loadAll();
      final viewerId = _backendUserIdStore.backendUserId;
      emit(
        state.copyWith(
          isLoading: false,
          reminders: reminders,
          viewerId: viewerId,
          clearFailure: true,
        ),
      );
    } catch (failure) {
      emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _onRefreshRequested(
    ReminderScheduleRefreshRequested event,
    Emitter<ReminderScheduleState> emit,
  ) => _hydrate(emit);

  Future<void> _onRealtimeEventReceived(
    ReminderScheduleRealtimeEventReceived event,
    Emitter<ReminderScheduleState> emit,
  ) => _hydrate(emit);

  Future<void> _hydrate(Emitter<ReminderScheduleState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    try {
      final reminders = await _repository.loadAll();
      final viewerId = _backendUserIdStore.backendUserId;
      emit(
        state.copyWith(
          isLoading: false,
          reminders: reminders,
          viewerId: viewerId,
          clearFailure: true,
        ),
      );
    } catch (failure) {
      emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _onWeekdaysChanged(
    ReminderScheduleWeekdaysChanged event,
    Emitter<ReminderScheduleState> emit,
  ) async {
    await _localPrefs.saveWeekdays(event.weekdays);
    emit(state.copyWith(weekdays: event.weekdays));
  }

  Future<void> _onTimeSubmitted(
    ReminderScheduleTimeSubmitted event,
    Emitter<ReminderScheduleState> emit,
  ) => _runAction(emit, () => _repository.setTime(event.time));

  Future<void> _onCreated(
    ReminderScheduleCreated event,
    Emitter<ReminderScheduleState> emit,
  ) => _runAction(
    emit,
    () => _repository.createReminder(
      time: event.time,
      description: event.description,
      weekdays: event.weekdays,
      isActive: event.isActive,
    ),
  );

  Future<void> _onUpdated(
    ReminderScheduleUpdated event,
    Emitter<ReminderScheduleState> emit,
  ) => _runAction(
    emit,
    () => _repository.updateReminder(
      id: event.id,
      time: event.time,
      description: event.description,
      weekdays: event.weekdays,
      isActive: event.isActive,
    ),
  );

  Future<void> _onToggleRequested(
    ReminderScheduleToggleRequested event,
    Emitter<ReminderScheduleState> emit,
  ) => _runAction(
    emit,
    () => _repository.toggleReminder(id: event.id, isActive: event.isActive),
  );

  Future<void> _onDeleteRequested(
    ReminderScheduleDeleteRequested event,
    Emitter<ReminderScheduleState> emit,
  ) => _runAction(emit, () => _repository.deleteReminder(event.id));

  Future<void> _onConfirmRequested(
    ReminderScheduleConfirmRequested event,
    Emitter<ReminderScheduleState> emit,
  ) => _runAction(emit, () => _repository.confirm(event.id));

  Future<void> _onConfirmPressed(
    ReminderScheduleConfirmPressed event,
    Emitter<ReminderScheduleState> emit,
  ) {
    final reminderId = state.reminder?.id;
    if (reminderId == null) return Future<void>.value();
    return _runAction(emit, () => _repository.confirm(reminderId));
  }

  Future<void> _onRejectRequested(
    ReminderScheduleRejectRequested event,
    Emitter<ReminderScheduleState> emit,
  ) => _runAction(emit, () => _repository.reject(event.id));

  Future<void> _onTimeoutNoticeAcknowledged(
    ReminderScheduleTimeoutNoticeAcknowledged event,
    Emitter<ReminderScheduleState> emit,
  ) async {
    await _localPrefs.setPendingTimeoutNotice(false);
    emit(state.copyWith(pendingTimeoutNotice: false));
  }

  Future<void> _runAction(
    Emitter<ReminderScheduleState> emit,
    Future<void> Function() action,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFailure: true));
    try {
      await action();
      final reminders = await _repository.loadAll();
      final viewerId = _backendUserIdStore.backendUserId;
      emit(
        state.copyWith(
          isSubmitting: false,
          reminders: reminders,
          viewerId: viewerId,
          clearFailure: true,
        ),
      );
    } catch (failure) {
      emit(state.copyWith(isSubmitting: false, failure: failure));
    }
  }

  @override
  Future<void> close() {
    unawaited(_realtimeSubscription?.cancel());
    return super.close();
  }
}
