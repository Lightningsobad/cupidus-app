import '../domain/thank_you_activation.dart';
import '../domain/thank_you_activation_repository.dart';
import 'thank_you_activation_dao.dart';

class ThankYouActivationRepositoryImpl implements ThankYouActivationRepository {
  const ThankYouActivationRepositoryImpl(this._dao);

  final ThankYouActivationDao _dao;

  @override
  Future<ThankYouActivation?> activationFor(String cardId) async {
    final row = await _dao.rowFor(cardId);
    if (row == null) {
      return null;
    }
    return ThankYouActivation(
      cardId: row.cardId,
      status: ThankYouActivationStatus.fromWireValue(row.status),
      armedOn: row.armedOn,
      consumedAt: row.consumedAt,
    );
  }

  @override
  Future<void> insertArmed({
    required String cardId,
    required String armedOn,
  }) {
    return _dao.insertArmed(cardId: cardId, armedOn: armedOn);
  }

  @override
  Future<void> settleArmed({
    required String cardId,
    required ThankYouActivationStatus status,
    DateTime? consumedAt,
  }) {
    return _dao.settleArmed(
      cardId: cardId,
      status: status.wireValue,
      consumedAt: consumedAt,
    );
  }
}
