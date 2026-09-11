import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/activity_card_detail_cubit.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/time_of_day_slot_picker.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keeps the last snapshot it was written, so a test can read the column back
/// the way the store would rather than trusting the cubit's own state.
class _StoringRepository implements ActivityCardRepository {
  ActivityCardEdit? lastEdit;
  int writes = 0;

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async {
    lastEdit = edit;
    writes++;
    return 1;
  }

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 1;

  @override
  Future<int> clearScheduledDate(String cardId) async => 1;

  @override
  Future<int> deleteCard(String id) async => 1;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw UnimplementedError();

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError();

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError();

  @override
  Future<ActivityCard?> cardById(String id) => throw UnimplementedError();

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() =>
      throw UnimplementedError();
}

ActivityCard _card() {
  final DateTime now = DateTime(2026, 9, 10);
  return ActivityCard(
    id: 'card-1',
    ownerKey: 'owner-1',
    title: 'Cà phê sách Hào Nam',
    status: ActivityCardStatus.scheduled,
    origin: ActivityCardOrigin.manual,
    activityType: ActivityType.dining,
    scheduledOn: '2026-10-01',
    note: 'Quán nhỏ.',
    invited: false,
    replyState: ActivityCardReplyState.notAnswered,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('editTimeOfDaySlot', () {
    test('writes each of the four slots and reads back what was stored',
        () async {
      for (final TimeOfDaySlot slot in TimeOfDaySlot.values) {
        final _StoringRepository repository = _StoringRepository();
        final ActivityCardDetailCubit cubit = ActivityCardDetailCubit(
          card: _card(),
          repository: repository,
        );

        await cubit.editTimeOfDaySlot(slot);

        expect(repository.lastEdit!.timeOfDaySlot, slot, reason: slot.name);
        expect(cubit.state.card.timeOfDaySlot, slot, reason: slot.name);
        await cubit.close();
      }
    });

    test('*Chưa rõ* clears the column instead of leaving the old slot',
        () async {
      final _StoringRepository repository = _StoringRepository();
      final ActivityCardDetailCubit cubit = ActivityCardDetailCubit(
        card: _card(),
        repository: repository,
      );

      await cubit.editTimeOfDaySlot(TimeOfDaySlot.evening);
      await cubit.editTimeOfDaySlot(null);

      expect(repository.lastEdit!.timeOfDaySlot, isNull);
      expect(cubit.state.card.timeOfDaySlot, isNull);
      expect(repository.writes, 2);
      await cubit.close();
    });

    test('the slot survives an unrelated edit', () async {
      final _StoringRepository repository = _StoringRepository();
      final ActivityCardDetailCubit cubit = ActivityCardDetailCubit(
        card: _card(),
        repository: repository,
      );

      await cubit.editTimeOfDaySlot(TimeOfDaySlot.noon);
      await cubit.editTitle('Cà phê sách, tầng hai');

      expect(repository.lastEdit!.timeOfDaySlot, TimeOfDaySlot.noon);
      await cubit.close();
    });
  });

  group('timeOfDaySlotForChoice', () {
    test('is total over the five choices and maps *Chưa rõ* to null', () {
      expect(TimeOfDaySlotChoice.values, hasLength(5));
      expect(
        <TimeOfDaySlot?>[
          for (final TimeOfDaySlotChoice choice in TimeOfDaySlotChoice.values)
            timeOfDaySlotForChoice(choice),
        ],
        <TimeOfDaySlot?>[
          TimeOfDaySlot.morning,
          TimeOfDaySlot.noon,
          TimeOfDaySlot.afternoon,
          TimeOfDaySlot.evening,
          null,
        ],
      );
    });
  });
}
