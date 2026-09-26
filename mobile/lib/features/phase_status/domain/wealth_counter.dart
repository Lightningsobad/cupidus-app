import '../../activity_cards/domain/activity_card.dart';

/// The "của cải đang lớn" value on screen (1): the cardinality of the durable
/// set the user has accumulated, and nothing else (AC-25/BR-5).
///
/// The signature is the guarantee. There is no clock parameter, no elapsed-day
/// parameter, and no gap-between-sessions parameter anywhere in this file, so
/// "count went down because you were away" is not expressible against this API
/// — which is what keeps the counter from becoming a streak in disguise
/// (R-1 cấm (f)). Absence is silent by construction: not calling [count] for a
/// while cannot change what the next call returns (AC-26/BR-6).
///
/// The value drops only when the user deletes a card, because deleting is the
/// only thing that shrinks the set this reads (AC-29). Nothing here dramatises
/// that drop: it returns a number, never a message.
class WealthCounter {
  const WealthCounter();

  /// [countsByStatus] is the map `ActivityCardRepository.countsByStatus()`
  /// returns. A status with no card is absent from that map rather than mapped
  /// to zero, so a user who has kept nothing yet reads as `0` — a fact, not an
  /// empty state to fill.
  int count(Map<ActivityCardStatus, int> countsByStatus) =>
      countsByStatus[ActivityCardStatus.memory] ?? 0;
}
