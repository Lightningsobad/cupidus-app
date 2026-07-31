import 'package:cupid_mobile/features/chat/data/chat_message_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessageMapper.fromJson', () {
    test('maps every field from a full message payload', () {
      final row = ChatMessageMapper.fromJson({
        'id': 'msg-1',
        'senderId': 'user-a',
        'receiverId': 'user-b',
        'content': 'hi',
        'type': 'text',
        'status': 'seen',
        'readAt': '2026-07-30T10:00:00.000Z',
        'createdAt': '2026-07-30T09:00:00.000Z',
      });

      expect(row.id, 'msg-1');
      expect(row.senderId, 'user-a');
      expect(row.receiverId, 'user-b');
      expect(row.content, 'hi');
      expect(row.type, 'text');
      expect(row.status, 'seen');
      expect(row.readAt, DateTime.parse('2026-07-30T10:00:00.000Z'));
      expect(row.createdAt, DateTime.parse('2026-07-30T09:00:00.000Z'));
    });

    test('tolerates a null readAt', () {
      final row = ChatMessageMapper.fromJson({
        'id': 'msg-2',
        'senderId': 'user-a',
        'receiverId': 'user-b',
        'content': 'hi',
        'type': 'text',
        'status': 'sent',
        'readAt': null,
        'createdAt': '2026-07-30T09:00:00.000Z',
      });

      expect(row.readAt, isNull);
    });

    test('tolerates a missing readAt key entirely', () {
      final row = ChatMessageMapper.fromJson({
        'id': 'msg-3',
        'senderId': 'user-a',
        'receiverId': 'user-b',
        'content': 'hi',
        'type': 'text',
        'status': 'sent',
        'createdAt': '2026-07-30T09:00:00.000Z',
      });

      expect(row.readAt, isNull);
    });

    test('sets cachedAt to the current time', () {
      final before = DateTime.now();
      final row = ChatMessageMapper.fromJson({
        'id': 'msg-4',
        'senderId': 'user-a',
        'receiverId': 'user-b',
        'content': 'hi',
        'type': 'text',
        'status': 'sent',
        'createdAt': '2026-07-30T09:00:00.000Z',
      });
      final after = DateTime.now();

      expect(
        row.cachedAt.isAfter(before) || row.cachedAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        row.cachedAt.isBefore(after) || row.cachedAt.isAtSameMomentAs(after),
        isTrue,
      );
    });
  });
}
