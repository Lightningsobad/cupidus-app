import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/database/app_database.dart' as db;
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart'
    as repo;
import 'package:cupid_mobile/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_point_card.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_skeleton.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A cheap-but-real, never-invoked [repo.TimelineRepository] to satisfy
/// [TimelineCubit]'s constructor (matches `timeline_screen_test.dart`'s
/// construction pattern).
(db.AppDatabase, repo.TimelineRepository) _buildRepository() {
  final db.AppDatabase database = db.AppDatabase(NativeDatabase.memory());
  final repo.TimelineRepository repository = repo.TimelineRepository(
    database,
    TimelineRemoteDataSource(CupidApiClient.create()),
  );
  return (database, repository);
}

/// Leaves the cubit in its default `TimelineLoading` state so a successful
/// push renders the skeleton -- proof the route provided the cubit without a
/// missing-provider error, with no network call attempted.
class _StubTimelineCubit extends TimelineCubit {
  _StubTimelineCubit(super.repository);

  @override
  Future<void> load() async {}
}

Widget _harness({
  required Future<PairingStatus> Function() resolvePairingStatus,
  required TimelineCubit Function() createTimelineCubit,
}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    ),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: HomeScreen(
      resolvePairingStatus: resolvePairingStatus,
      createTimelineCubit: createTimelineCubit,
    ),
  );
}

void main() {
  testWidgets(
    'home_screen_ready_signal pumps immediately, before the pairing status resolves',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _harness(
          resolvePairingStatus: () async => PairingStatus.paired,
          createTimelineCubit: () =>
              throw StateError('not exercised in this test'),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('home_screen_ready_signal')),
        findsOneWidget,
      );
    },
  );

  testWidgets('paired: the entry-point card renders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        resolvePairingStatus: () async => PairingStatus.paired,
        createTimelineCubit: () =>
            throw StateError('not exercised in this test'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TimelineEntryPointCard), findsOneWidget);
    expect(
      find.byKey(const Key('home_screen_ready_signal')),
      findsOneWidget,
    );
  });

  testWidgets('unpaired: the entry-point card is absent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        resolvePairingStatus: () async => PairingStatus.unpaired,
        createTimelineCubit: () =>
            throw StateError('not exercised in this test'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TimelineEntryPointCard), findsNothing);
  });

  testWidgets(
    'unknown (e.g. no connectivity and nothing cached): the entry-point card is absent',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _harness(
          resolvePairingStatus: () async => PairingStatus.unknown,
          createTimelineCubit: () =>
              throw StateError('not exercised in this test'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TimelineEntryPointCard), findsNothing);
    },
  );

  testWidgets(
    'tapping the card pushes TimelineScreen with its cubit available (no missing-provider error)',
    (WidgetTester tester) async {
      final (db.AppDatabase database, repo.TimelineRepository repository) =
          _buildRepository();
      addTearDown(database.close);
      // `TimelineScreen` wraps this cubit in `BlocProvider(create: ...)`,
      // which already closes it on disposal -- an explicit `addTearDown`
      // here would double-close the same `Cubit` and hang.
      final TimelineCubit cubit = _StubTimelineCubit(repository);

      await tester.pumpWidget(
        _harness(
          resolvePairingStatus: () async => PairingStatus.paired,
          createTimelineCubit: () => cubit,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TimelineEntryPointCard));
      await tester.pumpAndSettle();

      expect(find.byType(TimelineScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byType(TimelineSkeletonCard), findsNWidgets(5));
    },
  );
}
