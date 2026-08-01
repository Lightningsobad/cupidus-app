/// Connection status for the merged realtime stream
/// (`architecture/solution.md` §2, ADR-012g transition machine).
enum RealtimeStatus { offline, connecting, live, degraded }

/// Diagnostics-only transport label (`architecture/solution.md` §2).
/// Feature code must never branch on this — filter by `names` and switch on
/// `name` instead (§2 Feature-layer rule).
enum RealtimeTransport { socket, fcmForeground, fcmBackgroundReplay }

/// A single realtime payload merged from the socket and FCM transports
/// (`architecture/solution.md` §2). `name` holds the exact frozen
/// `CHAT_EVENTS` / `ALARM_EVENTS` string; there is no local event enum to
/// keep in sync with the backend.
sealed class RealtimeEvent {
  const RealtimeEvent();

  /// The exact frozen `CHAT_EVENTS` / `ALARM_EVENTS` string.
  String get name;

  /// The server uuid (`Message.id`, `Alarm.id`), or `null` for an ephemeral
  /// event that never carries one.
  String? get id;

  /// The raw event payload.
  Map<String, dynamic> get data;

  RealtimeTransport get transport;

  DateTime get receivedAt;

  /// ADR-012d classification: durable when a server uuid ([id]) is present.
  /// Classified by id presence, not by an event-name allowlist, so a new
  /// backend event does not silently become undeduped-durable. Known
  /// ephemeral events today: `ghostTyping`, `ghostStopTyping`,
  /// `messageSeen`, `messageDelivered`, `emojiStormReceived`.
  bool get isDurable => id != null;

  /// The inverse of [isDurable] — never FCM-delivered, and dropped while
  /// the app is not in the foreground (ADR-012d/ADR-012g).
  bool get isEphemeral => !isDurable;
}

/// The single concrete [RealtimeEvent] implementation. P0 does not split
/// chat/alarm event subtypes; feature code discriminates by [name], never by
/// subtype (`architecture/solution.md` §2).
final class GenericRealtimeEvent extends RealtimeEvent {
  const GenericRealtimeEvent({
    required this.name,
    required this.id,
    required this.data,
    required this.transport,
    required this.receivedAt,
  });

  @override
  final String name;

  @override
  final String? id;

  @override
  final Map<String, dynamic> data;

  @override
  final RealtimeTransport transport;

  @override
  final DateTime receivedAt;
}
