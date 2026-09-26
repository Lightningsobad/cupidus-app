import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_content_repository.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content.dart';
import 'package:cupid_mobile/features/phase_status/domain/solo_phase.dart';
import 'package:cupid_mobile/features/phase_status/presentation/phase_status_cubit.dart';
import 'package:cupid_mobile/features/phase_status/presentation/phase_status_line.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'
    show ByteData, CachingAssetBundle, FontLoader;
import 'package:flutter_test/flutter_test.dart';

/// The day every test in this file reads as "today". Pinned so the countdown
/// asserts a fixed number instead of one that changes with the clock.
final DateTime _today = DateTime(2026, 9, 16);

/// Widget tests ship no asset bundle, so the shipped packs are read off disk —
/// the same device this story's other tests use. The line under test is
/// therefore the copy an author actually shipped, not a fixture.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }
}

PhaseContentRepository _content() => PhaseContentRepository(bundle: _DiskBundle());

/// Counts publish calls, which is the whole assertion for `WIDGET-STALE`: the
/// widget is fed once per resolution, and a resolution happens on mount and on
/// resume and at no other moment.
class _RecordingPublisher implements PhaseWidgetPublisher {
  final List<PhaseResolution> pushed = <PhaseResolution>[];

  @override
  Future<void> pushWidgetPayload(PhaseResolution resolution) async {
    pushed.add(resolution);
  }
}

class _FakeRepository implements ActivityCardRepository {
  _FakeRepository(this._cards);

  final List<ActivityCard> _cards;

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async =>
      _cards
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
  Future<ActivityCard?> cardById(String id) async =>
      _cards.cast<ActivityCard?>().firstWhere(
            (ActivityCard? card) => card?.id == id,
            orElse: () => null,
          );

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async =>
      throw UnimplementedError();

  @override
  Future<int> deleteCard(String id) async => 0;

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 1;

  @override
  Future<int> clearScheduledDate(String cardId) async => 1;

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async => 1;
}

ActivityCard _card({
  required String id,
  required ActivityCardStatus status,
  String? title,
  bool invited = false,
  String? scheduledOn,
}) {
  final DateTime stamp = DateTime(2026, 9, 7);
  return ActivityCard(
    id: id,
    ownerKey: 'owner-1',
    title: title ?? 'Thẻ $id',
    status: status,
    origin: ActivityCardOrigin.manual,
    scheduledOn: scheduledOn,
    invited: invited,
    replyState: ActivityCardReplyState.notAnswered,
    createdAt: stamp,
    updatedAt: stamp,
  );
}

/// One card store per phase, so every test names the phase it is standing in
/// rather than re-deriving it from a card list.
final Map<SoloPhase, List<ActivityCard>> _storeFor =
    <SoloPhase, List<ActivityCard>>{
  SoloPhase.waiting: <ActivityCard>[
    _card(
      id: 'w1',
      status: ActivityCardStatus.idea,
      title: 'Đi xem phim',
      invited: true,
    ),
  ],
  SoloPhase.upcoming: <ActivityCard>[
    _card(
      id: 'u1',
      status: ActivityCardStatus.scheduled,
      title: 'Đi biển',
      scheduledOn: '2026-09-20',
    ),
  ],
  SoloPhase.dateDay: <ActivityCard>[
    _card(
      id: 'd1',
      status: ActivityCardStatus.scheduled,
      title: 'Ăn lẩu',
      scheduledOn: '2026-09-16',
    ),
  ],
  SoloPhase.quiet: <ActivityCard>[
    _card(id: 'q1', status: ActivityCardStatus.idea, title: 'Tự làm bánh'),
  ],
};

Widget _host(Widget child) => MaterialApp(
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

Widget _hub(
  List<ActivityCard> cards, {
  PhaseWidgetPublisher? publisher,
  DateTime? today,
}) =>
    _host(
      ActivityCardHubView(
        repository: _FakeRepository(cards),
        phaseContent: _content(),
        phaseWidgetPublisher: publisher,
        today: today ?? _today,
      ),
    );

String _lineText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(phaseStatusLineKey)).data!;

/// The shipped screen copy for [phase], read from the package rather than
/// transcribed here: a test holding its own copy of the strings would keep
/// passing after an author changed them (AC-37).
Future<PhaseContentItem> _screenItem(SoloPhase phase) async {
  final PhaseContentCatalogue catalogue = await _content().catalogue();
  return catalogue.phaseContent.items.firstWhere(
    (PhaseContentItem item) =>
        item.phaseId.wireValue == phase.wireValue && item.surface.allowsScreen,
  );
}

// ---------------------------------------------------------------------------
// Per-story rendered evidence (`solution.md` §4 `VISUAL-FIDELITY`).
//
// Screen (1) is reachable in the app only behind a signed-in, unpaired session
// and a DI-resolved card store, so the four phases are captured from this
// widget test instead, at the Android reference viewport the design canvas was
// rendered at. Off by default; enable with
// `--dart-define=CAPTURE_VISUALS=true`.
// ---------------------------------------------------------------------------
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');
const Size _referenceViewport = Size(412, 915);
const String _captureDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-012_phase_status_and_widget/visual-fidelity';
final GlobalKey _captureKey = GlobalKey();

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

Future<void> _capture(
  WidgetTester tester,
  Widget app,
  String fileName,
) async {
  tester.view.physicalSize = _referenceViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);
  // Without an opaque layer under the app the PNG keeps the boundary's alpha,
  // and every anti-aliased glyph edge reads as washed out in a viewer that
  // composites the file over white.
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: ColoredBox(
        color: const CupidColorTokens.dark().colorBackground,
        child: app,
      ),
    ),
  );
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureKey)) as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_captureDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  group('the phase line draws the shipped copy for each phase', () {
    testWidgets('waiting points at a preparation action (AC-5)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.waiting]!));
      await tester.pumpAndSettle();

      final PhaseContentItem item = await _screenItem(SoloPhase.waiting);
      expect(_lineText(tester), item.primary);
      expect(find.text(item.secondary!), findsOneWidget);
    });

    testWidgets('waiting draws the action the pack names (R-1)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.waiting]!));
      await tester.pumpAndSettle();

      final PhaseContentItem item = await _screenItem(SoloPhase.waiting);
      expect(item.actionLabel, isNotNull);
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(phaseStatusLineActionKey),
                matching: find.byType(Text),
              ),
            )
            .data,
        item.actionLabel,
      );
      // The action is a full tap target even though it reads a tier below the
      // card's own action (`ux/requirement-ux-survey.md` §4).
      expect(
        tester.getSize(find.byKey(phaseStatusLineActionKey)).height,
        greaterThanOrEqualTo(44),
      );
    });

    testWidgets('a phase whose line names no action draws none',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.upcoming]!));
      await tester.pumpAndSettle();

      final PhaseContentItem item = await _screenItem(SoloPhase.upcoming);
      expect(item.actionLabel, isNull);
      // Absent means absent: no chip, and no invented default label either.
      expect(find.byKey(phaseStatusLineActionKey), findsNothing);
      expect(find.byKey(phaseStatusLineKey), findsOneWidget);
    });

    testWidgets('the action opens the card detail rather than a route of its '
        'own', (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.waiting]!));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(phaseStatusLineActionKey));
      await tester.pumpAndSettle();

      expect(find.byKey(phaseStatusLineActionKey), findsNothing);
      expect(find.text('Đi xem phim'), findsWidgets);
    });

    testWidgets('upcoming counts the days down to the date (AC-14)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.upcoming]!));
      await tester.pumpAndSettle();

      final PhaseContentItem item = await _screenItem(SoloPhase.upcoming);
      expect(
        _lineText(tester),
        item.primary.replaceAll(phaseContentNumberPlaceholder, '4'),
      );
      // The substitution site is filled, never left showing its own syntax.
      expect(
        _lineText(tester).contains(phaseContentNumberPlaceholder),
        isFalse,
      );
    });

    testWidgets('date day says today, with no number at all',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.dateDay]!));
      await tester.pumpAndSettle();

      final PhaseContentItem item = await _screenItem(SoloPhase.dateDay);
      expect(_lineText(tester), item.primary);
      expect(RegExp(r'\d').hasMatch(_lineText(tester)), isFalse);
    });

    testWidgets('quiet has no screen line yet and collapses to nothing',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.quiet]!));
      await tester.pumpAndSettle();

      // The quiet pack's only screen-eligible line needs the kept-memory
      // counter P3/P8 owns, so at this phase there is nothing to say — and
      // nothing is drawn, not an empty row.
      expect(find.byKey(phaseStatusLineKey), findsNothing);
      expect(find.byKey(phaseStatusLineSecondaryKey), findsNothing);
      // The card list itself is untouched by the missing line.
      expect(find.text('Tự làm bánh'), findsOneWidget);
    });

    testWidgets('nothing to say renders as nothing, not as an empty row',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const Center(child: PhaseStatusLine())));
      await tester.pumpAndSettle();

      expect(find.byKey(phaseStatusLineKey), findsNothing);
      expect(
        tester.getSize(
          find.descendant(
            of: find.byType(PhaseStatusLine),
            matching: find.byType(SizedBox),
          ),
        ),
        Size.zero,
      );
    });

    testWidgets('AC-6/AC-7: the waiting line carries no digit anywhere',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.waiting]!));
      await tester.pumpAndSettle();

      final RegExp digit = RegExp(r'\d');
      expect(digit.hasMatch(_lineText(tester)), isFalse);
      final String secondary = tester
          .widget<Text>(find.byKey(phaseStatusLineSecondaryKey))
          .data!;
      expect(digit.hasMatch(secondary), isFalse);
      // No card in this phase carries a date, so nothing else on the tile can
      // start counting either.
      expect(find.byKey(const Key('activity_card_countdown_w1')), findsNothing);
    });
  });

  group('the per-card countdown', () {
    testWidgets('AC-14: a future date counts whole days, with no clock time',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.upcoming]!));
      await tester.pumpAndSettle();

      // D-4: the number is drawn at display size beside its unit, so the two
      // halves are two `Text`s. What is asserted is still the whole reading.
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('activity_card_countdown_numeral_u1')),
            )
            .data,
        '4',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('activity_card_countdown_u1')))
            .data,
        'ngày nữa',
      );
      // AC-14's unit is whole days: a screen reader hears one sentence, and it
      // carries no hour either.
      expect(
        tester
            .widget<Semantics>(
              find.ancestor(
                of: find.byKey(const Key('activity_card_countdown_u1')),
                matching: find.byType(Semantics),
              ).first,
            )
            .properties
            .label,
        'còn 4 ngày',
      );
      expect(find.textContaining(':'), findsNothing);
    });

    testWidgets('AC-15: a past date is drawn plainly, with no countdown and no '
        'elapsed count', (WidgetTester tester) async {
      await tester.pumpWidget(
        _hub(<ActivityCard>[
          _card(
            id: 'p1',
            status: ActivityCardStatus.scheduled,
            title: 'Đi chợ hoa',
            scheduledOn: '2026-09-01',
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('activity_card_countdown_p1')), findsNothing);
      expect(
        find.byKey(const Key('activity_card_countdown_numeral_p1')),
        findsNothing,
      );
      // The date itself stays on the card, unannotated — in the eyebrow, and
      // read the way a reader writes a date rather than as the stored column
      // value (D-3).
      expect(
        tester
            .widget<Text>(find.byKey(const Key('activity_card_eyebrow_p1')))
            .data,
        'ĐÃ HẸN NGÀY · T3 1/9',
      );
      expect(find.textContaining('2026-09-01'), findsNothing);
      // A passed date matches no phase branch, so no line claims one either.
      expect(find.byKey(phaseStatusLineKey), findsNothing);
    });

    testWidgets('the day of the date reads as today rather than as zero days',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_storeFor[SoloPhase.dateDay]!));
      await tester.pumpAndSettle();

      // No numeral at all on the day itself: zero days is not a count the card
      // ever prints. The eyebrow says the day in words instead, and drops the
      // date beside it because "today" already is the date (D-2/D-5).
      expect(find.byKey(const Key('activity_card_countdown_d1')), findsNothing);
      expect(
        find.byKey(const Key('activity_card_countdown_numeral_d1')),
        findsNothing,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('activity_card_eyebrow_d1')))
            .data,
        'ĐÚNG HÔM NAY',
      );
    });

    test('the day count is civil days, and negative once the date has passed',
        () {
      expect(
        civilDaysUntil(scheduledOnIso: '2026-09-20', today: _today),
        4,
      );
      expect(civilDaysUntil(scheduledOnIso: '2026-09-16', today: _today), 0);
      expect(civilDaysUntil(scheduledOnIso: '2026-09-01', today: _today), -15);
      // A time of day on the clock cannot move a civil-day answer.
      expect(
        civilDaysUntil(
          scheduledOnIso: '2026-09-20',
          today: DateTime(2026, 9, 16, 23, 59),
        ),
        4,
      );
      expect(civilDaysUntil(scheduledOnIso: 'not-a-date', today: _today), isNull);
    });
  });

  group('the widget payload is published from the same resolution', () {
    testWidgets('exactly once per mount', (WidgetTester tester) async {
      final _RecordingPublisher publisher = _RecordingPublisher();
      await tester.pumpWidget(
        _hub(_storeFor[SoloPhase.upcoming]!, publisher: publisher),
      );
      await tester.pumpAndSettle();

      expect(publisher.pushed, hasLength(1));
      expect(publisher.pushed.single.phase, SoloPhase.upcoming);
      expect(publisher.pushed.single.cardId, 'u1');
      expect(publisher.pushed.single.scheduledOn, '2026-09-20');

      // Rebuilding the list does not re-publish: the refresh loop is the
      // body's, not the sliver item builder's.
      await tester.pump();
      await tester.pumpAndSettle();
      expect(publisher.pushed, hasLength(1));
    });

    testWidgets('and again when the app comes back to the foreground',
        (WidgetTester tester) async {
      final _RecordingPublisher publisher = _RecordingPublisher();
      await tester.pumpWidget(
        _hub(_storeFor[SoloPhase.upcoming]!, publisher: publisher),
      );
      await tester.pumpAndSettle();
      expect(publisher.pushed, hasLength(1));

      for (final AppLifecycleState state in <AppLifecycleState>[
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();

      expect(publisher.pushed, hasLength(2));
    });

    testWidgets('a phase with no line still publishes its resolution',
        (WidgetTester tester) async {
      final _RecordingPublisher publisher = _RecordingPublisher();
      await tester.pumpWidget(
        _hub(_storeFor[SoloPhase.quiet]!, publisher: publisher),
      );
      await tester.pumpAndSettle();

      expect(publisher.pushed.single.phase, SoloPhase.quiet);
      expect(find.byKey(phaseStatusLineKey), findsNothing);
    });
  });

  group('AC-37/BR-15: the line widget holds no copy of its own', () {
    test('no display string is written in phase_status_line.dart', () async {
      final File source = File(
        'lib/features/phase_status/presentation/phase_status_line.dart',
      );
      // Comments are prose about the copy, not copy: stripping them keeps this
      // assertion on what the widget can actually render.
      final String code = source
          .readAsLinesSync()
          .where((String line) => !line.trimLeft().startsWith('//'))
          .join('\n');

      final PhaseContentCatalogue catalogue = await _content().catalogue();
      for (final PhaseContentItem item in catalogue.phaseContent.items) {
        for (final String text in item.displayStrings) {
          expect(
            code.contains(text),
            isFalse,
            reason: 'phase_status_line.dart must not carry "$text"',
          );
        }
      }
      // Stronger than "not these strings": no readable Vietnamese sentence of
      // any kind, so a new line cannot be added here later either.
      expect(
        RegExp('[ăâđêôơưàáảãạèéẻẽẹìíỉĩịòóỏõọùúủũụỳýỷỹỵ]', caseSensitive: false)
            .hasMatch(code),
        isFalse,
      );
    });
  });

  group('rendered evidence', () {
    for (final SoloPhase phase in SoloPhase.values) {
      testWidgets(
        'captures screen (1) in the ${phase.wireValue} phase',
        (WidgetTester tester) async {
          await _capture(
            tester,
            _hub(_storeFor[phase]!),
            'implemented-hub-${phase.wireValue}.png',
          );
        },
        skip: !kCaptureVisuals,
      );
    }
  });
}
