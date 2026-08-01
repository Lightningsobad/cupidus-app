import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/cupid_session.dart';

/// Client-local reminder preferences (`architecture/solution.md` §4 Data):
/// the weekday selection that computes the next single occurrence sent to
/// the backend (ASSUMPTION-1 -- the frozen `Alarm` entity has no recurrence
/// column) and the unacknowledged-timeout flag left behind by the 5-minute
/// client timeout (§4 D4) for the toast on next open. Both keys are cleared
/// on sign-out through [SessionScopedStore] (AC4).
class ReminderLocalPrefs implements SessionScopedStore {
  ReminderLocalPrefs({Future<SharedPreferences> Function()? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance;

  static const _weekdaysKey = 'reminder.weekdays';
  static const _pendingTimeoutNoticeKey = 'reminder.pending_timeout_notice';

  final Future<SharedPreferences> Function() _preferences;

  /// `DateTime.weekday` values (1 = Monday .. 7 = Sunday).
  Future<Set<int>> loadWeekdays() async {
    final prefs = await _preferences();
    final raw = prefs.getStringList(_weekdaysKey) ?? const <String>[];
    return raw.map(int.parse).toSet();
  }

  Future<void> saveWeekdays(Set<int> weekdays) async {
    final prefs = await _preferences();
    await prefs.setStringList(
      _weekdaysKey,
      weekdays.map((day) => day.toString()).toList(),
    );
  }

  /// Whether the 5-minute client timeout (§4 D4) fired while unacknowledged.
  Future<bool> loadPendingTimeoutNotice() async {
    final prefs = await _preferences();
    return prefs.getBool(_pendingTimeoutNoticeKey) ?? false;
  }

  Future<void> setPendingTimeoutNotice(bool value) async {
    final prefs = await _preferences();
    await prefs.setBool(_pendingTimeoutNoticeKey, value);
  }

  /// AC4 teardown: no local reminder preference survives sign-out, so a
  /// second user on the same device never inherits the first user's
  /// weekday selection or pending-notice flag.
  @override
  Future<void> clearOnSignOut() async {
    final prefs = await _preferences();
    await prefs.remove(_weekdaysKey);
    await prefs.remove(_pendingTimeoutNoticeKey);
  }
}
