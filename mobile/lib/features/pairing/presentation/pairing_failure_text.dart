import 'package:flutter/widgets.dart';

import '../data/pairing_failure.dart';

/// Maps the closed [PairingFailure] set to one short user-facing line each
/// (`ux/uiux-spec.md` §5): every `accept` rejection renders inline beneath
/// the "Pair up" button, never a raw backend message.
///
/// Note: this reads the ambient [Locale] directly rather than through the
/// generated `AppL10n` ARB pipeline, mirroring `features/auth/presentation/
/// auth_failure_text.dart` (`mobile/lib/l10n/**` is outside this phase's
/// write scope).
String pairingFailureMessage(BuildContext context, PairingFailure failure) {
  final bool isVi = Localizations.localeOf(context).languageCode == 'vi';
  return switch (failure) {
    InvalidOrExpiredCodeFailure() =>
      isVi ? 'Mã không đúng hoặc đã hết hạn' : 'Invalid or expired code',
    AlreadyPairedFailure() =>
      isVi ? 'Bạn đã được ghép đôi rồi' : "You're already paired",
    SelfInviteFailure() =>
      isVi ? 'Đây là mã của chính bạn' : 'This is your own code',
    InviterAlreadyPairedFailure() => isVi
        ? 'Người này đã ghép đôi với người khác rồi'
        : 'This person is already paired with someone else',
    UnmappedPairingFailure() => isVi
        ? 'Đã có lỗi xảy ra. Vui lòng thử lại.'
        : 'Something went wrong. Please try again.',
  };
}
