import 'package:cupid_mobile/core/network/cupid_api.dart';

import 'ghost_config_models.dart';

/// `architecture/solution.md` §2, §4 ADR-1: a hand-written Dio repository
/// over the frozen `ghost-config` REST contract. The generated
/// `Epic23GhostConfigAntiGhostingApi` types every response
/// `Future<Response<void>>` because the backend declares no Swagger response
/// schema, so every response body would be statically discarded through it
/// (§6 Option Evaluation). This repository calls [CupidApi.dio] directly and
/// parses JSON itself instead, matching
/// `mobile/lib/features/auth/data/auth_repository.dart`'s `_syncBackendProfile`
/// precedent. Every failure surfaces as [CupidApiFailure] (already set on
/// `DioException.error` by `CupidErrorInterceptor`); this repository catches
/// nothing and lets it propagate.
class GhostConfigRepository {
  GhostConfigRepository({required CupidApi api}) : _api = api;

  final CupidApi _api;

  /// `GET /ghost-config`. A null/empty body means "no active config" and is
  /// an empty state, not an error.
  Future<GhostConfig?> fetchActive() async {
    final response = await _api.dio.get<Object?>('/ghost-config');
    final data = response.data;
    if (_isEmptyBody(data)) {
      return null;
    }
    return GhostConfig.fromJson(data as Map<String, dynamic>);
  }

  /// `GET /ghost-config/pending`. An empty/null array means "no pending
  /// proposal" and is an empty state, not an error.
  Future<List<GhostConfig>> fetchPending() async {
    final response = await _api.dio.get<Object?>('/ghost-config/pending');
    final data = response.data;
    if (_isEmptyBody(data)) {
      return const [];
    }
    return (data as List<dynamic>)
        .map((item) => GhostConfig.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// `POST /ghost-config` with exactly
  /// `{"timeoutMinutes": <int>, "penalty": "<wire>", "publicCountdown": <bool>}`.
  /// `timeoutMinutes` must already be within 1-120
  /// (`create-ghost-config.dto.ts`); out-of-range input is rejected locally
  /// with an [ArgumentError] rather than sent to the server as an invalid
  /// body. [publicCountdown] defaults to the same `true` the server column
  /// default produces, so the two can never disagree.
  Future<GhostConfig> propose({
    required int timeoutMinutes,
    required Penalty penalty,
    bool publicCountdown = true,
  }) async {
    if (timeoutMinutes < 1 || timeoutMinutes > 120) {
      throw ArgumentError.value(
        timeoutMinutes,
        'timeoutMinutes',
        'must be between 1 and 120',
      );
    }
    final response = await _api.dio.post<Object?>(
      '/ghost-config',
      data: <String, Object?>{
        'timeoutMinutes': timeoutMinutes,
        'penalty': penalty.wireValue,
        'publicCountdown': publicCountdown,
      },
    );
    return GhostConfig.fromJson(response.data as Map<String, dynamic>);
  }

  /// `PATCH /ghost-config/:id/approve`.
  Future<GhostConfig> approve(String id) async {
    final response = await _api.dio.patch<Object?>(
      '/ghost-config/$id/approve',
    );
    return GhostConfig.fromJson(response.data as Map<String, dynamic>);
  }

  /// `PATCH /ghost-config/:id/reject`.
  Future<GhostConfig> reject(String id) async {
    final response = await _api.dio.patch<Object?>(
      '/ghost-config/$id/reject',
    );
    return GhostConfig.fromJson(response.data as Map<String, dynamic>);
  }

  /// `GET /ghost-config/storm-status/:partnerId`.
  Future<StormStatus> fetchStormStatus(String partnerId) async {
    final response = await _api.dio.get<Object?>(
      '/ghost-config/storm-status/$partnerId',
    );
    return StormStatus.fromJson(response.data as Map<String, dynamic>);
  }

  /// A JSON `null` body decodes to Dart `null`; a genuinely empty body with
  /// no JSON content-type decodes to `''` (`SyncTransformer`). Both are the
  /// contract's "no active config" / "no pending proposal" empty state.
  bool _isEmptyBody(Object? data) => data == null || data == '';
}
