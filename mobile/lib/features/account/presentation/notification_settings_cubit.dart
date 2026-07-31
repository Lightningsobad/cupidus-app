import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/notification_preferences_store.dart';

/// `notifs` screen state (`coding-plan/master-plan.md` §6.2 P5,
/// `ux/uiux-spec.md` §5).
sealed class NotificationSettingsState {
  const NotificationSettingsState();
}

class NotificationSettingsLoading extends NotificationSettingsState {
  const NotificationSettingsLoading();
}

class NotificationSettingsLoaded extends NotificationSettingsState {
  const NotificationSettingsLoaded(this.preferences);

  final Map<String, bool> preferences;
}

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit({required this._store})
    : super(const NotificationSettingsLoading()) {
    _load();
  }

  final NotificationPreferencesStore _store;

  Future<void> _load() async {
    final Map<String, bool> preferences = await _store.load();
    if (!isClosed) emit(NotificationSettingsLoaded(preferences));
  }

  /// Emits the flipped value immediately so the pill responds without
  /// waiting on the persistence round trip, then persists it.
  Future<void> setEnabled(String key, bool enabled) async {
    final NotificationSettingsState current = state;
    if (current is! NotificationSettingsLoaded) return;

    final Map<String, bool> updated = Map<String, bool>.of(
      current.preferences,
    )..[key] = enabled;
    emit(NotificationSettingsLoaded(updated));
    await _store.setEnabled(key, enabled);
  }
}
