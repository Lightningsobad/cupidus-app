import '../../../core/network/cupid_api.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../../../core/realtime/cupid_realtime.dart';
import '../domain/synced_reminder.dart';
import 'reminder_wire_events.dart';

/// Writes go over the socket; hydration reads go over REST raw body.
class ReminderRepository {
  ReminderRepository({
    required this._api,
    required this._realtime,
    required this._backendUserIdStore,
  });

  final CupidApi _api;
  final RealtimeCoordinator _realtime;
  final BackendUserIdStore _backendUserIdStore;

  /// Loads all alarms for the couple from `GET /alarms`.
  Future<List<SyncedReminder>> loadAll() async {
    final response = await _api.dio.get<Object?>('/alarms');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => SyncedReminder.fromJson(e))
          .whereType<SyncedReminder>()
          .toList();
    } else if (data is Map) {
      final single = SyncedReminder.fromJson(data);
      return single != null ? <SyncedReminder>[single] : <SyncedReminder>[];
    }
    return <SyncedReminder>[];
  }

  /// Backward compatibility for single-reminder callers.
  Future<SyncedReminder?> load() async {
    final list = await loadAll();
    return list.isNotEmpty ? list.first : null;
  }

  /// Merged, deduped inbound stream filtered to this feature's inbound wire events.
  Stream<RealtimeEvent> events() =>
      _realtime.events(names: ReminderWireEvents.inbound);

  Future<void> setTime(DateTime time) => createReminder(time: time);

  Future<void> createReminder({
    required DateTime time,
    String? description,
    Set<int>? weekdays,
    bool? isActive,
  }) async {
    try {
      await _api.dio.post<Object?>('/alarms', data: {
        'time': time.toIso8601String(),
        if (description != null) 'description': description,
        if (weekdays != null) 'weekdays': weekdays.map((e) => e.toString()).toList(),
        if (isActive != null) 'isActive': isActive,
      });
    } catch (_) {}
    await _realtime.emit(
      ReminderWireEvents.setAlarm,
      {
        'time': time.toIso8601String(),
        if (description != null) 'description': description,
        if (weekdays != null) 'weekdays': weekdays.map((e) => e.toString()).toList(),
        if (isActive != null) 'isActive': isActive,
        'userId': _backendUserIdStore.backendUserId,
      },
    );
  }

  Future<void> updateReminder({
    required String id,
    DateTime? time,
    String? description,
    Set<int>? weekdays,
    bool? isActive,
  }) async {
    try {
      await _api.dio.put<Object?>('/alarms/$id', data: {
        if (time != null) 'time': time.toIso8601String(),
        if (description != null) 'description': description,
        if (weekdays != null) 'weekdays': weekdays.map((e) => e.toString()).toList(),
        if (isActive != null) 'isActive': isActive,
      });
    } catch (_) {}
    await _realtime.emit(
      ReminderWireEvents.updateAlarm,
      {
        'alarmId': id,
        if (time != null) 'time': time.toIso8601String(),
        if (description != null) 'description': description,
        if (weekdays != null) 'weekdays': weekdays.map((e) => e.toString()).toList(),
        if (isActive != null) 'isActive': isActive,
        'userId': _backendUserIdStore.backendUserId,
      },
    );
  }

  Future<void> toggleReminder({
    required String id,
    required bool isActive,
  }) async {
    try {
      await _api.dio.patch<Object?>('/alarms/$id/toggle', data: {'isActive': isActive});
    } catch (_) {}
    await _realtime.emit(
      ReminderWireEvents.toggleAlarm,
      {
        'alarmId': id,
        'isActive': isActive,
        'userId': _backendUserIdStore.backendUserId,
      },
    );
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _api.dio.delete<Object?>('/alarms/$id');
    } catch (_) {}
    await _realtime.emit(
      ReminderWireEvents.deleteAlarm,
      {
        'alarmId': id,
        'userId': _backendUserIdStore.backendUserId,
      },
    );
  }

  Future<void> confirm(String alarmId) async {
    try {
      await _api.dio.patch<Object?>('/alarms/$alarmId/confirm');
    } catch (_) {}
    await _realtime.emit(
      ReminderWireEvents.confirmAlarm,
      {'alarmId': alarmId, 'userId': _backendUserIdStore.backendUserId},
    );
  }

  Future<void> reject(String alarmId) async {
    try {
      await _api.dio.patch<Object?>('/alarms/$alarmId/reject');
    } catch (_) {}
    await _realtime.emit(
      ReminderWireEvents.rejectAlarm,
      {'alarmId': alarmId, 'userId': _backendUserIdStore.backendUserId},
    );
  }

  Future<void> dismiss(String alarmId) async {
    try {
      await _api.dio.patch<Object?>('/alarms/$alarmId/stop');
    } catch (_) {}
    await _realtime.emit(
      ReminderWireEvents.stopAlarm,
      {'alarmId': alarmId, 'userId': _backendUserIdStore.backendUserId},
    );
  }
}
