import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic4PrivateGalleryApi
void main() {
  final instance = CupidApi().getEpic4PrivateGalleryApi();

  group(Epic4PrivateGalleryApi, () {
    // Add a new encrypted photo reference to Gallery
    //
    //Future galleryControllerCreate(CreateGalleryItemDto createGalleryItemDto) async
    test('test galleryControllerCreate', () async {
      // TODO
    });

    // Get gallery photos list
    //
    //Future galleryControllerFindAll(String limit, String offset) async
    test('test galleryControllerFindAll', () async {
      // TODO
    });

    // Delete a photo from Gallery
    //
    //Future galleryControllerRemove(String id) async
    test('test galleryControllerRemove', () async {
      // TODO
    });

  });
}
