import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';

/// `architecture/solution.md` ADR-015.7: pairing state is read through a
/// narrow seam keyed on `partnerId`. This consumes STORY-012's existing
/// `CouplePairingStore` (`GET /users/me`, `partnerId != null` => paired) --
/// the "pairing-state source already landed on the integration branch"
/// ADR-015.7 requires reusing -- rather than adding a new endpoint (A1).
class PairingStateReader {
  const PairingStateReader({required CouplePairingStore pairingStore})
    : _pairingStore = pairingStore; // ignore: prefer_initializing_formals

  final CouplePairingStore _pairingStore;

  /// `false` for both `unpaired` and `unknown` (nothing cached yet, network
  /// unavailable) -- AC4's gate must never optimistically grant access to a
  /// pairing state it cannot confirm.
  Future<bool> isPaired() async {
    final PairingStatus status = await _pairingStore.resolve();
    return status == PairingStatus.paired;
  }
}
