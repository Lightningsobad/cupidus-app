import 'package:cupid_api/cupid_api.dart';
import 'package:dio/dio.dart';

import '../config/cupid_api_config.dart';
import 'cupid_interceptor_slots.dart';

/// Builds the single shared [Dio] instance and the generated [CupidApi]
/// entry point (`architecture/solution.md` §2).
abstract final class CupidApiClient {
  static CupidApi create({
    Map<CupidInterceptorSlot, Interceptor> slotOverrides = const {},
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: CupidApiConfig.baseUrl,
        connectTimeout: CupidApiConfig.connectTimeout,
        receiveTimeout: CupidApiConfig.receiveTimeout,
      ),
    );
    dio.interceptors.addAll(mergeCupidInterceptorSlots(slotOverrides));

    // `interceptors: const []` suppresses CupidApi's own default OAuth/
    // Basic/Bearer/API-key interceptors: this pipeline's `auth` slot is the
    // single authentication plug point (`architecture/solution.md` §2).
    return CupidApi(dio: dio, interceptors: const []);
  }
}
