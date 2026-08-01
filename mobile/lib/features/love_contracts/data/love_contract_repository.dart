import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:dio/dio.dart';

import 'love_contract.dart';

/// Named boundary result for `sign()`'s ADR-006c 404 case. `CupidApiFailure`
/// is `sealed`, so a new subtype can only live in its own library; this
/// extension gives P3 a named check (`failure.isSignUnavailable`) instead of
/// inspecting `HttpStatusFailure.statusCode` directly in the UI.
extension SignUnavailableFailure on CupidApiFailure {
  bool get isSignUnavailable =>
      this is HttpStatusFailure && (this as HttpStatusFailure).statusCode == 404;
}

/// `architecture/solution.md` ADR-006b: reads response bodies from the
/// shared [Dio] directly (the generated `Epic1LoveContractsApi` types every
/// endpoint `Response<void>`), following the precedent in
/// `features/auth/data/auth_repository.dart`. Every method surfaces only
/// [CupidApiFailure] subtypes — never a raw [DioException].
class LoveContractRepository {
  LoveContractRepository(this._api);

  final CupidApi _api;

  /// `GET /love-contracts/my-pending`. A `null`/non-map body is the caller's
  /// empty state, not an error.
  Future<LoveContract?> fetchCurrent() async {
    try {
      final response = await _api.dio.get<Object?>(
        '/love-contracts/my-pending',
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) return null;
      return LoveContract.fromJson(body);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  /// `POST /love-contracts` with `{"clauses": clauses}`. Upserts the
  /// caller's own contract (server-side semantics; clauses pass through
  /// unchanged here, bounds are enforced in P1).
  Future<LoveContract> saveClauses(List<String> clauses) async {
    try {
      final response = await _api.dio.post<Object?>(
        '/love-contracts',
        data: {'clauses': clauses},
      );
      return LoveContract.fromJson(_asJsonMap(response.data));
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  /// `PATCH /love-contracts/sign` (no body). Matches the caller's own
  /// `created` contract only; a 404 means "no pending contract to sign"
  /// (ADR-006c creator-only capability), surfaced via
  /// [SignUnavailableFailure.isSignUnavailable].
  Future<LoveContract> sign() async {
    try {
      final response = await _api.dio.patch<Object?>('/love-contracts/sign');
      return LoveContract.fromJson(_asJsonMap(response.data));
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Map<String, dynamic> _asJsonMap(Object? data) =>
      data is Map<String, dynamic> ? data : const {};

  CupidApiFailure _mapFailure(DioException e) {
    final failure = e.error;
    return failure is CupidApiFailure ? failure : const UnexpectedFailure();
  }
}
