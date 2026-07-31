import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _AdapterResponse {
  _AdapterResponse.success(this.body) : error = null;

  _AdapterResponse.error(this.error) : body = null;

  final String? body;
  final DioException? error;
}

/// No live network: every response is programmed by the test via [respond],
/// mirroring `test/core/auth/cupid_auth_interceptor_test.dart`'s
/// `_FakeAdapter` pattern.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.respond);

  _AdapterResponse Function(RequestOptions options) respond;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final result = respond(options);
    if (result.error != null) {
      throw result.error!;
    }
    return ResponseBody.fromString(
      result.body ?? '',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DioException _notFound(RequestOptions options, String message) =>
    DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: 404),
      message: message,
    );

({DreamJarRepository repository, _RecordingAdapter adapter}) _build(
  _AdapterResponse Function(RequestOptions options) respond,
) {
  final adapter = _RecordingAdapter(respond);
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(const CupidErrorInterceptor());
  return (
    repository: DreamJarRepository(CupidApi(dio: dio, interceptors: const [])),
    adapter: adapter,
  );
}

Map<String, dynamic> _jarJson({String id = 'jar-1'}) => <String, dynamic>{
  'id': id,
  'name': 'Trip to Da Lat',
  'targetAmount': '50000000.00',
  'currentAmount': '12000000.00',
  'deadline': null,
  'currency': 'VND',
  'status': 'active',
  'progress': 24,
  'createdAt': '2026-01-01T00:00:00.000Z',
};

Map<String, dynamic> _contributionJson() => <String, dynamic>{
  'id': 'contribution-1',
  'dreamJarId': 'jar-1',
  'userId': 'user-1',
  'amount': '200000.00',
  'note': null,
  'createdAt': '2026-01-01T00:00:00.000Z',
};

void main() {
  group('DreamJarRepository.fetchJars', () {
    test('issues GET /dream-jar with the default limit/offset and decodes '
        'the list', () async {
      final built = _build(
        (options) => _AdapterResponse.success(
          jsonEncode([_jarJson(), _jarJson(id: 'jar-2')]),
        ),
      );

      final jars = await built.repository.fetchJars();

      expect(jars, hasLength(2));
      expect(jars.first, isA<DreamJar>());
      expect(built.adapter.requests.single.path, '/dream-jar');
      expect(built.adapter.requests.single.method, 'GET');
      expect(
        built.adapter.requests.single.queryParameters,
        <String, Object?>{'limit': 50, 'offset': 0},
      );
    });

    test('forwards a custom limit/offset', () async {
      final built = _build(
        (options) => _AdapterResponse.success(jsonEncode(<Object?>[])),
      );

      await built.repository.fetchJars(limit: 10, offset: 20);

      expect(
        built.adapter.requests.single.queryParameters,
        <String, Object?>{'limit': 10, 'offset': 20},
      );
    });
  });

  group('DreamJarRepository.fetchJar', () {
    test('issues GET /dream-jar/:id and decodes the jar', () async {
      final built = _build(
        (options) => _AdapterResponse.success(jsonEncode(_jarJson())),
      );

      final jar = await built.repository.fetchJar('jar-1');

      expect(jar.id, 'jar-1');
      expect(built.adapter.requests.single.path, '/dream-jar/jar-1');
      expect(built.adapter.requests.single.method, 'GET');
    });
  });

  group('DreamJarRepository.createJar', () {
    test('sends name/targetAmount and omits currency/deadline when absent', () async {
      final built = _build(
        (options) => _AdapterResponse.success(jsonEncode(_jarJson())),
      );

      await built.repository.createJar(
        name: 'Trip to Da Lat',
        targetAmount: 50000000,
      );

      final request = built.adapter.requests.single;
      expect(request.path, '/dream-jar');
      expect(request.method, 'POST');
      final body = request.data as Map<String, Object?>;
      expect(body, <String, Object?>{
        'name': 'Trip to Da Lat',
        'targetAmount': 50000000,
      });
      expect(body.containsKey('currency'), isFalse);
      expect(body.containsKey('deadline'), isFalse);
    });

    test('sends deadline as ISO-8601 when non-null', () async {
      final built = _build(
        (options) => _AdapterResponse.success(jsonEncode(_jarJson())),
      );
      final deadline = DateTime.utc(2026, 12, 31);

      await built.repository.createJar(
        name: 'Trip to Da Lat',
        targetAmount: 50000000,
        deadline: deadline,
      );

      final body = built.adapter.requests.single.data as Map<String, Object?>;
      expect(body['deadline'], deadline.toIso8601String());
    });
  });

  group('DreamJarRepository.addContribution', () {
    test('issues POST /dream-jar/:id/contributions with the amount body', () async {
      final built = _build(
        (options) => _AdapterResponse.success(jsonEncode(_contributionJson())),
      );

      final contribution = await built.repository.addContribution(
        jarId: 'jar-1',
        amount: 200000,
      );

      expect(contribution.amount, 200000);
      final request = built.adapter.requests.single;
      expect(request.path, '/dream-jar/jar-1/contributions');
      expect(request.method, 'POST');
      expect(request.data, <String, Object?>{'amount': 200000});
    });
  });

  group('DreamJarRepository.fetchContributions', () {
    test('issues GET /dream-jar/:id/contributions with limit/offset', () async {
      final built = _build(
        (options) => _AdapterResponse.success(jsonEncode([_contributionJson()])),
      );

      final contributions = await built.repository.fetchContributions('jar-1');

      expect(contributions, hasLength(1));
      final request = built.adapter.requests.single;
      expect(request.path, '/dream-jar/jar-1/contributions');
      expect(request.queryParameters, <String, Object?>{
        'limit': 50,
        'offset': 0,
      });
    });
  });

  group('DreamJarRepository failure mapping', () {
    test('a 404 mentioning "not paired" surfaces as DreamJarUnpairedFailure', () async {
      final built = _build(
        (options) => _AdapterResponse.error(
          _notFound(options, 'User not found or not paired'),
        ),
      );

      await expectLater(
        built.repository.fetchJars(),
        throwsA(isA<DreamJarUnpairedFailure>()),
      );
    });

    test('a 404 mentioning "not paired" case-insensitively still splits', () async {
      final built = _build(
        (options) =>
            _AdapterResponse.error(_notFound(options, 'User Not Paired')),
      );

      await expectLater(
        built.repository.fetchJar('jar-1'),
        throwsA(isA<DreamJarUnpairedFailure>()),
      );
    });

    test('a 404 for a missing jar stays a plain HttpStatusFailure', () async {
      final built = _build(
        (options) => _AdapterResponse.error(_notFound(options, 'Dream Jar not found')),
      );

      await expectLater(
        built.repository.fetchJar('jar-1'),
        throwsA(
          allOf(isA<HttpStatusFailure>(), isNot(isA<DreamJarUnpairedFailure>())),
        ),
      );
    });

    test('never rethrows a raw DioException', () async {
      final built = _build(
        (options) => _AdapterResponse.error(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      await expectLater(
        built.repository.fetchJars(),
        throwsA(isA<CupidApiFailure>()),
      );
    });
  });
}
