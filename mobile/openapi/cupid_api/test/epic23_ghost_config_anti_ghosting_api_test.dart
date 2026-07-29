import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic23GhostConfigAntiGhostingApi
void main() {
  final instance = CupidApi().getEpic23GhostConfigAntiGhostingApi();

  group(Epic23GhostConfigAntiGhostingApi, () {
    // Approve a pending config request
    //
    //Future ghostConfigControllerApprove(String id) async
    test('test ghostConfigControllerApprove', () async {
      // TODO
    });

    // Create or update Ghost Config (requires partner approval)
    //
    //Future ghostConfigControllerCreate(CreateGhostConfigDto createGhostConfigDto) async
    test('test ghostConfigControllerCreate', () async {
      // TODO
    });

    // Get current active Ghost Config
    //
    //Future ghostConfigControllerGetActive() async
    test('test ghostConfigControllerGetActive', () async {
      // TODO
    });

    // Get pending (unapproved) Ghost Configs
    //
    //Future ghostConfigControllerGetPending() async
    test('test ghostConfigControllerGetPending', () async {
      // TODO
    });

    // Check if user is allowed to send an Emoji Storm
    //
    //Future ghostConfigControllerGetStormStatus(String partnerId) async
    test('test ghostConfigControllerGetStormStatus', () async {
      // TODO
    });

    // Reject a pending config request
    //
    //Future ghostConfigControllerReject(String id) async
    test('test ghostConfigControllerReject', () async {
      // TODO
    });

  });
}
