import 'package:dio/dio.dart';

import 'cupid_api_failure.dart';

/// Maps every [DioException] to a [CupidApiFailure] on
/// `DioException.error` and rethrows via `handler.next` (Interceptor
/// Pipeline Contract, slot 3, `errorMapping`). Never resolves or swallows an
/// error.
class CupidErrorInterceptor extends Interceptor {
  const CupidErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: _mapToFailure(err)));
  }

  CupidApiFailure _mapToFailure(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkUnavailableFailure();
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          return const UnauthorizedFailure();
        }
        return HttpStatusFailure(statusCode ?? 0, err.message);
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const UnexpectedFailure();
    }
  }
}
