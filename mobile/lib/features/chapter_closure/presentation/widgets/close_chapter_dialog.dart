import 'package:flutter/material.dart';

import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../activity_cards/presentation/widgets/status_change_picker.dart';

/// The single confirmation between the user and a closed chapter (AC-2,
/// `ux/uiux-spec.md` §2), built on the same surface as the delete-card dialog
/// so the two destructive confirmations of stage 1 read identically.
///
/// The body is an inventory, not an argument: what closes, what is kept, and
/// that nothing is deleted. Absent by rule rather than by omission — a reason
/// field, a second "are you sure" step, a third deferral button, any line that
/// consoles or suggests reaching out again (AC-3, AC-4, AC-5, BR-9).
///
/// The journal is listed under what is kept because STORY-013 never closes it
/// (BR-6); the design frame `j11-dong-ngan-gon-gang` draws it on the closing
/// side, and the acceptance criterion wins over the frame.
Future<bool> showCloseChapterDialog(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final CupidColorTokens colors = dialogContext.cupidColors;
      final CupidPlatformTokens platform = dialogContext.cupidPlatform;
      final CupidTypographyTokens type = dialogContext.cupidType;

      return AlertDialog(
        key: const Key('close_chapter_dialog'),
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
            for (final List<String> line in _bodyLines) ...<Widget>[
              Text(
                closeChapterText(dialogContext, line),
                key: Key('close_chapter_fact_${_bodyLines.indexOf(line)}'),
                style: type.caption.copyWith(color: colors.colorTextMuted),
              ),
              if (line != _bodyLines.last)
                const SizedBox(height: CupidSpacing.sm),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          ActivityDialogChoiceButton(
            optionKey: const Key('close_chapter_cancel'),
            label: closeChapterText(dialogContext, _cancelLabel),
            color: colors.colorText,
            onTap: () => Navigator.of(dialogContext).pop(false),
          ),
          ActivityDialogChoiceButton(
            optionKey: const Key('close_chapter_confirm'),
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

/// Picks the Vietnamese or English half of a `[vi, en]` pair. Same shape as the
/// activity hub's own helper, kept local so this feature does not depend on
/// that one for its copy.
String closeChapterText(BuildContext context, List<String> pair) =>
    Localizations.localeOf(context).languageCode == 'vi' ? pair.first : pair.last;

const List<String> _title = <String>[
  'Đóng ngăn gọn gàng?',
  'Close this chapter?',
];

const List<String> _cancelLabel = <String>['Huỷ', 'Cancel'];

const List<String> _confirmLabel = <String>['Đóng ngăn', 'Close'];

/// The facts the confirmation states, in order. Public so the phase test can
/// assert the rendered strings against the same source the dialog draws from.
const List<List<String>> closeChapterFacts = _bodyLines;

const List<List<String>> _bodyLines = <List<String>>[
  <String>[
    'Sẽ đóng: thẻ và lời mời đã gắn người, sổ tay người yêu, '
        'câu hỏi gợi chuyện đã trả lời.',
    'Closing: cards and invites linked to a person, the partner notebook, '
        'and answered conversation prompts.',
  ],
  <String>[
    'Giữ lại: hồ sơ kỹ năng của bạn, nhật ký riêng, và những thẻ '
        'chưa gắn tên ai.',
    'Kept: your skill profile, your private journal, and cards that are not '
        'linked to anyone.',
  ],
  <String>[
    'Dữ liệu không bị xoá. Mục đã đóng nằm trong kho đã đóng.',
    'Nothing is deleted. Closed items live in the closed drawer.',
  ],
];
