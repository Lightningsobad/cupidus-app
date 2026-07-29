import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic3SyncedAlarmsApi
void main() {
  final instance = CupidApi().getEpic3SyncedAlarmsApi();

  group(Epic3SyncedAlarmsApi, () {
    // Confirm alarm time set by partner
    //
    //Future alarmsControllerConfirm(String id) async
    test('test alarmsControllerConfirm', () async {
      // TODO
    });

    // Create or update synced alarm time
    //
    //Future alarmsControllerCreate(CreateAlarmDto createAlarmDto) async
    test('test alarmsControllerCreate', () async {
      // TODO
    });

    // Get current coupled alarm setup
    //
    //Future alarmsControllerFindOne() async
    test('test alarmsControllerFindOne', () async {
      // TODO
    });

    // Stop alarm while ringing
    //
    //Future alarmsControllerStop(String id) async
    test('test alarmsControllerStop', () async {
      // TODO
    });

  });
}
