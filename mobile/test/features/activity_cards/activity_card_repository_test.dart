import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CupidDatabase database;
  late BackendUserIdStore ownerKeyStore;
  late ActivityCardRepository repository;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    ownerKeyStore = BackendUserIdStore()..updateUserId('user-1');
    repository = ActivityCardRepositoryImpl(
      dao: database.activityCardDao,
      ownerKeyStore: ownerKeyStore,
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('createCard tối thiểu (AC-6)', () {
    test('only title + origin creates an idea-status card with the agreed '
        'defaults', () async {
      final card = await repository.createCard(
        const NewActivityCard(
          title: 'Đi ăn phở',
          origin: ActivityCardOrigin.manual,
        ),
      );

      expect(card.id, isNotEmpty);
      expect(card.ownerKey, 'user-1');
      expect(card.title, 'Đi ăn phở');
      expect(card.status, ActivityCardStatus.idea);
      expect(card.origin, ActivityCardOrigin.manual);
      expect(card.invited, isFalse);
      expect(card.replyState, ActivityCardReplyState.notAnswered);
      expect(card.activityType, isNull);
      expect(card.scheduledOn, isNull);
      expect(card.note, isNull);
      expect(card.sourceLink, isNull);

      final reread = await repository.cardById(card.id);
      expect(reread, isNotNull);
      expect(reread!.title, 'Đi ăn phở');
    });

    test('two calls produce two different client-generated ids (R-15a: '
        'never a rowid/autoincrement)', () async {
      const draft = NewActivityCard(
        title: 'Xem phim',
        origin: ActivityCardOrigin.manual,
      );

      final first = await repository.createCard(draft);
      final second = await repository.createCard(draft);

      expect(first.id, isNot(second.id));
    });
  });

  group('dán link suy giảm êm (AC-7)', () {
    test('blank title on a pasted link defaults to the URL host, and the '
        'link is kept verbatim', () async {
      final card = await repository.createCard(
        const NewActivityCard(
          title: '',
          origin: ActivityCardOrigin.pastedLink,
          sourceLink: 'https://www.example.com/abc?x=1',
        ),
      );

      expect(card.title, 'www.example.com');
      expect(card.sourceLink, 'https://www.example.com/abc?x=1');
      expect(card.status, ActivityCardStatus.idea);
    });

    test('a non-blank title is kept even when a link is also pasted', () async {
      final card = await repository.createCard(
        const NewActivityCard(
          title: 'Bài viết hay',
          origin: ActivityCardOrigin.pastedLink,
          sourceLink: 'https://blog.example.com/post',
        ),
      );

      expect(card.title, 'Bài viết hay');
      expect(card.sourceLink, 'https://blog.example.com/post');
    });
  });

  group('ma trận chuyển trạng thái 4x4 hai chiều (AC-14, AC-15)', () {
    test('every from/to pair moves the card without touching other columns '
        'or updated_at (updateStatus chỉ ghi cột status)', () async {
      final created = await repository.createCard(
        const NewActivityCard(
          title: 'Đi biển Vũng Tàu',
          origin: ActivityCardOrigin.manual,
          scheduledOn: '2026-09-20',
          note: 'Nhớ mang kem chống nắng',
          priceVnd: 500000,
          distanceKm: 120.5,
          needsBooking: true,
          indoorOutdoor: ActivityCardIndoorOutdoor.outdoor,
        ),
      );
      final originalUpdatedAt = created.updatedAt;

      for (final from in ActivityCardStatus.values) {
        for (final to in ActivityCardStatus.values) {
          await repository.updateStatus(created.id, from);
          await repository.updateStatus(created.id, to);

          final card = await repository.cardById(created.id);
          expect(card, isNotNull);
          expect(
            card!.status,
            to,
            reason: 'transition $from -> $to did not land on $to',
          );
          expect(card.scheduledOn, '2026-09-20', reason: '$from -> $to');
          expect(
            card.note,
            'Nhớ mang kem chống nắng',
            reason: '$from -> $to',
          );
          expect(card.priceVnd, 500000, reason: '$from -> $to');
          expect(card.distanceKm, 120.5, reason: '$from -> $to');
          expect(card.needsBooking, isTrue, reason: '$from -> $to');
          expect(
            card.indoorOutdoor,
            ActivityCardIndoorOutdoor.outdoor,
            reason: '$from -> $to',
          );
          expect(card.invited, isFalse, reason: '$from -> $to');
          expect(
            card.replyState,
            ActivityCardReplyState.notAnswered,
            reason: '$from -> $to',
          );
          expect(
            card.updatedAt,
            originalUpdatedAt,
            reason:
                'updateStatus must write only the status column ($from -> $to)',
          );
        }
      }
    });
  });

  group('clearScheduledDate là mutation riêng, tách khỏi updateStatus', () {
    test('clears only scheduled_on, leaving status and other fields intact',
        () async {
      final created = await repository.createCard(
        const NewActivityCard(
          title: 'Đi hẹn hò',
          origin: ActivityCardOrigin.manual,
          scheduledOn: '2026-09-15',
          note: 'Ghi chú giữ nguyên',
        ),
      );

      await repository.updateStatus(created.id, ActivityCardStatus.idea);
      await repository.clearScheduledDate(created.id);

      final card = await repository.cardById(created.id);
      expect(card, isNotNull);
      expect(card!.scheduledOn, isNull);
      expect(card.status, ActivityCardStatus.idea);
      expect(card.note, 'Ghi chú giữ nguyên');
    });
  });
}
