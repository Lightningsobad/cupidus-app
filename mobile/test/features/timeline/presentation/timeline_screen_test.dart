import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart'
    as repo;
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';
import 'package:cupid_mobile/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_state.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_card.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_skeleton.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'stub_account_repository.dart';

/// A cheap-but-real, never-invoked [repo.TimelineRepository] to satisfy
/// [TimelineCubit]'s constructor. Matches the `timeline_cubit_test.dart`
/// construction pattern; every method that would use it is overridden below
/// as a no-op, so no local write or network call is ever attempted.
(db.CupidDatabase, repo.TimelineRepository) _buildRepository() {
  final db.CupidDatabase database = db.CupidDatabase(NativeDatabase.memory());
  final repo.TimelineRepository repository = repo.TimelineRepository(
    database.timelineDao,
    TimelineRemoteDataSource(CupidApiClient.create()),
  );
  return (database, repository);
}

/// Directly emits arbitrary [TimelineState]s for widget-test setup without
/// exercising the real load/refresh pipeline (no `bloc_test` dependency is
/// declared in `pubspec.yaml`, so this hand-rolled subclass calling the
/// protected `emit` is the established pattern for this codebase).
class _StubTimelineCubit extends TimelineCubit {
  _StubTimelineCubit(super.repository, {required TimelineState initialState}) {
    emit(initialState);
  }

  int retryCalls = 0;

  @override
  Future<void> load() async {}

  @override
  Future<void> retry() async {
    retryCalls++;
  }

  @override
  Future<void> createEntry(TimelineDraft draft) async {}
}

TimelineEntry _entry({
  String id = 'ev-1',
  TimelineEventType type = TimelineEventType.memory,
  String title = 'First date',
  DateTime? createdAt,
  String? description,
  String? photoUrl,
  String? icon,
}) {
  return TimelineEntry(
    id: id,
    type: type,
    title: title,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 1),
    description: description,
    photoUrl: photoUrl,
    icon: icon,
  );
}

Widget _harness({
  required TimelineState initialState,
  required repo.TimelineRepository repository,
  required void Function(AppL10n l10n, _StubTimelineCubit cubit) onReady,
}) {
  final _StubTimelineCubit cubit = _StubTimelineCubit(
    repository,
    initialState: initialState,
  );
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    ),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Builder(
      builder: (BuildContext context) {
        onReady(AppL10n.of(context), cubit);
        return TimelineScreen(
          createCubit: () => cubit,
          repository: repository,
          // No relationship start date, so these state-surface cases render
          // without the countdown hero. `timeline_design_fidelity_test.dart`
          // covers the countdown itself.
          accountRepository: StubAccountRepository(),
        );
      },
    ),
  );
}

void main() {
  testWidgets('loading renders exactly 5 skeleton cards', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);

    await tester.pumpWidget(
      _harness(
        initialState: const TimelineLoading(),
        repository: repository,
        onReady: (_, _) {},
      ),
    );
    await tester.pump();

    expect(find.byType(TimelineSkeletonCard), findsNWidgets(5));
  });

  testWidgets('ready(isOffline: false) renders entries with no offline banner', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);
    late AppL10n l10n;

    await tester.pumpWidget(
      _harness(
        initialState: TimelineReady(
          <TimelineEntry>[_entry(title: 'First date')],
          isOffline: false,
        ),
        repository: repository,
        onReady: (AppL10n value, _) => l10n = value,
      ),
    );
    await tester.pump();

    expect(find.text('First date'), findsOneWidget);
    expect(find.text(l10n.timeline_offline_banner), findsNothing);
    expect(find.text(l10n.timeline_empty_heading), findsNothing);
  });

  testWidgets(
    'ready(isOffline: true) renders entries and the offline banner, never '
    'the empty-state copy',
    (WidgetTester tester) async {
      final (db.CupidDatabase database, repo.TimelineRepository repository) =
          _buildRepository();
      addTearDown(database.close);
      late AppL10n l10n;

      await tester.pumpWidget(
        _harness(
          initialState: TimelineReady(
            <TimelineEntry>[_entry(title: 'Cached memory')],
            isOffline: true,
          ),
          repository: repository,
          onReady: (AppL10n value, _) => l10n = value,
        ),
      );
      await tester.pump();

      expect(find.text('Cached memory'), findsOneWidget);
      expect(find.text(l10n.timeline_offline_banner), findsOneWidget);
      expect(find.text(l10n.timeline_empty_heading), findsNothing);
    },
  );

  testWidgets('empty renders heading, body and the add-memory affordance', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);
    late AppL10n l10n;

    await tester.pumpWidget(
      _harness(
        initialState: const TimelineEmpty(),
        repository: repository,
        onReady: (AppL10n value, _) => l10n = value,
      ),
    );
    await tester.pump();

    expect(find.text(l10n.timeline_empty_heading), findsOneWidget);
    expect(find.text(l10n.timeline_empty_body), findsOneWidget);
    expect(find.text(l10n.timeline_add_memory_cta), findsOneWidget);
    expect(find.text(l10n.timeline_offline_banner), findsNothing);
  });

  testWidgets(
    'tapping Add a memory on the empty state opens the create-memory sheet',
    (WidgetTester tester) async {
      final (db.CupidDatabase database, repo.TimelineRepository repository) =
          _buildRepository();
      addTearDown(database.close);
      late AppL10n l10n;

      await tester.pumpWidget(
        _harness(
          initialState: const TimelineEmpty(),
          repository: repository,
          onReady: (AppL10n value, _) => l10n = value,
        ),
      );
      await tester.pump();

      await tester.tap(find.text(l10n.timeline_add_memory_cta));
      await tester.pumpAndSettle();

      expect(find.text(l10n.timeline_sheet_field_title_label), findsOneWidget);
      expect(find.text(l10n.timeline_sheet_save_label), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Add a memory on the ready state opens the create-memory sheet',
    (WidgetTester tester) async {
      final (db.CupidDatabase database, repo.TimelineRepository repository) =
          _buildRepository();
      addTearDown(database.close);
      late AppL10n l10n;

      await tester.pumpWidget(
        _harness(
          initialState: TimelineReady(
            <TimelineEntry>[_entry(title: 'First date')],
            isOffline: false,
          ),
          repository: repository,
          onReady: (AppL10n value, _) => l10n = value,
        ),
      );
      await tester.pump();

      await tester.tap(find.text(l10n.timeline_add_memory_cta));
      await tester.pumpAndSettle();

      expect(find.text(l10n.timeline_sheet_field_title_label), findsOneWidget);
    },
  );

  testWidgets(
    'offlineNoCache renders a surface distinct from empty, with retry',
    (WidgetTester tester) async {
      final (db.CupidDatabase database, repo.TimelineRepository repository) =
          _buildRepository();
      addTearDown(database.close);
      late AppL10n l10n;
      late _StubTimelineCubit cubit;

      await tester.pumpWidget(
        _harness(
          initialState: const TimelineOfflineNoCache(),
          repository: repository,
          onReady: (AppL10n value, _StubTimelineCubit stub) {
            l10n = value;
            cubit = stub;
          },
        ),
      );
      await tester.pump();

      expect(find.text(l10n.timeline_offline_no_cache_heading), findsOneWidget);
      expect(find.text(l10n.timeline_offline_no_cache_body), findsOneWidget);
      expect(find.text(l10n.timeline_empty_heading), findsNothing);
      expect(find.text(l10n.timeline_empty_body), findsNothing);

      await tester.tap(find.text(l10n.timeline_error_retry_label));
      await tester.pump();
      expect(cubit.retryCalls, 1);
    },
  );

  testWidgets('error renders heading, body and a working retry action', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);
    late AppL10n l10n;
    late _StubTimelineCubit cubit;

    await tester.pumpWidget(
      _harness(
        initialState: const TimelineError(NetworkUnavailableFailure()),
        repository: repository,
        onReady: (AppL10n value, _StubTimelineCubit stub) {
          l10n = value;
          cubit = stub;
        },
      ),
    );
    await tester.pump();

    expect(find.text(l10n.timeline_error_heading), findsOneWidget);
    expect(find.text(l10n.timeline_error_body), findsOneWidget);

    await tester.tap(find.text(l10n.timeline_error_retry_label));
    await tester.pump();
    expect(cubit.retryCalls, 1);
  });

  testWidgets(
    'an auto-generated entry shows the auto-added pill and no delete '
    'affordance',
    (WidgetTester tester) async {
      final (db.CupidDatabase database, repo.TimelineRepository repository) =
          _buildRepository();
      addTearDown(database.close);
      late AppL10n l10n;

      await tester.pumpWidget(
        _harness(
          initialState: TimelineReady(
            <TimelineEntry>[
              _entry(type: TimelineEventType.milestone, title: 'One year!'),
            ],
            isOffline: false,
          ),
          repository: repository,
          onReady: (AppL10n value, _) => l10n = value,
        ),
      );
      await tester.pump();

      expect(find.text(l10n.timeline_auto_added_pill), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byTooltip('Delete'), findsNothing);
    },
  );

  testWidgets(
    'an unreachable photoUrl falls back to a placeholder without throwing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCupidTheme(
            platform: CupidPlatform.material,
            brightness: Brightness.light,
          ),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Scaffold(
            body: TimelineEntryCard(
              entry: _entry(photoUrl: 'https://example.invalid/photo.jpg'),
            ),
          ),
        ),
      );
      await tester.pump();

      final Image image = tester.widget<Image>(find.byType(Image));
      expect(image.errorBuilder, isNotNull);

      // Exercises the exact fallback path a real DNS/connection failure
      // would trigger, without making a real network call from the test
      // environment (`phase-P5-timeline-screen.md`: "no throw").
      final Widget fallback = image.errorBuilder!(
        tester.element(find.byType(Image)),
        Exception('simulated unreachable host'),
        null,
      );
      expect(fallback, isNotNull);
    },
  );

  group('TimelineGlyphs.symbolFor', () {
    test('resolves a known icon name', () {
      expect(TimelineGlyphs.symbolFor('favorite'), isNotNull);
    });

    test('returns null for an unknown name, including backend emoji defaults', () {
      expect(TimelineGlyphs.symbolFor('💝'), isNull);
      expect(TimelineGlyphs.symbolFor('🏆'), isNull);
      expect(TimelineGlyphs.symbolFor(null), isNull);
      expect(TimelineGlyphs.symbolFor(''), isNull);
    });
  });
}
