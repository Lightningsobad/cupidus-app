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

  /// Declares which build flavor this binary is. Kept separate from [baseUrl]
  /// so a production build that forgets `CUPID_API_BASE_URL` is detectable:
  /// [baseUrl]'s localhost default is frozen by AC2 and cannot be removed.
  static const String environment = String.fromEnvironment(
    'CUPID_ENV',
    defaultValue: localEnvironment,
  );

  static const String localEnvironment = 'local';
  static const String productionEnvironment = 'production';

  /// The only place the production origin appears in `lib/`.
  static const String productionBaseUrl = 'https://api.cupidus.app';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// Pure so it is testable: [environment] and [baseUrl] are compile-time
  /// consts and cannot be varied inside a unit test.
  static String? validationError(String environment, String baseUrl) {
    if (environment != localEnvironment && environment != productionEnvironment) {
      return 'CUPID_ENV must be "$localEnvironment" or "$productionEnvironment", '
          'but this build declares "$environment".';
    }
    if (environment == productionEnvironment && baseUrl != productionBaseUrl) {
      return 'CUPID_ENV=$productionEnvironment requires '
          'CUPID_API_BASE_URL=$productionBaseUrl, but this build resolves to '
          '"$baseUrl". Rebuild with '
          '--dart-define=CUPID_API_BASE_URL=$productionBaseUrl.';
    }
    return null;
  }

  static void assertValidConfig() {
    final String? error = validationError(environment, baseUrl);
    if (error != null) {
      throw StateError(error);
    }
  }
}
