import '../../../core/network/cupid_api.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../../../core/realtime/cupid_realtime.dart';
import '../domain/synced_reminder.dart';
import 'reminder_wire_events.dart';

/// Writes go over the socket (D1); hydration reads go over REST raw body
/// (D2) (`architecture/solution.md` §4). `RealtimeNotLiveFailure` and
/// `CupidApiFailure` propagate unchanged — no retry queue (ADR-007b).
class ReminderRepository {
  ReminderRepository({
    required this._api,
    required this._realtime,
    required this._backendUserIdStore,
  });

  final CupidApi _api;
  final RealtimeCoordinator _realtime;
  final BackendUserIdStore _backendUserIdStore;

  /// `GET /alarms` raw body read (D2): the generated
  /// `Epic3SyncedAlarmsApi.alarmsControllerFindOne` is typed
  /// `Future<Response<void>>` because the backend Swagger declares no
  /// response schema, so the `Alarm` row is unreachable through it (mirrors
  /// `auth_repository.dart:99-112`). Returns `null` (not an error) when the
  /// body is `null` — no reminder exists yet.
  Future<SyncedReminder?> load() async {
    final response = await _api.dio.get<Object?>('/alarms');
    return SyncedReminder.fromJson(response.data);
  }

  /// Merged, deduped inbound stream filtered to this feature's five inbound
  /// wire events (§4 D5). Switch on `RealtimeEvent.name`, never `transport`.
  Stream<RealtimeEvent> events() =>
      _realtime.events(names: ReminderWireEvents.inbound);

  Future<void> setTime(DateTime time) => _realtime.emit(
    ReminderWireEvents.setAlarm,
    {
      'time': time.toIso8601String(),
      'userId': _backendUserIdStore.backendUserId,
    },
  );

  Future<void> confirm(String alarmId) => _realtime.emit(
    ReminderWireEvents.confirmAlarm,
    {'alarmId': alarmId, 'userId': _backendUserIdStore.backendUserId},
  );

  Future<void> dismiss(String alarmId) => _realtime.emit(
    ReminderWireEvents.stopAlarm,
    {'alarmId': alarmId, 'userId': _backendUserIdStore.backendUserId},
  );
}
