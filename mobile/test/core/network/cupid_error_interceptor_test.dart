import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  DioException? captured;

  @override
  void next(DioException error) {
    captured = error;
  }
}

void main() {
  group('CupidErrorInterceptor', () {
    late RequestOptions requestOptions;
    late CupidErrorInterceptor interceptor;

    setUp(() {
      requestOptions = RequestOptions(path: '/example');
      interceptor = const CupidErrorInterceptor();
    });

    CupidApiFailure mapError(DioException err) {
      final handler = _CapturingErrorHandler();
      interceptor.onError(err, handler);
      return handler.captured!.error as CupidApiFailure;
    }

    test('connection timeout maps to TimeoutFailure', () {
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      expect(mapError(err), isA<TimeoutFailure>());
    });

    test('connection error maps to NetworkUnavailableFailure', () {
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      expect(mapError(err), isA<NetworkUnavailableFailure>());
    });

    test('401 response maps to UnauthorizedFailure', () {
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: requestOptions, statusCode: 401),
      );

      expect(mapError(err), isA<UnauthorizedFailure>());
    });

    test('500 response maps to HttpStatusFailure', () {
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: requestOptions, statusCode: 500),
        message: 'Internal Server Error',
      );

      final failure = mapError(err);

      expect(failure, isA<HttpStatusFailure>());
      final httpFailure = failure as HttpStatusFailure;
      expect(httpFailure.statusCode, 500);
      expect(httpFailure.message, 'Internal Server Error');
    });

    test('onError does not swallow the error', () {
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );
      final handler = _CapturingErrorHandler();

      interceptor.onError(err, handler);

      expect(handler.captured, isNotNull);
    });
  });
}
