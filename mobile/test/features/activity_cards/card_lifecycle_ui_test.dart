import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/activity_card_detail_cubit.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_detail_screen.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/status_change_picker.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every write the cubit makes, in order. The AC-15 assertions are
/// about what is *not* written, so an exact call log is the measurable form of
/// "the saved date and the note survived".
class _RecordingRepository implements ActivityCardRepository {
  _RecordingRepository({this.failWrites = false});

  final bool failWrites;
  final List<String> calls = <String>[];

  @override
  Future<void> updateStatus(String cardId, ActivityCardStatus status) async {
    calls.add('updateStatus:$cardId:${status.wireValue}');
    if (failWrites) {
      throw StateError('store unavailable');
    }
  }

  @override
  Future<void> clearScheduledDate(String cardId) async {
    calls.add('clearScheduledDate:$cardId');
    if (failWrites) {
      throw StateError('store unavailable');
    }
  }

  @override
  Future<int> deleteCard(String id) async {
    calls.add('deleteCard:$id');
    if (failWrites) {
      throw StateError('store unavailable');
    }
    return 1;
  }

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw UnimplementedError('detail screen never creates');

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('detail screen never lists');

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('detail screen never lists');

  @override
  Future<ActivityCard?> cardById(String id) =>
      throw UnimplementedError('the card is handed in, not fetched');

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() =>
      throw UnimplementedError('detail screen never counts');
}

ActivityCard _card({
  ActivityCardStatus status = ActivityCardStatus.idea,
  String? scheduledOn,
  String? note,
  bool invited = false,
  ActivityCardReplyState replyState = ActivityCardReplyState.notAnswered,
}) {
  final DateTime now = DateTime(2026, 9, 8);
  return ActivityCard(
    id: 'card-1',
    ownerKey: 'owner-1',
    title: 'Cà phê sách Hào Nam',
    status: status,
    origin: ActivityCardOrigin.manual,
    activityType: ActivityType.dining,
    scheduledOn: scheduledOn,
    priceVnd: 120000,
    distanceKm: 3.5,
    note: note,
    invited: invited,
    replyState: replyState,
    createdAt: now,
    updatedAt: now,
  );
}

ActivityCardDetailCubit _cubit(
  _RecordingRepository repository, {
  ActivityCard? card,
}) =>
    ActivityCardDetailCubit(
      repository: repository,
      card: card ?? _card(),
    );

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

void main() {
  const CupidColorTokens colors = CupidColorTokens.dark();

  group('AC-12 · one gesture sets the date and the status', () {
    test('picking a date saves it and moves the card to Đã hẹn ngày', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(repository);

      await cubit.scheduleDate('2026-10-01');

      expect(cubit.state.card.scheduledOn, '2026-10-01');
      expect(cubit.state.card.status, ActivityCardStatus.scheduled);
      // One write, not "save the date" then "now change the status".
      expect(repository.calls, <String>['updateStatus:card-1:scheduled']);
      await cubit.close();
    });
  });

  group('AC-14 · the lifecycle runs in both directions', () {
    test('every status reaches every other status in one step', () async {
      for (final ActivityCardStatus from in ActivityCardStatus.values) {
        for (final ActivityCardStatus to in ActivityCardStatus.values) {
          if (from == to) {
            continue;
          }
          final _RecordingRepository repository = _RecordingRepository();
          // No saved date, so no transition here is the AC-15 special case.
          final ActivityCardDetailCubit cubit =
              _cubit(repository, card: _card(status: from));

          await cubit.changeStatus(to);

          expect(
            cubit.state.card.status,
            to,
            reason: '${from.wireValue} -> ${to.wireValue} must be reachable',
          );
          expect(cubit.state.pendingRegression, isNull);
          expect(repository.calls, <String>['updateStatus:card-1:${to.wireValue}']);
          await cubit.close();
        }
      }
    });

    test('re-picking the current status writes nothing', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(repository);

      await cubit.changeStatus(ActivityCardStatus.idea);

      expect(repository.calls, isEmpty);
      await cubit.close();
    });
  });

  group('AC-15 · no silent data loss when the status goes backwards', () {
    test('the regression parks and writes nothing until answered', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(
        repository,
        card: _card(
          status: ActivityCardStatus.scheduled,
          scheduledOn: '2026-10-01',
          note: 'Nhớ đặt bàn tầng 2',
        ),
      );

      await cubit.changeStatus(ActivityCardStatus.idea);

      expect(cubit.state.pendingRegression, ActivityCardStatus.idea);
      expect(cubit.state.card.status, ActivityCardStatus.scheduled);
      expect(cubit.state.card.scheduledOn, '2026-10-01');
      expect(repository.calls, isEmpty);
      await cubit.close();
    });

    test('"giữ ngày hẹn" moves the status and touches nothing else', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(
        repository,
        card: _card(
          status: ActivityCardStatus.scheduled,
          scheduledOn: '2026-10-01',
          note: 'Nhớ đặt bàn tầng 2',
        ),
      );

      await cubit.changeStatus(ActivityCardStatus.idea);
      await cubit.resolveRegression(ScheduledDateChoice.keep);

      expect(cubit.state.card.status, ActivityCardStatus.idea);
      expect(cubit.state.card.scheduledOn, '2026-10-01');
      expect(cubit.state.card.note, 'Nhớ đặt bàn tầng 2');
      // The whole point: the status column is the only thing written, so the
      // date, the note and the card's photo rows are all still there.
      expect(repository.calls, <String>['updateStatus:card-1:idea']);
      await cubit.close();
    });

    test('"xoá ngày hẹn" is the only path that drops the date', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(
        repository,
        card: _card(
          status: ActivityCardStatus.scheduled,
          scheduledOn: '2026-10-01',
          note: 'Nhớ đặt bàn tầng 2',
        ),
      );

      await cubit.changeStatus(ActivityCardStatus.idea);
      await cubit.resolveRegression(ScheduledDateChoice.clear);

      expect(cubit.state.card.status, ActivityCardStatus.idea);
      expect(cubit.state.card.scheduledOn, isNull);
      expect(cubit.state.card.note, 'Nhớ đặt bàn tầng 2');
      expect(repository.calls, <String>[
        'clearScheduledDate:card-1',
        'updateStatus:card-1:idea',
      ]);
      await cubit.close();
    });

    test('dismissing the question leaves the card exactly as it was', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(
        repository,
        card: _card(
          status: ActivityCardStatus.scheduled,
          scheduledOn: '2026-10-01',
        ),
      );

      await cubit.changeStatus(ActivityCardStatus.idea);
      cubit.cancelRegression();

      expect(cubit.state.pendingRegression, isNull);
      expect(cubit.state.card.status, ActivityCardStatus.scheduled);
      expect(cubit.state.card.scheduledOn, '2026-10-01');
      expect(repository.calls, isEmpty);
      await cubit.close();
    });

    test('a regression with no saved date asks nothing', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(
        repository,
        card: _card(status: ActivityCardStatus.scheduled),
      );

      await cubit.changeStatus(ActivityCardStatus.idea);

      expect(cubit.state.pendingRegression, isNull);
      expect(cubit.state.card.status, ActivityCardStatus.idea);
      await cubit.close();
    });

    testWidgets('the dialog offers two explicit branches and no default',
        (WidgetTester tester) async {
      final _RecordingRepository repository = _RecordingRepository();
      await tester.pumpWidget(
        _host(
          ActivityCardDetailScreen(
            card: _card(
              status: ActivityCardStatus.scheduled,
              scheduledOn: '2026-10-01',
            ),
            repository: repository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('card_detail_change_status_row')),
      );
      await tester.tap(find.byKey(const Key('card_detail_change_status_row')));
      await tester.pumpAndSettle();

      // AC-14: all four statuses on offer, in both directions.
      for (final ActivityCardStatus status in ActivityCardStatus.values) {
        expect(
          find.byKey(Key('status_change_option_${status.name}')),
          findsOneWidget,
        );
      }

      await tester.tap(find.byKey(const Key('status_change_option_idea')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('scheduled_date_choice_dialog')),
        findsOneWidget,
      );
      expect(find.text('Giữ ngày hẹn đã lưu hay xoá luôn?'), findsOneWidget);

      final Finder keep = find.byKey(const Key('scheduled_date_choice_keep'));
      final Finder clear = find.byKey(const Key('scheduled_date_choice_clear'));
      expect(keep, findsOneWidget);
      expect(clear, findsOneWidget);
      // Two branches, no third, and no button that acts as a default: neither
      // is an ElevatedButton and nothing is autofocused, so no Enter key and
      // no "confirm" gesture can reach the destructive branch on its own.
      expect(find.byType(ActivityDialogChoiceButton), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(repository.calls, isEmpty);

      await tester.tap(keep);
      await tester.pumpAndSettle();

      expect(repository.calls, <String>['updateStatus:card-1:idea']);
    });
  });

  group('AC-16 · deleting is one plain dialog', () {
    test('confirming deletes the card and its photos through the store',
        () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(repository);

      await cubit.deleteCard();

      expect(repository.calls, <String>['deleteCard:card-1']);
      expect(cubit.state.deleted, isTrue);
      await cubit.close();
    });

    testWidgets('the dialog asks once, without a reason field or a plea',
        (WidgetTester tester) async {
      final _RecordingRepository repository = _RecordingRepository();
      await tester.pumpWidget(
        _host(
          ActivityCardDetailScreen(card: _card(), repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('card_detail_delete_row')),
      );
      await tester.tap(find.byKey(const Key('card_detail_delete_row')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('delete_card_dialog')), findsOneWidget);
      expect(find.text('Xoá thẻ này?'), findsOneWidget);

      final Finder dialog = find.byKey(const Key('delete_card_dialog'));
      // No reason field and no second step.
      expect(
        find.descendant(of: dialog, matching: find.byType(EditableText)),
        findsNothing,
      );
      // Exactly two choices, drawn identically.
      expect(
        find.descendant(
          of: dialog,
          matching: find.byType(ActivityDialogChoiceButton),
        ),
        findsNWidgets(2),
      );
      expect(find.text('Huỷ'), findsOneWidget);
      expect(find.text('Xoá'), findsOneWidget);

      final TextStyle cancelStyle = tester.widget<Text>(find.text('Huỷ')).style!;
      final TextStyle deleteStyle = tester.widget<Text>(find.text('Xoá')).style!;
      expect(deleteStyle.fontSize, cancelStyle.fontSize);
      expect(deleteStyle.fontWeight, cancelStyle.fontWeight);
      // Colour is the only difference, and only the destructive label carries
      // it — the surface behind them stays neutral.
      expect(deleteStyle.color, colors.colorRed);
      expect(cancelStyle.color, isNot(colors.colorRed));
      expect(
        tester.widget<AlertDialog>(dialog).backgroundColor,
        colors.colorSurface,
      );

      // No copy that argues with the decision.
      for (final String plea in <String>['chắc', 'tiếc', 'không thể hoàn tác']) {
        expect(
          find.textContaining(plea, findRichText: true),
          findsNothing,
          reason: 'the delete dialog must not plead with the user',
        );
      }

      await tester.tap(find.byKey(const Key('delete_card_cancel')));
      await tester.pumpAndSettle();
      expect(repository.calls, isEmpty);

      await tester.tap(find.byKey(const Key('card_detail_delete_row')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_card_confirm')));
      await tester.pumpAndSettle();
      expect(repository.calls, <String>['deleteCard:card-1']);
    });
  });

  group('AC-17/AC-18 · "đã rủ" is a flag the user sets', () {
    test('it has exactly two values and never writes a timestamp', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(repository);

      expect(cubit.state.card.invited, isFalse);
      cubit.toggleInvited();
      expect(cubit.state.card.invited, isTrue);
      cubit.toggleInvited();
      expect(cubit.state.card.invited, isFalse);

      cubit.toggleReplyState();
      expect(cubit.state.card.replyState, ActivityCardReplyState.answered);
      cubit.toggleReplyState();
      expect(cubit.state.card.replyState, ActivityCardReplyState.notAnswered);

      // Nothing about the other person is recorded, inferred, or written.
      expect(repository.calls, isEmpty);
      expect(cubit.state.card.updatedAt, DateTime(2026, 9, 8));
      await cubit.close();
    });

    testWidgets('the chip moves only on a tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          ActivityCardDetailScreen(
            card: _card(),
            repository: _RecordingRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder chip = find.byKey(const Key('card_detail_invited_chip'));
      await tester.ensureVisible(chip);
      expect(find.text('Chưa rủ'), findsOneWidget);
      // The reply flag only exists once an invitation was actually sent.
      expect(find.byKey(const Key('card_detail_reply_chip')), findsNothing);

      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.text('Đã rủ'), findsOneWidget);
      expect(find.byKey(const Key('card_detail_reply_chip')), findsOneWidget);

      // Time passing on its own changes nothing.
      await tester.pump(const Duration(hours: 6));
      expect(find.text('Đã rủ'), findsOneWidget);
    });
  });

  group('card fields', () {
    test('each SB-76 field is editable and clearable', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = _cubit(repository);

      cubit.editTitle('Cà phê sách Hào Nam (đổi)');
      cubit.editNote('đi buổi chiều');
      cubit.editSourceLink('https://maps.app/abc');
      cubit.editActivityType(ActivityType.walk);
      cubit.editPriceVnd(90000);
      cubit.editDistanceKm(1.2);
      cubit.editNeedsBooking(true);
      cubit.editIndoorOutdoor(ActivityCardIndoorOutdoor.outdoor);
      cubit.editScheduledOn('2026-11-02');

      final ActivityCard edited = cubit.state.card;
      expect(edited.title, 'Cà phê sách Hào Nam (đổi)');
      expect(edited.note, 'đi buổi chiều');
      expect(edited.sourceLink, 'https://maps.app/abc');
      expect(edited.activityType, ActivityType.walk);
      expect(edited.priceVnd, 90000);
      expect(edited.distanceKm, 1.2);
      expect(edited.needsBooking, isTrue);
      expect(edited.indoorOutdoor, ActivityCardIndoorOutdoor.outdoor);
      expect(edited.scheduledOn, '2026-11-02');

      cubit.editNote(null);
      cubit.editPriceVnd(null);
      cubit.editActivityType(null);
      cubit.editIndoorOutdoor(null);
      cubit.editScheduledOn(null);

      final ActivityCard cleared = cubit.state.card;
      expect(cleared.note, isNull);
      expect(cleared.priceVnd, isNull);
      expect(cleared.activityType, isNull);
      expect(cleared.indoorOutdoor, isNull);
      expect(cleared.scheduledOn, isNull);
      // Field edits are screen-local until a field writer exists in the
      // repository contract; nothing pretends otherwise by calling the store.
      expect(repository.calls, isEmpty);
      await cubit.close();
    });
  });

  group('write failures', () {
    test('a failed status write leaves the card where it was', () async {
      final _RecordingRepository repository =
          _RecordingRepository(failWrites: true);
      final ActivityCardDetailCubit cubit = _cubit(repository);

      await cubit.changeStatus(ActivityCardStatus.done);

      expect(cubit.state.failed, isTrue);
      expect(cubit.state.card.status, ActivityCardStatus.idea);
      await cubit.close();
    });

    test('a failed delete does not report the card as gone', () async {
      final _RecordingRepository repository =
          _RecordingRepository(failWrites: true);
      final ActivityCardDetailCubit cubit = _cubit(repository);

      await cubit.deleteCard();

      expect(cubit.state.deleted, isFalse);
      expect(cubit.state.failed, isTrue);
      await cubit.close();
    });
  });
}
