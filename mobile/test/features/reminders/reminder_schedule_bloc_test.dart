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

/// Returns each body in [_bodies] in order, then repeats the last one --
/// lets a test simulate the server row changing between the initial
/// hydrate and a realtime-triggered re-hydrate (§4 D5).
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

/// Same low-level-fake-transport approach as
/// `test/features/reminders/reminder_repository_test.dart`.
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

Map<String, Object?> _row({String status = 'pending_confirmation'}) => {
  'id': 'alarm-1',
  'time': '2026-07-30T06:00:00.000Z',
  'isActive': true,
  'status': status,
  'requesterId': 'user-requester',
  'partnerId': 'user-partner',
  'stopperIds': <String>[],
};

ReminderScheduleBloc _bloc({
  required List<Object?> bodies,
  RealtimeCoordinator? realtime,
  BackendUserIdStore? backendUserIdStore,
  ReminderLocalPrefs? localPrefs,
}) {
  final store = backendUserIdStore ?? BackendUserIdStore();
  return ReminderScheduleBloc(
    repository: ReminderRepository(
      api: _apiReturningInOrder(bodies),
      realtime: realtime ?? _FakeRealtimeCoordinator(),
      backendUserIdStore: store,
    ),
    localPrefs: localPrefs ?? ReminderLocalPrefs(),
    backendUserIdStore: store,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ReminderScheduleBloc hydration', () {
    test('loads the reminder and derives the viewer stage', () async {
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final bloc = _bloc(
        bodies: [_row()],
        backendUserIdStore: backendUserIdStore,
      );
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>(
            (state) =>
                !state.isLoading &&
                state.reminder?.id == 'alarm-1' &&
                state.stage == ReminderStage.needsMyConfirmation,
          ),
        ),
      );

      bloc.add(const ReminderScheduleStarted());
      await expectation;
    });

    test('a null body is a valid empty-schedule state, not an error', () async {
      final bloc = _bloc(bodies: [null]);
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>(
            (state) =>
                !state.isLoading &&
                state.reminder == null &&
                state.stage == null &&
                state.failure == null,
          ),
        ),
      );

      bloc.add(const ReminderScheduleStarted());
      await expectation;
    });

    test('loads persisted weekdays and the pending timeout notice', () async {
      final localPrefs = ReminderLocalPrefs();
      await localPrefs.saveWeekdays({1, 3});
      await localPrefs.setPendingTimeoutNotice(true);
      final bloc = _bloc(bodies: [null], localPrefs: localPrefs);
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>(
            (state) =>
                !state.isLoading &&
                state.weekdays.containsAll({1, 3}) &&
                state.weekdays.length == 2 &&
                state.pendingTimeoutNotice,
          ),
        ),
      );

      bloc.add(const ReminderScheduleStarted());
      await expectation;
    });
  });

  group('ReminderScheduleBloc realtime refresh (§4 D5)', () {
    test('an inbound wire event re-hydrates from GET /alarms', () async {
      final realtime = _FakeRealtimeCoordinator();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final bloc = _bloc(
        bodies: [_row(), _row(status: 'scheduled')],
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
      );
      addTearDown(bloc.close);

      bloc.add(const ReminderScheduleStarted());
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>(
            (state) =>
                !state.isLoading &&
                state.stage == ReminderStage.needsMyConfirmation,
          ),
        ),
      );

      final refreshed = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>(
            (state) => !state.isLoading && state.stage == ReminderStage.bothConfirmed,
          ),
        ),
      );
      realtime.fire(ReminderWireEvents.alarmScheduled);
      await refreshed;
    });
  });

  group('ReminderScheduleBloc actions', () {
    test('confirmPressed calls repository.confirm with the loaded reminder id', () async {
      final realtime = _FakeRealtimeCoordinator();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-partner'});
      final bloc = _bloc(
        bodies: [_row()],
        realtime: realtime,
        backendUserIdStore: backendUserIdStore,
      );
      addTearDown(bloc.close);

      bloc.add(const ReminderScheduleStarted());
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>((state) => !state.isLoading),
        ),
      );

      final submitted = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>((state) => !state.isSubmitting),
        ),
      );
      bloc.add(const ReminderScheduleConfirmPressed());
      await submitted;

      expect(realtime.emitted.single.key, ReminderWireEvents.confirmAlarm);
      expect(realtime.emitted.single.value, {
        'alarmId': 'alarm-1',
        'userId': 'user-partner',
      });
    });

    test('confirmPressed is a no-op when no reminder is loaded yet', () async {
      final realtime = _FakeRealtimeCoordinator();
      final bloc = _bloc(bodies: [null], realtime: realtime);
      addTearDown(bloc.close);

      bloc.add(const ReminderScheduleStarted());
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>((state) => !state.isLoading),
        ),
      );

      bloc.add(const ReminderScheduleConfirmPressed());
      await Future<void>.delayed(Duration.zero);

      expect(realtime.emitted, isEmpty);
    });

    test(
      'timeSubmitted surfaces RealtimeNotLiveFailure inline without wiping the loaded reminder',
      () async {
        final realtime = _FakeRealtimeCoordinator();
        final backendUserIdStore = BackendUserIdStore()
          ..updateFromLoginResponse({'id': 'user-partner'});
        final bloc = _bloc(
          bodies: [_row()],
          realtime: realtime,
          backendUserIdStore: backendUserIdStore,
        );
        addTearDown(bloc.close);

        bloc.add(const ReminderScheduleStarted());
        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<ReminderScheduleState>((state) => !state.isLoading),
          ),
        );

        realtime.emitError = const RealtimeNotLiveFailure();
        final failed = expectLater(
          bloc.stream,
          emitsThrough(
            predicate<ReminderScheduleState>(
              (state) =>
                  !state.isSubmitting &&
                  state.failure is RealtimeNotLiveFailure &&
                  state.reminder?.id == 'alarm-1',
            ),
          ),
        );
        bloc.add(ReminderScheduleTimeSubmitted(DateTime.utc(2026, 7, 31, 6, 30)));
        await failed;
      },
    );

    test('weekdaysChanged persists the selection and updates state', () async {
      final localPrefs = ReminderLocalPrefs();
      final bloc = _bloc(bodies: [null], localPrefs: localPrefs);
      addTearDown(bloc.close);

      final changed = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>(
            (state) =>
                state.weekdays.containsAll({1, 2, 3}) &&
                state.weekdays.length == 3,
          ),
        ),
      );
      bloc.add(const ReminderScheduleWeekdaysChanged({1, 2, 3}));
      await changed;

      expect(await localPrefs.loadWeekdays(), {1, 2, 3});
    });

    test('timeoutNoticeAcknowledged clears the persisted flag', () async {
      final localPrefs = ReminderLocalPrefs();
      await localPrefs.setPendingTimeoutNotice(true);
      final bloc = _bloc(bodies: [null], localPrefs: localPrefs);
      addTearDown(bloc.close);

      final acknowledged = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ReminderScheduleState>((state) => !state.pendingTimeoutNotice),
        ),
      );
      bloc.add(const ReminderScheduleTimeoutNoticeAcknowledged());
      await acknowledged;

      expect(await localPrefs.loadPendingTimeoutNotice(), isFalse);
    });
  });
}
