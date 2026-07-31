import 'package:cupid_mobile/core/network/cupid_api.dart';

/// `POST /invitations/accept` failure classification
/// (`coding-plan/master-plan.md` §2, §4 — P0 owns this mapping so no
/// downstream phase string-matches a raw backend message itself).
sealed class PairingFailure {
  const PairingFailure();
}

/// 404 (code not found/inactive) or 400 (code past `expiresAt`) collapsed
/// into one case: UX spec §5 intentionally renders the same line for both so
/// an expired code cannot be distinguished from a wrong one.
class InvalidOrExpiredCodeFailure extends PairingFailure {
  const InvalidOrExpiredCodeFailure();
}

/// 409 `You are already paired with a partner` — the accepting user already
/// has a partner.
class AlreadyPairedFailure extends PairingFailure {
  const AlreadyPairedFailure();
}

/// 409 `Cannot invite yourself` — the code belongs to the user's own
/// account.
class SelfInviteFailure extends PairingFailure {
  const SelfInviteFailure();
}

/// 409 `This person is already paired with a partner` — AC3's couple-only
/// case: the code's inviter has since paired with someone else via a
/// different route.
class InviterAlreadyPairedFailure extends PairingFailure {
  const InviterAlreadyPairedFailure();
}

/// Any transport/HTTP failure not classified above (network, timeout,
/// unauthorized, an unmapped status, or an unrecognized 409 message),
/// carrying the underlying [CupidApiFailure] so a caller that wants a
/// generic error still can, without ever seeing a raw [DioException].
class UnmappedPairingFailure extends PairingFailure {
  const UnmappedPairingFailure(this.cause);

  final CupidApiFailure cause;
}
