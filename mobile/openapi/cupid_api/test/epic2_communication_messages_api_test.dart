import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic2CommunicationMessagesApi
void main() {
  final instance = CupidApi().getEpic2CommunicationMessagesApi();

  group(Epic2CommunicationMessagesApi, () {
    // Create a new chat message (fallback for websocket)
    //
    //Future messagesControllerCreate() async
    test('test messagesControllerCreate', () async {
      // TODO
    });

    // Get messages history
    //
    //Future messagesControllerFindAll(String partnerId, num page, num limit) async
    test('test messagesControllerFindAll', () async {
      // TODO
    });

  });
}
