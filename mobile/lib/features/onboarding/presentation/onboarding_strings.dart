import 'package:flutter/widgets.dart';

/// vi/en copy transcribed verbatim from the locked design source
/// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `isPermissions`
/// block and its `permList` fixture), resolved from the ambient [Locale]
/// rather than the generated `AppL10n` ARB pipeline — `mobile/lib/l10n/**` is
/// outside this story's write scope, matching the `auth_strings.dart`
/// precedent.
extension OnboardingLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  /// Returns [vi] when the ambient locale is Vietnamese, else [en].
  String viEn(String vi, String en) => _isVi ? vi : en;
}
