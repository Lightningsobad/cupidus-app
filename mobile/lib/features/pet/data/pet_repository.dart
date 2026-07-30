import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:dio/dio.dart';

import 'pet_models.dart';

/// `architecture/solution.md` §2 `PetRepository` contract (§D1-D4). Reads the
/// `pets` REST surface through the shared [CupidApi.dio] directly (D1): the
/// generated `Epic4LovePetApi` declares no response schema and is typed
/// `Future<Response<void>>`, so this repository hand-writes every request/
/// response shape and is the single place that knows the `pets`/`users` JSON
/// key names.
class PetRepository {
  PetRepository({required this._api});

  final CupidApi _api;

  /// `GET /users/me` (D2): the only reliable pairing signal for AC3, since
  /// `GET /pets` and `GET /pets/status` both return an empty body for
  /// "unpaired" and for "paired but no pet yet".
  Future<PetPairing> readPairing() async {
    final response = await _unwrap(() => _api.dio.get<Object?>('/users/me'));
    return PetPairing.fromJson(response.data as Map<String, dynamic>);
  }

  /// `GET /pets/status`. The backend returns an empty body (HTTP 200, not
  /// 404) for "unpaired" and "paired but no pet yet"; this maps that to
  /// `null` rather than throwing, so the cubit can derive `PetNoPet`.
  Future<PetStatus?> readStatus() async {
    final response =
        await _unwrap(() => _api.dio.get<Object?>('/pets/status'));
    final body = response.data;
    return body == null
        ? null
        : PetStatus.fromJson(body as Map<String, dynamic>);
  }

  /// `PATCH /pets/interact`, then refetch `GET /pets/status` (D4): the
  /// interact response is the raw pet row without `mood`, and recomputing
  /// mood client-side would duplicate frozen backend thresholds. Decay
  /// cannot double-apply because `interact` has just set `lastInteraction`.
  Future<PetStatus> interact() async {
    await _unwrap(() => _api.dio.patch<Object?>('/pets/interact'));
    return _requireStatus();
  }

  /// `POST /pets/adopt`, then refetch `GET /pets/status` for the same reason
  /// as [interact] (D4): the adopt response is also the raw pet row.
  Future<PetStatus> adopt({
    required PetSpecies species,
    required String name,
  }) async {
    await _unwrap(
      () => _api.dio.post<Object?>(
        '/pets/adopt',
        data: {'species': species.wireValue, 'name': name},
      ),
    );
    return _requireStatus();
  }

  Future<PetStatus> _requireStatus() async {
    final status = await readStatus();
    if (status != null) {
      return status;
    }
    // All failures surface as `CupidApiFailure` subtypes only
    // (`architecture/solution.md` §2); this is not a network failure, so it
    // is not one of the more specific subtypes.
    throw const UnexpectedFailure();
  }

  /// Rethrows the `CupidApiFailure` set on `DioException.error` by
  /// `CupidErrorInterceptor` instead of the raw `DioException`, matching the
  /// `AuthRepository._syncBackendProfile` precedent so callers only ever
  /// catch `CupidApiFailure`.
  Future<T> _unwrap<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final failure = e.error;
      throw failure is CupidApiFailure ? failure : const UnexpectedFailure();
    }
  }
}
