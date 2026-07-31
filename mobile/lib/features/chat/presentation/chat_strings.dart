import 'package:flutter/widgets.dart';

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
    'Chỉ nằm trên máy hai người',
    'Stays on your two devices only',
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
}
