import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_repository.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_wire_events.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake transport: intercepts `fetch` so `load()` never opens a real socket
/// (same low-level-fake-transport approach as
/// `test/core/realtime/realtime_coordinator_test.dart`'s `_FakeRealtimeSocket`).
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._body);

  final Object? _body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(_body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

CupidApi _apiReturning(Object? body) {
  final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter(body);
  return CupidApi(dio: dio, interceptors: const []);
}

class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  final emitted = <MapEntry<String, Object?>>[];
  final _events = StreamController<RealtimeEvent>.broadcast();
  Object? emitError;

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    final stream = _events.stream;
    return names == null ? stream : stream.where((e) => names.contains(e.name));
  }

  @override
  Stream<RealtimeStatus> get status => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> emit(String name, Object? payload) async {
    if (emitError != null) {
      throw emitError!;
    }
    emitted.add(MapEntry(name, payload));
  }

  @override
  Future<void> resync() async {}

  void fire(String name, {Map<String, dynamic> data = const {}}) {
    _events.add(
      GenericRealtimeEvent(
        name: name,
        id: null,
        data: data,
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.now(),
      ),
    );
  }
}

void main() {
  group('ReminderRepository.load', () {
    test('returns null when the body is null', () async {
      final repository = ReminderRepository(
        api: _apiReturning(null),
        realtime: _FakeRealtimeCoordinator(),
        backendUserIdStore: BackendUserIdStore(),
      );

      expect(await repository.load(), isNull);
    });

    test('parses the alarm row from the raw response body', () async {
      final repository = ReminderRepository(
        api: _apiReturning({
          'id': 'alarm-1',
          'time': '2026-07-30T06:00:00.000Z',
          'isActive': true,
          'status': 'scheduled',
          'requesterId': 'user-requester',
          'partnerId': 'user-partner',
          'stopperIds': <String>[],
        }),
        realtime: _FakeRealtimeCoordinator(),
        backendUserIdStore: BackendUserIdStore(),
      );

      final reminder = await repository.load();

      expect(reminder, isNotNull);
      expect(reminder!.id, 'alarm-1');
      expect(reminder.status, 'scheduled');
    });
  });

  group('ReminderRepository outbound emit', () {
    late _FakeRealtimeCoordinator realtime;
    late BackendUserIdStore backendUserIdStore;
    late ReminderRepository repository;

    setUp(() {
      realtime = _FakeRealtimeCoordinator();
      backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-1'});
      repository = ReminderRepository(
        api: _apiReturning(null),
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
      );
    });

    test('setTime emits setAlarm with an ISO-8601 time and backend userId', () async {
      final time = DateTime.utc(2026, 7, 30, 6);

      await repository.setTime(time);

      expect(realtime.emitted, hasLength(1));
      expect(realtime.emitted.single.key, ReminderWireEvents.setAlarm);
      expect(realtime.emitted.single.value, {
        'time': time.toIso8601String(),
        'userId': 'user-1',
      });
    });

    test('confirm emits confirmAlarm with alarmId and backend userId', () async {
      await repository.confirm('alarm-1');

      expect(realtime.emitted.single.key, ReminderWireEvents.confirmAlarm);
      expect(realtime.emitted.single.value, {
        'alarmId': 'alarm-1',
        'userId': 'user-1',
      });
    });

    test('dismiss emits stopAlarm with alarmId and backend userId', () async {
      await repository.dismiss('alarm-1');

      expect(realtime.emitted.single.key, ReminderWireEvents.stopAlarm);
      expect(realtime.emitted.single.value, {
        'alarmId': 'alarm-1',
        'userId': 'user-1',
      });
    });

    test('propagates RealtimeNotLiveFailure unchanged', () async {
      realtime.emitError = const RealtimeNotLiveFailure();

      await expectLater(
        repository.setTime(DateTime.utc(2026)),
        throwsA(isA<RealtimeNotLiveFailure>()),
      );
    });
  });

  group('ReminderRepository.events', () {
    test('filters the merged stream to the five inbound wire events', () async {
      final realtime = _FakeRealtimeCoordinator();
      final repository = ReminderRepository(
        api: _apiReturning(null),
        realtime: realtime,
        backendUserIdStore: BackendUserIdStore(),
      );

      final received = <String>[];
      final subscription = repository.events().listen(
        (event) => received.add(event.name),
      );

      realtime.fire(ReminderWireEvents.triggerAlarm);
      realtime.fire('rejectAlarm');
      realtime.fire(ReminderWireEvents.alarmFullyStopped);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(received, [
        ReminderWireEvents.triggerAlarm,
        ReminderWireEvents.alarmFullyStopped,
      ]);
    });
  });
}
