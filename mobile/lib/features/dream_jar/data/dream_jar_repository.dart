import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:dio/dio.dart';

import 'dream_jar.dart';

/// AC3: the backend's `getCoupleIdForUser()` throws
/// `NotFoundException('User not found or not paired')` for an unpaired user
/// (`architecture/solution.md` §4 `Contracts And Integrations`). `Extends
/// HttpStatusFailure` rather than `CupidApiFailure` directly: `CupidApiFailure`
/// is a `sealed class` (`core/network/cupid_api_failure.dart`), so a direct
/// subtype must live in that same file; `HttpStatusFailure` carries no such
/// restriction, and this stays a `CupidApiFailure` transitively, satisfying
/// the "every repository method throws a `CupidApiFailure` subtype" contract
/// without touching a file outside this phase's write scope.
class DreamJarUnpairedFailure extends HttpStatusFailure {
  const DreamJarUnpairedFailure(String? message) : super(404, message);
}

/// The single HTTP boundary for the frozen `dream-jar` backend routes
/// (`architecture/solution.md` §4 `Contracts And Integrations`). Calls
/// `CupidApi.dio` directly, mirroring `AuthRepository._syncBackendProfile()`:
/// the generated `Epic5DreamJarApi` types every response `Future<Response<
/// void>>` because the controller publishes no response schema, so response
/// bodies are unreachable through it (ADR-014g).
class DreamJarRepository {
  DreamJarRepository(this._api);

  final CupidApi _api;

  Future<List<DreamJar>> fetchJars({int limit = 50, int offset = 0}) async {
    try {
      final response = await _api.dio.get<Object?>(
        '/dream-jar',
        queryParameters: <String, Object?>{'limit': limit, 'offset': offset},
      );
      final data = response.data as List<Object?>;
      return data
          .map((item) => DreamJar.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Future<DreamJar> fetchJar(String id) async {
    try {
      final response = await _api.dio.get<Object?>('/dream-jar/$id');
      return DreamJar.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Future<DreamJar> createJar({
    required String name,
    required num targetAmount,
    DateTime? deadline,
  }) async {
    try {
      final response = await _api.dio.post<Object?>(
        '/dream-jar',
        data: <String, Object?>{
          'name': name,
          'targetAmount': targetAmount,
          if (deadline != null) 'deadline': deadline.toIso8601String(),
        },
      );
      return DreamJar.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Future<DreamJar> approveJar(String id) async {
    try {
      final response = await _api.dio.patch<Object?>('/dream-jar/$id/approve');
      return DreamJar.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Future<DreamJar> rejectJar(String id) async {
    try {
      final response = await _api.dio.patch<Object?>('/dream-jar/$id/reject');
      return DreamJar.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Future<Contribution> addContribution({
    required String jarId,
    required num amount,
  }) async {
    try {
      final response = await _api.dio.post<Object?>(
        '/dream-jar/$jarId/contributions',
        data: <String, Object?>{'amount': amount},
      );
      return Contribution.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Future<DreamJar> deleteContribution({
    required String jarId,
    required String contributionId,
  }) async {
    try {
      final response = await _api.dio.delete<Object?>(
        '/dream-jar/$jarId/contributions/$contributionId',
      );
      return DreamJar.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Future<List<Contribution>> fetchContributions(
    String jarId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _api.dio.get<Object?>(
        '/dream-jar/$jarId/contributions',
        queryParameters: <String, Object?>{'limit': limit, 'offset': offset},
      );
      final data = response.data as List<Object?>;
      return data
          .map((item) => Contribution.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  /// Rethrows the mapped [CupidApiFailure] set on `DioException.error` by
  /// `CupidErrorInterceptor`, substituting [UnexpectedFailure] when it is
  /// null (mirrors `AuthRepository`). Before rethrowing, splits a 404 whose
  /// message contains "not paired" (case-insensitive) into
  /// [DreamJarUnpairedFailure]; any other 404 (e.g. "Dream Jar not found")
  /// stays the original [HttpStatusFailure] so a missing jar remains
  /// distinguishable from an unpaired user.
  CupidApiFailure _mapFailure(DioException e) {
    final failure = e.error;
    if (failure is HttpStatusFailure &&
        failure.statusCode == 404 &&
        (failure.message?.toLowerCase().contains('not paired') ?? false)) {
      return DreamJarUnpairedFailure(failure.message);
    }
    if (failure is CupidApiFailure) return failure;
    return const UnexpectedFailure();
  }
}
