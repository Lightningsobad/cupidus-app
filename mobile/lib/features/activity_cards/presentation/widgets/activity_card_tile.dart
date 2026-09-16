import 'package:flutter/material.dart';

import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../phase_status/presentation/phase_status_line.dart';
import '../../domain/activity_card.dart';
import '../../domain/activity_type.dart';
import 'activity_status_filter.dart';

/// Days remaining until a scheduled card's date (AC-14), or `null` when the
/// card carries no countdown at all.
///
/// `null` on three distinct cases that all read the same way to a user: a card
/// with no date, a card that is not scheduled, and a date that has already
/// passed. The last one is the point of AC-15 — a missed date is still drawn,
/// neutrally, as the plain date already in the card's meta line, and nothing
/// here counts the days since. There is no overdue label, no negative number
/// and no time of day: the unit is whole days and stops there.
String? activityCardCountdownLabel(
  BuildContext context, {
  required ActivityCard card,
  required DateTime today,
}) {
  if (card.status != ActivityCardStatus.scheduled || card.scheduledOn == null) {
    return null;
  }
  final int? days = civilDaysUntil(
    scheduledOnIso: card.scheduledOn!,
    today: today,
  );
  if (days == null || days < 0) {
    return null;
  }
  if (days == 0) {
    return activityHubText(context, 'Hôm nay', 'Today');
  }
  return activityHubText(context, 'còn $days ngày', '$days days to go');
}

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

/// The secondary choices reachable from the footer overflow (AC-11, D-2).
/// None of them is a primary action: they open from a collapsed "…" and are
/// never drawn beside the CTA as a second button.
enum ActivityCardOverflowAction { changeStatus, edit, delete }

String activityOverflowActionLabel(
  BuildContext context,
  ActivityCardOverflowAction action,
) {
  switch (action) {
    case ActivityCardOverflowAction.changeStatus:
      return activityHubText(context, 'Chuyển trạng thái', 'Change status');
    case ActivityCardOverflowAction.edit:
      return activityHubText(context, 'Sửa', 'Edit');
    case ActivityCardOverflowAction.delete:
      return activityHubText(context, 'Xoá', 'Delete');
  }
}

/// The accessible name of the line-2 leading glyph. The icon is decorative
/// only when the type is known from elsewhere on the card, which it never is,
/// so it always carries a label rather than being announced as a bare image.
String activityTypeSemanticLabel(BuildContext context, ActivityType? type) {
  switch (type) {
    case null:
      return activityHubText(context, 'Chưa rõ loại', 'Type not set');
    case ActivityType.outing:
      return activityHubText(context, 'Đi chơi', 'Outing');
    case ActivityType.home:
      return activityHubText(context, 'Ở nhà', 'At home');
    case ActivityType.visit:
      return activityHubText(context, 'Đi thăm', 'Visiting');
    case ActivityType.dining:
      return activityHubText(context, 'Ăn uống', 'Dining');
    case ActivityType.handmade:
      return activityHubText(context, 'Tự làm', 'Handmade');
    case ActivityType.walk:
      return activityHubText(context, 'Đi bộ', 'A walk');
    case ActivityType.photo:
      return activityHubText(context, 'Chụp ảnh', 'Photos');
    case ActivityType.gift:
      return activityHubText(context, 'Quà', 'A gift');
  }
}

/// One card in a status pane (`ux/uiux-spec.md` §2). The footer holds exactly
/// one primary action, whose label comes from [primaryActionFor] — never a
/// second CTA — plus at most one collapsed "…" overflow holding the secondary
/// choices (AC-11, D-2). Deleting is reachable only from that overflow: D-4
/// ruled that the design canvas carries no per-card delete affordance, and
/// AC-13's "or" branch is already satisfied by the primary action and the
/// status change (`req_master.md` → `## Design Ruling Log`).
class ActivityCardTile extends StatelessWidget {
  const ActivityCardTile({
    super.key,
    required this.card,
    required this.replyState,
    required this.onPrimaryAction,
    required this.onToggleReply,
    required this.onOverflowAction,
    this.today,
  });

  final ActivityCard card;

  /// Effective reply state, which the cubit may be holding optimistically.
  final ActivityCardReplyState replyState;

  /// Clock seam for the countdown, supplied by the hub so every card on screen
  /// counts from the same day. `null` reads the device clock.
  final DateTime? today;
  final VoidCallback onPrimaryAction;
  final VoidCallback onToggleReply;
  final ValueChanged<ActivityCardOverflowAction> onOverflowAction;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String? subtitle = _subtitle(context);
    final String? countdown = activityCardCountdownLabel(
      context,
      card: card,
      today: today ?? DateTime.now(),
    );
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
          Text(
            card.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: type.body.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.colorText,
            ),
          ),
          if (countdown != null) ...<Widget>[
            const SizedBox(height: CupidSpacing.xs),
            Text(
              countdown,
              key: Key('activity_card_countdown_${card.id}'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: type.caption.copyWith(color: colors.colorText),
            ),
          ],
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: CupidSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  activityTypeIcon(card.activityType),
                  key: Key('activity_card_type_icon_${card.id}'),
                  size: 14,
                  color: colors.colorTextMuted,
                  semanticLabel: activityTypeSemanticLabel(
                    context,
                    card.activityType,
                  ),
                ),
                const SizedBox(width: CupidSpacing.xs),
                Expanded(
                  child: Text(
                    subtitle,
                    key: Key('activity_card_meta_${card.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: type.caption.copyWith(color: colors.colorTextMuted),
                  ),
                ),
              ],
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _PrimaryActionPill(
                cardId: card.id,
                label: activityPrimaryActionLabel(
                  context,
                  primaryActionFor(card.status),
                ),
                onTap: onPrimaryAction,
              ),
              const SizedBox(width: CupidSpacing.sm),
              _OverflowButton(cardId: card.id, onSelected: onOverflowAction),
            ],
          ),
        ],
      ),
    );
  }

  /// Optional second line. The price joins it only when it is `> 0`
  /// (`ux/uiux-spec.md` §2); a `null` or `0` price prints nothing at all
  /// rather than a "0đ" placeholder.
  ///
  /// The activity type is deliberately absent: D-5 moved it out of this string
  /// and into the leading glyph, so it is never both an icon and a word.
  String? _subtitle(BuildContext context) {
    final List<String> parts = <String>[
      if (card.scheduledOn != null) card.scheduledOn!,
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

/// The single overflow allowed beside the CTA (`ux/uiux-spec.md` §2 after
/// D-2): a round muted-surface button, deliberately without the `gradientHot`
/// fill and narrower than the CTA, so it reads one tier below it. The glyph is
/// the literal "…" character because `CupidIcons` carries no `more_horiz`
/// codepoint and that file is outside this story's write scope.
class _OverflowButton extends StatelessWidget {
  const _OverflowButton({required this.cardId, required this.onSelected});

  final String cardId;
  final ValueChanged<ActivityCardOverflowAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return PopupMenuButton<ActivityCardOverflowAction>(
      key: Key('activity_card_overflow_$cardId'),
      onSelected: onSelected,
      color: colors.colorSurface,
      tooltip: activityHubText(context, 'Lựa chọn khác', 'More options'),
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<ActivityCardOverflowAction>>[
        for (final ActivityCardOverflowAction action
            in ActivityCardOverflowAction.values)
          PopupMenuItem<ActivityCardOverflowAction>(
            key: Key('activity_card_overflow_${action.name}_$cardId'),
            value: action,
            child: Text(
              activityOverflowActionLabel(context, action),
              style: type.body.copyWith(color: colors.colorText),
            ),
          ),
      ],
      child: SizedBox(
        width: platform.tapTarget,
        height: platform.tapTarget,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.colorSurfaceAlt,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '…',
              style: type.body.copyWith(color: colors.colorTextMuted),
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
