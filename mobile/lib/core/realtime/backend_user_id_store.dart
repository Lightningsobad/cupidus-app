import '../auth/cupid_session.dart';
import 'realtime_failure.dart';

/// Holds the cached backend `User.id` used to key the Socket.IO `joinRoom`
/// room (`architecture/solution.md` §2 `backendUserId`, ADR-012b). Realtime
/// owns the room key: `core/auth/` stays untouched and `features/auth`
/// populates this store after each successful backend profile sync
/// (`AuthRepository._syncBackendProfile`).
class BackendUserIdStore implements SessionScopedStore {
  BackendUserIdStore({Future<String?> Function()? readPersistedUserId})
      : _readPersistedUserId = readPersistedUserId;

  String? _backendUserId;
  final Future<String?> Function()? _readPersistedUserId;

  /// The cached backend `User.id`, or `null` before the first successful
  /// sign-in of this session.
  String? get backendUserId => _backendUserId;

  /// The injected `Future<String?> Function()` resolver contract consumed by
  /// `SocketTransport` / `RealtimeCoordinator` (`architecture/solution.md`
  /// §2 `backendUserId`). Lazily rehydrates from the id already persisted by
  /// `JwtTokenProvider` on a cold app start after login, when a
  /// `readPersistedUserId` reader was injected (`coding-plan/master-plan.md`
  /// §9.3-§9.4) — the RAM cache always wins when already populated.
  Future<String?> resolve() async {
    final cached = _backendUserId;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final read = _readPersistedUserId;
    if (read == null) {
      return cached;
    }
    final persisted = await read();
    if (persisted == null || persisted.isEmpty) {
      return cached;
    }
    _backendUserId = persisted;
    return persisted;
  }

  /// Extracts and caches the backend `User.id` from a `POST /auth/login` or
  /// `POST /auth/register` response body. Throws
  /// [RealtimeRoomKeyUnavailableFailure] when the id is absent — joining a
  /// room keyed by the Firebase uid instead would silently produce a
  /// zero-event socket (§2 Room-key typing gap).
  void updateFromLoginResponse(Object? body) {
    final id = body is Map ? body['id'] : null;
    if (id is! String || id.isEmpty) {
      throw const RealtimeRoomKeyUnavailableFailure();
    }
    _backendUserId = id;
  }

  /// Sets the backend user ID directly (e.g. from `/users/me`).
  void updateUserId(String id) {
    if (id.isNotEmpty) {
      _backendUserId = id;
    }
  }

  /// AC4 teardown: no cached room key survives sign-out, so a second user on
  /// the same device never inherits the first user's room.
  @override
  Future<void> clearOnSignOut() async {
    _backendUserId = null;
  }
}
