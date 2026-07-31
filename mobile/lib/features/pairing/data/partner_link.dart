import 'package:cupid_mobile/core/network/cupid_api.dart';

/// The `GET /users/me` field this feature reads (`coding-plan/master-plan.md`
/// §2). D1's `waiting` poll only needs `partnerId`; other profile fields are
/// out of this phase's scope.
class PartnerLink {
  const PartnerLink({required this.partnerId});

  /// Throws [UnexpectedFailure] (`core/network/cupid_api_failure.dart`'s
  /// documented "unparseable response" case) if [body] does not match the
  /// shape above.
  factory PartnerLink.fromJson(Object? body) {
    if (body is! Map) {
      throw const UnexpectedFailure();
    }
    final partnerId = body['partnerId'];
    if (partnerId != null && partnerId is! String) {
      throw const UnexpectedFailure();
    }
    return PartnerLink(partnerId: partnerId as String?);
  }

  final String? partnerId;

  bool get isPaired => partnerId != null;
}
