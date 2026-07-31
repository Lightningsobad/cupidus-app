import 'package:flutter/widgets.dart';

import '../domain/vibe_mood.dart';

/// vi/en copy transcribed verbatim from `ux/uiux-spec.md` (§3-§6) and the
/// design source's `MOODS`/`suggestion`/`suggestionCta` maps, resolved from
/// the ambient [Locale] rather than the generated `AppL10n` ARB pipeline
/// (out of this phase's write scope) — mirrors the shape of
/// `AuthLocaleText` (`features/auth/presentation/auth_strings.dart`).
extension VibeLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  /// Returns [vi] when the ambient locale is Vietnamese, else [en].
  String viEn(String vi, String en) => _isVi ? vi : en;

  /// UX §3 5-value mood label set; `spicy` is [VibeMood.horny]'s display
  /// label (D-010-2).
  String moodLabel(VibeMood mood) => switch (mood) {
    VibeMood.happy => viEn('Vui phơi phới', 'Happy'),
    VibeMood.sad => viEn('Tủi thân', 'Sad'),
    VibeMood.angry => viEn('Đang cọc', 'Angry'),
    VibeMood.horny => viEn('Hơi bậy', 'Spicy'),
    VibeMood.tired => viEn('Kiệt sức', 'Tired'),
  };

  /// UX §5/§6/§7 "no check-in yet" state, reused for the partner card and
  /// the unpair defensive fallback.
  String get waitingLabel => viEn('Chưa nói gì', 'Waiting…');

  /// UX §4 vibe screen header copy (consumed by P3's `VibeScreen`).
  String get checkInPromptTitle =>
      viEn('Hôm nay bạn thế nào?', 'How are you today?');

  /// UX §4 vibe screen header subtitle (consumed by P3's `VibeScreen`).
  String get checkInPromptSubtitle => viEn(
    'Một tap là Bae biết, không cần gõ chữ nào 🎀',
    'One tap and Bae knows — no typing needed 🎀',
  );

  /// UX §6 A-2: accurate "last 7 days" header, replacing the design
  /// source's inaccurate "auto-deleted in 30d" claim (no deletion job
  /// exists on the backend).
  String get historyHeader => viEn('7 ngày gần nhất', 'last 7 days');

  /// UX §5 contextual nudge banner copy. `null` is the "partner has not
  /// checked in yet" state; any mood other than `sad`/`angry`/`tired`
  /// (including the dropped `soft` cell's replacement, §3) falls into the
  /// generic positive-acknowledgment branch.
  String nudgeMessage(VibeMood? partnerMood) => switch (partnerMood) {
    VibeMood.sad => viEn(
      'Bae đang tủi. Gửi một cái ôm ảo nha?',
      'Bae is down. Send a virtual hug?',
    ),
    VibeMood.angry => viEn(
      'Bae đang cọc. Trà sữa có thể cứu.',
      'Bae is fuming. Milk tea might help.',
    ),
    VibeMood.tired => viEn(
      'Bae kiệt sức. Cho ngủ thêm chút đi.',
      'Bae is drained. Let them sleep in.',
    ),
    null => viEn(
      'Bae chưa check-in. Huých một cái?',
      'Bae has not checked in yet. Nudge them.',
    ),
    _ => viEn('Vibe ổn đấy. Gửi lại sticker đi.', 'Good vibes. Send a sticker back.'),
  };

  /// UX §5 decorative nudge pill label (D-010-4: no `onTap`, no interactive
  /// semantics — display copy only).
  String nudgeCta(VibeMood? partnerMood) => switch (partnerMood) {
    VibeMood.sad => viEn('Ôm ảo', 'Send hug'),
    VibeMood.angry => viEn('Trà sữa', 'Order tea'),
    _ => viEn('Huých', 'Nudge'),
  };

  /// UX §6 oldest→newest day-of-week mono label for the 7-day strip, in the
  /// design source's Vietnamese abbreviation order (`T2`..`T7`, `CN`).
  String weekdayLabel(DateTime day) {
    const List<String> vi = <String>['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const List<String> en = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    final int index = day.weekday - 1; // DateTime.monday == 1
    return viEn(vi[index], en[index]);
  }
}
