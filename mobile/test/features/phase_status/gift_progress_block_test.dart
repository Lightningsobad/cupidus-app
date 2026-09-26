import 'dart:io';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_content_repository.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_status_prefs.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content.dart';
import 'package:cupid_mobile/features/phase_status/presentation/gift_progress_block.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DateTime _today = DateTime(2026, 9, 16);

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

PhaseContentRepository _content() =>
    PhaseContentRepository(bundle: _DiskBundle());

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

ActivityCard _card({required String id, ActivityType? activityType}) {
  final DateTime stamp = DateTime(2026, 9, 7);
  return ActivityCard(
    id: id,
    ownerKey: 'owner-1',
    title: 'Thẻ $id',
    status: ActivityCardStatus.idea,
    origin: ActivityCardOrigin.manual,
    activityType: activityType,
    invited: false,
    replyState: ActivityCardReplyState.notAnswered,
    createdAt: stamp,
    updatedAt: stamp,
  );
}

/// The quiet phase with a gift the user is making, and the quiet phase without
/// one. Neither card is invited and neither carries a date, so both resolve to
/// `quiet` and differ only in the thing under test.
final List<ActivityCard> _withGift = <ActivityCard>[
  _card(id: 'g1', activityType: ActivityType.gift),
];
final List<ActivityCard> _withoutGift = <ActivityCard>[_card(id: 'n1')];

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

Widget _hub(List<ActivityCard> cards) => _host(
      ActivityCardHubView(
        repository: _FakeRepository(cards),
        phaseContent: _content(),
        phaseStatusPrefs: PhaseStatusPrefs(),
        today: _today,
      ),
    );

Future<List<String>> _dripIds() async {
  final PhaseContentCatalogue catalogue = await _content().catalogue();
  return catalogue.drip.items
      .map((DripItem item) => item.id)
      .toList(growable: false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('the gift block appears only when there is something to report', () {
    testWidgets('a gift in progress gets the shipped progress line (AC-20)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_withGift));
      await tester.pumpAndSettle();

      final PhaseContentCatalogue catalogue = await _content().catalogue();
      final NudgeItem item = catalogue.nudges.items.firstWhere(
        (NudgeItem item) => item.slot == NudgeSlot.giftProgress,
      );
      expect(
        tester.widget<Text>(find.byKey(giftProgressBlockKey)).data,
        item.body,
      );
    });

    testWidgets('no gift means no block and no invitation to make one (AC-21)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_withoutGift));
      await tester.pumpAndSettle();

      expect(find.byKey(giftProgressBlockKey), findsNothing);
      expect(find.byType(GiftProgressBlock), findsOneWidget);
      expect(
        tester.widget<GiftProgressBlock>(find.byType(GiftProgressBlock)).line,
        isNull,
      );
    });

    testWidgets('the line reports doing, never a ratio or a bar (AC-20/BR-7)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_withGift));
      await tester.pumpAndSettle();

      final String body =
          tester.widget<Text>(find.byKey(giftProgressBlockKey)).data!;
      expect(body, isNot(contains('%')));
      expect(body, isNot(contains('/')));
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('the drip keeps its cadence and its silence', () {
    testWidgets('the quiet phase may carry one caption (AC-22)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_withoutGift));
      await tester.pumpAndSettle();

      expect(find.byKey(dripCaptionLineKey), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(dripCaptionLineKey)).data,
        isNot(contains(phaseContentNumberPlaceholder)),
      );
    });

    testWidgets('a second open in the same week says nothing more (BR-9)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_hub(_withoutGift));
      await tester.pumpAndSettle();
      expect(find.byKey(dripCaptionLineKey), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_hub(_withoutGift));
      await tester.pumpAndSettle();

      expect(find.byKey(dripCaptionLineKey), findsNothing);
    });

    testWidgets('an exhausted store is silent, with no trace (AC-38)',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        phaseStatusDripSeenIdsKey: await _dripIds(),
      });

      await tester.pumpWidget(_hub(_withoutGift));
      await tester.pumpAndSettle();

      expect(find.byKey(dripCaptionLineKey), findsNothing);
      for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
        final String lower = text.data?.toLowerCase() ?? '';
        expect(lower, isNot(contains('đã hết')));
        expect(lower, isNot(contains('còn lại')));
        expect(lower, isNot(contains('lần sau')));
      }
    });
  });

  group('the fully empty quiet screen invites nothing', () {
    testWidgets('no memories, no gift, no drip left: no extra call to action '
        '(AC-21/AC-38)', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        phaseStatusDripSeenIdsKey: await _dripIds(),
      });

      await tester.pumpWidget(_hub(_withoutGift));
      await tester.pumpAndSettle();

      expect(find.byKey(giftProgressBlockKey), findsNothing);
      expect(find.byKey(dripCaptionLineKey), findsNothing);
      // The quick-capture add action is screen (1)'s one standing entry point
      // and predates this story; the quiet surfaces must not have grown a
      // second one beside it.
      expect(find.byType(ButtonStyleButton), findsNothing);
    });
  });
}
