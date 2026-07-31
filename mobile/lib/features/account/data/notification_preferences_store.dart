import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/cupid_session.dart';

/// Device-local notification-toggle prefs (`coding-plan/master-plan.md` §6.2
/// P5, `ux/uiux-spec.md` §5, DEC-2: AC3 is device-local-only, no network
/// call). Persisted the same way as
/// `mobile/lib/core/realtime/pending_event_store.dart:16-24` — `defaults`
/// resolves each row's initial on/off state from the design source
/// (`cupid-mobile-design/Cupid Screens.dc.html:1597-1605`).
class NotificationPreferencesStore implements SessionScopedStore {
  NotificationPreferencesStore({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  static const _storageKey = 'cupid_notification_preferences_v1';

  static const Map<String, bool> defaults = <String, bool>{
    'syncedAlarm': true,
    'emojiStorm': true,
    'vibeCheck': true,
    'petNeedsYou': true,
    'baeTyping': false,
    'dreamJarMilestone': true,
    'loveTimelineOnThisDay': false,
  };

  final Future<SharedPreferences> Function() _preferences;

  /// Every row's current on/off state, filled in with [defaults] for any
  /// row never persisted before.
  Future<Map<String, bool>> load() async {
    final prefs = await _preferences();
    return _decode(prefs.getString(_storageKey));
  }

  Future<void> setEnabled(String key, bool enabled) async {
    final prefs = await _preferences();
    final entries = _decode(prefs.getString(_storageKey))..[key] = enabled;
    await prefs.setString(_storageKey, jsonEncode(entries));
  }

  /// OQ-B: clears on sign-out for shared-device safety, matching every other
  /// `SharedPreferences`-backed `SessionScopedStore` in this codebase.
  @override
  Future<void> clearOnSignOut() async {
    final prefs = await _preferences();
    await prefs.remove(_storageKey);
  }

  Map<String, bool> _decode(String? raw) {
    if (raw == null) return Map<String, bool>.of(defaults);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return <String, bool>{
      for (final MapEntry<String, bool> entry in defaults.entries)
        entry.key: decoded[entry.key] as bool? ?? entry.value,
    };
  }
}
