import 'package:cupid_mobile/core/database/cupid_database.dart';

/// Converts a raw message payload — the identical shape returned by both the
/// `newMessage` socket event and `GET /messages` rows
/// (`architecture/solution.md` §2) — into the P0 Drift row. Tolerates a
/// missing/null `readAt` (server-side nullable column).
abstract final class ChatMessageMapper {
  static Message fromJson(Map<String, dynamic> json) {
    final rawReadAt = json['readAt'];
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      readAt: rawReadAt == null ? null : DateTime.parse(rawReadAt as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      cachedAt: DateTime.now(),
    );
  }
}
