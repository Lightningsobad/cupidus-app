import 'package:flutter/widgets.dart';

/// vi/en copy transcribed verbatim from the locked design source's `jar`
/// screen, resolved from the ambient [Locale] rather than the generated
/// `AppL10n` ARB pipeline — `mobile/lib/l10n/**` is outside STORY-027's write
/// scope (same precedent as `chat_strings.dart` and `auth_strings.dart`).
extension DreamJarLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  String viEn(String vi, String en) => _isVi ? vi : en;
}

abstract final class DreamJarStrings {
  /// `t_jar` in the design source — the literal string "Dream Jar" in both
  /// `vi` and `en`, so it is intentionally not locale-branched.
  static const String headerTitle = 'Dream Jar';

  /// The quick-add section label. No ARB key exists for it yet.
  static String quickAddPrompt(BuildContext context) => context.viEn(
    'Thả một chút vào hũ nào 🫙',
    'Drop a little in the jar 🫙',
  );
}
