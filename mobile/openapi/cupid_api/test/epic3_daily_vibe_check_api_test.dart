import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic3DailyVibeCheckApi
void main() {
  final instance = CupidApi().getEpic3DailyVibeCheckApi();

  group(Epic3DailyVibeCheckApi, () {
    // Post daily mood / vibe
    //
    //Future vibesControllerCreate(CreateVibeDto createVibeDto) async
    test('test vibesControllerCreate', () async {
      // TODO
    });

    // Get user's vibe history
    //
    //Future vibesControllerGetHistory(String days) async
    test('test vibesControllerGetHistory', () async {
      // TODO
    });

    // Get partner's vibe history
    //
    //Future vibesControllerGetPartnerHistory(String days) async
    test('test vibesControllerGetPartnerHistory', () async {
      // TODO
    });

    // Get current user's vibe for today
    //
    //Future vibesControllerGetToday() async
    test('test vibesControllerGetToday', () async {
      // TODO
    });

  });
}
