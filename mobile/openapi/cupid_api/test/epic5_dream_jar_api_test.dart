import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic5DreamJarApi
void main() {
  final instance = CupidApi().getEpic5DreamJarApi();

  group(Epic5DreamJarApi, () {
    // Add a contribution to a Dream Jar
    //
    //Future dreamJarControllerAddContribution(String id, AddContributionDto addContributionDto) async
    test('test dreamJarControllerAddContribution', () async {
      // TODO
    });

    // Create a new Dream Jar
    //
    //Future dreamJarControllerCreate(CreateDreamJarDto createDreamJarDto) async
    test('test dreamJarControllerCreate', () async {
      // TODO
    });

    // Get all Dream Jars
    //
    //Future dreamJarControllerFindAll(String limit, String offset) async
    test('test dreamJarControllerFindAll', () async {
      // TODO
    });

    // Get a specific Dream Jar
    //
    //Future dreamJarControllerFindOne(String id) async
    test('test dreamJarControllerFindOne', () async {
      // TODO
    });

    // Get contribution history of a Dream Jar
    //
    //Future dreamJarControllerGetContributions(String id, String limit, String offset) async
    test('test dreamJarControllerGetContributions', () async {
      // TODO
    });

    // Delete a Dream Jar
    //
    //Future dreamJarControllerRemove(String id) async
    test('test dreamJarControllerRemove', () async {
      // TODO
    });

    // Update a Dream Jar
    //
    //Future dreamJarControllerUpdate(String id, UpdateDreamJarDto updateDreamJarDto) async
    test('test dreamJarControllerUpdate', () async {
      // TODO
    });

  });
}
