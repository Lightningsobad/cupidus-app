import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/cupid_database.dart';
import '../../../core/database/daos/chapter_closure_dao.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../domain/chapter_closure_gate.dart';

/// Writes and undoes a chapter closure
/// (`architecture/contract-summary.md` §3, `solution.md` §1 Key Discovery 1).
///
/// The classification predicate (AC-6) runs exactly once, at closing time, and
/// its result is stored as a snapshot. It is never re-evaluated on read: a card
/// that survived the closure and is later invited to a new person would
/// otherwise be pulled into the closed drawer by a recomputed predicate, which
/// is exactly what AC-9 forbids.
///
/// Only positive signals close an item. "The user never touched it" is not a
/// signal, so a private "mới nghĩ ra" idea that was never invited, never
/// answered and never messaged about stays in the everyday flow (AC-7).
class ChapterClosureService {
  ChapterClosureService({
    required CupidDatabase db,
    required ChapterClosureDao dao,
    required BackendUserIdStore ownerKeyStore,
    String Function() newId = _newUuidV4,
    DateTime Function() now = DateTime.now,
  })  : _db = db,
        _dao = dao,
        _ownerKeyStore = ownerKeyStore,
        _newId = newId,
        _now = now;

  final CupidDatabase _db;
  final ChapterClosureDao _dao;
  final BackendUserIdStore _ownerKeyStore;
  final String Function() _newId;
  final DateTime Function() _now;

  /// Closes the current chapter: one `chapter_closures` row plus every member
  /// id, in a single transaction (AC-1). A crash halfway through leaves no
  /// closure at all rather than a half-closed chapter.
  ///
  /// Closing twice replaces the previous snapshot instead of stacking a second
  /// one, so a double tap cannot produce two overlapping ledgers. The
  /// replacement is inside the same transaction as the insert.
  Future<String> close() async {
    final ownerKey = await _requireOwnerKey();
    final closureId = _newId();
    final closedAt = _now();

    await _db.transaction(() async {
      final itemIdsByKind = await _classify(ownerKey);
      await _dao.deleteClosuresForOwner(ownerKey);
      await _dao.createClosure(
        id: closureId,
        ownerKey: ownerKey,
        closedAt: closedAt,
        itemIdsByKind: itemIdsByKind,
      );
    });

    return closureId;
  }

  /// Reopens the chapter by deleting the owner's closure row; its members go
  /// with it through `ON DELETE CASCADE` (AC-17).
  ///
  /// Nothing records that this happened. There is no `reopened_at` and no
  /// closure id, date or count crosses this boundary, so no screen can ever
  /// grow a "lần thứ 3 bạn đóng ngăn" string out of it (BR-7).
  Future<void> reopen() async {
    final ownerKey = await _requireOwnerKey();
    await _dao.deleteClosuresForOwner(ownerKey);
  }

  /// The AC-6 predicate. Runs once per [close], entirely in SQL.
  Future<Map<String, Set<String>>> _classify(String ownerKey) async {
    return <String, Set<String>>{
      ChapterClosureItemKind.activityCard.wireValue:
          await _personAttachedCardIds(ownerKey),
      ChapterClosureItemKind.notebookEntry.wireValue:
          await _notebookEntryIds(ownerKey),
      ChapterClosureItemKind.askPrompt.wireValue:
          await _askPromptQuestionIds(ownerKey),
    };
  }

  /// A card is person-attached when the user invited someone to it, when they
  /// marked a reply, or when an invite message points at it.
  ///
  /// Invites themselves get no `item_kind`: `invite_messages.card_id` already
  /// cascades from `activity_cards`, so a closed card's messages are handled by
  /// the card's own lifecycle (`solution.md` §1 Key Discovery 4).
  Future<Set<String>> _personAttachedCardIds(String ownerKey) async {
    final cards = _db.activityCards;
    final invites = _db.inviteMessages;
    final hasInviteMessage = existsQuery(
      _db.selectOnly(invites)
        ..addColumns([invites.cardId])
        ..where(invites.cardId.equalsExp(cards.id)),
    );

    final query = _db.selectOnly(cards)
      ..addColumns([cards.id])
      ..where(
        cards.ownerKey.equals(ownerKey) &
            (cards.invited.equals(true) |
                cards.replyState.equals('not_answered').not() |
                hasInviteMessage),
      );
    final rows = await query.get();
    return rows.map((row) => row.read(cards.id)!).toSet();
  }

  /// Every live relationship-notebook entry, both kinds. The private journal is
  /// a different table and is never a closure member (BR-6); the skill profile
  /// belongs to the user, not to the relationship, and is never one either
  /// (AC-8).
  Future<Set<String>> _notebookEntryIds(String ownerKey) async {
    final entries = _db.notebookEntries;
    final query = _db.selectOnly(entries)
      ..addColumns([entries.id])
      ..where(entries.ownerKey.equals(ownerKey));
    final rows = await query.get();
    return rows.map((row) => row.read(entries.id)!).toSet();
  }

  /// `item_id` is the `question_id`, not a row id (§2): `ask_prompt_state` is
  /// keyed by `(owner_key, question_id)` and has no surrogate id.
  Future<Set<String>> _askPromptQuestionIds(String ownerKey) async {
    final prompts = _db.askPromptState;
    final query = _db.selectOnly(prompts)
      ..addColumns([prompts.questionId])
      ..where(prompts.ownerKey.equals(ownerKey));
    final rows = await query.get();
    return rows.map((row) => row.read(prompts.questionId)!).toSet();
  }

  Future<String> _requireOwnerKey() async {
    final ownerKey = await _ownerKeyStore.resolve();
    if (ownerKey == null || ownerKey.isEmpty) {
      throw StateError(
        'ChapterClosureService used before a backend user id resolved.',
      );
    }
    return ownerKey;
  }
}

/// Matches `ContextNotebookRepository` and `ActivityCardRepositoryImpl`: no
/// `uuid` package is a direct dependency, so the client-generated v4 id
/// (R-15a) comes from `dart:math`'s cryptographic RNG.
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
