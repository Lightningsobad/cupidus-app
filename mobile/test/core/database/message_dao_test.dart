import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CupidDatabase database;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Message buildMessage({
    required String id,
    required String senderId,
    required String receiverId,
    String content = 'hi',
    String status = 'sent',
    DateTime? readAt,
    required DateTime createdAt,
  }) {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: 'text',
      status: status,
      readAt: readAt,
      createdAt: createdAt,
      cachedAt: DateTime.now(),
    );
  }

  group('MessageDao.upsertAll', () {
    test('upserting the same server id twice leaves exactly one row with '
        "the second write's values", () async {
      final dao = database.messageDao;
      final createdAt = DateTime.utc(2026, 1, 1);

      await dao.upsertAll([
        buildMessage(
          id: 'msg-1',
          senderId: 'me',
          receiverId: 'partner',
          content: 'first',
          createdAt: createdAt,
        ),
      ]);
      await dao.upsertAll([
        buildMessage(
          id: 'msg-1',
          senderId: 'me',
          receiverId: 'partner',
          content: 'second',
          createdAt: createdAt,
        ),
      ]);

      final page = await dao.pageForPartner(
        myId: 'me',
        partnerId: 'partner',
        limit: 10,
        offset: 0,
      );

      expect(page, hasLength(1));
      expect(page.single.content, 'second');
    });
  });

  group('MessageDao.pageForPartner', () {
    test('returns rows in ascending createdAt order and respects '
        'limit/offset for both conversation directions', () async {
      final dao = database.messageDao;
      final base = DateTime.utc(2026, 1, 1);

      await dao.upsertAll([
        buildMessage(
          id: 'msg-1',
          senderId: 'me',
          receiverId: 'partner',
          createdAt: base,
        ),
        buildMessage(
          id: 'msg-2',
          senderId: 'partner',
          receiverId: 'me',
          createdAt: base.add(const Duration(minutes: 1)),
        ),
        buildMessage(
          id: 'msg-3',
          senderId: 'me',
          receiverId: 'partner',
          createdAt: base.add(const Duration(minutes: 2)),
        ),
        // Different conversation entirely — must never leak in.
        buildMessage(
          id: 'msg-other',
          senderId: 'me',
          receiverId: 'stranger',
          createdAt: base.add(const Duration(minutes: 3)),
        ),
      ]);

      final fullPage = await dao.pageForPartner(
        myId: 'me',
        partnerId: 'partner',
        limit: 10,
        offset: 0,
      );

      expect(
        fullPage.map((row) => row.id),
        ['msg-1', 'msg-2', 'msg-3'],
      );

      final secondRowOnly = await dao.pageForPartner(
        myId: 'me',
        partnerId: 'partner',
        limit: 1,
        offset: 1,
      );

      expect(secondRowOnly.single.id, 'msg-2');
    });
  });

  group('MessageDao.markSeenLocally', () {
    test('sets status to seen and stamps readAt for messages the partner '
        'sent me', () async {
      final dao = database.messageDao;
      final createdAt = DateTime.utc(2026, 1, 1);

      await dao.upsertAll([
        buildMessage(
          id: 'msg-1',
          senderId: 'partner',
          receiverId: 'me',
          createdAt: createdAt,
        ),
      ]);

      await dao.markSeenLocally(senderId: 'partner', receiverId: 'me');

      final page = await dao.pageForPartner(
        myId: 'me',
        partnerId: 'partner',
        limit: 10,
        offset: 0,
      );

      expect(page.single.status, 'seen');
      expect(page.single.readAt, isNotNull);
    });
  });

  group('MessageDao.clearAll', () {
    test('wipes the whole local cache', () async {
      final dao = database.messageDao;

      await dao.upsertAll([
        buildMessage(
          id: 'msg-1',
          senderId: 'me',
          receiverId: 'partner',
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ]);

      await dao.clearAll();

      final page = await dao.pageForPartner(
        myId: 'me',
        partnerId: 'partner',
        limit: 10,
        offset: 0,
      );
      expect(page, isEmpty);
    });
  });

  group('messages schema (AC4 / OQ4 / ADR-007 gate)', () {
    test('exposes no column whose name matches an offline-write-queue '
        'concept', () {
      final forbiddenFragments = [
        'pending',
        'queued',
        'outbox',
        'retry',
        'local',
        'sendState',
      ];
      final columnNames = database.messages.$columns
          .map((column) => column.name.toLowerCase())
          .toList();

      expect(columnNames, isNotEmpty);
      for (final fragment in forbiddenFragments) {
        expect(
          columnNames.where((name) => name.contains(fragment.toLowerCase())),
          isEmpty,
          reason: 'messages table must never contain a "$fragment" column',
        );
      }
    });
  });
}
