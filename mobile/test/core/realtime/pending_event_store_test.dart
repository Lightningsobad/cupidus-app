import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/core/realtime/pending_event_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

RealtimeEvent _durableEvent({
  String name = 'chat.messageCreated',
  required String id,
  DateTime? receivedAt,
}) =>
    GenericRealtimeEvent(
      name: name,
      id: id,
      data: const {'text': 'hi'},
      transport: RealtimeTransport.fcmBackgroundReplay,
      receivedAt: receivedAt ?? DateTime.utc(2026, 7, 30),
    );

RealtimeEvent _ephemeralEvent() => GenericRealtimeEvent(
      name: 'chat.ghostTyping',
      id: null,
      data: const {'senderId': 'u1'},
      transport: RealtimeTransport.fcmBackgroundReplay,
      receivedAt: DateTime.utc(2026, 7, 30),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('PendingEventStore persistence (ADR-012g.4)', () {
    test('a persisted queue survives a store re-instantiation', () async {
      final first = PendingEventStore();
      await first.append(_durableEvent(id: 'msg-1'));

      final second = PendingEventStore();
      final loaded = await second.loadAll();

      expect(loaded, hasLength(1));
      expect(loaded.single.name, 'chat.messageCreated');
      expect(loaded.single.id, 'msg-1');
      expect(loaded.single.data, {'text': 'hi'});
      expect(loaded.single.transport, RealtimeTransport.fcmBackgroundReplay);
    });

    test('the queue never exceeds its bound and evicts oldest-first',
        () async {
      final store = PendingEventStore(maxLength: 2);

      await store.append(_durableEvent(id: 'msg-1'));
      await store.append(_durableEvent(id: 'msg-2'));
      await store.append(_durableEvent(id: 'msg-3'));

      final loaded = await store.loadAll();

      expect(loaded, hasLength(2));
      expect(loaded.map((e) => e.id), ['msg-2', 'msg-3']);
    });

    test('an ephemeral event is never persisted', () async {
      final store = PendingEventStore();

      await store.append(_ephemeralEvent());

      expect(await store.loadAll(), isEmpty);
    });

    test('clearOnSignOut leaves the queue empty', () async {
      final store = PendingEventStore();
      await store.append(_durableEvent(id: 'msg-1'));

      await store.clearOnSignOut();

      expect(await store.loadAll(), isEmpty);
    });
  });
}
