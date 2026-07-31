import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/auth/cupid_session.dart';
import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stubs the transport layer beneath [CupidApiClient.create]'s shared [Dio],
/// matching the P2/P3 remote-source test approach (real interceptor
/// pipeline, no live network call, no extra test-only package).
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

CupidApi _apiWithHandler(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = _FakeHttpClientAdapter(handler);
  return api;
}

BackendUserIdStore _backendUserIdStore(String id) =>
    BackendUserIdStore()..updateFromLoginResponse({'id': id});

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('resolve() reports paired from GET /users/me', () async {
    final api = _apiWithHandler((options) async {
      expect(options.path, '/users/me');
      return _jsonResponse({'id': 'user-1', 'partnerId': 'user-2'}, 200);
    });
    final store = CouplePairingStore(
      api: api,
      backendUserIdStore: _backendUserIdStore('user-1'),
    );

    expect(await store.resolve(), PairingStatus.paired);
  });

  test('resolve() reports unpaired when partnerId is absent', () async {
    final api = _apiWithHandler((options) async {
      return _jsonResponse({'id': 'user-1'}, 200);
    });
    final store = CouplePairingStore(
      api: api,
      backendUserIdStore: _backendUserIdStore('user-1'),
    );

    expect(await store.resolve(), PairingStatus.unpaired);
  });

  test('a cached status is served immediately while offline', () async {
    final backendUserIdStore = _backendUserIdStore('user-1');
    await CouplePairingStore(
      api: _apiWithHandler(
        (options) async =>
            _jsonResponse({'id': 'user-1', 'partnerId': 'user-2'}, 200),
      ),
      backendUserIdStore: backendUserIdStore,
    ).resolve();

    var networkCalls = 0;
    final offlineStore = CouplePairingStore(
      api: _apiWithHandler((options) async {
        networkCalls++;
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }),
      backendUserIdStore: backendUserIdStore,
    );

    final status = await offlineStore.resolve();
    await pumpEventQueue();

    expect(status, PairingStatus.paired);
    expect(networkCalls, greaterThanOrEqualTo(1));
  });

  test(
    'unknown is returned when nothing is cached and the network is '
    'unavailable',
    () async {
      final api = _apiWithHandler((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });
      final store = CouplePairingStore(
        api: api,
        backendUserIdStore: _backendUserIdStore('user-1'),
      );

      expect(await store.resolve(), PairingStatus.unknown);
    },
  );

  test(
    'clearOnSignOut removes the persisted status so it does not survive '
    'sign-out',
    () async {
      final backendUserIdStore = _backendUserIdStore('user-1');
      final store = CouplePairingStore(
        api: _apiWithHandler(
          (options) async =>
              _jsonResponse({'id': 'user-1', 'partnerId': 'user-2'}, 200),
        ),
        backendUserIdStore: backendUserIdStore,
      );
      await store.resolve();

      await store.clearOnSignOut();

      final storeAfterSignOut = CouplePairingStore(
        api: _apiWithHandler((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }),
        backendUserIdStore: backendUserIdStore,
      );

      expect(await storeAfterSignOut.resolve(), PairingStatus.unknown);
    },
  );

  test(
    'clearOnSignOut resolves the key even after BackendUserIdStore has '
    'already cleared its cached id',
    () async {
      final backendUserIdStore = _backendUserIdStore('user-1');
      final store = CouplePairingStore(
        api: _apiWithHandler(
          (options) async =>
              _jsonResponse({'id': 'user-1', 'partnerId': 'user-2'}, 200),
        ),
        backendUserIdStore: backendUserIdStore,
      );
      await store.resolve();

      await backendUserIdStore.clearOnSignOut();
      await store.clearOnSignOut();

      final storeAfterSignOut = CouplePairingStore(
        api: _apiWithHandler((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }),
        backendUserIdStore: _backendUserIdStore('user-1'),
      );

      expect(await storeAfterSignOut.resolve(), PairingStatus.unknown);
    },
  );

  test('is registered as a SessionScopedStore', () {
    final store = CouplePairingStore(
      api: _apiWithHandler((options) async => _jsonResponse({}, 200)),
      backendUserIdStore: _backendUserIdStore('user-1'),
    );
    expect(store, isA<SessionScopedStore>());
  });
}
