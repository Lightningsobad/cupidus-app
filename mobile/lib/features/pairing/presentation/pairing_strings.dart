import 'package:flutter/widgets.dart';

/// vi/en copy transcribed verbatim from `ux/uiux-spec.md`, resolved from the
/// ambient [Locale] rather than the generated `AppL10n` ARB pipeline
/// (`mobile/lib/l10n/**` is outside this phase's write scope — mirrors
/// `features/auth/presentation/auth_strings.dart`).
extension PairingLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  /// Returns [vi] when the ambient locale is Vietnamese, else [en].
  String viEn(String vi, String en) => _isVi ? vi : en;
}
