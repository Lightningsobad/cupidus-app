import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic6AdminConfigurationsApi
void main() {
  final instance = CupidApi().getEpic6AdminConfigurationsApi();

  group(Epic6AdminConfigurationsApi, () {
    // Get all system configurations
    //
    //Future adminControllerGetAllConfigs() async
    test('test adminControllerGetAllConfigs', () async {
      // TODO
    });

    // Get a specific system configuration
    //
    //Future adminControllerGetConfig(String key) async
    test('test adminControllerGetConfig', () async {
      // TODO
    });

    // Get system metrics (users, couples, etc.)
    //
    //Future adminControllerGetMetrics() async
    test('test adminControllerGetMetrics', () async {
      // TODO
    });

    // Update a specific system configuration
    //
    //Future adminControllerUpdateConfig(String key, UpdateConfigDto updateConfigDto) async
    test('test adminControllerUpdateConfig', () async {
      // TODO
    });

  });
}
