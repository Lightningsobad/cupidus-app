import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
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

  group('updateCardDetails: đường ghi trường (P8, AC-12/AC-15)', () {
    test('writes every editable column and leaves the identity columns alone',
        () async {
      final created = await repository.createCard(
        const NewActivityCard(
          title: 'Cà phê sách Hào Nam',
          origin: ActivityCardOrigin.pastedLink,
          sourceLink: 'https://maps.app/abc',
        ),
      );
      await repository.updateStatus(created.id, ActivityCardStatus.scheduled);

      final rows = await repository.updateCardDetails(
        created.id,
        ActivityCardEdit(
          title: 'Cà phê sách Hào Nam (đổi)',
          activityType: ActivityType.walk,
          scheduledOn: '2026-11-02',
          priceVnd: 90000,
          distanceKm: 1.2,
          needsBooking: true,
          indoorOutdoor: ActivityCardIndoorOutdoor.outdoor,
          note: 'đi buổi chiều',
          sourceLink: 'https://maps.app/xyz',
          invited: true,
          replyState: ActivityCardReplyState.answered,
        ),
      );

      expect(rows, 1);
      final card = await repository.cardById(created.id);
      expect(card!.title, 'Cà phê sách Hào Nam (đổi)');
      expect(card.activityType, ActivityType.walk);
      expect(card.scheduledOn, '2026-11-02');
      expect(card.priceVnd, 90000);
      expect(card.distanceKm, 1.2);
      expect(card.needsBooking, isTrue);
      expect(card.indoorOutdoor, ActivityCardIndoorOutdoor.outdoor);
      expect(card.note, 'đi buổi chiều');
      expect(card.sourceLink, 'https://maps.app/xyz');
      expect(card.invited, isTrue);
      expect(card.replyState, ActivityCardReplyState.answered);
      // The columns [ActivityCardEdit] deliberately cannot reach.
      expect(card.id, created.id);
      expect(card.ownerKey, 'user-1');
      expect(card.status, ActivityCardStatus.scheduled);
      expect(card.origin, ActivityCardOrigin.pastedLink);
      expect(card.createdAt, created.createdAt);
      expect(card.updatedAt.isBefore(created.updatedAt), isFalse);
    });

    test('a null field clears the column rather than leaving it alone',
        () async {
      final created = await repository.createCard(
        const NewActivityCard(
          title: 'Đi hẹn hò',
          origin: ActivityCardOrigin.manual,
          scheduledOn: '2026-09-15',
          priceVnd: 120000,
          note: 'Ghi chú cũ',
          sourceLink: 'https://maps.app/abc',
        ),
      );

      await repository.updateCardDetails(
        created.id,
        ActivityCardEdit.from(created).copyCleared(),
      );

      final card = await repository.cardById(created.id);
      expect(card!.scheduledOn, isNull);
      expect(card.priceVnd, isNull);
      expect(card.note, isNull);
      expect(card.sourceLink, isNull);
      // Full-snapshot semantics only applies to what the edit carries: the
      // title is still required, so it survives.
      expect(card.title, 'Đi hẹn hò');
    });

    test("writing another owner's card reports zero rows and changes nothing",
        () async {
      final created = await repository.createCard(
        const NewActivityCard(
          title: 'Đi ăn phở',
          origin: ActivityCardOrigin.manual,
        ),
      );

      ownerKeyStore.updateUserId('user-2');
      final rows = await repository.updateCardDetails(
        created.id,
        ActivityCardEdit(
          title: 'không phải thẻ của mình',
          invited: true,
          replyState: ActivityCardReplyState.answered,
        ),
      );

      // `0` is what lets a caller tell "not mine" from "updated" — without it
      // this write is indistinguishable from a successful one (S2-F2-3).
      expect(rows, 0);
      ownerKeyStore.updateUserId('user-1');
      final card = await repository.cardById(created.id);
      expect(card!.title, 'Đi ăn phở');
      expect(card.invited, isFalse);
    });
  });

  group('năm trường B-1 (P11, AC-8)', () {
    Future<ActivityCard> createdCard() => repository.createCard(
          const NewActivityCard(
            title: 'Đi dạo hồ Tây',
            origin: ActivityCardOrigin.manual,
          ),
        );

    test('a fresh card starts with all five B-1 fields null', () async {
      final card = await createdCard();

      expect(card.durationMinutes, isNull);
      expect(card.timeOfDaySlot, isNull);
      expect(card.noteKeywords, isNull);
      expect(card.linkSourceLabel, isNull);
      expect(card.linkSavedAt, isNull);
    });

    test('updateCardDetails round-trips all five through storage', () async {
      final created = await createdCard();

      final rows = await repository.updateCardDetails(
        created.id,
        ActivityCardEdit.from(created).copyWithB1(
          durationMinutes: 90,
          timeOfDaySlot: TimeOfDaySlot.evening,
          noteKeywords: 'hồ tây, đi bộ',
          linkSourceLabel: 'Google Maps',
          linkSavedAt: 1757462400000,
        ),
      );

      expect(rows, 1);
      final card = await repository.cardById(created.id);
      expect(card!.durationMinutes, 90);
      expect(card.timeOfDaySlot, TimeOfDaySlot.evening);
      expect(card.noteKeywords, 'hồ tây, đi bộ');
      expect(card.linkSourceLabel, 'Google Maps');
      expect(card.linkSavedAt, 1757462400000);
      // B-1 forbids deriving the slot from the date: the card still has no
      // scheduled date and yet carries a slot.
      expect(card.scheduledOn, isNull);
      // `note_keywords` is a sibling of `note`, never a migration target.
      expect(card.note, isNull);
    });

    test('an unrecognized time_of_day_slot on disk reads back as null rather '
        'than throwing', () async {
      final created = await createdCard();
      await repository.updateCardDetails(
        created.id,
        ActivityCardEdit.from(created)
            .copyWithB1(timeOfDaySlot: TimeOfDaySlot.noon),
      );

      await database.customStatement(
        "UPDATE activity_cards SET time_of_day_slot = 'khuya' WHERE id = ?",
        [created.id],
      );

      final card = await repository.cardById(created.id);
      expect(card!.timeOfDaySlot, isNull);
      expect(card.title, 'Đi dạo hồ Tây');
    });

    test('writing null clears a previously set B-1 column (full-snapshot '
        'semantics)', () async {
      final created = await createdCard();
      await repository.updateCardDetails(
        created.id,
        ActivityCardEdit.from(created).copyWithB1(
          durationMinutes: 45,
          timeOfDaySlot: TimeOfDaySlot.morning,
          noteKeywords: 'sáng sớm',
          linkSourceLabel: 'Foody',
          linkSavedAt: 1757462400000,
        ),
      );
      final populated = await repository.cardById(created.id);

      await repository.updateCardDetails(
        created.id,
        ActivityCardEdit.from(populated!).copyCleared(),
      );

      final card = await repository.cardById(created.id);
      expect(card!.durationMinutes, isNull);
      expect(card.timeOfDaySlot, isNull);
      expect(card.noteKeywords, isNull);
      expect(card.linkSourceLabel, isNull);
      expect(card.linkSavedAt, isNull);
      expect(card.title, 'Đi dạo hồ Tây');
    });
  });

  group('khởi động nguội với owner key nạp lười (P10)', () {
    test('createCard and cardsByStatus succeed, and _requireOwnerKey does '
        'not throw, when the store has never been logged into this session '
        'but its reader resolves a persisted id', () async {
      final coldStore = BackendUserIdStore(
        readPersistedUserId: () async => 'persisted-user-cold',
      );
      final coldRepository = ActivityCardRepositoryImpl(
        dao: database.activityCardDao,
        ownerKeyStore: coldStore,
      );

      final created = await coldRepository.createCard(
        const NewActivityCard(
          title: 'Đi cà phê',
          origin: ActivityCardOrigin.manual,
        ),
      );

      expect(created.ownerKey, 'persisted-user-cold');

      final cards = await coldRepository.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: 10,
      );
      expect(cards.map((c) => c.id), contains(created.id));
    });
  });
}

extension on ActivityCardEdit {
  /// The same edit with every clearable column dropped, so a test can state
  /// "clear all of these" without restating the eleven-field constructor.
  ActivityCardEdit copyCleared() => ActivityCardEdit(
        title: title,
        invited: invited,
        replyState: replyState,
      );

  /// The same edit with only the five B-1 fields overridden, so a test can set
  /// them without restating the sixteen-field constructor.
  ActivityCardEdit copyWithB1({
    int? durationMinutes,
    TimeOfDaySlot? timeOfDaySlot,
    String? noteKeywords,
    String? linkSourceLabel,
    int? linkSavedAt,
  }) =>
      ActivityCardEdit(
        title: title,
        activityType: activityType,
        scheduledOn: scheduledOn,
        priceVnd: priceVnd,
        distanceKm: distanceKm,
        needsBooking: needsBooking,
        indoorOutdoor: indoorOutdoor,
        note: note,
        sourceLink: sourceLink,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        timeOfDaySlot: timeOfDaySlot ?? this.timeOfDaySlot,
        noteKeywords: noteKeywords ?? this.noteKeywords,
        linkSourceLabel: linkSourceLabel ?? this.linkSourceLabel,
        linkSavedAt: linkSavedAt ?? this.linkSavedAt,
        invited: invited,
        replyState: replyState,
      );
}
