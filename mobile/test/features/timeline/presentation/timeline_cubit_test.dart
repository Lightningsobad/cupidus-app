import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/app_database.dart' as db;
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart'
    hide TimelineOfflineNoCache;
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_state.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stubs the transport layer beneath [CupidApiClient.create]'s shared [Dio]
/// so the cubit is exercised against a real [TimelineRepository] and a real
/// in-memory Drift database (matching the P3 repository test approach), with
/// no live network call and no extra test-only package.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);
}

ResponseBody _jsonResponse(Object? body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

TimelineRemoteDataSource _remoteWithHandler(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = _FakeHttpClientAdapter(handler);
  return TimelineRemoteDataSource(api);
}

TimelineRemoteDataSource _remoteAlwaysFailing(
  DioExceptionType type, {
  int? statusCode,
}) {
  return _remoteWithHandler((options) async {
    throw DioException(
      requestOptions: options,
      type: type,
      response: statusCode != null
          ? Response(requestOptions: options, statusCode: statusCode)
          : null,
    );
  });
}

Map<String, Object?> _wireEntry({
  required String id,
  required String title,
  required String createdAt,
  String type = 'memory',
}) => {'id': id, 'type': type, 'title': title, 'createdAt': createdAt};

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('emits loading before the first stream/refresh settles', () async {
    final repository = TimelineRepository(
      database,
      _remoteWithHandler((options) async => _jsonResponse([], 200)),
    );
    final cubit = TimelineCubit(repository);
    addTearDown(cubit.close);

    expect(cubit.state, isA<TimelineLoading>());
  });

  test(
    'cache-then-refresh: cached rows show first, then a fresh sync replaces '
    'them',
    () async {
      await database.replaceFirstPage([
        db.TimelineEntry(
          id: 'ev-cached',
          type: 'memory',
          title: 'Cached',
          description: null,
          photoUrl: null,
          icon: null,
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ]);
      final repository = TimelineRepository(
        database,
        _remoteWithHandler(
          (options) async => _jsonResponse([
            _wireEntry(
              id: 'ev-fresh',
              title: 'Fresh',
              createdAt: '2026-05-14T00:00:00.000Z',
            ),
          ], 200),
        ),
      );
      final cubit = TimelineCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await pumpEventQueue();

      final state = cubit.state;
      expect(state, isA<TimelineReady>());
      expect((state as TimelineReady).isOffline, isFalse);
      expect(state.entries.map((e) => e.id), ['ev-fresh']);
    },
  );

  test(
    'offline-serves-cache: a connectivity failure keeps showing cached '
    'entries with isOffline true',
    () async {
      await database.replaceFirstPage([
        db.TimelineEntry(
          id: 'ev-1',
          type: 'memory',
          title: 'Before offline',
          description: null,
          photoUrl: null,
          icon: null,
          createdAt: DateTime.utc(2026, 5, 1),
        ),
      ]);
      final repository = TimelineRepository(
        database,
        _remoteAlwaysFailing(DioExceptionType.connectionError),
      );
      final cubit = TimelineCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await pumpEventQueue();

      final state = cubit.state;
      expect(state, isA<TimelineReady>());
      expect((state as TimelineReady).isOffline, isTrue);
      expect(state.entries.map((e) => e.id), ['ev-1']);
      expect(cubit.isOffline, isTrue);
    },
  );

  test(
    'offlineNoCache is reachable and distinct from empty when nothing has '
    'ever synced',
    () async {
      final repository = TimelineRepository(
        database,
        _remoteAlwaysFailing(DioExceptionType.connectionTimeout),
      );
      final cubit = TimelineCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await pumpEventQueue();

      expect(cubit.state, isA<TimelineOfflineNoCache>());
    },
  );

  test(
    'empty is reachable and distinct from offlineNoCache when a sync '
    'succeeds with zero entries',
    () async {
      final repository = TimelineRepository(
        database,
        _remoteWithHandler((options) async => _jsonResponse([], 200)),
      );
      final cubit = TimelineCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await pumpEventQueue();

      expect(cubit.state, isA<TimelineEmpty>());
    },
  );

  test(
    'error is reachable when a non-connectivity failure occurs with no '
    'cache to fall back on',
    () async {
      final repository = TimelineRepository(
        database,
        _remoteAlwaysFailing(DioExceptionType.badResponse, statusCode: 500),
      );
      final cubit = TimelineCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await pumpEventQueue();

      final state = cubit.state;
      expect(state, isA<TimelineError>());
      expect((state as TimelineError).failure, isA<HttpStatusFailure>());
    },
  );

  test(
    'a refresh failure never clears already-emitted entries',
    () async {
      final seedRemote = _remoteWithHandler(
        (options) async => _jsonResponse([
          _wireEntry(
            id: 'ev-kept',
            title: 'Kept',
            createdAt: '2026-05-01T00:00:00.000Z',
          ),
        ], 200),
      );
      final repository = TimelineRepository(database, seedRemote);
      final cubit = TimelineCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await pumpEventQueue();
      expect(cubit.state, isA<TimelineReady>());

      final failingRepository = TimelineRepository(
        database,
        _remoteAlwaysFailing(DioExceptionType.badResponse, statusCode: 500),
      );
      final failingOutcome = await failingRepository.refresh();
      expect(failingOutcome, isA<TimelineRefreshFailed>());

      await cubit.retry();
      await pumpEventQueue();

      final state = cubit.state;
      expect(state, isA<TimelineReady>());
      expect((state as TimelineReady).entries.map((e) => e.id), ['ev-kept']);
    },
  );

  test(
    'retry() can transition offlineNoCache to ready once connectivity '
    'returns',
    () async {
      var online = false;
      final repository = TimelineRepository(
        database,
        _remoteWithHandler((options) async {
          if (!online) {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            );
          }
          return _jsonResponse([
            _wireEntry(
              id: 'ev-recovered',
              title: 'Recovered',
              createdAt: '2026-05-14T00:00:00.000Z',
            ),
          ], 200);
        }),
      );
      final cubit = TimelineCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await pumpEventQueue();
      expect(cubit.state, isA<TimelineOfflineNoCache>());

      online = true;
      await cubit.retry();
      await pumpEventQueue();

      final state = cubit.state;
      expect(state, isA<TimelineReady>());
      expect((state as TimelineReady).isOffline, isFalse);
      expect(state.entries.map((e) => e.id), ['ev-recovered']);
    },
  );

  test(
    'createEntry fails fast without calling the repository or writing '
    'locally while offline',
    () async {
      var postCount = 0;
      final repository = TimelineRepository(
        database,
        _remoteAlwaysFailing(DioExceptionType.connectionError),
      );
      final cubit = TimelineCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await pumpEventQueue();
      expect(cubit.isOffline, isTrue);

      final onlineButUnusedRepository = TimelineRepository(
        database,
        _remoteWithHandler((options) async {
          if (options.method == 'POST') postCount++;
          return _jsonResponse([], 200);
        }),
      );
      // The cubit under test never reaches this repository while offline --
      // this second instance exists only to prove no POST would have counted.
      expect(onlineButUnusedRepository, isNotNull);

      await expectLater(
        cubit.createEntry(
          TimelineDraft(title: 'Should not send', date: DateTime.utc(2026, 6, 1)),
        ),
        throwsA(isA<NetworkUnavailableFailure>()),
      );

      expect(postCount, 0);
      expect(await database.select(database.timelineEntries).get(), isEmpty);
    },
  );

  test('subscription is cancelled on close and stops emitting', () async {
    final repository = TimelineRepository(
      database,
      _remoteWithHandler((options) async => _jsonResponse([], 200)),
    );
    final cubit = TimelineCubit(repository);

    await cubit.load();
    await pumpEventQueue();

    await cubit.close();

    await database.replaceFirstPage([
      db.TimelineEntry(
        id: 'ev-after-close',
        type: 'memory',
        title: 'After close',
        description: null,
        photoUrl: null,
        icon: null,
        createdAt: DateTime.utc(2026, 6, 1),
      ),
    ]);
    await pumpEventQueue();

    await expectLater(cubit.stream, emitsDone);
  });
}
