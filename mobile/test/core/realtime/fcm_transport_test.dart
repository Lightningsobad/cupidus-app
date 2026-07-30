import 'dart:async';
import 'dart:convert';

import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/core/realtime/fcm_transport.dart';
import 'package:cupid_mobile/core/realtime/pending_event_store.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('parseFcmDataMap (ADR-012f)', () {
    test(
        'a well-formed payload parses into a RealtimeEvent whose name/id '
        'match and whose transport reflects the FCM leg', () {
      final receivedAt = DateTime.utc(2026, 7, 30);

      final event = parseFcmDataMap(
        {
          'cupid_event': 'chat.messageCreated',
          'cupid_event_id': 'msg-1',
          'cupid_payload': jsonEncode({'text': 'hi'}),
        },
        transport: RealtimeTransport.fcmForeground,
        receivedAt: receivedAt,
      );

      expect(event, isNotNull);
      expect(event!.name, 'chat.messageCreated');
      expect(event.id, 'msg-1');
      expect(event.data, {'text': 'hi'});
      expect(event.transport, RealtimeTransport.fcmForeground);
      expect(event.receivedAt, receivedAt);
      expect(event.isDurable, isTrue);
    });

    test(
        'a payload missing cupid_event is rejected without throwing, and '
        'nothing is persisted', () {
      final logged = <String>[];

      final event = parseFcmDataMap(
        {'cupid_event_id': 'msg-1', 'cupid_payload': '{"secret":"leak"}'},
        transport: RealtimeTransport.fcmForeground,
        receivedAt: DateTime.utc(2026, 7, 30),
        log: logged.add,
      );

      expect(event, isNull);
      expect(logged, hasLength(1));
      // AC: no log line contains payload contents.
      expect(logged.single.contains('secret'), isFalse);
      expect(logged.single.contains('leak'), isFalse);
    });

    test('an event with no cupid_event_id is treated as ephemeral', () {
      final event = parseFcmDataMap(
        {'cupid_event': 'chat.ghostTyping'},
        transport: RealtimeTransport.fcmForeground,
        receivedAt: DateTime.utc(2026, 7, 30),
      );

      expect(event, isNotNull);
      expect(event!.id, isNull);
      expect(event.isEphemeral, isTrue);
    });
  });

  group('FcmTransport foreground handling', () {
    test('a valid message is emitted on foregroundEvents', () async {
      final controller = StreamController<RemoteMessage>();
      final transport = FcmTransport(
        messageStreamFactory: () => controller.stream,
        registerBackgroundHandler: (_) {},
      );

      final events = <RealtimeEvent>[];
      final subscription = transport.foregroundEvents.listen(events.add);

      transport.start();
      controller.add(
        RemoteMessage(
          data: {
            'cupid_event': 'chat.messageCreated',
            'cupid_event_id': 'msg-1',
            'cupid_payload': jsonEncode({'text': 'hi'}),
          },
        ),
      );
      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.single.name, 'chat.messageCreated');
      expect(events.single.transport, RealtimeTransport.fcmForeground);

      await subscription.cancel();
      await transport.stop();
      await controller.close();
    });

    test('a message missing cupid_event never reaches foregroundEvents',
        () async {
      final controller = StreamController<RemoteMessage>();
      final transport = FcmTransport(
        messageStreamFactory: () => controller.stream,
        registerBackgroundHandler: (_) {},
      );

      final events = <RealtimeEvent>[];
      final subscription = transport.foregroundEvents.listen(events.add);

      transport.start();
      controller.add(RemoteMessage(data: {'cupid_payload': '{}'}));
      await pumpEventQueue();

      expect(events, isEmpty);

      await subscription.cancel();
      await transport.stop();
      await controller.close();
    });

    test('start() registers the top-level background handler', () {
      BackgroundMessageHandler? captured;
      final transport = FcmTransport(
        messageStreamFactory: () => const Stream<RemoteMessage>.empty(),
        registerBackgroundHandler: (handler) => captured = handler,
      );

      transport.start();

      expect(identical(captured, fcmBackgroundMessageHandler), isTrue);
    });
  });

  group('fcmBackgroundMessageHandler (ADR-012g.4)', () {
    test('a durable message is present in the queue after persistence',
        () async {
      await fcmBackgroundMessageHandler(
        RemoteMessage(
          data: {
            'cupid_event': 'alarm.triggered',
            'cupid_event_id': 'alarm-1',
            'cupid_payload': jsonEncode({'label': 'wake up'}),
          },
        ),
      );

      final queued = await PendingEventStore().loadAll();

      expect(queued, hasLength(1));
      expect(queued.single.id, 'alarm-1');
      expect(queued.single.transport, RealtimeTransport.fcmBackgroundReplay);
    });

    test('an ephemeral message (no cupid_event_id) is not persisted',
        () async {
      await fcmBackgroundMessageHandler(
        RemoteMessage(data: {'cupid_event': 'chat.ghostTyping'}),
      );

      expect(await PendingEventStore().loadAll(), isEmpty);
    });

    test('a message missing cupid_event does not throw and persists nothing',
        () async {
      await fcmBackgroundMessageHandler(
        RemoteMessage(data: {'cupid_payload': '{}'}),
      );

      expect(await PendingEventStore().loadAll(), isEmpty);
    });
  });
}
