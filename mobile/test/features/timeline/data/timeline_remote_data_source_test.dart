import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stubs the transport layer beneath [CupidApiClient.create]'s shared
/// [Dio] so tests exercise the real interceptor pipeline -- including
/// `CupidErrorInterceptor`'s `DioException` -> `CupidApiFailure` mapping --
/// without a live network call or an extra test-only package.
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

CupidApi _apiWithAdapter(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = _FakeHttpClientAdapter(handler);
  return api;
}

void main() {
  group('TimelineRemoteDataSource.fetchFirstPage', () {
    test('decodes a successful GET /timeline body into entries', () async {
      Uri? capturedUri;
      final api = _apiWithAdapter((options) async {
        capturedUri = options.uri;
        return _jsonResponse([
          {
            'id': 'ev-1',
            'type': 'memory',
            'title': 'First fight, survived',
            'description': null,
            'photoUrl': null,
            'icon': 'favorite',
            'createdAt': '2026-05-14T00:00:00.000Z',
          },
          {
            'id': 'ev-2',
            'type': 'milestone',
            'title': '1 Week Together!',
            'icon': '🏆',
            'createdAt': '2026-05-07T00:00:00.000Z',
          },
        ], 200);
      });
      final dataSource = TimelineRemoteDataSource(api);

      final entries = await dataSource.fetchFirstPage();

      expect(entries, [
        TimelineEntry.fromDto(
          TimelineEventDto.fromJson({
            'id': 'ev-1',
            'type': 'memory',
            'title': 'First fight, survived',
            'icon': 'favorite',
            'createdAt': '2026-05-14T00:00:00.000Z',
          }),
        ),
        TimelineEntry.fromDto(
          TimelineEventDto.fromJson({
            'id': 'ev-2',
            'type': 'milestone',
            'title': '1 Week Together!',
            'icon': '🏆',
            'createdAt': '2026-05-07T00:00:00.000Z',
          }),
        ),
      ]);
      expect(capturedUri!.path, '/timeline');
      expect(capturedUri!.queryParameters['limit'], '50');
      expect(capturedUri!.queryParameters['offset'], '0');
    });

    test(
      'throws NetworkUnavailableFailure when the connection is unavailable',
      () async {
        final api = _apiWithAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        });
        final dataSource = TimelineRemoteDataSource(api);

        await expectLater(
          dataSource.fetchFirstPage(),
          throwsA(isA<NetworkUnavailableFailure>()),
        );
      },
    );

    test('throws TimeoutFailure when the connection times out', () async {
      final api = _apiWithAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      });
      final dataSource = TimelineRemoteDataSource(api);

      await expectLater(
        dataSource.fetchFirstPage(),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test('throws HttpStatusFailure(404) on a 404 response', () async {
      final api = _apiWithAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 404),
        );
      });
      final dataSource = TimelineRemoteDataSource(api);

      await expectLater(
        dataSource.fetchFirstPage(),
        throwsA(
          isA<HttpStatusFailure>().having(
            (f) => f.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });

    test('throws a typed decode failure for a non-list body', () async {
      final api = _apiWithAdapter((options) async {
        return _jsonResponse({'not': 'a list'}, 200);
      });
      final dataSource = TimelineRemoteDataSource(api);

      await expectLater(
        dataSource.fetchFirstPage(),
        throwsA(isA<TimelineDecodeException>()),
      );
    });

    test(
      'throws a typed decode failure for a single undecodable element',
      () async {
        final api = _apiWithAdapter((options) async {
          return _jsonResponse([
            {
              'id': 'ev-1',
              'title': 'Valid',
              'createdAt': '2026-05-14T00:00:00.000Z',
            },
            {'title': 'Missing id'},
          ], 200);
        });
        final dataSource = TimelineRemoteDataSource(api);

        await expectLater(
          dataSource.fetchFirstPage(),
          throwsA(isA<TimelineDecodeException>()),
        );
      },
    );
  });

  group('TimelineRemoteDataSource.createEntry', () {
    test('POSTs exactly the draft fields', () async {
      String? capturedPath;
      Object? capturedBody;
      final api = _apiWithAdapter((options) async {
        capturedPath = options.path;
        capturedBody = options.data;
        return _jsonResponse({'id': 'ev-new'}, 201);
      });
      final dataSource = TimelineRemoteDataSource(api);
      final draft = TimelineDraft(
        title: 'Our first date',
        date: DateTime.utc(2026, 5, 14),
        description: 'It was magical',
      );

      await dataSource.createEntry(draft);

      expect(capturedPath, '/timeline');
      expect(capturedBody, draft.toJson());
    });

    test(
      'throws NetworkUnavailableFailure when the connection is unavailable',
      () async {
        final api = _apiWithAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        });
        final dataSource = TimelineRemoteDataSource(api);

        await expectLater(
          dataSource.createEntry(
            TimelineDraft(title: 'Offline', date: DateTime.utc(2026, 5, 14)),
          ),
          throwsA(isA<NetworkUnavailableFailure>()),
        );
      },
    );

    test(
      'throws HttpStatusFailure(404) when the couple is unpaired',
      () async {
        final api = _apiWithAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: options, statusCode: 404),
          );
        });
        final dataSource = TimelineRemoteDataSource(api);

        await expectLater(
          dataSource.createEntry(
            TimelineDraft(title: 'Unpaired', date: DateTime.utc(2026, 5, 14)),
          ),
          throwsA(
            isA<HttpStatusFailure>().having(
              (f) => f.statusCode,
              'statusCode',
              404,
            ),
          ),
        );
      },
    );
  });
}
