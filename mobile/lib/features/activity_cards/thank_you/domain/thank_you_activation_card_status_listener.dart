import '../../domain/activity_card.dart';
import 'thank_you_activation_service.dart';

/// Binds the activation lifecycle to STORY-001's card status signal (AC-14)
/// without touching the card schema or the card repository: callers of
/// `ActivityCardRepository.updateStatus` hand the same transition here.
///
/// It lives on this side of the boundary on purpose. Putting the arm/cancel
/// call inside the card repository would make STORY-001 depend on STORY-007,
/// and `activity_cards` would grow a column for a turn it does not own
/// (`architecture/solution.md` §4 Boundaries And Ownership).
class ThankYouActivationCardStatusListener {
  const ThankYouActivationCardStatusListener(this._service);

  final ThankYouActivationService _service;

  /// Entering *Đã đi rồi* arms the turn (AC-1); leaving it in any direction
  /// cancels a still-pending one (AC-5). Both calls are no-ops once the card's
  /// single turn has been settled, so a card bouncing between statuses cannot
  /// produce a second turn (AC-4).
  Future<void> onCardStatusChanged({
    required String cardId,
    required ActivityCardStatus status,
  }) {
    if (status == ActivityCardStatus.done) {
      return _service.arm(cardId);
    }
    return _service.cancel(cardId);
  }
}
