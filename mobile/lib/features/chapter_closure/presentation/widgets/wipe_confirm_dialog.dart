import 'package:flutter/material.dart';

import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../activity_cards/presentation/widgets/status_change_picker.dart';
import 'close_chapter_dialog.dart';

/// The one and only confirmation before stage-1 data is wiped (AC-26, AC-28,
/// `ux/uiux-spec.md` §2 and §7). Returns `true` only on an explicit tap.
///
/// The body states scope and irreversibility as fact and stops there. Ruled out
/// by the spec rather than overlooked: a question, a reason field, any line that
/// argues or laments, a retention offer, a second confirmation step, a red
/// surface, a warning icon. Only the destructive label carries `colorRed`, so
/// the colour marks which button wipes instead of pushing the user away from it.
Future<bool> showWipeConfirmDialog(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final CupidColorTokens colors = dialogContext.cupidColors;
      final CupidPlatformTokens platform = dialogContext.cupidPlatform;
      final CupidTypographyTokens type = dialogContext.cupidType;

      return AlertDialog(
        key: const Key('wipe_confirm_dialog'),
        backgroundColor: colors.colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(platform.radiusCard),
        ),
        title: Text(
          closeChapterText(dialogContext, _title),
          style: type.body.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.colorText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final List<String> line in wipeConfirmFacts) ...<Widget>[
              Text(
                closeChapterText(dialogContext, line),
                key: Key('wipe_confirm_fact_${wipeConfirmFacts.indexOf(line)}'),
                style: type.caption.copyWith(color: colors.colorTextMuted),
              ),
              if (line != wipeConfirmFacts.last)
                const SizedBox(height: CupidSpacing.sm),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          ActivityDialogChoiceButton(
            optionKey: const Key('wipe_confirm_cancel'),
            label: closeChapterText(dialogContext, _cancelLabel),
            color: colors.colorText,
            onTap: () => Navigator.of(dialogContext).pop(false),
          ),
          ActivityDialogChoiceButton(
            optionKey: const Key('wipe_confirm_accept'),
            label: closeChapterText(dialogContext, _confirmLabel),
            color: colors.colorRed,
            onTap: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

const List<String> _title = <String>[
  'Xoá hết dữ liệu chặng 1?',
  'Erase all stage-1 data?',
];

const List<String> _cancelLabel = <String>['Huỷ', 'Cancel'];

const List<String> _confirmLabel = <String>['Xoá sạch', 'Erase'];

/// The facts the confirmation states, in order. Public so the phase test can
/// assert the rendered strings against the same source the dialog draws from.
const List<List<String>> wipeConfirmFacts = <List<String>>[
  <String>[
    'Xoá toàn bộ dữ liệu chặng 1: thẻ, sổ tay, hồ sơ kỹ năng, '
        'nhật ký và ảnh, chân dung, kết quả ăn khớp, lời mời, bộ đếm.',
    'Erases all stage-1 data: cards, notebooks, skill profile, journal and '
        'photos, portrait, match results, invites, counters.',
  ],
  <String>[
    'Không hoàn tác được. Tài khoản của bạn vẫn còn, app trở về '
        'trạng thái mới cài.',
    'This cannot be undone. Your account stays; the app returns to its '
        'freshly installed state.',
  ],
];
