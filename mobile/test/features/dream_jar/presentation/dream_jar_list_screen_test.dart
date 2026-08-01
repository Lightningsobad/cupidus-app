import 'package:cupid_mobile/core/network/cupid_api.dart';
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
  _FakeDreamJarRepository(this._fetchJars) : super(CupidApiClient.create());

  final Future<List<DreamJar>> Function() _fetchJars;

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
}

DreamJar _jar({
  String id = 'jar-1',
  String name = 'Trip to Da Lat',
  num targetAmount = 1000000,
  num currentAmount = 200000,
  DreamJarStatus status = DreamJarStatus.active,
}) => DreamJar(
  id: id,
  name: name,
  targetAmount: targetAmount,
  currentAmount: currentAmount,
  deadline: null,
  currency: 'VND',
  status: status,
  serverProgress: null,
  createdAt: DateTime(2026, 1, 1),
);

Widget _harness(DreamJarRepository repository) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: DreamJarListScreen(repository: repository),
  );
}

void main() {
  testWidgets('shows the empty state when there are no jars', (tester) async {
    final repository = _FakeDreamJarRepository(() async => <DreamJar>[]);

    await tester.pumpWidget(_harness(repository));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Start saving toward something together'),
      findsOneWidget,
    );
    expect(find.text('New Dream Jar'), findsOneWidget);
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
    'skips straight to the jar detail screen when exactly one non-archived jar exists',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[_jar()],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(find.byType(DreamJarDetailScreen), findsOneWidget);
      expect(find.text('+100k'), findsOneWidget);
    },
  );

  testWidgets(
    'shows a card list for 2+ jars and navigates to detail on tap',
    (tester) async {
      final repository = _FakeDreamJarRepository(
        () async => <DreamJar>[
          _jar(id: 'jar-1', name: 'Trip to Da Lat'),
          _jar(
            id: 'jar-2',
            name: 'New Bike',
            currentAmount: 500000,
            targetAmount: 500000,
            status: DreamJarStatus.completed,
          ),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pump();
      await tester.pump();

      expect(find.text('Trip to Da Lat'), findsOneWidget);
      expect(find.text('New Bike'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      await tester.tap(find.text('New Bike'));
      await tester.pumpAndSettle();

      expect(find.byType(DreamJarDetailScreen), findsOneWidget);
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
