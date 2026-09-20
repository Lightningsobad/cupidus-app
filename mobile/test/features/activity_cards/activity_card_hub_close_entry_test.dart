import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/chapter_closure/data/chapter_closure_service.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the writes the entry point makes. `implements` rather than
/// `extends`: the real service needs a database, and this test only asserts
/// how many times the hub asked for a closure.
class _RecordingClosureService implements ChapterClosureService {
  int closeCalls = 0;
  int reopenCalls = 0;

  @override
  Future<String> close() async {
    closeCalls++;
    return 'closure-$closeCalls';
  }

  @override
  Future<void> reopen() async => reopenCalls++;
}

/// The hub only reads here; the closure flow is what this file exercises.
class _EmptyActivityCardRepository implements ActivityCardRepository {
  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async =>
      const <ActivityCard>[];

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async* {
    yield const <ActivityCard>[];
  }

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async =>
      <ActivityCardStatus, int>{ActivityCardStatus.idea: 1};

  @override
  Future<ActivityCard?> cardById(String id) async => null;

  @override
  Future<int> deleteCard(String id) async => 0;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async =>
      throw UnimplementedError();

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 0;

  @override
  Future<int> clearScheduledDate(String cardId) async => 0;

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async => 0;
}

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

Future<_RecordingClosureService> _pumpHub(WidgetTester tester) async {
  final _RecordingClosureService service = _RecordingClosureService();
  await tester.pumpWidget(
    _host(
      ActivityCardHubView(
        repository: _EmptyActivityCardRepository(),
        chapterClosureService: service,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

Future<void> _openOverflow(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('activity_card_hub_overflow')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the overflow is the only way in, and holds one item', (
    WidgetTester tester,
  ) async {
    await _pumpHub(tester);

    // Nothing proposes the closure on its own (AC-16). The hub's own quick
    // capture action stays what it is; what must not exist is a second, always
    // visible way into the closing flow.
    expect(find.textContaining('ngăn'), findsNothing);
    expect(find.byKey(const Key('activity_card_hub_close_chapter')),
        findsNothing);
    expect(find.byKey(const Key('close_chapter_dialog')), findsNothing);

    await _openOverflow(tester);
    expect(find.byType(PopupMenuItem<String>), findsOneWidget);
    expect(find.text('Đóng ngăn gọn gàng'), findsOneWidget);
  });

  testWidgets('one confirmation closes the chapter exactly once', (
    WidgetTester tester,
  ) async {
    final _RecordingClosureService service = await _pumpHub(tester);

    await _openOverflow(tester);
    await tester.tap(find.byKey(const Key('activity_card_hub_close_chapter')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('close_chapter_dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('close_chapter_confirm')));
    await tester.pumpAndSettle();

    // No second prompt, no survey, no consolation screen (AC-2, AC-5).
    expect(find.byKey(const Key('close_chapter_dialog')), findsNothing);
    expect(service.closeCalls, 1);
    expect(service.reopenCalls, 0);
  });

  testWidgets('confirmation is followed by one neutral line, no way back in', (
    WidgetTester tester,
  ) async {
    await _pumpHub(tester);

    await _openOverflow(tester);
    await tester.tap(find.byKey(const Key('activity_card_hub_close_chapter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close_chapter_confirm')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('close_chapter_done')), findsOneWidget);
    // AC-3/AC-16: it reports, it does not console and it does not invite the
    // user back into the closed drawer.
    expect(find.textContaining('Mở lại'), findsNothing);
    expect(find.textContaining('nhớ'), findsNothing);
    // AC-30: the hub is still standing underneath and still usable.
    expect(find.byKey(const Key('activity_card_hub')), findsOneWidget);
  });

  testWidgets('cancelling writes nothing', (WidgetTester tester) async {
    final _RecordingClosureService service = await _pumpHub(tester);

    await _openOverflow(tester);
    await tester.tap(find.byKey(const Key('activity_card_hub_close_chapter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close_chapter_cancel')));
    await tester.pumpAndSettle();

    expect(service.closeCalls, 0);
    expect(find.byKey(const Key('close_chapter_done')), findsNothing);
    expect(find.byKey(const Key('activity_card_hub')), findsOneWidget);
  });
}
