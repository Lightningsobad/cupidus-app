import 'package:flutter/material.dart';

import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import 'activity_status_filter.dart';

/// The three lifecycle choices A-1 moved off the detail body and onto the
/// header (`master-plan.md` §12.2). There are exactly three, and each one opens
/// exactly one dialog or sheet at one level: no value here opens a second menu,
/// a submenu, or an intermediate screen before the action it names.
enum CardDetailOverflowAction { changeStatus, delete, markReply }

String cardDetailOverflowActionLabel(
  BuildContext context,
  CardDetailOverflowAction action,
) {
  switch (action) {
    case CardDetailOverflowAction.changeStatus:
      return activityHubText(context, 'Chuyển trạng thái', 'Change status');
    case CardDetailOverflowAction.delete:
      return activityHubText(context, 'Xoá thẻ', 'Delete card');
    case CardDetailOverflowAction.markReply:
      return activityHubText(
        context,
        'Đánh dấu đã trả lời / chưa trả lời',
        'Mark answered / not answered',
      );
  }
}

IconData cardDetailOverflowActionIcon(CardDetailOverflowAction action) {
  switch (action) {
    case CardDetailOverflowAction.changeStatus:
      return CupidIcons.history;
    case CardDetailOverflowAction.delete:
      return CupidIcons.delete;
    case CardDetailOverflowAction.markReply:
      return CupidIcons.check;
  }
}

/// The detail header's overflow (A-1). The glyph is the literal ellipsis
/// character rather than an icon codepoint, matching the P4 tile's own
/// overflow: this font's cmap carries no `more_horiz`, and §12.5 forbids
/// inventing one.
///
/// The character is U+2026 `…`, the same one the P4 tile renders. `master-plan`
/// §12.2 writes the affordance as `⋯` (U+22EF), which neither bundled text font
/// carries — it rasterizes as a tofu box. U+2026 is the ellipsis both
/// `Nunito-Variable.ttf` and `Roboto-Variable.ttf` actually publish.
class CardDetailOverflowMenu extends StatelessWidget {
  const CardDetailOverflowMenu({super.key, required this.onSelected});

  final ValueChanged<CardDetailOverflowAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return PopupMenuButton<CardDetailOverflowAction>(
      key: const Key('card_detail_overflow'),
      onSelected: onSelected,
      color: colors.colorSurface,
      tooltip: activityHubText(context, 'Lựa chọn khác', 'More options'),
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<CardDetailOverflowAction>>[
        for (final CardDetailOverflowAction action
            in CardDetailOverflowAction.values)
          PopupMenuItem<CardDetailOverflowAction>(
            key: Key('card_detail_overflow_${action.name}'),
            value: action,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  cardDetailOverflowActionIcon(action),
                  size: 18,
                  color: action == CardDetailOverflowAction.delete
                      ? colors.colorRed
                      : colors.colorText,
                ),
                const SizedBox(width: CupidSpacing.sm),
                Flexible(
                  child: Text(
                    cardDetailOverflowActionLabel(context, action),
                    style: type.body.copyWith(
                      color: action == CardDetailOverflowAction.delete
                          ? colors.colorRed
                          : colors.colorText,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      child: SizedBox(
        width: platform.tapTarget,
        height: platform.tapTarget,
        child: Center(
          child: Text(
            '…',
            style: type.body.copyWith(
              fontSize: 20,
              color: colors.colorTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}
