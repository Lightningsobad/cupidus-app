/// Immutable client view of the backend `Alarm` row
/// (`backend/src/modules/alarms/entities/alarm.entity.ts`).
class SyncedReminder {
  const SyncedReminder({
    required this.id,
    required this.time,
    this.description = 'Nhắc nhở đồng bộ',
    this.weekdays = const <int>{},
    required this.isActive,
    this.targetIsActive,
    required this.status,
    required this.requesterId,
    required this.partnerId,
    required this.stopperIds,
  });

  final String id;
  final DateTime time;
  final String description;

  /// Set of days of week (1=Monday..7=Sunday). Empty means one-time alarm.
  final Set<int> weekdays;
  final bool isActive;

  /// Target active state when in `pending_toggle` status.
  final bool? targetIsActive;

  /// One of `pending_confirmation` | `pending_toggle` | `pending_deletion` | `scheduled` | `ringing` | `stopped`
  final String status;
  final String requesterId;
  final String partnerId;

  /// User ids that have already dismissed the current `ringing` reminder.
  final Set<String> stopperIds;

  bool hasDismissed(String userId) => stopperIds.contains(userId);

  bool needsMyConfirmation(String myUserId) =>
      requesterId != myUserId &&
      (status == 'pending_confirmation' ||
          status == 'pending_toggle' ||
          status == 'pending_deletion');

  bool isAwaitingPartner(String myUserId) =>
      requesterId == myUserId &&
      (status == 'pending_confirmation' ||
          status == 'pending_toggle' ||
          status == 'pending_deletion');

  bool get isPendingDeletion => status == 'pending_deletion';
  bool get isPendingToggle => status == 'pending_toggle';
  bool get isPendingCreationOrEdit => status == 'pending_confirmation';
  bool get isBothConfirmed => status == 'scheduled';
  bool get isRinging => status == 'ringing';

  SyncedReminder copyWith({
    String? id,
    DateTime? time,
    String? description,
    Set<int>? weekdays,
    bool? isActive,
    bool? targetIsActive,
    String? status,
    String? requesterId,
    String? partnerId,
    Set<String>? stopperIds,
  }) {
    return SyncedReminder(
      id: id ?? this.id,
      time: time ?? this.time,
      description: description ?? this.description,
      weekdays: weekdays ?? this.weekdays,
      isActive: isActive ?? this.isActive,
      targetIsActive: targetIsActive ?? this.targetIsActive,
      status: status ?? this.status,
      requesterId: requesterId ?? this.requesterId,
      partnerId: partnerId ?? this.partnerId,
      stopperIds: stopperIds ?? this.stopperIds,
    );
  }

  /// Tolerates a `null` body (empty-state contract: no reminder yet) and a
  /// missing/empty `stopperIds` or `weekdays` array.
  static SyncedReminder? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final stopperIdsRaw = json['stopperIds'];
    final weekdaysRaw = json['weekdays'];

    final Set<int> parsedWeekdays;
    if (weekdaysRaw is List) {
      parsedWeekdays = weekdaysRaw
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toSet();
    } else if (weekdaysRaw is String && weekdaysRaw.isNotEmpty) {
      parsedWeekdays = weekdaysRaw
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toSet();
    } else {
      parsedWeekdays = const <int>{};
    }

    return SyncedReminder(
      id: json['id'] as String? ?? '',
      time: DateTime.parse(json['time'] as String),
      description: json['description'] as String? ?? 'Nhắc nhở đồng bộ',
      weekdays: parsedWeekdays,
      isActive: json['isActive'] as bool? ?? true,
      targetIsActive: json['targetIsActive'] as bool?,
      status: json['status'] as String? ?? 'scheduled',
      requesterId: json['requesterId'] as String? ?? '',
      partnerId: json['partnerId'] as String? ?? '',
      stopperIds: stopperIdsRaw is List
          ? stopperIdsRaw.map((e) => e as String).toSet()
          : const <String>{},
    );
  }
}
