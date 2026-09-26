import 'package:shared_preferences/shared_preferences.dart';

import '../domain/before_you_go_resolver.dart';

/// Device-local record of the civil date the block was closed on, one key per
/// card (`architecture/contract-summary.md` §2). Shaped exactly like
/// `features/account/data/notification_preferences_store.dart`: a
/// `SharedPreferences` string behind an injectable accessor, nothing else — no
/// Drift table, so no `schemaVersion` bump (ADR-010).
///
/// The stored value *is* the day it applies to, so the key stops applying by
/// itself once the calendar rolls over. That is why there is no cleanup job and
/// no reconciliation against deleted cards: a stale key can only ever compare
/// unequal to today.
class BeforeYouGoDismissalStore {
  BeforeYouGoDismissalStore({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _preferences;

  /// The `YYYY-MM-DD` the user closed the block on for [cardId], or `null` if
  /// they never have.
  Future<String?> dismissedOn(String cardId) async {
    final SharedPreferences prefs = await _preferences();
    return prefs.getString(beforeYouGoDismissedOnKey(cardId));
  }

  Future<void> dismiss(String cardId, String dateIso) async {
    final SharedPreferences prefs = await _preferences();
    await prefs.setString(beforeYouGoDismissedOnKey(cardId), dateIso);
  }

  /// "Mở lại" (AC-16). Removes the key rather than writing a sentinel, so the
  /// absent-key and reopened cases stay the same single state.
  Future<void> reopen(String cardId) async {
    final SharedPreferences prefs = await _preferences();
    await prefs.remove(beforeYouGoDismissedOnKey(cardId));
  }
}
