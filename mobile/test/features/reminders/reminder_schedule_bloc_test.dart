import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_local_prefs.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_repository.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_wire_events.dart';
import 'package:cupid_mobile/features/reminders/domain/reminder_stage.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_schedule_bloc.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_schedule_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _QueueHttpClientAdapter implements HttpClientAdapter {
  _QueueHttpClientAdapter(this._bodies);

  final List<Object?> _bodies;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = _bodies.length > 1 ? _bodies.removeAt(0) : _bodies.first;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

CupidApi _apiReturningInOrder(List<Object?> bodies) {
  final dio = Dio()..httpClientAdapter = _QueueHttpClientAdapter(bodies);
  return CupidApi(dio: dio, interceptors: const []);
}

class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  final emitted = <MapEntry<String, Object?>>[];
  final _events = StreamController<RealtimeEvent>.broadcast();
  Object? emitError;

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    final stream = _events.stream;
    return names == null
        ? stream
        : stream.where((e) => names.contains(e.name));
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

  void fire(String name) {
    _events.add(
      GenericRealtimeEvent(
        name: name,
        id: null,
        data: const {},
        transport: RealtimeTransport.socket,
        receivedAt: DateTime.now(),
      ),
    );
  }
}

Map<String, Object?> _row({String status = 'pending_confirmation', String id = 'alarm-1'}) => {
  'id': id,
  'time': '2026-07-30T06:00:00.000Z',
  'description': 'Thức dậy',
  'weekdays': ['1', '2', '3', '4', '5'],
  'isActive': true,
  'status': status,
  'requesterId': 'user-requester',
  'partnerId': 'user-partner',
  'stopperIds': <String>[],
};

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ReminderScheduleBloc hydration', () {
    test('started loads all reminders and computes stage', () async {
      final repository = ReminderRepository(
        api: _apiReturningInOrder([
          [_row(status: 'scheduled')],
        ]),
        realtime: _FakeRealtimeCoordinator(),
        backendUserIdStore: BackendUserIdStore()
          ..updateFromLoginResponse({'id': 'user-partner'}),
      );

      final bloc = ReminderScheduleBloc(
        repository: repository,
        localPrefs: ReminderLocalPrefs(),
        backendUserIdStore: BackendUserIdStore()
          ..updateFromLoginResponse({'id': 'user-partner'}),
      );

      bloc.add(const ReminderScheduleStarted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ReminderScheduleState>().having((s) => s.isLoading, 'isLoading', true),
          isA<ReminderScheduleState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.reminders.length, 'reminders.length', 1)
              .having((s) => s.stage, 'stage', ReminderStage.bothConfirmed),
        ]),
      );

      await bloc.close();
    });
  });

  group('ReminderScheduleBloc multi-alarm actions', () {
    test('create, update, toggle, delete, and confirm dispatch to repository', () async {
      final realtime = _FakeRealtimeCoordinator();
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final repository = ReminderRepository(
        api: _apiReturningInOrder([
          [_row()],
        ]),
        realtime: realtime,
        backendUserIdStore: store,
      );

      final bloc = ReminderScheduleBloc(
        repository: repository,
        localPrefs: ReminderLocalPrefs(),
        backendUserIdStore: store,
      );

      // Create
      bloc.add(
        ReminderScheduleCreated(
          time: DateTime.parse('2026-07-30T07:00:00.000Z'),
          description: 'Uống thuốc',
          weekdays: {1, 2},
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(realtime.emitted.last.key, ReminderWireEvents.setAlarm);

      // Toggle
      bloc.add(
        const ReminderScheduleToggleRequested(id: 'alarm-1', isActive: false),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(realtime.emitted.last.key, ReminderWireEvents.toggleAlarm);

      // Delete
      bloc.add(
        const ReminderScheduleDeleteRequested('alarm-1'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(realtime.emitted.last.key, ReminderWireEvents.deleteAlarm);

      // Confirm
      bloc.add(
        const ReminderScheduleConfirmRequested('alarm-1'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(realtime.emitted.last.key, ReminderWireEvents.confirmAlarm);

      await bloc.close();
    });
  });
}
