import 'dart:typed_data';
import 'package:cupid_mobile/core/auth/cupid_auth_interceptor.dart';
import 'package:cupid_mobile/core/network/cupid_auth_token_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTokenProvider implements CupidAuthTokenProvider {
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<String?> refreshAccessToken() async => 'new-token';
}

class _FakeAdapter implements HttpClientAdapter {
  int fetchCount = 0;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    fetchCount++;
    return ResponseBody.fromString('{}', 200, headers: {Headers.contentTypeHeader: ['application/json']});
  }
  @override
  void close({bool force = false}) {}
}

class _H extends ErrorInterceptorHandler {
  DioException? forwardedError;
  Response<dynamic>? resolvedResponse;
  @override
  void next(DioException err) { forwardedError = err; print('next called: $err'); }
  @override
  void resolve(Response<dynamic> response) { resolvedResponse = response; print('resolve called'); }
}

void main() {
  test('probe2', () async {
    final adapter = _FakeAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final interceptor = CupidAuthInterceptor(tokenProvider: _FakeTokenProvider(), dio: dio);
    final handler = _H();
    final options = RequestOptions(path: '/x');
    final err = DioException(requestOptions: options, type: DioExceptionType.badResponse, response: Response(requestOptions: options, statusCode: 401));

    interceptor.onError(err, handler);
    await pumpEventQueue();

    print('fetchCount: ${adapter.fetchCount}');
  });
}
