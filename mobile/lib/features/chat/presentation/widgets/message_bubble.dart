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

// Off-scale metrics transcribed verbatim from the locked design source
// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `isChat` block).
// They do not map onto the 8pt `CupidSpacing` scale or the `body`/`caption`
// type roles, so they are pinned here instead of being rounded to a token.
const double _maxWidthFactor = 0.78;
const double _bubblePaddingX = 15;
const double _bubblePaddingY = 11;
const double _bubbleFontSize = 15.5;
const double _bubbleLineHeight = 1.4;
const double _metaFontSize = 10;
const double _metaIconSize = 12;

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
            maxWidth: MediaQuery.sizeOf(context).width * _maxWidthFactor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _bubblePaddingX,
                  vertical: _bubblePaddingY,
                ),
                decoration: BoxDecoration(
                  gradient: isMine ? colors.gradientHot : null,
                  color: isMine ? null : colors.colorSurface,
                  borderRadius: isMine ? _mineRadius : _theirsRadius,
                  boxShadow: isMine
                      ? colors.glowShadow
                      : context.cupidPlatform.elevationShadow,
                ),
                child: Text(
                  message.content,
                  style: type.body.copyWith(
                    fontSize: _bubbleFontSize,
                    height: _bubbleLineHeight,
                    color: colors.colorOnAccent,
                  ),
                ),
              ),
              const SizedBox(height: CupidSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timestamp,
                    style: type.caption.copyWith(
                      fontSize: _metaFontSize,
                      color: colors.colorTextMuted,
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
                      size: _metaIconSize,
                      color: colors.colorMint,
                    ),
                  ],
                ],
              ),
            ],
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
