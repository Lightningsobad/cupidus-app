import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/auth/cupid_session.dart';

/// Device-local storage for user theme visual preferences (e.g. enabling/disabling dynamic FX).
class ThemePreferencesStore implements SessionScopedStore {
  ThemePreferencesStore({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  static const String _storageKeyEffects = 'cupid_theme_effects_enabled';

  final Future<SharedPreferences> Function() _preferences;

  /// Loads whether dynamic theme animations & particles are enabled. Defaults to `true`.
  Future<bool> isEffectsEnabled() async {
    final prefs = await _preferences();
    return prefs.getBool(_storageKeyEffects) ?? true;
  }

  /// Persists user choice for theme effects.
  Future<void> setEffectsEnabled(bool enabled) async {
    final prefs = await _preferences();
    await prefs.setBool(_storageKeyEffects, enabled);
  }

  @override
  Future<void> clearOnSignOut() async {
    // Keep device preference intact across sign-outs
  }
}
