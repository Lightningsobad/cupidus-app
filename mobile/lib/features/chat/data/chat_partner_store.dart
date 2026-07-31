import 'package:cupid_mobile/core/auth/cupid_session.dart';
import 'package:dio/dio.dart';

/// Chat's cache of the paired partner plus this device's own ghost-consent
/// flag (`architecture/solution.md` §2 `GET /users/me`). Mirrors
/// `core/realtime/backend_user_id_store.dart` in shape. Raw [Dio] is
/// required because the generated `epic1_users_api` returns `Response<void>`
/// and cannot expose the response body — the same limitation
/// `auth_repository.dart:95-109` already works around.
class ChatPartnerStore implements SessionScopedStore {
  ChatPartnerStore({required Dio dio}) : _dio = dio;

  final Dio _dio;

  String? _partnerId;
  String? _displayName;
  bool? _isGhostModeEnabled;

  /// The paired partner's backend `User.id`, or `null` before the first
  /// successful [refreshFromServer] call or once unpaired.
  String? get partnerId => _partnerId;

  /// The paired partner's display name.
  String? get displayName => _displayName;

  /// This device's own `isGhostModeEnabled` flag (ADR-013e).
  bool? get isGhostModeEnabled => _isGhostModeEnabled;

  /// Populates all three fields from `GET /users/me`.
  Future<void> refreshFromServer() async {
    final response = await _dio.get<Object?>('/users/me');
    final body = response.data;
    if (body is! Map) return;
    final partnerId = body['partnerId'];
    final displayName = body['displayName'];
    final isGhostModeEnabled = body['isGhostModeEnabled'];
    _partnerId = partnerId is String ? partnerId : null;
    _displayName = displayName is String ? displayName : null;
    _isGhostModeEnabled = isGhostModeEnabled is bool ? isGhostModeEnabled : null;
  }

  /// AC4 teardown: no cached partner data survives sign-out.
  @override
  Future<void> clearOnSignOut() async {
    _partnerId = null;
    _displayName = null;
    _isGhostModeEnabled = null;
  }
}
