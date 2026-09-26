import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The one key this store owns (`architecture/contract-summary.md` §2). Its
/// value is a JSON object `{"<setId>": <cursor>}`.
const String zodiacRotationCursorKey = 'zodiac_shell.rotation_cursor.v1';

/// Where each set resumes next time it is played (AC-32).
///
/// Shaped like `features/before_you_go/data/before_you_go_dismissal_store.dart`:
/// one `SharedPreferences` string behind an injectable accessor, so no Drift
/// table and no `schemaVersion` bump (ADR-010, `solution.md` §6).
///
/// The cursor is stored already reduced modulo the set's length, so the number
/// on disk is a *position*, never a tally. That is what makes "how many rounds
/// have I played", "how many are left", and "I have finished them all"
/// unanswerable from this state rather than merely unexposed (AC-18/AC-31).
class ZodiacRotationStore {
  ZodiacRotationStore({Future<SharedPreferences> Function()? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _preferences;

  /// The question indices to ask next for [setId], and the only method here.
  ///
  /// [total] and [perRound] are read off the set, never off a constant: a pack
  /// that ships one more question rotates one step further with no code change
  /// (R-15b/AC-31). Running past the last question wraps to the first in the
  /// same order, so there is no exhausted state to store and no dead end to
  /// render (AC-32).
  Future<List<int>> nextWindow({
    required String setId,
    required int total,
    required int perRound,
  }) async {
    if (total < 1) {
      throw ArgumentError.value(total, 'total', 'a set has at least one question');
    }
    if (perRound < 1 || perRound > total) {
      throw ArgumentError.value(perRound, 'perRound', 'must be within 1..$total');
    }

    final SharedPreferences prefs = await _preferences();
    final Map<String, int> cursors = _decodeCursors(
      prefs.getString(zodiacRotationCursorKey),
    );
    final int cursor = (cursors[setId] ?? 0) % total;

    final List<int> window = <int>[
      for (int step = 0; step < perRound; step += 1) (cursor + step) % total,
    ];

    cursors[setId] = (cursor + perRound) % total;
    await prefs.setString(zodiacRotationCursorKey, jsonEncode(cursors));

    return List<int>.unmodifiable(window);
  }

  /// A value this store did not write — a downgrade, a wiped preference, a
  /// hand-edited file — restarts the rotation instead of failing the round.
  static Map<String, int> _decodeCursors(String? raw) {
    if (raw == null) {
      return <String, int>{};
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return <String, int>{};
    }
    if (decoded is! Map<String, Object?>) {
      return <String, int>{};
    }
    return <String, int>{
      for (final MapEntry<String, Object?> entry in decoded.entries)
        if (entry.value is int && (entry.value as int) >= 0)
          entry.key: entry.value as int,
    };
  }
}
