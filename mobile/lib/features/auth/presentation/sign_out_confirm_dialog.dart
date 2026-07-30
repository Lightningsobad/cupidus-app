import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'auth_strings.dart';

/// AC4 destructive-pattern sign-out confirmation (`ux/uiux-spec.md` section
/// 5): a standard confirm dialog, not a hold-gesture — hold-gestures are
/// reserved for partner-facing rituals (e.g. the Love Contract sign), not
/// this solo, device-local action. `showDialog`/`AlertDialog` already trap
/// focus within the dialog and return it to the triggering control on
/// pop/cancel (section 7 accessibility), so no extra focus handling is
/// added here.
///
/// Returns `true` only if the user tapped the destructive confirm action;
/// cancelling, tapping the barrier, or dismissing (e.g. back button)
/// resolve to `false`.
Future<bool> showSignOutConfirmDialog(BuildContext context) async {
  final CupidColorTokens colors = context.cupidColors;
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(dialogContext.viEn('Đăng xuất?', 'Log out?')),
      content: Text(
        dialogContext.viEn(
          'Ảnh và dữ liệu riêng tư trên máy này sẽ bị xoá.',
          'Photos and private data on this device will be cleared.',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(dialogContext.viEn('Huỷ', 'Cancel')),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: colors.colorRed),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(dialogContext.viEn('Đăng xuất', 'Log out')),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
