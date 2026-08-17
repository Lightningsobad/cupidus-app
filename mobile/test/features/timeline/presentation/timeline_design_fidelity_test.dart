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
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_countdown_card.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_dashed_border.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'stub_account_repository.dart';

/// Design-fidelity checks for the Love Timeline in the audited configuration
/// (dark theme, `vi` locale) against `Cupid Screens.dc.html` `isTimeline`.
(db.CupidDatabase, repo.TimelineRepository) _buildRepository() {
  final db.CupidDatabase database = db.CupidDatabase(NativeDatabase.memory());
  final repo.TimelineRepository repository = repo.TimelineRepository(
    database.timelineDao,
    TimelineRemoteDataSource(CupidApiClient.create()),
  );
  return (database, repository);
}

class _StubTimelineCubit extends TimelineCubit {
  _StubTimelineCubit(super.repository, {required TimelineState initialState}) {
    emit(initialState);
  }

  @override
  Future<void> load() async {}

  @override
  Future<void> retry() async {}

  @override
  Future<void> createEntry(TimelineDraft draft) async {}
}

final ThemeData _darkTheme = buildCupidTheme(
  platform: CupidPlatform.material,
  brightness: Brightness.dark,
);

CupidColorTokens get _darkColors => _darkTheme.extension<CupidColorTokens>()!;

CupidPlatformTokens get _darkPlatform =>
    _darkTheme.extension<CupidPlatformTokens>()!;

TimelineEntry _entry({
  required String id,
  required String title,
  required DateTime createdAt,
  TimelineEventType type = TimelineEventType.memory,
  String? description,
  String? photoUrl,
  String? icon,
}) {
  return TimelineEntry(
    id: id,
    type: type,
    title: title,
    createdAt: createdAt,
    description: description,
    photoUrl: photoUrl,
    icon: icon,
  );
}

Widget _harness({
  required List<TimelineEntry> entries,
  required repo.TimelineRepository repository,
  DateTime? relationshipStartDate,
}) {
  final _StubTimelineCubit cubit = _StubTimelineCubit(
    repository,
    initialState: TimelineReady(entries, isOffline: false),
  );
  return MaterialApp(
    theme: _darkTheme,
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: TimelineScreen(
      createCubit: () => cubit,
      repository: repository,
      accountRepository: StubAccountRepository(
        relationshipStartDate: relationshipStartDate,
      ),
    ),
  );
}

/// Local noon [daysAgo] days back, derived through UTC date arithmetic so a
/// DST boundary cannot shift the day count the screen derives.
DateTime _daysAgo(int daysAgo) {
  final DateTime now = DateTime.now();
  final DateTime day = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: daysAgo));
  return DateTime(day.year, day.month, day.day, 12);
}

void main() {
  group('TimelineCountdown', () {
    test('derives the design source countdown from the relationship start', () {
      final TimelineCountdown countdown = TimelineCountdown.since(
        DateTime(2025, 11, 25),
        now: DateTime(2026, 7, 29, 9),
      );

      expect(countdown.daysTogether, 247);
      expect(countdown.milestoneDays, 300);
      expect(countdown.daysRemaining, 53);
      expect(countdown.percentComplete, 82);
      expect(countdown.milestoneDate, DateTime(2026, 9, 20));
    });

    test('counts the start day itself as day one', () {
      final TimelineCountdown countdown = TimelineCountdown.since(
        DateTime(2026, 7, 29),
        now: DateTime(2026, 7, 29, 9),
      );

      expect(countdown.daysTogether, 1);
      expect(countdown.milestoneDays, 100);
    });
  });

  testWidgets('countdown card renders the vi headline and progress ring', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);

    await tester.pumpWidget(
      _harness(
        entries: <TimelineEntry>[
          // Deliberately much newer than the relationship start: the card must
          // count from the profile anchor, not from this entry.
          _entry(id: 'a', title: 'Ký Love Contract', createdAt: _daysAgo(12)),
        ],
        repository: repository,
        relationshipStartDate: _daysAgo(246),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Còn 53 ngày'), findsOneWidget);
    expect(find.textContaining('tới mốc 300 ngày · '), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);

    final TimelineProgressRing ring = tester.widget<TimelineProgressRing>(
      find.byType(TimelineProgressRing),
    );
    expect(ring.percentComplete, 82);
  });

  testWidgets('no countdown is shown when the profile has no start date', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);

    await tester.pumpWidget(
      _harness(
        entries: <TimelineEntry>[
          _entry(id: 'a', title: 'Ký Love Contract', createdAt: _daysAgo(246)),
        ],
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TimelineCountdownCard), findsNothing);
    expect(find.byType(TimelineProgressRing), findsNothing);
  });

  testWidgets('entry cards cycle the design source per-entry accent', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);

    await tester.pumpWidget(
      _harness(
        entries: <TimelineEntry>[
          for (int index = 0; index < 5; index++)
            _entry(
              id: 'e$index',
              title: 'Kỷ niệm $index',
              createdAt: _daysAgo(246 - index),
            ),
        ],
        repository: repository,
      ),
    );
    await tester.pump();

    final CupidColorTokens colors = _darkColors;
    final List<Color> expected = <Color>[
      colors.colorAccentPink,
      colors.colorMint,
      colors.colorPeach,
      colors.colorButter,
      colors.colorAccentPurple,
    ];

    for (int index = 0; index < expected.length; index++) {
      final CupidIcon icon = tester.widget<CupidIcon>(
        find
            .descendant(
              of: find.byType(TimelineEntryCard).at(index),
              matching: find.byType(CupidIcon),
            )
            .first,
      );
      expect(icon.color, expected[index], reason: 'row $index leading icon');
      expect(icon.size, 18);
    }
  });

  testWidgets('the connector dot keeps the design fill inside its ring', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);

    await tester.pumpWidget(
      _harness(
        entries: <TimelineEntry>[
          _entry(id: 'a', title: 'Mốc 200 ngày', createdAt: _daysAgo(246)),
        ],
        repository: repository,
      ),
    );
    await tester.pump();

    final Finder dot = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
    );
    expect(dot, findsOneWidget);

    final BoxDecoration decoration =
        tester.widget<Container>(dot).decoration! as BoxDecoration;
    final BorderSide ring = (decoration.border! as Border).top;
    expect(ring.width, 3);
    expect(ring.color, _darkColors.colorBackground);

    // The design source's `width:16px;height:16px;border:3px` is content-box,
    // so the ring grows the box to 22 and the coloured fill stays 16 --
    // Flutter's inside-painted border would otherwise leave a 10px fill.
    final Size size = tester.getSize(dot);
    expect(size, const Size(22, 22));
    expect(size.width - ring.width * 2, 16);
    // `left:-26px` places the box, not the fill: 16 (screen padding) + 11.
    expect(tester.getCenter(dot).dx, 27);
  });

  testWidgets('entry card matches the design card box and date format', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);

    await tester.pumpWidget(
      _harness(
        entries: <TimelineEntry>[
          _entry(
            id: 'a',
            title: 'Mốc 200 ngày',
            createdAt: DateTime(2026, 1, 18, 12),
          ),
        ],
        repository: repository,
      ),
    );
    await tester.pump();

    expect(find.text('18/01/26'), findsOneWidget);

    final Container card = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TimelineEntryCard),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      card.padding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );

    final BoxDecoration decoration = card.decoration! as BoxDecoration;
    expect(decoration.color, _darkColors.colorSurface);
    expect(decoration.boxShadow, _darkPlatform.elevationShadow);
  });

  testWidgets('scroll padding matches the design container box', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);

    await tester.pumpWidget(
      _harness(
        entries: <TimelineEntry>[
          _entry(id: 'a', title: 'Mốc 200 ngày', createdAt: _daysAgo(246)),
        ],
        repository: repository,
      ),
    );
    await tester.pump();

    final ListView list = tester.widget<ListView>(find.byType(ListView));
    expect(list.padding, const EdgeInsets.fromLTRB(16, 10, 16, 40));
  });

  testWidgets('an unreachable photo renders the image-slot placeholder', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);

    await tester.pumpWidget(
      _harness(
        entries: <TimelineEntry>[
          _entry(
            id: 'a',
            title: 'Cãi nhau lần đầu, sống sót',
            createdAt: _daysAgo(246),
            photoUrl: 'https://example.invalid/photo.jpg',
          ),
        ],
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TimelinePhotoPlaceholder), findsOneWidget);
    expect(find.text('Ảnh kỷ niệm'), findsOneWidget);
  });

  testWidgets('the add-memory pill uses the design line border', (
    WidgetTester tester,
  ) async {
    final (db.CupidDatabase database, repo.TimelineRepository repository) =
        _buildRepository();
    addTearDown(database.close);

    await tester.pumpWidget(
      _harness(
        entries: <TimelineEntry>[
          _entry(id: 'a', title: 'Mốc 200 ngày', createdAt: _daysAgo(246)),
        ],
        repository: repository,
      ),
    );
    await tester.pump();

    final TimelineDashedBorder border = tester.widget<TimelineDashedBorder>(
      find.byType(TimelineDashedBorder),
    );
    expect(border.color, _darkColors.colorLine);
    expect(border.radius, _darkPlatform.radiusButton);
  });
}
