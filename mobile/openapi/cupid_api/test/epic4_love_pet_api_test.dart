import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic4LovePetApi
void main() {
  final instance = CupidApi().getEpic4LovePetApi();

  group(Epic4LovePetApi, () {
    // Adopt a new Love Pet
    //
    //Future petsControllerAdopt(AdoptPetDto adoptPetDto) async
    test('test petsControllerAdopt', () async {
      // TODO
    });

    // Get current Love Pet details
    //
    //Future petsControllerGetPet() async
    test('test petsControllerGetPet', () async {
      // TODO
    });

    // Get Love Pet dynamic status
    //
    //Future petsControllerGetStatus() async
    test('test petsControllerGetStatus', () async {
      // TODO
    });

    // Interact with the Love Pet (feed/play) to increase happiness
    //
    //Future petsControllerInteract() async
    test('test petsControllerInteract', () async {
      // TODO
    });

  });
}
