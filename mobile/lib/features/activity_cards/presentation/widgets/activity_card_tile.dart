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
int? activityCardCountdownDays({
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
  return days;
}

/// The countdown as one readable sentence. The card draws the number at
/// display size beside its unit (D-4), so this stays the spoken form: a screen
/// reader hears "còn 4 ngày", not a bare numeral followed by a noun.
String? activityCardCountdownLabel(
  BuildContext context, {
  required ActivityCard card,
  required DateTime today,
}) {
  final int? days = activityCardCountdownDays(card: card, today: today);
  if (days == null) {
    return null;
  }
  if (days == 0) {
    return activityHubText(context, 'Hôm nay', 'Today');
  }
  return activityHubText(context, 'còn $days ngày', '$days days to go');
}

const Map<int, String> _weekdayVi = <int, String>{
  DateTime.monday: 'T2',
  DateTime.tuesday: 'T3',
  DateTime.wednesday: 'T4',
  DateTime.thursday: 'T5',
  DateTime.friday: 'T6',
  DateTime.saturday: 'T7',
  DateTime.sunday: 'CN',
};

const Map<int, String> _weekdayEn = <int, String>{
  DateTime.monday: 'MON',
  DateTime.tuesday: 'TUE',
  DateTime.wednesday: 'WED',
  DateTime.thursday: 'THU',
  DateTime.friday: 'FRI',
  DateTime.saturday: 'SAT',
  DateTime.sunday: 'SUN',
};

/// The scheduled date as a reader sees dates (D-3), not as the store holds
/// them: the card used to print the raw `YYYY-MM-DD` column value.
///
/// Day granularity only, and deliberately so — the card carries a civil date
/// and no clock field, so there is no hour to print and none is invented. An
/// unparseable value falls back to the stored string rather than to a blank,
/// because a date a user typed is still information.
String activityCardDateLabel(
  BuildContext context, {
  required String scheduledOnIso,
  required DateTime today,
}) {
  final DateTime? date = DateTime.tryParse('${scheduledOnIso}T00:00:00Z');
  if (date == null) {
    return scheduledOnIso;
  }
  if (civilDaysUntil(scheduledOnIso: scheduledOnIso, today: today) == 0) {
    return activityHubText(context, 'HÔM NAY', 'TODAY');
  }
  final String weekday = activityHubText(
    context,
    _weekdayVi[date.weekday]!,
    _weekdayEn[date.weekday]!,
  );
  return '$weekday ${date.day}/${date.month}';
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

/// The status half of the card eyebrow (D-2). Reports where the card already
/// is, in this user's own bookkeeping — never a judgement of the other person:
/// "đang đợi" is the state of an invitation this user sent, which is exactly
/// what the reply chip already records (R-1b, AC-20).
String activityCardStatusLabel(
  BuildContext context, {
  required ActivityCard card,
  required ActivityCardReplyState replyState,
  required int? countdownDays,
}) {
  switch (card.status) {
    case ActivityCardStatus.idea:
      return activityHubText(context, 'MỚI NGHĨ RA', 'NEW IDEA');
    case ActivityCardStatus.done:
      return activityHubText(context, 'ĐÃ XONG', 'DONE');
    case ActivityCardStatus.memory:
      return activityHubText(context, 'KỶ NIỆM', 'A MEMORY');
    case ActivityCardStatus.scheduled:
      if (countdownDays == 0) {
        return activityHubText(context, 'ĐÚNG HÔM NAY', 'TODAY IS THE DAY');
      }
      if (!card.invited) {
        return activityHubText(context, 'ĐÃ HẸN NGÀY', 'DATE SET');
      }
      return replyState == ActivityCardReplyState.answered
          ? activityHubText(context, 'CHỐT RỒI', 'CONFIRMED')
          : activityHubText(context, 'ĐANG ĐỢI TRẢ LỜI', 'WAITING FOR A REPLY');
  }
}

/// The eyebrow dot, which carries the same distinction as the label beside it
/// and never carries it alone — the colour is a second channel on a text label,
/// not the only way to read the state (`ux/uiux-spec.md` §5).
Color activityCardStatusColor(
  CupidColorTokens colors, {
  required ActivityCard card,
  required ActivityCardReplyState replyState,
  required int? countdownDays,
}) {
  switch (card.status) {
    case ActivityCardStatus.idea:
      return colors.colorAccentLilac;
    case ActivityCardStatus.done:
    case ActivityCardStatus.memory:
      return colors.colorMint;
    case ActivityCardStatus.scheduled:
      if (countdownDays == 0) {
        return colors.colorAccentPink;
      }
      if (card.invited && replyState != ActivityCardReplyState.answered) {
        return colors.colorAccentPurple;
      }
      return colors.colorMint;
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
    this.phaseBlock,
  });

  final ActivityCard card;

  /// The phase guidance block, when this card is the one the phase is about
  /// (D-1). It sits inside the card, on its own surface, because the design
  /// draws it as part of the card it explains rather than as a heading over
  /// the whole list. `null` on every other card.
  final Widget? phaseBlock;

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
    final DateTime day = today ?? DateTime.now();
    final String? subtitle = _subtitle(context);
    final int? countdownDays = activityCardCountdownDays(card: card, today: day);
    // D-5: the card whose date is today is the one thing on the screen the user
    // can still act on, so it is drawn one tier up — lifted surface, accent
    // edge, full-width call to action — instead of as one more card in a stack
    // of equals.
    final bool today0 = countdownDays == 0;
    final bool showReplyChip =
        card.status == ActivityCardStatus.scheduled && card.invited;
    final Widget? phaseBlock = this.phaseBlock;

    return Container(
      key: Key('activity_card_tile_${card.id}'),
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: today0 ? colors.colorSurfaceAlt : colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        border: today0
            ? Border.all(
                color: colors.colorAccentPink.withValues(alpha: 0.55),
                width: 1.5,
              )
            : null,
        boxShadow: today0 ? colors.glowShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StatusEyebrow(
            cardId: card.id,
            label: <String>[
              activityCardStatusLabel(
                context,
                card: card,
                replyState: replyState,
                countdownDays: countdownDays,
              ),
              if (card.scheduledOn != null && !today0)
                activityCardDateLabel(
                  context,
                  scheduledOnIso: card.scheduledOn!,
                  today: day,
                ),
            ].join(' · '),
            color: activityCardStatusColor(
              colors,
              card: card,
              replyState: replyState,
              countdownDays: countdownDays,
            ),
          ),
          const SizedBox(height: CupidSpacing.xs),
          Text(
            card.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: type.body.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.colorText,
            ),
          ),
          if (countdownDays != null && countdownDays > 0) ...<Widget>[
            const SizedBox(height: CupidSpacing.xs),
            _CountdownBlock(
              cardId: card.id,
              days: countdownDays,
              spoken: activityCardCountdownLabel(
                context,
                card: card,
                today: day,
              )!,
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
          if (phaseBlock != null) ...<Widget>[
            const SizedBox(height: CupidSpacing.md),
            phaseBlock,
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
            mainAxisSize: today0 ? MainAxisSize.max : MainAxisSize.min,
            children: <Widget>[
              if (today0)
                Expanded(
                  child: _PrimaryActionPill(
                    cardId: card.id,
                    wide: true,
                    label: activityPrimaryActionLabel(
                      context,
                      primaryActionFor(card.status),
                    ),
                    onTap: onPrimaryAction,
                  ),
                )
              else
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
  ///
  /// The date is absent for the same reason since D-3: it is drawn once, in the
  /// eyebrow, in the form a reader expects — it used to appear here as the raw
  /// `YYYY-MM-DD` column value.
  String? _subtitle(BuildContext context) {
    final List<String> parts = <String>[
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

/// The status eyebrow above the card title (D-2): a phase-coloured dot and the
/// state in small caps, with the date joined onto it when the card has one.
class _StatusEyebrow extends StatelessWidget {
  const _StatusEyebrow({
    required this.cardId,
    required this.label,
    required this.color,
  });

  final String cardId;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;

    return Row(
      children: <Widget>[
        Container(
          key: Key('activity_card_eyebrow_dot_$cardId'),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: CupidSpacing.xs),
        Expanded(
          child: Text(
            label,
            key: Key('activity_card_eyebrow_$cardId'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // 12px small-caps eyebrow, per the size the design source draws
            // card eyebrows at — see the `caption` dartdoc in
            // `CupidTypographyTokens`, which owns the 13px metadata role only.
            style: type.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// The days-remaining number at display size beside its unit (D-4). The pair
/// is announced as one sentence so the number is never read out on its own.
class _CountdownBlock extends StatelessWidget {
  const _CountdownBlock({
    required this.cardId,
    required this.days,
    required this.spoken,
  });

  final String cardId;
  final int days;
  final String spoken;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      label: spoken,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '$days',
            key: Key('activity_card_countdown_numeral_$cardId'),
            style: type.display.copyWith(
              color: colors.colorAccentPink,
              height: 1,
            ),
          ),
          const SizedBox(width: CupidSpacing.sm),
          Expanded(
            child: Text(
              activityHubText(
                context,
                'ngày nữa',
                days == 1 ? 'day to go' : 'days to go',
              ),
              key: Key('activity_card_countdown_$cardId'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
          ),
        ],
      ),
    );
  }
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
    this.wide = false,
  });

  final String cardId;
  final String label;
  final VoidCallback onTap;

  /// Fills the width it is given instead of hugging its label (D-5).
  final bool wide;

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
                widthFactor: wide ? null : 1,
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
