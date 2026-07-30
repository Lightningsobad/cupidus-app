import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';
import 'package:dio/dio.dart';

/// Client for the frozen `timeline` REST contract (`architecture/
/// solution.md` §2, §4). Reads/writes go through the shared [CupidApi.dio]
/// because the generated `timelineController*` operations are typed
/// `Response<void>` (the OpenAPI spec declares no response schema) --
/// mirrors `AuthRepository._syncBackendProfile`'s raw-body pattern. Never
/// constructs a `Dio` and never switches on `DioExceptionType`; errors
/// reach callers as the `CupidApiFailure` already mapped onto
/// `DioException.error` by `CupidErrorInterceptor`.
class TimelineRemoteDataSource {
  TimelineRemoteDataSource(this._api);

  final CupidApi _api;

  /// `GET /timeline?limit=50&offset=0`. First page only (D-012-8); the
  /// server returns newest-first order, preserved here.
  Future<List<TimelineEntry>> fetchFirstPage() async {
    try {
      final response = await _api.dio.get<Object?>(
        '/timeline',
        queryParameters: const {'limit': 50, 'offset': 0},
      );
      final body = response.data;
      if (body is! List) {
        throw const TimelineDecodeException(
          'Expected a JSON array body for GET /timeline',
        );
      }
      return body.map((element) {
        if (element is! Map) {
          throw const TimelineDecodeException(
            'Expected a JSON object per timeline event',
          );
        }
        return TimelineEntry.fromDto(
          TimelineEventDto.fromJson(Map<String, Object?>.from(element)),
        );
      }).toList(growable: false);
    } on DioException catch (e) {
      throw e.error ?? const UnexpectedFailure();
    }
  }

  /// `POST /timeline`. Sends exactly [TimelineDraft.toJson]'s fields.
  Future<void> createEntry(TimelineDraft draft) async {
    try {
      await _api.dio.post<Object?>('/timeline', data: draft.toJson());
    } on DioException catch (e) {
      throw e.error ?? const UnexpectedFailure();
    }
  }
}
