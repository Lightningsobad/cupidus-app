import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists this device's local opt-in decision for Typing Ghost
/// (`architecture/solution.md` ADR-013e). The frozen backend defaults
/// `User.isGhostModeEnabled` to `true`, so the server flag alone is not
/// informed consent for keystroke streaming — the composer stays `off`
/// until this local flag is explicitly set once per device. Raw [Dio] is
/// used for the `PATCH` rather than the generated client, matching
/// `ChatPartnerStore`'s and `auth_repository.dart:95-109`'s existing
/// raw-`Dio` precedent for endpoints the generated client cannot express.
class GhostConsentStore {
  GhostConsentStore({
    required Dio dio,
    Future<SharedPreferences> Function()? preferences,
  })  : _dio = dio,
        _preferences = preferences ?? SharedPreferences.getInstance;

  static const String _storageKey = 'cupid_ghost_local_opt_in_v1';

  final Dio _dio;
  final Future<SharedPreferences> Function() _preferences;

  /// Whether this device has ever explicitly opted in to Typing Ghost.
  Future<bool> hasOptedIn() async {
    final SharedPreferences prefs = await _preferences();
    return prefs.getBool(_storageKey) ?? false;
  }

  /// Records the local opt-in on this device and syncs the server flag
  /// true (`PATCH /users/me {isGhostModeEnabled: true}`).
  Future<void> optIn() async {
    final SharedPreferences prefs = await _preferences();
    await prefs.setBool(_storageKey, true);
    await _dio.patch<Object?>(
      '/users/me',
      data: {'isGhostModeEnabled': true},
    );
  }

  /// Clears the local opt-in on this device and syncs the server flag
  /// false (`PATCH /users/me {isGhostModeEnabled: false}`).
  Future<void> optOut() async {
    final SharedPreferences prefs = await _preferences();
    await prefs.setBool(_storageKey, false);
    await _dio.patch<Object?>(
      '/users/me',
      data: {'isGhostModeEnabled': false},
    );
  }
}
