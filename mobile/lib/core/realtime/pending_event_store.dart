import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../auth/cupid_session.dart';
import 'realtime_event.dart';

/// Bounded, append-only, oldest-first-eviction persisted queue for
/// FCM-background-delivered durable events (`architecture/solution.md`
/// ADR-012g.4, `master-plan.md` §3 pending-queue contract). Persisted entry
/// shape: `{name,id,payload,receivedAt}`.
///
/// This is a deliberate placeholder: F5/ADR-007 has not landed Drift yet, so
/// the queue lives in `SharedPreferences` for now and must be migrated to
/// Drift when F5 ships (ADR-012g.4).
class PendingEventStore implements SessionScopedStore {
  PendingEventStore({
    Future<SharedPreferences> Function()? preferences,
    this.maxLength = 200,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  static const _storageKey = 'cupid_realtime_pending_events_v1';

  final Future<SharedPreferences> Function() _preferences;

  /// Fixed maximum queue length (ADR-012g.4). Once exceeded, the oldest
  /// entry is evicted first so the queue cannot grow unbounded.
  final int maxLength;

  /// Appends a durable [event] to the queue, oldest-first-evicting once
  /// [maxLength] is exceeded. Ephemeral events
  /// (`RealtimeEvent.isEphemeral`) are never FCM-delivered (ADR-012d) and
  /// are rejected here as a defensive boundary check; callers must not
  /// route ephemeral events here in the first place.
  Future<void> append(RealtimeEvent event) async {
    if (event.isEphemeral) return;

    final prefs = await _preferences();
    final entries = prefs.getStringList(_storageKey)?.toList() ?? <String>[];
    entries.add(jsonEncode(_encode(event)));
    while (entries.length > maxLength) {
      entries.removeAt(0);
    }
    await prefs.setStringList(_storageKey, entries);
  }

  /// Loads the persisted queue, oldest first, reconstructed with
  /// [RealtimeTransport.fcmBackgroundReplay] — the only transport a
  /// persisted entry can have come from.
  Future<List<RealtimeEvent>> loadAll() async {
    final prefs = await _preferences();
    final entries = prefs.getStringList(_storageKey) ?? const <String>[];
    return entries
        .map((raw) => _decode(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  /// Drains all persisted events from the queue (returning them oldest-first)
  /// and atomically empties the persisted storage so they are not replayed again on future resumes.
  Future<List<RealtimeEvent>> drain() async {
    final prefs = await _preferences();
    final entries = prefs.getStringList(_storageKey) ?? const <String>[];
    if (entries.isNotEmpty) {
      await prefs.remove(_storageKey);
    }
    return entries
        .map((raw) => _decode(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  /// AC4-equivalent teardown: no queued event survives sign-out, so a
  /// second user on the same device never inherits the first user's queue.
  @override
  Future<void> clearOnSignOut() async {
    final prefs = await _preferences();
    await prefs.remove(_storageKey);
  }

  Map<String, dynamic> _encode(RealtimeEvent event) => {
        'name': event.name,
        'id': event.id,
        'payload': event.data,
        'receivedAt': event.receivedAt.toIso8601String(),
      };

  RealtimeEvent _decode(Map<String, dynamic> entry) => GenericRealtimeEvent(
        name: entry['name'] as String,
        id: entry['id'] as String?,
        data: Map<String, dynamic>.from(entry['payload'] as Map),
        transport: RealtimeTransport.fcmBackgroundReplay,
        receivedAt: DateTime.parse(entry['receivedAt'] as String),
      );
}
