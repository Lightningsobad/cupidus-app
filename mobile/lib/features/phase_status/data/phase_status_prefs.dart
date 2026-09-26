import 'package:shared_preferences/shared_preferences.dart';

/// Civil date the 23h reminder for one card was already handled on — fired or
/// skipped, the two are the same terminal state (AC-17/BR-10). One key per
/// card, shaped exactly like `before_you_go_dismissal_store.dart`.
String phaseStatusRemindedOnKey(String cardId) =>
    'phase_status.reminded_on.$cardId';

/// Civil date the last drip item was shown on, the cadence cursor for BR-9.
const String phaseStatusDripLastShownOnKey = 'phase_status.drip.last_shown_on';

/// Durable ids of drip items already consumed. Ids, not indices: the package
/// can grow or be reordered without re-showing an item (R-15a).
const String phaseStatusDripSeenIdsKey = 'phase_status.drip.seen_ids';

/// Highest milestone threshold already announced, so crossing it once is
/// announced once.
const String phaseStatusMilestoneLastShownValueKey =
    'phase_status.milestone.last_shown_value';

const String phaseStatusEveningCheckInEnabledKey =
    'notifications.evening_check_in.enabled';

const String phaseStatusQuietDripEnabledKey = 'notifications.quiet_drip.enabled';

/// Every piece of device-local state this story owns. `SharedPreferences` only:
/// no Drift table, so no `schemaVersion` bump and no migration (ADR-010,
/// `solution.md` §4).
///
/// Both notification toggles read `true` when absent, so a fresh install
/// behaves as opted-in without a first-run write. Turning one off is therefore
/// always an explicit stored `false`, never an inferred one.
class PhaseStatusPrefs {
  PhaseStatusPrefs({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _preferences;

  Future<String?> remindedOn(String cardId) async {
    final SharedPreferences prefs = await _preferences();
    return prefs.getString(phaseStatusRemindedOnKey(cardId));
  }

  Future<void> markReminded(String cardId, String dateIso) async {
    final SharedPreferences prefs = await _preferences();
    await prefs.setString(phaseStatusRemindedOnKey(cardId), dateIso);
  }

  /// Used when `scheduled_on` moves: the old date's record no longer applies,
  /// so the new date gets exactly one fresh schedule.
  Future<void> clearReminded(String cardId) async {
    final SharedPreferences prefs = await _preferences();
    await prefs.remove(phaseStatusRemindedOnKey(cardId));
  }

  Future<String?> dripLastShownOn() async {
    final SharedPreferences prefs = await _preferences();
    return prefs.getString(phaseStatusDripLastShownOnKey);
  }

  Future<void> setDripLastShownOn(String dateIso) async {
    final SharedPreferences prefs = await _preferences();
    await prefs.setString(phaseStatusDripLastShownOnKey, dateIso);
  }

  Future<List<String>> dripSeenIds() async {
    final SharedPreferences prefs = await _preferences();
    return List<String>.unmodifiable(
      prefs.getStringList(phaseStatusDripSeenIdsKey) ?? const <String>[],
    );
  }

  /// Appends [itemId] once. Re-marking an already-seen id is a no-op rather
  /// than an error, so a retried show cannot grow the list.
  Future<void> markDripSeen(String itemId) async {
    final SharedPreferences prefs = await _preferences();
    final List<String> stored =
        prefs.getStringList(phaseStatusDripSeenIdsKey) ?? <String>[];
    if (stored.contains(itemId)) {
      return;
    }
    await prefs.setStringList(
      phaseStatusDripSeenIdsKey,
      <String>[...stored, itemId],
    );
  }

  /// `null` when no milestone has ever been announced, which is distinct from
  /// `0`.
  Future<int?> milestoneLastShownValue() async {
    final SharedPreferences prefs = await _preferences();
    return prefs.getInt(phaseStatusMilestoneLastShownValueKey);
  }

  Future<void> setMilestoneLastShownValue(int value) async {
    final SharedPreferences prefs = await _preferences();
    await prefs.setInt(phaseStatusMilestoneLastShownValueKey, value);
  }

  Future<bool> eveningCheckInEnabled() async {
    final SharedPreferences prefs = await _preferences();
    return prefs.getBool(phaseStatusEveningCheckInEnabledKey) ?? true;
  }

  Future<void> setEveningCheckInEnabled(bool enabled) async {
    final SharedPreferences prefs = await _preferences();
    await prefs.setBool(phaseStatusEveningCheckInEnabledKey, enabled);
  }

  Future<bool> quietDripEnabled() async {
    final SharedPreferences prefs = await _preferences();
    return prefs.getBool(phaseStatusQuietDripEnabledKey) ?? true;
  }

  Future<void> setQuietDripEnabled(bool enabled) async {
    final SharedPreferences prefs = await _preferences();
    await prefs.setBool(phaseStatusQuietDripEnabledKey, enabled);
  }
}
