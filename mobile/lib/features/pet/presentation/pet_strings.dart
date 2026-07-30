import 'package:flutter/widgets.dart';

import '../data/pet_mood.dart';

/// vi/en copy transcribed verbatim from `ux/uiux-spec.md` §2-§4, resolved
/// from the ambient [Locale] rather than the generated `AppL10n` ARB
/// pipeline (`mobile/lib/l10n/arb/**` is outside this feature's write scope).
/// Mirrors `features/auth/presentation/auth_strings.dart`.
extension PetLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  /// Returns [vi] when the ambient locale is Vietnamese, else [en].
  String viEn(String vi, String en) => _isVi ? vi : en;

  /// §3 design label for the given mood (e.g. the `Lv.{level} · {label}`
  /// pill).
  String petMoodLabel(PetMood mood) => switch (mood) {
        PetMood.ecstatic => viEn('Mềm lòng', 'Delighted'),
        PetMood.happy => viEn('Vui phơi phới', 'Happy'),
        PetMood.content => viEn('Tạm ổn', 'Content'),
        PetMood.sad => viEn('Đang dỗi', 'Sulking'),
        PetMood.sick => viEn('Ốm rồi', 'Sick'),
      };

  /// §4 one-sentence status line for the given mood.
  String petStatusLine(PetMood mood) => switch (mood) {
        PetMood.ecstatic =>
          viEn('Bún hôm nay phổng phao ✨', 'Bun is glowing today ✨'),
        PetMood.happy =>
          viEn('Bún đang vui vẻ lắm', 'Bun is having a great day'),
        PetMood.content =>
          viEn('Bún đòi được để ý một chút', 'Bun wants a little attention'),
        PetMood.sad => viEn(
            'Bún đang dỗi. Nhắn nhau nhiều lên.',
            'Bun is sulking. Chat more.',
          ),
        PetMood.sick => viEn(
            'Bún không khoẻ. Ghé thăm Bún đi.',
            "Bun isn't feeling well. Go check on Bun.",
          ),
      };

  /// §2.2 adopt entry-point empty-state headline.
  String get petAdoptHeadline =>
      viEn('Nhận nuôi một Bún cho cả hai', 'Adopt a Bun together');

  /// §2.2 adopt entry-point / adopt-sheet primary CTA.
  String get petAdoptCta => viEn('Nhận nuôi', 'Adopt');

  /// §2.3 unpaired hard-gate headline.
  String get petLockedHeadline =>
      viEn('Ghép đôi để nuôi Bún cùng nhau', 'Pair up to adopt a Bun together');
}
