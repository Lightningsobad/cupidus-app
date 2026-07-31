import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:dio/dio.dart';

import '../domain/vibe_entry.dart';
import '../domain/vibe_mood.dart';

/// The only file aware of `/vibes*` paths and JSON keys
/// (`architecture/solution.md` §4). Rethrows the mapped [CupidApiFailure]
/// from `DioException.error` (never the raw [DioException]), matching
/// `AuthRepository` (`features/auth/data/auth_repository.dart:99-112`).
class VibesRepository {
  VibesRepository(this._api);

  final CupidApi _api;

  static const _historyDays = 8;

  /// `GET /vibes/today`. A `null`/empty body or empty map means no check-in
  /// yet today (R-010-3), not a parse error.
  Future<VibeEntry?> fetchMyToday() async {
    try {
      final response = await _api.dio.get<Object?>('/vibes/today');
      return _parseSingle(response.data);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  /// `GET /vibes/history?days=8` (D-010-3: 8, not 7, so the rolling window
  /// covers the last 7 local calendar days under any timezone offset).
  Future<List<VibeEntry>> fetchMyHistory() => _fetchEntries('/vibes/history');

  /// `GET /vibes/partner?days=8`. An empty list is a valid unpaired/no-data
  /// result (AC3 defensive path), never an error.
  Future<List<VibeEntry>> fetchPartnerHistory() =>
      _fetchEntries('/vibes/partner');

  /// `POST /vibes` with `{"mood": wireValue}` and no `note` key.
  Future<void> submitMood(VibeMood mood) async {
    try {
      await _api.dio.post<Object?>('/vibes', data: {'mood': mood.wireValue});
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  Future<List<VibeEntry>> _fetchEntries(String path) async {
    try {
      final response = await _api.dio.get<Object?>(
        path,
        queryParameters: const {'days': _historyDays},
      );
      final data = response.data;
      if (data is! List) {
        return const [];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(VibeEntry.fromJson)
          .whereType<VibeEntry>()
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapFailure(e);
    }
  }

  VibeEntry? _parseSingle(Object? data) {
    if (data == null) {
      return null;
    }
    if (data is String && data.isEmpty) {
      return null;
    }
    if (data is Map && data.isEmpty) {
      return null;
    }
    if (data is Map<String, dynamic>) {
      return VibeEntry.fromJson(data);
    }
    return null;
  }

  CupidApiFailure _mapFailure(DioException e) =>
      (e.error as CupidApiFailure?) ?? const UnexpectedFailure();
}

/// Buckets a DESC-ordered (newest first) entry list into the last 7 local
/// calendar days, oldest -> newest, newest entry wins per day, `null` for a
/// day with no entry (D-010-3). Tolerates an 8-day window: an entry from an
/// 8th, older day simply does not match any of the 7 target days.
List<VibeEntry?> bucketByLocalDay(
  List<VibeEntry> entriesDescending, {
  DateTime? now,
}) {
  final today = _dateOnly((now ?? DateTime.now()).toLocal());
  final days = List<DateTime>.generate(
    7,
    (i) => today.subtract(Duration(days: 6 - i)),
  );

  final buckets = <DateTime, VibeEntry>{};
  for (final entry in entriesDescending) {
    buckets.putIfAbsent(_dateOnly(entry.createdAt.toLocal()), () => entry);
  }

  return days.map((day) => buckets[day]).toList(growable: false);
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
