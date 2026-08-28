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
  group('ReminderRepository.loadAll', () {
    test('returns empty list when the body is null', () async {
      final repository = ReminderRepository(
        api: _apiReturning(null),
        realtime: _FakeRealtimeCoordinator(),
        backendUserIdStore: BackendUserIdStore(),
      );

      expect(await repository.loadAll(), isEmpty);
    });

    test('parses a list of alarm rows from the raw response body', () async {
      final row = {
        'id': 'alarm-1',
        'time': '2026-07-30T06:00:00.000Z',
        'description': 'Thức dậy',
        'weekdays': ['1', '2', '3'],
        'isActive': true,
        'status': 'scheduled',
        'requesterId': 'user-1',
        'partnerId': 'user-2',
        'stopperIds': <String>[],
      };
      final repository = ReminderRepository(
        api: _apiReturning([row]),
        realtime: _FakeRealtimeCoordinator(),
        backendUserIdStore: BackendUserIdStore(),
      );

      final list = await repository.loadAll();
      expect(list.length, 1);
      expect(list.first.id, 'alarm-1');
      expect(list.first.description, 'Thức dậy');
      expect(list.first.weekdays, {1, 2, 3});
    });
  });

  group('ReminderRepository actions', () {
    test('createReminder emits setAlarm with time, description, and weekdays', () async {
      final realtime = _FakeRealtimeCoordinator();
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'u1'});
      final repository = ReminderRepository(
        api: _apiReturning(null),
        realtime: realtime,
        backendUserIdStore: store,
      );

      final target = DateTime.parse('2026-07-30T06:30:00.000Z');
      await repository.createReminder(
        time: target,
        description: 'Uống thuốc',
        weekdays: {1, 2},
      );

      expect(realtime.emitted.length, 1);
      expect(realtime.emitted.first.key, ReminderWireEvents.setAlarm);
      final payload = realtime.emitted.first.value as Map<String, Object?>;
      expect(payload['time'], target.toIso8601String());
      expect(payload['description'], 'Uống thuốc');
      expect(payload['weekdays'], ['1', '2']);
      expect(payload['userId'], 'u1');
    });

    test('toggleReminder emits toggleAlarm with target state', () async {
      final realtime = _FakeRealtimeCoordinator();
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'u1'});
      final repository = ReminderRepository(
        api: _apiReturning(null),
        realtime: realtime,
        backendUserIdStore: store,
      );

      await repository.toggleReminder(id: 'alarm-1', isActive: false);

      expect(realtime.emitted.length, 1);
      expect(realtime.emitted.first.key, ReminderWireEvents.toggleAlarm);
      final payload = realtime.emitted.first.value as Map<String, Object?>;
      expect(payload['alarmId'], 'alarm-1');
      expect(payload['isActive'], false);
      expect(payload['userId'], 'u1');
    });

    test('deleteReminder emits deleteAlarm', () async {
      final realtime = _FakeRealtimeCoordinator();
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'u1'});
      final repository = ReminderRepository(
        api: _apiReturning(null),
        realtime: realtime,
        backendUserIdStore: store,
      );

      await repository.deleteReminder('alarm-1');

      expect(realtime.emitted.length, 1);
      expect(realtime.emitted.first.key, ReminderWireEvents.deleteAlarm);
      final payload = realtime.emitted.first.value as Map<String, Object?>;
      expect(payload['alarmId'], 'alarm-1');
      expect(payload['userId'], 'u1');
    });

    test('confirm and reject emit respective wire events', () async {
      final realtime = _FakeRealtimeCoordinator();
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'u1'});
      final repository = ReminderRepository(
        api: _apiReturning(null),
        realtime: realtime,
        backendUserIdStore: store,
      );

      await repository.confirm('alarm-1');
      await repository.reject('alarm-1');

      expect(realtime.emitted.length, 2);
      expect(realtime.emitted[0].key, ReminderWireEvents.confirmAlarm);
      expect(realtime.emitted[1].key, ReminderWireEvents.rejectAlarm);
    });
  });
}
