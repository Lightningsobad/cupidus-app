/// Public, non-secret runtime configuration for the Cupid mobile app.
///
/// Values here are compile-time defaults only. Real endpoints, Firebase
/// options, and any secrets are wired in later foundation stories (F2 api
/// client, F3 auth) and must never be hard-coded in this file.
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.environment});

  final String apiBaseUrl;
  final String environment;

  static const AppConfig defaultConfig = AppConfig(
    apiBaseUrl: 'http://localhost:3000',
    environment: 'local',
  );
}
