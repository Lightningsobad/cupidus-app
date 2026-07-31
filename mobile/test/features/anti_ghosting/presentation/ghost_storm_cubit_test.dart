import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_models.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_repository.dart';
import 'package:cupid_mobile/features/anti_ghosting/presentation/ghost_storm_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-written fake transport (no `mocktail`/`bloc_test`, neither is a
/// dependency), mirroring `anti_ghost_cubit_test.dart`'s fake.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<_QueuedResponse Function(RequestOptions)> _queue = [];

  void queueJson(Object? body, {int statusCode = 200}) {
    _queue.add((_) => _QueuedResponse(jsonEncode(body), statusCode));
  }

  void queueStatus(int statusCode) {
    _queue.add((_) => _QueuedResponse('', statusCode, asJson: false));
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final queued = _queue.isNotEmpty
        ? _queue.removeAt(0)(options)
        : const _QueuedResponse('{"eligible":false,"penalty":null}', 200);
    if (queued.statusCode >= 400) {
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: queued.statusCode,
          data: queued.asJson ? jsonDecode(queued.body) : queued.body,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return ResponseBody.fromString(
      queued.body,
      queued.statusCode,
      headers: queued.asJson
          ? {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            }
          : {},
    );
  }

  @override
  void close({bool force = false}) {}
}

class _QueuedResponse {
  const _QueuedResponse(this.body, this.statusCode, {this.asJson = true});

  final String body;
  final int statusCode;
  final bool asJson;
}

/// Fake `Timer` implementing the real interface (mirrors
/// `core/realtime/realtime_coordinator_test.dart`'s `_FakeGraceTimer`), so
/// the cubit test drives ticks deterministically instead of waiting 60s.
class _FakePollTimer implements Timer {
  _FakePollTimer(this._onTick);

  final void Function() _onTick;
  bool _cancelled = false;

  void fire() {
    if (!_cancelled) _onTick();
  }

  @override
  void cancel() => _cancelled = true;

  @override
  bool get isActive => !_cancelled;

  @override
  int get tick => 0;
}

class _FakePollTimerFactory {
  final List<_FakePollTimer> createdTimers = [];
  Duration? lastDuration;
  int callCount = 0;

  Timer call(Duration duration, void Function() onTick) {
    callCount++;
    lastDuration = duration;
    final timer = _FakePollTimer(onTick);
    createdTimers.add(timer);
    return timer;
  }

  _FakePollTimer get lastTimer => createdTimers.last;
}

void main() {
  late _FakeHttpClientAdapter adapter;
  late GhostConfigRepository repository;
  late _FakePollTimerFactory timerFactory;

  setUp(() {
    adapter = _FakeHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = adapter
      ..interceptors.add(const CupidErrorInterceptor());
    repository = GhostConfigRepository(api: CupidApi(dio: dio, interceptors: const []));
    timerFactory = _FakePollTimerFactory();
  });

  GhostStormCubit buildCubit({String partnerId = 'partner-1'}) {
    return GhostStormCubit(
      repository: repository,
      partnerId: partnerId,
      timerFactory: timerFactory.call,
    );
  }

  // A single zero-delay Future only flushes one macrotask turn; Dio's
  // interceptor chain needs several, so loop a handful of zero-delay turns.
  Future<void> pumpMicrotasks() async {
    for (var i = 0; i < 100; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('GhostStormCubit construction', () {
    test('fetches storm status on start', () async {
      adapter.queueJson({'eligible': true, 'penalty': 'emoji_storm'});
      final cubit = buildCubit();

      await pumpMicrotasks();

      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.path, '/ghost-config/storm-status/partner-1');
      final state = cubit.state as GhostStormLoaded;
      expect(state.status.eligible, isTrue);
      await cubit.close();
    });

    test('starts the 60s poll timer on construction', () async {
      adapter.queueJson({'eligible': false, 'penalty': null});
      final cubit = buildCubit();
      await pumpMicrotasks();

      expect(timerFactory.callCount, 1);
      expect(timerFactory.lastDuration, const Duration(seconds: 60));
      await cubit.close();
    });

    test('a fetch failure emits GhostStormLoadFailed', () async {
      adapter.queueStatus(500);
      final cubit = buildCubit();

      await pumpMicrotasks();

      expect(cubit.state, isA<GhostStormLoadFailed>());
      await cubit.close();
    });
  });

  group('GhostStormCubit.refresh', () {
    test('an external refresh() call re-fetches (host-screen focus trigger)', () async {
      adapter.queueJson({'eligible': false, 'penalty': null});
      final cubit = buildCubit();
      await pumpMicrotasks();

      adapter.queueJson({'eligible': true, 'penalty': 'noise'});
      await cubit.refresh();
      await pumpMicrotasks();

      expect(adapter.requests, hasLength(2));
      final state = cubit.state as GhostStormLoaded;
      expect(state.status.eligible, isTrue);
      expect(state.status.penalty, Penalty.noise);
      await cubit.close();
    });
  });

  group('GhostStormCubit poll timer lifecycle (ADR-2)', () {
    test('a timer tick triggers another fetch', () async {
      adapter.queueJson({'eligible': false, 'penalty': null});
      final cubit = buildCubit();
      await pumpMicrotasks();

      adapter.queueJson({'eligible': true, 'penalty': 'emoji_storm'});
      timerFactory.lastTimer.fire();
      await pumpMicrotasks();

      expect(adapter.requests, hasLength(2));
      final state = cubit.state as GhostStormLoaded;
      expect(state.status.eligible, isTrue);
      await cubit.close();
    });

    test('backgrounding cancels the timer', () async {
      adapter.queueJson({'eligible': false, 'penalty': null});
      final cubit = buildCubit();
      await pumpMicrotasks();

      expect(timerFactory.lastTimer.isActive, isTrue);
      cubit.handleAppLifecycleState(AppLifecycleState.paused);

      expect(timerFactory.lastTimer.isActive, isFalse);
      await cubit.close();
    });

    test('no polling happens while backgrounded: a cancelled timer firing is a no-op', () async {
      adapter.queueJson({'eligible': false, 'penalty': null});
      final cubit = buildCubit();
      await pumpMicrotasks();

      final backgroundedTimer = timerFactory.lastTimer;
      cubit.handleAppLifecycleState(AppLifecycleState.paused);
      backgroundedTimer.fire();
      await pumpMicrotasks();

      expect(adapter.requests, hasLength(1));
      await cubit.close();
    });

    test('resuming refetches and restarts the timer', () async {
      adapter.queueJson({'eligible': false, 'penalty': null});
      final cubit = buildCubit();
      await pumpMicrotasks();
      cubit.handleAppLifecycleState(AppLifecycleState.paused);
      final callsBeforeResume = timerFactory.callCount;

      adapter.queueJson({'eligible': true, 'penalty': 'emoji_storm'});
      cubit.handleAppLifecycleState(AppLifecycleState.resumed);
      await pumpMicrotasks();

      expect(timerFactory.callCount, callsBeforeResume + 1);
      expect(timerFactory.lastTimer.isActive, isTrue);
      final state = cubit.state as GhostStormLoaded;
      expect(state.status.eligible, isTrue);
      await cubit.close();
    });

    test('close() cancels the timer', () async {
      adapter.queueJson({'eligible': false, 'penalty': null});
      final cubit = buildCubit();
      await pumpMicrotasks();

      final timer = timerFactory.lastTimer;
      expect(timer.isActive, isTrue);
      await cubit.close();

      expect(timer.isActive, isFalse);
    });
  });
}
