import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/database/daos/timeline_dao.dart' as db;
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stubs the transport layer beneath [CupidApiClient.create]'s shared [Dio]
/// so the repository is exercised end to end (real interceptor pipeline,
/// real in-memory Drift database) with no live network call and no extra
/// test-only package, matching the P2 remote-source test approach.
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
  late db.CupidDatabase database;
  late db.TimelineDao dao;

  setUp(() {
    database = db.CupidDatabase(NativeDatabase.memory());
    dao = database.timelineDao;
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'watchEntries emits cached content before any network call completes',
    () async {
      await dao.replaceFirstPage([
        db.TimelineEntry(
          id: 'ev-1',
          type: 'memory',
          title: 'Cached',
          description: null,
          photoUrl: null,
          icon: null,
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ]);
      final remote = _remoteWithHandler((options) async {
        fail('watchEntries must never call the network');
      });
      final repository = TimelineRepository(dao, remote);

      final first = await repository.watchEntries().first;

      expect(first, hasLength(1));
      expect(first.single.id, 'ev-1');
    },
  );

  test(
    'a successful refresh replaces the first page and the stream re-emits',
    () async {
      final remote = _remoteWithHandler((options) async {
        return _jsonResponse([
          _wireEntry(
            id: 'ev-2',
            title: 'Fresh',
            createdAt: '2026-05-14T00:00:00.000Z',
          ),
        ], 200);
      });
      final repository = TimelineRepository(dao, remote);
      final emissions = <List<TimelineEntry>>[];
      final subscription = repository.watchEntries().listen(emissions.add);
      addTearDown(subscription.cancel);

      final outcome = await repository.refresh();
      await pumpEventQueue();

      expect(outcome, isA<TimelineSynced>());
      expect(emissions.last.map((e) => e.id), ['ev-2']);
    },
  );

  test(
    'offline with a populated cache returns offlineWithCache and keeps '
    'cached rows readable',
    () async {
      final seedRemote = _remoteWithHandler((options) async {
        return _jsonResponse([
          _wireEntry(
            id: 'ev-3',
            title: 'Before offline',
            createdAt: '2026-05-01T00:00:00.000Z',
          ),
        ], 200);
      });
      await TimelineRepository(dao, seedRemote).refresh();

      final repository = TimelineRepository(
        dao,
        _remoteAlwaysFailing(DioExceptionType.connectionError),
      );

      final outcome = await repository.refresh();

      expect(outcome, isA<TimelineOfflineWithCache>());
      final cached = await repository.watchEntries().first;
      expect(cached.map((e) => e.id), ['ev-3']);
    },
  );

  test('offline with no prior sync returns offlineNoCache', () async {
    final repository = TimelineRepository(
      dao,
      _remoteAlwaysFailing(DioExceptionType.connectionTimeout),
    );

    final outcome = await repository.refresh();

    expect(outcome, isA<TimelineOfflineNoCache>());
  });

  test(
    'a synced-but-empty timeline is distinguishable from never-synced',
    () async {
      expect(await dao.lastSyncedAt(), isNull);
      final repository = TimelineRepository(
        dao,
        _remoteWithHandler((options) async => _jsonResponse([], 200)),
      );

      final outcome = await repository.refresh();

      expect(outcome, isA<TimelineSynced>());
      expect(await dao.lastSyncedAt(), isNotNull);
      expect(await repository.watchEntries().first, isEmpty);
    },
  );

  test(
    'a non-connectivity failure returns failed and leaves the cache '
    'untouched',
    () async {
      final seedRemote = _remoteWithHandler((options) async {
        return _jsonResponse([
          _wireEntry(
            id: 'ev-4',
            title: 'Untouched',
            createdAt: '2026-05-01T00:00:00.000Z',
          ),
        ], 200);
      });
      await TimelineRepository(dao, seedRemote).refresh();

      final repository = TimelineRepository(
        dao,
        _remoteAlwaysFailing(DioExceptionType.badResponse, statusCode: 500),
      );

      final outcome = await repository.refresh();

      expect(outcome, isA<TimelineRefreshFailed>());
      expect(
        (outcome as TimelineRefreshFailed).failure,
        isA<HttpStatusFailure>(),
      );
      final cached = await repository.watchEntries().first;
      expect(cached.map((e) => e.id), ['ev-4']);
    },
  );

  test('createEntry performs exactly one POST and no local insert on failure', () async {
    var postCount = 0;
    final remote = _remoteWithHandler((options) async {
      if (options.method == 'POST') {
        postCount++;
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return _jsonResponse([], 200);
    });
    final repository = TimelineRepository(dao, remote);

    await expectLater(
      repository.createEntry(
        TimelineDraft(title: 'Fails', date: DateTime.utc(2026, 5, 14)),
      ),
      throwsA(isA<NetworkUnavailableFailure>()),
    );

    expect(postCount, 1);
    expect(await database.select(database.timelineEntries).get(), isEmpty);
  });

  test(
    'createEntry success calls refresh so the server-assigned id becomes '
    'local truth',
    () async {
      final remote = _remoteWithHandler((options) async {
        if (options.method == 'POST') {
          return _jsonResponse({'id': 'server-assigned'}, 201);
        }
        return _jsonResponse([
          _wireEntry(
            id: 'server-assigned',
            title: 'Our first date',
            createdAt: '2026-05-14T00:00:00.000Z',
          ),
        ], 200);
      });
      final repository = TimelineRepository(dao, remote);

      final outcome = await repository.createEntry(
        TimelineDraft(title: 'Our first date', date: DateTime.utc(2026, 5, 14)),
      );

      expect(outcome, isA<TimelineSynced>());
      final cached = await repository.watchEntries().first;
      expect(cached.single.id, 'server-assigned');
    },
  );
}
