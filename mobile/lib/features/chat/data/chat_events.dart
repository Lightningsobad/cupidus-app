/// Literal `CHAT_EVENTS` strings mirrored from the frozen backend
/// (`backend/src/modules/messages/chat.constants.ts`,
/// `architecture/solution.md` §2 API/event contract). Mirrors only the names
/// this story uses — the delivered-receipt pair is forbidden (ADR-013d) and
/// `emojiStorm`/`emojiStormReceived` are STORY-008 scope.
abstract final class ChatEvents {
  static const String sendMessage = 'sendMessage';
  static const String newMessage = 'newMessage';
  static const String typing = 'typing';
  static const String stopTyping = 'stopTyping';
  static const String ghostTyping = 'ghostTyping';
  static const String ghostStopTyping = 'ghostStopTyping';
  static const String markSeen = 'markSeen';
  static const String messageSeen = 'messageSeen';
}
