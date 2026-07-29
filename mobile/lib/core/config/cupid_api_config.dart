/// Build-time REST client configuration (`architecture/solution.md` §2, §4).
///
/// Follows the same const `String.fromEnvironment` pattern as
/// `core/config/cupid_feature_flags.dart`. `10.0.2.2` is the Android
/// emulator's loopback alias for the host machine's `localhost`.
abstract final class CupidApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'CUPID_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
