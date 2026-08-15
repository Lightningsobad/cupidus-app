import 'dart:async';
import 'dart:typed_data';

import 'package:cupid_mobile/core/auth/cupid_auth_interceptor.dart';
import 'package:cupid_mobile/core/auth/session_termination.dart';
import 'package:cupid_mobile/core/network/cupid_auth_token_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTokenProvider implements CupidAuthTokenProvider {
  _FakeTokenProvider({this.readToken, this.refreshResult, this.refreshError});

  String? readToken;
  String? refreshResult;
  Object? refreshError;
  bool holdRefresh = false;
  int refreshCallCount = 0;
  final List<Completer<String?>> _pendingRefreshes = [];

  @override
  Future<String?> readAccessToken() async => readToken;

  @override
  Future<String?> refreshAccessToken() async {
    refreshCallCount++;
    if (holdRefresh) {
      final completer = Completer<String?>();
      _pendingRefreshes.add(completer);
      return completer.future;
    }
    if (refreshError != null) {
      throw refreshError!;
    }
    return refreshResult;
  }

  void completeAllPendingRefreshes() {
    for (final completer in _pendingRefreshes) {
      if (!completer.isCompleted) completer.complete(refreshResult);
    }
  }
}

class _FakeAdapter implements HttpClientAdapter {
  int fetchCount = 0;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCount++;
    lastOptions = options;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CapturingRequestHandler extends RequestInterceptorHandler {
  RequestOptions? forwarded;

  @override
  void next(RequestOptions requestOptions) {
    forwarded = requestOptions;
  }
}

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  DioException? forwardedError;
  Response<dynamic>? resolvedResponse;

  @override
  void next(DioException err) {
    forwardedError = err;
  }

  @override
  void resolve(Response<dynamic> response) {
    resolvedResponse = response;
  }
}

/// Records the `emit` call itself rather than the stream delivery: the
/// notifier's broadcast controller is async, so a plain stream listener cannot
/// observe whether the signal was published before or after teardown ran.
class _RecordingNotifier extends SessionTerminationNotifier {
  _RecordingNotifier(this.calls);

  final List<String> calls;

  @override
  void emit(SessionTerminationReason reason) {
    calls.add('emit:${reason.name}');
    super.emit(reason);
  }
}

DioException _unauthorizedError(RequestOptions options) => DioException(
  requestOptions: options,
  type: DioExceptionType.badResponse,
  response: Response(requestOptions: options, statusCode: 401),
);

Future<void> _flush() => pumpEventQueue();

void main() {
  group('CupidAuthInterceptor.onRequest', () {
    test('attaches a bearer header when a token exists', () async {
      final provider = _FakeTokenProvider(readToken: 'abc123');
      final interceptor = CupidAuthInterceptor(
        tokenProvider: provider,
        dio: Dio(),
      );
      final handler = _CapturingRequestHandler();

      interceptor.onRequest(RequestOptions(path: '/x'), handler);
      await _flush();

      expect(handler.forwarded?.headers['Authorization'], 'Bearer abc123');
    });

    test('forwards the request unchanged when no token exists', () async {
      final provider = _FakeTokenProvider(readToken: null);
      final interceptor = CupidAuthInterceptor(
        tokenProvider: provider,
        dio: Dio(),
      );
      final handler = _CapturingRequestHandler();

      interceptor.onRequest(RequestOptions(path: '/x'), handler);
      await _flush();

      expect(handler.forwarded?.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('CupidAuthInterceptor.onError', () {
    test('non-401 errors are forwarded without a refresh attempt', () async {
      final provider = _FakeTokenProvider();
      final interceptor = CupidAuthInterceptor(
        tokenProvider: provider,
        dio: Dio(),
      );
      final handler = _CapturingErrorHandler();
      final options = RequestOptions(path: '/x');
      final err = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );

      interceptor.onError(err, handler);
      await _flush();

      expect(handler.forwardedError, same(err));
      expect(provider.refreshCallCount, 0);
    });

    test('401 -> one refresh -> one retry -> success', () async {
      final provider = _FakeTokenProvider(refreshResult: 'new-token');
      final adapter = _FakeAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final interceptor = CupidAuthInterceptor(tokenProvider: provider, dio: dio);
      final handler = _CapturingErrorHandler();
      final options = RequestOptions(path: '/x');

      interceptor.onError(_unauthorizedError(options), handler);
      await _flush();

      expect(provider.refreshCallCount, 1);
      expect(adapter.fetchCount, 1);
      expect(adapter.lastOptions?.extra['cupid_auth_retried'], true);
      expect(adapter.lastOptions?.headers['Authorization'], 'Bearer new-token');
      expect(handler.resolvedResponse, isNotNull);
      expect(handler.forwardedError, isNull);
    });

    test('a request already retried once is forwarded, no second refresh', () async {
      final provider = _FakeTokenProvider(refreshResult: 'new-token');
      final interceptor = CupidAuthInterceptor(
        tokenProvider: provider,
        dio: Dio(),
      );
      final handler = _CapturingErrorHandler();
      final options = RequestOptions(
        path: '/x',
        extra: {'cupid_auth_retried': true},
      );
      final err = _unauthorizedError(options);

      interceptor.onError(err, handler);
      await _flush();

      expect(provider.refreshCallCount, 0);
      expect(handler.forwardedError, same(err));
    });

    test(
      'a failed refresh drives session-expired and forwards the original '
      'error, with no retry',
      () async {
        final provider = _FakeTokenProvider(
          refreshError: Exception('user-token-expired'),
        );
        final adapter = _FakeAdapter();
        final dio = Dio()..httpClientAdapter = adapter;
        var sessionExpiredCalls = 0;
        final interceptor = CupidAuthInterceptor(
          tokenProvider: provider,
          dio: dio,
          onSessionExpired: () async {
            sessionExpiredCalls++;
          },
        );
        final handler = _CapturingErrorHandler();
        final options = RequestOptions(path: '/x');
        final err = _unauthorizedError(options);

        interceptor.onError(err, handler);
        await _flush();

        expect(sessionExpiredCalls, 1);
        expect(handler.forwardedError, same(err));
        expect(adapter.fetchCount, 0);
      },
    );

    test(
      'a failed refresh publishes refreshFailed before session teardown, '
      'still forwards the original error, and never throws',
      () async {
        final provider = _FakeTokenProvider(
          refreshError: Exception('user-token-expired'),
        );
        final order = <String>[];
        final notifier = _RecordingNotifier(order);
        addTearDown(notifier.dispose);
        final reasons = <SessionTerminationReason>[];
        notifier.stream.listen(reasons.add);

        final interceptor = CupidAuthInterceptor(
          tokenProvider: provider,
          dio: Dio(),
          sessionTermination: notifier,
          onSessionExpired: () async => order.add('teardown'),
        );
        final handler = _CapturingErrorHandler();
        final options = RequestOptions(path: '/x');
        final err = _unauthorizedError(options);

        interceptor.onError(err, handler);
        await _flush();

        expect(order, <String>['emit:refreshFailed', 'teardown']);
        expect(reasons, <SessionTerminationReason>[
          SessionTerminationReason.refreshFailed,
        ]);
        expect(handler.forwardedError, same(err));
      },
    );

    test('a successful refresh publishes no termination reason', () async {
      final provider = _FakeTokenProvider(refreshResult: 'new-token');
      final adapter = _FakeAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final notifier = SessionTerminationNotifier();
      addTearDown(notifier.dispose);
      final reasons = <SessionTerminationReason>[];
      notifier.stream.listen(reasons.add);

      final interceptor = CupidAuthInterceptor(
        tokenProvider: provider,
        dio: dio,
        sessionTermination: notifier,
      );
      final handler = _CapturingErrorHandler();

      interceptor.onError(
        _unauthorizedError(RequestOptions(path: '/x')),
        handler,
      );
      await _flush();

      expect(handler.resolvedResponse, isNotNull);
      expect(reasons, isEmpty);
    });

    test('5 concurrent 401s trigger exactly one refreshAccessToken call', () async {
      final provider = _FakeTokenProvider(refreshResult: 'new-token')
        ..holdRefresh = true;
      final adapter = _FakeAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final interceptor = CupidAuthInterceptor(tokenProvider: provider, dio: dio);
      final handlers = List.generate(5, (_) => _CapturingErrorHandler());

      for (var i = 0; i < 5; i++) {
        interceptor.onError(
          _unauthorizedError(RequestOptions(path: '/x$i')),
          handlers[i],
        );
      }
      await _flush();

      expect(provider.refreshCallCount, 1);

      provider.completeAllPendingRefreshes();
      await _flush();

      expect(adapter.fetchCount, 5);
      for (final handler in handlers) {
        expect(handler.resolvedResponse, isNotNull);
      }
    });
  });
}
