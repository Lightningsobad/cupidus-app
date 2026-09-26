import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/cupid_database.dart';
import '../../../core/database/daos/invite_message_dao.dart';
import '../domain/invite_payload.dart';
import '../domain/invite_payload_repository.dart';

/// Drift-backed [InvitePayloadRepository].
///
/// The mapping is column-per-field with one exception: `filled_values` is the
/// only thing that becomes JSON, because it is the only field with a variable
/// key set. `card_id`, `preset_id`, `category_id`, and `pack_version` stay as
/// their own columns so the SB-125 payload is inspectable and queryable rather
/// than buried in a blob (AC-17).
class InvitePayloadRepositoryImpl implements InvitePayloadRepository {
  InvitePayloadRepositoryImpl(
    this._dao, {
    String Function() newId = _newUuidV4,
    DateTime Function() now = DateTime.now,
  })  : _newId = newId,
        _now = now;

  final InviteMessageDao _dao;
  final String Function() _newId;
  final DateTime Function() _now;

  @override
  Future<InvitePayload> savePayload({
    required String cardId,
    required String categoryId,
    required String presetId,
    required String packVersion,
    required Map<String, String> filledValues,
    String? userEditedText,
  }) async {
    final InvitePayload payload = InvitePayload(
      id: _newId(),
      cardId: cardId,
      categoryId: categoryId,
      presetId: presetId,
      packVersion: packVersion,
      filledValues: filledValues,
      userEditedText: userEditedText,
      // Truncated to whole milliseconds because that is the column's
      // resolution; keeping microseconds in memory would make the returned
      // payload differ from the one that comes back off disk.
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _now().millisecondsSinceEpoch,
      ),
    );
    await _dao.insertMessage(
      InviteMessagesCompanion.insert(
        id: payload.id,
        cardId: payload.cardId,
        categoryId: payload.categoryId,
        presetId: payload.presetId,
        packVersion: payload.packVersion,
        filledValues: encodeFilledValues(payload.filledValues),
        userEditedText: Value<String?>(payload.userEditedText),
        createdAt: payload.createdAt.millisecondsSinceEpoch,
      ),
    );
    return payload;
  }

  @override
  Future<InvitePayload?> latestForCard(String cardId) async =>
      _toPayload(await _dao.latestForCard(cardId));

  @override
  Future<InvitePayload?> payloadById(String id) async =>
      _toPayload(await _dao.rowById(id));

  InvitePayload? _toPayload(InviteMessageRow? row) {
    if (row == null) {
      return null;
    }
    return InvitePayload(
      id: row.id,
      cardId: row.cardId,
      categoryId: row.categoryId,
      presetId: row.presetId,
      packVersion: row.packVersion,
      filledValues: decodeFilledValues(row.filledValues),
      userEditedText: row.userEditedText,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }
}

String _newUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
