import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RealtimeEvent classification (ADR-012d)', () {
    test('a durable event (server uuid present) classifies as durable', () {
      final event = GenericRealtimeEvent(
        name: 'newMessage',
        id: 'a1b2c3d4-0000-0000-0000-000000000000',
        data: const {'content': 'hey', 'senderId': 'user-1'},
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.utc(2026, 7, 30),
      );

      expect(event.isDurable, isTrue);
      expect(event.isEphemeral, isFalse);
    });

    test('an ephemeral event (no server id) classifies as ephemeral', () {
      final event = GenericRealtimeEvent(
        name: 'ghostTyping',
        id: null,
        data: const {'content': 'he', 'senderId': 'user-1'},
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.utc(2026, 7, 30),
      );

      expect(event.isDurable, isFalse);
      expect(event.isEphemeral, isTrue);
    });
  });

  group('RealtimeEvent payload parsing', () {
    test('preserves the exact frozen event name and raw payload fields for '
        'a durable event', () {
      final receivedAt = DateTime.utc(2026, 7, 30, 12);
      final event = GenericRealtimeEvent(
        name: 'newAlarm',
        id: 'e5f6a7b8-1111-1111-1111-111111111111',
        data: const {'title': 'Wake up', 'time': '07:00'},
        transport: RealtimeTransport.fcmBackgroundReplay,
        receivedAt: receivedAt,
      );

      expect(event.name, 'newAlarm');
      expect(event.id, 'e5f6a7b8-1111-1111-1111-111111111111');
      expect(event.data, {'title': 'Wake up', 'time': '07:00'});
      expect(event.transport, RealtimeTransport.fcmBackgroundReplay);
      expect(event.receivedAt, receivedAt);
    });

    test('preserves the exact frozen event name and raw payload fields for '
        'an ephemeral event', () {
      final receivedAt = DateTime.utc(2026, 7, 30, 12, 1);
      final event = GenericRealtimeEvent(
        name: 'messageSeen',
        id: null,
        data: const {'seenBy': 'user-2', 'readAt': '2026-07-30T12:01:00Z'},
        transport: RealtimeTransport.socket,
        receivedAt: receivedAt,
      );

      expect(event.name, 'messageSeen');
      expect(event.id, isNull);
      expect(
        event.data,
        {'seenBy': 'user-2', 'readAt': '2026-07-30T12:01:00Z'},
      );
      expect(event.transport, RealtimeTransport.socket);
      expect(event.receivedAt, receivedAt);
    });
  });
}
