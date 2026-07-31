import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_api.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_local_cache.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_repository.dart';
import 'package:cupid_mobile/features/gallery/domain/gallery_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records every request the fake sees and returns a canned JSON body per
/// path/method, mirroring `test/core/auth/cupid_auth_interceptor_test.dart`'s
/// `_FakeAdapter` pattern rather than hitting a real backend.
class _FakeGalleryAdapter implements HttpClientAdapter {
  bool failGalleryFetch = false;
  bool failUpload = false;
  int uploadCalls = 0;
  int createItemCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/gallery' && options.method == 'GET') {
      if (failGalleryFetch) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return _jsonResponse(jsonEncode([
        {
          'id': 'item-1',
          'userId': 'u1',
          'filename': 'a.jpg',
          'thumbnailUrl': null,
          'isEncrypted': true,
          'encryptionKeyId': null,
          'mimeType': 'image/jpeg',
          'createdAt': '2026-07-30T10:15:00.000Z',
        },
      ]));
    }

    if (options.path == '/uploads' && options.method == 'POST') {
      uploadCalls++;
      if (failUpload) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return _jsonResponse(jsonEncode({
        'url': '/uploads/abc.jpg',
        'filename': 'abc.jpg',
        'originalName': 'photo.jpg',
        'mimeType': 'image/jpeg',
        'size': 1024,
      }));
    }

    if (options.path == '/gallery' && options.method == 'POST') {
      createItemCalls++;
      return _jsonResponse(jsonEncode({
        'id': 'item-2',
        'userId': 'u1',
        'filename': 'abc.jpg',
        'thumbnailUrl': null,
        'isEncrypted': true,
        'encryptionKeyId': null,
        'mimeType': 'image/jpeg',
        'createdAt': '2026-07-31T00:00:00.000Z',
      }));
    }

    throw UnimplementedError(
      'unexpected request ${options.method} ${options.path}',
    );
  }

  @override
  void close({bool force = false}) {}

  ResponseBody _jsonResponse(String body) => ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
}

GalleryApi _apiWith(_FakeGalleryAdapter adapter) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = adapter;
  return GalleryApi(api: api);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('GalleryRepository.fetchPage', () {
    test(
      'maps a recorded GET /gallery fixture into GalleryItem values with '
      'correct createdAt parsing',
      () async {
        final repository = GalleryRepository(
          api: _apiWith(_FakeGalleryAdapter()),
          cache: GalleryLocalCache(),
        );

        final page = await repository.fetchPage();

        expect(page.isStale, isFalse);
        expect(page.items, hasLength(1));
        final item = page.items.single;
        expect(item.id, 'item-1');
        expect(item.userId, 'u1');
        expect(item.filename, 'a.jpg');
        expect(item.createdAt, DateTime.parse('2026-07-30T10:15:00.000Z'));
      },
    );

    test(
      'returns the cached snapshot and marks the result stale on a '
      'DioException instead of throwing',
      () async {
        final cache = GalleryLocalCache();
        await cache.save([
          GalleryItem(
            id: 'cached-1',
            userId: 'u1',
            filename: 'cached.jpg',
            createdAt: DateTime.utc(2026, 7, 29),
          ),
        ]);
        final repository = GalleryRepository(
          api: _apiWith(_FakeGalleryAdapter()..failGalleryFetch = true),
          cache: cache,
        );

        final page = await repository.fetchPage();

        expect(page.isStale, isTrue);
        expect(page.items, hasLength(1));
        expect(page.items.single.id, 'cached-1');
      },
    );
  });

  group('GalleryRepository.uploadPhoto', () {
    late File tempImageFile;

    setUp(() {
      tempImageFile = File(
        '${Directory.systemTemp.path}/gallery_repository_test_upload.jpg',
      )..writeAsBytesSync(const [0xFF, 0xD8, 0xFF]);
    });

    tearDown(() {
      if (tempImageFile.existsSync()) tempImageFile.deleteSync();
    });

    test('calls POST /uploads then POST /gallery in sequence', () async {
      final adapter = _FakeGalleryAdapter();
      final repository = GalleryRepository(
        api: _apiWith(adapter),
        cache: GalleryLocalCache(),
      );

      final item = await repository.uploadPhoto(tempImageFile);

      expect(adapter.uploadCalls, 1);
      expect(adapter.createItemCalls, 1);
      expect(item.filename, 'abc.jpg');
    });

    test('a step-1 upload failure never issues step 2', () async {
      final adapter = _FakeGalleryAdapter()..failUpload = true;
      final repository = GalleryRepository(
        api: _apiWith(adapter),
        cache: GalleryLocalCache(),
      );

      await expectLater(
        repository.uploadPhoto(tempImageFile),
        throwsA(isA<DioException>()),
      );
      expect(adapter.createItemCalls, 0);
    });
  });

  group('galleryMediaUrl', () {
    test('derives <baseUrl>/uploads/<filename> with no double slash', () {
      expect(
        galleryMediaUrl('abc.jpg'),
        '${CupidApiConfig.baseUrl}/uploads/abc.jpg',
      );
      expect(
        galleryMediaUrl('/abc.jpg'),
        '${CupidApiConfig.baseUrl}/uploads/abc.jpg',
      );
    });
  });
}
