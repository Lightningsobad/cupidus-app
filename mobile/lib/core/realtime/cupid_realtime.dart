/// The only public realtime surface (`architecture/solution.md` §2, §4
/// Boundaries And Ownership). Feature code must import this barrel only —
/// never `package:socket_io_client/...` or `package:firebase_messaging/...`
/// directly — and must filter by `names` / switch on `name`, never on
/// `transport` (§2 Feature-layer rule).
library;

import 'realtime_event.dart';
import 'realtime_failure.dart';

export 'realtime_event.dart';
export 'realtime_failure.dart';

/// Owns one Socket.IO connection plus the FCM handlers and exposes one
/// deduped, broadcast [RealtimeEvent] stream (`architecture/solution.md` §2,
/// ADR-012a/d/g). Contract owner: Tech Lead — do not rename any member
/// without a new architecture pass.
abstract interface class RealtimeCoordinator {
  /// Merged + deduped broadcast stream, optionally filtered by [names].
  Stream<RealtimeEvent> events({Set<String>? names});

  /// Connection status (ADR-012g transition machine).
  Stream<RealtimeStatus> get status;

  /// Idempotent: connects the socket, joins the room, and registers the
  /// FCM handlers.
  Future<void> start();

  /// Disconnects the socket and tears down the FCM handlers.
  Future<void> stop();

  /// Socket-only write path. Throws [RealtimeNotLiveFailure] when [status]
  /// is not [RealtimeStatus.live] (ADR-012h).
  Future<void> emit(String name, Object? payload);

  /// Manual gap-fill: a bounded page-1 REST refetch reconciled by id
  /// (ADR-012g.3, ADR-007).
  Future<void> resync();
}
