import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart'
    as repo;
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart'
    as domain;
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
(db.CupidDatabase, repo.TimelineRepository) _buildRepository() {
  final db.CupidDatabase database = db.CupidDatabase(NativeDatabase.memory());
  final repo.TimelineRepository repository = repo.TimelineRepository(
    database.timelineDao,
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

/// Since REQ-016 STORY-001 P4 an unpaired session renders the solo card hub,
/// so that case needs a card repository. This one is empty and never writes:
/// the assertion here is still only about the timeline entry point.
class _EmptyActivityCardRepository implements ActivityCardRepository {
  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async => const <ActivityCard>[];

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => Stream<List<ActivityCard>>.value(const <ActivityCard>[]);

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async =>
      const <ActivityCardStatus, int>{};

  @override
  Future<ActivityCard?> cardById(String id) async => null;

  @override
  Future<int> deleteCard(String id) async => 0;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw StateError('not exercised in this test');

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) =>
      throw StateError('not exercised in this test');

  @override
  Future<int> clearScheduledDate(String cardId) =>
      throw StateError('not exercised in this test');

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) =>
      throw StateError('not exercised in this test');
}

Widget _harness({
  required Future<PairingStatus> Function() resolvePairingStatus,
  required TimelineCubit Function() createTimelineCubit,
  ActivityCardRepository? activityCardRepository,
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
      activityCardRepository: activityCardRepository,
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

      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
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
    expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
  });

  testWidgets('unpaired: the entry-point card is absent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        resolvePairingStatus: () async => PairingStatus.unpaired,
        createTimelineCubit: () =>
            throw StateError('not exercised in this test'),
        activityCardRepository: _EmptyActivityCardRepository(),
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
      final (db.CupidDatabase database, repo.TimelineRepository repository) =
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

      // The card sits below several other additive entry cards inside the
      // home screen's scrollable body; scroll it into view before tapping
      // (mirrors real-user behavior, not just a fixed-viewport tap).
      await tester.ensureVisible(find.byType(TimelineEntryPointCard));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TimelineEntryPointCard));
      await tester.pumpAndSettle();

      expect(find.byType(TimelineScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byType(TimelineSkeletonCard), findsNWidgets(5));
    },
  );

  testWidgets('renders latest memory title and date when latestEntry is provided', (
    WidgetTester tester,
  ) async {
    final entry = db.TimelineEntry(
      id: 'entry-1',
      title: 'Đi Đà Lạt cùng nhau 🌲',
      type: 'memory',
      createdAt: DateTime(2026, 2, 14),
      description: 'Chuyến đi đầu tiên',
      photoUrl: null,
      icon: 'flight',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.light,
        ),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: TimelineEntryPointCard(
            onTap: () {},
            latestEntry: domain.TimelineEntry(
              id: entry.id,
              title: entry.title,
              type: domain.TimelineEventType.memory,
              createdAt: entry.createdAt,
              description: entry.description,
              photoUrl: entry.photoUrl,
              icon: entry.icon,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đi Đà Lạt cùng nhau 🌲'), findsOneWidget);
    expect(find.textContaining('14/02/2026'), findsOneWidget);
    expect(find.textContaining('Chuyến đi đầu tiên'), findsOneWidget);
  });
}
