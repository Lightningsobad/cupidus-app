import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic1LoveContractsApi
void main() {
  final instance = CupidApi().getEpic1LoveContractsApi();

  group(Epic1LoveContractsApi, () {
    // Create a new love contract
    //
    //Future loveContractsControllerCreate(CreateContractDto createContractDto) async
    test('test loveContractsControllerCreate', () async {
      // TODO
    });

    // Get current pending love contract
    //
    //Future loveContractsControllerGetMyPending() async
    test('test loveContractsControllerGetMyPending', () async {
      // TODO
    });

    // Sign the pending love contract
    //
    //Future loveContractsControllerSign() async
    test('test loveContractsControllerSign', () async {
      // TODO
    });

  });
}
