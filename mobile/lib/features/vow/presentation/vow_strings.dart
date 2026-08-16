import 'package:flutter/widgets.dart';

/// vi/en copy transcribed verbatim from the locked design source's `isVow`
/// block and its `t_*` string tables, resolved from the ambient [Locale]
/// rather than the generated `AppL10n` ARB pipeline (mirrors
/// `features/pairing/presentation/pairing_strings.dart`).
extension VowLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  /// Returns [vi] when the ambient locale is Vietnamese, else [en].
  String viEn(String vi, String en) => _isVi ? vi : en;
}
