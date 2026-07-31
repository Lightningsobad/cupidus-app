import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Handler = ResponseBody Function(RequestOptions options, String? body);

/// Records every request it receives and answers with a canned response,
/// standing in for the real HTTP transport below the shared `Dio` pipeline.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final _Handler handler;
  final List<RequestOptions> requests = [];
  final List<String?> bodies = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    String? body;
    if (requestStream != null) {
      final bytes = await requestStream.expand((chunk) => chunk).toList();
      body = utf8.decode(bytes);
    }
    bodies.add(body);
    return handler(options, body);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> json, {int statusCode = 200}) {
  return ResponseBody.fromBytes(
    utf8.encode(jsonEncode(json)),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> _profileJson({String displayName = 'Alex'}) => {
  'id': 'user-1',
  'email': 'alex@example.com',
  'displayName': displayName,
  'photoUrl': null,
  'birthday': '1996-05-15',
  'relationshipStartDate': null,
  'zodiacSign': 'Taurus',
  'language': 'vi',
  'partnerId': null,
  'coupleType': null,
  'vowTaken': false,
  'isGhostModeEnabled': true,
};

CupidApi _buildApi(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(const CupidErrorInterceptor());
  return CupidApi(dio: dio, interceptors: const []);
}

void main() {
  group('AccountRepository.fetchProfile', () {
    test('maps a successful GET /users/me response', () async {
      final adapter = _FakeAdapter(
        (options, body) => _jsonBody(_profileJson()),
      );
      final repository = AccountRepository(api: _buildApi(adapter));

      final profile = await repository.fetchProfile();

      expect(profile.displayName, 'Alex');
      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.path, '/users/me');
    });

    test('rethrows the mapped CupidApiFailure, not DioException', () async {
      final adapter = _FakeAdapter(
        (options, body) => _jsonBody({'message': 'boom'}, statusCode: 500),
      );
      final repository = AccountRepository(api: _buildApi(adapter));

      await expectLater(
        repository.fetchProfile(),
        throwsA(isA<HttpStatusFailure>()),
      );
    });
  });

  group('AccountRepository.updateProfile', () {
    test('PATCH body contains only the changed fields', () async {
      final adapter = _FakeAdapter((options, body) {
        if (options.method == 'PATCH') {
          return _jsonBody({});
        }
        return _jsonBody(_profileJson(displayName: 'Alexandra'));
      });
      final repository = AccountRepository(api: _buildApi(adapter));

      await repository.updateProfile(displayName: 'Alexandra');

      final patchRequest = adapter.requests.firstWhere(
        (r) => r.method == 'PATCH',
      );
      expect(patchRequest.path, '/users/me');
      final sentBody =
          jsonDecode(adapter.bodies[adapter.requests.indexOf(patchRequest)]!)
              as Map<String, dynamic>;
      expect(sentBody, {'displayName': 'Alexandra'});
    });

    test('re-reads the profile after a successful PATCH', () async {
      final adapter = _FakeAdapter((options, body) {
        if (options.method == 'PATCH') {
          return _jsonBody({});
        }
        return _jsonBody(_profileJson(displayName: 'Alexandra'));
      });
      final repository = AccountRepository(api: _buildApi(adapter));

      final profile = await repository.updateProfile(
        displayName: 'Alexandra',
      );

      expect(profile.displayName, 'Alexandra');
      expect(adapter.requests.map((r) => r.method).toList(), [
        'PATCH',
        'GET',
      ]);
    });

    test('a failed PATCH yields a CupidApiFailure and never re-reads',
        () async {
      final adapter = _FakeAdapter(
        (options, body) => _jsonBody({'message': 'boom'}, statusCode: 500),
      );
      final repository = AccountRepository(api: _buildApi(adapter));

      await expectLater(
        repository.updateProfile(displayName: 'Alexandra'),
        throwsA(isA<HttpStatusFailure>()),
      );
      expect(adapter.requests, hasLength(1));
    });
  });
}
