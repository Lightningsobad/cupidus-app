import 'package:flutter/material.dart';

import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import 'activity_status_filter.dart';
import 'status_change_picker.dart';

/// The single confirmation between the user and a deleted card (AC-16,
/// `ux/uiux-spec.md` §5). Returns `true` only on an explicit "Xoá" tap.
///
/// Deliberately absent, each because the spec rules it out rather than because
/// it was overlooked: a reason field, any copy that argues with the choice
/// ("chắc chưa?", "tiếc quá"), a red-tinted dialog surface, and a second
/// confirmation step. The dialog is a plain surface with two identically drawn
/// buttons; only the destructive label carries `colorRed`, so the color marks
/// which button deletes rather than pressuring the user away from it.
Future<bool> showDeleteCardDialog(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final CupidColorTokens colors = dialogContext.cupidColors;
      final CupidPlatformTokens platform = dialogContext.cupidPlatform;
      final CupidTypographyTokens type = dialogContext.cupidType;

      return AlertDialog(
        key: const Key('delete_card_dialog'),
        backgroundColor: colors.colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(platform.radiusCard),
        ),
        title: Text(
          activityHubText(dialogContext, 'Xoá thẻ này?', 'Delete this card?'),
          style: type.body.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.colorText,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          ActivityDialogChoiceButton(
            optionKey: const Key('delete_card_cancel'),
            label: activityHubText(dialogContext, 'Huỷ', 'Cancel'),
            color: colors.colorText,
            onTap: () => Navigator.of(dialogContext).pop(false),
          ),
          ActivityDialogChoiceButton(
            optionKey: const Key('delete_card_confirm'),
            label: activityHubText(dialogContext, 'Xoá', 'Delete'),
            color: colors.colorRed,
            onTap: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
