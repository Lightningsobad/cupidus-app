import 'thank_you_activation.dart';

/// Row access for the activation ledger. Deliberately has no `delete` and no
/// bulk reader: a turn is never erased and never counted (AC-25).
abstract interface class ThankYouActivationRepository {
  Future<ThankYouActivation?> activationFor(String cardId);

  /// Inserts the card's one and only `armed` row. Does nothing when a row for
  /// [cardId] already exists, whatever its status (AC-4).
  Future<void> insertArmed({required String cardId, required String armedOn});

  /// Moves an `armed` row to [status]. Does nothing when the stored row is
  /// already absorbing, so [consumedAt] can never be overwritten
  /// (`architecture/solution.md` §4 Idempotency).
  Future<void> settleArmed({
    required String cardId,
    required ThankYouActivationStatus status,
    DateTime? consumedAt,
  });
}
