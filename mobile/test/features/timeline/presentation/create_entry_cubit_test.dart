import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/database/daos/timeline_dao.dart' as db;
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:cupid_mobile/features/timeline/presentation/create_entry_cubit.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors the `timeline_cubit_test.dart` transport stub: exercises a real
/// [TimelineRepository] and a real in-memory Drift database against a faked
/// [Dio] transport, with no live network call and no extra test-only
/// package.
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
  return _remoteWithHandler((RequestOptions options) async {
    throw DioException(
      requestOptions: options,
      type: type,
      response: statusCode != null
          ? Response(requestOptions: options, statusCode: statusCode)
          : null,
    );
  });
}

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
    'submit rejects an empty title with no network call and stays in '
    'editing',
    () async {
      int postCount = 0;
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteWithHandler((RequestOptions options) async {
          if (options.method == 'POST') postCount++;
          return _jsonResponse(<Object?>[], 200);
        }),
      );
      final CreateEntryCubit cubit = CreateEntryCubit(
        repository,
        isOffline: () => false,
      );
      addTearDown(cubit.close);

      await cubit.submit(
        TimelineDraft(title: '   ', date: DateTime.utc(2026, 6, 1)),
      );

      expect(cubit.state, isA<CreateEntryEditing>());
      expect(postCount, 0);
      expect(await database.select(database.timelineEntries).get(), isEmpty);
    },
  );

  test(
    'submit succeeds: emits submitting then success and writes exactly one '
    'POST, with no local write performed by the cubit itself',
    () async {
      int postCount = 0;
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteWithHandler((RequestOptions options) async {
          if (options.method == 'POST') postCount++;
          return _jsonResponse(<Object?>[], 200);
        }),
      );
      final CreateEntryCubit cubit = CreateEntryCubit(
        repository,
        isOffline: () => false,
      );
      addTearDown(cubit.close);

      final List<CreateEntryState> emitted = <CreateEntryState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      await cubit.submit(
        TimelineDraft(title: 'First date', date: DateTime.utc(2026, 6, 1)),
      );
      await pumpEventQueue();

      expect(emitted, <Matcher>[
        isA<CreateEntrySubmitting>(),
        isA<CreateEntrySuccess>(),
      ]);
      expect(postCount, 1);
    },
  );

  test(
    'submit blocked proactively while already offline: no repository call, '
    'no Drift row, blockedOffline emitted',
    () async {
      int postCount = 0;
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteWithHandler((RequestOptions options) async {
          if (options.method == 'POST') postCount++;
          return _jsonResponse(<Object?>[], 200);
        }),
      );
      final CreateEntryCubit cubit = CreateEntryCubit(
        repository,
        isOffline: () => true,
      );
      addTearDown(cubit.close);

      await cubit.submit(
        TimelineDraft(title: 'Should not send', date: DateTime.utc(2026, 6, 1)),
      );

      expect(cubit.state, isA<CreateEntryBlockedOffline>());
      expect(postCount, 0);
      expect(await database.select(database.timelineEntries).get(), isEmpty);
    },
  );

  test(
    'a NetworkUnavailableFailure from the repository maps to blockedOffline '
    'and writes no Drift row',
    () async {
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteAlwaysFailing(DioExceptionType.connectionError),
      );
      final CreateEntryCubit cubit = CreateEntryCubit(
        repository,
        isOffline: () => false,
      );
      addTearDown(cubit.close);

      await cubit.submit(
        TimelineDraft(title: 'Backdated', date: DateTime.utc(2026, 1, 1)),
      );

      expect(cubit.state, isA<CreateEntryBlockedOffline>());
      expect(await database.select(database.timelineEntries).get(), isEmpty);
    },
  );

  test(
    'a TimeoutFailure from the repository also maps to blockedOffline',
    () async {
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteAlwaysFailing(DioExceptionType.connectionTimeout),
      );
      final CreateEntryCubit cubit = CreateEntryCubit(
        repository,
        isOffline: () => false,
      );
      addTearDown(cubit.close);

      await cubit.submit(
        TimelineDraft(title: 'Timed out', date: DateTime.utc(2026, 1, 1)),
      );

      expect(cubit.state, isA<CreateEntryBlockedOffline>());
    },
  );

  test('a 404 maps to pairingRequired', () async {
    final TimelineRepository repository = TimelineRepository(
      dao,
      _remoteAlwaysFailing(DioExceptionType.badResponse, statusCode: 404),
    );
    final CreateEntryCubit cubit = CreateEntryCubit(
      repository,
      isOffline: () => false,
    );
    addTearDown(cubit.close);

    await cubit.submit(
      TimelineDraft(title: 'Unpaired attempt', date: DateTime.utc(2026, 1, 1)),
    );

    expect(cubit.state, isA<CreateEntryPairingRequired>());
  });

  test(
    'any other CupidApiFailure maps to failed with the generic error copy',
    () async {
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteAlwaysFailing(DioExceptionType.badResponse, statusCode: 500),
      );
      final CreateEntryCubit cubit = CreateEntryCubit(
        repository,
        isOffline: () => false,
      );
      addTearDown(cubit.close);

      await cubit.submit(
        TimelineDraft(title: 'Server error', date: DateTime.utc(2026, 1, 1)),
      );

      final CreateEntryState state = cubit.state;
      expect(state, isA<CreateEntryFailed>());
      expect((state as CreateEntryFailed).failure, isA<HttpStatusFailure>());
    },
  );

  test(
    'an UnauthorizedFailure propagates to the caller instead of being '
    'mapped to a sheet-local state',
    () async {
      final TimelineRepository repository = TimelineRepository(
        dao,
        _remoteAlwaysFailing(DioExceptionType.badResponse, statusCode: 401),
      );
      final CreateEntryCubit cubit = CreateEntryCubit(
        repository,
        isOffline: () => false,
      );
      addTearDown(cubit.close);

      await expectLater(
        cubit.submit(
          TimelineDraft(title: 'Needs re-auth', date: DateTime.utc(2026, 1, 1)),
        ),
        throwsA(isA<UnauthorizedFailure>()),
      );

      expect(cubit.state, isA<CreateEntrySubmitting>());
    },
  );
}
