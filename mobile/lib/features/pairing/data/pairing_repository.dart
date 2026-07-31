import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:dio/dio.dart';

import 'pairing_failure.dart';
import 'pairing_invitation.dart';
import 'partner_link.dart';

/// Epic-1 invitations REST calls (`coding-plan/master-plan.md` §1 D4, §2).
///
/// `Epic1InvitationsApi`'s generated methods all return
/// `Future<Response<void>>` (backticked to avoid doc-comment HTML parsing)
/// and take no `code` parameter, so the generated client can neither send
/// the `accept` request body nor read `code`/`expiresAt` back.
/// This follows the precedent set in STORY-003
/// (`features/auth/data/auth_repository.dart:_syncBackendProfile`): call
/// `_api.dio` directly and parse the body by hand, keeping
/// `CupidAuthInterceptor` and `CupidErrorInterceptor` (`CupidApiFailure`
/// mapping) in the request path.
///
/// `POST /invitations/validate` is intentionally never called (plan §2): it
/// cannot confirm a pair will succeed and would only add a misleading
/// pre-check.
class PairingRepository {
  PairingRepository({required this._api});

  final CupidApi _api;

  /// Idempotent per backend truth (`invitations.service.ts generateCode`):
  /// returns the existing active code if one exists rather than minting a
  /// new one.
  Future<PairingInvitation> generateInvitation() async {
    try {
      final response = await _api.dio.post<Object?>('/invitations/generate');
      return PairingInvitation.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as CupidApiFailure? ?? const UnexpectedFailure();
    }
  }

  /// D1's poll target: `waiting` calls this until `partnerId` is non-null.
  Future<PartnerLink> getPartnerLink() async {
    try {
      final response = await _api.dio.get<Object?>('/users/me');
      return PartnerLink.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error as CupidApiFailure? ?? const UnexpectedFailure();
    }
  }

  /// Throws a [PairingFailure] on any rejection; never a raw [DioException]
  /// or an unclassified backend message (plan §2, §4).
  Future<void> acceptInvitation(String code) async {
    try {
      await _api.dio.post<Object?>(
        '/invitations/accept',
        data: {'code': code},
      );
    } on DioException catch (e) {
      throw _mapAcceptFailure(e);
    }
  }

  PairingFailure _mapAcceptFailure(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 404 || statusCode == 400) {
      return const InvalidOrExpiredCodeFailure();
    }
    if (statusCode == 409) {
      final body = e.response?.data;
      final message = body is Map ? body['message'] : null;
      switch (message) {
        case 'You are already paired with a partner':
          return const AlreadyPairedFailure();
        case 'Cannot invite yourself':
          return const SelfInviteFailure();
        case 'This person is already paired with a partner':
          return const InviterAlreadyPairedFailure();
      }
    }
    final failure = e.error;
    return UnmappedPairingFailure(
      failure is CupidApiFailure ? failure : const UnexpectedFailure(),
    );
  }
}
