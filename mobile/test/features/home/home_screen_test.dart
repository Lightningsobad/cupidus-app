import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
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

void main() {
  setUp(() {
    getIt.registerLazySingleton<DreamJarRepository>(
      _NoOpDreamJarRepository.new,
    );
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
}
