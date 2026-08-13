import 'package:flutter/widgets.dart';

import 'ghost_cubit.dart' show GhostConsentLevel;

/// vi/en copy transcribed verbatim from `ux/uiux-spec.md`, resolved from the
/// ambient [Locale] rather than the generated `AppL10n` ARB pipeline
/// (`mobile/lib/l10n/**` is outside this phase's write scope — see the
/// STORY-003 P4 completion report, same precedent `auth_strings.dart` uses).
extension ChatLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  String viEn(String vi, String en) => _isVi ? vi : en;
}

/// `chat` screen copy (`ux/uiux-spec.md` §3a-§3e, §5, §8).
abstract final class ChatStrings {
  static String privacyChip(BuildContext context) => context.viEn(
    'Level 1 · chỉ nằm trên máy hai người',
    'Level 1 · on your devices only',
  );

  /// Placeholder copy — pending PO sign-off as the final user-facing string
  /// (`ux/uiux-spec.md` §10.6). Only shown once a page-1 fetch has completed
  /// with zero rows (`ChatState.showEmptyState`), never during the initial
  /// fetch itself.
  static String emptyStateFirstOpen(BuildContext context) =>
      context.viEn('Chào Bae đi 👋', 'Say hi 👋');

  static String degradedIndicator(BuildContext context) =>
      context.viEn('Mất kết nối realtime', 'Realtime connection lost');

  static String composerHint(BuildContext context) =>
      context.viEn('Nhắn gì đó…', 'Type a message…');

  static String mineBubbleSemanticLabel({
    required BuildContext context,
    required String content,
    required String timestamp,
    required bool seen,
  }) => context.viEn(
    'Tin nhắn của bạn: $content, $timestamp, '
        '${seen ? "đã xem" : "đã gửi"}',
    'Your message: $content, $timestamp, '
        '${seen ? "seen" : "sent"}',
  );

  static String theirBubbleSemanticLabel({
    required BuildContext context,
    required String content,
    required String timestamp,
  }) => context.viEn(
    'Tin nhắn của Bae: $content, $timestamp',
    'Their message: $content, $timestamp',
  );

  // -- Typing Ghost (`ux/uiux-spec.md` §3d, §4, §8) --------------------

  /// Glyph-only visible toggle label (§3d) — never the sole accessible
  /// signal, see [ghostToggleSemanticLabel] (§8).
  static String ghostToggleGlyph(GhostConsentLevel level) =>
      switch (level) {
        GhostConsentLevel.off => 'OFF',
        GhostConsentLevel.pending => '···',
        GhostConsentLevel.on => 'ON',
      };

  /// Accessible label for the 3-state toggle — must not rely on colour or
  /// the `···` glyph alone (§8).
  static String ghostToggleSemanticLabel(
    BuildContext context,
    GhostConsentLevel level,
  ) => switch (level) {
    GhostConsentLevel.off =>
      context.viEn('Typing Ghost: tắt', 'Typing Ghost: off'),
    GhostConsentLevel.pending => context.viEn(
      'Typing Ghost: đang chờ cả hai đồng ý',
      'Typing Ghost: waiting for both to agree',
    ),
    GhostConsentLevel.on =>
      context.viEn('Typing Ghost: đang bật', 'Typing Ghost: on'),
  };

  /// Standing composer placeholder while Ghost is on (§3d) — reused
  /// verbatim from the design source.
  static String composerHintGhostOn(BuildContext context) =>
      context.viEn('Đối phương thấy từng chữ…', 'They see every keystroke…');

  /// "You are being watched" warning row (§3d) — shown only while Ghost is
  /// on and the draft is non-empty; reused verbatim, partner name
  /// interpolated.
  static String ghostWatchingWarning(
    BuildContext context,
    String partnerName,
  ) => context.viEn(
    '$partnerName đang xem bạn gõ',
    '$partnerName is watching you type',
  );

  /// Assertive-priority announcement for a ghost on/off transition
  /// (`ux/uiux-spec.md` §8) — never fired for the `pending` state or for
  /// per-keystroke draft deltas.
  static String ghostTurnedOnAnnouncement(BuildContext context) =>
      context.viEn('Typing Ghost đã bật', 'Typing Ghost turned on');

  static String ghostTurnedOffAnnouncement(BuildContext context) =>
      context.viEn('Typing Ghost đã tắt', 'Typing Ghost turned off');

  /// Header line above the partner's live draft bubble (design source
  /// `Cupid Screens.dc.html` §isChat `ghostHeader`).
  static String ghostBubbleHeader(BuildContext context, String partnerName) =>
      context.viEn('$partnerName đang nghĩ…', '$partnerName is thinking…');

  static String ghostPartnerDraftSemanticLabel(
    BuildContext context,
    String content,
  ) => context.viEn(
    'Đối phương đang gõ: $content',
    'Partner is typing: $content',
  );

  // -- `ghostset` screen (§4) -------------------------------------------

  static String ghostSetHeroHeadline(BuildContext context) => context.viEn(
    'Đối phương thấy cả phần bạn đã xoá',
    'They see what you deleted',
  );

  /// Sub-200ms delivery / no-persistence claim. The "under 200ms" figure is
  /// existing product copy carried over from the design source, not a
  /// verified engineering SLA (`architecture/solution.md` ADR-013b latency
  /// caveat, `coding-plan/phase-P3-typing-ghost.md` §5 notes) — PO owns
  /// revising this line if the achievable latency differs materially.
  static String ghostSetHeroBody(BuildContext context) => context.viEn(
    'Ký tự bạn gõ đến trong dưới 200ms và không bao giờ được lưu lại.',
    'Your keystrokes arrive in under 200ms and are never stored.',
  );

  static String ghostSetToggleTitle(BuildContext context) =>
      context.viEn('Typing Ghost', 'Typing Ghost');

  static String ghostSetToggleStateLine(
    BuildContext context,
    GhostConsentLevel level,
  ) => switch (level) {
    GhostConsentLevel.off => context.viEn('Tắt', 'Off'),
    GhostConsentLevel.pending => context.viEn(
      'Đang chờ cả hai đồng ý',
      'Waiting for both to agree',
    ),
    GhostConsentLevel.on =>
      context.viEn('Đang bật · cả hai đã đồng ý', 'On · both agreed'),
  };

  static String ghostSetConsentAgreed(BuildContext context) =>
      context.viEn('Đã đồng ý', 'Agreed');

  static String ghostSetConsentOff(BuildContext context) =>
      context.viEn('Tắt', 'Off');

  static String ghostSetYouColumn(BuildContext context) =>
      context.viEn('Bạn', 'You');

  static String ghostSetPartnerColumn(BuildContext context) =>
      context.viEn('Đối phương', 'Partner');

  /// The contract exposes no partner flag — this column reads
  /// waiting/unknown, never a definite "off" (`coding-plan/phase-P3-typing
  /// -ghost.md` §6 required checks).
  static String ghostSetPartnerUnknown(BuildContext context) =>
      context.viEn('Chưa rõ', 'Waiting to hear back');

  static String ghostSetMutualConsentFooter(BuildContext context) =>
      context.viEn(
        'Cả hai phải đồng ý. Một trong hai người tắt sẽ tắt cho cả hai.',
        'Both must agree. Either one turning it off stops it for both.',
      );

  static String ghostSetLegendLive(BuildContext context) =>
      context.viEn('Đang gõ', 'Live text');

  static String ghostSetLegendDeleted(BuildContext context) =>
      context.viEn('Đã xoá', 'Deleted text');

  static String ghostSetEphemeralFooter(BuildContext context) =>
      context.viEn(
        '100% ẩn danh tạm thời. Ký tự chỉ đi qua socket — không bao giờ '
            'được ghi vào cơ sở dữ liệu hay lịch sử trò chuyện của bạn.',
        '100% ephemeral. Keystrokes pass through the socket only — never '
            'written to a database or your chat history.',
      );
}
