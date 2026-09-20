import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/activity_card_list_cubit.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/activity_status_filter.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// iOS reference viewport, matching the `--platform=ios` render of
/// `render-design-canvas.js` that produced the design frame this strip is
/// compared against.
const Size _iosReferenceViewport = Size(415, 900);

/// Off by default so the ordinary scoped suite stays hermetic. Enable with
/// `flutter test test/features/activity_cards/activity_status_filter_closed_pane_test.dart --dart-define=CAPTURE_VISUALS=true`.
const bool _captureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const String _visualDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-013_graceful_exit_and_return/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

/// The store as the five ordinary panes see it. It holds only open material:
/// the DAO hides closed rows in SQL (`activity_card_dao_closure_filter_test`),
/// so a repository that still returned them would be modelling a bug.
class _OpenCardRepository implements ActivityCardRepository {
  _OpenCardRepository(this._cards);

  final List<ActivityCard> _cards;

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async => _cards
      .where((ActivityCard card) => card.status == status)
      .skip(offset)
      .take(limit)
      .toList(growable: false);

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async* {
    yield await cardsByStatus(status: status, limit: limit, offset: offset);
  }

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async {
    final Map<ActivityCardStatus, int> counts = <ActivityCardStatus, int>{};
    for (final ActivityCard card in _cards) {
      counts[card.status] = (counts[card.status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<ActivityCard?> cardById(String id) async => null;

  @override
  Future<int> deleteCard(String id) async => 0;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw UnimplementedError('not exercised by the closed pane');

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) =>
      throw UnimplementedError('not exercised by the closed pane');

  @override
  Future<int> clearScheduledDate(String cardId) =>
      throw UnimplementedError('not exercised by the closed pane');

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) =>
      throw UnimplementedError('not exercised by the closed pane');
}

/// The archive side of the same store, and a call counter: the five ordinary
/// panes must never reach it.
class _FakeClosedArchive implements ClosedArchiveReader {
  _FakeClosedArchive(this._closed);

  final List<ActivityCard> _closed;
  int closedCardsCalls = 0;

  @override
  Future<bool> hasAnyClosure() async => _closed.isNotEmpty;

  @override
  Future<List<ActivityCard>> closedCards({
    required int limit,
    int offset = 0,
  }) async {
    closedCardsCalls++;
    return _closed.skip(offset).take(limit).toList(growable: false);
  }

  @override
  Future<int> closedCardCount() async => _closed.length;
}

ActivityCard _card(String id, ActivityCardStatus status) {
  final DateTime now = DateTime(2026, 9, 7);
  return ActivityCard(
    id: id,
    ownerKey: 'owner-1',
    title: 'Thẻ $id',
    status: status,
    origin: ActivityCardOrigin.manual,
    invited: false,
    replyState: ActivityCardReplyState.notAnswered,
    createdAt: now,
    updatedAt: now,
  );
}

final List<ActivityCard> _openCards = <ActivityCard>[
  _card('open-idea', ActivityCardStatus.idea),
  _card('open-scheduled', ActivityCardStatus.scheduled),
  _card('open-done', ActivityCardStatus.done),
  _card('open-memory', ActivityCardStatus.memory),
];

final List<ActivityCard> _closedCards = <ActivityCard>[
  _card('closed-idea', ActivityCardStatus.idea),
  _card('closed-memory', ActivityCardStatus.memory),
];

Widget _host(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: child,
      ),
    );

/// Counts route pushes so "no new route" is a measured number rather than an
/// inference from what happens to be on screen.
class _RoutePushCounter extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}

/// Screen (1) itself, wide enough that the sixth cell is inside the frame:
/// the strip scrolls horizontally, and an off-frame cell would make `tap()`
/// miss for a reason that has nothing to do with this story.
Future<_FakeClosedArchive> _pumpHub(
  WidgetTester tester, {
  required List<ActivityCard> closed,
  _RoutePushCounter? observer,
}) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final _FakeClosedArchive archive = _FakeClosedArchive(closed);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      navigatorObservers: <NavigatorObserver>[?observer],
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: ActivityCardHubView(
          repository: _OpenCardRepository(_openCards),
          closedArchive: archive,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return archive;
}

Finder _cell(ActivityCardPane pane) =>
    find.byKey(Key('activity_status_filter_cell_${pane.name}'));

/// How a user actually reaches a cell: the strip scrolls horizontally rather
/// than shrinking its labels, so the sixth one is a scroll away, never a
/// screen away.
Future<void> _selectPane(WidgetTester tester, ActivityCardPane pane) async {
  await tester.ensureVisible(_cell(pane));
  await tester.pumpAndSettle();
  await tester.tap(_cell(pane));
  await tester.pumpAndSettle();
}

List<String> _cellLabels(WidgetTester tester) => tester
    .widgetList<GestureDetector>(
      find.descendant(
        of: find.byKey(const Key('activity_status_filter')),
        matching: find.byType(GestureDetector),
      ),
    )
    .map(
      (GestureDetector cell) =>
          ((cell.key! as ValueKey<String>).value).replaceFirst(
        'activity_status_filter_cell_',
        '',
      ),
    )
    .toList(growable: false);

Future<void> _loadDesignFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    const Map<String, String> families = <String, String>{
      'Nunito': 'assets/fonts/Nunito-Variable.ttf',
      'Roboto': 'assets/fonts/Roboto-Variable.ttf',
      'Roboto Mono': 'assets/fonts/RobotoMono-Variable.ttf',
      'Material Symbols Rounded':
          'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
    };
    for (final MapEntry<String, String> entry in families.entries) {
      final Uint8List bytes = await File(entry.value).readAsBytes();
      await (FontLoader(entry.key)
            ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
          .load();
    }
  });
}

void main() {
  testWidgets('exactly five cells before a closure exists (AC-16)', (
    WidgetTester tester,
  ) async {
    await _pumpHub(tester, closed: const <ActivityCard>[]);

    expect(_cellLabels(tester), <String>[
      'all',
      'idea',
      'scheduled',
      'done',
      'memory',
    ]);
    expect(_cell(ActivityCardPane.closed), findsNothing);
    // Not even the word, so nothing on screen hints the archive is a thing
    // this app has.
    expect(find.text('Đã đóng'), findsNothing);
  });

  testWidgets('exactly six cells once a closure exists (AC-11, AC-14)', (
    WidgetTester tester,
  ) async {
    await _pumpHub(tester, closed: _closedCards);

    expect(_cellLabels(tester), <String>[
      'all',
      'idea',
      'scheduled',
      'done',
      'memory',
      'closed',
    ]);
    expect(find.text('Đã đóng'), findsOneWidget);
  });

  testWidgets('the sixth cell is reachable from screen (1) and opens no route',
      (WidgetTester tester) async {
    final _RoutePushCounter observer = _RoutePushCounter();
    await _pumpHub(tester, closed: _closedCards, observer: observer);
    final int pushesBefore = observer.pushes;

    await _selectPane(tester, ActivityCardPane.closed);

    // Same screen, same list, no second surface (ux/uiux-spec.md §3).
    expect(observer.pushes, pushesBefore);
    expect(find.byKey(const Key('activity_card_hub')), findsOneWidget);
    expect(find.byKey(const Key('activity_card_tile_closed-idea')),
        findsOneWidget);
    expect(find.byKey(const Key('activity_card_tile_closed-memory')),
        findsOneWidget);
    // The archive's two actions live in the pane itself (AC-15, AC-17).
    expect(find.byKey(const Key('closed_archive_actions')), findsOneWidget);
  });

  testWidgets('closed material is absent from the other five panes (AC-11)', (
    WidgetTester tester,
  ) async {
    final _FakeClosedArchive archive =
        await _pumpHub(tester, closed: _closedCards);

    for (final ActivityCardPane pane in <ActivityCardPane>[
      ActivityCardPane.all,
      ActivityCardPane.idea,
      ActivityCardPane.scheduled,
      ActivityCardPane.done,
      ActivityCardPane.memory,
    ]) {
      await _selectPane(tester, pane);

      for (final ActivityCard closed in _closedCards) {
        expect(
          find.byKey(Key('activity_card_tile_${closed.id}')),
          findsNothing,
          reason: '${closed.id} must not surface in pane ${pane.name}',
        );
      }
      expect(find.byKey(const Key('closed_archive_actions')), findsNothing);
    }

    // The stronger statement: the five ordinary panes never even ask the
    // archive for rows, so there is no path by which closed material could
    // leak into them.
    expect(archive.closedCardsCalls, 0);
  });

  testWidgets('the closed count sits beside the sixth label, and outside the '
      'store total (AC-11)', (WidgetTester tester) async {
    await _pumpHub(tester, closed: _closedCards);

    // "Tất cả" counts the four open cards only; the archive counts its own two.
    expect(
      find.descendant(of: _cell(ActivityCardPane.all), matching: find.text('· 4')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _cell(ActivityCardPane.closed),
        matching: find.text('· 2'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('an emptied archive lands the user on "Tất cả", not a dead end '
      '(AC-30)', (WidgetTester tester) async {
    final ActivityCardListCubit cubit = ActivityCardListCubit(
      repository: _OpenCardRepository(_openCards),
      closedArchive: _FakeClosedArchive(<ActivityCard>[]),
    );
    await cubit.selectPane(ActivityCardPane.closed);

    expect(cubit.state.pane, ActivityCardPane.all);
    expect(cubit.state.hasClosedArchive, isFalse);
    await cubit.close();
  });

  test('the closed pane pages like the other five', () async {
    final List<ActivityCard> many = <ActivityCard>[
      for (int i = 0; i < 5; i++) _card('closed-$i', ActivityCardStatus.idea),
    ];
    final ActivityCardListCubit cubit = ActivityCardListCubit(
      repository: _OpenCardRepository(_openCards),
      closedArchive: _FakeClosedArchive(many),
      pageSize: 2,
    );
    await cubit.selectPane(ActivityCardPane.closed);

    expect(cubit.state.cards.map((ActivityCard c) => c.id), <String>[
      'closed-0',
      'closed-1',
    ]);
    expect(cubit.state.hasMore, isTrue);

    await cubit.loadMore();
    await cubit.loadMore();
    expect(cubit.state.cards, hasLength(5));
    // A short last page is the honest end of the archive.
    expect(cubit.state.hasMore, isFalse);
    await cubit.close();
  });

  testWidgets('the label is never abbreviated in either language', (
    WidgetTester tester,
  ) async {
    late String vi;
    late String en;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (BuildContext context) {
            vi = activityPaneLabel(context, ActivityCardPane.closed);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Builder(
          builder: (BuildContext context) {
            en = activityPaneLabel(context, ActivityCardPane.closed);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(vi, 'Đã đóng');
    expect(en, 'Closed');
  });

  testWidgets(
    'captures the implemented frame for visual fidelity',
    (WidgetTester tester) async {
      tester.view.physicalSize = _iosReferenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _loadDesignFonts(tester);
      await tester.pumpWidget(
        RepaintBoundary(
          key: _captureBoundaryKey,
          child: _host(
            // The hub paints on the app background; without an opaque layer
            // under it the capture comes out transparent and reads as white.
            Builder(
              builder: (BuildContext context) => ColoredBox(
                color: context.cupidColors.colorBackground,
                child: ActivityCardHubView(
                  repository: _OpenCardRepository(_openCards),
                  closedArchive: _FakeClosedArchive(_closedCards),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _selectPane(tester, ActivityCardPane.closed);

      final RenderRepaintBoundary boundary =
          tester.renderObject(find.byKey(_captureBoundaryKey))
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final ui.Image image = await boundary.toImage(pixelRatio: 1);
        final ByteData? png =
            await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        final File out =
            File('$_visualDir/implemented-kho-da-dong-ios.png');
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(png!.buffer.asUint8List());
      });
    },
    skip: !_captureVisuals,
  );
}
