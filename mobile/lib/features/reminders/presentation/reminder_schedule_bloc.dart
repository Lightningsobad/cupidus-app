import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/realtime/backend_user_id_store.dart';
import '../../../core/realtime/cupid_realtime.dart';
import '../data/reminder_local_prefs.dart';
import '../data/reminder_repository.dart';
import '../domain/reminder_stage.dart';
import 'reminder_schedule_state.dart';

sealed class ReminderScheduleEvent {
  const ReminderScheduleEvent();
}

/// Dispatched once when the schedule screen mounts: hydrates the local
/// weekday/timeout-notice prefs, loads the server-owned reminder (§4 D2),
/// and starts the inbound realtime subscription (§4 D5).
class ReminderScheduleStarted extends ReminderScheduleEvent {
  const ReminderScheduleStarted();
}

/// The inline-retry affordance required by the §4 D1/D2 error contract.
class ReminderScheduleRefreshRequested extends ReminderScheduleEvent {
  const ReminderScheduleRefreshRequested();
}

/// Client-local weekday selection edit (§4 Data, ASSUMPTION-1) -- persisted,
/// never sent over the wire.
class ReminderScheduleWeekdaysChanged extends ReminderScheduleEvent {
  const ReminderScheduleWeekdaysChanged(this.weekdays);

  final Set<int> weekdays;
}

/// The single absolute occurrence timestamp the weekday selection computed
/// (ASSUMPTION-1); written over the socket via `setAlarm` (§4 D1).
class ReminderScheduleTimeSubmitted extends ReminderScheduleEvent {
  const ReminderScheduleTimeSubmitted(this.time);

  final DateTime time;
}

/// Confirms the current `pending_confirmation` reminder (§4 D1 `confirmAlarm`).
class ReminderScheduleConfirmPressed extends ReminderScheduleEvent {
  const ReminderScheduleConfirmPressed();
}

/// Clears the local `pending_timeout_notice` flag once the toast it drives
/// has been shown (§4 D4/Data).
class ReminderScheduleTimeoutNoticeAcknowledged extends ReminderScheduleEvent {
  const ReminderScheduleTimeoutNoticeAcknowledged();
}

/// Bridges `ReminderRepository.events()` (§4 D5) into the bloc's own event
/// queue. Every inbound wire event re-hydrates from `GET /alarms` instead of
/// being parsed ad hoc: `alarmStoppedByPartner`'s `{stopperId}`-only payload
/// cannot rebuild the full row anyway, so a REST re-fetch is the one
/// derivation path for every inbound event (§4 D5).
class ReminderScheduleRealtimeEventReceived extends ReminderScheduleEvent {
  const ReminderScheduleRealtimeEventReceived();
}

/// Drives the reminder schedule screen (P2/P4): server-derived stage (§4 D3),
/// client-local weekday selection and timeout-notice flag (§4 Data), and the
/// `setTime`/`confirm` write actions (§4 D1). The firing overlay's own
/// 5-minute timeout is `ReminderFiringCubit`'s concern (P3); this bloc only
/// reads/clears the `pending_timeout_notice` flag that timeout leaves behind.
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
    on<ReminderScheduleConfirmPressed>(_onConfirmPressed);
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
        weekdays: weekdays,
        pendingTimeoutNotice: pendingTimeoutNotice,
      ),
    );
    await _hydrate(emit);
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
      final reminder = await _repository.load();
      final viewerId = _backendUserIdStore.backendUserId;
      final stage = reminder != null && viewerId != null
          ? reminder.stageFor(viewerId)
          : null;
      emit(
        ReminderScheduleState(
          isLoading: false,
          reminder: reminder,
          stage: stage,
          weekdays: state.weekdays,
          pendingTimeoutNotice: state.pendingTimeoutNotice,
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

  Future<void> _onConfirmPressed(
    ReminderScheduleConfirmPressed event,
    Emitter<ReminderScheduleState> emit,
  ) {
    final reminderId = state.reminder?.id;
    if (reminderId == null) return Future<void>.value();
    return _runAction(emit, () => _repository.confirm(reminderId));
  }

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
      emit(state.copyWith(isSubmitting: false));
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
