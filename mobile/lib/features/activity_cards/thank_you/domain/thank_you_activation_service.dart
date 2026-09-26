import 'thank_you_activation.dart';
import 'thank_you_activation_repository.dart';

/// The four-operation lifecycle of a card's single lifetime activation
/// (`architecture/solution.md` §4, phase P1 §3).
///
/// Every rule that AC-1..AC-5 state lives here rather than in the widget, so
/// P2 can render the block from [isEligible] alone and mark it spent with one
/// [consume] call without knowing the state machine.
///
/// The clock is injected because the whole contract is a calendar-day
/// comparison and the day boundary is the thing under test.
class ThankYouActivationService {
  ThankYouActivationService(
    this._repository, {
    this.now = DateTime.now,
  });

  final ThankYouActivationRepository _repository;
  final DateTime Function() now;

  /// Arms the card's turn when it enters *Đã đi rồi*. A card that already has
  /// a row — `armed`, `consumed` or `cancelled` — keeps it: BR-2 gives each
  /// card exactly one turn for its whole lifetime, so a status round trip
  /// (AC-4) and a silent cancel (AC-5) are both permanent.
  Future<void> arm(String cardId) async {
    await _repository.insertArmed(
      cardId: cardId,
      armedOn: civilDateOf(now()),
    );
  }

  /// Silently drops a pending turn when the card leaves *Đã đi rồi* before the
  /// block ever showed (AC-5). Nothing is surfaced to the user and nothing is
  /// recorded about what they missed (AC-25).
  Future<void> cancel(String cardId) async {
    await _repository.settleArmed(
      cardId: cardId,
      status: ThankYouActivationStatus.cancelled,
    );
  }

  /// Spends the turn on the block's first presentation (AC-3). Idempotent: a
  /// rebuild calling it again on a `consumed` card leaves `consumedAt`
  /// untouched.
  Future<void> consume(String cardId) async {
    await _repository.settleArmed(
      cardId: cardId,
      status: ThankYouActivationStatus.consumed,
      consumedAt: now(),
    );
  }

  /// True only on a calendar day strictly after the arming day (AC-1), which
  /// is what keeps the block off the card on the evening it was marked done
  /// (AC-2). There is no deadline on the far side: an `armed` turn stays
  /// eligible for as long as it takes (BR-3).
  Future<bool> isEligible(String cardId) async {
    final activation = await _repository.activationFor(cardId);
    if (activation == null ||
        activation.status != ThankYouActivationStatus.armed) {
      return false;
    }
    return civilDateOf(now()).compareTo(activation.armedOn) > 0;
  }
}
