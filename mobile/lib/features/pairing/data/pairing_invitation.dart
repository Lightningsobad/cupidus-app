import 'package:cupid_mobile/core/network/cupid_api.dart';

/// `POST /invitations/generate` success body (`coding-plan/master-plan.md`
/// §2). Backend truth (`invitations.service.ts generateCode`): [code] is a
/// 6-character uppercase hex string (`randomBytes(3).toString('hex')
/// .toUpperCase()`, no dash) and [expiresAt] is a 24h-from-creation
/// timestamp. Render [code] exactly as returned — UX spec §3 corrects the
/// design mockup's non-hex "CPD-8F2K" placeholder.
class PairingInvitation {
  const PairingInvitation({required this.code, required this.expiresAt});

  /// Throws [UnexpectedFailure] (`core/network/cupid_api_failure.dart`'s
  /// documented "unparseable response" case) if [body] does not match the
  /// shape above.
  factory PairingInvitation.fromJson(Object? body) {
    if (body is! Map || body['code'] is! String) {
      throw const UnexpectedFailure();
    }
    final expiresAtRaw = body['expiresAt'];
    if (expiresAtRaw is! String) {
      throw const UnexpectedFailure();
    }
    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) {
      throw const UnexpectedFailure();
    }
    return PairingInvitation(code: body['code'] as String, expiresAt: expiresAt);
  }

  final String code;
  final DateTime expiresAt;
}
