import 'activity_card.dart';

/// The card store's only interface (`architecture/contract-summary.md` §1).
/// Every query is implicitly scoped to the signed-in session's own
/// `owner_key` — no method accepts it as a parameter, so a consumer cannot
/// accidentally read or write another owner's cards.
abstract interface class ActivityCardRepository {
  /// The sole write gate for the 11 consumer stories. See [NewActivityCard]
  /// for the field contract.
  Future<ActivityCard> createCard(NewActivityCard draft);

  /// One status pane, newest-updated first, paged — never a full-table read.
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  });

  /// Live version of [cardsByStatus] for the list screen.
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  });

  Future<ActivityCard?> cardById(String id);

  /// Per-pane badge counts. A status with no card is absent from the map
  /// rather than mapped to `0`.
  Future<Map<ActivityCardStatus, int>> countsByStatus();

  /// Writes every user-editable field of a card in one statement (AC-12/AC-15).
  /// Never touches `id`, `owner_key`, `status`, `origin` or `created_at`, and
  /// always bumps `updated_at`. Full-snapshot semantics: each field of [edit]
  /// is written exactly as given, so a `null` clears that column.
  ///
  /// Returns the number of rows written; `0` means the card does not belong to
  /// the current owner.
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit);

  /// Writes only the `status` column (AC-14/AC-15): `scheduled_on`, `note`,
  /// photos, and every other field survive a transition in either direction,
  /// including a regression. Callers that need to also clear the scheduled
  /// date on a deliberate regression call [clearScheduledDate] separately.
  ///
  /// Returns the number of rows written, so a caller can tell "not mine" from
  /// "updated".
  Future<int> updateStatus(String cardId, ActivityCardStatus status);

  /// Writes only the `scheduled_on` column, for the explicit "xoá ngày hẹn"
  /// choice on a `scheduled -> idea` regression (`ux/uiux-spec.md` §5).
  /// Returns the number of rows written.
  Future<int> clearScheduledDate(String cardId);

  /// Deletes the card; its photo rows cascade with it. Returns the number of
  /// rows written, so a caller can tell "not mine" from "deleted".
  Future<int> deleteCard(String id);
}
