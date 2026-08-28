/// Backend transport names frozen by A1/ADR-002
/// (`backend/src/modules/alarms/alarm.constants.ts`). These must never reach
/// the UI as user-facing strings — the internal Dart feature name is
/// "reminders" (`architecture/solution.md` §1 Architectural invariants).
abstract final class ReminderWireEvents {
  static const String setAlarm = 'setAlarm';
  static const String updateAlarm = 'updateAlarm';
  static const String toggleAlarm = 'toggleAlarm';
  static const String deleteAlarm = 'deleteAlarm';
  static const String confirmAlarm = 'confirmAlarm';
  static const String rejectAlarm = 'rejectAlarm';
  static const String stopAlarm = 'stopAlarm';
  static const String newAlarmRequest = 'newAlarmRequest';
  static const String alarmScheduled = 'alarmScheduled';
  static const String alarmDeleted = 'alarmDeleted';
  static const String triggerAlarm = 'triggerAlarm';
  static const String alarmStoppedByPartner = 'alarmStoppedByPartner';
  static const String alarmFullyStopped = 'alarmFullyStopped';

  /// Passed to `RealtimeCoordinator.events(names: ...)` (§4 D5). Feature code
  /// switches on `RealtimeEvent.name`, never on `transport`.
  static const Set<String> inbound = {
    newAlarmRequest,
    alarmScheduled,
    alarmDeleted,
    triggerAlarm,
    alarmStoppedByPartner,
    alarmFullyStopped,
    'alarm:newAlarmRequest',
    'alarm:alarmScheduled',
    'alarm:alarmDeleted',
    'alarm:triggerAlarm',
    'alarm:alarmStoppedByPartner',
    'alarm:alarmFullyStopped',
  };
}
