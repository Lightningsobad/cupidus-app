import 'dart:convert';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_gate_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A `DioAdapter`-free stand-in for a scripted HTTP response, consistent
/// with the pattern in `test/features/auth/data/auth_repository_test.dart`
/// (injected fakes, no mocking package).
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._respond);

  final Future<ResponseBody> Function(RequestOptions options) _respond;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) => _respond(options);
}

ResponseBody _jsonResponse(Object? data, [int statusCode = 200]) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

LoveContractGateRepository _repositoryWith(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = adapter
    ..interceptors.add(const CupidErrorInterceptor());
  return LoveContractGateRepository(
    CupidApi(dio: dio, interceptors: const []),
  );
}

void main() {
  group('LoveContractGateRepository.fetchPairingState', () {
    test('returns a paired state when partnerId is present', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter(
          (options) async => _jsonResponse({
            'displayName': 'An',
            'partnerId': 'partner-1',
          }),
        ),
      );

      final state = await repository.fetchPairingState();

      expect(state.isPaired, isTrue);
      expect(state.myDisplayName, 'An');
      expect(state.partnerId, 'partner-1');
    });

    test('returns unpaired when partnerId is null', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter(
          (options) async =>
              _jsonResponse({'displayName': 'An', 'partnerId': null}),
        ),
      );

      final state = await repository.fetchPairingState();

      expect(state.isPaired, isFalse);
      expect(state.partnerId, isNull);
    });

    test('returns unpaired when the body is not a map', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter((options) async => _jsonResponse(null)),
      );

      final state = await repository.fetchPairingState();

      expect(state, same(PairingState.unpaired));
    });

    test('returns unpaired on a connection failure', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter(
          (options) async => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      final state = await repository.fetchPairingState();

      expect(state, same(PairingState.unpaired));
    });

    test('returns unpaired on a 500 response', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter(
          (options) async => _jsonResponse({'message': 'boom'}, 500),
        ),
      );

      final state = await repository.fetchPairingState();

      expect(state, same(PairingState.unpaired));
    });
  });
}
