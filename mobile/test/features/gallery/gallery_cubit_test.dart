import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/app_shell.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_api.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_local_cache.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_repository.dart';
import 'package:cupid_mobile/features/gallery/domain/gallery_item.dart';
import 'package:cupid_mobile/features/gallery/presentation/gallery_cubit.dart';
import 'package:cupid_mobile/features/gallery/presentation/gallery_state.dart';
import 'package:cupid_mobile/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:cupid_mobile/features/gallery/presentation/widgets/gallery_locked_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake `Dio` transport for `GET /users/me` and `GET /gallery`, mirroring
/// `test/features/gallery/gallery_repository_test.dart`'s `_FakeGalleryAdapter`
/// pattern (records call counts so the AC3 "no `GET /gallery` call in the
/// locked branch" check can be asserted directly on the fake).
class _FakeGalleryAdapter implements HttpClientAdapter {
  _FakeGalleryAdapter({
    this.mePartnerId,
    this.meId = 'me-1',
    this.failGalleryFetch = false,
    this.galleryItemsJson = const <Map<String, dynamic>>[],
  });

  final String meId;
  final String? mePartnerId;
  final bool failGalleryFetch;
  final List<Map<String, dynamic>> galleryItemsJson;

  int meFetchCalls = 0;
  int galleryFetchCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/users/me' && options.method == 'GET') {
      meFetchCalls++;
      return _jsonResponse(
        jsonEncode({'id': meId, 'partnerId': mePartnerId}),
      );
    }

    if (options.path == '/gallery' && options.method == 'GET') {
      galleryFetchCalls++;
      if (failGalleryFetch) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return _jsonResponse(jsonEncode(galleryItemsJson));
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

GalleryRepository _repositoryWith(_FakeGalleryAdapter adapter) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = adapter;
  return GalleryRepository(api: GalleryApi(api: api), cache: GalleryLocalCache());
}

Map<String, dynamic> _itemJson(String id) => {
  'id': id,
  'userId': 'me-1',
  'filename': '$id.jpg',
  'thumbnailUrl': null,
  'mimeType': 'image/jpeg',
  'createdAt': '2026-07-30T10:15:00.000Z',
};

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('GalleryCubit.load', () {
    test(
      'partnerId == null emits GalleryLocked and issues no GET /gallery call '
      '(AC3)',
      () async {
        final adapter = _FakeGalleryAdapter(mePartnerId: null);
        final cubit = GalleryCubit(repository: _repositoryWith(adapter));

        await cubit.load();

        expect(cubit.state, isA<GalleryLocked>());
        expect(adapter.galleryFetchCalls, 0);
        await cubit.close();
      },
    );

    test('partnerId != null with an empty list emits GalleryEmpty', () async {
      final adapter = _FakeGalleryAdapter(
        mePartnerId: 'partner-1',
        galleryItemsJson: const [],
      );
      final cubit = GalleryCubit(repository: _repositoryWith(adapter));

      await cubit.load();

      expect(cubit.state, isA<GalleryEmpty>());
      expect(adapter.galleryFetchCalls, 1);
      await cubit.close();
    });

    test(
      'partnerId != null with items emits GalleryLoaded carrying '
      'currentUserId',
      () async {
        final adapter = _FakeGalleryAdapter(
          mePartnerId: 'partner-1',
          meId: 'me-42',
          galleryItemsJson: [_itemJson('item-1')],
        );
        final cubit = GalleryCubit(repository: _repositoryWith(adapter));

        await cubit.load();

        final state = cubit.state;
        expect(state, isA<GalleryLoaded>());
        state as GalleryLoaded;
        expect(state.currentUserId, 'me-42');
        expect(state.items, hasLength(1));
        expect(state.isStale, isFalse);
        await cubit.close();
      },
    );

    test(
      'a repository failure with a cached snapshot emits GalleryLoaded with '
      'isStale: true',
      () async {
        final cache = GalleryLocalCache();
        await cache.save([
          GalleryItem(
            id: 'cached-1',
            userId: 'me-1',
            filename: 'cached.jpg',
            createdAt: DateTime.utc(2026, 7, 29),
          ),
        ]);
        final api = CupidApiClient.create();
        final adapter = _FakeGalleryAdapter(
          mePartnerId: 'partner-1',
          failGalleryFetch: true,
        );
        api.dio.httpClientAdapter = adapter;
        final cubit = GalleryCubit(
          repository: GalleryRepository(api: GalleryApi(api: api), cache: cache),
        );

        await cubit.load();

        final state = cubit.state;
        expect(state, isA<GalleryLoaded>());
        state as GalleryLoaded;
        expect(state.isStale, isTrue);
        expect(state.items.single.id, 'cached-1');
        await cubit.close();
      },
    );

    test(
      'a repository failure with no cache emits GalleryFailure',
      () async {
        final adapter = _FakeGalleryAdapter(
          mePartnerId: 'partner-1',
          failGalleryFetch: true,
        );
        final cubit = GalleryCubit(repository: _repositoryWith(adapter));

        await cubit.load();

        expect(cubit.state, isA<GalleryFailure>());
        await cubit.close();
      },
    );
  });

  group('AppShell gallery destination', () {
    setUp(() {
      getIt.reset();
      final adapter = _FakeGalleryAdapter(mePartnerId: null);
      final api = CupidApiClient.create();
      api.dio.httpClientAdapter = adapter;
      final galleryApi = GalleryApi(api: api);
      final galleryLocalCache = GalleryLocalCache();
      // Registered eagerly (not `registerLazySingleton`): the tab-tap
      // rebuild below drives `MaterialApp`'s `Navigator`/`Overlay` through
      // more than one build pass in the same `pump()`, so `BlocProvider`'s
      // `create` can run more than once. A lazy singleton's first-ever
      // resolution isn't reentrancy-safe against that (get_it's
      // `_readyCompleter` double-completes); pre-creating the instances
      // here means widget build never hits the lazy-creation branch at all.
      getIt.registerSingleton<GalleryApi>(galleryApi);
      getIt.registerSingleton<GalleryLocalCache>(galleryLocalCache);
      getIt.registerSingleton<GalleryRepository>(
        GalleryRepository(api: galleryApi, cache: galleryLocalCache),
      );
      // `AppShell()` here takes no explicit stores, so its `ChatEntryGate`
      // wrap (always evaluated on build) and its Home tab's
      // `_TimelineEntryPointGate` (rendered first, before the Gallery tap)
      // both resolve their stores through GetIt; neither has any other
      // override hook.
      final storeDio = Dio()..httpClientAdapter = adapter;
      getIt.registerSingleton<ChatPartnerStore>(
        ChatPartnerStore(dio: storeDio),
      );
      getIt.registerSingleton<CouplePairingStore>(
        CouplePairingStore(
          api: CupidApi(dio: storeDio, interceptors: const []),
          backendUserIdStore: BackendUserIdStore(),
        ),
      );
    });

    tearDown(getIt.reset);

    testWidgets(
      'exposes a labelled gallery destination reachable by tap, opening '
      'GalleryScreen',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildCupidTheme(
              platform: CupidPlatform.material,
              brightness: Brightness.dark,
            ),
            home: const AppShell(),
          ),
        );

        expect(find.text('Gallery'), findsOneWidget);
        expect(find.byType(GalleryScreen), findsNothing);

        await tester.tap(find.text('Gallery'));
        // `pumpAndSettle` (not a single `pump`): tapping mounts `GalleryScreen`,
        // which fires `GalleryCubit.load()`'s `GET /users/me` Dio request in
        // the background. A single `pump` leaves that request's timeout timer
        // pending when the test ends, tripping flutter_test's
        // `!timersPending` invariant check.
        await tester.pumpAndSettle();

        expect(find.byType(GalleryScreen), findsOneWidget);
      },
    );
  });

  group('GalleryLockedView', () {
    testWidgets(
      'labels the CTA for screen readers as navigating to the pairing flow '
      'and uses no lock/biometric iconography (AC3 accessibility)',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: buildCupidTheme(
              platform: CupidPlatform.material,
              brightness: Brightness.dark,
            ),
            home: Scaffold(
              body: GalleryLockedView(onPairingCta: () => tapped = true),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Go to the pairing screen'),
          findsOneWidget,
        );

        final CupidIcon icon = tester.widget<CupidIcon>(
          find.byType(CupidIcon),
        );
        // link_off, not lock/fingerprint (`architecture/solution.md` §5 D-1).
        expect(icon.icon.codePoint, 0xe16f);

        await tester.tap(find.text('Pair up now'));
        expect(tapped, isTrue);
      },
    );
  });
}
