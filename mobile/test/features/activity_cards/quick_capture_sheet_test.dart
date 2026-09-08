import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/quick_capture_sheet.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every draft the capture path submits, so the AC assertions read the
/// contract that reached `createCard` rather than the rendered text.
class _RecordingRepository implements ActivityCardRepository {
  final List<NewActivityCard> drafts = <NewActivityCard>[];

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async {
    drafts.add(draft);
    final DateTime now = DateTime(2026, 9, 8);
    return ActivityCard(
      id: 'card-${drafts.length}',
      ownerKey: 'owner-1',
      // Mirrors the repository's AC-7 defaulting so a blank title still yields
      // a displayable card here.
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
  }) async => const <ActivityCard>[];

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async* {
    yield const <ActivityCard>[];
  }

  @override
  Future<ActivityCard?> cardById(String id) async => null;

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async =>
      const <ActivityCardStatus, int>{};

  @override
  Future<int> deleteCard(String id) async => 0;

  @override
  Future<void> updateStatus(String cardId, ActivityCardStatus status) =>
      throw UnimplementedError('not exercised by quick capture');

  @override
  Future<void> clearScheduledDate(String cardId) =>
      throw UnimplementedError('not exercised by quick capture');
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

void main() {
  group('QuickCaptureSheet', () {
    testWidgets('asks for exactly one field and no form (AC-1)', (
      WidgetTester tester,
    ) async {
      final _RecordingRepository repository = _RecordingRepository();
      await _openSheet(tester, repository, QuickCaptureMode.title);

      expect(
        find.byKey(const Key('activity_quick_capture_field')),
        findsOneWidget,
      );
      expect(find.byType(EditableText), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(Form), findsNothing);
    });

    testWidgets('saves on submit with no confirm button (AC-6)', (
      WidgetTester tester,
    ) async {
      final _RecordingRepository repository = _RecordingRepository();
      await _openSheet(tester, repository, QuickCaptureMode.title);

      // Nothing else in the sheet is tappable: the field is the whole
      // interaction, so there is no second step between typing and the card.
      expect(find.byType(ButtonStyleButton), findsNothing);

      await tester.enterText(
        find.byKey(const Key('activity_quick_capture_field')),
        '  Đi ăn bún chả  ',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repository.drafts, hasLength(1));
      expect(repository.drafts.single.title, 'Đi ăn bún chả');
      expect(repository.drafts.single.origin, ActivityCardOrigin.manual);
      expect(repository.drafts.single.sourceLink, isNull);
      expect(
        find.byKey(const Key('activity_quick_capture_sheet')),
        findsNothing,
      );
    });

    testWidgets('a bare link with no title becomes a card (AC-7)', (
      WidgetTester tester,
    ) async {
      final _RecordingRepository repository = _RecordingRepository();
      await _openSheet(tester, repository, QuickCaptureMode.link);

      await tester.enterText(
        find.byKey(const Key('activity_quick_capture_field')),
        'https://tiktok.com/@quan/video/1',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repository.drafts, hasLength(1));
      final NewActivityCard draft = repository.drafts.single;
      expect(draft.origin, ActivityCardOrigin.pastedLink);
      expect(draft.sourceLink, 'https://tiktok.com/@quan/video/1');
      // Blank on purpose: defaulting a title off the host is the repository's
      // job, so the UI never blocks the save on a field the user did not give.
      expect(draft.title, isEmpty);
    });

    testWidgets('an empty submit writes nothing', (WidgetTester tester) async {
      final _RecordingRepository repository = _RecordingRepository();
      await _openSheet(tester, repository, QuickCaptureMode.title);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repository.drafts, isEmpty);
    });
  });

  group('QuickCaptureAddAction', () {
    testWidgets('is hidden while the store is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          Scaffold(
            body: QuickCaptureAddAction(
              repository: _RecordingRepository(),
              storeCount: 0,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('activity_quick_capture_add')), findsNothing);
      expect(
        find.byKey(const Key('activity_quick_capture_add_hidden')),
        findsOneWidget,
      );
    });

    testWidgets('appears once the store holds a card and captures a title', (
      WidgetTester tester,
    ) async {
      final _RecordingRepository repository = _RecordingRepository();
      final List<ActivityCard> created = <ActivityCard>[];
      await tester.pumpWidget(
        _host(
          Scaffold(
            body: Center(
              child: QuickCaptureAddAction(
                repository: repository,
                storeCount: 1,
                onCardCreated: created.add,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('activity_quick_capture_add')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('activity_quick_capture_add')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('activity_quick_capture_field')),
        'Mua hoa',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repository.drafts.single.title, 'Mua hoa');
      expect(created, hasLength(1));
    });
  });
}

Future<void> _openSheet(
  WidgetTester tester,
  ActivityCardRepository repository,
  QuickCaptureMode mode,
) async {
  await tester.pumpWidget(
    _host(
      Scaffold(
        body: Builder(
          builder: (BuildContext context) => GestureDetector(
            key: const Key('open_sheet'),
            behavior: HitTestBehavior.opaque,
            onTap: () => QuickCaptureSheet.show(
              context,
              mode: mode,
              repository: repository,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.tap(find.byKey(const Key('open_sheet')));
  await tester.pumpAndSettle();
}
