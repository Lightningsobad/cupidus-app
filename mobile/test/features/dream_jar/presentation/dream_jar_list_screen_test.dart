import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/dream_jar_unpaired_notice.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `dream_jar_list_cubit_test.dart`'s fake — kept local to this
/// file per this repo's existing per-file fake convention
/// (`test/features/auth/presentation/*_test.dart`).
class _FakeDreamJarRepository extends DreamJarRepository {
  _FakeDreamJarRepository(
    this._fetchJars, {
    this.contributions = const <Contribution>[],
  }) : super(CupidApiClient.create());

  final Future<List<DreamJar>> Function() _fetchJars;
  final List<Contribution> contributions;

  @override
  Future<List<DreamJar>> fetchJars({int limit = 50, int offset = 0}) =>
      _fetchJars();

  /// Backs both the single-jar bypass and the tap-to-navigate cases: both
  /// push a `DreamJarDetailScreen`, whose cubit calls `fetchJar` directly
  /// rather than reusing the list already fetched above.
  @override
  Future<DreamJar> fetchJar(String id) async {
    final jars = await _fetchJars();
    return jars.firstWhere((jar) => jar.id == id);
  }

  /// The detail screen loads contributions for its comparison card; stub it so
  /// these list-navigation tests never reach the real `CupidApiClient`.
  @override
  Future<List<Contribution>> fetchContributions(
    String jarId, {
    int limit = 50,
    int offset = 0,
  }) async => contributions;
}

Contribution _contribution({
  required String id,
  required String userId,
  required num amount,
}) => Contribution(
  id: id,
  dreamJarId: 'jar-1',
  userId: userId,
  amount: amount,
  note: null,
  createdAt: DateTime(2026, 1, 1),
);

DreamJar _jar({
  String id = 'jar-1',
  String name = 'Trip to Da Lat',
  num targetAmount = 1000000,
  num currentAmount = 200000,
  DreamJarStatus status = DreamJarStatus.active,
  DateTime? deadline,
}) => DreamJar(
  id: id,
  name: name,
  targetAmount: targetAmount,
  currentAmount: currentAmount,
  deadline: deadline,
  currency: 'VND',
  status: status,
  serverProgress: null,
  createdAt: DateTime(2026, 1, 1),
);

Widget _harness(DreamJarRepository repository) {
  return MediaQuery(
    // The detail screen's jar illustration animates indefinitely; disable
    // motion so `pumpAndSettle` can complete (same precedent as
    // `pet_screen_test.dart`).
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('en'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: DreamJarListScreen(repository: repository),
    ),
  );
}

void main() {
  // `DreamJarListScreen` resolves the signed-in id from the composition root
  // (`HomeScreen` has none to thread), so registering the real store here
  // exercises the production wiring rather than an injected test id.
  setUp(() {
    getIt.registerSingleton<BackendUserIdStore>(
      BackendUserIdStore()
        ..updateFromLoginResponse(<String, Object?>{'id': 'me'}),
    );
  });

  tearDown(getIt.reset);

  testWidgets('shows the empty state when there are no jars', (tester) async {
    final repository = _FakeDreamJarRepository(() async => <DreamJar>[]);

    await tester.pumpWidget(_harness(repository));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Start saving toward something together'),
      findsOneWidget,
    );
    expect(find.text('New jar'), findsOneWidget);
  });

  testWidgets(
    'shows the empty state when every jar is archived (archived jars never appear)',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[_jar(status: DreamJarStatus.archived)],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Start saving toward something together'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows jar card in list screen when one jar exists and navigates to detail on tap',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[_jar(name: 'Trip to Da Lat')],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(find.text('Trip to Da Lat'), findsOneWidget);
      expect(find.text('New jar'), findsOneWidget);

      await tester.tap(find.text('Trip to Da Lat'));
      await tester.pumpAndSettle();

      expect(find.byType(DreamJarDetailScreen), findsOneWidget);
    },
  );

  testWidgets(
    'jar card tap attributes the comparison card to the signed-in user',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1', name: 'Trip to Da Lat'),
          _jar(id: 'jar-2', name: 'New Bike'),
        ],
        contributions: <Contribution>[
          _contribution(id: 'c1', userId: 'me', amount: 2180000),
          _contribution(id: 'c2', userId: 'partner', amount: 1720000),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('New Bike'));
      await tester.pumpAndSettle();

      expect(find.text('2,18tr'), findsOneWidget);
      expect(find.text('1,72tr'), findsOneWidget);
      expect(find.text("You're 460.000₫ ahead"), findsOneWidget);
    },
  );

  testWidgets(
    'empty state carries no header add action, only the body CTA (AC1)',
    (tester) async {
      final repository = _FakeDreamJarRepository(() async => <DreamJar>[]);

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CupidAddAction), findsNothing);
      expect(find.text('New jar'), findsOneWidget);
    },
  );

  testWidgets(
    'ready state carries no header add action, only the body CTA (AC1)',
    (tester) async {
      // Two jars: a lone active jar with no completed jars takes the
      // detail-screen bypass and never renders the list header.
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1', name: 'Trip to Da Lat'),
          _jar(id: 'jar-2', name: 'New Bike'),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CupidAddAction), findsNothing);
      expect(find.text('New jar'), findsOneWidget);
    },
  );

  testWidgets(
    'summary pill totals and counts the active jars only (STORY-061 AC1)',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1', name: 'Trip to Da Lat', currentAmount: 3900000),
          _jar(id: 'jar-2', name: 'New Bike', currentAmount: 2400000),
          _jar(
            id: 'jar-3',
            name: 'Rings',
            currentAmount: 850000,
            status: DreamJarStatus.completed,
          ),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(
        find.text("Together you're saving 6.300.000₫ across 2 jars"),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'each card renders its deadline zero-padded, and none when the jar has '
    'no deadline (STORY-061 AC3)',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(
            id: 'jar-1',
            name: 'Trip to Da Lat',
            deadline: DateTime(2026, 9, 30),
          ),
          _jar(id: 'jar-2', name: 'New Bike', deadline: DateTime(2027, 6, 1)),
          _jar(id: 'jar-3', name: 'Rings'),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(find.text('30/09/2026'), findsOneWidget);
      expect(find.text('01/06/2027'), findsOneWidget);
    },
  );

  testWidgets(
    'only the first card carries the currently-viewing badge (STORY-061 AC4)',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1', name: 'Trip to Da Lat'),
          _jar(id: 'jar-2', name: 'New Bike'),
          _jar(id: 'jar-3', name: 'Rings'),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(find.text('Viewing'), findsOneWidget);
    },
  );

  testWidgets(
    'completed jars render in their own row, not as cards (STORY-061 AC5)',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1', name: 'Trip to Da Lat'),
          _jar(id: 'jar-2', name: 'New Bike', status: DreamJarStatus.completed),
          _jar(id: 'jar-3', name: 'Rings', status: DreamJarStatus.completed),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      // The bypass must not fire on one active jar plus completed ones.
      expect(find.byType(DreamJarDetailScreen), findsNothing);
      expect(find.text('Completed jars'), findsOneWidget);
      expect(find.text('2 · New Bike, Rings'), findsOneWidget);
    },
  );

  testWidgets(
    'no completed-jars row when every jar is active (STORY-061 AC5)',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1', name: 'Trip to Da Lat'),
          _jar(id: 'jar-2', name: 'New Bike'),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(find.text('Completed jars'), findsNothing);
    },
  );

  testWidgets(
    'title and CTA copy match the design reference (STORY-061 AC6/AC7)',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1', name: 'Trip to Da Lat'),
          _jar(id: 'jar-2', name: 'New Bike'),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(find.text('Dream jars'), findsOneWidget);
      expect(find.text('New jar'), findsOneWidget);
      // AC7's "+" is CupidPrimaryButton's leading glyph, never a character in
      // the label string.
      expect(find.byIcon(CupidIcons.add), findsOneWidget);
    },
  );

  testWidgets('shows the unpaired notice (AC3)', (tester) async {
    final repository = _FakeDreamJarRepository(
      () async =>
          throw const DreamJarUnpairedFailure('User not found or not paired'),
    );

    await tester.pumpWidget(_harness(repository));
    await tester.pump();
    await tester.pump();

    expect(find.byType(DreamJarUnpairedNotice), findsOneWidget);
  });
}
