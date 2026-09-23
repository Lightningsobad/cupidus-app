import '../../domain/activity_card.dart';
import '../../domain/activity_card_repository.dart';
import 'thank_you_activation_card_status_listener.dart';

/// Makes [ThankYouActivationCardStatusListener] fire in a real build: a
/// successful `updateStatus` write is STORY-001's only card status signal
/// (`activity_card_repository.dart` AC-14), and this decorator is what hands
/// that transition to the activation ledger (phase P1 §3).
///
/// It wraps `ActivityCardRepositoryImpl` at the composition root instead of
/// calling the listener from inside it, so the dependency stays one-way:
/// STORY-007 knows about the card store, the card store knows nothing about
/// the ledger (`architecture/solution.md` §4 Boundaries And Ownership). The
/// card schema is untouched.
class ThankYouActivationAwareCardRepository implements ActivityCardRepository {
  ThankYouActivationAwareCardRepository({
    required ActivityCardRepository inner,
    required ThankYouActivationCardStatusListener listener,
  })  : _inner = inner,
        _listener = listener;

  final ActivityCardRepository _inner;
  final ThankYouActivationCardStatusListener _listener;

  /// Zero rows written means the card belongs to another owner, so nothing is
  /// armed or cancelled for it.
  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async {
    final rows = await _inner.updateStatus(cardId, status);
    if (rows > 0) {
      await _listener.onCardStatusChanged(cardId: cardId, status: status);
    }
    return rows;
  }

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      _inner.createCard(draft);

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) =>
      _inner.cardsByStatus(status: status, limit: limit, offset: offset);

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) =>
      _inner.watchCardsByStatus(status: status, limit: limit, offset: offset);

  @override
  Future<ActivityCard?> cardById(String id) => _inner.cardById(id);

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() =>
      _inner.countsByStatus();

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) =>
      _inner.updateCardDetails(cardId, edit);

  @override
  Future<int> clearScheduledDate(String cardId) =>
      _inner.clearScheduledDate(cardId);

  @override
  Future<int> deleteCard(String id) => _inner.deleteCard(id);
}
