import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Never issues a real HTTP call: this file's tests only assert the
/// navigation edge, not `DreamJarListScreen`'s own data loading (already
/// covered by that screen's own tests).
class _NoOpDreamJarRepository extends DreamJarRepository {
  _NoOpDreamJarRepository() : super(CupidApiClient.create());

  @override
  Future<List<DreamJar>> fetchJars({int limit = 50, int offset = 0}) async =>
      <DreamJar>[];
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

Widget _host(Widget home) => MaterialApp(
  theme: buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  ),
  locale: const Locale('vi'),
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  home: home,
);

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
}
