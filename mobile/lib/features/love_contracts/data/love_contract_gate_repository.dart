import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:dio/dio.dart';

/// AC4 pairing gate state (`architecture/solution.md` §4 Pairing Gate):
/// `partnerId == null` means the caller is unpaired and the love-contracts
/// entry point must stay hidden.
class PairingState {
  const PairingState({required this.myDisplayName, required this.partnerId});

  static const unpaired = PairingState(myDisplayName: null, partnerId: null);

  final String? myDisplayName;
  final String? partnerId;

  bool get isPaired => partnerId != null;
}

/// `GET /users/me` → `{ displayName, partnerId }`
/// (`backend/src/modules/users/entities/user.entity.ts`). A failed fetch is
/// treated as "not paired" rather than thrown, per the architecture's
/// hidden-is-safer gate contract.
class LoveContractGateRepository {
  LoveContractGateRepository(this._api);

  final CupidApi _api;

  Future<PairingState> fetchPairingState() async {
    try {
      final response = await _api.dio.get<Object?>('/users/me');
      final body = response.data;
      if (body is! Map<String, dynamic>) return PairingState.unpaired;
      return PairingState(
        myDisplayName: body['displayName'] as String?,
        partnerId: body['partnerId'] as String?,
      );
    } on DioException {
      return PairingState.unpaired;
    }
  }
}
