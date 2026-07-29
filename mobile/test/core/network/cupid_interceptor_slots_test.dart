import 'package:cupid_mobile/core/network/cupid_interceptor_slots.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthInterceptor extends Interceptor {
  const _FakeAuthInterceptor();
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
        expect(interceptors[3], isA<PassthroughInterceptor>());
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
}
