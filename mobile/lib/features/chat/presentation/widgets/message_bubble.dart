import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../chat_strings.dart';

const BorderRadius _mineRadius = BorderRadius.only(
  topLeft: Radius.circular(22),
  topRight: Radius.circular(22),
  bottomRight: Radius.circular(7),
  bottomLeft: Radius.circular(22),
);

const BorderRadius _theirsRadius = BorderRadius.only(
  topLeft: Radius.circular(22),
  topRight: Radius.circular(22),
  bottomRight: Radius.circular(22),
  bottomLeft: Radius.circular(7),
);

/// One thread bubble (`ux/uiux-spec.md` §3b). Renders as a single accessible
/// node (§8, `Semantics(excludeSemantics: true)`) combining sender context,
/// text, timestamp, and read state, rather than exposing them as separate
/// unlabeled nodes. Read state is exactly two visual states — a single check
/// (sent/delivered) or a double check (seen) — never a third "delivered"
/// state (ADR-013d: the client only ever emits `markSeen`).
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String timestamp = _formatTimestamp(message.createdAt);
    final bool seen = message.status == 'seen';

    final String semanticLabel = isMine
        ? ChatStrings.mineBubbleSemanticLabel(
            context: context,
            content: message.content,
            timestamp: timestamp,
            seen: seen,
          )
        : ChatStrings.theirBubbleSemanticLabel(
            context: context,
            content: message.content,
            timestamp: timestamp,
          );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        container: true,
        label: semanticLabel,
        excludeSemantics: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CupidSpacing.md,
              vertical: CupidSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: isMine ? colors.gradientHot : null,
              color: isMine ? null : colors.colorSurface,
              borderRadius: isMine ? _mineRadius : _theirsRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: type.body.copyWith(
                    color: isMine ? Colors.white : colors.colorText,
                  ),
                ),
                const SizedBox(height: CupidSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timestamp,
                      style: type.caption.copyWith(
                        color: isMine
                            ? Colors.white.withValues(alpha: 0.8)
                            : colors.colorTextMuted,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: CupidSpacing.xs),
                      // `CupidIcons` (design_system/icons/) does not yet
                      // carry verified cmap codepoints for a check glyph —
                      // adding one is out of this phase's write scope. Uses
                      // Flutter's bundled Material Icons font directly
                      // rather than guessing an unverified codepoint on the
                      // app's custom icon font.
                      Icon(
                        seen ? Icons.done_all : Icons.check,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatTimestamp(DateTime dateTime) {
  final DateTime local = dateTime.toLocal();
  final String hour = local.hour.toString().padLeft(2, '0');
  final String minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
