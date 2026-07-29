import 'package:dio/dio.dart';

import '../network/cupid_auth_token_provider.dart';

/// The `auth` slot's real occupant (`architecture/solution.md` ADR-011c).
///
/// Attaches the current Firebase ID token as a bearer header and, on a 401,
/// force-refreshes exactly once via [CupidAuthTokenProvider.refreshAccessToken]
/// before replaying the request exactly once. Concurrent 401s share a single
/// in-flight refresh so N failures never trigger N refreshes (a "refresh
/// storm"). If the refresh fails, [onSessionExpired] is invoked so the caller
/// can drive `CupidSession` to `SignedOut` (AC2, ADR-011c) and the original
/// error is forwarded unchanged — this interceptor never throws.
class CupidAuthInterceptor extends Interceptor {
  CupidAuthInterceptor({
    required this.tokenProvider,
    required this.dio,
    Future<void> Function()? onSessionExpired,
  }) : _onSessionExpired = onSessionExpired ?? _noopSessionExpired;

  static Future<void> _noopSessionExpired() async {}

  static const _retriedKey = 'cupid_auth_retried';

  final CupidAuthTokenProvider tokenProvider;
  final Dio dio;
  final Future<void> Function() _onSessionExpired;

  /// The single in-flight refresh, shared by every concurrent 401 (ADR-011c
  /// "single-flight is mandatory").
  Future<String?>? _refreshFuture;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
    if (err.response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final token = await _refreshToken();
    if (token == null) {
      await _onSessionExpired();
      handler.next(err);
      return;
    }

    final retryOptions = err.requestOptions;
    retryOptions.extra[_retriedKey] = true;
    retryOptions.headers['Authorization'] = 'Bearer $token';

    try {
      final response = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshToken() {
    return _refreshFuture ??= _forceRefresh().whenComplete(
      () => _refreshFuture = null,
    );
  }

  /// A thrown refresh (`user-token-expired`, `user-disabled`,
  /// `user-not-found`) is treated the same as a `null` result (ADR-011c):
  /// both drive [onSessionExpired] and forward the original 401 unchanged.
  Future<String?> _forceRefresh() async {
    try {
      return await tokenProvider.refreshAccessToken();
    } catch (_) {
      return null;
    }
  }
}
