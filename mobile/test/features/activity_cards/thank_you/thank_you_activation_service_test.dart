import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/thank_you_activation_dao.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/thank_you_activation_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation_card_status_listener.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation_service.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The lifecycle runs against a real in-memory drift database rather than a
/// fake repository: `arm` relies on `INSERT OR IGNORE` and `cancel`/`consume`
/// rely on a `status = 'armed'` predicate, so a hand-written fake would be
/// asserting the fake's own rules instead of the ones that ship.
void main() {
  late CupidDatabase database;
  late DateTime clock;
  late ThankYouActivationService service;

  Future<void> seedCard(String id) async {
    await database.into(database.activityCards).insert(
          ActivityCardsCompanion.insert(
            id: id,
            ownerKey: 'user-1',
            title: 'Đi ăn lẩu',
            origin: 'manual',
            status: const Value('done'),
            createdAt: DateTime.utc(2026, 9, 20),
            updatedAt: DateTime.utc(2026, 9, 20),
          ),
        );
  }

  Future<ThankYouActivation?> activation(String cardId) {
    return ThankYouActivationRepositoryImpl(ThankYouActivationDao(database))
        .activationFor(cardId);
  }

  setUp(() async {
    database = CupidDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 9, 20, 21, 30);
    service = ThankYouActivationService(
      ThankYouActivationRepositoryImpl(ThankYouActivationDao(database)),
      now: () => clock,
    );
    await seedCard('card-1');
  });

  tearDown(() async {
    await database.close();
  });

  group('năm chuyển trạng thái của một lượt trọn đời (BR-2)', () {
    test('arm ghi đúng một bản ghi ARMED theo ngày lịch địa phương (AC-1)',
        () async {
      await service.arm('card-1');

      final stored = await activation('card-1');
      expect(stored!.status, ThankYouActivationStatus.armed);
      expect(stored.armedOn, '2026-09-20');
      expect(stored.consumedAt, isNull);
    });

    test('isEligible sai trong cùng ngày arm (AC-2)', () async {
      await service.arm('card-1');

      expect(await service.isEligible('card-1'), isFalse);
    });

    test('isEligible đúng từ ngày lịch kế tiếp (AC-1)', () async {
      await service.arm('card-1');
      clock = DateTime(2026, 9, 21, 7, 0);

      expect(await service.isEligible('card-1'), isTrue);
    });

    test('consume rồi arm lại là no-op — CONSUMED hấp thụ (AC-3, AC-4)',
        () async {
      await service.arm('card-1');
      clock = DateTime(2026, 9, 21, 7, 0);
      await service.consume('card-1');

      clock = DateTime(2026, 9, 25, 9, 0);
      await service.arm('card-1');

      final stored = await activation('card-1');
      expect(stored!.status, ThankYouActivationStatus.consumed);
      expect(stored.armedOn, '2026-09-20');
      expect(await service.isEligible('card-1'), isFalse);
    });

    test('rời Đã đi rồi khi còn ARMED huỷ lặng lẽ, arm lại là no-op (AC-5)',
        () async {
      await service.arm('card-1');
      await service.cancel('card-1');

      clock = DateTime(2026, 9, 22, 9, 0);
      await service.arm('card-1');

      final stored = await activation('card-1');
      expect(stored!.status, ThankYouActivationStatus.cancelled);
      expect(await service.isEligible('card-1'), isFalse);
    });
  });

  group('biên ngày lịch địa phương (AC-1 vs AC-2)', () {
    test('cùng một thẻ ở 23:59 và 00:01 cho kết quả isEligible khác nhau',
        () async {
      clock = DateTime(2026, 9, 20, 23, 59);
      await service.arm('card-1');
      final atNightOfArming = await service.isEligible('card-1');

      clock = DateTime(2026, 9, 21, 0, 1);
      final twoMinutesLater = await service.isEligible('card-1');

      expect(atNightOfArming, isFalse);
      expect(twoMinutesLater, isTrue);
    });

    test('lượt đã tiêu thụ không sống lại khi đồng hồ lùi về ngày arm',
        () async {
      clock = DateTime(2026, 9, 20, 23, 59);
      await service.arm('card-1');
      clock = DateTime(2026, 9, 21, 0, 1);
      await service.consume('card-1');

      clock = DateTime(2026, 9, 20, 20, 0);

      expect(await service.isEligible('card-1'), isFalse);
    });

    test('isEligible sai khi thẻ chưa từng có lượt nào', () async {
      expect(await service.isEligible('card-1'), isFalse);
    });
  });

  group('consume idempotent (solution.md §4)', () {
    test('gọi hai lần không đổi consumedAt', () async {
      await service.arm('card-1');
      clock = DateTime(2026, 9, 21, 7, 0);
      await service.consume('card-1');
      final firstConsumedAt = (await activation('card-1'))!.consumedAt;

      clock = DateTime(2026, 9, 21, 19, 45);
      await service.consume('card-1');

      expect(firstConsumedAt, DateTime(2026, 9, 21, 7, 0));
      expect((await activation('card-1'))!.consumedAt, firstConsumedAt);
    });

    test('consume trên một lượt đã huỷ là no-op — CANCELLED hấp thụ (AC-5)',
        () async {
      await service.arm('card-1');
      await service.cancel('card-1');

      clock = DateTime(2026, 9, 21, 7, 0);
      await service.consume('card-1');

      final stored = await activation('card-1');
      expect(stored!.status, ThankYouActivationStatus.cancelled);
      expect(stored.consumedAt, isNull);
    });
  });

  group('không phạt im lặng (AC-25)', () {
    test('bỏ qua khối không sinh bản ghi nào ngoài chính lượt kích hoạt',
        () async {
      await service.arm('card-1');
      clock = DateTime(2026, 9, 21, 7, 0);
      await service.consume('card-1');

      final rows = await database.select(database.thankYouActivations).get();
      expect(rows, hasLength(1));

      final card = await (database.select(database.activityCards)
            ..where((row) => row.id.equals('card-1')))
          .getSingle();
      expect(card.status, 'done');
      expect(card.updatedAt.toUtc(), DateTime.utc(2026, 9, 20));
    });

    test('huỷ lặng lẽ không để lại dấu vết trên thẻ', () async {
      await service.arm('card-1');
      await service.cancel('card-1');

      final card = await (database.select(database.activityCards)
            ..where((row) => row.id.equals('card-1')))
          .getSingle();
      expect(card.replyState, 'not_answered');
      expect(card.updatedAt.toUtc(), DateTime.utc(2026, 9, 20));
    });
  });

  group('nối vào tín hiệu đổi trạng thái thẻ của STORY-001 (AC-14)', () {
    late ThankYouActivationCardStatusListener listener;

    setUp(() {
      listener = ThankYouActivationCardStatusListener(service);
    });

    test('chuyển sang done thì arm', () async {
      await listener.onCardStatusChanged(
        cardId: 'card-1',
        status: ActivityCardStatus.done,
      );

      expect((await activation('card-1'))!.status,
          ThankYouActivationStatus.armed);
    });

    test('rời done thì huỷ lượt đang chờ', () async {
      await listener.onCardStatusChanged(
        cardId: 'card-1',
        status: ActivityCardStatus.done,
      );
      await listener.onCardStatusChanged(
        cardId: 'card-1',
        status: ActivityCardStatus.scheduled,
      );

      expect((await activation('card-1'))!.status,
          ThankYouActivationStatus.cancelled);
    });

    test('vòng done -> scheduled -> done sau khi đã tiêu thụ không tạo lượt '
        'thứ hai (AC-4)', () async {
      await listener.onCardStatusChanged(
        cardId: 'card-1',
        status: ActivityCardStatus.done,
      );
      clock = DateTime(2026, 9, 21, 7, 0);
      await service.consume('card-1');

      await listener.onCardStatusChanged(
        cardId: 'card-1',
        status: ActivityCardStatus.scheduled,
      );
      await listener.onCardStatusChanged(
        cardId: 'card-1',
        status: ActivityCardStatus.done,
      );

      clock = DateTime(2026, 9, 22, 7, 0);
      final stored = await activation('card-1');
      expect(stored!.status, ThankYouActivationStatus.consumed);
      expect(await service.isEligible('card-1'), isFalse);
    });
  });
}
