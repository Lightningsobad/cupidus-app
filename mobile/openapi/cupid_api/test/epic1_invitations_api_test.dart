import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic1InvitationsApi
void main() {
  final instance = CupidApi().getEpic1InvitationsApi();

  group(Epic1InvitationsApi, () {
    // Accept an invitation using a code
    //
    //Future invitationsControllerAccept() async
    test('test invitationsControllerAccept', () async {
      // TODO
    });

    // Generate a pairing invitation code
    //
    //Future invitationsControllerGenerate() async
    test('test invitationsControllerGenerate', () async {
      // TODO
    });

    // Debug: Test generating code
    //
    //Future invitationsControllerTestGenerate(String uid) async
    test('test invitationsControllerTestGenerate', () async {
      // TODO
    });

    // Debug: Test validating code
    //
    //Future invitationsControllerTestValidate(String code) async
    test('test invitationsControllerTestValidate', () async {
      // TODO
    });

    // Validate an invitation code
    //
    //Future invitationsControllerValidate() async
    test('test invitationsControllerValidate', () async {
      // TODO
    });

  });
}
