import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/activity_card_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingRepository implements ActivityCardRepository {
  final List<ActivityCardEdit> edits = <ActivityCardEdit>[];
  final List<ActivityCardStatus> statuses = <ActivityCardStatus>[];

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async {
    edits.add(edit);
    return 1;
  }

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async {
    statuses.add(status);
    return 1;
  }

  @override
  Future<int> clearScheduledDate(String cardId) async => 1;

  @override
  Future<int> deleteCard(String id) async => 1;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw UnimplementedError('the cubit never creates');

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('the cubit never lists');

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('the cubit never lists');

  @override
  Future<ActivityCard?> cardById(String id) =>
      throw UnimplementedError('the card is handed in, not fetched');

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() =>
      throw UnimplementedError('the cubit never counts');
}

ActivityCard _card({String? location}) => ActivityCard(
      id: 'card-1',
      ownerKey: 'owner-1',
      title: 'Cà phê sách Hào Nam',
      status: ActivityCardStatus.scheduled,
      origin: ActivityCardOrigin.manual,
      note: 'Quán nhỏ, có kệ sách cũ ở tầng hai.',
      scheduledOn: '2026-09-20',
      location: location,
      invited: false,
      replyState: ActivityCardReplyState.notAnswered,
      createdAt: DateTime.utc(2026, 9, 1),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

void main() {
  group('BUG-20260910-001 · `location` survives an unrelated edit', () {
    // `updateCardDetails` takes a full snapshot, so a column the cubit forgets
    // to carry forward is written as an explicit `SET location = NULL`. These
    // three cases are the paths that reach `_withEdits`.
    test('a `_persist` edit of another field keeps the saved place', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = ActivityCardDetailCubit(
        repository: repository,
        card: _card(location: 'rạp CGV Vincom Đồng Khởi'),
      );

      await cubit.editTitle('Cà phê sách Hào Nam (mới)');

      expect(repository.edits.single.title, 'Cà phê sách Hào Nam (mới)');
      expect(repository.edits.single.location, 'rạp CGV Vincom Đồng Khởi');
      expect(cubit.state.card.location, 'rạp CGV Vincom Đồng Khởi');
    });

    test('a `_writeStatus` transition keeps the saved place', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = ActivityCardDetailCubit(
        repository: repository,
        card: _card(location: 'rạp CGV Vincom Đồng Khởi'),
      );

      // `scheduled -> done` is not the AC-15 regression, so it writes straight
      // through and re-emits the card from `_withEdits`.
      await cubit.changeStatus(ActivityCardStatus.done);

      expect(repository.statuses, <ActivityCardStatus>[
        ActivityCardStatus.done,
      ]);
      expect(cubit.state.card.location, 'rạp CGV Vincom Đồng Khởi');
    });

    test('a later unrelated edit still carries the just-typed place', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = ActivityCardDetailCubit(
        repository: repository,
        card: _card(),
      );

      await cubit.editLocation('sân thượng nhà mình');
      await cubit.editNote('Nhớ mang áo khoác.');

      expect(repository.edits.first.location, 'sân thượng nhà mình');
      expect(repository.edits.last.location, 'sân thượng nhà mình');
      expect(repository.edits.last.note, 'Nhớ mang áo khoác.');
    });

    test('an emptied place clears the column and stays cleared', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final ActivityCardDetailCubit cubit = ActivityCardDetailCubit(
        repository: repository,
        card: _card(location: 'rạp CGV Vincom Đồng Khởi'),
      );

      await cubit.editLocation(null);
      await cubit.editTitle('Đổi chỗ');

      expect(repository.edits.first.location, isNull);
      expect(repository.edits.last.location, isNull);
      expect(cubit.state.card.location, isNull);
    });
  });
}
