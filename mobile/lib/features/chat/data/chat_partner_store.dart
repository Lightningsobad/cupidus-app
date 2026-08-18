import 'package:cupid_mobile/core/auth/cupid_session.dart';
import 'package:dio/dio.dart';

/// Chat's cache of the signed-in caller's own name, the paired partner's
/// identity, plus this device's own ghost-consent flag
/// (`architecture/solution.md` §2 `GET /users/me`). Mirrors
/// `core/realtime/backend_user_id_store.dart` in shape. Raw [Dio] is
/// required because the generated `epic1_users_api` returns `Response<void>`
/// and cannot expose the response body — the same limitation
/// `auth_repository.dart:95-109` already works around.
class ChatPartnerStore implements SessionScopedStore {
  ChatPartnerStore({required Dio dio}) : _dio = dio;

  final Dio _dio;

  String? _partnerId;
  String? _selfDisplayName;
  String? _partnerDisplayName;
  bool? _isGhostModeEnabled;

  /// The paired partner's backend `User.id`, or `null` before the first
  /// successful [refreshFromServer] call or once unpaired.
  String? get partnerId => _partnerId;

  /// The signed-in caller's own display name, from `GET /users/me`'s
  /// `displayName` key. This is *not* the partner — three other readers
  /// depend on that key keeping its caller-scoped meaning
  /// (`architecture/contract-summary.md` §2).
  String? get selfDisplayName => _selfDisplayName;

  /// The paired partner's display name, from `GET /users/me`'s
  /// `partnerDisplayName` key. `null` means no partner name is available
  /// (unpaired, dangling `partnerId`, or the partner has no name); it never
  /// means "still loading".
  String? get partnerDisplayName => _partnerDisplayName;

  /// This device's own `isGhostModeEnabled` flag (ADR-013e).
  bool? get isGhostModeEnabled => _isGhostModeEnabled;

  /// Populates all four fields from `GET /users/me`.
  Future<void> refreshFromServer() async {
    final response = await _dio.get<Object?>('/users/me');
    final body = response.data;
    if (body is! Map) return;
    final partnerId = body['partnerId'];
    final selfDisplayName = body['displayName'];
    final partnerDisplayName = body['partnerDisplayName'];
    final isGhostModeEnabled = body['isGhostModeEnabled'];
    _partnerId = partnerId is String ? partnerId : null;
    _selfDisplayName = selfDisplayName is String ? selfDisplayName : null;
    _partnerDisplayName = partnerDisplayName is String
        ? partnerDisplayName
        : null;
    _isGhostModeEnabled = isGhostModeEnabled is bool ? isGhostModeEnabled : null;
  }

  /// AC4 teardown: no cached partner data survives sign-out.
  @override
  Future<void> clearOnSignOut() async {
    _partnerId = null;
    _selfDisplayName = null;
    _partnerDisplayName = null;
    _isGhostModeEnabled = null;
  }
}
