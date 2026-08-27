import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cupid_mobile/features/emojis/data/emoji_catalog.dart';
import 'package:cupid_mobile/features/emojis/data/emoji_models.dart';
import 'package:cupid_mobile/features/emojis/data/emojis_repository.dart';

class _FakeDioAdapter implements HttpClientAdapter {
  Map<String, dynamic>? mockResponse;
  List<dynamic>? mockListResponse;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/emojis/catalog') {
      return ResponseBody.fromString(
        '[]',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == '/emojis/state') {
      return ResponseBody.fromString(
        '{"activePackId":"mochi-cat","downloadedPackIds":["mochi-cat","baby-dino"]}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == '/emojis/unlock') {
      return ResponseBody.fromString(
        '{"activePackId":"mochi-cat","downloadedPackIds":["mochi-cat","baby-dino","new-pack"]}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == '/emojis/active') {
      return ResponseBody.fromString(
        '{"activePackId":"baby-dino","downloadedPackIds":["mochi-cat","baby-dino"]}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString('{}', 200);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmojisRepository Test', () {
    late Dio dio;
    late EmojisRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      dio = Dio();
      dio.httpClientAdapter = _FakeDioAdapter();
      repository = EmojisRepository(
        dio: dio,
        preferences: SharedPreferences.getInstance,
      );
    });

    test('fetchCatalog returns fallback catalog when remote is empty or on error', () async {
      final catalog = await repository.fetchCatalog();
      expect(catalog.length, cupidEmojiCatalog.length);
      expect(catalog.first.id, 'mochi-cat');
    });

    test('getCoupleState returns state from backend', () async {
      final state = await repository.getCoupleState();
      expect(state.activePackId, 'mochi-cat');
      expect(state.downloadedPackIds, containsAll(['mochi-cat', 'baby-dino']));
    });

    test('unlockOrDownloadPack updates state with new pack', () async {
      final state = await repository.unlockOrDownloadPack('new-pack');
      expect(state.downloadedPackIds, contains('new-pack'));
    });

    test('setActivePack updates active pack id', () async {
      final state = await repository.setActivePack('baby-dino');
      expect(state.activePackId, 'baby-dino');
    });
  });
}
