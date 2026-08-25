import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_api.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_local_cache.dart';
import 'package:cupid_mobile/features/gallery/data/gallery_repository.dart';
import 'package:cupid_mobile/features/gallery/domain/gallery_item.dart';
import 'package:cupid_mobile/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_preview_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../pet/presentation/fake_pet_repository.dart';

/// Never issues a real HTTP call: this file's tests only assert the
/// navigation edge, not `DreamJarListScreen`'s own data loading (already
/// covered by that screen's own tests).
class _NoOpDreamJarRepository extends DreamJarRepository {
  _NoOpDreamJarRepository() : super(CupidApiClient.create());

  @override
  Future<List<DreamJar>> fetchJars({int limit = 50, int offset = 0}) async =>
      <DreamJar>[];
}

/// Same contract as [_NoOpDreamJarRepository]: the Gallery test asserts the
/// navigation edge only, so no read may reach the network.
class _NoOpGalleryRepository extends GalleryRepository {
  _NoOpGalleryRepository()
    : super(
        api: GalleryApi(api: CupidApiClient.create()),
        cache: GalleryLocalCache(),
      );

  @override
  Future<GalleryPage> fetchPage({int limit = 30, int offset = 0}) async =>
      const GalleryPage(items: <GalleryItem>[], isStale: false);

  @override
  Future<GalleryPage> cachedPage() async =>
      const GalleryPage(items: <GalleryItem>[], isStale: true);

  @override
  Future<GalleryMe> currentUser() async => const GalleryMe(id: 'u1');
}

/// Fixed clock so the derived day count and milestone copy stay deterministic.
final DateTime _startDate = DateTime.now().subtract(const Duration(days: 247));

CupidProfile _pairedProfile({String? coupleType = 'SAME_CITY'}) =>
    CupidProfile(
      id: 'u1',
      email: 'minh@example.com',
      language: 'vi',
      vowTaken: true,
      isGhostModeEnabled: false,
      displayName: 'Minh',
      relationshipStartDate: _startDate,
      partnerId: 'u2',
      coupleType: coupleType,
    );

Widget _host(
  Widget home, {
  CupidPlatform platform = CupidPlatform.material,
  Locale locale = const Locale('vi'),
}) => MaterialApp(
  theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
  locale: locale,
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  // `buildCupidTheme` only picks the token set; `CupidPlatform.of` reads this
  // override (or `defaultTargetPlatform`), so the glyph branch needs it.
  home: CupidPlatformOverride(platform: platform, child: home),
);

/// `share_plus` 13.3.0 reaches the OS sheet through this channel and method
/// (read from the resolved `share_plus_platform_interface-7.2.0`
/// `method_channel/method_channel_share.dart` in the pub cache, not from
/// memory). Mocking it lets the tap test assert the exact composed payload.
const MethodChannel _shareChannel = MethodChannel(
  'dev.fluttercommunity.plus/share',
);

/// Captures every `share` invocation's arguments and answers `''`, which the
/// plugin maps to `ShareResultStatus.dismissed` — the AC3 path.
List<Map<Object?, Object?>> _captureShareCalls(WidgetTester tester) {
  final List<Map<Object?, Object?>> calls = <Map<Object?, Object?>>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _shareChannel,
    (MethodCall call) async {
      expect(call.method, 'share');
      calls.add(call.arguments as Map<Object?, Object?>);
      return '';
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _shareChannel,
      null,
    ),
  );
  return calls;
}

void main() {
  setUp(() {
    getIt.registerLazySingleton<DreamJarRepository>(
      _NoOpDreamJarRepository.new,
    );
    // `DreamJarListScreen` reads the signed-in id from the composition root,
    // which `service_locator.dart` registers but this test bypasses.
    getIt.registerLazySingleton<BackendUserIdStore>(BackendUserIdStore.new);
  });

  tearDown(() => getIt.reset());

  testWidgets(
    'HomeScreen renders the Dream Jar card; the readiness signal keeps '
    'pumping and tapping the card pushes DreamJarListScreen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCupidTheme(
            platform: CupidPlatform.material,
            brightness: Brightness.dark,
          ),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          // Overrides the default `getIt<CouplePairingStore>()` lookup: this
          // test only exercises the Dream Jar entry card, so it never
          // registers a CouplePairingStore and must not depend on one.
          home: HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
          ),
        ),
      );

      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
      expect(
        find.byKey(const Key('home_dream_jar_entry_card')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('home_dream_jar_entry_card')));
      await tester.pumpAndSettle();

      expect(find.byType(DreamJarListScreen), findsOneWidget);
    },
  );

  testWidgets(
    'AC1/AC5: the dashboard paints no AppBar (design source lists `home` in '
    'NO_CHROME) and adds no navigation entry point beyond the existing cards',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AppBar), findsNothing);
      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
      expect(
        find.byKey(const Key('home_dream_jar_entry_card')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'AC1: the couple-presence signal renders both avatar discs, the couple '
    'name and the couple-type label',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        ),
      );
      await tester.pump();

      final Finder hero = find.byKey(const Key('home_couple_hero'));
      expect(hero, findsOneWidget);
      expect(find.descendant(of: hero, matching: find.text('Minh')), findsOne);
      expect(
        find.descendant(of: hero, matching: find.text('Cùng thành phố')),
        findsOne,
      );
      // Self avatar carries the display-name initial; the partner disc has no
      // initial because `GET /users/me` exposes no partner display name.
      expect(find.descendant(of: hero, matching: find.text('M')), findsOne);
    },
  );

  testWidgets(
    'AC3: the days counter uses the §2 Display role (Nunito 900, 34pt) and is '
    'painted with the Dream Gradient',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        ),
      );
      await tester.pump();

      final Finder counter = find.byKey(const Key('home_days_counter'));
      expect(counter, findsOneWidget);

      final ShaderMask mask = tester.widget<ShaderMask>(counter);
      expect(mask.blendMode, BlendMode.srcIn);

      final Text count = tester.widget<Text>(
        find.descendant(of: counter, matching: find.text('247')),
      );
      expect(count.style?.fontFamily, 'Nunito');
      expect(count.style?.fontWeight, FontWeight.w900);
      expect(count.style?.fontSize, 34);

      expect(find.text('ngày bên nhau'), findsOne);
    },
  );

  testWidgets(
    'AC1: the next-milestone pill counts down to the next 100-day mark',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.textContaining('nữa tới mốc 300', findRichText: true),
        findsOne,
      );
      expect(find.textContaining('53 ngày', findRichText: true), findsOne);
    },
  );

  testWidgets(
    'The hero degrades instead of inventing data: no start date means no days '
    'counter, and an unlabelled couple type prints no label line',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => const CupidProfile(
              id: 'u1',
              email: 'minh@example.com',
              language: 'vi',
              vowTaken: false,
              isGhostModeEnabled: false,
              displayName: 'Minh',
              coupleType: 'DATING',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('home_couple_hero')), findsOneWidget);
      expect(find.byKey(const Key('home_days_counter')), findsNothing);
      expect(find.text('Cùng thành phố'), findsNothing);
      expect(find.text('Yêu xa'), findsNothing);
    },
  );

  testWidgets(
    'An unresolved profile hides the hero without blocking the entry cards',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () => Future<CupidProfile>.error(
              StateError('AccountRepository unavailable'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('home_couple_hero')), findsNothing);
      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
    },
  );

  // STORY-061 P2 / PO Decision 1: the design's 5-tab shell has no Gallery
  // slot, so this card is now `GalleryScreen`'s only production entry point.
  // Asserted by test, not by inspection, precisely because losing it would
  // orphan a shipped feature silently.
  testWidgets(
    'STORY-061: the Gallery entry card is present and pushes GalleryScreen',
    (WidgetTester tester) async {
      getIt.registerLazySingleton<GalleryRepository>(
        _NoOpGalleryRepository.new,
      );

      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        ),
      );
      await tester.pump();

      final Finder card = find.byKey(const Key('home_gallery_entry_card'));
      expect(card, findsOneWidget);

      await tester.ensureVisible(card);
      await tester.pump();
      await tester.tap(card);
      await tester.pump();
      // Let the push transition run out; not `pumpAndSettle`, because the
      // gallery cubit's own load is not what this navigation edge asserts.
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(GalleryScreen), findsOneWidget);
    },
  );

  // STORY-004: the share icon is its own entry point, so it is asserted on the
  // Home screen as actually rendered, not on an isolated widget.
  testWidgets(
    'STORY-004 AC1: the header share action renders in the hero header with '
    'the §1 tokens and the Material `share` glyph',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        ),
      );
      await tester.pump();

      final Finder action = find.byKey(const Key('home_header_share_action'));
      expect(action, findsOneWidget);
      expect(
        find.ancestor(
          of: action,
          matching: find.byKey(const Key('home_couple_hero')),
        ),
        findsOneWidget,
      );

      final Icon glyph = tester.widget<Icon>(
        find.descendant(of: action, matching: find.byType(Icon)),
      );
      expect(glyph.icon, CupidIcons.share);
      expect(glyph.size, 23);
      expect(glyph.fill, 0);
      expect(glyph.color, const Color(0xFFB4A6CE));

      final SizedBox box = tester.widget<SizedBox>(
        find.descendant(of: action, matching: find.byType(SizedBox)).first,
      );
      expect(box.width, 48);
      expect(box.height, 38);
    },
  );

  testWidgets(
    'STORY-004 AC1: the iOS platform branch renders the `ios_share` glyph',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
          platform: CupidPlatform.ios,
        ),
      );
      await tester.pump();

      final Icon glyph = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('home_header_share_action')),
          matching: find.byType(Icon),
        ),
      );
      expect(glyph.icon, CupidIcons.iosShare);
    },
  );

  testWidgets(
    'STORY-004 AC1: _PresenceRow keeps its leading position once the actions '
    'row is added',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        ),
      );
      await tester.pump();

      final double nameLeft = tester.getTopLeft(find.text('Minh')).dx;
      final double shareLeft = tester
          .getTopLeft(find.byKey(const Key('home_header_share_action')))
          .dx;
      expect(nameLeft, lessThan(shareLeft));
    },
  );

  testWidgets(
    'STORY-004 AC2: tapping the share action opens the OS share sheet with '
    'the §2 `vi` payload for the displayed day count',
    (WidgetTester tester) async {
      final List<Map<Object?, Object?>> calls = _captureShareCalls(tester);

      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('home_header_share_action')));
      await tester.pump();

      expect(calls, hasLength(1));
      expect(calls.single['text'], '247 ngày bên nhau rồi 💕');
      expect(calls.single['subject'], isNull);
      expect(calls.single['uri'], isNull);
      expect(calls.single['paths'], isNull);
    },
  );

  testWidgets(
    'STORY-004 AC2: the payload follows the active locale',
    (WidgetTester tester) async {
      final List<Map<Object?, Object?>> calls = _captureShareCalls(tester);

      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('home_header_share_action')));
      await tester.pump();

      expect(calls.single['text'], '247 days together 💕');
    },
  );

  // AC3: `''` is what the plugin returns for a dismissed sheet. Nothing may
  // hang off that outcome, so the assertion is that the screen keeps rendering
  // unchanged and the test raises no error.
  testWidgets(
    'STORY-004 AC3: dismissing the share sheet surfaces no error or snackbar',
    (WidgetTester tester) async {
      _captureShareCalls(tester);

      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => _pairedProfile(),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('home_header_share_action')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
      expect(find.byKey(const Key('home_days_counter')), findsOneWidget);
      expect(
        find.byKey(const Key('home_header_share_action')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'STORY-004: no start date means nothing to share, so the header share '
    'action does not render',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          HomeScreen(
            resolvePairingStatus: () async => PairingStatus.unknown,
            resolveProfile: () async => const CupidProfile(
              id: 'u1',
              email: 'minh@example.com',
              language: 'vi',
              vowTaken: false,
              isGhostModeEnabled: false,
              displayName: 'Minh',
              coupleType: 'DATING',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('home_couple_hero')), findsOneWidget);
      expect(find.byKey(const Key('home_header_share_action')), findsNothing);
    },
  );

  // STORY-003 (REQ-010): `HomeScreen.petRepository` exists only so the
  // design-fidelity capture harness can photograph the card's real `PetReady`
  // state instead of the `PetFailure` an unauthenticated session produces.
  group('STORY-003: the pet preview fixture seam', () {
    testWidgets('the default HomeScreen passes no repository override', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(HomeScreen(resolvePairingStatus: () async => PairingStatus.unknown)),
      );
      await tester.pump();

      final PetPreviewCard card = tester.widget<PetPreviewCard>(
        find.byType(PetPreviewCard),
      );
      // Null here is what keeps production on the card's own
      // `getIt<PetRepository>()` lookup.
      expect(card.repository, isNull);
    });

    testWidgets('an injected repository reaches the card and renders it ready', (
      WidgetTester tester,
    ) async {
      final FakePetRepository repository = FakePetRepository()
        ..paired = true
        ..status = PetStatus(
          pet: Pet(
            id: 'pet-1',
            coupleId: 'couple-1',
            species: PetSpecies.bunny,
            name: 'Bún',
            happiness: 62,
            level: 3,
            totalInteractions: 131,
            lastInteraction: null,
          ),
          mood: PetMood.content,
          decayedHappiness: 62,
          milestone: null,
          nextMilestone: 150,
        );

      await tester.pumpWidget(
        MediaQuery(
          // BunSprite bobs indefinitely once the ready variant renders.
          data: const MediaQueryData(disableAnimations: true),
          child: _host(
            HomeScreen(
              resolvePairingStatus: () async => PairingStatus.unknown,
              resolveProfile: () async => _pairedProfile(),
              petRepository: repository,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<PetPreviewCard>(find.byType(PetPreviewCard)).repository,
        same(repository),
      );
      expect(find.text('Lv.3'), findsOneWidget);
    });
  });
}
