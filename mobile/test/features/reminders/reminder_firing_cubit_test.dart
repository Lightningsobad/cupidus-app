import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_local_prefs.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_repository.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_wire_events.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_firing_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Same low-level-fake-transport approach as
/// `test/features/reminders/reminder_schedule_bloc_test.dart`.
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

/// Records the timer seam so tests can trigger expiry synchronously instead
/// of waiting the real 5-minute D4 timeout.
class _TimerRecorder {
  void Function()? lastCallback;

  Timer create(Duration duration, void Function() callback) {
    lastCallback = callback;
    return _NoopTimer();
  }
}

class _NoopTimer implements Timer {
  @override
  void cancel() {}

  @override
  bool get isActive => true;

  @override
  int get tick => 0;
}

Map<String, Object?> _row({
  String status = 'ringing',
  List<String> stopperIds = const [],
}) => {
  'id': 'alarm-1',
  'time': '2026-07-30T06:00:00.000Z',
  'isActive': true,
  'status': status,
  'requesterId': 'user-requester',
  'partnerId': 'user-partner',
  'stopperIds': stopperIds,
};

ReminderFiringCubit _cubit({
  required List<Object?> bodies,
  required _FakeRealtimeCoordinator realtime,
  required BackendUserIdStore backendUserIdStore,
  ReminderLocalPrefs? localPrefs,
  Timer Function(Duration, void Function())? createTimer,
}) {
  return ReminderFiringCubit(
    repository: ReminderRepository(
      api: _apiReturningInOrder(bodies),
      realtime: realtime,
      backendUserIdStore: backendUserIdStore,
    ),
    localPrefs: localPrefs ?? ReminderLocalPrefs(),
    backendUserIdStore: backendUserIdStore,
    createTimer: createTimer ?? _TimerRecorder().create,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ReminderFiringCubit open (D5)', () {
    test(
      'opens on triggerAlarm and re-derives partner-dismissed from GET /alarms stopperIds',
      () async {
        final realtime = _FakeRealtimeCoordinator();
        final backendUserIdStore = BackendUserIdStore()
          ..updateFromLoginResponse({'id': 'user-partner'});
        final cubit = _cubit(
          bodies: [
            _row(stopperIds: ['user-requester']),
          ],
          realtime: realtime,
          backendUserIdStore: backendUserIdStore,
        );
        addTearDown(cubit.close);

        final opened = expectLater(
          cubit.stream,
          emitsThrough(
            predicate<ReminderFiringState>(
              (state) =>
                  state is ReminderFiringOpen &&
                  state.reminder.id == 'alarm-1' &&
                  state.partnerDismissed &&
                  !state.viewerDismissed,
            ),
          ),
        );

        // The live triggerAlarm payload carries no stopperIds yet -- only
        // the D5 REST refresh below should surface `user-requester`'s
        // dismissal.
        realtime.fire(ReminderWireEvents.triggerAlarm, data: _row());
        await opened;
      },
    );

    test('ignores unrelated inbound events (newAlarmRequest, alarmScheduled)', () async {
      final realtime = _FakeRealtimeCoordinator();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final cubit = _cubit(
        bodies: [_row()],
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
      );
      addTearDown(cubit.close);

      realtime.fire(ReminderWireEvents.alarmScheduled, data: _row(status: 'scheduled'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<ReminderFiringClosed>());
    });
  });

  group('ReminderFiringCubit dismiss', () {
    test('dismiss emits exactly one stopAlarm and marks the viewer dismissed', () async {
      final realtime = _FakeRealtimeCoordinator();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final cubit = _cubit(
        bodies: [_row()],
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
      );
      addTearDown(cubit.close);

      realtime.fire(ReminderWireEvents.triggerAlarm, data: _row());
      await cubit.stream.firstWhere((s) => s is ReminderFiringOpen);

      final dismissed = expectLater(
        cubit.stream,
        emitsThrough(
          predicate<ReminderFiringState>(
            (state) => state is ReminderFiringOpen && state.viewerDismissed,
          ),
        ),
      );
      await cubit.dismiss();
      await dismissed;

      expect(realtime.emitted.single.key, ReminderWireEvents.stopAlarm);
      expect(realtime.emitted.single.value, {
        'alarmId': 'alarm-1',
        'userId': 'user-partner',
      });
    });

    test('a second dismiss call is a no-op (exactly one stopAlarm total)', () async {
      final realtime = _FakeRealtimeCoordinator();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final cubit = _cubit(
        bodies: [_row()],
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
      );
      addTearDown(cubit.close);

      realtime.fire(ReminderWireEvents.triggerAlarm, data: _row());
      await cubit.stream.firstWhere((s) => s is ReminderFiringOpen);

      await cubit.dismiss();
      await cubit.dismiss();

      expect(realtime.emitted.length, 1);
    });
  });

  group('ReminderFiringCubit D4 client-side timeout', () {
    test('timeout expiry clears the overlay with zero outbound emits and sets the pending notice', () async {
      final realtime = _FakeRealtimeCoordinator();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final localPrefs = ReminderLocalPrefs();
      final recorder = _TimerRecorder();
      final cubit = _cubit(
        bodies: [_row()],
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
        localPrefs: localPrefs,
        createTimer: recorder.create,
      );
      addTearDown(cubit.close);

      realtime.fire(ReminderWireEvents.triggerAlarm, data: _row());
      await cubit.stream.firstWhere((s) => s is ReminderFiringOpen);
      expect(recorder.lastCallback, isNotNull);

      final closed = expectLater(
        cubit.stream,
        emitsThrough(isA<ReminderFiringClosed>()),
      );
      recorder.lastCallback!();
      await closed;

      expect(realtime.emitted, isEmpty);
      expect(await localPrefs.loadPendingTimeoutNotice(), isTrue);
    });
  });

  group('ReminderFiringCubit alarmFullyStopped', () {
    test('closes the overlay for the viewer', () async {
      final realtime = _FakeRealtimeCoordinator();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final cubit = _cubit(
        bodies: [_row()],
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
      );
      addTearDown(cubit.close);

      realtime.fire(ReminderWireEvents.triggerAlarm, data: _row());
      await cubit.stream.firstWhere((s) => s is ReminderFiringOpen);

      final closed = expectLater(
        cubit.stream,
        emitsThrough(isA<ReminderFiringClosed>()),
      );
      realtime.fire(ReminderWireEvents.alarmFullyStopped, data: _row(status: 'stopped'));
      await closed;
    });
  });

  group('ReminderFiringCubit foreground refresh (D5)', () {
    test('refreshFromForeground re-derives partner dismissal from stopperIds', () async {
      final realtime = _FakeRealtimeCoordinator();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final cubit = _cubit(
        bodies: [
          _row(),
          _row(stopperIds: ['user-requester']),
        ],
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
      );
      addTearDown(cubit.close);

      realtime.fire(ReminderWireEvents.triggerAlarm, data: _row());
      await cubit.stream.firstWhere(
        (s) => s is ReminderFiringOpen && !s.partnerDismissed,
      );

      final refreshed = expectLater(
        cubit.stream,
        emitsThrough(
          predicate<ReminderFiringState>(
            (state) => state is ReminderFiringOpen && state.partnerDismissed,
          ),
        ),
      );
      await cubit.refreshFromForeground();
      await refreshed;
    });

    test('refreshFromForeground is a no-op while closed', () async {
      final realtime = _FakeRealtimeCoordinator();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final cubit = _cubit(
        bodies: [_row()],
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
      );
      addTearDown(cubit.close);

      await cubit.refreshFromForeground();

      expect(cubit.state, isA<ReminderFiringClosed>());
    });
  });

  group('ReminderFiringCubit timeout-notice toast support', () {
    test('consumePendingTimeoutNotice reads and clears the flag', () async {
      final localPrefs = ReminderLocalPrefs();
      await localPrefs.setPendingTimeoutNotice(true);
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final cubit = _cubit(
        bodies: [null],
        realtime: _FakeRealtimeCoordinator(),
        backendUserIdStore: backendUserIdStore,
        localPrefs: localPrefs,
      );
      addTearDown(cubit.close);

      expect(await cubit.consumePendingTimeoutNotice(), isTrue);
      expect(await localPrefs.loadPendingTimeoutNotice(), isFalse);
      expect(await cubit.consumePendingTimeoutNotice(), isFalse);
    });
  });
}
