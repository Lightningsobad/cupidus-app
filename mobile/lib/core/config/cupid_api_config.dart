import 'package:flutter/services.dart' show appFlavor;

/// Build-time REST client configuration (`architecture/solution.md` §2, §4).
///
/// Follows the same const `String.fromEnvironment` pattern as
/// `core/config/cupid_feature_flags.dart`. `10.0.2.2` is the Android
/// emulator's loopback alias for the host machine's `localhost`.
///
/// Precedence is explicit `--dart-define` > Android product flavor
/// (`appFlavor`) > no-flavor local default. The flavor only supplies the
/// `defaultValue` of REQ-007's two existing keys, so it drives that mechanism
/// instead of being a second config system.
abstract final class CupidApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'CUPID_API_BASE_URL',
    defaultValue: _isProductionFlavor ? productionBaseUrl : localBaseUrl,
  );

  /// Declares which build flavor this binary is. Kept separate from [baseUrl]
  /// so a production build that forgets `CUPID_API_BASE_URL` is detectable:
  /// [baseUrl]'s localhost default is frozen by AC2 and cannot be removed.
  static const String environment = String.fromEnvironment(
    'CUPID_ENV',
    defaultValue: _isProductionFlavor ? productionEnvironment : localEnvironment,
  );

  static const String localEnvironment = 'local';
  static const String productionEnvironment = 'production';

  /// Android product flavor names declared in `android/app/build.gradle.kts`.
  static const String localFlavor = 'local';
  static const String productionFlavor = 'prod';

  static const String localBaseUrl = 'http://localhost:3000';

  /// The only place the production origin appears in `lib/`.
  static const String productionBaseUrl = 'https://api.cupidus.app';

  static const bool _isProductionFlavor = appFlavor == productionFlavor;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// The environment a flavor is required to resolve to, or `null` when the
  /// build carries no flavor (or one this app does not declare).
  ///
  /// Only [productionFlavor] constrains the build. [localFlavor] is also the
  /// `default-flavor`, so it is what an unflavored invocation resolves to and
  /// cannot be read as a deliberate "this is local" assertion — REQ-007's
  /// define-only production build still carries it.
  static String? requiredEnvironmentForFlavor(String? flavor) =>
      flavor == productionFlavor ? productionEnvironment : null;

  /// Pure so it is testable: [environment], [baseUrl], and [appFlavor] are
  /// compile-time consts and cannot be varied inside a unit test.
  static String? validationError(
    String environment,
    String baseUrl, {
    String? flavor,
  }) {
    if (environment != localEnvironment && environment != productionEnvironment) {
      return 'CUPID_ENV must be "$localEnvironment" or "$productionEnvironment", '
          'but this build declares "$environment".';
    }
    final String? requiredEnvironment = requiredEnvironmentForFlavor(flavor);
    if (requiredEnvironment != null && requiredEnvironment != environment) {
      return 'Build flavor "$flavor" requires CUPID_ENV=$requiredEnvironment, '
          'but this build resolves to "$environment". Drop the conflicting '
          '--dart-define=CUPID_ENV or select the matching build variant.';
    }
    if (environment == productionEnvironment && baseUrl != productionBaseUrl) {
      return 'CUPID_ENV=$productionEnvironment requires '
          'CUPID_API_BASE_URL=$productionBaseUrl, but this build resolves to '
          '"$baseUrl". Rebuild with '
          '--dart-define=CUPID_API_BASE_URL=$productionBaseUrl.';
    }
    if (environment == localEnvironment && baseUrl == productionBaseUrl) {
      return 'CUPID_ENV=$localEnvironment must not point at '
          '$productionBaseUrl. This build would talk to production while '
          'declaring itself local; select the "$productionFlavor" build '
          'variant instead.';
    }
    return null;
  }

  static void assertValidConfig() {
    final String? error = validationError(
      environment,
      baseUrl,
      flavor: appFlavor,
    );
    if (error != null) {
      throw StateError(error);
    }
  }
}
