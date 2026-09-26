import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/thank_you_activation_dao.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/thank_you_activation_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation_card_status_listener.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation_card_status_repository.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The lifecycle tests next door drive [ThankYouActivationCardStatusListener]
/// by hand, which passes even when nothing in the app ever calls it. These
/// drive the card store the app itself resolves, so they fail if the ledger is
/// ever unplugged from STORY-001's status signal again (AC-14).
void main() {
  late CupidDatabase database;
  late ActivityCardRepository repository;

  Future<ThankYouActivation?> activation(String cardId) {
    return ThankYouActivationRepositoryImpl(ThankYouActivationDao(database))
        .activationFor(cardId);
  }

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    repository = ThankYouActivationAwareCardRepository(
      inner: ActivityCardRepositoryImpl(
        dao: database.activityCardDao,
        ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
      ),
      listener: ThankYouActivationCardStatusListener(
        ThankYouActivationService(
          ThankYouActivationRepositoryImpl(ThankYouActivationDao(database)),
        ),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<ActivityCard> createCard() => repository.createCard(
        const NewActivityCard(
          title: 'Đi ăn lẩu',
          origin: ActivityCardOrigin.manual,
        ),
      );

  test('thẻ sang *Đã đi rồi* qua chính card store của app thì có hàng ARMED '
      '— không cần nối tay (AC-1, AC-14)', () async {
    final card = await createCard();

    await repository.updateStatus(card.id, ActivityCardStatus.done);

    final stored = await activation(card.id);
    expect(stored, isNotNull);
    expect(stored!.status, ThankYouActivationStatus.armed);
  });

  test('rời *Đã đi rồi* qua card store thì lượt đang chờ bị huỷ lặng lẽ '
      '(AC-5)', () async {
    final card = await createCard();

    await repository.updateStatus(card.id, ActivityCardStatus.done);
    await repository.updateStatus(card.id, ActivityCardStatus.scheduled);

    expect((await activation(card.id))!.status,
        ThankYouActivationStatus.cancelled);
  });

  test('thẻ của chủ khác không ghi được trạng thái nên cũng không arm '
      '(AC-22)', () async {
    await database.into(database.activityCards).insert(
          ActivityCardsCompanion.insert(
            id: 'card-cua-nguoi-khac',
            ownerKey: 'user-2',
            title: 'Không phải thẻ của mình',
            origin: 'manual',
            createdAt: DateTime.utc(2026, 9, 20),
            updatedAt: DateTime.utc(2026, 9, 20),
          ),
        );

    final rows = await repository.updateStatus(
      'card-cua-nguoi-khac',
      ActivityCardStatus.done,
    );

    expect(rows, 0);
    expect(await activation('card-cua-nguoi-khac'), isNull);
  });

  test('các thao tác còn lại của card store đi thẳng qua lớp bọc', () async {
    final card = await createCard();

    expect((await repository.cardById(card.id))!.title, 'Đi ăn lẩu');
    expect(
      await repository.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: 10,
      ),
      hasLength(1),
    );
    expect(await repository.countsByStatus(),
        containsPair(ActivityCardStatus.idea, 1));
    expect(await repository.deleteCard(card.id), 1);
  });
}
