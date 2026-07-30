import 'dart:async';

import 'package:cupid_mobile/core/auth/cupid_session.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AC4's offline pairing gate (`architecture/solution.md` §2, §3 OQ4).
enum PairingStatus { paired, unpaired, unknown }

/// Resolves whether the signed-in user is paired, serving a persisted value
/// immediately and refreshing it from `GET /users/me` in the background
/// (`partnerId != null` => paired) so the gate holds correctly offline. Never
/// guesses `paired` when nothing is cached and the network is unavailable.
class CouplePairingStore implements SessionScopedStore {
  CouplePairingStore({
    required this._api,
    required this._backendUserIdStore,
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  static const _keyPrefix = 'cupid_pairing_status_v1';

  final CupidApi _api;
  final BackendUserIdStore _backendUserIdStore;
  final Future<SharedPreferences> Function() _preferences;

  /// Keeps the persistence key resolvable in [clearOnSignOut] even after
  /// [BackendUserIdStore.clearOnSignOut] has already run (D-012-5 teardown
  /// ordering is not guaranteed between session-scoped stores).
  String? _lastKnownUserId;

  Future<PairingStatus> resolve() async {
    final cached = await _readCached();
    if (cached != null) {
      unawaited(_refreshInBackground());
      return cached;
    }
    try {
      final status = await _fetchFromNetwork();
      await _persist(status);
      return status;
    } on CupidApiFailure {
      return PairingStatus.unknown;
    }
  }

  /// AC4 teardown: no persisted status survives sign-out.
  @override
  Future<void> clearOnSignOut() async {
    final key = _resolveKey();
    _lastKnownUserId = null;
    if (key == null) return;
    final prefs = await _preferences();
    await prefs.remove(key);
  }

  Future<void> _refreshInBackground() async {
    try {
      final status = await _fetchFromNetwork();
      await _persist(status);
    } on CupidApiFailure {
      // Keep serving the last persisted value; the next resolve() retries.
    }
  }

  Future<PairingStatus> _fetchFromNetwork() async {
    try {
      final response = await _api.dio.get<Object?>('/users/me');
      final body = response.data;
      final partnerId = body is Map ? body['partnerId'] : null;
      return partnerId != null ? PairingStatus.paired : PairingStatus.unpaired;
    } on DioException catch (e) {
      throw e.error ?? const UnexpectedFailure();
    }
  }

  Future<PairingStatus?> _readCached() async {
    final key = _resolveKey();
    if (key == null) return null;
    final prefs = await _preferences();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return PairingStatus.values.firstWhere(
      (status) => status.name == raw,
      orElse: () => PairingStatus.unknown,
    );
  }

  Future<void> _persist(PairingStatus status) async {
    final key = _resolveKey();
    if (key == null) return;
    final prefs = await _preferences();
    await prefs.setString(key, status.name);
  }

  String? _resolveKey() {
    final id = _backendUserIdStore.backendUserId ?? _lastKnownUserId;
    if (id == null) return null;
    _lastKnownUserId = id;
    return '$_keyPrefix:$id';
  }
}
