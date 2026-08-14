import 'package:shared_preferences/shared_preferences.dart';

import 'cupid_session.dart';

/// Device-local "this device has been authenticated before" marker
/// (`architecture/solution.md` ADR-3). Firebase maps three different
/// real-world situations — never signed in, deliberate sign-out, and revoked
/// refresh token — onto the same [CupidSessionSignedOut], so it alone cannot
/// satisfy AC2 and AC3 at once. This is a one-bit history flag plus a login
/// prefill hint; it is deliberately not a token and not a second session
/// store.
class AuthHistoryStore implements SessionScopedStore {
  AuthHistoryStore({Future<SharedPreferences> Function()? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance;

  static const _hasPreviousSessionKey = 'auth.has_previous_session_v1';
  static const _lastEmailKey = 'auth.last_email_v1';

  final Future<SharedPreferences> Function() _preferences;

  Future<bool> hasPreviousSession() async {
    final prefs = await _preferences();
    return prefs.getBool(_hasPreviousSessionKey) ?? false;
  }

  Future<String?> lastEmail() async {
    final prefs = await _preferences();
    return prefs.getString(_lastEmailKey);
  }

  /// A null/blank [email] (Apple private relay, Facebook without an email
  /// scope) still sets the marker and drops any previously stored address,
  /// so the session-expired login variant never prefills a different user's
  /// email.
  Future<void> markAuthenticated({String? email}) async {
    final prefs = await _preferences();
    await prefs.setBool(_hasPreviousSessionKey, true);
    if (email == null || email.isEmpty) {
      await prefs.remove(_lastEmailKey);
      return;
    }
    await prefs.setString(_lastEmailKey, email);
  }

  /// AC3 teardown: a deliberate sign-out returns this device to the "never
  /// signed in" outcome. Reached through [CupidSession]'s existing scoped-store
  /// hook, so no second sign-out path exists.
  @override
  Future<void> clearOnSignOut() async {
    final prefs = await _preferences();
    await prefs.remove(_hasPreviousSessionKey);
    await prefs.remove(_lastEmailKey);
  }
}
