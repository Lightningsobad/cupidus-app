import 'package:flutter/material.dart';

import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../domain/activity_card.dart';
import 'activity_status_filter.dart';

/// SC-4: one label per status, and the only primary action a card may carry.
String activityPrimaryActionLabel(
  BuildContext context,
  ActivityCardPrimaryAction action,
) {
  switch (action) {
    case ActivityCardPrimaryAction.scheduleDate:
      return activityHubText(context, 'Hẹn ngày', 'Set a date');
    case ActivityCardPrimaryAction.prepare:
      return activityHubText(context, 'Chuẩn bị', 'Prepare');
    case ActivityCardPrimaryAction.recordMemory:
      return activityHubText(context, 'Ghi lại', 'Record it');
    case ActivityCardPrimaryAction.review:
      return activityHubText(context, 'Xem lại', 'Look back');
  }
}

/// One card in a status pane (`ux/uiux-spec.md` §2). The footer holds exactly
/// one primary action, whose label comes from [primaryActionFor] — never a
/// second CTA. Deleting is a low-emphasis affordance in the title row, so
/// AC-13's exit path exists in every pane without breaking SC-4.
class ActivityCardTile extends StatelessWidget {
  const ActivityCardTile({
    super.key,
    required this.card,
    required this.replyState,
    required this.onPrimaryAction,
    required this.onToggleReply,
    required this.onDelete,
  });

  final ActivityCard card;

  /// Effective reply state, which the cubit may be holding optimistically.
  final ActivityCardReplyState replyState;
  final VoidCallback onPrimaryAction;
  final VoidCallback onToggleReply;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String? subtitle = _subtitle(context);
    final bool showReplyChip =
        card.status == ActivityCardStatus.scheduled && card.invited;

    return Container(
      key: Key('activity_card_tile_${card.id}'),
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  card.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: type.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.colorText,
                  ),
                ),
              ),
              const SizedBox(width: CupidSpacing.sm),
              Semantics(
                button: true,
                label: activityHubText(context, 'Xoá thẻ', 'Delete card'),
                child: GestureDetector(
                  key: Key('activity_card_delete_${card.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onDelete,
                  child: SizedBox(
                    width: platform.tapTarget,
                    height: platform.tapTarget,
                    child: Icon(
                      CupidIcons.remove,
                      size: 20,
                      color: colors.colorTextMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: CupidSpacing.xs),
            Text(
              subtitle,
              key: Key('activity_card_meta_${card.id}'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ],
          if (showReplyChip) ...<Widget>[
            const SizedBox(height: CupidSpacing.sm),
            _ReplyChip(
              cardId: card.id,
              replyState: replyState,
              onTap: onToggleReply,
            ),
          ],
          const SizedBox(height: CupidSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: _PrimaryActionPill(
              cardId: card.id,
              label: activityPrimaryActionLabel(
                context,
                primaryActionFor(card.status),
              ),
              onTap: onPrimaryAction,
            ),
          ),
        ],
      ),
    );
  }

  /// Optional second line. The price joins it only when it is `> 0`
  /// (`ux/uiux-spec.md` §2); a `null` or `0` price prints nothing at all
  /// rather than a "0đ" placeholder.
  String? _subtitle(BuildContext context) {
    final List<String> parts = <String>[
      if (card.scheduledOn != null) card.scheduledOn!,
      if (card.activityType != null && card.activityType!.isNotEmpty)
        card.activityType!,
      if (card.distanceKm != null) '${_trimDouble(card.distanceKm!)} km',
      if (card.priceVnd != null && card.priceVnd! > 0)
        _formatVnd(card.priceVnd!),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

String _trimDouble(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

String _formatVnd(int value) {
  final String digits = value.toString();
  final StringBuffer grouped = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      grouped.write('.');
    }
    grouped.write(digits[i]);
  }
  grouped.write('đ');
  return grouped.toString();
}

/// "đã rủ" chip: exactly two values, toggled on tap, with no time label
/// (`ux/uiux-spec.md` §2). It reports this user's own invitation bookkeeping,
/// not a measurement of the other person's behaviour (R-1b, AC-20).
class _ReplyChip extends StatelessWidget {
  const _ReplyChip({
    required this.cardId,
    required this.replyState,
    required this.onTap,
  });

  final String cardId;
  final ActivityCardReplyState replyState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final bool answered = replyState == ActivityCardReplyState.answered;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: Key('activity_card_reply_chip_$cardId'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: Align(
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: answered ? colors.colorMint : colors.colorSurfaceAlt,
                borderRadius: BorderRadius.circular(platform.radiusSmall),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CupidSpacing.sm,
                  vertical: CupidSpacing.xs,
                ),
                child: Text(
                  answered
                      ? activityHubText(context, 'Đã trả lời', 'Answered')
                      : activityHubText(context, 'Chưa trả lời', 'No reply yet'),
                  style: type.caption.copyWith(
                    color: answered ? colors.colorOnAccent : colors.colorTextMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionPill extends StatelessWidget {
  const _PrimaryActionPill({
    required this.cardId,
    required this.label,
    required this.onTap,
  });

  final String cardId;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: Key('activity_card_primary_action_$cardId'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: colors.gradientHot,
              borderRadius: BorderRadius.circular(platform.radiusButton),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.lg,
                vertical: CupidSpacing.sm,
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: type.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.colorText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
