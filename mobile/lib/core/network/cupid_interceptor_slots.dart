import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'cupid_error_interceptor.dart';

/// Fixed, ordered Dio interceptor pipeline
/// (`architecture/solution.md` Interceptor Pipeline Contract). Occupants may
/// be replaced by override; slot order itself is part of the contract and
/// must not change.
enum CupidInterceptorSlot { requestContext, auth, diagnostics, errorMapping }

/// A no-op interceptor: forwards every request, response, and error
/// unchanged. Occupies a slot until a real interceptor replaces it.
class PassthroughInterceptor extends Interceptor {
  const PassthroughInterceptor();
}

/// Stamps every outbound request with the headers every backend call needs
/// (Interceptor Pipeline Contract, slot 0, `requestContext`).
class RequestContextInterceptor extends Interceptor {
  const RequestContextInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    options.headers['X-Client-Platform'] = Platform.operatingSystem;
    handler.next(options);
  }
}

/// The default occupant for each [CupidInterceptorSlot], in contract order.
///
/// `auth`'s real occupant is supplied by STORY-003 via override.
Map<CupidInterceptorSlot, Interceptor> defaultCupidInterceptorSlots() {
  return {
    CupidInterceptorSlot.requestContext: const RequestContextInterceptor(),
    CupidInterceptorSlot.auth: const PassthroughInterceptor(),
    CupidInterceptorSlot.diagnostics: kDebugMode
        ? LogInterceptor()
        : const PassthroughInterceptor(),
    CupidInterceptorSlot.errorMapping: const CupidErrorInterceptor(),
  };
}

/// Merges [overrides] onto the default slot pipeline, replacing exactly the
/// occupant of each overridden slot and preserving slot order.
List<Interceptor> mergeCupidInterceptorSlots(
  Map<CupidInterceptorSlot, Interceptor> overrides,
) {
  final defaults = defaultCupidInterceptorSlots();
  return CupidInterceptorSlot.values
      .map((slot) => overrides[slot] ?? defaults[slot]!)
      .toList(growable: false);
}
