/// Immutable client view of the frozen backend `Alarm` row
/// (`backend/src/modules/alarms/entities/alarm.entity.ts`, A1 freeze).
class SyncedReminder {
  const SyncedReminder({
    required this.id,
    required this.time,
    required this.isActive,
    required this.status,
    required this.requesterId,
    required this.partnerId,
    required this.stopperIds,
  });

  final String id;
  final DateTime time;
  final bool isActive;

  /// One of `pending_confirmation` | `scheduled` | `ringing` | `stopped`
  /// (frozen backend values, §4 D3).
  final String status;
  final String requesterId;
  final String partnerId;

  /// User ids that have already dismissed the current `ringing` reminder.
  final Set<String> stopperIds;

  /// Tolerates a `null` body (D2 empty-state contract: no reminder yet) and a
  /// missing/empty `stopperIds` array.
  static SyncedReminder? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final stopperIdsRaw = json['stopperIds'];
    return SyncedReminder(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      isActive: json['isActive'] as bool? ?? true,
      status: json['status'] as String,
      requesterId: json['requesterId'] as String,
      partnerId: json['partnerId'] as String,
      stopperIds: stopperIdsRaw is List
          ? stopperIdsRaw.map((e) => e as String).toSet()
          : const <String>{},
    );
  }
}
