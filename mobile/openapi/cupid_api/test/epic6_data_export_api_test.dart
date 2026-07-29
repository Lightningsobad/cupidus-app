import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic6DataExportApi
void main() {
  final instance = CupidApi().getEpic6DataExportApi();

  group(Epic6DataExportApi, () {
    // Download a completed data export zip file
    //
    //Future dataExportControllerDownloadExport(String id) async
    test('test dataExportControllerDownloadExport', () async {
      // TODO
    });

    // Get list of personal data exports
    //
    //Future dataExportControllerGetExports() async
    test('test dataExportControllerGetExports', () async {
      // TODO
    });

    // Request a new personal data export
    //
    //Future dataExportControllerRequestExport() async
    test('test dataExportControllerRequestExport', () async {
      // TODO
    });

  });
}
