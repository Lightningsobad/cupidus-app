import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:flutter/widgets.dart';

/// Maps the closed [CupidAuthFailure]/[CupidApiFailure] sets to one short
/// user-facing line each (`ux/uiux-spec.md` section 6): "Do not expose raw
/// `CupidApiFailure` types ... to the UI".
///
/// Note: this reads the ambient [Locale] directly rather than through the
/// generated `AppL10n` ARB pipeline (`mobile/lib/l10n/**` is outside this
/// phase's write scope — see the STORY-003 P4 completion report). The
/// vi/en copy below is transcribed verbatim from the UX spec and should be
/// migrated into `AppL10n` as a follow-up.
String authFailureMessage(BuildContext context, Object failure) {
  final bool isVi = Localizations.localeOf(context).languageCode == 'vi';
  return switch (failure) {
    InvalidCredentialFailure() =>
      isVi ? 'Email hoặc mật khẩu không đúng' : 'Incorrect email or password',
    EmailAlreadyInUseFailure() =>
      isVi ? 'Email này đã được sử dụng' : 'This email is already in use',
    WeakPasswordFailure() =>
      isVi ? 'Mật khẩu quá yếu' : 'Password is too weak',
    SessionExpiredFailure() =>
      isVi ? 'Phiên đăng nhập đã hết hạn' : 'Your session has expired',
    AuthNetworkFailure() || NetworkUnavailableFailure() =>
      isVi ? 'Không có kết nối mạng' : 'No internet connection',
    TimeoutFailure() => isVi
        ? 'Kết nối quá chậm, vui lòng thử lại'
        : 'Connection timed out, please try again',
    UnauthorizedFailure() =>
      isVi ? 'Phiên đăng nhập đã hết hạn' : 'Your session has expired',
    _ => isVi
        ? 'Đã có lỗi xảy ra. Vui lòng thử lại.'
        : 'Something went wrong. Please try again.',
  };
}
