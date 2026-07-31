import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/realtime/backend_user_id_store.dart';
import '../../../core/realtime/cupid_realtime.dart';
import '../data/reminder_local_prefs.dart';
import '../data/reminder_repository.dart';
import '../data/reminder_wire_events.dart';
import '../domain/reminder_stage.dart';
import '../domain/synced_reminder.dart';

/// Firing-overlay presence state (`architecture/solution.md` §4 D4/D5).
sealed class ReminderFiringState {
  const ReminderFiringState();
}

/// No reminder is currently firing for the viewer.
class ReminderFiringClosed extends ReminderFiringState {
  const ReminderFiringClosed();
}

/// The overlay is open. [reminder] is the last-known server row for the
/// firing reminder; [viewerId] is this device's backend user id, used to
/// derive the viewer/partner dismissed flags client-side (§4 D3 pattern).
class ReminderFiringOpen extends ReminderFiringState {
  const ReminderFiringOpen({required this.reminder, required this.viewerId});

  final SyncedReminder reminder;
  final String viewerId;

  /// The other participant's backend user id. Derived from
  /// [SyncedReminder.requesterId]/[SyncedReminder.partnerId] since the row
  /// carries no dedicated "the other one" field.
  String get partnerUserId =>
      viewerId == reminder.requesterId ? reminder.partnerId : reminder.requesterId;

  bool get viewerDismissed => reminder.hasDismissed(viewerId);
  bool get partnerDismissed => reminder.hasDismissed(partnerUserId);
}

/// Opens the firing overlay on the server-sent `triggerAlarm` event, enforces
/// the D4 client-side 5-minute timeout, and re-derives partner-dismissed
/// state from `GET /alarms` per D5 rather than trusting the ephemeral
/// `alarmStoppedByPartner` event alone (`architecture/solution.md` §4).
class ReminderFiringCubit extends Cubit<ReminderFiringState> {
  ReminderFiringCubit({
    required ReminderRepository repository,
    required ReminderLocalPrefs localPrefs,
    required BackendUserIdStore backendUserIdStore,
    Duration timeout = const Duration(minutes: 5),
    Timer Function(Duration duration, void Function() callback)? createTimer,
  }) : _repository = repository,
       _localPrefs = localPrefs,
       _backendUserIdStore = backendUserIdStore,
       _timeout = timeout,
       _createTimer = createTimer ?? Timer.new,
       super(const ReminderFiringClosed()) {
    _subscription = _repository.events().listen(_onEvent);
  }

  final ReminderRepository _repository;
  final ReminderLocalPrefs _localPrefs;
  final BackendUserIdStore _backendUserIdStore;
  final Duration _timeout;

  /// Injected timer seam (D4) so tests do not wait five real minutes.
  final Timer Function(Duration duration, void Function() callback) _createTimer;
  StreamSubscription<RealtimeEvent>? _subscription;
  Timer? _timeoutTimer;

  void _onEvent(RealtimeEvent event) {
    switch (event.name) {
      case ReminderWireEvents.triggerAlarm:
        _open(event.data);
      case ReminderWireEvents.alarmStoppedByPartner:
        // D5: this event is ephemeral and may be missed while backgrounded,
        // so re-derive from REST rather than trusting its `{stopperId}`
        // payload directly.
        unawaited(refreshFromForeground());
      case ReminderWireEvents.alarmFullyStopped:
        _close();
    }
  }

  void _open(Map<String, dynamic> data) {
    final SyncedReminder? reminder = SyncedReminder.fromJson(data);
    final String? viewerId = _backendUserIdStore.backendUserId;
    if (reminder == null || viewerId == null) return;
    _timeoutTimer?.cancel();
    _timeoutTimer = _createTimer(_timeout, _onTimeout);
    emit(ReminderFiringOpen(reminder: reminder, viewerId: viewerId));
    unawaited(refreshFromForeground());
  }

  /// D4: the client-side timeout clears the overlay locally only. It must
  /// **not** emit `stopAlarm` -- that event means "this user swiped" and
  /// would falsely record the viewer as a stopper. The server row may stay
  /// `ringing`; the next `setAlarm` resets it.
  Future<void> _onTimeout() async {
    _timeoutTimer = null;
    if (isClosed) return;
    await _localPrefs.setPendingTimeoutNotice(true);
    if (!isClosed) emit(const ReminderFiringClosed());
  }

  void _close() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    if (!isClosed) emit(const ReminderFiringClosed());
  }

  /// The one dismiss write path (§4 D1 `stopAlarm`). A no-op once the viewer
  /// has already dismissed or the overlay has otherwise closed. Optimistic:
  /// the viewer's own dismissal is known locally the moment it succeeds
  /// (unlike the partner's, which is only knowable through D5's REST
  /// refresh), so it is folded into the reminder locally instead of waiting
  /// on a wire round-trip.
  Future<void> dismiss() async {
    final ReminderFiringState current = state;
    if (current is! ReminderFiringOpen || current.viewerDismissed) return;
    await _repository.dismiss(current.reminder.id);
    if (isClosed) return;
    final ReminderFiringState latest = state;
    if (latest is! ReminderFiringOpen) return;
    final SyncedReminder reminder = latest.reminder;
    emit(
      ReminderFiringOpen(
        reminder: SyncedReminder(
          id: reminder.id,
          time: reminder.time,
          isActive: reminder.isActive,
          status: reminder.status,
          requesterId: reminder.requesterId,
          partnerId: reminder.partnerId,
          stopperIds: {...reminder.stopperIds, latest.viewerId},
        ),
        viewerId: latest.viewerId,
      ),
    );
  }

  /// D5: `alarmStoppedByPartner` is ephemeral (dropped while backgrounded),
  /// so partner-dismissed state is re-derived here from `GET /alarms`
  /// `stopperIds` -- called on overlay open and again whenever
  /// `ReminderOverlayHost` observes a foreground transition.
  Future<void> refreshFromForeground() async {
    if (state is! ReminderFiringOpen) return;
    final SyncedReminder? reminder = await _repository.load();
    if (reminder == null || isClosed) return;
    final ReminderFiringState latest = state;
    if (latest is! ReminderFiringOpen) return;
    emit(ReminderFiringOpen(reminder: reminder, viewerId: latest.viewerId));
  }

  /// Reads and clears the unacknowledged-timeout flag (§4 Data,
  /// `ux/uiux-spec.md` §7) so `ReminderOverlayHost` can surface the one-time
  /// "Reminder timed out" notice on next app open.
  Future<bool> consumePendingTimeoutNotice() async {
    final bool pending = await _localPrefs.loadPendingTimeoutNotice();
    if (pending) {
      await _localPrefs.setPendingTimeoutNotice(false);
    }
    return pending;
  }

  @override
  Future<void> close() {
    _timeoutTimer?.cancel();
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
