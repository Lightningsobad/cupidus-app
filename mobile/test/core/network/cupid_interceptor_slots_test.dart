import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/core/network/cupid_interceptor_slots.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthInterceptor extends Interceptor {
  const _FakeAuthInterceptor();
}

class _NoopRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}

void main() {
  group('mergeCupidInterceptorSlots', () {
    test(
      'slot order is exactly requestContext, auth, diagnostics, errorMapping',
      () {
        final interceptors = mergeCupidInterceptorSlots(const {});

        expect(interceptors, hasLength(CupidInterceptorSlot.values.length));
        expect(interceptors[0], isA<RequestContextInterceptor>());
        expect(interceptors[1], isA<PassthroughInterceptor>());
        expect(interceptors[2], isA<LogInterceptor>());
        expect(interceptors[3], isA<CupidErrorInterceptor>());
      },
    );

    test(
      'overriding auth replaces exactly one interceptor and leaves the '
      'other three untouched',
      () {
        final defaultTypes = mergeCupidInterceptorSlots(
          const {},
        ).map((interceptor) => interceptor.runtimeType).toList();
        const override = _FakeAuthInterceptor();

        final overridden = mergeCupidInterceptorSlots({
          CupidInterceptorSlot.auth: override,
        });

        expect(overridden, hasLength(4));
        expect(overridden[0].runtimeType, defaultTypes[0]);
        expect(overridden[1], same(override));
        expect(overridden[1].runtimeType, isNot(defaultTypes[1]));
        expect(overridden[2].runtimeType, defaultTypes[2]);
        expect(overridden[3].runtimeType, defaultTypes[3]);
      },
    );
  });

  group('diagnostics token leak (ADR-011d)', () {
    test(
      'the default diagnostics interceptor never logs the Authorization '
      'header value',
      () {
        final logs = <String>[];
        final diagnostics =
            defaultCupidInterceptorSlots()[CupidInterceptorSlot.diagnostics]!
                as LogInterceptor;
        diagnostics.logPrint = (line) => logs.add(line.toString());
        final options = RequestOptions(
          path: '/x',
          headers: {'Authorization': 'Bearer live-secret-id-token'},
        );

        diagnostics.onRequest(options, _NoopRequestHandler());

        expect(
          logs.any((line) => line.contains('live-secret-id-token')),
          isFalse,
        );
        expect(logs.any((line) => line.contains('Authorization')), isFalse);
      },
    );
  });
}
