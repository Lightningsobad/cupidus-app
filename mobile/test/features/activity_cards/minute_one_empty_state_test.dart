import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/occasion_suggestion_service.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/activity_card_list_cubit.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/minute_one_empty_state.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/quick_entry_strip.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendered-evidence capture for the per-story visual fidelity gate. Off by
/// default so the scoped suite stays hermetic; enable with
/// `flutter test test/features/activity_cards/minute_one_empty_state_test.dart
/// --dart-define=CAPTURE_VISUALS=true`.
///
/// This is a widget-tree capture rather than a device screenshot because the
/// screen has no reachable route yet: mounting it into the hub is
/// `activity_card_hub_view.dart`'s job and that file is outside this phase's
/// write scope, so no running app can navigate here.
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// Exactly the frame `design-reference-phut-1-kho-trong-ios.png` was rendered
/// at, so the two PNGs compare without rescaling either one.
const Size _iosReferenceViewport = Size(415, 900);

const String _visualEvidenceDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-001_activity_card_hub/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

class _RecordingRepository implements ActivityCardRepository {
  _RecordingRepository([this._cards = const <ActivityCard>[]]);

  final List<ActivityCard> _cards;
  final List<NewActivityCard> drafts = <NewActivityCard>[];

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async {
    drafts.add(draft);
    final DateTime now = DateTime(2026, 9, 8);
    return ActivityCard(
      id: 'card-${drafts.length}',
      ownerKey: 'owner-1',
      title: draft.title.isEmpty ? 'tiktok.com' : draft.title,
      status: ActivityCardStatus.idea,
      origin: draft.origin,
      activityType: draft.activityType,
      sourceLink: draft.sourceLink,
      invited: false,
      replyState: ActivityCardReplyState.notAnswered,
      createdAt: now,
      updatedAt: now,
    );
  }

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
  Future<ActivityCard?> cardById(String id) async => null;

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async {
    final Map<ActivityCardStatus, int> counts = <ActivityCardStatus, int>{};
    for (final ActivityCard card in _cards) {
      counts[card.status] = (counts[card.status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<int> deleteCard(String id) async => 0;

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) =>
      throw UnimplementedError('not exercised by Minute-1');

  @override
  Future<int> clearScheduledDate(String cardId) =>
      throw UnimplementedError('not exercised by Minute-1');

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) =>
      throw UnimplementedError('not exercised by Minute-1');
}

ActivityCard _card(ActivityCardStatus status) {
  final DateTime now = DateTime(2026, 9, 7);
  return ActivityCard(
    id: 'seed-${status.wireValue}',
    ownerKey: 'owner-1',
    title: 'Thẻ ${status.wireValue}',
    status: status,
    origin: ActivityCardOrigin.manual,
    invited: false,
    replyState: ActivityCardReplyState.notAnswered,
    createdAt: now,
    updatedAt: now,
  );
}

/// Stands in for the shipped occasion package. Titles and the occasion name
/// live here rather than in the widget, which is the same rule production
/// follows: occasion content is data, never Dart (R-15a).
final Occasion _occasion = const Occasion(
  id: 'occ-1',
  name: 'Dịp thử nghiệm',
  calendar: 'lunar',
  dates: <String>['2026-09-25'],
  suggestions: <OccasionSuggestion>[
    OccasionSuggestion(id: 'sug-1', title: 'Gợi ý thứ nhất'),
    OccasionSuggestion(id: 'sug-2', title: 'Gợi ý thứ hai'),
  ],
);

OccasionPrompt get _prompt => OccasionPrompt(
  occasion: _occasion,
  date: _occasion.dates.first,
  suggestions: _occasion.suggestions,
);

Widget _host(Widget child, {CupidPlatform platform = CupidPlatform.material}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(
        platform: platform,
        child: Builder(
          builder: (BuildContext context) => ColoredBox(
            color: context.cupidColors.colorBackground,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(child: SingleChildScrollView(child: child)),
            ),
          ),
        ),
      ),
    );

Widget _minuteOne(
  _RecordingRepository repository, {
  OccasionPrompt? prompt,
  ValueChanged<ActivityCard>? onCardCreated,
}) => MinuteOneEmptyState(
  repository: repository,
  loadPrompt: () async => prompt,
  onCardCreated: onCardCreated,
);

void main() {
  group('empty branch selection', () {
    test('an empty store is the absolute-empty Minute-1 branch', () async {
      final ActivityCardListCubit cubit = ActivityCardListCubit(
        repository: _RecordingRepository(),
      );
      await cubit.load();

      expect(cubit.state.loading, isFalse);
      expect(cubit.state.cards, isEmpty);
      expect(cubit.state.storeCount, 0);
      await cubit.close();
    });

    test('an empty pane beside one filled pane is not Minute-1', () async {
      final ActivityCardListCubit cubit = ActivityCardListCubit(
        repository: _RecordingRepository(<ActivityCard>[
          _card(ActivityCardStatus.memory),
        ]),
      );
      await cubit.load();
      await cubit.selectPane(ActivityCardPane.idea);

      expect(cubit.state.cards, isEmpty);
      // The discriminator: the pane is empty, the store is not, so the two
      // invitations must not appear.
      expect(cubit.state.storeCount, 1);
      await cubit.close();
    });
  });

  group('MinuteOneEmptyState', () {
    testWidgets('offers exactly two invitations and no onboarding form (AC-1)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(_minuteOne(_RecordingRepository(), prompt: _prompt)),
      );
      await tester.pump();

      expect(_invites, findsNWidgets(2));
      expect(find.byKey(const Key('activity_minute1_invite_link')),
          findsOneWidget);
      expect(find.byKey(const Key('activity_minute1_invite_occasion')),
          findsOneWidget);

      // No form, no wizard, and not even one field before an invitation is
      // chosen.
      expect(find.byType(EditableText), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(Form), findsNothing);

      // One short title line, and no marketing paragraph under it.
      final Text title = tester.widget<Text>(
        find.byKey(const Key('activity_card_hub_minute1_title')),
      );
      expect(title.maxLines, 1);

      // The manual "+" belongs to a store that already holds something.
      expect(find.byKey(const Key('activity_quick_capture_add')), findsNothing);
    });

    testWidgets('the paste-link invite asks for one field only (AC-2, AC-7)',
        (WidgetTester tester) async {
      final _RecordingRepository repository = _RecordingRepository();
      final List<ActivityCard> created = <ActivityCard>[];
      await tester.pumpWidget(
        _host(_minuteOne(repository, onCardCreated: created.add)),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('activity_minute1_invite_link')));
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);

      await tester.enterText(
        find.byKey(const Key('activity_quick_capture_field')),
        'https://tiktok.com/@quan/video/1',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repository.drafts, hasLength(1));
      expect(repository.drafts.single.origin, ActivityCardOrigin.pastedLink);
      expect(created, hasLength(1));
    });

    testWidgets('an occasion suggestion creates a card with no extra field '
        '(AC-3)', (WidgetTester tester) async {
      final _RecordingRepository repository = _RecordingRepository();
      final List<ActivityCard> created = <ActivityCard>[];
      await tester.pumpWidget(
        _host(
          _minuteOne(
            repository,
            prompt: _prompt,
            onCardCreated: created.add,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('activity_minute1_invite_occasion')),
      );
      await tester.pumpAndSettle();

      // Package content, shown verbatim.
      expect(find.text(_occasion.name), findsOneWidget);
      expect(find.text('Gợi ý thứ nhất'), findsOneWidget);
      expect(find.text('Gợi ý thứ hai'), findsOneWidget);
      // 1–2 suggestions, never the whole package.
      expect(_suggestionRows, findsNWidgets(2));

      await tester.tap(find.byKey(const Key('activity_minute1_suggestion_sug-1')));
      await tester.pumpAndSettle();

      expect(repository.drafts, hasLength(1));
      expect(
        repository.drafts.single.origin,
        ActivityCardOrigin.occasionSuggestion,
      );
      expect(repository.drafts.single.title, 'Gợi ý thứ nhất');
      expect(created, hasLength(1));
      // No intermediate required-field screen sat between the tap and the
      // card.
      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('the quick-entry strip keeps its shape through both states',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(_minuteOne(_RecordingRepository(), prompt: _prompt)),
      );
      await tester.pump();

      expect(find.byType(QuickEntryStrip), findsOneWidget);
      final List<double> before = _slotWidths(tester);
      expect(before, hasLength(kQuickEntryCellCount));
      expect(before.toSet(), hasLength(1));

      // One label per cell and nothing else: no count badge, no "new" dot.
      expect(
        find.descendant(
          of: find.byKey(const Key('activity_quick_entry_strip')),
          matching: find.byType(Text),
        ),
        findsNWidgets(kQuickEntryCellCount),
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('activity_quick_entry_strip')),
          matching: find.byType(Badge),
        ),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const Key('activity_minute1_invite_occasion')),
      );
      await tester.pumpAndSettle();

      expect(_slotWidths(tester), before);
    });

    testWidgets(
      'B-6: once the occasion package runs out, the occasion invitation is not '
      'offered at all rather than offered and refused',
      (WidgetTester tester) async {
        // `loadPrompt` answering null is exactly what production does after
        // 2027-12-24: no packaged date on or after today.
        await tester.pumpWidget(_host(_minuteOne(_RecordingRepository())));
        await tester.pump();

        expect(
          find.byKey(const Key('activity_minute1_invite_occasion')),
          findsNothing,
        );
        // The paste-link invitation is content-independent, so it stays.
        expect(
          find.byKey(const Key('activity_minute1_invite_link')),
          findsOneWidget,
        );
        expect(_invites, findsOneWidget);
        // Minute-1 is still a working surface, not a stub: the strip and the
        // title are untouched by the expiry.
        expect(find.byType(QuickEntryStrip), findsOneWidget);
        expect(
          find.byKey(const Key('activity_card_hub_minute1_title')),
          findsOneWidget,
        );
      },
    );

    testWidgets('an unfilled quick-entry cell answers, never dead-ends (SC-5)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_minuteOne(_RecordingRepository())));
      await tester.pump();

      await tester.tap(find.byKey(const Key('activity_quick_entry_slot_0')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sắp có'), findsOneWidget);
    });

    testWidgets(
      'renders the visual-fidelity evidence frame',
      (WidgetTester tester) async {
        tester.view.physicalSize = _iosReferenceViewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await _loadDesignFonts(tester);
        await tester.pumpWidget(
          RepaintBoundary(
            key: _captureBoundaryKey,
            child: _host(
              _minuteOne(_RecordingRepository(), prompt: _prompt),
              platform: CupidPlatform.ios,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        await _writeCapture(tester, 'implemented-phut-1-kho-trong-ios.png');

        await tester.tap(
          find.byKey(const Key('activity_minute1_invite_occasion')),
        );
        await tester.pumpAndSettle();
        await _writeCapture(
          tester,
          'implemented-phut-1-kho-trong-ios-suggestions.png',
        );
      },
      skip: !kCaptureVisuals,
    );
  });
}

final Finder _invites = find.byWidgetPredicate(
  (Widget widget) =>
      widget.key != null &&
      '${widget.key}'.contains('activity_minute1_invite_'),
);

final Finder _suggestionRows = find.byWidgetPredicate(
  (Widget widget) =>
      widget.key != null &&
      '${widget.key}'.contains('activity_minute1_suggestion_'),
);

List<double> _slotWidths(WidgetTester tester) => <double>[
  for (int slot = 0; slot < kQuickEntryCellCount; slot++)
    tester.getSize(find.byKey(Key('activity_quick_entry_slot_$slot'))).width,
];

/// Widget tests ship no asset bundle, so the bundled variable fonts are read
/// off disk. Without this every glyph rasterizes as a fallback box and the
/// capture is worthless for typography comparison.
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

Future<void> _writeCapture(WidgetTester tester, String fileName) async {
  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    final File out = File('$_visualEvidenceDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}
